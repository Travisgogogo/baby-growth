import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_theme.dart';
import '../constants/who_growth_data.dart';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../services/database_service.dart';
import '../widgets/animations.dart';

/// 生长曲线详情页面
class GrowthChartDetailScreen extends StatefulWidget {
  final Baby baby;

  const GrowthChartDetailScreen({
    super.key,
    required this.baby,
  });

  @override
  State<GrowthChartDetailScreen> createState() => _GrowthChartDetailScreenState();
}

class _GrowthChartDetailScreenState extends State<GrowthChartDetailScreen> {
  List<GrowthRecord> _records = [];
  bool _isLoading = true;
  
  // 当前选中的指标
  GrowthMetric _selectedMetric = GrowthMetric.weight;
  
  // 时间范围
  TimeRange _timeRange = TimeRange.months36;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final babyId = widget.baby.id;
    if (babyId != null) {
      final records = await DatabaseService.instance.getGrowthRecords(babyId);
      setState(() {
        _records = records;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  /// 获取WHO参考曲线数据
  List<WHOGrowthDataPoint> get _whoCurveData {
    switch (_selectedMetric) {
      case GrowthMetric.weight:
        return WHOGrowthData.getWeightCurveData(widget.baby.gender);
      case GrowthMetric.height:
        return WHOGrowthData.getHeightCurveData(widget.baby.gender);
      case GrowthMetric.headCircumference:
        return WHOGrowthData.getHeadCircumferenceCurveData(widget.baby.gender);
    }
  }

  /// 获取实际记录数据点
  List<FlSpot> get _actualDataPoints {
    final filteredRecords = _getFilteredRecords();
    if (filteredRecords.isEmpty) return [];

    return filteredRecords.map((record) {
      final ageInMonths = _calculateAgeInMonths(record.date);
      double? value;
      
      switch (_selectedMetric) {
        case GrowthMetric.weight:
          value = record.weight;
          break;
        case GrowthMetric.height:
          value = record.height;
          break;
        case GrowthMetric.headCircumference:
          value = record.headCircumference;
          break;
      }
      
      return FlSpot(ageInMonths.toDouble(), value ?? 0);
    }).where((spot) => spot.y > 0).toList();
  }

  /// 获取过滤后的记录
  List<GrowthRecord> _getFilteredRecords() {
    final maxAge = _timeRange.maxMonths;
    return _records.where((record) {
      final ageInMonths = _calculateAgeInMonths(record.date);
      return ageInMonths >= 0 && ageInMonths <= maxAge;
    }).toList();
  }

  /// 计算月龄
  int _calculateAgeInMonths(DateTime date) {
    final diff = date.difference(widget.baby.birthDate);
    return (diff.inDays / 30).floor();
  }

  /// 获取WHO曲线点
  List<FlSpot> _getWHOSpots(int percentileIndex) {
    final maxAge = _timeRange.maxMonths;
    final data = _whoCurveData.where((d) => d.ageInMonths <= maxAge).toList();
    
    return data.map((d) {
      double value;
      switch (percentileIndex) {
        case 0:
          value = d.p3;
          break;
        case 1:
          value = d.p15;
          break;
        case 2:
          value = d.p50;
          break;
        case 3:
          value = d.p85;
          break;
        case 4:
          value = d.p97;
          break;
        default:
          value = d.p50;
      }
      return FlSpot(d.ageInMonths.toDouble(), value);
    }).toList();
  }

  /// 获取指标单位
  String get _unit {
    switch (_selectedMetric) {
      case GrowthMetric.weight:
        return 'kg';
      case GrowthMetric.height:
      case GrowthMetric.headCircumference:
        return 'cm';
    }
  }

  /// 获取指标标题
  String get _metricTitle {
    switch (_selectedMetric) {
      case GrowthMetric.weight:
        return '体重-for-年龄';
      case GrowthMetric.height:
        return '身高-for-年龄';
      case GrowthMetric.headCircumference:
        return '头围-for-年龄';
    }
  }

  /// 获取最新评估
  GrowthAssessment? get _latestAssessment {
    if (_records.isEmpty) return null;
    
    final latest = _records.first;
    final ageInMonths = _calculateAgeInMonths(latest.date);
    
    switch (_selectedMetric) {
      case GrowthMetric.weight:
        if (latest.weight == null) return null;
        return GrowthAssessmentUtil.assessWeight(
          widget.baby.gender,
          ageInMonths,
          latest.weight!,
        );
      case GrowthMetric.height:
        if (latest.height == null) return null;
        return GrowthAssessmentUtil.assessHeight(
          widget.baby.gender,
          ageInMonths,
          latest.height!,
        );
      case GrowthMetric.headCircumference:
        if (latest.headCircumference == null) return null;
        return GrowthAssessmentUtil.assessHeadCircumference(
          widget.baby.gender,
          ageInMonths,
          latest.headCircumference!,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('生长曲线'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // 指标选择器
                    _buildMetricSelector(),
                    
                    // 时间范围选择器
                    _buildTimeRangeSelector(),
                    
                    // 图表区域
                    _buildChartCard(),
                    
                    // 最新评估卡片
                    _buildAssessmentCard(),
                    
                    // 图例说明
                    _buildLegend(),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  /// 构建指标选择器
  Widget _buildMetricSelector() {
    return FadeInAnimation(
      child: AnimatedCard(
        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('选择指标', style: AppTextStyles.subtitle),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricButton(
                    GrowthMetric.weight,
                    '体重',
                    Icons.monitor_weight_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricButton(
                    GrowthMetric.height,
                    '身高',
                    Icons.height,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricButton(
                    GrowthMetric.headCircumference,
                    '头围',
                    Icons.circle_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建指标按钮
  Widget _buildMetricButton(GrowthMetric metric, String label, IconData icon) {
    final isSelected = _selectedMetric == metric;
    return GestureDetector(
      onTap: () => setState(() => _selectedMetric = metric),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建时间范围选择器
  Widget _buildTimeRangeSelector() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
        child: SegmentedButton<TimeRange>(
          style: SegmentedButton.styleFrom(
            backgroundColor: AppColors.cardBackground,
            selectedBackgroundColor: AppColors.primary,
            selectedForegroundColor: Colors.white,
            foregroundColor: AppColors.textSecondary,
          ),
          segments: const [
            ButtonSegment(
              value: TimeRange.months6,
              label: Text('6个月'),
            ),
            ButtonSegment(
              value: TimeRange.months12,
              label: Text('1年'),
            ),
            ButtonSegment(
              value: TimeRange.months24,
              label: Text('2年'),
            ),
            ButtonSegment(
              value: TimeRange.months36,
              label: Text('3年'),
            ),
          ],
          selected: {_timeRange},
          onSelectionChanged: (set) {
            if (set.isNotEmpty) {
              setState(() => _timeRange = set.first);
            }
          },
        ),
      ),
    );
  }

  /// 构建图表卡片
  Widget _buildChartCard() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 200),
      child: AnimatedCard(
        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_metricTitle, style: AppTextStyles.title),
                Text(
                  '($_unit)',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            SizedBox(
              height: 300,
              child: _actualDataPoints.isEmpty
                  ? _buildEmptyChart()
                  : _buildLineChart(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空图表提示
  Widget _buildEmptyChart() {
    return Center(
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
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建折线图
  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: _getHorizontalInterval(),
          verticalInterval: _timeRange == TimeRange.months6 ? 1 : 3,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.divider.withOpacity(0.5),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppColors.divider.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: _getHorizontalInterval(),
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _timeRange == TimeRange.months6 ? 1 : 6,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${value.toInt()}月',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: _timeRange.maxMonths.toDouble(),
        minY: _getMinY(),
        maxY: _getMaxY(),
        lineBarsData: [
          // P3 曲线
          _buildWHOLineBarData(0, Colors.red.withOpacity(0.5), false),
          // P15 曲线
          _buildWHOLineBarData(1, Colors.orange.withOpacity(0.5), false),
          // P50 曲线 (中位数)
          _buildWHOLineBarData(2, Colors.green, true),
          // P85 曲线
          _buildWHOLineBarData(3, Colors.orange.withOpacity(0.5), false),
          // P97 曲线
          _buildWHOLineBarData(4, Colors.red.withOpacity(0.5), false),
          // 实际数据点
          _buildActualDataLineBar(),
        ],
      ),
    );
  }

  /// 构建WHO曲线数据
  LineChartBarData _buildWHOLineBarData(
    int percentileIndex,
    Color color,
    bool isBold,
  ) {
    return LineChartBarData(
      spots: _getWHOSpots(percentileIndex),
      isCurved: true,
      color: color,
      barWidth: isBold ? 3 : 1.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  /// 构建实际数据曲线
  LineChartBarData _buildActualDataLineBar() {
    return LineChartBarData(
      spots: _actualDataPoints,
      isCurved: false,
      color: AppColors.primary,
      barWidth: 0,
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
    );
  }

  /// 获取Y轴最小值
  double _getMinY() {
    final spots = _getWHOSpots(0);
    if (spots.isEmpty) return 0;
    return spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) * 0.95;
  }

  /// 获取Y轴最大值
  double _getMaxY() {
    final spots = _getWHOSpots(4);
    if (spots.isEmpty) return 100;
    
    double maxWho = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    
    // 考虑实际数据点
    if (_actualDataPoints.isNotEmpty) {
      final maxActual = _actualDataPoints.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      maxWho = maxWho > maxActual ? maxWho : maxActual;
    }
    
    return maxWho * 1.05;
  }

  /// 获取Y轴间隔
  double _getHorizontalInterval() {
    final range = _getMaxY() - _getMinY();
    if (range <= 10) return 1;
    if (range <= 50) return 5;
    return 10;
  }

  /// 构建评估卡片
  Widget _buildAssessmentCard() {
    final assessment = _latestAssessment;
    if (assessment == null) return const SizedBox.shrink();

    return FadeInAnimation(
      delay: const Duration(milliseconds: 300),
      child: AnimatedCard(
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assessment,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('生长评估', style: AppTextStyles.subtitle),
              ],
            ),
            const SizedBox(height: 16),
            _buildAssessmentRow('百分位', 'P${assessment.percentile.toInt()}'),
            const SizedBox(height: 8),
            _buildAssessmentRow('状态', assessment.status),
            const SizedBox(height: 8),
            Text(
              assessment.description,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建评估行
  Widget _buildAssessmentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(value).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: _getStatusColor(value),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(String status) {
    switch (status) {
      case '正常':
        return Colors.green;
      case '偏低':
      case '偏高':
        return Colors.orange;
      case '无法评估':
        return AppColors.textTertiary;
      default:
        return AppColors.primary;
    }
  }

  /// 构建图例
  Widget _buildLegend() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 400),
      child: AnimatedCard(
        margin: const EdgeInsets.all(AppDimensions.paddingMedium),
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('参考曲线说明', style: AppTextStyles.subtitle),
            const SizedBox(height: 12),
            _buildLegendItem(Colors.red.withOpacity(0.5), 'P3 (第3百分位) - 偏低'),
            _buildLegendItem(Colors.orange.withOpacity(0.5), 'P15 (第15百分位)'),
            _buildLegendItem(Colors.green, 'P50 (第50百分位) - 中位数'),
            _buildLegendItem(Colors.orange.withOpacity(0.5), 'P85 (第85百分位)'),
            _buildLegendItem(Colors.red.withOpacity(0.5), 'P97 (第97百分位) - 偏高'),
            const Divider(height: 24),
            _buildLegendItem(AppColors.primary, '● 宝宝实际数据'),
          ],
        ),
      ),
    );
  }

  /// 构建图例项
  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 生长指标枚举
enum GrowthMetric {
  weight,
  height,
  headCircumference,
}

/// 时间范围枚举
enum TimeRange {
  months6,
  months12,
  months24,
  months36,
}

extension TimeRangeExtension on TimeRange {
  int get maxMonths {
    switch (this) {
      case TimeRange.months6:
        return 6;
      case TimeRange.months12:
        return 12;
      case TimeRange.months24:
        return 24;
      case TimeRange.months36:
        return 36;
    }
  }
}
