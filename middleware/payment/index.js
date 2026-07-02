const express = require('express');
const midtransClient = require('midtrans-client');
const bodyParser = require('body-parser');
const cors = require('cors');
const nodemailer = require('nodemailer');

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
    serverKey: process.env.MIDTRANS_SERVER_KEY || 'Mid-server-PLACEHOLDER', // Gunakan environment variable
    clientKey: process.env.MIDTRANS_CLIENT_KEY || 'Mid-client-PLACEHOLDER'  // Gunakan environment variable
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

/**
 * 3. ENDPOINT UNTUK MENGIRIM LAPORAN ASUPAN KALORI HARI INI VIA SMTP (EMAIL)
 */
app.post('/send-report', async (req, res) => {
    try {
        const { email, userName, date, totalCalories, goalCalories, remainingCalories, meals } = req.body;
        
        console.log(`Menerima request kirim laporan untuk email: ${email}`);

        // Konfigurasi SMTP Transport (Bisa customize via ENV jika diproduksi)
        const smtpHost = process.env.SMTP_HOST || 'smtp.gmail.com'; 
        const smtpPort = parseInt(process.env.SMTP_PORT || '587');
        const smtpUser = process.env.SMTP_USER; 
        const smtpPass = process.env.SMTP_PASS;

        let transporter;

        if (!smtpUser) {
            // JIKA TIDAK ADA ENV SMTP: Gunakan Ethereal (Test SMTP) otomatis agar langsung jalan untuk testing mahasiswa!
            console.log('Menggunakan test account SMTP Ethereal...');
            let testAccount = await nodemailer.createTestAccount();
            transporter = nodemailer.createTransport({
                host: "smtp.ethereal.email",
                port: 587,
                secure: false, 
                auth: {
                    user: testAccount.user, 
                    pass: testAccount.pass, 
                },
            });
        } else {
            transporter = nodemailer.createTransport({
                host: smtpHost,
                port: smtpPort,
                secure: smtpPort === 465, 
                auth: {
                    user: smtpUser,
                    pass: smtpPass,
                },
            });
        }

        // Susun HTML Makanan
        let mealsHtml = '';
        if (meals && meals.length > 0) {
            mealsHtml = meals.map(meal => {
                const foodName = meal.name || 'Makanan';
                const calories = meal.calories || 0;
                const mealType = (meal.mealType || 'Makanan').toUpperCase();
                return `
                    <tr style="border-bottom: 1px solid #eee;">
                        <td style="padding: 10px; font-weight: bold; color: #555; text-transform: uppercase;">[${mealType}]</td>
                        <td style="padding: 10px;">${foodName}</td>
                        <td style="padding: 10px; text-align: right; font-weight: bold; color: #333;">${calories} kal</td>
                    </tr>
                `;
            }).join('');
        } else {
            mealsHtml = `<tr><td colspan="3" style="padding: 20px; text-align: center; color: #999;">Belum ada makanan dicatat hari ini.</td></tr>`;
        }

        // Susun Email HTML yang premium / wowed
        const mailOptions = {
            from: '"FitMotion App" <noreply@fitmotion.com>',
            to: email,
            subject: `Laporan Ringkasan Kalori Harian - ${date}`,
            html: `
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 12px; background-color: #fff;">
                <div style="text-align: center; background-color: #FFB800; padding: 20px; border-radius: 8px 8px 0 0;">
                    <h1 style="margin: 0; color: #000; font-size: 24px; font-weight: bold;">Laporan Harian FitMotion</h1>
                    <p style="margin: 5px 0 0 0; color: #333; font-size: 14px;">Halo ${userName || 'Pengguna'}, berikut adalah asupan kalori harian Anda.</p>
                </div>
                
                <div style="padding: 20px;">
                    <h3 style="color: #666; margin-top: 0;">Ringkasan Nutrisi (${date})</h3>
                    
                    <table style="width: 100%; margin-bottom: 20px; background-color: #f9f9f9; padding: 15px; border-radius: 8px; border-collapse: collapse;">
                        <tr>
                            <td style="text-align: center; width: 33%;">
                                <span style="font-size: 11px; color: #888; display: block; text-transform: uppercase;">Target Kalori</span>
                                <strong style="font-size: 16px; color: #333;">${goalCalories} kal</strong>
                            </td>
                            <td style="text-align: center; width: 34%; border-left: 1px solid #ddd; border-right: 1px solid #ddd;">
                                <span style="font-size: 11px; color: #888; display: block; text-transform: uppercase;">Dikonsumsi</span>
                                <strong style="font-size: 16px; color: #de3e3b;">${totalCalories} kal</strong>
                            </td>
                            <td style="text-align: center; width: 33%;">
                                <span style="font-size: 11px; color: #888; display: block; text-transform: uppercase;">Sisa Kalori</span>
                                <strong style="font-size: 16px; color: #2e7d32;">${remainingCalories} kal</strong>
                            </td>
                        </tr>
                    </table>

                    <h4 style="border-bottom: 2px solid #FFB800; padding-bottom: 8px; color: #333; margin-bottom: 10px;">Detail Asupan Makanan</h4>
                    <table style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="background-color: #f5f5f5;">
                                <th style="text-align: left; padding: 10px; font-size: 13px; color: #666; width: 25%;">Waktu</th>
                                <th style="text-align: left; padding: 10px; font-size: 13px; color: #666; width: 50%;">Makanan</th>
                                <th style="text-align: right; padding: 10px; font-size: 13px; color: #666; width: 25%;">Kalori</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${mealsHtml}
                        </tbody>
                    </table>
                </div>

                <div style="text-align: center; margin-top: 30px; padding-top: 15px; border-top: 1px solid #eee; font-size: 12px; color: #999;">
                    <p style="margin: 0;">Dikirim secara otomatis dari aplikasi FitMotion.</p>
                    <p style="margin: 5px 0 0 0;">Tetap jaga pola makan dan capai gaya hidup sehat Anda!</p>
                </div>
            </div>
            `
        };

        // Kirim email
        let info = await transporter.sendMail(mailOptions);
        console.log("Email berhasil dikirim: %s", info.messageId);

        // Jika pakai testAccount SMTP Ethereal, kita log link preview url nya agar mahasiswa gampang cek!
        let previewUrl = nodemailer.getTestMessageUrl(info);
        if (previewUrl) {
            console.log("==========================================");
            console.log("PREVIEW EMAIL (Nodemailer Ethereal):");
            console.log(previewUrl);
            console.log("==========================================");
        }
        
        res.json({
            status: 'success',
            message: 'Laporan berhasil dikirim ke email Anda!',
            messageId: info.messageId,
            previewUrl: previewUrl || null
        });

    } catch (e) {
        console.error('SMTP Email Error Detail:', e);
        res.status(500).json({
            status: 'error',
            message: e.message
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
