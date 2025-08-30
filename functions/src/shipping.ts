import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import axios from "axios";

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

const REGION = "asia-southeast2";
const RATE_PER_100M = 250;
const STEP_METERS = 100;

// === NEW: secret for Maps key ===
const SERVER_MAPS_KEY = defineSecret("SERVER_MAPS_KEY");

// Ambil API key dari Secret/ENV (tanpa functions.config)
function getMapsKey(): string {
  const key =
    SERVER_MAPS_KEY.value() ||           // secret v2
    process.env.GOOGLE_MAPS_API_KEY ||   // optional: ENV runtime
    process.env.MAPS_API_KEY ||          // optional: ENV runtime
    process.env.MAPS_KEY;                // optional: ENV runtime
  if (!key) {
    throw new HttpsError(
      "failed-precondition",
      "Google Maps API key belum dikonfigurasi (Secret/ENV)."
    );
  }
  return key;
}

// Fallback (kalau API gagal) – jarak garis lurus (haversine)
function haversineMeters(a: {lat:number,lng:number}, b:{lat:number,lng:number}) {
  const R = 6371000;
  const toRad = (d:number)=> d*Math.PI/180;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const la1 = toRad(a.lat);
  const la2 = toRad(b.lat);
  const h = Math.sin(dLat/2)**2 + Math.cos(la1)*Math.cos(la2)*Math.sin(dLng/2)**2;
  return 2*R*Math.asin(Math.sqrt(h));
}

export const quoteDelivery = onCall({ region: REGION, secrets: [SERVER_MAPS_KEY] }, async (req) => {
  // Wajib login untuk tracing/kuota
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Login diperlukan.");

  const {
    storeId,
    storeLat,
    storeLng,
    buyerLat,
    buyerLng,
    mode = "driving",
  } = (req.data ?? {}) as Record<string, any>;

  // Validasi input buyer
  if (
    typeof buyerLat !== "number" ||
    typeof buyerLng !== "number" ||
    !Number.isFinite(buyerLat) ||
    !Number.isFinite(buyerLng)
  ) {
    throw new HttpsError("invalid-argument", "Koordinat buyer tidak valid.");
  }

  // Ambil koordinat toko
  let sLat: number | undefined = storeLat;
  let sLng: number | undefined = storeLng;

  if ((sLat == null || sLng == null) && typeof storeId === "string" && storeId) {
    const snap = await db.collection("stores").doc(storeId).get();
    if (!snap.exists) throw new HttpsError("not-found", "Store tidak ditemukan.");
    const d = snap.data()!;
    sLat = Number(d.latitude);
    sLng = Number(d.longitude);
  }

  if (
    typeof sLat !== "number" ||
    typeof sLng !== "number" ||
    !Number.isFinite(sLat) ||
    !Number.isFinite(sLng)
  ) {
    throw new HttpsError("invalid-argument", "Koordinat store tidak valid.");
  }

  const origin = `${sLat},${sLng}`;
  const dest = `${buyerLat},${buyerLng}`;

  // Panggil Distance Matrix (jarak rute jalan)
  let distanceMeters: number | undefined;
  let durationText = "";
  let distanceText = "";

   try {
    const key = getMapsKey();
    const url = "https://maps.googleapis.com/maps/api/distancematrix/json";
    const { data } = await axios.get(url, {
      params: { origins: origin, destinations: dest, mode, units: "metric", key },
      timeout: 10_000,
    });

    // Parse hasil
    if (data?.status === "OK" && data?.rows?.length) {
      const el = data.rows[0]?.elements?.[0];
      if (el?.status === "OK") {
        distanceMeters = Number(el.distance?.value);
        distanceText = String(el.distance?.text ?? "");
        durationText = String(el.duration?.text ?? "");
      }
    }
  } catch (e) {
    console.error("DistanceMatrix error:", e);
  }

  // Fallback: haversine
  if (!Number.isFinite(distanceMeters as number)) {
    distanceMeters = Math.round(
      haversineMeters({ lat: sLat!, lng: sLng! }, { lat: buyerLat, lng: buyerLng })
    );
    distanceText = `${(distanceMeters / 1000).toFixed(2)} km (garis lurus)`;
    durationText = "-";
  }

    // Hitung ongkir: minimal 1 step (100 m) × 250
    const dist = Math.max(0, Number(distanceMeters));   // clamp
    const rawSteps = Math.ceil(dist / STEP_METERS);
    const steps = Math.max(1, rawSteps);                // <- minimum charge
    const fee = steps * RATE_PER_100M;

  return {
    ok: true,
    distanceMeters,
    distanceText,
    durationText,
    fee,
    breakdown: {
        ratePer100m: RATE_PER_100M,
        stepMeters: STEP_METERS,
        steps,
        rawSteps,                        // optional
        minChargeApplied: steps > rawSteps ? true : false,
    },
    store: { lat: sLat, lng: sLng, id: storeId ?? null },
    buyer: { lat: buyerLat, lng: buyerLng },
  };
});
