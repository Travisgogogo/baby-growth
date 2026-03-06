import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/baby.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../widgets/animations.dart';
import 'reminder_edit_screen.dart';

class ReminderListScreen extends StatefulWidget {
  final Baby baby;

  const ReminderListScreen({super.key, required this.baby});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      setState(() => _isLoading = true);
      final reminders = await DatabaseService.instance.getReminders(widget.baby.id!);
      if (mounted) {
        setState(() {
          _reminders = reminders;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('加载提醒失败: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('今日提醒'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? _buildEmptyState()
              : _buildReminderList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无提醒',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右下角添加提醒',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _navigateToEdit(),
            icon: const Icon(Icons.add),
            label: const Text('添加提醒'),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderList() {
    return RefreshIndicator(
      onRefresh: _loadReminders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return ListItemAnimation(
            index: index,
            child: _buildReminderCard(reminder),
          );
        },
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    return Dismissible(
      key: Key(reminder.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteReminder(reminder),
      child: AnimatedCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: reminder.isEnabled
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  reminder.timeDisplay,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: reminder.isEnabled ? AppColors.primary : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: reminder.isEnabled
                          ? AppColors.textPrimary
                          : Colors.grey,
                      decoration: reminder.isEnabled
                          ? null
                          : TextDecoration.lineThrough,
                    ),
                  ),
                  if (reminder.description != null &&
                      reminder.description!.isNotEmpty)
                    Text(
                      reminder.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: reminder.isEnabled
                            ? Colors.grey.shade600
                            : Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        reminder.isRepeating
                            ? Icons.repeat
                            : Icons.notifications,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reminder.repeatDisplay,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: reminder.isEnabled,
              onChanged: (value) => _toggleReminder(reminder, value),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey),
              onPressed: () => _navigateToEdit(reminder: reminder),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToEdit({Reminder? reminder}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReminderEditScreen(
          baby: widget.baby,
          reminder: reminder,
        ),
      ),
    );
    if (result == true) {
      _loadReminders();
    }
  }

  Future<void> _toggleReminder(Reminder reminder, bool isEnabled) async {
    final updated = reminder.copyWith(isEnabled: isEnabled);
    final success = await DatabaseService.instance.updateReminder(updated);
    if (success && mounted) {
      if (isEnabled) {
        // 启用：调度通知
        await notificationService.scheduleReminder(updated);
      } else {
        // 禁用：取消通知
        await notificationService.cancelReminder(reminder);
      }
      _loadReminders();
    }
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    if (reminder.id == null) return;
    
    // 取消通知
    await notificationService.cancelReminder(reminder);
    
    final success = await DatabaseService.instance.deleteReminder(reminder.id!);
    if (success && mounted) {
      setState(() {
        _reminders.removeWhere((r) => r.id == reminder.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('提醒已删除')),
      );
    }
  }
}
