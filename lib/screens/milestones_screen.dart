import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../constants/milestone_data.dart';
import '../widgets/animations.dart';
import '../models/baby.dart';
import '../models/milestone_record.dart';
import '../services/database_service.dart';

class Milestone {
  final String id;
  final String title;
  bool completed;
  DateTime? completedDate;
  String? photoPath;

  Milestone(this.id, this.title, this.completed, this.completedDate, {this.photoPath});
}

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  Baby? _baby;
  late final Map<String, List<Milestone>> _milestonesByMonth;

  _MilestonesScreenState() {
    // 从常量数据初始化里程碑
    _milestonesByMonth = {};
    DefaultMilestones.milestonesByMonth.forEach((month, defs) {
      _milestonesByMonth[month] = defs
          .map((def) => Milestone(def.id, def.title, false, null))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final babies = await DatabaseService.instance.getAllBabies();
    if (babies.isNotEmpty) {
      final baby = babies.first;
      final babyId = baby.id;
      if (babyId != null) {
        setState(() => _baby = baby);
        final records = await DatabaseService.instance.getMilestoneRecords(babyId);
        _updateMilestonesFromRecords(records);
      }
    }
  }

  void _updateMilestonesFromRecords(List<MilestoneRecord> records) {
    for (final record in records) {
      for (final list in _milestonesByMonth.values) {
        for (final m in list) {
          if (m.id == record.milestoneId) {
            m.completed = true;
            m.completedDate = record.completedDate;
            m.photoPath = record.photoPath;
          }
        }
      }
    }
    setState(() {});
  }

  Future<void> _toggleMilestone(Milestone milestone) async {
    if (_baby == null) return;
    
    final babyId = _baby!.id;
    if (babyId == null) return;
    
    if (!milestone.completed) {
      // 标记完成
      final record = MilestoneRecord(
        babyId: babyId,
        milestoneId: milestone.id,
        completedDate: DateTime.now(),
      );
      await DatabaseService.instance.createMilestoneRecord(record);
      setState(() {
        milestone.completed = true;
        milestone.completedDate = DateTime.now();
      });
    } else {
      // 取消完成
      await DatabaseService.instance.deleteMilestoneRecord(babyId, milestone.id);
      setState(() {
        milestone.completed = false;
        milestone.completedDate = null;
        milestone.photoPath = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalCompleted = 0;
    int totalCount = 0;
    _milestonesByMonth.forEach((_, list) {
      totalCompleted += list.where((m) => m.completed).length;
      totalCount += list.length;
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('发育里程碑'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          FadeInAnimation(
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
                        Text('发育进度', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                          '$totalCompleted/$totalCount',
                          style: AppTextStyles.headline.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: totalCount > 0 ? totalCompleted / totalCount : 0,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
              itemCount: _milestonesByMonth.length,
              itemBuilder: (context, index) {
                final month = _milestonesByMonth.keys.elementAt(index);
                final milestones = _milestonesByMonth[month]!;
                return ListItemAnimation(
                  index: index,
                  child: _buildMonthSection(month, milestones),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(String month, List<Milestone> milestones) {
    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
          childrenPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
          title: Text(month, style: AppTextStyles.title),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textTertiary,
          children: milestones.asMap().entries.map((entry) {
            final m = entry.value;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: AnimatedContainer(
                duration: AppAnimations.fast,
                child: Checkbox(
                  value: m.completed,
                  onChanged: (_) => _toggleMilestone(m),
                  activeColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              title: Text(
                m.title,
                style: AppTextStyles.body.copyWith(
                  decoration: m.completed ? TextDecoration.lineThrough : null,
                  color: m.completed ? AppColors.textTertiary : AppColors.textPrimary,
                ),
              ),
              subtitle: m.completedDate != null
                  ? Text(_formatDate(m.completedDate!), style: AppTextStyles.caption)
                  : null,
              trailing: AnimatedSwitcher(
                duration: AppAnimations.normal,
                child: m.completed
                    ? Icon(Icons.check_circle, color: AppColors.success, key: ValueKey('completed_${m.id}'))
                    : Icon(Icons.radio_button_unchecked, color: AppColors.textTertiary, key: ValueKey('pending_${m.id}')),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
