import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../constants/who_growth_data.dart';
import '../widgets/animations.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../services/database_service.dart';
import 'growth_chart_detail_screen.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('生长曲线'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_baby != null)
            IconButton(
              icon: const Icon(Icons.fullscreen),
              tooltip: '查看详细曲线',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GrowthChartDetailScreen(baby: _baby!),
                  ),
                ).then((_) => _loadData());
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                children: [
                  // 指标选择
                  FadeInAnimation(
                    child: AnimatedCard(
                      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
                      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildMetricButton('weight', '体重', '${_getLatestWeight()} kg')),
                              const SizedBox(width: 8),
                              Expanded(child: _buildMetricButton('height', '身高', '${_getLatestHeight()} cm')),
                              const SizedBox(width: 8),
                              Expanded(child: _buildMetricButton('head', '头围', '${_getLatestHead()} cm')),
                            ],
                          ),
                          if (_baby != null && _records.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _buildQuickAssessment(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  // 时间范围选择
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
                      child: SegmentedButton<String>(
                        style: SegmentedButton.styleFrom(
                          backgroundColor: AppColors.cardBackground,
                          selectedBackgroundColor: AppColors.primary,
                          selectedForegroundColor: Colors.white,
                          foregroundColor: AppColors.textSecondary,
                        ),
                        segments: const [
                          ButtonSegment(value: '3m', label: Text('3个月')),
                          ButtonSegment(value: '6m', label: Text('6个月')),
                          ButtonSegment(value: '1y', label: Text('1年')),
                        ],
                        selected: {_timeRange},
                        onSelectionChanged: (set) => setState(() => _timeRange = set.first),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppDimensions.paddingMedium),
                  
                  // 图表
                  Expanded(
                    child: FadeInAnimation(
                      delay: const Duration(milliseconds: 200),
                      child: AnimatedCard(
                        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
                        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                        child: chartData.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.show_chart,
                                      size: 64,
                                      color: AppColors.textTertiary.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '暂无数据，请先记录生长数据',
                                      style: AppTextStyles.subtitle.copyWith(color: AppColors.textTertiary),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_getMetricTitle(), style: AppTextStyles.title),
                                  const SizedBox(height: AppDimensions.paddingMedium),
                                  Expanded(
                                    child: LineChart(
                                      LineChartData(
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: false,
                                          horizontalInterval: 1,
                                          getDrawingHorizontalLine: (value) {
                                            return FlLine(
                                              color: AppColors.divider,
                                              strokeWidth: 1,
                                            );
                                          },
                                        ),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  value.toStringAsFixed(1),
                                                  style: AppTextStyles.caption,
                                                );
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: chartData,
                                            isCurved: true,
                                            color: AppColors.primary,
                                            barWidth: 4,
                                            dotData: FlDotData(
                                              show: true,
                                              getDotPainter: (spot, percent, bar, index) {
                                                return FlDotCirclePainter(
                                                  radius: 6,
                                                  color: AppColors.primary,
                                                  strokeWidth: 2,
                                                  strokeColor: Colors.white,
                                                );
                                              },
                                            ),
                                            belowBarData: BarAreaData(
                                              show: true,
                                              color: AppColors.primary.withOpacity(0.15),
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
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.subtitle.copyWith(color: isSelected ? Colors.white : AppColors.primary)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption.copyWith(color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 构建快速评估
  Widget _buildQuickAssessment() {
    final latestRecord = _records.first;
    final ageInMonths = _calculateAgeInMonths(latestRecord.date);
    
    GrowthAssessment? assessment;
    String metricName = '';
    double? value;
    
    switch (_selectedMetric) {
      case 'weight':
        if (latestRecord.weight != null) {
          value = latestRecord.weight;
          assessment = GrowthAssessmentUtil.assessWeight(
            _baby!.gender,
            ageInMonths,
            latestRecord.weight!,
          );
          metricName = '体重';
        }
        break;
      case 'height':
        if (latestRecord.height != null) {
          value = latestRecord.height;
          assessment = GrowthAssessmentUtil.assessHeight(
            _baby!.gender,
            ageInMonths,
            latestRecord.height!,
          );
          metricName = '身高';
        }
        break;
      case 'head':
        if (latestRecord.headCircumference != null) {
          value = latestRecord.headCircumference;
          assessment = GrowthAssessmentUtil.assessHeadCircumference(
            _baby!.gender,
            ageInMonths,
            latestRecord.headCircumference!,
          );
          metricName = '头围';
        }
        break;
    }
    
    if (assessment == null || value == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GrowthChartDetailScreen(baby: _baby!),
          ),
        ).then((_) => _loadData());
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getAssessmentColor(assessment.status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(
            color: _getAssessmentColor(assessment.status).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: _getAssessmentColor(assessment.status),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$metricName: ${value.toStringAsFixed(1)} - ${assessment.status} (P${assessment.percentile.toInt()})',
                style: AppTextStyles.caption.copyWith(
                  color: _getAssessmentColor(assessment.status),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: _getAssessmentColor(assessment.status),
            ),
          ],
        ),
      ),
    );
  }

  /// 计算月龄
  int _calculateAgeInMonths(DateTime date) {
    final diff = date.difference(_baby!.birthDate);
    return (diff.inDays / 30).floor();
  }

  /// 获取评估颜色
  Color _getAssessmentColor(String status) {
    switch (status) {
      case '正常':
        return Colors.green;
      case '偏低':
      case '偏高':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }
}