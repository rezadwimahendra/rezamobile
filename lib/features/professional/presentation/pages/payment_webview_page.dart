import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;
  
  const PaymentWebViewPage({super.key, required this.paymentUrl});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

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
            // Midtrans Sandbox sering menggunakan kode 200 untuk sukses, 201 untuk pending, 202 untuk error
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Aman', style: TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: CloseButton(
          onPressed: () {
            // Tampilkan konfirmasi batal jika diinginkan
            Navigator.pop(context, false);
          }
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.black54),
            ),
        ],
      ),
    );
  }
}
