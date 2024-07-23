import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMapScreen extends StatefulWidget {
  final String pickupLocation;
  final String destinationLocation;

  LocationMapScreen({required this.pickupLocation, required this.destinationLocation});

  @override
  _LocationMapScreenState createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends State<LocationMapScreen> {
  late GoogleMapController _mapController;
  LatLng? _pickupLatLng;
  LatLng? _destinationLatLng;

  @override
  void initState() {
    super.initState();
    _pickupLatLng = _parseCoordinates(widget.pickupLocation);
    _destinationLatLng = _parseCoordinates(widget.destinationLocation);
  }

  LatLng _parseCoordinates(String coordinates) {
    List<String> parts = coordinates.split(',');
    double lat = double.parse(parts[0]);
    double lng = double.parse(parts[1]);
    return LatLng(lat, lng);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _moveCameraToFitLocations();
  }

  void _moveCameraToFitLocations() {
    if (_pickupLatLng != null && _destinationLatLng != null) {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          _pickupLatLng!.latitude < _destinationLatLng!.latitude
              ? _pickupLatLng!.latitude
              : _destinationLatLng!.latitude,
          _pickupLatLng!.longitude < _destinationLatLng!.longitude
              ? _pickupLatLng!.longitude
              : _destinationLatLng!.longitude,
        ),
        northeast: LatLng(
          _pickupLatLng!.latitude > _destinationLatLng!.latitude
              ? _pickupLatLng!.latitude
              : _destinationLatLng!.latitude,
          _pickupLatLng!.longitude > _destinationLatLng!.longitude
              ? _pickupLatLng!.longitude
              : _destinationLatLng!.longitude,
        ),
      );
      _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Location Map'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
          target: _pickupLatLng ?? LatLng(0, 0),
          zoom: 10.0,
        ),
        markers: {
          if (_pickupLatLng != null)
            Marker(
              markerId: MarkerId('pickupLocation'),
              position: _pickupLatLng!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              infoWindow: InfoWindow(title: 'Pickup Location', snippet: 'Here is the pickup location'),
            ),
          if (_destinationLatLng != null)
            Marker(
              markerId: MarkerId('destinationLocation'),
              position: _destinationLatLng!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              infoWindow: InfoWindow(title: 'Destination Location', snippet: 'Here is the destination location'),
            ),
        },
      ),
    );
  }
}
