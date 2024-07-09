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

