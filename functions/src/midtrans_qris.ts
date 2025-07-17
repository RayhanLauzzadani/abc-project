import { onRequest } from "firebase-functions/v2/https";
import type { Request, Response } from "express";
import axios from "axios";

/**
 * Cloud Functions v2: Best practice
 * - Use onRequest from v2/https
 * - Secret is injected via process.env (set via: firebase functions:secrets:set MIDTRANS_SERVER_KEY)
 * - Clear error handling, avoid sending large/verbose errors to client
 */
export const createQrisTransaction = onRequest(
  { secrets: ["MIDTRANS_SERVER_KEY"] }, // <<<< penting! agar secret disuntik ke env
  async (req: Request, res: Response) => {
    const midtransServerKey = process.env.MIDTRANS_SERVER_KEY;
    if (!midtransServerKey) {
      res.status(500).send("Server configuration error: midtransServerKey is missing.");
      return;
    }
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }
    const { amount, orderId, customerName, customerEmail } = req.body;
    if (!amount || !orderId) {
      res.status(400).send("amount dan orderId wajib diisi");
      return;
    }
    try {
      const response = await axios.post(
        "https://api.sandbox.midtrans.com/v2/charge",
        {
          payment_type: "qris",
          transaction_details: { order_id: orderId, gross_amount: amount },
          customer_details: { first_name: customerName, email: customerEmail },
          qris: {},
        },
        {
          headers: {
            "Content-Type": "application/json",
            Authorization: "Basic " + Buffer.from(midtransServerKey + ":").toString("base64"),
          },
        }
      );
      res.status(200).json(response.data);
    } catch (error: any) {
      // Only return error message and status
      console.error("MIDTRANS ERROR:", error?.response?.data || error.message || error);
      res.status(500).json({
        message: error?.message || "Unknown Error",
        midtrans: error?.response?.data || null,
      });
    }
  }
);
