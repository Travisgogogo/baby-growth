import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/reminder_list_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'models/baby.dart';
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
  
  // 初始化通知服务，设置点击回调
  await notificationService.init(
    onNotificationTap: _handleNotificationTap,
  );
  
  // 调度所有已启用的提醒
  await _scheduleAllEnabledReminders();
  
  runApp(const BabyGrowthApp());
}

/// 处理通知点击
void _handleNotificationTap(String? payload) {
  print('处理通知点击: payload=$payload');
  // 通知点击的处理逻辑在 HomeScreen 中通过全局键或路由处理
  // 这里只是记录，实际跳转在应用内处理
}

/// 调度所有已启用的提醒
Future<void> _scheduleAllEnabledReminders() async {
  try {
    final babies = await DatabaseService.instance.getAllBabies();
    if (babies.isNotEmpty) {
      final baby = babies.first;
      if (baby.id != null) {
        final reminders = await DatabaseService.instance.getEnabledReminders(baby.id!);
        int successCount = 0;
        for (final reminder in reminders) {
          final success = await notificationService.scheduleReminder(reminder);
          if (success) successCount++;
        }
        print('已调度 $successCount/${reminders.length} 个提醒');
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 应用启动后检查权限
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 检查通知权限
  Future<void> _checkPermissions() async {
    final (hasNotification, hasExactAlarm) = await notificationService.checkAndRequestPermissions();
    
    print('权限状态: 通知=$hasNotification, 精确闹钟=$hasExactAlarm');
    
    if (!hasNotification) {
      // 通知权限被拒绝，可以显示提示
      if (mounted) {
        _showPermissionDeniedDialog('通知权限');
      }
    }
    
    if (!hasExactAlarm) {
      // 精确闹钟权限被拒绝，显示提示引导用户开启
      if (mounted) {
        _showExactAlarmPermissionDialog();
      }
    }
  }

  /// 显示权限被拒绝提示
  void _showPermissionDeniedDialog(String permissionName) {
    // 这里可以选择是否显示提示，首次启动不建议立即弹窗
    print('$permissionName 被拒绝');
  }

  /// 显示精确闹钟权限引导对话框
  void _showExactAlarmPermissionDialog() {
    showDialog(
      context: _navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('需要权限'),
        content: const Text(
          '为了确保提醒能够准时送达，需要您允许应用设置精确闹钟。\n\n'
          '请在系统设置中找到"宝宝成长记"，开启"设置精确闹钟"权限。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // 打开应用设置页面
              _openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  /// 打开应用设置
  void _openAppSettings() {
    // 使用 permission_handler 或 app_settings 包打开设置
    // 这里简化处理，实际使用时可以添加 app_settings 依赖
    print('打开应用设置');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 当应用进入后台时关闭数据库，返回前台时重新打开
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      DatabaseService.instance.close();
    } else if (state == AppLifecycleState.resumed) {
      // 应用返回前台时重新初始化数据库
      DatabaseService.instance.database;
      // 重新调度所有提醒（权限可能已更改）
      _scheduleAllEnabledReminders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '宝宝成长记',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
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
