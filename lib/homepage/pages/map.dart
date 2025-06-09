import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleMapSearchPage extends StatefulWidget {
  @override
  _GoogleMapSearchPageState createState() => _GoogleMapSearchPageState();
}

class _GoogleMapSearchPageState extends State<GoogleMapSearchPage> {
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  LatLng _initialPosition = LatLng(26.9363, 75.9235); // Default to SF

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _markers.add(Marker(
            markerId: MarkerId('current'),
            position: _initialPosition,
            infoWindow: InfoWindow(title: 'Your Location')));
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _searchAndNavigate(String placeName) async {
    try {
      List<Location> locations = await locationFromAddress(placeName);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final newPosition = LatLng(location.latitude, location.longitude);

        mapController.animateCamera(CameraUpdate.newLatLngZoom(newPosition, 15));
        setState(() {
          _markers.add(Marker(
            markerId: MarkerId(placeName),
            position: newPosition,
            infoWindow: InfoWindow(title: placeName),
          ));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Place not found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Map ')),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 12,
            ),
            markers: _markers,
            myLocationEnabled: true,
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search places...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      final query = _searchController.text.trim();
                      if (query.isNotEmpty) {
                        _searchAndNavigate(query);
                      }
                    },
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: _searchAndNavigate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}