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
        setState(() => _baby = baby);
        final records = await DatabaseService.instance.getGrowthRecords(babyId);
        setState(() => _records = records);
      }
    }
    setState(() => _isLoading = false);
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

  List<FlSpot> _getChartData() {
    if (_records.isEmpty) return [];
    
    final now = DateTime.now();
    final monthsBack = _timeRange == '3m' ? 3 : _timeRange == '6m' ? 6 : 12;
    final cutoffDate = DateTime(now.year, now.month - monthsBack, now.day);
    
    final filteredRecords = _records.where((r) => r.date.isAfter(cutoffDate)).toList();
    if (filteredRecords.isEmpty) return [];
    
    return filteredRecords.asMap().entries.map((entry) {
      final index = entry.key;
      final record = entry.value;
      double? value;
      switch (_selectedMetric) {
        case 'weight':
          value = record.weight;
          break;
        case 'height':
          value = record.height;
          break;
        case 'head':
          value = record.headCircumference;
          break;
      }
      return FlSpot(index.toDouble(), value ?? 0);
    }).toList();
  }

  String _getMetricTitle() {
    switch (_selectedMetric) {
      case 'weight':
        return '体重 (kg)';
      case 'height':
        return '身高 (cm)';
      case 'head':
        return '头围 (cm)';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _getChartData();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('生长曲线'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 指标选择
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
                  
                  // 时间范围选择
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: '3m', label: Text('3个月')),
                        ButtonSegment(value: '6m', label: Text('6个月')),
                        ButtonSegment(value: '1y', label: Text('1年')),
                      ],
                      selected: {_timeRange},
                      onSelectionChanged: (set) => setState(() => _timeRange = set.first),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 图表
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: chartData.isEmpty
                          ? const Center(child: Text('暂无数据，请先记录生长数据'))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_getMetricTitle(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: LineChart(
                                    LineChartData(
                                      gridData: FlGridData(show: true, drawVerticalLine: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: false),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: chartData,
                                          isCurved: true,
                                          color: const Color(0xFF667eea),
                                          barWidth: 3,
                                          dotData: FlDotData(show: true),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: const Color(0xFF667eea).withOpacity(0.1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  // 数据列表
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('历史记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        ..._records.take(5).map((record) => ListTile(
                          dense: true,
                          title: Text('${_formatDate(record.date)}'),
                          subtitle: Text('体重: ${record.weight?.toStringAsFixed(1) ?? "--"}kg, 身高: ${record.height?.toStringAsFixed(0) ?? "--"}cm'),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
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

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
