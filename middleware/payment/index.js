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
                    process.env[key] = process.env[key] || value;
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
const isProd = process.env.MIDTRANS_IS_PRODUCTION === 'true';
const sKey = process.env.MIDTRANS_SERVER_KEY || '';
const cKey = process.env.MIDTRANS_CLIENT_KEY || '';

console.log('=== LOG DIAGNOSIS MIDTRANS ===');
console.log('Mode Production (isProduction):', isProd);
console.log('Nilai MIDTRANS_IS_PRODUCTION:', process.env.MIDTRANS_IS_PRODUCTION);
console.log('Panjang Server Key:', sKey.length);
console.log('Karakter Awal Server Key:', sKey.substring(0, 11));
console.log('Karakter Awal Client Key:', cKey.substring(0, 11));
console.log('=============================');

let snap = new midtransClient.Snap({
    isProduction: isProd,
    serverKey: sKey || 'Mid-server-PLACEHOLDER',
    clientKey: cKey || 'Mid-client-PLACEHOLDER'
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
const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`==========================================`);
    console.log(` FitMotion Payment & Email Middleware Berjalan! `);
    console.log(` Port: ${PORT} `);
    console.log(` URL Internal: http://localhost:${PORT} `);
    console.log(`==========================================`);
});
