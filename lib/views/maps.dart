import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class Maps extends StatelessWidget {
   Maps({super.key});
 
   final CameraPosition _sourceDestination = const CameraPosition(
    target: LatLng(0.347596, 32.582520),
    zoom: 14.4746,
  );
    GoogleMapController ? myMapController;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 180,
            left: 0,
            right: 0,
            bottom: 0,
            child: GoogleMap(
            mapType: MapType.terrain,
            onMapCreated: (GoogleMapController controller) {
              myMapController = controller;
            }, initialCameraPosition: _sourceDestination ),
          ),

          buildProfileTile(), 
      ]));
  }
}


Widget buildProfileTile() {
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Container( 
        child:  Row(
         children: [
          CircleAvatar(backgroundColor: Colors.grey[300] ,
          radius: 30,),
          SizedBox(width: 15,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              RichText(text: TextSpan(
                children: [
                  TextSpan(text: 'Hello, ', style: TextStyle(color: Colors.black,fontSize: 14)),
                  TextSpan(text: 'Martin', style: TextStyle(color: Colors.orange,fontSize: 16))
                  ])),
                  SizedBox(height: 10,),
                  Text('Where are you going?',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)

                  ]
            
          )
        ],
      )
    ));
    }
