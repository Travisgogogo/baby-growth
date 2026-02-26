import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../constants/milestone_data.dart';
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
      appBar: AppBar(
        title: const Text('发育里程碑'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('发育进度', style: TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text('$totalCompleted/$totalCount',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                CircularProgressIndicator(
                  value: totalCount > 0 ? totalCompleted / totalCount : 0,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 8,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _milestonesByMonth.length,
              itemBuilder: (context, index) {
                final month = _milestonesByMonth.keys.elementAt(index);
                final milestones = _milestonesByMonth[month]!;
                return _buildMonthSection(month, milestones);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(String month, List<Milestone> milestones) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(month, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: milestones.map((m) => ListTile(
          leading: Checkbox(
            value: m.completed,
            onChanged: (_) => _toggleMilestone(m),
          ),
          title: Text(m.title, style: TextStyle(
            decoration: m.completed ? TextDecoration.lineThrough : null,
            color: m.completed ? Colors.grey : Colors.black,
          )),
          subtitle: m.completedDate != null 
              ? Text('${_formatDate(m.completedDate!)}')
              : null,
          trailing: m.completed 
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        )).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
