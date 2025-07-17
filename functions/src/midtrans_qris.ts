
import * as functions from "firebase-functions";
import axios from "axios";

const midtransServerKey = functions.config().midtrans.server_key;
console.log('midtransServerKey:', midtransServerKey);

export const createQrisTransaction = functions.https.onRequest(async (req, res) => {
  if (!midtransServerKey) {
    console.error('Missing midtransServerKey config!');
    res.status(500).send('Server configuration error: midtransServerKey is missing.');
    return;
  }
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }
  const {amount, orderId, customerName, customerEmail} = req.body;
  if (!amount || !orderId) {
    res.status(400).send("amount dan orderId wajib diisi");
    return;
  }
  try {
    const response = await axios.post(
      "https://api.sandbox.midtrans.com/v2/charge",
      {
        payment_type: "qris",
        transaction_details: {order_id: orderId, gross_amount: amount},
        customer_details: {first_name: customerName, email: customerEmail},
        qris: {},
      },
      {
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic " + Buffer.from(midtransServerKey + ":").toString("base64"),
        },
      }
    );
    res.status(200).json(response.data);
  } catch (error) {
    res.status(500).send((error as any).response?.data || (error as any).message || "Error");
  }
});
