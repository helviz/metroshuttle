import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserModel {
  // String? bAddress;
  String? hAddress;
  String? contact;
  String? name;
  String? image;

  LatLng? homeAddress;
  // LatLng? businessAddress;
  // LatLng? shoppingAddress;


  UserModel({this.name,this.contact,this.hAddress,this.image});

  UserModel.fromJson(Map<String,dynamic> json){
    // bAddress = json['business_address'];
    hAddress = json['home_address'];
    contact = json['contact'];
    // mallAddress = json['shopping_address'];
    name = json['name'];
    image = json['image'];
    homeAddress = LatLng(json['home_latlng'].latitude, json['home_latlng'].longitude);
    // bussinessAddres = LatLng(json['business_latlng'].latitude, json['business_latlng'].longitude);
    // shoppingAddress = LatLng(json['shopping_latlng'].latitude, json['shopping_latlng'].longitude);
  }
}