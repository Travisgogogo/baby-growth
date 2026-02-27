import 'package:flutter/material.dart';
import 'dart:io';
import '../constants/app_theme.dart';
import '../constants/milestone_data.dart';
import '../constants/who_growth_data.dart';
import '../widgets/animations.dart';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../models/feed_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../models/milestone.dart';
import '../services/database_service.dart';
import '../services/update_service.dart';
import 'growth_chart_screen.dart';
import 'growth_chart_detail_screen.dart';
import 'records_screen.dart';
import 'milestones_screen.dart';
import 'profile_screen.dart';
import 'health_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Baby? _baby;
  GrowthRecord? _latestGrowth;
  List<FeedRecord> _recentFeeds = [];
  List<SleepRecord> _recentSleeps = [];
  List<DiaperRecord> _recentDiapers = [];
  List<MilestoneRecord> _milestoneRecords = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Android 检查更新
    if (Platform.isAndroid) {
      _checkUpdate();
    }
  }

  Future<void> _checkUpdate() async {
    // 延迟检查，避免启动时卡顿
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final updateInfo = await UpdateService.checkUpdate();
    if (updateInfo != null && updateInfo.hasUpdate && mounted) {
      UpdateDialog.show(context, updateInfo);
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final babies = await DatabaseService.instance.getAllBabies();
    if (babies.isNotEmpty) {
      final baby = babies.first;
      final babyId = baby.id;
      if (babyId != null) {
        setState(() {
          _baby = baby;
        });
        await _loadBabyData(babyId);
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadBabyData(int babyId) async {
    final growthRecords = await DatabaseService.instance.getGrowthRecords(babyId);
    final feedRecords = await DatabaseService.instance.getFeedRecords(babyId);
    final sleepRecords = await DatabaseService.instance.getSleepRecords(babyId);
    final diaperRecords = await DatabaseService.instance.getDiaperRecords(babyId);
    final milestoneRecords = await DatabaseService.instance.getMilestoneRecords(babyId);

    setState(() {
      if (growthRecords.isNotEmpty) {
        _latestGrowth = growthRecords.first;
      }
      _recentFeeds = feedRecords;
      _recentSleeps = sleepRecords;
      _recentDiapers = diaperRecords;
      _milestoneRecords = milestoneRecords;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_baby == null) {
      return Scaffold(
        body: _buildEmptyState(),
      );
    }

    final screens = [
      _buildHomeTab(),
      const GrowthChartScreen(),
      const RecordsScreen(),
      const MilestonesScreen(),
      const HealthScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // 切换到首页或我的页面时刷新数据
          if (index == 0 || index == 5) {
            _loadData();
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: '生长'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: '记录'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: '里程碑'),
          BottomNavigationBarItem(icon: Icon(Icons.health_and_safety), label: '健康'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_baby == null) {
      return _buildEmptyState();
    }
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildQuickActions(),
            _buildGrowthChart(),
            _buildRecentRecords(),
            _buildMilestones(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.child_care, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('欢迎使用宝宝成长记', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('请先添加宝宝信息', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showAddBabyDialog,
            icon: const Icon(Icons.add),
            label: const Text('添加宝宝'),
          ),
        ],
      ),
    );
  }

  void _showAddBabyDialog() {
    final nameController = TextEditingController();
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final headController = TextEditingController();
    String gender = '女';
    DateTime birthDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('添加宝宝'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '宝宝姓名',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: birthDate,
                      firstDate: DateTime(AppConstants.minBirthYear),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() => birthDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: '出生日期',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text('${birthDate.year}年${birthDate.month}月${birthDate.day}日'),
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: '男', label: Text('男')),
                    ButtonSegment(value: '女', label: Text('女')),
                  ],
                  selected: {gender},
                  onSelectionChanged: (set) => setDialogState(() => gender = set.first),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '出生体重 (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '出生身高 (cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: headController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '出生头围 (cm)',
                    border: OutlineInputBorder(),
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
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final newBaby = await DatabaseService.instance.createBaby(
                    Baby(
                      name: nameController.text,
                      birthDate: birthDate,
                      gender: gender,
                      birthWeight: double.tryParse(weightController.text),
                      birthHeight: double.tryParse(heightController.text),
                      birthHeadCircumference: double.tryParse(headController.text),
                    ),
                  );
                  if (newBaby != null) {
                    Navigator.pop(context);
                    setState(() => _baby = newBaby);
                    final babyId = newBaby.id;
                    if (babyId != null) {
                      await _loadBabyData(babyId);
                    }
                  }
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _baby?.avatarPath != null
                      ? Image.file(
                          File(_baby!.avatarPath!),
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                _baby?.name.isNotEmpty == true ? _baby!.name[0] : '👶',
                                style: const TextStyle(fontSize: 22),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            _baby?.name.isNotEmpty == true ? _baby!.name[0] : '👶',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _baby!.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_baby!.ageDisplay} · ${_baby!.gender}宝',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatItem('体重', '${_latestGrowth?.weight?.toStringAsFixed(1) ?? "--"}', 'kg'),
              const SizedBox(width: 6),
              _buildStatItem('身高', '${_latestGrowth?.height?.toStringAsFixed(0) ?? "--"}', 'cm'),
              const SizedBox(width: 6),
              _buildStatItem('头围', '${_latestGrowth?.headCircumference?.toStringAsFixed(0) ?? "--"}', 'cm'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$label $unit',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _ActionItem('喂奶', '🍼', Colors.orange.shade50, () => _showFeedDialog()),
      _ActionItem('睡眠', '😴', Colors.green.shade50, () => _showSleepDialog()),
      _ActionItem('换尿布', '💩', Colors.yellow.shade50, () => _showDiaperDialog()),
      _ActionItem('量身高', '📏', Colors.blue.shade50, () => _showGrowthDialog()),
    ];

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actions.map((action) => _buildActionButton(action)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(_ActionItem action) {
    return AnimatedButton(
      onTap: action.onTap,
      backgroundColor: action.bgColor,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Text(action.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            action.label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthChart() {
    // 计算宝宝月龄
    int? ageInMonths;
    String? weightPercentile;
    String? heightPercentile;
    
    if (_baby != null && _latestGrowth != null) {
      ageInMonths = _baby!.ageInMonths;
      if (ageInMonths != null && _latestGrowth!.weight != null) {
        final weightData = WHOGrowthData.getWeightForAge(
          _baby!.gender == '男' ? 'boy' : 'girl',
          ageInMonths,
        );
        if (weightData != null) {
          weightPercentile = GrowthAssessmentUtil.getPercentileLevel(
            _latestGrowth!.weight!,
            weightData,
          );
        }
      }
      if (ageInMonths != null && _latestGrowth!.height != null) {
        final heightData = WHOGrowthData.getHeightForAge(
          _baby!.gender == '男' ? 'boy' : 'girl',
          ageInMonths,
        );
        if (heightData != null) {
          heightPercentile = GrowthAssessmentUtil.getPercentileLevel(
            _latestGrowth!.height!,
            heightData,
          );
        }
      }
    }

    return AnimatedCard(
      onTap: () {
        if (_baby != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GrowthChartDetailScreen(baby: _baby!)),
          );
        }
      },
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📈 生长曲线', style: AppTextStyles.title),
              Text('查看详情 →', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          if (_latestGrowth == null)
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Center(
                child: Text('暂无生长数据', style: AppTextStyles.caption),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '体重 ${_latestGrowth!.weight?.toStringAsFixed(1) ?? "--"} kg',
                          style: AppTextStyles.body,
                        ),
                        if (weightPercentile != null)
                          Text(
                            weightPercentile,
                            style: AppTextStyles.caption.copyWith(
                              color: GrowthAssessmentUtil.getStatusColor(weightPercentile),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppColors.divider),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '身高 ${_latestGrowth!.height?.toStringAsFixed(0) ?? "--"} cm',
                          style: AppTextStyles.body,
                        ),
                        if (heightPercentile != null)
                          Text(
                            heightPercentile,
                            style: AppTextStyles.caption.copyWith(
                              color: GrowthAssessmentUtil.getStatusColor(heightPercentile),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentRecords() {
    // 合并所有记录并按时间排序
    final allRecords = _getAllRecentRecords();

    return AnimatedCard(
      onTap: () => setState(() => _currentIndex = 2),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📝 今日记录', style: AppTextStyles.title),
              Text('全部记录 →', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          if (allRecords.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('暂无记录', style: AppTextStyles.caption),
              ),
            )
          else
            ...allRecords.take(5).toList().asMap().entries.map(
              (entry) => ListItemAnimation(
                index: entry.key,
                child: _buildRecordItem(entry.value),
              ),
            ),
        ],
      ),
    );
  }

  /// 获取所有类型的记录并按时间排序
  List<RecordItem> _getAllRecentRecords() {
    final List<RecordItem> records = [];
    
    // 添加喂奶记录
    for (final feed in _recentFeeds) {
      records.add(RecordItem(
        type: RecordType.feed,
        title: '${feed.typeDisplay} · ${feed.amountDisplay}',
        time: feed.time,
        icon: '🍼',
        iconBgColor: Colors.orange.shade50,
      ));
    }
    
    // 添加睡眠记录
    for (final sleep in _recentSleeps) {
      final duration = sleep.endTime != null 
          ? sleep.endTime!.difference(sleep.startTime).inMinutes 
          : null;
      records.add(RecordItem(
        type: RecordType.sleep,
        title: duration != null 
            ? '睡眠 · ${duration ~/ 60}小时${duration % 60}分钟'
            : '开始睡觉',
        time: sleep.startTime,
        icon: '😴',
        iconBgColor: Colors.green.shade50,
      ));
    }
    
    // 添加换尿布记录
    for (final diaper in _recentDiapers) {
      records.add(RecordItem(
        type: RecordType.diaper,
        title: '换尿布 · ${diaper.type}',
        time: diaper.time,
        icon: '💩',
        iconBgColor: Colors.yellow.shade50,
      ));
    }
    
    // 按时间倒序排序
    records.sort((a, b) => b.time.compareTo(a.time));
    
    return records;
  }

  Widget _buildRecordItem(RecordItem record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: record.iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(record.icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text('${_formatTime(record.time)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestones() {
    // 计算各分类完成进度
    final stats = MilestoneStats.calculate(_milestoneRecords);
    final completedCount = stats.completedCount;
    final totalCount = DefaultMilestones.totalCount;
    final progressPercent = totalCount > 0 ? (completedCount / totalCount * 100).toInt() : 0;

    return AnimatedCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MilestonesScreen()),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🎯 发育里程碑', style: AppTextStyles.title),
              Text('$completedCount/$totalCount →', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          // 总体进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            child: LinearProgressIndicator(
              value: totalCount > 0 ? completedCount / totalCount : 0,
              backgroundColor: AppColors.cardBackground,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text('$progressPercent% 已完成', style: AppTextStyles.caption),
          const SizedBox(height: 12),
          // 各分类进度
          Row(
            children: [
              _buildCategoryProgress('大运动', stats.completedByCategory[MilestoneCategory.grossMotor] ?? 0, MilestoneData.countByCategory[MilestoneCategory.grossMotor] ?? 0),
              _buildCategoryProgress('精细动作', stats.completedByCategory[MilestoneCategory.fineMotor] ?? 0, MilestoneData.countByCategory[MilestoneCategory.fineMotor] ?? 0),
              _buildCategoryProgress('语言', stats.completedByCategory[MilestoneCategory.language] ?? 0, MilestoneData.countByCategory[MilestoneCategory.language] ?? 0),
              _buildCategoryProgress('社交', stats.completedByCategory[MilestoneCategory.socialEmotion] ?? 0, MilestoneData.countByCategory[MilestoneCategory.socialEmotion] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryProgress(String label, int completed, int total) {
    final percent = total > 0 ? (completed / total * 100).toInt() : 0;
    return Expanded(
      child: Column(
        children: [
          Text('$completed/$total', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }

  // ========== 实现所有对话框功能 ==========

  void _showFeedDialog() {
    final amountController = TextEditingController();
    String feedType = '母乳';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('🍼 记录喂奶'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '母乳', label: Text('母乳')),
                  ButtonSegment(value: '奶粉', label: Text('奶粉')),
                  ButtonSegment(value: '辅食', label: Text('辅食')),
                ],
                selected: {feedType},
                onSelectionChanged: (set) {
                  setDialogState(() => feedType = set.first);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '量（ml或g）',
                  border: OutlineInputBorder(),
                ),
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
                if (amountController.text.isNotEmpty && _baby != null) {
                  final babyId = _baby!.id;
                  if (babyId == null) return;
                  final record = FeedRecord(
                    babyId: babyId,
                    type: feedType,
                    amount: double.tryParse(amountController.text) ?? 0,
                    time: DateTime.now(),
                  );
                  await DatabaseService.instance.createFeedRecord(record);
                  await _loadBabyData(babyId);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('😴 记录睡眠'),
        content: const Text('宝宝开始睡觉了'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              if (_baby != null) {
                final babyId = _baby!.id;
                if (babyId == null) return;
                final record = SleepRecord(
                  babyId: babyId,
                  startTime: DateTime.now(),
                );
                await DatabaseService.instance.createSleepRecord(record);
                await _loadBabyData(babyId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('睡眠记录已保存')),
                  );
                }
              }
            },
            child: const Text('开始睡眠'),
          ),
        ],
      ),
    );
  }

  void _showDiaperDialog() {
    String diaperType = '湿尿';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('💩 记录换尿布'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '湿尿', label: Text('湿尿')),
                  ButtonSegment(value: '大便', label: Text('大便')),
                  ButtonSegment(value: '两者', label: Text('两者')),
                ],
                selected: {diaperType},
                onSelectionChanged: (set) {
                  setDialogState(() => diaperType = set.first);
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
                if (_baby != null) {
                  final babyId = _baby!.id;
                  if (babyId == null) return;
                  final record = DiaperRecord(
                    babyId: babyId,
                    time: DateTime.now(),
                    type: diaperType,
                  );
                  await DatabaseService.instance.createDiaperRecord(record);
                  await _loadBabyData(babyId);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$diaperType 尿布记录已保存')),
                    );
                  }
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGrowthDialog() {
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final headController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📏 记录生长数据'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '体重 (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '身高 (cm)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: headController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '头围 (cm)',
                  border: OutlineInputBorder(),
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
            onPressed: () async {
              if (_baby != null && 
                  (weightController.text.isNotEmpty || 
                   heightController.text.isNotEmpty || 
                   headController.text.isNotEmpty)) {
                final babyId = _baby!.id;
                if (babyId == null) return;
                final record = GrowthRecord(
                  babyId: babyId,
                  date: DateTime.now(),
                  weight: double.tryParse(weightController.text),
                  height: double.tryParse(heightController.text),
                  headCircumference: double.tryParse(headController.text),
                );
                await DatabaseService.instance.createGrowthRecord(record);
                await _loadBabyData(babyId);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final String label;
  final String icon;
  final Color bgColor;
  final VoidCallback onTap;

  _ActionItem(this.label, this.icon, this.bgColor, this.onTap);
}

/// 记录类型枚举
enum RecordType {
  feed,
  sleep,
  diaper,
  growth,
}

/// 统一的记录项类
class RecordItem {
  final RecordType type;
  final String title;
  final DateTime time;
  final String icon;
  final Color iconBgColor;

  RecordItem({
    required this.type,
    required this.title,
    required this.time,
    required this.icon,
    required this.iconBgColor,
  });
}
