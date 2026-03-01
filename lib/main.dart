import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';

void main() {
  // 捕获 Flutter 错误
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack: ${details.stack}');
  };
  
  // 确保数据库在应用退出时关闭
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const BabyGrowthApp());
}

class BabyGrowthApp extends StatefulWidget {
  const BabyGrowthApp({super.key});

  @override
  State<BabyGrowthApp> createState() => _BabyGrowthAppState();
}

class _BabyGrowthAppState extends State<BabyGrowthApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 当应用进入后台或退出时关闭数据库
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      DatabaseService.instance.close();
    }
  }

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