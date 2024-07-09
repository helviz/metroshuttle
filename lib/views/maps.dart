// import 'package:flutter/material.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:google_maps_webservice/places.dart';


// class Maps extends StatefulWidget {
//    const Maps({super.key});

//   @override
//   State<Maps> createState() => _MapsState();
// }

// class _MapsState extends State<Maps> {

//   String ? _mapStyle;

//   @override
//   void initState() {
//     super.initState();
//    _loadMapStyle();
//   }

//    Future<void> _loadMapStyle() async {
//     final style = await rootBundle.loadString('assets/map_style.txt');
//     setState(() {
//       _mapStyle = style;
//     });
//   }

//    final CameraPosition _sourceDestination = const CameraPosition(
//     target: LatLng(0.347596, 32.582520),
//     zoom: 14.4746,
//   );

//   @override
//   Widget build(BuildContext context) {


//     Future<String> showGoogleAutoComplete() async {
  
//   Prediction ? p = await  PlacesAutocomplete.show(
//     context: context,
//     apiKey: "AIzaSyAGPzzZXp4o0xEnGCemV-_gGcLpJum4Hes",
//     offset: 0,
//     radius: 1000,
//     strictbounds: false,
//     region: 'us',
//     language: 'en',
//     mode: Mode.overlay,
//     components: [Component(Component.country, 'us')],
//     types: ['(cities)'],
//     hint: 'Search'
//   );
//   return p!.description!;
//     }

//     Widget buildTextFieldForSource() {
//     return Positioned(
//       top: 170,
//       left: 20,
//       right: 20,
//       child: Container(
//         height: 50,
//         padding: const EdgeInsets.only(left: 15),
//         decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   spreadRadius: 4,
//                   blurRadius: 10)
//             ],
//             borderRadius: BorderRadius.circular(8)),
//         child: TextFormField(
//           controller: sourceController,
//            readOnly: true,
//            onTap: () async { String selectedPlace = await showGoogleAutoComplete();
//            sourceController!.text = selectedPlace;
//            showDestinationField = true;},
//            style: GoogleFonts.poppins(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//           decoration: InputDecoration(
//             hintText: 'Your location',
//             hintStyle: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//             suffixIcon: const Padding(
//               padding: EdgeInsets.only(left: 10),
//               child: Icon(
//                 Icons.search,
//               ),
//             ),
//             border: InputBorder.none,
//           ),
//         ),
//       ),
//     );
//   }

//     return  Scaffold(
//       body: Stack(
//         children: [
//           Positioned(
//             top: 180,
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: GoogleMap(
//               zoomControlsEnabled: false,
//             onMapCreated: (GoogleMapController controller) {

//               if (_mapStyle != null) {

//                 }
//                          }, initialCameraPosition:  _sourceDestination , style: _mapStyle,),

//           ),
//           buildProfileTile(), 
//           buildTextFieldForSource(),
//           // showDestinationField ? buildTextFieldForDestination(context) : Container(),
//           buildTextFieldForDestination(context),

//           buildCurrentLocationIcon(),
//           buildNotificationIcon(),
//           buildBottomSheet(),

//       ]));
//   }
// }

// Widget buildProfileTile() {
//     return Positioned(
//       top: 60,
//       left: 20,
//       right: 20,
//       child: Row(
//        children: [
//         const CircleAvatar(backgroundColor: Colors.orange ,
//         radius: 30,),
//         const SizedBox(width: 15,),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(text: const TextSpan(
//               children: [
//                 TextSpan(text: 'Hello, ', style: TextStyle(color: Colors.black,fontSize: 14)),
//                 TextSpan(text: 'Martin', style: TextStyle(color: Colors.orange,fontSize: 16))
//                 ])),
//                 const SizedBox(height: 10,),
//                 const Text('Where are you going?',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)

//                 ]

//         )
//       ],
//             ));
//     }

// TextEditingController ? destinationController;
// TextEditingController ? sourceController;
// bool showDestinationField = false;


// Widget buildTextFieldForDestination(context) {
//     return Positioned(
//       top: 170,
//       left: 20,
//       right: 20,
//       child: Container(
//         height: 50,
//         padding: const EdgeInsets.only(left: 15),
//         decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   spreadRadius: 4,
//                   blurRadius: 10)
//             ],
//             borderRadius: BorderRadius.circular(8)),
//         child: TextFormField(
//           controller: destinationController,
//            readOnly: true,
//            onTap: () { 
//             showModalBottomSheet(context: context, builder: (context) { 
//               return Container(
//               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 100),
//               child: const Text('Bottom Sheet'),
//             ); });
//              },
//           decoration: InputDecoration(
//             hintText: 'Select destination',
//             hintStyle: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//             suffixIcon: const Padding(
//               padding: EdgeInsets.only(left: 10),
//               child: Icon(
//                 Icons.search,
//               ),
//             ),
//             border: InputBorder.none,
//           ),
//         ),
//       ),
//     );
//   }


// Widget buildCurrentLocationIcon() {
//   return Align(
//     alignment: Alignment.bottomRight,
//     child: Padding(
//       padding: const EdgeInsets.only(bottom: 30, right: 8),
//       child: CircleAvatar(backgroundColor: Colors.orange,radius: 25,
//       child: IconButton(icon: const Icon(Icons.my_location,color: Colors.white,), onPressed: (){}),
//     ),
//   ));
// }

// Widget buildNotificationIcon() {
//   return Align(
//     alignment: Alignment.bottomLeft,
//     child: Padding(padding: const EdgeInsets.only(bottom: 30,left: 8), child:
//     CircleAvatar(backgroundColor: Colors.orange, radius: 20,
//     child: IconButton(onPressed: () {}, icon: const Icon(Icons.notification_add, color: Colors.white,)),),),
//     );
// }

// Widget buildBottomSheet() {
//   return Align(
//     alignment: Alignment.bottomCenter,
//     child: Container(
//       height: 20,width: 250,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             spreadRadius: 4,
//             blurRadius: 10,
//           )
//         ],
//         borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))
//       ),
//       child: Center(
//         child: Container(
//           height: 4,
//           width: 200,
//           color: Colors.black,
//         ),
//       ),
//     ),
//   );
// }