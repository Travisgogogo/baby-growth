import 'package:flutter/material.dart';

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  // 里程碑数据（按月龄分类）
  final Map<String, List<Milestone>> _milestonesByMonth = {
    '0-3个月': [
      Milestone('追视移动物体', true, DateTime(2025, 7, 15)),
      Milestone('对声音有反应', true, DateTime(2025, 7, 20)),
      Milestone('俯卧抬头45度', true, DateTime(2025, 8, 5)),
      Milestone('发出咕咕声', true, DateTime(2025, 8, 10)),
    ],
    '4-6个月': [
      Milestone('翻身', true, DateTime(2025, 9, 15)),
      Milestone('独坐片刻', true, DateTime(2025, 10, 1)),
      Milestone('抓取玩具', true, DateTime(2025, 10, 10)),
      Milestone('笑出声', true, DateTime(2025, 9, 20)),
    ],
    '7-9个月': [
      Milestone('独坐稳定', true, DateTime(2025, 11, 15)),
      Milestone('双手传递物品', true, DateTime(2025, 11, 20)),
      Milestone('咿呀学语', true, DateTime(2025, 12, 1)),
      Milestone('爬行', false, null),
      Milestone('理解"不"', false, null),
    ],
    '10-12个月': [
      Milestone('扶站', false, null),
      Milestone('挥手再见', false, null),
      Milestone('叫爸爸妈妈', false, null),
      Milestone('独站片刻', false, null),
      Milestone('牵手走路', false, null),
    ],
    '1-2岁': [
      Milestone('独走', false, null),
      Milestone('用勺子吃饭', false, null),
      Milestone('说10个词', false, null),
      Milestone('指认身体部位', false, null),
      Milestone('模仿动作', false, null),
    ],
  };

  @override
  Widget build(BuildContext context) {
    int totalCompleted = 0;
    int totalCount = 0;
    _milestonesByMonth.forEach((_, milestones) {
      totalCompleted += milestones.where((m) => m.completed).length;
      totalCount += milestones.length;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('发育里程碑'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 进度概览
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
                      const Text(
                        '发育进度',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$totalCompleted/$totalCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '已完成 ${(totalCompleted / totalCount * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: totalCompleted / totalCount,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    strokeWidth: 8,
                  ),
                ),
              ],
            ),
          ),

          // 里程碑列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _milestonesByMonth.length,
              itemBuilder: (context, index) {
                final monthRange = _milestonesByMonth.keys.elementAt(index);
                final milestones = _milestonesByMonth[monthRange]!;
                return _buildMonthSection(monthRange, milestones);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(String monthRange, List<Milestone> milestones) {
    final completedCount = milestones.where((m) => m.completed).length;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              monthRange,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$completedCount/${milestones.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF667eea),
                ),
              ),
            ),
          ],
        ),
        children: milestones.map((milestone) => _buildMilestoneItem(milestone)).toList(),
      ),
    );
  }

  Widget _buildMilestoneItem(Milestone milestone) {
    return ListTile(
      leading: GestureDetector(
        onTap: () => _toggleMilestone(milestone),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: milestone.completed
                ? const Color(0xFF4ade80).withOpacity(0.1)
                : const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            milestone.completed ? Icons.check_circle : Icons.circle_outlined,
            color: milestone.completed ? const Color(0xFF4ade80) : Colors.grey,
          ),
        ),
      ),
      title: Text(
        milestone.name,
        style: TextStyle(
          decoration: milestone.completed ? TextDecoration.lineThrough : null,
          color: milestone.completed ? Colors.grey : Colors.black,
        ),
      ),
      subtitle: milestone.completed && milestone.completedDate != null
          ? Text(
              '完成于 ${_formatDate(milestone.completedDate!)}',
              style: const TextStyle(fontSize: 12),
            )
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.camera_alt_outlined),
        onPressed: () => _showAddPhotoDialog(milestone),
      ),
    );
  }

  void _toggleMilestone(Milestone milestone) {
    setState(() {
      milestone.completed = !milestone.completed;
      milestone.completedDate = milestone.completed ? DateTime.now() : null;
    });
  }

  void _showAddPhotoDialog(Milestone milestone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('📸 ${milestone.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '添加备注',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('照片已保存')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class Milestone {
  String name;
  bool completed;
  DateTime? completedDate;

  Milestone(this.name, this.completed, this.completedDate);
}
