import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../models/illness_record.dart';
import '../../services/database_service.dart';
import '../../widgets/animations.dart';

/// 疾病记录列表页面
class IllnessListScreen extends StatefulWidget {
  final int babyId;
  
  const IllnessListScreen({super.key, required this.babyId});

  @override
  State<IllnessListScreen> createState() => _IllnessListScreenState();
}

class _IllnessListScreenState extends State<IllnessListScreen> {
  List<IllnessRecord> _illnessRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final records = await DatabaseService.instance.getIllnessRecords(widget.babyId);
      setState(() => _illnessRecords = records);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('疾病记录'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _illnessRecords.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  itemCount: _illnessRecords.length,
                  itemBuilder: (context, index) => ListItemAnimation(
                    index: index,
                    child: _buildIllnessCard(_illnessRecords[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        backgroundColor: AppColors.error,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Future<void> _markRecovered(IllnessRecord record) async {
    final updated = record.copyWith(endTime: DateTime.now());
    final success = await DatabaseService.instance.updateIllnessRecord(updated);
    if (success) {
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已标记痊愈')),
        );
      }
    }
  }

  void _showAddDialog() {
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
                decoration: const InputDecoration(
                  labelText: '症状',
                  hintText: '如：发烧、感冒、腹泻',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tempController,
                decoration: const InputDecoration(
                  labelText: '体温（可选）',
                  hintText: '如：38.5',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: '详细描述',
                  hintText: '症状表现、精神状态等',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: treatmentController,
                decoration: const InputDecoration(
                  labelText: '治疗措施',
                  hintText: '用药、护理方法等',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () async {
              if (symptomController.text.isNotEmpty) {
                final record = IllnessRecord(
                  babyId: widget.babyId,
                  startTime: DateTime.now(),
                  symptom: symptomController.text,
                  temperature: tempController.text.isNotEmpty 
                      ? double.tryParse(tempController.text) 
                      : null,
                  description: descController.text,
                  treatment: treatmentController.text,
                );
                final result = await DatabaseService.instance.createIllnessRecord(record);
                if (result == null) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('保存失败，请重试')),
                    );
                  }
                  return;
                }
                Navigator.pop(context);
                await _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('记录已添加')),
                  );
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
