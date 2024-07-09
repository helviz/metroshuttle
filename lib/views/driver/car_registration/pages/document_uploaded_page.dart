import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentUploadedPage extends StatefulWidget {
  const DocumentUploadedPage({Key? key}) : super(key: key);



  @override
  State<DocumentUploadedPage> createState() => _DocumentUploadedPageState();
}

class _DocumentUploadedPageState extends State<DocumentUploadedPage> {




  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

      Text('Upload Documents',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: Colors.black),),

    SizedBox(height: 30,),

