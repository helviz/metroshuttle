import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverMapPage extends StatefulWidget {
  @override
  _DriverMapPageState createState() => _DriverMapPageState();
}

class _DriverMapPageState extends State<DriverMapPage> {
  GoogleMapController? _controller;
  LatLng _initialPosition = LatLng(0.3476, 32.5825); // Kampala coordinates
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchRoutesFromFirestore();
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
        _markers.add(
          Marker(
            markerId: MarkerId('pickup_${doc.id}'),
            position: pickupLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(title: 'Pickup: $childsName', snippet: 'HOME'),
          ),
        );

        _markers.add(
          Marker(
            markerId: MarkerId('destination_${doc.id}'),
            position: destinationLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(title: 'Destination: $childsName', snippet: "SCHOOL"),
          ),
        );
      });
    });
  }

  LatLng _parseCoordinates(String coordinates) {
    List<String> parts = coordinates.split(',');
    double lat = double.parse(parts[0]);
    double lng = double.parse(parts[1]);
    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Map'),
      ),
      body: GoogleMap(
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
      ),
    );
  }
}
