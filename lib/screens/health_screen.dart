import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../constants/vaccine_data.dart';
import '../widgets/animations.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('健康管理'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '疫苗接种'),
            Tab(text: '疾病记录'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVaccineTab(int completed, int total) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      children: [
        FadeInAnimation(
          child: Container(
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
                Text('疫苗接种进度', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$completed/$total',
                            style: AppTextStyles.headline.copyWith(color: Colors.white),
                          ),
                          Text(
                            '已完成 ${total > 0 ? (completed / total * 100).toStringAsFixed(0) : 0}%',
                            style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.9)),
                          ),
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
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLarge),
        FadeInAnimation(
          delay: const Duration(milliseconds: 100),
          child: Text('疫苗清单', style: AppTextStyles.title),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        ..._vaccineRecords.asMap().entries.map((entry) => ListItemAnimation(
          index: entry.key,
          child: _buildVaccineItem(entry.value),
        )),
      ],
    );
  }

  Widget _buildVaccineItem(VaccineRecord v) {
    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium, vertical: 4),
          leading: AnimatedContainer(
            duration: AppAnimations.normal,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: v.completed ? AppColors.success.withOpacity(0.1) : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: Icon(
              v.completed ? Icons.check_circle : Icons.circle_outlined,
              color: v.completed ? AppColors.success : AppColors.textTertiary,
            ),
          ),
          title: Text(
            v.name,
            style: AppTextStyles.body.copyWith(
              decoration: v.completed ? TextDecoration.lineThrough : null,
              color: v.completed ? AppColors.textTertiary : AppColors.textPrimary,
            ),
          ),
          subtitle: Text(v.scheduledTime, style: AppTextStyles.caption),
          trailing: v.completed
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${v.completedDate?.month}月${v.completedDate?.day}日',
                      style: AppTextStyles.caption,
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 20, color: AppColors.primary),
                      onPressed: () => _editVaccineRecord(v),
                    ),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => _markVaccineCompleted(v),
                      child: const Text('标记完成'),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 20, color: AppColors.primary),
                      onPressed: () => _editVaccineRecord(v),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildIllnessTab() {
    if (_illnessRecords.isEmpty) {
      return Center(
        child: FadeInAnimation(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.healing, size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('暂无疾病记录', style: AppTextStyles.subtitle.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: _illnessRecords.length,
      itemBuilder: (context, index) {
        final record = _illnessRecords[index];
        return ListItemAnimation(
          index: index,
          child: _buildIllnessCard(record),
        );
      },
    );
  }

  Widget _buildIllnessCard(IllnessRecord record) {
    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
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
                      color: record.isOngoing ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Text(
                      record.symptom,
                      style: AppTextStyles.caption.copyWith(
                        color: record.isOngoing ? AppColors.error : AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (record.temperature != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${record.temperature}°C',
                      style: AppTextStyles.subtitle.copyWith(color: AppColors.error),
                    ),
                  ],
                ],
              ),
              if (record.isOngoing)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedButton(
                      onTap: () => _markRecovered(record),
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('已痊愈', style: AppTextStyles.caption.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 20, color: AppColors.primary),
                      onPressed: () => _editIllnessRecord(record),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: Text('已痊愈', style: AppTextStyles.caption.copyWith(color: AppColors.success)),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 20, color: AppColors.primary),
                      onPressed: () => _editIllnessRecord(record),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(record.description, style: AppTextStyles.body),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.medical_services, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Expanded(child: Text('治疗: ${record.treatment}', style: AppTextStyles.caption)),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.timer, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text('持续: ${record.duration}', style: AppTextStyles.caption),
          ]),
        ],
      ),
    );
  }

  void _editVaccineRecord(VaccineRecord record) {
    DateTime? completedDate = record.completedDate;
    bool isCompleted = record.completed;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('编辑 ${record.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text('已完成接种'),
                value: isCompleted,
                onChanged: (value) {
                  setDialogState(() {
                    isCompleted = value ?? false;
                    if (isCompleted && completedDate == null) {
                      completedDate = DateTime.now();
                    }
                  });
                },
              ),
              if (isCompleted)
                ListTile(
                  title: const Text('接种日期'),
                  subtitle: Text(completedDate != null
                      ? '${completedDate!.year}年${completedDate!.month}月${completedDate!.day}日'
                      : '未选择'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: completedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setDialogState(() {
                        completedDate = date;
                      });
                    }
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final updated = record.copyWith(
                  completed: isCompleted,
                  completedDate: isCompleted ? completedDate : null,
                );
                await DatabaseService.instance.updateVaccineRecord(updated);
                Navigator.pop(context);
                await _loadData();
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _editIllnessRecord(IllnessRecord record) {
    final symptomController = TextEditingController(text: record.symptom);
    final tempController = TextEditingController(text: record.temperature?.toString());
    final descController = TextEditingController(text: record.description);
    final treatmentController = TextEditingController(text: record.treatment);
    DateTime startTime = record.startTime;
    DateTime? endTime = record.endTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('编辑疾病记录'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: symptomController,
                  decoration: const InputDecoration(labelText: '症状', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tempController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '体温 (°C)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: '描述', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: treatmentController,
                  decoration: const InputDecoration(labelText: '治疗措施', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('开始时间'),
                  subtitle: Text(_formatDateTime(startTime)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startTime,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(startTime),
                      );
                      if (time != null) {
                        setDialogState(() {
                          startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                ),
                ListTile(
                  title: const Text('结束时间'),
                  subtitle: Text(endTime != null ? _formatDateTime(endTime!) : '进行中'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endTime ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: endTime != null ? TimeOfDay.fromDateTime(endTime!) : TimeOfDay.now(),
                      );
                      if (time != null) {
                        setDialogState(() {
                          endTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                ),
                if (endTime != null)
                  TextButton(
                    onPressed: () {
                      setDialogState(() {
                        endTime = null;
                      });
                    },
                    child: const Text('标记为进行中'),
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
              onPressed: () async {
                final updated = record.copyWith(
                  symptom: symptomController.text,
                  temperature: double.tryParse(tempController.text),
                  description: descController.text,
                  treatment: treatmentController.text,
                  startTime: startTime,
                  endTime: endTime,  // 这个值可能为 null（进行中状态）
                );
                print('更新疾病记录: id=${updated.id}, endTime=${updated.endTime}'); // 调试
                final result = await DatabaseService.instance.updateIllnessRecord(updated);
                print('更新结果: $result'); // 调试
                Navigator.pop(context);
                await _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result ? '保存成功' : '保存失败')),
                  );
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.month}月${dt.day}日 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
