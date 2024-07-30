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
// import 'package:metroshuttle/views/driver/car_registration/car_registration_template.dart';
// import 'package:metroshuttle/views/home.dart';
import 'package:metroshuttle/views/parent/parent_homescreen.dart';
import 'package:metroshuttle/views/profile_settings.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
// import 'package:metroshuttle/views/profile_settings.dart';
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
      String? playerId = await OneSignal.shared.getDeviceState().then((deviceState) {
        return deviceState?.userId;
      });

      if (playerId != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
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
    if (isDecided) {
      return;
    }
    isDecided = true;
    print("called");

    // Step 1: Check user login
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid; // Get the user ID

      // Step 2: Check whether user profile exists
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((value) async {
            // Store the device token after confirming the user's profile
        await storeOneSignalPlayerId();;

        
        if (isLoginAsDriver) {
          if (value.exists) {
            Get.offAll(() => DriverHomeScreen(userId: userId));
          } else {
            Get.offAll(() => DriverProfileSetup(userId: userId));
          }
        } else if (isLoginAsUser) {
          if (value.exists) {
            Get.offAll(() => ParentHomeScreen(userId: userId));
          } else {
            Get.offAll(() => ProfileSettingScreen());
          }
        } else if (isLoginAsCoordinator) {
          if (value.exists) {
            Get.offAll(() => CoordinatorHomeScreen(userId: userId));
          } else {
            Get.offAll(() => CoordinatorProfile());
          }
        }
      }).catchError((e) {
        print("Error while decideRoute is $e");
      });
    }
  }

  uploadImage(File image) async {
    String imageUrl = '';
    String fileName = Path.basename(image.path);
    var reference = FirebaseStorage.instance
        .ref()
        .child('users/$fileName'); // Modify this path/string as your need
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then(
      (value) {
        imageUrl = value;
        print("Download URL: $value");
      },
    );

    return imageUrl;
  }

  storeUserInfo(
    File? selectedImage,
    String parentname,
    String parentcontact,
    String home, {
    // String business,
    // String shop, {
    String url = '',
    LatLng? homeLatLng,
    LatLng? businessLatLng,
    // LatLng? shoppingLatLng,
  }) async {
    String url_new = url;
    if (selectedImage != null) {
      url_new = await uploadImage(selectedImage);
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      'image': url_new,
      'name': parentname,
      'contact': parentcontact,
      'homeAddress': home,
      // 'business_address': business,
      // 'shopping_address': shop,
      'home_latlng': GeoPoint(homeLatLng!.latitude, homeLatLng.longitude),
      'business_latlng':
          GeoPoint(businessLatLng!.latitude, businessLatLng.longitude),
      // 'shopping_latlng':
      // GeoPoint(shoppingLatLng!.latitude, shoppingLatLng.longitude),
    }, SetOptions(merge: true)).then((value) {
      isProfileUploading(false);

      // Get.to(() => HomeScreen());
    });
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
      hint: "Search City",
    );

    return p;
  }

  Future<LatLng> buildLatLngFromAddress(String place) async {
    List<geoCoding.Location> locations =
        await geoCoding.locationFromAddress(place);
    return LatLng(locations.first.latitude, locations.first.longitude);
  }

  storeDriverProfile(
    File? selectedImage,
    String name,
    String email, {
    String url = '',
  }) async {
    String url_new = url;
    if (selectedImage != null) {
      url_new = await uploadImage(selectedImage);
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'image': url_new, 'name': name, 'email': email, 'isDriver': true},
        SetOptions(merge: true)).then((value) {
      isProfileUploading(false);

      // Get.off(()=> DriverHomeScreen());
    });
  }

// Future<bool> uploadCarEntry(Map<String,dynamic> carData)async{
//   bool isUploaded = false;
//   String uid = FirebaseAuth.instance.currentUser!.uid;

//   await FirebaseFirestore.instance.collection('users').doc(uid).set(carData,SetOptions(merge: true));

//   isUploaded = true;

//   return isUploaded;
// }
}
