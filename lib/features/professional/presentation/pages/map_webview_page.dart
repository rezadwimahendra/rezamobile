import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapWebViewPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String gymName;

  const MapWebViewPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.gymName,
  });

  @override
  State<MapWebViewPage> createState() => _MapWebViewPageState();
}

class _MapWebViewPageState extends State<MapWebViewPage> {
  late final WebViewController? _controller;
  bool _isLoading = true;
  late final String _url;

  @override
  void initState() {
    super.initState();
    _url = "https://www.openstreetmap.org/?mlat=${widget.latitude}&mlon=${widget.longitude}#map=16/${widget.latitude}/${widget.longitude}";
    
    // Inisialisasi controller hanya jika bukan web (karena webview_flutter tidak didukung di web)
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
              },
            ),
          )
          ..loadRequest(Uri.parse(_url));
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
        title: Text(widget.gymName, style: const TextStyle(color: Colors.black, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: CloseButton(
          onPressed: () => Navigator.pop(context),
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
                    const Icon(Icons.map_outlined, size: 80, color: Color(0xFFFFB800)),
                    const SizedBox(height: 24),
                    Text(
                      widget.gymName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Koordinat: ${widget.latitude}, ${widget.longitude}",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Peta interaktif tidak dapat dibuka langsung di dalam browser web karena keterbatasan browser sandbox.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
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
                          launchUrl(Uri.parse(_url), mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text(
                          "Buka di Browser Tab Baru",
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
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFB800)),
                  ),
              ],
            ),
    );
  }
}
