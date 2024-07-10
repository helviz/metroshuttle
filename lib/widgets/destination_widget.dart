import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class DestinationWidget extends StatefulWidget {
  const DestinationWidget({super.key});

  @override
  State<DestinationWidget> createState() => _DestinationWidgetState();
}

class _DestinationWidgetState extends State<DestinationWidget> {
  final _formkey = GlobalKey();
  final List<String> division = ['Central', 'Kawempe', 'Rubaga', 'Nakawa', 'Makindye'];

  final List<Map<String, String>> destinationData = [
    {
      'division' : 'Central',
      'parish' : ''
    }
  ];

  String? _division;
  String? _parish;


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Column(
        children: [
          Text('Choose location', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
          SizedBox(height: 15,),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
            hintText: 'Select division',
            hintStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            border: InputBorder.none,
          ),
          items: division.map((division) { 
            return DropdownMenuItem(
              value: division,
              child: Text('$division Division', style: GoogleFonts.poppins( fontSize: 14,
              fontWeight: FontWeight.bold,) )
            );
          }).toList(), 
          onChanged: (String? value) {  },

          ),
        ],

    ))
    
      ;
  }
}