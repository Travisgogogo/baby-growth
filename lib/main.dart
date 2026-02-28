import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  // 捕获 Flutter 错误
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack: ${details.stack}');
  };
  
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
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: '-apple-system, BlinkMacSystemFont, Segoe UI, Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}