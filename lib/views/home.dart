import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_webservice/places.dart';
import 'package:metroshuttle/views/my_profile.dart';

import '../controller/auth_controller.dart';
import '../controller/polyline_handler.dart';
import '../utils/app_colors.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'dart:ui' as ui;

import '../widgets/text_widget.dart';
import 'payment.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _mapStyle;

  AuthController authController = Get.find<AuthController>();

  late LatLng destination;
  late LatLng source;
  final Set<Polyline> _polyline = {};
  Set<Marker> markers = Set<Marker>();
  List<String> list = <String>[
    '**** **** **** 8789',
    '**** **** **** 8921',
    '**** **** **** 1233',
    '**** **** **** 4352'
  ];

  @override
  void initState() {
    super.initState();

    authController.getUserInfo();

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    loadCustomMarker();
  }

  String dropdownValue = '**** **** **** 8789';
  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(0.347596, 32.582520 ),
    zoom: 14.4746,
  );

  GoogleMapController? myMapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: GoogleMap(
              markers: markers,
              polylines: polyline,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                myMapController = controller;

                myMapController!.setMapStyle(_mapStyle);
              },
              initialCameraPosition: _kGooglePlex,
            ),
          ),
          buildProfileTile(),
          buildTextFieldForSource(),
          showDestinationField ? buildTextFieldForDestination() : Container(),
          buildCurrentLocationIcon(),
          buildNotificationIcon(),
          buildBottomSheet(),
        ],
      ),
    );
  }
