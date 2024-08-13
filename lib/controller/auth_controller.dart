import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:metroshuttle/models/user_model/user_model.dart';
import 'package:metroshuttle/views/coordinator/coordinator_homescreen.dart';
import 'package:metroshuttle/views/coordinator/coordinator_profile.dart';
import 'package:metroshuttle/views/driver/driverhome.dart';

import 'package:metroshuttle/views/parent/parent_homescreen.dart';
import 'package:metroshuttle/views/profile_settings.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:path/path.dart' as Path;

import '../utils/app_constants.dart';
import '../views/driver/profile_setup.dart';

class AuthController extends GetxController {
  String userUid = '';
  var verId = '';
  int? resendTokenId;
  bool phoneAuthCheck = false;
  dynamic credentials;

  var isProfileUploading = false.obs;

  bool isLoginAsDriver = false;
  bool isLoginAsUser = false;
  bool isLoginAsCoordinator = false;

  storeUserCard(String number, String expiry, String cvv, String name) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cards')
        .add({'name': name, 'number': number, 'cvv': cvv, 'expiry': expiry});

    return true;
  }

  RxList userCards = [].obs;

  Future<void> storeOneSignalPlayerId() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? playerId =
            await OneSignal.shared.getDeviceState().then((deviceState) {
          return deviceState?.userId;
        });

        if (playerId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'oneSignalPlayerId': playerId,
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      // Handle errors here
      print('Error storing OneSignal player ID: $e');
    }
  }

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
      log("Error occured $e");
    }
  }

  verifyOtp(String otpNumber) async {
    log("Called");
    PhoneAuthCredential credential =
        PhoneAuthProvider.credential(verificationId: verId, smsCode: otpNumber);

    log("LogedIn");

    await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      decideRoute();
    }).catchError((e) {
      print("Error while sign In $e");
    });
  }

  var isDecided = false;

  void decideRoute() {
    if (isDecided) return;

    isDecided = true;
    print("called");

    // Step 1: Check if the user is logged in
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid; // Get the user ID

      // Step 2: Fetch the user profile and determine the route
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((value) async {
        await storeOneSignalPlayerId(); // Store the device token after confirming the user's profile

        if (value.exists) {
          final String userType = value.data()?['userType'] ?? '';

          switch (userType) {
            case 'driver':
              Get.offAll(() => DriverHomeScreen(userId: userId));
              break;
            case 'user':
              Get.offAll(() => ParentHomeScreen(userId: userId));
              break;
            case 'coordinator':
              Get.offAll(() => CoordinatorHomeScreen(userId: userId));
              break;
            default:
              print('Unknown user type: $userType');
          }
        } else {
          if (isLoginAsDriver) {
            Get.offAll(() => DriverProfileSetup(userId: userId));
          } else if (isLoginAsUser) {
            Get.offAll(() => ProfileSettingScreen());
          } else if (isLoginAsCoordinator) {
            Get.offAll(() => CoordinatorProfile(userId: userId));
          }
        }
      }).catchError((e) {
        print("Error in decideRoute: $e");
      });
    } else {
      print('User is not logged in');
    }
  }
}
