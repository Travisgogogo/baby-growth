import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';

/// 本地通知服务
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _channelId = 'baby_growth_reminder';
  static const String _channelName = '宝宝成长提醒';
  static const String _channelDesc = '用于喂养、睡眠、换尿布和疫苗提醒';

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  /// 初始化通知服务
  Future<void> init() async {
    // 初始化时区数据
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    // Android 设置
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 设置
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // 创建通知渠道（Android）
    await _createNotificationChannel();
  }

  /// 创建 Android 通知渠道
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 通知点击回调
  void _onNotificationTap(NotificationResponse response) {
    print('通知被点击: ${response.payload}');
  }

  /// 请求通知权限
  Future<bool> requestPermission() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    // iOS 权限在初始化时已请求
    return true;
  }

  /// 检查是否有通知权限
  Future<bool> checkPermission() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final enabled = await androidImplementation.areNotificationsEnabled();
      return enabled ?? false;
    }
    return true;
  }

  /// 调度提醒通知
  Future<void> scheduleReminder(Reminder reminder) async {
    if (!reminder.isEnabled) return;

    // 确保有有效的ID
    final id = reminder.id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
    debugPrint('调度提醒: id=$id, title=${reminder.title}, time=${reminder.time}');
    
    final title = _getReminderTitle(reminder.title);
    final body = reminder.description ?? _getDefaultBody(reminder.title);

    try {
      if (reminder.isRepeating && reminder.repeatDays != null && reminder.repeatDays!.isNotEmpty) {
        // 重复提醒：为每个选中的星期几创建单独的通知
        for (final day in reminder.repeatDays!) {
          final notificationId = id * 10 + day; // 生成唯一 ID
          debugPrint('调度重复通知: id=$notificationId, day=$day');
          await _scheduleWeeklyNotification(
            id: notificationId,
            title: title,
            body: body,
            time: reminder.time,
            day: day,
          );
        }
      } else {
        // 一次性提醒
        debugPrint('调度一次性通知: id=$id');
        await _scheduleOneTimeNotification(
          id: id,
          title: title,
          body: body,
          time: reminder.time,
        );
      }
      debugPrint('调度提醒完成');
    } catch (e, stack) {
      debugPrint('scheduleReminder 错误: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  /// 调度一次性通知
  Future<void> _scheduleOneTimeNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    try {
      // 如果时间已过，设置为明天
      var scheduledTime = time;
      if (scheduledTime.isBefore(DateTime.now())) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      debugPrint('调度一次性通知: id=$id, time=$scheduledTime');
      
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        _buildNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('一次性通知调度成功');
    } catch (e, stack) {
      debugPrint('_scheduleOneTimeNotification 错误: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  /// 调度每周重复通知
  Future<void> _scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required int day, // 0=周日, 1=周一...
  }) async {
    try {
      final scheduledTime = _nextInstanceOfWeeklyTime(time, day);
      debugPrint('调度每周通知: id=$id, day=$day, time=$scheduledTime');
      
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        _buildNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      debugPrint('每周通知调度成功: id=$id');
    } catch (e, stack) {
      debugPrint('_scheduleWeeklyNotification 错误: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  /// 计算下一次每周提醒时间
  tz.TZDateTime _nextInstanceOfWeeklyTime(DateTime time, int day) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // 调整到目标星期几
    final currentDay = scheduledDate.weekday % 7; // 转换为 0=周日格式
    var daysUntilTarget = day - currentDay;
    if (daysUntilTarget < 0) {
      daysUntilTarget += 7;
    } else if (daysUntilTarget == 0 && scheduledDate.isBefore(now)) {
      // 今天的时间已过，推到下周
      daysUntilTarget = 7;
    }

    scheduledDate = scheduledDate.add(Duration(days: daysUntilTarget));
    return scheduledDate;
  }

  /// 构建通知详情
  NotificationDetails _buildNotificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// 取消指定提醒的所有通知
  Future<void> cancelReminder(Reminder reminder) async {
    final baseId = reminder.id ?? reminder.hashCode;
    
    // 取消一次性通知
    await _notifications.cancel(baseId);
    
    // 取消重复通知（每个星期几一个通知）
    if (reminder.repeatDays != null) {
      for (final day in reminder.repeatDays!) {
        await _notifications.cancel(baseId * 10 + day);
      }
    }
  }

  /// 取消所有通知
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// 获取提醒标题
  String _getReminderTitle(String title) {
    return title;
  }

  /// 获取默认提醒内容
  String _getDefaultBody(String title) {
    if (title.contains('喂养') || title.contains('喝奶')) {
      return '该给宝宝喂奶啦～';
    } else if (title.contains('睡眠') || title.contains('睡觉')) {
      return '该哄宝宝睡觉啦～';
    } else if (title.contains('换尿布') || title.contains('尿不湿')) {
      return '该给宝宝换尿布啦～';
    } else if (title.contains('疫苗')) {
      return '别忘了疫苗接种哦～';
    }
    return '宝宝成长提醒';
  }
}

/// 全局通知服务实例
final notificationService = NotificationService();
