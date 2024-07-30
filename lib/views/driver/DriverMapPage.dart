import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverMapPage extends StatefulWidget {
  @override
  _DriverMapPageState createState() => _DriverMapPageState();
}

class _DriverMapPageState extends State<DriverMapPage> {
  GoogleMapController? _controller;
  LatLng _initialPosition = LatLng(0.3476, 32.5825);
  Set<Marker> _markers = {};
  Set<Marker> _homeMarkers = {};
  Set<Marker> _schoolMarkers = {};
  Set<Polyline> _polylines = {};
  bool _isPickupToDestination = true;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _fetchRoutesFromFirestore();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    setState(() {
      _currentLocation = LatLng(_locationData.latitude!, _locationData.longitude!);
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          infoWindow: InfoWindow(title: 'Current Location'),
        ),
      );
      _controller?.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 15));
    });
  }

  Future<void> _fetchRoutesFromFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No user is logged in');
      return;
    }

    String userId = user.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference driverRoutes = firestore.collection('driverRoutes');

    QuerySnapshot querySnapshot = await driverRoutes.where('driverId', isEqualTo: userId).get();

    querySnapshot.docs.forEach((doc) {
      String pickupLocation = doc['pickupLocation'];
      String destinationLocation = doc['destination'];
      String childsName = doc['childsName'];

      LatLng pickupLatLng = _parseCoordinates(pickupLocation);
      LatLng destinationLatLng = _parseCoordinates(destinationLocation);

      setState(() {
        Marker homeMarker = Marker(
          markerId: MarkerId('pickup_${doc.id}'),
          position: pickupLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: 'Pickup: $childsName', snippet: 'HOME'),
          onTap: () => _showRemoveMarkerDialog('pickup_${doc.id}'),
        );

        Marker schoolMarker = Marker(
          markerId: MarkerId('destination_${doc.id}'),
          position: destinationLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'Destination: $childsName', snippet: 'SCHOOL'),
          onTap: () => _showRemoveMarkerDialog('destination_${doc.id}'),
        );

        _homeMarkers.add(homeMarker);
        _schoolMarkers.add(schoolMarker);

        _drawRoute(pickupLatLng, destinationLatLng);
      });
    });
  }

  LatLng _parseCoordinates(String coordinates) {
    List<String> parts = coordinates.split(',');
    double lat = double.parse(parts[0]);
    double lng = double.parse(parts[1]);
    return LatLng(lat, lng);
  }

  Future<void> _drawRoute(LatLng pickupLatLng, LatLng destinationLatLng) async {
    LatLng start = _isPickupToDestination ? pickupLatLng : destinationLatLng;
    LatLng end = _isPickupToDestination ? destinationLatLng : pickupLatLng;

    // Google Routes API endpoint
    String url =
        'https://routes.googleapis.com/maps/api/directions/v1/computeRoutes:json?key=AIzaSyANZU1sirqFeP1RbaXOtEJE3LsLSgUM9WU';

    var requestBody = {
      'originAddresses': ['${start.latitude},${start.longitude}'],
      'destinationAddresses': ['${end.latitude},${end.longitude}'],
      'travelMode': 'DRIVING', // Use 'DRIVE' or 'DRIVING' as per the API specification
    };

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var polylinePoints = data['routes'][0]['polyline']['points'];
      var decodedPoints = _decodePolyline(polylinePoints);

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('${start.latitude},${start.longitude}'),
            points: decodedPoints,
            color: Colors.blue,
            width: 5,
          ),
        );
      });
    } else {
      print('Failed to load route: ${response.statusCode}');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng p = LatLng(lat / 1E5, lng / 1E5);
      polyline.add(p);
    }

    return polyline;
  }

  void _showCurrentLocation() {
    if (_currentLocation != null) {
      _controller?.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 15));
    } else {
      _getCurrentLocation();
    }
  }

  void _showMarkers(Set<Marker> markersToShow) {
    setState(() {
      _markers.clear();
      _markers.addAll(markersToShow);
    });
  }

  void _showRemoveMarkerDialog(String markerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Marker'),
        content: Text('Do you want to remove this marker?'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _markers.removeWhere((marker) => marker.markerId.value == markerId);
                _homeMarkers.removeWhere((marker) => marker.markerId.value == markerId);
                _schoolMarkers.removeWhere((marker) => marker.markerId.value == markerId);
              });
              Navigator.of(context).pop();
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 12.0,
            ),
            mapType: MapType.hybrid, // Set map type to hybrid
            onMapCreated: (controller) {
              setState(() {
                _controller = controller;
              });
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 20,
            left: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () => _showMarkers(_homeMarkers),
                  child: Icon(Icons.home),
                  tooltip: 'Show Home Markers',
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () => _showMarkers(_schoolMarkers),
                  child: Icon(Icons.school),
                  tooltip: 'Show School Markers',
                ),
                SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _showCurrentLocation,
                  child: Icon(Icons.my_location),
                  tooltip: 'Show Current Location',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
