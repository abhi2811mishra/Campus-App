import 'package:flutter/material.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: unused_import
import 'package:permission_handler/permission_handler.dart';

class GoogleMapSearchPage extends StatefulWidget {
  const GoogleMapSearchPage({super.key}); // Added const constructor

  @override
  _GoogleMapSearchPageState createState() => _GoogleMapSearchPageState();
}

class _GoogleMapSearchPageState extends State<GoogleMapSearchPage> {
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  // Default to a location near Kalol, Gujarat, India
  LatLng _initialPosition = const LatLng(23.2384, 72.5008); // Kalol, Gujarat, India

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper function to show a SnackBar
  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled. Please enable them.', backgroundColor: Colors.orange);
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions are denied.', backgroundColor: Colors.red);
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(
          'Location permissions are permanently denied, we cannot request permissions.', backgroundColor: Colors.red);
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _markers.clear(); // Clear existing markers before adding current location
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: _initialPosition,
            infoWindow: const InfoWindow(title: 'Your Current Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // Blue marker for current location
          ),
        );
      });
      mapController.animateCamera(CameraUpdate.newLatLngZoom(_initialPosition, 15)); // Animate to current location
      _showSnackBar('Current location updated!', backgroundColor: Colors.green);
    } catch (e) {
      _showSnackBar('Could not get current location: $e', backgroundColor: Colors.red);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Animate to the initial position (either default or current location)
    mapController.animateCamera(CameraUpdate.newLatLngZoom(_initialPosition, 12));
  }

  Future<void> _searchAndNavigate(String placeName) async {
    if (placeName.isEmpty) {
      _showSnackBar('Please enter a place name to search.');
      return;
    }

    try {
      List<Location> locations = await locationFromAddress(placeName);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final newPosition = LatLng(location.latitude, location.longitude);

        mapController.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 15));
        setState(() {
          // Clear previous search markers, keep current location if present
          _markers.removeWhere((marker) => marker.markerId.value != 'currentLocation');
          _markers.add(
            Marker(
              markerId: MarkerId(placeName),
              position: newPosition,
              infoWindow: InfoWindow(title: placeName, snippet: 'Searched Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Red marker for search results
            ),
          );
        });
        _showSnackBar('Found: $placeName', backgroundColor: Colors.green);
      } else {
        _showSnackBar('Place not found. Try a more specific name.');
      }
    } catch (e) {
      print('Error searching place: $e'); // For debugging
      _showSnackBar('Failed to search for place. Check network or name.', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Campus Map', // More descriptive title
          style: TextStyle(
            fontSize: 26, // Larger title
            fontWeight: FontWeight.w800, // Heavier weight
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.lightBlue.shade700, // Darker blue for app bar
        elevation: 4, // Add a subtle shadow
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white, size: 30),
            tooltip: 'Go to My Current Location',
            onPressed: () {
              _determinePosition();
            },
          ),
          const SizedBox(width: 10), // Add some spacing
        ],
        iconTheme: const IconThemeData(color: Colors.white), // Ensures back button (if any) is white
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 12,
            ),
            markers: _markers,
            myLocationEnabled: true, // Shows blue dot for user's current location
            myLocationButtonEnabled: false, // Hide default button, use custom one
            zoomControlsEnabled: false, // Hide default zoom controls
          ),
          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8, // Increased elevation for a floating effect
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // More rounded shape
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0), // Padding inside the card
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search for places or campus areas...', // More descriptive hint
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    border: InputBorder.none, // Remove default border
                    prefixIcon: Icon(Icons.search, color: Colors.blue.shade700), // Themed search icon
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey.shade600),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                // Optionally clear search markers when clearing text
                                _markers.removeWhere((marker) => marker.markerId.value != 'currentLocation');
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14), // Vertically center content
                  ),
                  onChanged: (text) {
                    setState(() {}); // Rebuild to show/hide clear icon
                  },
                  onSubmitted: _searchAndNavigate,
                  cursorColor: Colors.lightBlue.shade700, // Themed cursor
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoomInBtn',
                  onPressed: () {
                    mapController.animateCamera(CameraUpdate.zoomIn());
                  },
                  backgroundColor: Colors.lightBlue.shade600,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add, size: 30),
                  elevation: 6,
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'zoomOutBtn',
                  onPressed: () {
                    mapController.animateCamera(CameraUpdate.zoomOut());
                  },
                  backgroundColor: Colors.lightBlue.shade600,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.remove, size: 30),
                  elevation: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}