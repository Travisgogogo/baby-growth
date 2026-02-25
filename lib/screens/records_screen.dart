import 'package:flutter/material.dart';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../models/feed_record.dart';
import '../services/database_service.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Baby? _baby;
  List<GrowthRecord> _growthRecords = [];
  List<FeedRecord> _feedRecords = [];

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
    final babies = await DatabaseService.instance.getAllBabies();
    if (babies.isNotEmpty) {
      setState(() {
        _baby = babies.first;
      });
      final growthRecords = await DatabaseService.instance.getGrowthRecords(babies.first.id!);
      final feedRecords = await DatabaseService.instance.getFeedRecords(babies.first.id!);
      setState(() {
        _growthRecords = growthRecords;
        _feedRecords = feedRecords;
      });
    }
  }

  Future<void> _deleteGrowthRecord(int id) async {
    // TODO: Implement delete in database service
    setState(() {
      _growthRecords.removeWhere((r) => r.id == id);
    });
  }

  Future<void> _deleteFeedRecord(int id) async {
    // TODO: Implement delete in database service
    setState(() {
      _feedRecords.removeWhere((r) => r.id == id);
    });
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
            Tab(text: '喂养记录'),
            Tab(text: '生长记录'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedRecordsTab(),
          _buildGrowthRecordsTab(),
        ],
      ),
    );
  }

  Widget _buildFeedRecordsTab() {
    if (_feedRecords.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无喂养记录', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _feedRecords.length,
      itemBuilder: (context, index) {
        final record = _feedRecords[index];
        return _buildFeedRecordCard(record);
      },
    );
  }

  Widget _buildFeedRecordCard(FeedRecord record) {
    IconData icon;
    Color color;
    switch (record.type) {
      case '母乳':
        icon = Icons.water_drop;
        color = Colors.orange;
        break;
      case '奶粉':
        icon = Icons.local_drink;
        color = Colors.blue;
        break;
      case '辅食':
        icon = Icons.restaurant;
        color = Colors.green;
        break;
      default:
        icon = Icons.restaurant;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text('${record.type} · ${record.amount}ml'),
        subtitle: Text(_formatDateTime(record.time)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _showDeleteConfirm('喂养记录', () => _deleteFeedRecord(record.id!)),
        ),
      ),
    );
  }

  Widget _buildGrowthRecordsTab() {
    if (_growthRecords.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无生长记录', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _growthRecords.length,
      itemBuilder: (context, index) {
        final record = _growthRecords[index];
        return _buildGrowthRecordCard(record);
      },
    );
  }

  Widget _buildGrowthRecordCard(GrowthRecord record) {
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
                Text(
                  _formatDate(record.date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => _showDeleteConfirm('生长记录', () => _deleteGrowthRecord(record.id!)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (record.weight != null)
                  _buildMetricChip('体重', '${record.weight}kg', Colors.blue),
                if (record.height != null)
                  _buildMetricChip('身高', '${record.height}cm', Colors.green),
                if (record.headCircumference != null)
                  _buildMetricChip('头围', '${record.headCircumference}cm', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showDeleteConfirm(String title, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除这条$title吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
