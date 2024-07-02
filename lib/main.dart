import 'package:flutter/material.dart';
import 'package:metroshuttle/views/maps.dart';

void main() {
  runApp(const MaterialApp(
    home: Home(),
  ));
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return  const Maps();
  }
}