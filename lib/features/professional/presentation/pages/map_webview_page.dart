import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

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
  final MapController _mapController = MapController();
  late LatLng _gymLocation;

  @override
  void initState() {
    super.initState();
    _gymLocation = LatLng(widget.latitude, widget.longitude);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFFFB800);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.gymName, 
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: CloseButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _gymLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                subdomains: const ['0', '1', '2', '3'],
                userAgentPackageName: 'com.example.fitness_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _gymLocation,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 44,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // My Location Button
          Positioned(
            top: 24,
            right: 24,
            child: FloatingActionButton(
              heroTag: 'gym_view_my_location_btn',
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: () async {
                try {
                  LocationPermission permission = await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied) return;
                  }
                  if (permission == LocationPermission.deniedForever) return;
                  
                  final Position position = await Geolocator.getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.high,
                  );
                  final userLatLng = LatLng(position.latitude, position.longitude);
                  _mapController.move(userLatLng, 15.0);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal mendapatkan lokasi GPS: $e')),
                    );
                  }
                }
              },
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
          // Gym Position Centering Button
          Positioned(
            top: 80,
            right: 24,
            child: FloatingActionButton(
              heroTag: 'gym_view_target_location_btn',
              mini: true,
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                _mapController.move(_gymLocation, 15.0);
              },
              child: const Icon(Icons.fitness_center, color: Colors.red),
            ),
          ),
          // Clean bottom UI card for gym details
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, color: Colors.red, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.gymName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Lokasi Hub Mitra Gym',
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.explore_outlined, color: Colors.grey, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Koordinat: ${widget.latitude.toStringAsFixed(5)}, ${widget.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        _mapController.move(_gymLocation, 16.0);
                      },
                      icon: const Icon(Icons.explore, size: 20),
                      child: const Text('Fokus ke Lokasi Gym', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
