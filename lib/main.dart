import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metroshuttle/views/decision_screen/decission_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:metroshuttle/controller/auth_controller.dart';
import 'firebase_options.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize OneSignal
  OneSignal.shared.setAppId("c4a0b63b-3d62-43be-813c-aa05d3b023b2");

  
  OneSignal.shared
      .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    print('Notification opened: ${result.notification.jsonRepresentation()}');
  });

  // Optional: Set notification received handler
  OneSignal.shared.setNotificationWillShowInForegroundHandler(
      (OSNotificationReceivedEvent event) {
    print(
        'Notification received in foreground: ${event.notification.jsonRepresentation()}');
    event.complete(event.notification);
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put(AuthController());
    authController.decideRoute();
    final textTheme = Theme.of(context).textTheme;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(textTheme),
      ),
      home: DecisionScreen(),
    );
  }
}
