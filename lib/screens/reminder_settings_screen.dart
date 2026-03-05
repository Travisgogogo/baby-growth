import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../constants/app_theme.dart';
import '../widgets/animations.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  bool _feedReminderEnabled = false;
  bool _sleepReminderEnabled = false;
  bool _diaperReminderEnabled = false;
  bool _vaccineReminderEnabled = false;
  
  TimeOfDay _feedTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 21, minute: 0);
  TimeOfDay _diaperTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _vaccineTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    await NotificationService().init();
    final hasPermission = await NotificationService().hasPermission();
    if (!hasPermission && mounted) {
      await NotificationService().requestPermission();
    }
  }

  Future<void> _pickTime(String type, TimeOfDay initialTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        switch (type) {
          case 'feed':
            _feedTime = picked;
            if (_feedReminderEnabled) _updateFeedReminder();
            break;
          case 'sleep':
            _sleepTime = picked;
            if (_sleepReminderEnabled) _updateSleepReminder();
            break;
          case 'diaper':
            _diaperTime = picked;
            if (_diaperReminderEnabled) _updateDiaperReminder();
            break;
          case 'vaccine':
            _vaccineTime = picked;
            if (_vaccineReminderEnabled) _updateVaccineReminder();
            break;
        }
      });
    }
  }

  Future<void> _toggleFeedReminder(bool value) async {
    setState(() => _feedReminderEnabled = value);
    if (value) {
      await _updateFeedReminder();
    } else {
      await NotificationService().cancelNotification(1);
    }
  }

  Future<void> _updateFeedReminder() async {
    await NotificationService().scheduleDailyNotification(
      id: 1,
      title: '🍼 喂养提醒',
      body: '该给宝宝喂奶啦！记得记录喂养情况哦~',
      hour: _feedTime.hour,
      minute: _feedTime.minute,
    );
  }

  Future<void> _toggleSleepReminder(bool value) async {
    setState(() => _sleepReminderEnabled = value);
    if (value) {
      await _updateSleepReminder();
    } else {
      await NotificationService().cancelNotification(2);
    }
  }

  Future<void> _updateSleepReminder() async {
    await NotificationService().scheduleDailyNotification(
      id: 2,
      title: '😴 睡眠提醒',
      body: '该哄宝宝睡觉啦！良好的睡眠有助于成长~',
      hour: _sleepTime.hour,
      minute: _sleepTime.minute,
    );
  }

  Future<void> _toggleDiaperReminder(bool value) async {
    setState(() => _diaperReminderEnabled = value);
    if (value) {
      await _updateDiaperReminder();
    } else {
      await NotificationService().cancelNotification(3);
    }
  }

  Future<void> _updateDiaperReminder() async {
    await NotificationService().scheduleDailyNotification(
      id: 3,
      title: '🧷 换尿布提醒',
      body: '检查一下宝宝是否需要换尿布~',
      hour: _diaperTime.hour,
      minute: _diaperTime.minute,
    );
  }

  Future<void> _toggleVaccineReminder(bool value) async {
    setState(() => _vaccineReminderEnabled = value);
    if (value) {
      await _updateVaccineReminder();
    } else {
      await NotificationService().cancelNotification(4);
    }
  }

  Future<void> _updateVaccineReminder() async {
    await NotificationService().scheduleDailyNotification(
      id: 4,
      title: '💉 疫苗提醒',
      body: '记得查看宝宝的疫苗接种计划~',
      hour: _vaccineTime.hour,
      minute: _vaccineTime.minute,
    );
  }

  Future<void> _testNotification() async {
    await NotificationService().showNotification(
      id: 999,
      title: '测试通知',
      body: '通知功能正常工作！',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('测试通知已发送')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('提醒设置'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          FadeInAnimation(
            child: _buildReminderCard(
              icon: Icons.restaurant,
              title: '喂养提醒',
              subtitle: '每天提醒记录喂养情况',
              time: _feedTime,
              enabled: _feedReminderEnabled,
              onToggle: _toggleFeedReminder,
              onTapTime: () => _pickTime('feed', _feedTime),
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 12),
          FadeInAnimation(
            delay: const Duration(milliseconds: 100),
            child: _buildReminderCard(
              icon: Icons.bedtime,
              title: '睡眠提醒',
              subtitle: '每天提醒记录睡眠情况',
              time: _sleepTime,
              enabled: _sleepReminderEnabled,
              onToggle: _toggleSleepReminder,
              onTapTime: () => _pickTime('sleep', _sleepTime),
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 12),
          FadeInAnimation(
            delay: const Duration(milliseconds: 200),
            child: _buildReminderCard(
              icon: Icons.baby_changing_station,
              title: '换尿布提醒',
              subtitle: '每天提醒检查尿布情况',
              time: _diaperTime,
              enabled: _diaperReminderEnabled,
              onToggle: _toggleDiaperReminder,
              onTapTime: () => _pickTime('diaper', _diaperTime),
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 12),
          FadeInAnimation(
            delay: const Duration(milliseconds: 300),
            child: _buildReminderCard(
              icon: Icons.vaccines,
              title: '疫苗提醒',
              subtitle: '每天提醒查看疫苗计划',
              time: _vaccineTime,
              enabled: _vaccineReminderEnabled,
              onToggle: _toggleVaccineReminder,
              onTapTime: () => _pickTime('vaccine', _vaccineTime),
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 32),
          FadeInAnimation(
            delay: const Duration(milliseconds: 400),
            child: Center(
              child: FilledButton.icon(
                onPressed: _testNotification,
                icon: const Icon(Icons.notifications_active),
                label: const Text('测试通知'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInAnimation(
            delay: const Duration(milliseconds: 450),
            child: Center(
              child: Text(
                '请确保已开启通知权限，否则提醒无法正常工作',
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required bool enabled,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTapTime,
    required Color color,
  }) {
    return AnimatedCard(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeColor: AppColors.primary,
              ),
            ],
          ),
          if (enabled) ...[
            const Divider(height: 24),
            InkWell(
              onTap: onTapTime,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.title.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit, size: 16, color: AppColors.textTertiary),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
