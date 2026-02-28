import 'package:flutter/material.dart';
import 'dart:io';
import '../constants/app_theme.dart';
import '../constants/milestone_data.dart';
import '../widgets/animations.dart';
import '../models/baby.dart';
import '../models/milestone.dart';
import '../services/database_service.dart';
import 'milestone_detail_screen.dart';

/// 里程碑页面 - 整合概览和列表
class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
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

  Future<void> _navigateToDetail(Milestone milestone) async {
    final babyId = _baby?.id;
    if (babyId == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MilestoneDetailScreen(
          milestone: milestone,
          babyId: babyId,
          isCompleted: _isMilestoneCompleted(milestone.id),
        ),
      ),
    );
    _loadData();
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
      delay: const Duration(milliseconds: 100),
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
                        '总体进度',
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
                      const SizedBox(height: 4),
                      Text(
                        '已完成 ${(overallProgress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
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
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: MilestoneCategory.values.map((category) {
                final progress = categoryProgress[category] ?? 0;
                return Column(
                  children: [
                    Icon(category.icon, color: Colors.white70, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 月龄筛选
            Row(
              children: [
                Expanded(
                  child: FilterChip(
                    selected: _showCurrentAgeOnly,
                    onSelected: (selected) {
                      setState(() => _showCurrentAgeOnly = selected);
                    },
                    label: Text('当前月龄 (${_babyAgeInMonths}个月)'),
                    avatar: const Icon(Icons.calendar_today, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 分类筛选
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                    label: const Text('全部'),
                  ),
                  const SizedBox(width: 8),
                  ...MilestoneCategory.values.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = selected ? category : null);
                        },
                        label: Text(category.displayName),
                        avatar: Icon(category.icon, size: 18, color: category.color),
                        selectedColor: category.color.withOpacity(0.2),
                        checkmarkColor: category.color,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestonesList() {
    final milestones = _getFilteredMilestones();

    if (milestones.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text('没有符合条件的里程碑'),
        ),
      );
    }

    return FadeInAnimation(
      delay: const Duration(milliseconds: 300),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: milestones.length,
        itemBuilder: (context, index) {
          final milestone = milestones[index];
          final isCompleted = _isMilestoneCompleted(milestone.id);

          return AnimatedCard(
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: 4,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: 4,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withOpacity(0.2)
                      : milestone.category.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: Center(
                  child: Icon(
                    isCompleted ? Icons.check : milestone.category.icon,
                    color: isCompleted ? AppColors.success : milestone.category.color,
                    size: 24,
                  ),
                ),
              ),
              title: Text(
                milestone.title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${milestone.minMonth}-${milestone.maxMonth}个月 · ${milestone.category.displayName}',
                    style: AppTextStyles.caption,
                  ),
                  if (milestone.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      milestone.description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              trailing: isCompleted
                  ? const Icon(Icons.check_circle, color: AppColors.success)
                  : const Icon(Icons.chevron_right, color: AppColors.textTertiary),
              onTap: () => _navigateToDetail(milestone),
            ),
          );
        },
      ),
    );
  }
}
