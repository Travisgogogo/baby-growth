import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_theme.dart';
import '../models/sleep_record.dart';

/// 睡眠曲线图表
class SleepChart extends StatelessWidget {
  final List<SleepRecord> sleepRecords;
  final int days;

  const SleepChart({
    super.key,
    required this.sleepRecords,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    final data = _prepareChartData();
    
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '睡眠时长趋势（小时）',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: days == 7 ? 1 : 5,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          final date = data[index].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.month}/${date.day}',
                              style: AppTextStyles.caption.copyWith(fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: 16,
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.hours);
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.5)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.secondary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.secondary.withOpacity(0.3),
                          AppColors.secondary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<SleepDataPoint> _prepareChartData() {
    final now = DateTime.now();
    final data = <SleepDataPoint>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      // 计算当天总睡眠时长
      double totalHours = 0;
      for (final record in sleepRecords) {
        if (record.endTime != null) {
          // 检查睡眠记录是否与当天有重叠
          final sleepStart = record.startTime;
          final sleepEnd = record.endTime!;
          
          // 如果睡眠跨越了当天
          if (sleepStart.isBefore(dayEnd) && sleepEnd.isAfter(dayStart)) {
            final overlapStart = sleepStart.isAfter(dayStart) ? sleepStart : dayStart;
            final overlapEnd = sleepEnd.isBefore(dayEnd) ? sleepEnd : dayEnd;
            final duration = overlapEnd.difference(overlapStart).inMinutes / 60;
            totalHours += duration;
          }
        }
      }

      data.add(SleepDataPoint(
        date: date,
        hours: totalHours,
      ));
    }

    return data;
  }
}

class SleepDataPoint {
  final DateTime date;
  final double hours;

  SleepDataPoint({required this.date, required this.hours});
}
