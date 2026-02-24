import 'package:flutter/material.dart';

 class GrowthChartScreen extends StatelessWidget {
   const GrowthChartScreen({super.key});

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: const Text('生长曲线'),
         backgroundColor: const Color(0xFF667eea),
         foregroundColor: Colors.white,
       ),
       body: const Center(child: Text('生长曲线详细页面')),
     );
   }
 }