import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_theme.dart';
import '../constants/milestone_data.dart';
import '../widgets/animations.dart';
import '../models/baby.dart';
import '../models/milestone.dart';
import '../services/database_service.dart';

/// 里程碑详情/记录页面
class MilestoneDetailScreen extends StatefulWidget {
  final Milestone milestone;
  final Baby baby;
  final bool isCompleted;
  final MilestoneRecord? existingRecord;

  const MilestoneDetailScreen({
    super.key,
    required this.milestone,
    required this.baby,
    required this.isCompleted,
    this.existingRecord,
  });

  @override
  State<MilestoneDetailScreen> createState() => _MilestoneDetailScreenState();
}

class _MilestoneDetailScreenState extends State<MilestoneDetailScreen> {
  late bool _isCompleted;
  DateTime _completedDate = DateTime.now();
  final TextEditingController _noteController = TextEditingController();
  String? _photoPath;
  bool _isSaving = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.isCompleted;
    
    // 如果有已有记录，加载数据
    if (widget.existingRecord != null) {
      _completedDate = widget.existingRecord!.completedDate;
      _noteController.text = widget.existingRecord!.note ?? '';
      _photoPath = widget.existingRecord!.photoPath;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() => _photoPath = image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() => _photoPath = photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _completedDate,
      firstDate: widget.baby.birthDate,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => _completedDate = picked);
    }
  }

  Future<void> _saveRecord() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);

    try {
      final babyId = widget.baby.id;
      if (babyId == null) {
        throw Exception('宝宝ID为空');
      }

      if (_isCompleted) {
        // 保存完成记录
        final record = MilestoneRecord(
          id: widget.existingRecord?.id,
          babyId: babyId,
          milestoneId: widget.milestone.id,
          completedDate: _completedDate,
          photoPath: _photoPath,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );

        if (widget.existingRecord != null) {
          // 更新现有记录
          await DatabaseService.instance.updateMilestoneRecord(record);
        } else {
          // 创建新记录
          await DatabaseService.instance.createMilestoneRecord(record);
        }
      } else {
        // 删除完成记录（标记为未完成）
        await DatabaseService.instance.deleteMilestoneRecord(
          babyId,
          widget.milestone.id,
        );
      }

      if (mounted) {
        Navigator.pop(context, true); // 返回true表示有更新
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteRecord() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个里程碑记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final babyId = widget.baby.id;
      if (babyId != null) {
        await DatabaseService.instance.deleteMilestoneRecord(
          babyId,
          widget.milestone.id,
        );
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildMilestoneInfo(),
                _buildCompletionSection(),
                if (_isCompleted) ...[
                  _buildDateSection(),
                  _buildPhotoSection(),
                  _buildNoteSection(),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getCategoryColor(widget.milestone.category),
                _getCategoryColor(widget.milestone.category).withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getCategoryIcon(widget.milestone.category),
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.milestone.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: _getCategoryColor(widget.milestone.category),
    );
  }

  Widget _buildMilestoneInfo() {
    return FadeInAnimation(
      child: AnimatedCard(
        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(widget.milestone.category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.milestone.category.displayName,
                    style: TextStyle(
                      color: _getCategoryColor(widget.milestone.category),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.milestone.monthRange,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '描述',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 8),
            Text(
              widget.milestone.description,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            Text(
              '训练建议',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 8),
            Text(
              widget.milestone.trainingTip,
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionSection() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 100),
      child: AnimatedCard(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '完成状态',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusOption(
                    title: '已完成',
                    icon: Icons.check_circle,
                    color: AppColors.success,
                    isSelected: _isCompleted,
                    onTap: () => setState(() => _isCompleted = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusOption(
                    title: '未完成',
                    icon: Icons.radio_button_unchecked,
                    color: AppColors.textTertiary,
                    isSelected: !_isCompleted,
                    onTap: () => setState(() => _isCompleted = false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textTertiary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 200),
      child: AnimatedCard(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '完成日期',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_completedDate.year}年${_completedDate.month}月${_completedDate.day}日',
                        style: AppTextStyles.body,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 300),
      child: AnimatedCard(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '照片记录',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 12),
            if (_photoPath != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    child: Image.file(
                      File(_photoPath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _photoPath = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildPhotoButton(
                      icon: Icons.camera_alt,
                      label: '拍照',
                      onTap: _takePhoto,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPhotoButton(
                      icon: Icons.photo_library,
                      label: '从相册选择',
                      onTap: _pickImage,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 400),
      child: AnimatedCard(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '备注',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '记录这个里程碑的点滴...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textTertiary,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(AppDimensions.paddingMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (widget.existingRecord != null)
              IconButton(
                onPressed: _isSaving ? null : _deleteRecord,
                icon: const Icon(Icons.delete_outline),
                color: AppColors.error,
              ),
            if (widget.existingRecord != null) const SizedBox(width: 8),
            Expanded(
              child: AnimatedButton(
                onTap: _isSaving ? () {} : _saveRecord,
                backgroundColor: _isCompleted ? AppColors.success : AppColors.primary,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isCompleted ? '保存记录' : '标记为未完成',
                        style: AppTextStyles.button,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(MilestoneCategory category) {
    switch (category) {
      case MilestoneCategory.grossMotor:
        return Icons.directions_run;
      case MilestoneCategory.fineMotor:
        return Icons.back_hand;
      case MilestoneCategory.language:
        return Icons.record_voice_over;
      case MilestoneCategory.socialEmotion:
        return Icons.mood;
    }
  }

  Color _getCategoryColor(MilestoneCategory category) {
    switch (category) {
      case MilestoneCategory.grossMotor:
        return Colors.blue;
      case MilestoneCategory.fineMotor:
        return Colors.green;
      case MilestoneCategory.language:
        return Colors.orange;
      case MilestoneCategory.socialEmotion:
        return Colors.purple;
    }
  }
}
