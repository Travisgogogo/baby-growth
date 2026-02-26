import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../constants/milestone_data.dart';
import '../widgets/animations.dart';
import '../models/baby.dart';
import '../models/milestone.dart';
import '../services/database_service.dart';
import 'milestone_detail_screen.dart';

/// 里程碑列表页面 - 按分类展示，支持月龄筛选
class MilestonesListScreen extends StatefulWidget {
  const MilestonesListScreen({super.key});

  @override
  State<MilestonesListScreen> createState() => _MilestonesListScreenState();
}

class _MilestonesListScreenState extends State<MilestonesListScreen>
    with SingleTickerProviderStateMixin {
  Baby? _baby;
  List<MilestoneRecord> _completedRecords = [];
  bool _isLoading = true;
  int _babyAgeInMonths = 0;

  // 筛选状态
  bool _showCurrentAgeOnly = false;
  MilestoneCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final babies = await DatabaseService.instance.getAllBabies();
    if (babies.isNotEmpty) {
      final baby = babies.first;
      final babyId = baby.id;
      if (babyId != null) {
        setState(() {
          _baby = baby;
          _babyAgeInMonths = baby.ageInDays ~/ 30;
        });
        
        final records = await DatabaseService.instance.getMilestoneRecords(babyId);
        setState(() => _completedRecords = records);
      }
    }
    
    setState(() => _isLoading = false);
  }

  /// 检查里程碑是否已完成
  bool _isMilestoneCompleted(String milestoneId) {
    return _completedRecords.any((r) => r.milestoneId == milestoneId);
  }

  /// 获取里程碑完成记录
  MilestoneRecord? _getMilestoneRecord(String milestoneId) {
    try {
      return _completedRecords.firstWhere((r) => r.milestoneId == milestoneId);
    } catch (e) {
      return null;
    }
  }

  /// 获取筛选后的里程碑列表
  List<Milestone> _getFilteredMilestones() {
    List<Milestone> result = List.from(MilestoneData.allMilestones);

    // 按分类筛选
    if (_selectedCategory != null) {
      result = result.where((m) => m.category == _selectedCategory).toList();
    }

    // 按当前月龄筛选
    if (_showCurrentAgeOnly) {
      result = result.where((m) => m.isInRange(_babyAgeInMonths)).toList();
    }

    // 按最小月龄排序
    result.sort((a, b) => a.minMonth.compareTo(b.minMonth));

    return result;
  }

  /// 计算总体进度
  double _getOverallProgress() {
    if (MilestoneData.totalCount == 0) return 0;
    return _completedRecords.length / MilestoneData.totalCount;
  }

  /// 计算各分类进度
  Map<MilestoneCategory, double> _getCategoryProgress() {
    final result = <MilestoneCategory, double>{};
    final categoryCounts = MilestoneData.categoryCounts;

    for (final category in MilestoneCategory.values) {
      final totalInCategory = categoryCounts[category] ?? 0;
      if (totalInCategory == 0) {
        result[category] = 0;
        continue;
      }

      final completedInCategory = _completedRecords.where((r) {
        final milestone = MilestoneData.getById(r.milestoneId);
        return milestone?.category == category;
      }).length;

      result[category] = completedInCategory / totalInCategory;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _baby == null
              ? _buildEmptyState()
              : CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildProgressSection(),
                          _buildFilterSection(),
                          _buildMilestonesList(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.child_care, size: 80, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            '请先添加宝宝信息',
            style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '${_baby?.name ?? ""}的里程碑',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    '当前月龄: ${_babyAgeInMonths}个月',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.primary,
    );
  }

  Widget _buildProgressSection() {
    final overallProgress = _getOverallProgress();
    final categoryProgress = _getCategoryProgress();

    return FadeInAnimation(
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '发育进度',
                        style: AppTextStyles.subtitle.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_completedRecords.length}/${MilestoneData.totalCount}',
                        style: AppTextStyles.headline.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: overallProgress,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                      ),
                      Center(
                        child: Text(
                          '${(overallProgress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            // 各分类进度
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: MilestoneCategory.values.map((category) {
                final progress = categoryProgress[category] ?? 0;
                return _buildCategoryProgressItem(category, progress);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgressItem(MilestoneCategory category, double progress) {
    return Column(
      children: [
        _getCategoryIcon(category),
        const SizedBox(height: 4),
        Text(
          category.displayName,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _getCategoryIcon(MilestoneCategory category) {
    IconData iconData;
    switch (category) {
      case MilestoneCategory.grossMotor:
        iconData = Icons.directions_run;
        break;
      case MilestoneCategory.fineMotor:
        iconData = Icons.back_hand;
        break;
      case MilestoneCategory.language:
        iconData = Icons.record_voice_over;
        break;
      case MilestoneCategory.socialEmotion:
        iconData = Icons.mood;
        break;
    }
    return Icon(iconData, color: Colors.white, size: 24);
  }

  Color _getCategoryColor(MilestoneCategory category) {
    switch (category) {
      case MilestoneCategory.grossMotor:
        return const Color(0xFFFF8A80);  // 珊瑚粉
      case MilestoneCategory.fineMotor:
        return const Color(0xFF81D4FA);  // 天蓝
      case MilestoneCategory.language:
        return const Color(0xFFFFF59D);  // 暖黄
      case MilestoneCategory.socialEmotion:
        return const Color(0xFF80CBC4);  // 薄荷绿
    }
  }

  Widget _buildFilterSection() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 月龄筛选开关
            AnimatedCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: AppDimensions.paddingSmall,
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '只显示适合当前月龄的里程碑',
                      style: AppTextStyles.body,
                    ),
                  ),
                  Switch(
                    value: _showCurrentAgeOnly,
                    onChanged: (value) {
                      setState(() => _showCurrentAgeOnly = value);
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 分类筛选
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip(null),
                  ...MilestoneCategory.values.map(_buildCategoryChip),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(MilestoneCategory? category) {
    final isSelected = _selectedCategory == category;
    final label = category?.displayName ?? '全部';
    final color = category != null ? _getCategoryColor(category) : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        backgroundColor: AppColors.surface,
        selectedColor: color.withOpacity(0.2),
        checkmarkColor: color,
        side: BorderSide(
          color: isSelected ? color : AppColors.divider,
        ),
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? color : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMilestonesList() {
    final milestones = _getFilteredMilestones();

    if (milestones.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.search_off,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                '没有找到符合条件的里程碑',
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        final isCompleted = _isMilestoneCompleted(milestone.id);
        final record = _getMilestoneRecord(milestone.id);

        return ListItemAnimation(
          index: index,
          child: _buildMilestoneCard(milestone, isCompleted, record),
        );
      },
    );
  }

  Widget _buildMilestoneCard(
    Milestone milestone,
    bool isCompleted,
    MilestoneRecord? record,
  ) {
    final isSuitable = milestone.isInRange(_babyAgeInMonths);
    final categoryColor = _getCategoryColor(milestone.category);

    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      onTap: () => _navigateToDetail(milestone, isCompleted, record),
      child: Row(
        children: [
          // 分类图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Center(
              child: _getCategoryIcon(milestone.category),
            ),
          ),
          const SizedBox(width: 12),
          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        milestone.title,
                        style: AppTextStyles.title.copyWith(
                          fontSize: 16,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCompleted
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  milestone.description,
                  style: AppTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSuitable
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        milestone.monthRange,
                        style: AppTextStyles.caption.copyWith(
                          color: isSuitable
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          fontWeight: isSuitable ? FontWeight.w500 : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      milestone.category.displayName,
                      style: AppTextStyles.caption.copyWith(
                        color: categoryColor,
                      ),
                    ),
                    if (record != null) ...[
                      const Spacer(),
                      Text(
                        _formatDate(record.completedDate),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  void _navigateToDetail(
    Milestone milestone,
    bool isCompleted,
    MilestoneRecord? record,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MilestoneDetailScreen(
          milestone: milestone,
          baby: _baby!,
          isCompleted: isCompleted,
          existingRecord: record,
        ),
      ),
    );

    // 如果有更新，刷新数据
    if (result == true) {
      _loadData();
    }
  }
}
