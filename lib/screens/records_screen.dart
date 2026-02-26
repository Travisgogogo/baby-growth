import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../widgets/animations.dart';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../models/feed_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../services/database_service.dart';
import '../widgets/confirm_dialog.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Baby? _baby;
  List<FeedRecord> _feedRecords = [];
  List<GrowthRecord> _growthRecords = [];
  List<SleepRecord> _sleepRecords = [];
  List<DiaperRecord> _diaperRecords = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final babies = await DatabaseService.instance.getAllBabies();
    if (babies.isNotEmpty) {
      final baby = babies.first;
      final babyId = baby.id;
      if (babyId != null) {
        setState(() => _baby = baby);
        
        final feeds = await DatabaseService.instance.getFeedRecords(babyId);
        final growth = await DatabaseService.instance.getGrowthRecords(babyId);
        final sleep = await DatabaseService.instance.getSleepRecords(babyId);
        final diapers = await DatabaseService.instance.getDiaperRecords(babyId);
        
        setState(() {
          _feedRecords = feeds;
          _growthRecords = growth;
          _sleepRecords = sleep;
          _diaperRecords = diapers;
        });
      }
    }
  }

  Future<void> _deleteFeedRecord(int id) async {
    final confirmed = await ConfirmDialog.showDeleteConfirm(
      context,
      title: '确认删除',
      content: '确定要删除这条喂养记录吗？',
    );
    if (confirmed) {
      await DatabaseService.instance.deleteFeedRecord(id);
      await _loadData();
    }
  }

  Future<void> _deleteGrowthRecord(int id) async {
    final confirmed = await ConfirmDialog.showDeleteConfirm(
      context,
      title: '确认删除',
      content: '确定要删除这条生长记录吗？',
    );
    if (confirmed) {
      await DatabaseService.instance.deleteGrowthRecord(id);
      await _loadData();
    }
  }

  Future<void> _deleteSleepRecord(int id) async {
    final confirmed = await ConfirmDialog.showDeleteConfirm(
      context,
      title: '确认删除',
      content: '确定要删除这条睡眠记录吗？',
    );
    if (confirmed) {
      await DatabaseService.instance.deleteSleepRecord(id);
      await _loadData();
    }
  }

  Future<void> _deleteDiaperRecord(int id) async {
    final confirmed = await ConfirmDialog.showDeleteConfirm(
      context,
      title: '确认删除',
      content: '确定要删除这条换尿布记录吗？',
    );
    if (confirmed) {
      await DatabaseService.instance.deleteDiaperRecord(id);
      await _loadData();
    }
  }

  void _editFeedRecord(FeedRecord record) {
    final amountController = TextEditingController(text: record.amount?.toString());
    String type = record.type;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('编辑喂养记录'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '母乳', label: Text('母乳')),
                  ButtonSegment(value: '奶粉', label: Text('奶粉')),
                  ButtonSegment(value: '辅食', label: Text('辅食')),
                ],
                selected: {type},
                onSelectionChanged: (set) => setDialogState(() => type = set.first),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '量（ml或g）', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            FilledButton(
              onPressed: () async {
                final updated = record.copyWith(
                  type: type,
                  amount: double.tryParse(amountController.text),
                );
                await DatabaseService.instance.updateFeedRecord(updated);
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

  void _editGrowthRecord(GrowthRecord record) {
    final weightController = TextEditingController(text: record.weight?.toString());
    final heightController = TextEditingController(text: record.height?.toString());
    final headController = TextEditingController(text: record.headCircumference?.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑生长记录'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '体重 (kg)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '身高 (cm)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: headController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '头围 (cm)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () async {
              final updated = record.copyWith(
                weight: double.tryParse(weightController.text),
                height: double.tryParse(heightController.text),
                headCircumference: double.tryParse(headController.text),
              );
              await DatabaseService.instance.updateGrowthRecord(updated);
              Navigator.pop(context);
              await _loadData();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('全部记录'),
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
            Tab(text: '喂养'),
            Tab(text: '生长'),
            Tab(text: '睡眠'),
            Tab(text: '尿布'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedTab(),
          _buildGrowthTab(),
          _buildSleepTab(),
          _buildDiaperTab(),
        ],
      ),
    );
  }

  Widget _buildFeedTab() {
    if (_feedRecords.isEmpty) {
      return Center(
        child: FadeInAnimation(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('暂无喂养记录', style: AppTextStyles.subtitle.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: _feedRecords.length,
      itemBuilder: (context, index) {
        final record = _feedRecords[index];
        return ListItemAnimation(
          index: index,
          child: AnimatedCard(
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              child: Dismissible(
                key: Key('feed_${record.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppDimensions.paddingMedium),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteFeedRecord(record.id!),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.breastMilk,
                    child: const Icon(Icons.restaurant, color: Colors.white),
                  ),
                  title: Text('${record.type} ${record.amount?.toInt()}ml', style: AppTextStyles.body),
                  subtitle: Text(_formatTime(record.time), style: AppTextStyles.caption),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, size: 20, color: AppColors.primary),
                    onPressed: () => _editFeedRecord(record),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrowthTab() {
    if (_growthRecords.isEmpty) {
      return Center(
        child: FadeInAnimation(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up, size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('暂无生长记录', style: AppTextStyles.subtitle.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: _growthRecords.length,
      itemBuilder: (context, index) {
        final record = _growthRecords[index];
        return ListItemAnimation(
          index: index,
          child: AnimatedCard(
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              child: Dismissible(
                key: Key('growth_${record.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppDimensions.paddingMedium),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteGrowthRecord(record.id!),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.mint,
                    child: const Icon(Icons.trending_up, color: Colors.white),
                  ),
                  title: Text(
                    '${record.weight?.toStringAsFixed(1)}kg, ${record.height?.toStringAsFixed(0)}cm',
                    style: AppTextStyles.body,
                  ),
                  subtitle: Text(_formatDate(record.date), style: AppTextStyles.caption),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, size: 20, color: AppColors.primary),
                    onPressed: () => _editGrowthRecord(record),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSleepTab() {
    if (_sleepRecords.isEmpty) {
      return Center(
        child: FadeInAnimation(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bedtime, size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('暂无睡眠记录', style: AppTextStyles.subtitle.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: _sleepRecords.length,
      itemBuilder: (context, index) {
        final record = _sleepRecords[index];
        final duration = record.endTime != null 
            ? record.endTime!.difference(record.startTime).inMinutes 
            : null;
        return ListItemAnimation(
          index: index,
          child: AnimatedCard(
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              child: Dismissible(
                key: Key('sleep_${record.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppDimensions.paddingMedium),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteSleepRecord(record.id!),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary,
                    child: const Icon(Icons.bedtime, color: Colors.white),
                  ),
                  title: Text(
                    duration != null ? '睡眠 ${duration ~/ 60}小时${duration % 60}分钟' : '睡眠中',
                    style: AppTextStyles.body,
                  ),
                  subtitle: Text(_formatTime(record.startTime), style: AppTextStyles.caption),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiaperTab() {
    if (_diaperRecords.isEmpty) {
      return Center(
        child: FadeInAnimation(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.baby_changing_station, size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('暂无换尿布记录', style: AppTextStyles.subtitle.copyWith(color: AppColors.textTertiary)),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      itemCount: _diaperRecords.length,
      itemBuilder: (context, index) {
        final record = _diaperRecords[index];
        return ListItemAnimation(
          index: index,
          child: AnimatedCard(
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              child: Dismissible(
                key: Key('diaper_${record.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppDimensions.paddingMedium),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteDiaperRecord(record.id!),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: const Icon(Icons.baby_changing_station, color: Colors.white),
                  ),
                  title: Text(record.type, style: AppTextStyles.body),
                  subtitle: Text(_formatTime(record.time), style: AppTextStyles.caption),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
