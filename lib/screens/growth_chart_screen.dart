import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../services/database_service.dart';

class GrowthChartScreen extends StatefulWidget {
  const GrowthChartScreen({super.key});

  @override
  State<GrowthChartScreen> createState() => _GrowthChartScreenState();
}

class _GrowthChartScreenState extends State<GrowthChartScreen> {
  Baby? _baby;
  List<GrowthRecord> _records = [];
  String _selectedMetric = 'weight';
  String _timeRange = '6m';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final babies = await DatabaseService.instance.getAllBabies();
    if (babies.isNotEmpty) {
      setState(() {
        _baby = babies.first;
      });
      final records = await DatabaseService.instance.getGrowthRecords(babies.first.id!);
      setState(() {
        _records = records;
      });
    }
  }

  String _getLatestWeight() {
    if (_records.isEmpty) return '--';
    final record = _records.firstWhere((r) => r.weight != null, orElse: () => _records.first);
    return record.weight?.toStringAsFixed(1) ?? '--';
  }

  String _getLatestHeight() {
    if (_records.isEmpty) return '--';
    final record = _records.firstWhere((r) => r.height != null, orElse: () => _records.first);
    return record.height?.toStringAsFixed(0) ?? '--';
  }

  String _getLatestHead() {
    if (_records.isEmpty) return '--';
    final record = _records.firstWhere((r) => r.headCircumference != null, orElse: () => _records.first);
    return record.headCircumference?.toStringAsFixed(0) ?? '--';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('生长曲线'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Expanded(child: _buildMetricButton('weight', '体重', '${_getLatestWeight()} kg')),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricButton('height', '身高', '${_getLatestHeight()} cm')),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricButton('head', '头围', '${_getLatestHead()} cm')),
              ],
            ),
          ),
          const Expanded(child: Center(child: Text('生长曲线图表'))),
        ],
      ),
    );
  }

  Widget _buildMetricButton(String metric, String label, String value) {
    final isSelected = _selectedMetric == metric;
    return GestureDetector(
      onTap: () => setState(() => _selectedMetric = metric),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667eea) : const Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : const Color(0xFF667eea))),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey)),
          ],
        ),
      ),
    );
  }
}
