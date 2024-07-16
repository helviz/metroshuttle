import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';

class LocationPickerScreen extends StatefulWidget {
  final bool isPickup;

  LocationPickerScreen({required this.isPickup});

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController _mapController;
  final googlePlace = GooglePlace('AIzaSyCbWvKmyMR11ZwX9_-nD2OflivR3WFHQCA'); // Replace with your API key
  final TextEditingController _searchController = TextEditingController();
  LatLng? _selectedLocation;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _searchPlace(String place) async {
    var result = await googlePlace.autocomplete.get(
      place,
      location: LatLon(0.3476, 32.5825), // Kampala, Uganda
      radius: 5000, // limit the search to a 5km radius around Kampala
    );
    if (result != null && result.predictions != null && result.predictions!.isNotEmpty) {
      var prediction = result.predictions!.first;
      var detail = await googlePlace.details.get(prediction.placeId!);
      if (detail != null && detail.result != null) {
        var location = detail.result!.geometry!.location;
        if (location?.lat != null && location?.lng != null) {
          _mapController.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(location!.lat!, location.lng!),
            15.0,
          ));
          setState(() {
            _selectedLocation = LatLng(location.lat!, location.lng!);
          });
        } else {
          // Handle the case when lat or lng is null
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location data is not available')),
          );
        }
      }
    }
  }

  void _setMarker(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPickup ? 'Select Pick-up Location' : 'Select Destination Location'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a place (e.g., schools)',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchPlace(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(0.3476, 32.5825), // Kampala, Uganda
                zoom: 13.0,
              ),
              mapType: MapType.hybrid,
              onTap: (LatLng location) {
                _setMarker(location);
              },
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: MarkerId('selectedLocation'),
                        position: _selectedLocation!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                      ),
                    }
                  : {},
            ),
          ),
        ],
      ),
    );
  }
}
