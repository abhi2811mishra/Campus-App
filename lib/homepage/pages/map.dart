import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class CampusMapPage extends StatefulWidget {
  const CampusMapPage({super.key});

  @override
  State<CampusMapPage> createState() => _CampusMapPageState();
}

class _CampusMapPageState extends State<CampusMapPage> {
  late final MapController _mapController;
  LatLng _currentLocation = const LatLng(23.0225, 72.5714);
  bool _locationLoaded = false;
  // ignore: unused_field
  String _searchQuery = '';

  final List<Map<String, dynamic>> buildings = [
    {
      "name": "Library",
      "location": LatLng(23.0221, 72.5710),
    },
    {
      "name": "Admin Block",
      "location": LatLng(23.0228, 72.5716),
    },
    {
      "name": "Computer Lab",
      "location": LatLng(23.0232, 72.5719),
    },
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getPermissionAndLocation();
  }

  Future<void> _getPermissionAndLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _locationLoaded = true;
        });
      } catch (e) {
        debugPrint('Location error: $e');
        setState(() => _locationLoaded = true); // fallback
      }
    } else {
      debugPrint('Permission denied');
      setState(() => _locationLoaded = true); // fallback
    }
  }

  void _launchGoogleMaps(LatLng destination) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=${_currentLocation.latitude},${_currentLocation.longitude}&destination=${destination.latitude},${destination.longitude}&travelmode=walking';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Campus Map")),
      body: !_locationLoaded
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search for a building...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                      final match = buildings.firstWhere(
                        (b) => b["name"].toLowerCase().contains(value.toLowerCase()),
                        orElse: () => {},
                      );
                      if (match.isNotEmpty) {
                        _mapController.move(match["location"], 18);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation,
                      initialZoom: 17,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.campusapp',
                      ),
                      MarkerLayer(
                        markers: [
                          // Current location
                          Marker(
                            point: _currentLocation,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.my_location, color: Colors.blue, size: 36),
                          ),
                          // Building markers
                          ...buildings.map((b) => Marker(
                                point: b['location'],
                                width: 40,
                                height: 40,
                                child: GestureDetector(
                                  onTap: () => showModalBottomSheet(
                                    context: context,
                                    builder: (_) => Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(b['name'],
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 8),
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                _launchGoogleMaps(b['location']),
                                            icon: const Icon(Icons.navigation),
                                            label: const Text("Navigate"),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  child: const Icon(Icons.location_on,
                                      color: Colors.red, size: 40),
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
