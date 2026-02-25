import 'package:flutter/material.dart';
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
  final Map<String, List<Milestone>> _milestonesByMonth = {
    '0-3个月': [
      Milestone('m1', '追视移动物体', false, null),
      Milestone('m2', '对声音有反应', false, null),
      Milestone('m3', '俯卧抬头45度', false, null),
      Milestone('m4', '发出咕咕声', false, null),
    ],
    '4-6个月': [
      Milestone('m5', '翻身', false, null),
      Milestone('m6', '独坐片刻', false, null),
      Milestone('m7', '抓取玩具', false, null),
      Milestone('m8', '笑出声', false, null),
    ],
    '7-9个月': [
      Milestone('m9', '独坐稳定', false, null),
      Milestone('m10', '双手传递物品', false, null),
      Milestone('m11', '咿呀学语', false, null),
      Milestone('m12', '爬行', false, null),
      Milestone('m13', '理解"不"', false, null),
    ],
    '10-12个月': [
      Milestone('m14', '扶站', false, null),
      Milestone('m15', '挥手再见', false, null),
      Milestone('m16', '叫爸爸妈妈', false, null),
      Milestone('m17', '独站片刻', false, null),
      Milestone('m18', '牵手走路', false, null),
    ],
    '1-2岁': [
      Milestone('m19', '独走', false, null),
      Milestone('m20', '用勺子吃饭', false, null),
      Milestone('m21', '说10个词', false, null),
      Milestone('m22', '指认身体部位', false, null),
      Milestone('m23', '模仿动作', false, null),
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final babies = await DatabaseService.instance.getAllBabies();
    if (babies.isNotEmpty) {
      setState(() => _baby = babies.first);
      final records = await DatabaseService.instance.getMilestoneRecords(babies.first.id!);
      _updateMilestonesFromRecords(records);
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
    
    if (!milestone.completed) {
      // 标记完成
      final record = MilestoneRecord(
        babyId: _baby!.id!,
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
      await DatabaseService.instance.deleteMilestoneRecord(_baby!.id!, milestone.id);
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
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
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
