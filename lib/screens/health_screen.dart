import 'package:flutter/material.dart';
import '../models/baby.dart';
import '../services/database_service.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Baby? _baby;
  
  // 疫苗数据
  final List<Vaccine> _vaccines = [
    // 出生时
    Vaccine('乙肝疫苗第1剂', '出生', true, DateTime(2025, 6, 10)),
    Vaccine('卡介苗', '出生', true, DateTime(2025, 6, 10)),
    // 1月龄
    Vaccine('乙肝疫苗第2剂', '1月龄', true, DateTime(2025, 7, 10)),
    // 2月龄
    Vaccine('脊灰疫苗第1剂', '2月龄', true, DateTime(2025, 8, 10)),
    // 3月龄
    Vaccine('脊灰疫苗第2剂', '3月龄', true, DateTime(2025, 9, 10)),
    Vaccine('百白破疫苗第1剂', '3月龄', true, DateTime(2025, 9, 10)),
    // 4月龄
    Vaccine('脊灰疫苗第3剂', '4月龄', true, DateTime(2025, 10, 10)),
    Vaccine('百白破疫苗第2剂', '4月龄', true, DateTime(2025, 10, 10)),
    // 5月龄
    Vaccine('百白破疫苗第3剂', '5月龄', true, DateTime(2025, 11, 10)),
    // 6月龄
    Vaccine('乙肝疫苗第3剂', '6月龄', false, null),
    Vaccine('A群流脑疫苗第1剂', '6月龄', false, null),
    // 8月龄
    Vaccine('麻腮风疫苗第1剂', '8月龄', false, null),
    Vaccine('乙脑减毒活疫苗第1剂', '8月龄', false, null),
    // 9月龄
    Vaccine('A群流脑疫苗第2剂', '9月龄', false, null),
    // 18月龄
    Vaccine('百白破疫苗第4剂', '18月龄', false, null),
    Vaccine('麻腮风疫苗第2剂', '18月龄', false, null),
    Vaccine('甲肝减毒活疫苗', '18月龄', false, null),
    // 2岁
    Vaccine('乙脑减毒活疫苗第2剂', '2岁', false, null),
    // 3岁
    Vaccine('A群C群流脑疫苗第1剂', '3岁', false, null),
    // 4岁
    Vaccine('脊灰疫苗第4剂', '4岁', false, null),
    // 6岁
    Vaccine('白破疫苗', '6岁', false, null),
    Vaccine('A群C群流脑疫苗第2剂', '6岁', false, null),
  ];

  // 疾病记录
  final List<IllnessRecord> _illnessRecords = [
    IllnessRecord(
      date: DateTime(2025, 8, 15),
      symptom: '低烧',
      temperature: 37.8,
      description: '下午开始有点发热，精神状态还好',
      treatment: '物理降温，多喝水',
      duration: '1天',
    ),
    IllnessRecord(
      date: DateTime(2025, 10, 20),
      symptom: '感冒',
      temperature: null,
      description: '流鼻涕，轻微咳嗽',
      treatment: '多喝水，保持室内湿度',
      duration: '3天',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final babies = await DatabaseService.instance.getAllBabies();
    if (babies.isNotEmpty) {
      setState(() {
        _baby = babies.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _vaccines.where((v) => v.completed).length;
    final totalCount = _vaccines.length;
    final nextVaccine = _vaccines.firstWhere(
      (v) => !v.completed,
      orElse: () => _vaccines.last,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('健康管理'),
        backgroundColor: const Color(0xFF667eea),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVaccineTab(completedCount, totalCount, nextVaccine),
          _buildIllnessTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIllnessDialog(),
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVaccineTab(int completed, int total, Vaccine next) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 进度卡片
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '疫苗接种进度',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$completed/$total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '已完成 ${(completed / total * 100).toStringAsFixed(0)}%',
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
                      value: completed / total,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 8,
                    ),
                  ),
                ],
              ),
              if (!next.completed) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '下次接种',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              next.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 疫苗列表
        const Text(
          '疫苗清单',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        ..._vaccines.map((vaccine) => _buildVaccineItem(vaccine)),
      ],
    );
  }

  Widget _buildVaccineItem(Vaccine vaccine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: vaccine.completed
              ? const Color(0xFF4ade80).withOpacity(0.1)
              : const Color(0xFFF5F5F7),
          child: Icon(
            vaccine.completed ? Icons.check_circle : Icons.circle_outlined,
            color: vaccine.completed ? const Color(0xFF4ade80) : Colors.grey,
          ),
        ),
        title: Text(
          vaccine.name,
          style: TextStyle(
            decoration: vaccine.completed ? TextDecoration.lineThrough : null,
            color: vaccine.completed ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text('${vaccine.time}接种'),
        trailing: vaccine.completed
            ? Text(
                '${vaccine.completedDate?.month}月${vaccine.completedDate?.day}日',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            : TextButton(
                onPressed: () => _markVaccineCompleted(vaccine),
                child: const Text('标记完成'),
              ),
      ),
    );
  }

  Widget _buildIllnessTab() {
    if (_illnessRecords.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.healing, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无疾病记录', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text('点击右下角添加记录', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
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
                        color: record.temperature != null
                            ? Colors.red.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        record.symptom,
                        style: TextStyle(
                          color: record.temperature != null ? Colors.red : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (record.temperature != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${record.temperature}°C',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${record.date.month}月${record.date.day}日',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              record.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.medical_services, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '治疗: ${record.treatment}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.timer, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '持续: ${record.duration}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _markVaccineCompleted(Vaccine vaccine) {
    setState(() {
      vaccine.completed = true;
      vaccine.completedDate = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${vaccine.name}已标记完成')),
    );
  }

  void _showAddIllnessDialog() {
    final symptomController = TextEditingController();
    final tempController = TextEditingController();
    final descController = TextEditingController();
    final treatmentController = TextEditingController();
    final durationController = TextEditingController();

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
                decoration: const InputDecoration(
                  labelText: '症状',
                  hintText: '如：发烧、感冒、腹泻',
                ),
              ),
              TextField(
                controller: tempController,
                decoration: const InputDecoration(
                  labelText: '体温（可选）',
                  hintText: '如：38.5',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: '详细描述',
                  hintText: '症状表现、精神状态等',
                ),
                maxLines: 2,
              ),
              TextField(
                controller: treatmentController,
                decoration: const InputDecoration(
                  labelText: '治疗措施',
                  hintText: '用药、护理方法等',
                ),
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: '持续时间',
                  hintText: '如：2天',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (symptomController.text.isNotEmpty) {
                setState(() {
                  _illnessRecords.add(IllnessRecord(
                    date: DateTime.now(),
                    symptom: symptomController.text,
                    temperature: tempController.text.isNotEmpty
                        ? double.tryParse(tempController.text)
                        : null,
                    description: descController.text,
                    treatment: treatmentController.text,
                    duration: durationController.text,
                  ));
                });
                Navigator.pop(context);
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
}

class Vaccine {
  String name;
  String time;
  bool completed;
  DateTime? completedDate;

  Vaccine(this.name, this.time, this.completed, this.completedDate);
}

class IllnessRecord {
  DateTime date;
  String symptom;
  double? temperature;
  String description;
  String treatment;
  String duration;

  IllnessRecord({
    required this.date,
    required this.symptom,
    this.temperature,
    required this.description,
    required this.treatment,
    required this.duration,
  });
}
