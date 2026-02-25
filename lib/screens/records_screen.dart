import 'package:flutter/material.dart';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../models/feed_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../services/database_service.dart';

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
      final babyId = babies.first.id!;
      setState(() => _baby = babies.first);
      
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('全部记录'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
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
      return const Center(child: Text('暂无喂养记录', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: _feedRecords.length,
      itemBuilder: (context, index) {
        final record = _feedRecords[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.restaurant)),
          title: Text('${record.type} ${record.amount?.toInt()}ml'),
          subtitle: Text('${_formatTime(record.time)}'),
        );
      },
    );
  }

  Widget _buildGrowthTab() {
    if (_growthRecords.isEmpty) {
      return const Center(child: Text('暂无生长记录', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: _growthRecords.length,
      itemBuilder: (context, index) {
        final record = _growthRecords[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.trending_up)),
          title: Text('${record.weight?.toStringAsFixed(1)}kg, ${record.height?.toStringAsFixed(0)}cm'),
          subtitle: Text('${_formatDate(record.date)}'),
        );
      },
    );
  }

  Widget _buildSleepTab() {
    if (_sleepRecords.isEmpty) {
      return const Center(child: Text('暂无睡眠记录', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: _sleepRecords.length,
      itemBuilder: (context, index) {
        final record = _sleepRecords[index];
        final duration = record.endTime != null 
            ? record.endTime!.difference(record.startTime).inMinutes 
            : null;
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.bedtime)),
          title: Text(duration != null ? '睡眠 ${duration ~/ 60}小时${duration % 60}分钟' : '睡眠中'),
          subtitle: Text('${_formatTime(record.startTime)}'),
        );
      },
    );
  }

  Widget _buildDiaperTab() {
    if (_diaperRecords.isEmpty) {
      return const Center(child: Text('暂无换尿布记录', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: _diaperRecords.length,
      itemBuilder: (context, index) {
        final record = _diaperRecords[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.baby_changing_station)),
          title: Text(record.type),
          subtitle: Text('${_formatTime(record.time)}'),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }
}
