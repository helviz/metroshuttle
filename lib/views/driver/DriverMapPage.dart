import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverMapPage extends StatefulWidget {
  @override
  _DriverMapPageState createState() => _DriverMapPageState();
}

class _DriverMapPageState extends State<DriverMapPage> {
  GoogleMapController? _controller;
  LatLng _initialPosition = LatLng(37.7749, -122.4194); // Example initial position

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _initialPosition,
        zoom: 12.0,
      ),
      onMapCreated: (controller) {
        setState(() {
          _controller = controller;
        });
      },
    );
  }
}
