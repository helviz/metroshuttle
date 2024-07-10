import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:get/get.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:metroshuttle/utils/app_constants.dart';

class AuthController extends GetxController {
  String userUid = '';
  var verId = '';
  int? resendTokenId;
  bool phoneAuthCheck = false;
  dynamic credentials;

  set isDecided(bool isDecided) {}


  phoneAuth(String phone) async {
    try {
      credentials = null;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          log('Completed');
          credentials = credential;
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        forceResendingToken: resendTokenId,
        verificationFailed: (FirebaseAuthException e) {
          log('Failed');
          if (e.code == 'invalid-phone-number') {
            debugPrint('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          log('Code sent');
          verId = verificationId;
          resendTokenId = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      log("Error occurred $e");
    }
  }

  verifyOtp(String otpNumber) async {
    log("Called");
    PhoneAuthCredential credential =
    PhoneAuthProvider.credential(verificationId: verId, smsCode: otpNumber);

    log("LoggedIn");

    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  var myUser = UserModel().obs;

  getUserInfo() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((event) {
      myUser.value = UserModel.fromJson(event.data()!);
    });
  }

  Future<Prediction?> showGoogleAutoComplete(BuildContext context) async {
    Prediction? p = await PlacesAutocomplete.show(
      offset: 0,
      radius: 1000,
      strictbounds: false,
      region: "ug",
      language: "en",
      context: context,
      mode: Mode.overlay,
      apiKey: AppConstants.kGoogleApiKey,
      components: [new Component(Component.country, "ug")],
      types: [],
      hint: "Search",
    );

    return p;
  }

   Future<LatLng> buildLatLngFromAddress(String place) async {
    List<geoCoding.Location> locations =
        await geoCoding.locationFromAddress(place);
    return LatLng(locations.first.latitude, locations.first.longitude);
  }



}
