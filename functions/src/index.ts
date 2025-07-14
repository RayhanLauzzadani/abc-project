import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import sgMail from "@sendgrid/mail";
import type {Request, Response} from "express";

admin.initializeApp();

const db = admin.firestore();

const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY!;
const SENDER_EMAIL = process.env.SENDGRID_SENDER_EMAIL!;

sgMail.setApiKey(SENDGRID_API_KEY);

function generateOTP(): string {
  return Math.floor(1000 + Math.random() * 9000).toString();
}

export const sendOtpToEmail = functions.https.onRequest(
  async (req: Request, res: Response): Promise<void> => {
    if (req.method !== "POST") {
      res.status(405).send({success: false, message: "Method not allowed"});
      return;
    }

    const {email} = req.body;

    if (!email || typeof email !== "string") {
      res.status(400).send({success: false, message: "Email wajib diisi."});
      return;
    }

    const otp = generateOTP();
    const createdAt = admin.firestore.Timestamp.now();
    const expiresAt = admin.firestore.Timestamp.fromMillis(
      createdAt.toMillis() + 5 * 60 * 1000
    );

    try {
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
        html: `<p>Kode OTP Anda adalah <strong>${otp}</strong>.<br />Berlaku selama 5 menit.</p>`,
      };

      await sgMail.send(msg);
      res.status(200).send({success: true, message: "OTP berhasil dikirim."});
    } catch (error) {
      console.error("Gagal mengirim email:", error);
      res.status(500).send({success: false, message: "Gagal mengirim email."});
    }
  }
);
