import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CampusMapPage extends StatefulWidget {
  const CampusMapPage({super.key});

  @override
  State<CampusMapPage> createState() => _CampusMapPageState();
}

class _CampusMapPageState extends State<CampusMapPage> {
  LatLng _currentLocation = const LatLng(23.0225, 72.5714); // Fallback location
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _getPermissionAndLocation();
  }

  Future<void> _getPermissionAndLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
          // ignore: deprecated_member_use
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _locationLoaded = true;
        });
      } catch (e) {
        debugPrint('Location error: $e');
        setState(() => _locationLoaded = true); // use fallback
      }
    } else {
      debugPrint('Permission denied');
      setState(() => _locationLoaded = true); // use fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Campus Map")),
      body: !_locationLoaded
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 17,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.campusapp',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

