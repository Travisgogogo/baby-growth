import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../constants/vaccine_data.dart';
import '../models/baby.dart';
import '../models/illness_record.dart';
import '../models/vaccine_record.dart';
import '../services/database_service.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Baby? _baby;
  List<IllnessRecord> _illnessRecords = [];
  List<VaccineRecord> _vaccineRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final babies = await DatabaseService.instance.getAllBabies();
    if (babies.isNotEmpty) {
      final baby = babies.first;
      final babyId = baby.id;
      if (babyId != null) {
        setState(() => _baby = baby);
        
        // 加载疾病记录
        final illnessRecords = await DatabaseService.instance.getIllnessRecords(babyId);
        setState(() => _illnessRecords = illnessRecords);
        
        // 加载疫苗记录，如果没有则初始化
        var vaccineRecords = await DatabaseService.instance.getVaccineRecords(babyId);
        if (vaccineRecords.isEmpty) {
          // 初始化默认疫苗
          for (final v in DefaultVaccines.vaccines) {
            final record = VaccineRecord(
              babyId: babyId,
              vaccineId: v.id,
              name: v.name,
              scheduledTime: v.scheduledTime,
            );
            await DatabaseService.instance.createVaccineRecord(record);
          }
          vaccineRecords = await DatabaseService.instance.getVaccineRecords(babyId);
        }
        setState(() => _vaccineRecords = vaccineRecords);
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _markVaccineCompleted(VaccineRecord record) async {
    final updated = record.copyWith(completed: true, completedDate: DateTime.now());
    await DatabaseService.instance.updateVaccineRecord(updated);
    await _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${record.name}已标记完成')),
    );
  }

  Future<void> _markRecovered(IllnessRecord record) async {
    final updated = record.copyWith(endTime: DateTime.now());
    await DatabaseService.instance.updateIllnessRecord(updated);
    await _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已标记痊愈')),
    );
  }

  void _showAddIllnessDialog() {
    final symptomController = TextEditingController();
    final tempController = TextEditingController();
    final descController = TextEditingController();
    final treatmentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加疾病记录'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: symptomController,
                decoration: const InputDecoration(labelText: '症状', hintText: '如：发烧、感冒、腹泻', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tempController,
                decoration: const InputDecoration(labelText: '体温（可选）', hintText: '如：38.5', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: '详细描述', hintText: '症状表现、精神状态等', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: treatmentController,
                decoration: const InputDecoration(labelText: '治疗措施', hintText: '用药、护理方法等', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () async {
              if (symptomController.text.isNotEmpty && _baby != null) {
                final babyId = _baby!.id;
                if (babyId == null) return;
                final record = IllnessRecord(
                  babyId: babyId,
                  startTime: DateTime.now(),
                  symptom: symptomController.text,
                  temperature: tempController.text.isNotEmpty ? double.tryParse(tempController.text) : null,
                  description: descController.text,
                  treatment: treatmentController.text,
                );
                await DatabaseService.instance.createIllnessRecord(record);
                Navigator.pop(context);
                await _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('记录已添加')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _vaccineRecords.where((v) => v.completed).length;
    final totalCount = _vaccineRecords.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('健康管理'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: '疫苗接种'),
            Tab(text: '疾病记录'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildVaccineTab(completedCount, totalCount),
                _buildIllnessTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIllnessDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVaccineTab(int completed, int total) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('疫苗接种进度', style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$completed/$total', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        Text('已完成 ${total > 0 ? (completed / total * 100).toStringAsFixed(0) : 0}%', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: total > 0 ? completed / total : 0,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('疫苗清单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ..._vaccineRecords.map((v) => _buildVaccineItem(v)),
      ],
    );
  }

  Widget _buildVaccineItem(VaccineRecord v) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: v.completed ? const Color(0xFF4ade80).withOpacity(0.1) : const Color(0xFFF5F5F7),
          child: Icon(v.completed ? Icons.check_circle : Icons.circle_outlined, color: v.completed ? const Color(0xFF4ade80) : Colors.grey),
        ),
        title: Text(v.name, style: TextStyle(decoration: v.completed ? TextDecoration.lineThrough : null, color: v.completed ? Colors.grey : Colors.black)),
        subtitle: Text('${v.scheduledTime}接种'),
        trailing: v.completed
            ? Text('${v.completedDate?.month}月${v.completedDate?.day}日', style: const TextStyle(fontSize: 12, color: Colors.grey))
            : TextButton(onPressed: () => _markVaccineCompleted(v), child: const Text('标记完成')),
      ),
    );
  }

  Widget _buildIllnessTab() {
    if (_illnessRecords.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.healing, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Text('暂无疾病记录', style: TextStyle(color: Colors.grey)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _illnessRecords.length,
      itemBuilder: (context, index) {
        final record = _illnessRecords[index];
        return _buildIllnessCard(record);
      },
    );
  }

  Widget _buildIllnessCard(IllnessRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: record.isOngoing ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(record.symptom, style: TextStyle(color: record.isOngoing ? Colors.red : Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                    if (record.temperature != null) ...[
                      const SizedBox(width: 8),
                      Text('${record.temperature}°C', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
                if (record.isOngoing)
                  FilledButton.icon(
                    onPressed: () => _markRecovered(record),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('已痊愈'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(0, 32)),
                  )
                else
                  Chip(label: const Text('已痊愈'), backgroundColor: Colors.green.withOpacity(0.1), side: BorderSide.none),
              ],
            ),
            const SizedBox(height: 12),
            Text(record.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.medical_services, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text('治疗: ${record.treatment}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.timer, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text('持续: ${record.duration}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ]),
          ],
        ),
      ),
    );
  }
}
