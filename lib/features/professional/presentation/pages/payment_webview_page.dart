import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fitness_app/utils/url_helper.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  
  const PaymentWebViewPage({super.key, required this.paymentUrl});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      try {
        _controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() => _isLoading = true);
              },
              onPageFinished: (String url) {
                setState(() => _isLoading = false);
                debugPrint("DEBUG: WebView mengarah ke -> $url");
                
                // Deteksi jika Midtrans mengarahkan ke halaman finish/success (URL Callback)
                if (url.contains('finish') || url.contains('success') || url.contains('transaction_status=settlement') || url.contains('/200')) {
                  debugPrint("DEBUG: Deteksi SUKSES! Menutup WebView...");
                  Navigator.pop(context, true); 
                } else if (url.contains('error') || url.contains('failed') || url.contains('status_code=500')) {
                  debugPrint("DEBUG: Deteksi GAGAL! Menutup WebView...");
                  Navigator.pop(context, false);
                }
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint("WebView Error: ${error.description}");
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.paymentUrl));
      } catch (e) {
        _controller = null;
        _isLoading = false;
      }
    } else {
      _controller = null;
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showWebFallback = kIsWeb || _controller == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Aman', style: TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: CloseButton(
          onPressed: () {
            Navigator.pop(context, false);
          }
        ),
      ),
      body: showWebFallback
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.payment_outlined, size: 80, color: Color(0xFFFFB800)),
                    const SizedBox(height: 24),
                    const Text(
                      "Pembayaran Midtrans",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Untuk transaksi yang aman, silakan klik tombol di bawah untuk membuka gateway pembayaran Midtrans di tab baru browser Anda.",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB800),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          openUrl(widget.paymentUrl);
                          
                          // Tampilkan konfirmasi manual di dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Text("Konfirmasi Pembayaran"),
                              content: const Text("Apakah Anda sudah menyelesaikan pembayaran di tab baru browser?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Belum", style: TextStyle(color: Colors.grey)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFB800),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context); // Tutup dialog
                                    Navigator.pop(context, true); // Kirim return true (Sukses)
                                  },
                                  child: const Text("Ya, Sudah", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text(
                          "Buka Halaman Pembayaran",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.black54),
                  ),
              ],
            ),
    );
  }
}
