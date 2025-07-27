import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController _mapController;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: CameraPosition(
          target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 14.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        markers: {
          Marker(
            markerId: const MarkerId('ubicacion_usuario'),
            position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            infoWindow: const InfoWindow(title: 'Tu ubicación'),
          ),
        },
      ),
    );
  }
}
