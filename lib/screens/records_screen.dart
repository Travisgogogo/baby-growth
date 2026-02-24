import 'package:flutter/material.dart';

 class RecordsScreen extends StatelessWidget {
   const RecordsScreen({super.key});

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: const Text('全部记录'),
         backgroundColor: const Color(0xFF667eea),
         foregroundColor: Colors.white,
       ),
       body: const Center(child: Text('记录列表页面')),
     );
   }
 }