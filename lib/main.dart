import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'models/reminder.dart';

void main() async {
  // 确保 Flutter 绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 捕获 Flutter 错误
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack: ${details.stack}');
  };
  
  // 初始化通知服务
  await notificationService.init();
  // 请求通知权限
  await notificationService.requestPermission();
  
  // 调度所有已启用的提醒
  await _scheduleAllEnabledReminders();
  
  runApp(const BabyGrowthApp());
}

/// 调度所有已启用的提醒
Future<void> _scheduleAllEnabledReminders() async {
  try {
    final babies = await DatabaseService.instance.getAllBabies();
    if (babies.isNotEmpty) {
      final baby = babies.first;
      if (baby.id != null) {
        final reminders = await DatabaseService.instance.getEnabledReminders(baby.id!);
        for (final reminder in reminders) {
          await notificationService.scheduleReminder(reminder);
        }
        print('已调度 ${reminders.length} 个提醒');
      }
    }
  } catch (e) {
    print('调度提醒失败: $e');
  }
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
    // 当应用进入后台时关闭数据库，返回前台时重新打开
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      DatabaseService.instance.close();
    } else if (state == AppLifecycleState.resumed) {
      // 应用返回前台时重新初始化数据库
      DatabaseService.instance.database;
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