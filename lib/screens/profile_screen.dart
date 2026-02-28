import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../constants/app_theme.dart';
import '../widgets/animations.dart';
import 'dart:convert';
import '../models/baby.dart';
import '../services/database_service.dart';
import 'share_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Baby? _baby;
  final ImagePicker _imagePicker = ImagePicker();

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

  /// 显示头像选择对话框
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '更换头像',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library, color: AppColors.primary),
                ),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              if (_baby?.avatarPath != null) ...[
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  title: const Text('删除头像', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteAvatar();
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 拍照
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (photo != null && _baby != null) {
        final updatedBaby = _baby!.copyWith(avatarPath: photo.path);
        await DatabaseService.instance.updateBaby(updatedBaby);
        setState(() => _baby = updatedBaby);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('头像已更新')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e')),
        );
      }
    }
  }

  /// 从相册选择
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null && _baby != null) {
        final updatedBaby = _baby!.copyWith(avatarPath: image.path);
        await DatabaseService.instance.updateBaby(updatedBaby);
        setState(() => _baby = updatedBaby);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('头像已更新')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }
  }

  /// 删除头像
  Future<void> _deleteAvatar() async {
    if (_baby == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除宝宝头像吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final updatedBaby = _baby!.copyWith(avatarPath: null);
      await DatabaseService.instance.updateBaby(updatedBaby);
      setState(() => _baby = updatedBaby);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('头像已删除')),
        );
      }
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
            child: _buildMenuItem(Icons.share, '分享成长', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShareScreen()),
              );
            }),
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
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.hasData ? snapshot.data!.version : '1.0.0';
              return Center(
                child: Text('宝宝成长记 v$version', style: AppTextStyles.caption),
              );
            },
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
      child: Row(
        children: [
          // 头像区域 - 可点击更换
          GestureDetector(
            onTap: _showAvatarPicker,
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: _baby?.avatarPath != null 
                        ? null 
                        : AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _baby?.avatarPath != null
                        ? Image.file(
                            File(_baby!.avatarPath!),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  _baby!.name.isNotEmpty ? _baby!.name[0] : '👶',
                                  style: AppTextStyles.headline.copyWith(color: Colors.white),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              _baby!.name.isNotEmpty ? _baby!.name[0] : '👶',
                              style: AppTextStyles.headline.copyWith(color: Colors.white),
                            ),
                          ),
                  ),
                ),
                // 相机图标
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _editBabyProfile,
                  child: Row(
                    children: [
                      Text(_baby!.name, style: AppTextStyles.title),
                      const SizedBox(width: 8),
                      Icon(Icons.edit, color: AppColors.textTertiary, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_baby!.gender} · ${_baby!.ageDisplay}',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 8),
                // 点击更换头像提示
                GestureDetector(
                  onTap: _showAvatarPicker,
                  child: Text(
                    '点击更换头像',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
