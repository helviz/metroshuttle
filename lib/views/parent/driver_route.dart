// parent_driver_route.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class ParentDriverRoute extends StatefulWidget {
  @override
  _ParentDriverRouteState createState() => _ParentDriverRouteState();
}

class _ParentDriverRouteState extends State<ParentDriverRoute> {
  GoogleMapController _mapController;
  Set<Marker> _markers = Set();
  Set<Polyline> _polylines = Set();
  List<LatLng> _routeCoordinates = [];
  bool _consentGiven = false;

  Future<void> _loadRouteData() async {
    // Retrieve route data from API or database
    final response = await http.get(Uri.parse('https://example.com/api/driver-route'));

    if (response.statusCode == 200) {
      // Parse route data
      final jsonData = jsonDecode(response.body);
      _routeCoordinates = jsonData['route_coordinates'];

      // Add markers and polylines to the map
      _addMarkersAndPolylines();
    } else {
      // Handle error
      print('Error loading route data: ${response.statusCode}');
    }
  }

  void _addMarkersAndPolylines() {
    _markers.clear();
    _polylines.clear();

    for (int i = 0; i < _routeCoordinates.length; i++) {
      _markers.add(Marker(
        markerId: MarkerId(i.toString()),
        position: _routeCoordinates[i],
        infoWindow: InfoWindow(title: 'Stop ${i + 1}'),
      ));

      if (i > 0) {
        _polylines.add(Polyline(
          polylineId: PolylineId(i.toString()),
          points: [_routeCoordinates[i - 1], _routeCoordinates[i]],
          color: Colors.blue,
          width: 5,
        ));
      }
    }
  }

  void _giveConsent() {
    setState(() {
      _consentGiven = true;
    });

    // Send consent to API or database
    http.post(Uri.parse('https://example.com/api/consent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'consent': true}));

    Fluttertoast.showToast(msg: 'Consent given successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver\'s Current Route'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _routeCoordinates.first,
                zoom: 15,
              ),
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _consentGiven ? null : _giveConsent,
              child: Text(_consentGiven ? 'Consent given' : 'Give consent'),
            ),
          ),
        ],
      ),
    );
  }
}