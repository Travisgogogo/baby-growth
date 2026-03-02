import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../models/vaccine_record.dart';
import '../../services/database_service.dart';
import '../../widgets/animations.dart';

/// 疫苗列表页面
class VaccineListScreen extends StatefulWidget {
  final int babyId;
  
  const VaccineListScreen({super.key, required this.babyId});

  @override
  State<VaccineListScreen> createState() => _VaccineListScreenState();
}

class _VaccineListScreenState extends State<VaccineListScreen> {
  List<VaccineRecord> _vaccineRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final records = await DatabaseService.instance.getVaccineRecords(widget.babyId);
      setState(() => _vaccineRecords = records);
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
    final completedCount = _vaccineRecords.where((v) => v.completed).length;
    final totalCount = _vaccineRecords.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('疫苗接种'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              children: [
                _buildProgressCard(completedCount, totalCount),
                const SizedBox(height: AppDimensions.paddingLarge),
                Text('疫苗清单', style: AppTextStyles.title),
                const SizedBox(height: AppDimensions.paddingMedium),
                ..._vaccineRecords.asMap().entries.map((entry) => ListItemAnimation(
                  index: entry.key,
                  child: _buildVaccineItem(entry.value),
                )),
              ],
            ),
    );
  }

  Widget _buildProgressCard(int completed, int total) {
    return Container(
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
                  ],
                )
              : TextButton(
                  onPressed: () => _markCompleted(v),
                  child: const Text('标记完成'),
                ),
        ),
      ),
    );
  }

  Future<void> _markCompleted(VaccineRecord record) async {
    final updated = record.copyWith(completed: true, completedDate: DateTime.now());
    final success = await DatabaseService.instance.updateVaccineRecord(updated);
    if (success) {
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${record.name}已标记完成')),
        );
      }
    }
  }
}
