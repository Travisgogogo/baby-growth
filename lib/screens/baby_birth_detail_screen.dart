import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/baby.dart';
import '../services/database_service.dart';
import '../utils/date_time_util.dart';
import '../utils/image_picker_util.dart';
import '../widgets/animations.dart';

/// 宝宝出生信息详情页面
class BabyBirthDetailScreen extends StatefulWidget {
  final Baby baby;
  
  const BabyBirthDetailScreen({super.key, required this.baby});

  @override
  State<BabyBirthDetailScreen> createState() => _BabyBirthDetailScreenState();
}

class _BabyBirthDetailScreenState extends State<BabyBirthDetailScreen> {
  late Baby _baby;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _baby = widget.baby;
  }

  Future<void> _updateBaby(Baby updatedBaby) async {
    setState(() => _isLoading = true);
    try {
      final success = await DatabaseService.instance.updateBaby(updatedBaby);
      if (success) {
        setState(() => _baby = updatedBaby);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('保存成功')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 选择或拍照
  Future<void> _pickImage(String type, String title) async {
    await ImagePickerUtil.showPickerOptions(
      context,
      title: title,
      onImageSelected: (path) async {
        Baby updatedBaby;
        switch (type) {
          case 'birthPhoto':
            updatedBaby = _baby.copyWith(birthPhotoPath: path);
            break;
          case 'handprint':
            updatedBaby = _baby.copyWith(handprintPath: path);
            break;
          case 'footprint':
            updatedBaby = _baby.copyWith(footprintPath: path);
            break;
          default:
            return;
        }
        await _updateBaby(updatedBaby);
      },
    );
  }

  /// 编辑文本字段
  void _editTextField(String title, String? currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '请输入$title',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onSave(controller.text);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 编辑时间
  Future<void> _editBirthTime() async {
    final now = DateTime.now();
    final initialTime = _baby.birthTime != null 
        ? TimeOfDay.fromDateTime(_baby.birthTime!)
        : TimeOfDay.now();
    
    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    
    if (time != null) {
      final birthTime = DateTime(
        _baby.birthDate.year,
        _baby.birthDate.month,
        _baby.birthDate.day,
        time.hour,
        time.minute,
      );
      await _updateBaby(_baby.copyWith(birthTime: birthTime));
    }
  }

  /// 选择分娩方式
  void _editDeliveryMode() {
    final modes = ['顺产', '剖腹产', '产钳助产', '真空吸引', '水中分娩'];
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('选择分娩方式', style: AppTextStyles.subtitle),
            ),
            ...modes.map((mode) => ListTile(
              title: Text(mode),
              trailing: _baby.deliveryMode == mode 
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () async {
                Navigator.pop(context);
                await _updateBaby(_baby.copyWith(deliveryMode: mode));
              },
            )),
          ],
        ),
      ),
    );
  }

  /// 选择血型
  void _editBloodType() {
    final types = ['A型', 'B型', 'AB型', 'O型', 'Rh阴性'];
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('选择血型', style: AppTextStyles.subtitle),
            ),
            ...types.map((type) => ListTile(
              title: Text(type),
              trailing: _baby.bloodType == type 
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () async {
                Navigator.pop(context);
                await _updateBaby(_baby.copyWith(bloodType: type));
              },
            )),
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
        title: const Text('出生信息'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle('基本信息'),
                _buildInfoCard([
                  _buildInfoItem('出生时间', _formatBirthTime(), Icons.access_time, _editBirthTime),
                  _buildDivider(),
                  _buildInfoItem('出生地点', _baby.birthPlace ?? '未设置', Icons.location_on, () {
                    _editTextField('出生地点', _baby.birthPlace, (value) async {
                      await _updateBaby(_baby.copyWith(birthPlace: value));
                    });
                  }),
                  _buildDivider(),
                  _buildInfoItem('胎龄', _baby.gestationalAge ?? '未设置', Icons.calendar_today, () {
                    _editTextField('胎龄', _baby.gestationalAge, (value) async {
                      await _updateBaby(_baby.copyWith(gestationalAge: value));
                    });
                  }),
                  _buildDivider(),
                  _buildInfoItem('分娩方式', _baby.deliveryMode ?? '未设置', Icons.medical_services, _editDeliveryMode),
                  _buildDivider(),
                  _buildInfoItem('血型', _baby.bloodType ?? '未设置', Icons.water_drop, _editBloodType),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle('珍贵纪念'),
                const SizedBox(height: 12),
                _buildPhotoCard(
                  '出生照片',
                  _baby.birthPhotoPath,
                  Icons.child_care,
                  () => _pickImage('birthPhoto', '选择出生照片'),
                ),
                const SizedBox(height: 12),
                _buildPhotoCard(
                  '小手印',
                  _baby.handprintPath,
                  Icons.pan_tool,
                  () => _pickImage('handprint', '选择小手印照片'),
                ),
                const SizedBox(height: 12),
                _buildPhotoCard(
                  '小脚印',
                  _baby.footprintPath,
                  Icons.directions_walk,
                  () => _pickImage('footprint', '选择小脚印照片'),
                ),
              ],
            ),
    );
  }

  String _formatBirthTime() {
    if (_baby.birthTime == null) return '未设置';
    return DateTimeUtil.formatTime(_baby.birthTime!);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: AppTextStyles.subtitle.copyWith(color: AppColors.textTertiary)),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return AnimatedCard(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      subtitle: Text(value, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 56, color: Colors.grey.shade200);
  }

  Widget _buildPhotoCard(String title, String? imagePath, IconData icon, VoidCallback onTap) {
    return AnimatedCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title, style: AppTextStyles.body),
                const Spacer(),
                if (imagePath != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('确认删除'),
                          content: Text('确定要删除$title吗？'),
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
                        Baby updatedBaby;
                        switch (title) {
                          case '出生照片':
                            updatedBaby = _baby.copyWith(clearBirthPhotoPath: true);
                            break;
                          case '小手印':
                            updatedBaby = _baby.copyWith(clearHandprintPath: true);
                            break;
                          case '小脚印':
                            updatedBaby = _baby.copyWith(clearFootprintPath: true);
                            break;
                          default:
                            return;
                        }
                        await _updateBaby(updatedBaby);
                      }
                    },
                  ),
              ],
            ),
          ),
          if (imagePath != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Image.file(
                File(imagePath),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text('点击添加照片', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
