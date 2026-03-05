import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../constants/milestone_data.dart';
import '../widgets/animations.dart';
import '../models/baby.dart';
import '../models/milestone.dart';
import '../services/database_service.dart';
import 'milestones_list_screen.dart';

/// 里程碑页面 - 概览入口
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

  /// 计算总体进度
  double _getOverallProgress() {
    if (DefaultMilestones.totalCount == 0) return 0;
    return _completedRecords.length / DefaultMilestones.totalCount;
  }

  /// 计算各分类进度
  Map<MilestoneCategory, double> _getCategoryProgress() {
    final result = <MilestoneCategory, double>{};
    final countByCategory = DefaultMilestones.countByCategory;

    for (final category in MilestoneCategory.values) {
      final totalInCategory = countByCategory[category] ?? 0;
      if (totalInCategory == 0) {
        result[category] = 0;
        continue;
      }

      final completedInCategory = _completedRecords.where((r) {
        final def = DefaultMilestones.getMilestoneById(r.milestoneId);
        return def?.category == category;
      }).length;

      result[category] = completedInCategory / totalInCategory;
    }

    return result;
  }

  /// 获取当前月龄应关注的里程碑
  List<Milestone> _getCurrentMilestones() {
    return DefaultMilestones.getMilestonesForAge(_babyAgeInMonths)
        .where((m) => !_completedRecords.any((r) => r.milestoneId == m.id))
        .take(3)
        .toList();
  }

  Future<void> _navigateToList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MilestonesListScreen(),
      ),
    );
    // 返回后刷新数据
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
                          _buildCategoryProgressSection(),
                          _buildCurrentMilestonesSection(),
                          _buildQuickStatsSection(),
                          const SizedBox(height: 32),
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
      expandedHeight: 150,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          '发育里程碑',
          style: TextStyle(
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
                    '${_baby?.name ?? ""} · ${_babyAgeInMonths}个月',
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
      actions: [
        IconButton(
          icon: const Icon(Icons.list),
          onPressed: _navigateToList,
          tooltip: '查看全部',
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    final overallProgress = _getOverallProgress();

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
        child: Row(
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
                    '${_completedRecords.length}/${DefaultMilestones.totalCount}',
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
      ),
    );
  }

  Widget _buildCategoryProgressSection() {
    final categoryProgress = _getCategoryProgress();

    return FadeInAnimation(
      delay: const Duration(milliseconds: 100),
      child: AnimatedCard(
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '各分类进度',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 16),
            ...MilestoneCategory.values.map((category) {
              final progress = categoryProgress[category] ?? 0;
              final countByCategory = DefaultMilestones.countByCategory;
              final totalInCategory = countByCategory[category] ?? 0;
              final completedInCategory = (progress * totalInCategory).round();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          category.icon,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.displayName,
                            style: AppTextStyles.body,
                          ),
                        ),
                        Text(
                          '$completedInCategory/$totalInCategory',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: AppTextStyles.body.copyWith(
                            color: category.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation(category.color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentMilestonesSection() {
    final currentMilestones = _getCurrentMilestones();

    if (currentMilestones.isEmpty) {
      return const SizedBox.shrink();
    }

    return FadeInAnimation(
      delay: const Duration(milliseconds: 200),
      child: AnimatedCard(
        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '当前关注',
                  style: AppTextStyles.subtitle,
                ),
                TextButton(
                  onPressed: _navigateToList,
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '适合${_babyAgeInMonths}个月宝宝的里程碑：',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 12),
            ...currentMilestones.asMap().entries.map((entry) {
              final milestone = entry.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: milestone.category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Center(
                    child: Icon(
                      milestone.category.icon,
                      size: 20,
                      color: milestone.category.color,
                    ),
                  ),
                ),
                title: Text(
                  milestone.title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  milestone.category.displayName,
                  style: AppTextStyles.caption.copyWith(
                    color: milestone.category.color,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textTertiary,
                ),
                onTap: _navigateToList,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    // 计算最近完成的里程碑
    final recentCompleted = _completedRecords.take(3).toList();

    return FadeInAnimation(
      delay: const Duration(milliseconds: 300),
      child: AnimatedCard(
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最近完成',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 12),
            if (recentCompleted.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '还没有完成的里程碑，快去记录吧！',
                    style: AppTextStyles.caption,
                  ),
                ),
              )
            else
              ...recentCompleted.map((record) {
                final milestone = DefaultMilestones.getMilestoneById(record.milestoneId);
                if (milestone == null) return const SizedBox.shrink();

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  title: Text(
                    milestone.title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    _formatDate(record.completedDate),
                    style: AppTextStyles.caption,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
