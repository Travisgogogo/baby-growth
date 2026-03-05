import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../widgets/animations.dart';
import 'dart:convert';
import '../models/baby.dart';
import '../services/database_service.dart';
import 'reminder_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Baby? _baby;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final babies = await DatabaseService.instance.getAllBabies();
    if (babies.isNotEmpty) {
      setState(() => _baby = babies.first);
    }
  }

  Future<void> _backupData() async {
    if (_baby == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('正在备份...'),
          ],
        ),
      ),
    );

    try {
      final babyId = _baby?.id;
      if (babyId == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('备份失败: 宝宝信息不存在')),
        );
        return;
      }
      final backup = {
        'version': AppConstants.backupVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'baby': _baby!.toMap(),
        'growthRecords': (await DatabaseService.instance.getGrowthRecords(babyId)).map((r) => r.toMap()).toList(),
        'feedRecords': (await DatabaseService.instance.getFeedRecords(babyId, limit: AppConstants.maxQueryLimit)).map((r) => r.toMap()).toList(),
        'sleepRecords': (await DatabaseService.instance.getSleepRecords(babyId)).map((r) => r.toMap()).toList(),
        'diaperRecords': (await DatabaseService.instance.getDiaperRecords(babyId)).map((r) => r.toMap()).toList(),
        'milestoneRecords': (await DatabaseService.instance.getMilestoneRecords(babyId)).map((r) => r.toMap()).toList(),
      };
      
      final jsonStr = jsonEncode(backup);
      
      Navigator.pop(context);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('备份成功'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('请将以下备份代码保存到安全的地方：'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  base64Encode(utf8.encode(jsonStr)).substring(0, 100) + '...',
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('复制'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('备份失败: $e')),
      );
    }
  }

  void _restoreData() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('数据恢复'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: '请输入备份代码',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('恢复功能开发中')),
              );
            },
            child: const Text('恢复'),
          ),
        ],
      ),
    );
  }

  void _editBabyProfile() {
    if (_baby == null) return;
    
    final nameController = TextEditingController(text: _baby!.name);
    final weightController = TextEditingController(text: _baby!.birthWeight?.toString() ?? '');
    final heightController = TextEditingController(text: _baby!.birthHeight?.toString() ?? '');
    final headController = TextEditingController(text: _baby!.birthHeadCircumference?.toString() ?? '');
    String gender = _baby!.gender;
    DateTime birthDate = _baby!.birthDate;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('编辑宝宝资料'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '宝宝姓名',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // 出生日期选择
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: birthDate,
                      firstDate: DateTime(AppConstants.minBirthYear),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() => birthDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '出生日期',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text('${birthDate.year}年${birthDate.month}月${birthDate.day}日'),
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: '男', label: Text('男')),
                    ButtonSegment(value: '女', label: Text('女')),
                  ],
                  selected: {gender},
                  onSelectionChanged: (set) {
                    setDialogState(() => gender = set.first);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '出生体重 (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '出生身高 (cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: headController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '出生头围 (cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final updatedBaby = _baby!.copyWith(
                    name: nameController.text,
                    birthDate: birthDate,
                    gender: gender,
                    birthWeight: double.tryParse(weightController.text),
                    birthHeight: double.tryParse(heightController.text),
                    birthHeadCircumference: double.tryParse(headController.text),
                  );
                  // 更新数据库
                  await DatabaseService.instance.updateBaby(updatedBaby);
                  setState(() => _baby = updatedBaby);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('资料已更新')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('更新失败: $e')),
                  );
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMedium),
        children: [
          FadeInAnimation(child: _buildBabyCard()),
          const SizedBox(height: AppDimensions.paddingLarge),
          FadeInAnimation(
            delay: const Duration(milliseconds: 100),
            child: _buildSectionTitle('数据管理'),
          ),
          FadeInAnimation(
            delay: const Duration(milliseconds: 150),
            child: _buildMenuItem(Icons.backup, '数据备份', _backupData),
          ),
          FadeInAnimation(
            delay: const Duration(milliseconds: 200),
            child: _buildMenuItem(Icons.restore, '数据恢复', _restoreData),
          ),
          FadeInAnimation(
            delay: const Duration(milliseconds: 250),
            child: _buildMenuItem(Icons.share, '分享成长', () {}),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          FadeInAnimation(
            delay: const Duration(milliseconds: 275),
            child: _buildSectionTitle('提醒'),
          ),
          FadeInAnimation(
            delay: const Duration(milliseconds: 285),
            child: _buildMenuItem(
              Icons.notifications_active,
              '提醒设置',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReminderSettingsScreen()),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          FadeInAnimation(
            delay: const Duration(milliseconds: 300),
            child: _buildSectionTitle('关于'),
          ),
          FadeInAnimation(
            delay: const Duration(milliseconds: 350),
            child: _buildMenuItem(Icons.info, '关于我们', () {}),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text('宝宝成长记 v1.8.2', style: AppTextStyles.caption),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBabyCard() {
    if (_baby == null) {
      return AnimatedCard(
        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Center(
          child: Text('暂无宝宝信息', style: AppTextStyles.subtitle.copyWith(color: AppColors.textTertiary)),
        ),
      );
    }

    return AnimatedCard(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      onTap: _editBabyProfile,
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _baby!.name[0],
                style: AppTextStyles.headline.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_baby!.name, style: AppTextStyles.title),
                    const SizedBox(width: 8),
                    Icon(Icons.edit, color: AppColors.textTertiary, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_baby!.gender} · ${_baby!.ageDisplay}',
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Text(title, style: AppTextStyles.subtitle.copyWith(color: AppColors.textTertiary)),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return AnimatedCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: 4,
      ),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Icon(icon, color: AppColors.primary, size: AppDimensions.iconMedium),
          ),
          title: Text(title, style: AppTextStyles.body),
          trailing: Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ),
      ),
    );
  }
}
