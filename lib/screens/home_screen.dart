import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../models/feed_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../models/milestone_record.dart';
import '../services/database_service.dart';
import 'growth_chart_screen.dart';
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
  List<MilestoneRecord> _milestoneRecords = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
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
    final milestoneRecords = await DatabaseService.instance.getMilestoneRecords(babyId);

    setState(() {
      if (growthRecords.isNotEmpty) {
        _latestGrowth = growthRecords.first;
      }
      _recentFeeds = feedRecords;
      _milestoneRecords = milestoneRecords;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_baby == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
        selectedItemColor: const AppColors.primary,
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
                      firstDate: DateTime(2000),
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
                child: const Center(child: Text('👶', style: TextStyle(fontSize: 22))),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((action) => _buildActionButton(action)).toList(),
      ),
    );
  }

  Widget _buildActionButton(_ActionItem action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: action.bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(action.icon, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(height: 3),
          Text(action.label, style: const TextStyle(fontSize: 10, color: Color(0xFF666666))),
        ],
      ),
    );
  }

  Widget _buildGrowthChart() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 1),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('📈 生长曲线', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text('查看详情 →', style: TextStyle(fontSize: 11, color: Colors.blue.shade600)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 140,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('生长曲线图表')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRecords() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('📝 今日记录', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text('全部记录 →', style: TextStyle(fontSize: 11, color: Colors.blue.shade600)),
              ],
            ),
            const SizedBox(height: 10),
            if (_recentFeeds.isEmpty)
              const Center(child: Text('暂无记录', style: TextStyle(color: Colors.grey)))
            else
              ..._recentFeeds.take(3).map((feed) => _buildRecordItem(feed)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(FeedRecord feed) {
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
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Text('🍼', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${feed.typeDisplay} · ${feed.amountDisplay}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text('${_formatTime(feed.time)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestones() {
    final completedCount = _milestoneRecords.where((m) => m.completedDate != null).length;
    final totalCount = 23; // 总里程碑数
    final recentMilestones = _milestoneRecords.take(5).toList();

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 3),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🎯 发育里程碑', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text('$completedCount/$totalCount 已完成 →', style: TextStyle(fontSize: 11, color: Colors.blue.shade600)),
              ],
            ),
            const SizedBox(height: 10),
            if (recentMilestones.isEmpty)
              const Center(child: Text('暂无里程碑记录', style: TextStyle(color: Colors.grey, fontSize: 12)))
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: recentMilestones.map((m) => _buildMilestoneItem(m)).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneItem(MilestoneRecord milestone) {
    final isCompleted = milestone.completedDate != null;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(isCompleted ? '✅' : '⭕', style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(milestone.milestoneId, style: const TextStyle(fontSize: 10, color: Color(0xFF666666))),
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
