const fs = require('fs');
const path = require('path');

// Load environment variables manually from .env file if it exists
try {
    const envPath = path.join(__dirname, '.env');
    if (fs.existsSync(envPath)) {
        const envConfig = fs.readFileSync(envPath, 'utf8');
        envConfig.split(/\r?\n/).forEach(line => {
            const parts = line.split('=');
            if (parts.length >= 2) {
                const key = parts[0].trim();
                const value = parts.slice(1).join('=').trim().replace(/^['"]|['"]$/g, '');
                if (key) {
                    process.env[key] = value;
                }
            }
        });
    }
} catch (e) {
    console.error('Gagal memuat file .env:', e);
}

const express = require('express');
const midtransClient = require('midtrans-client');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();

// Middleware
app.use(cors()); // Agar bisa diakses dari aplikasi Flutter
app.use(bodyParser.json());

/**
 * 1. KONFIGURASI MIDTRANS
 * Ambil Server Key & Client Key dari Dashboard Midtrans Settings -> Access Keys
 */
let snap = new midtransClient.Snap({
    isProduction: false, // Disamakan dengan Laravel (false) agar bisa jalan
    serverKey: process.env.MIDTRANS_SERVER_KEY || 'Mid-server-PLACEHOLDER', // Gunakan environment variable dari .env
    clientKey: process.env.MIDTRANS_CLIENT_KEY || 'Mid-client-PLACEHOLDER'  // Gunakan environment variable dari .env
});

/**
 * 2. ENDPOINT UNTUK MENDAPATKAN SNAP TOKEN
 */
app.post('/snap-token', async (req, res) => {
    try {
        console.log('Menerima request pembayaran:', req.body);

        let parameter = {
            "transaction_details": {
                "order_id": req.body.order_id,
                "gross_amount": Math.round(req.body.gross_amount) // Pastikan integer
            },
            "item_details": [
                {
                    "id": "ITEM1",
                    "price": Math.round(req.body.gross_amount),
                    "quantity": 1,
                    "name": "FitMotion Professional Subscription"
                }
            ],
            "customer_details": {
                "first_name": req.body.first_name,
                "email": req.body.email
            },
            "credit_card": {
                "secure": true
            }
        };

        // Buat transaksi ke Midtrans
        const transaction = await snap.createTransaction(parameter);

        console.log('Snap Token Berhasil Dibuat:', transaction.token);

        res.json({
            token: transaction.token,
            redirect_url: transaction.redirect_url
        });

    } catch (e) {
        console.error('Midtrans Error Detail:', e);
        res.status(500).json({
            status: 'error',
            message: e.message,
            ApiResponse: e.ApiResponse // Log detail dari Midtrans
        });
    }
});



// Jalankan Server
const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`==========================================`);
    console.log(` FitMotion Payment & Email Middleware Berjalan! `);
    console.log(` Port: ${PORT} `);
    console.log(` URL Internal: http://localhost:${PORT} `);
    console.log(`==========================================`);
});
