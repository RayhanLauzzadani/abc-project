import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import * as dotenv from "dotenv";
import * as sgMail from "@sendgrid/mail";

dotenv.config();
admin.initializeApp();

const db = admin.firestore();

const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY!;
const SENDER_EMAIL = process.env.SENDGRID_SENDER_EMAIL!;

sgMail.setApiKey(SENDGRID_API_KEY);

// Fungsi untuk generate 4 digit OTP
function generateOTP(): string {
  return Math.floor(1000 + Math.random() * 9000).toString();
}

// Tipe data untuk permintaan OTP
interface RequestData {
  email: string;
}

// Fungsi utama untuk mengirim OTP ke email
export const sendOtpToEmail = functions.https.onCall(
  async (
    data: unknown,
    _context
  ): Promise<{ success: boolean; message: string }> => {
    const {email} = data as RequestData;

    if (!email) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Email wajib diisi."
      );
    }

    const otp = generateOTP();
    const createdAt = admin.firestore.Timestamp.now();
    const expiresAt = admin.firestore.Timestamp.fromMillis(
      createdAt.toMillis() + 5 * 60 * 1000
    );

    await db.collection("otp_codes").doc(email).set({
      email,
      otp,
      createdAt,
      expiresAt,
    });

    const msg = {
      to: email,
      from: SENDER_EMAIL,
      subject: "Kode OTP Verifikasi Anda",
      text: `Kode OTP Anda adalah ${otp}. Berlaku selama 5 menit.`,
      html:
        `<p>Kode OTP Anda adalah <strong>${otp}</strong>.<br />` +
        "Berlaku selama 5 menit.</p>",
    };

    try {
      await sgMail.send(msg);
      return {success: true, message: "OTP berhasil dikirim."};
    } catch (error) {
      console.error("Gagal mengirim email:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Gagal mengirim email."
      );
    }
  }
);
