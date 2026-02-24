import 'package:flutter/material.dart';
 import 'screens/home_screen.dart';

 void main() {
   runApp(const BabyGrowthApp());
 }

 class BabyGrowthApp extends StatelessWidget {
   const BabyGrowthApp({super.key});

   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       title: '宝宝成长记',
       debugShowCheckedModeBanner: false,
       theme: ThemeData(
         colorScheme: ColorScheme.fromSeed(
           seedColor: const Color(0xFF667eea),
           brightness: Brightness.light,
         ),
         useMaterial3: true,
         fontFamily: '-apple-system, BlinkMacSystemFont, Segoe UI, Roboto',
       ),
       home: const HomeScreen(),
     );
   }
 }