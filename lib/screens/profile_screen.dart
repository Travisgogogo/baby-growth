import 'package:flutter/material.dart';

 class ProfileScreen extends StatelessWidget {
   const ProfileScreen({super.key});

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: const Text('我的'),
         backgroundColor: const Color(0xFF667eea),
         foregroundColor: Colors.white,
       ),
       body: const Center(child: Text('个人中心页面')),
     );
   }
 }