import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerDialog extends StatefulWidget {
  final LatLng initialLocation;

  const MapPickerDialog({
    super.key,
    required this.initialLocation,
  });

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  late LatLng _selectedLatLng;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedLatLng = widget.initialLocation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determineInitialLocation();
    });
  }

  Future<void> _determineInitialLocation() async {
    if (widget.initialLocation.latitude == -6.2000 && widget.initialLocation.longitude == 106.8166) {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return;

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) return;
        }
        
        if (permission == LocationPermission.deniedForever) return;

        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 4),
        );
        
        if (mounted) {
          setState(() {
            _selectedLatLng = LatLng(position.latitude, position.longitude);
          });
          _mapController.move(_selectedLatLng, 15.0);
        }
      } catch (e) {
        debugPrint('MapPickerDialog auto GPS error: $e');
      }
    }
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
      appBar: AppBar(
        title: const Text('Tentukan Lokasi', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: CloseButton(
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, _selectedLatLng);
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLatLng,
              initialZoom: 14.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLatLng = point;
                });
              },
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
                    point: _selectedLatLng,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 24,
            right: 24,
            child: FloatingActionButton(
              heroTag: 'my_location_btn',
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
                  final targetLatLng = LatLng(position.latitude, position.longitude);
                  setState(() {
                    _selectedLatLng = targetLatLng;
                  });
                  _mapController.move(targetLatLng, 15.0);
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
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      const Text('Koordinat Terpilih:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lat: ${_selectedLatLng.latitude.toStringAsFixed(6)} | Lng: ${_selectedLatLng.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context, _selectedLatLng);
                      },
                      child: const Text('Konfirmasi Lokasi', style: TextStyle(fontWeight: FontWeight.bold)),
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
