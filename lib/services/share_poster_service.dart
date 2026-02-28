import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../models/milestone.dart';
import '../constants/app_theme.dart';

/// 成长海报生成服务
class SharePosterService {
  /// 生成成长海报
  static Future<File?> generateGrowthPoster({
    required Baby baby,
    GrowthRecord? latestGrowth,
    List<MilestoneRecord> milestones = const [],
    String? template,
  }) async {
    try {
      // 创建海报 widget
      final posterWidget = GrowthPosterWidget(
        baby: baby,
        latestGrowth: latestGrowth,
        milestones: milestones,
        template: template ?? 'default',
      );

      // 渲染为图片
      final image = await _widgetToImage(
        posterWidget,
        size: const Size(1080, 1920),
      );
      if (image == null) return null;

      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/growth_poster_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(image);

      return file;
    } catch (e) {
      print('生成海报失败: $e');
      return null;
    }
  }

  /// 生成时间轴回顾海报
  static Future<File?> generateTimelinePoster({
    required Baby baby,
    required List<TimelineItem> items,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final posterWidget = TimelinePosterWidget(
        baby: baby,
        items: items,
        startDate: startDate,
        endDate: endDate,
      );

      final image = await _widgetToImage(
        posterWidget,
        size: const Size(1080, 1920),
      );
      if (image == null) return null;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/timeline_poster_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(image);

      return file;
    } catch (e) {
      print('生成时间轴海报失败: $e');
      return null;
    }
  }

  /// 将 Widget 转换为图片
  static Future<Uint8List?> _widgetToImage(Widget widget, {required Size size}) async {
    final repaintBoundary = RenderRepaintBoundary();
    
    final renderView = RenderView(
      view: ui.PlatformDispatcher.instance.views.first,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
    );

    final pipelineOwner = PipelineOwner();
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final buildOwner = BuildOwner(focusManager: FocusManager());
    
    // 使用 SizedBox 给 widget 设置大小
    final sizedWidget = SizedBox(
      width: size.width,
      height: size.height,
      child: widget,
    );
    
    final element = RenderObjectToWidgetAdapter(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: sizedWidget,
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(element);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData?.buffer.asUint8List();
  }
}

/// 成长海报 Widget
class GrowthPosterWidget extends StatelessWidget {
  final Baby baby;
  final GrowthRecord? latestGrowth;
  final List<MilestoneRecord> milestones;
  final String template;

  const GrowthPosterWidget({
    super.key,
    required this.baby,
    this.latestGrowth,
    required this.milestones,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1920,
      decoration: _buildBackground(),
      child: Column(
        children: [
          _buildHeader(),
          _buildBabyInfo(),
          if (latestGrowth != null) _buildGrowthData(),
          _buildMilestones(),
          const Spacer(),
          _buildFooter(),
        ],
      ),
    );
  }

  BoxDecoration _buildBackground() {
    switch (template) {
      case 'warm':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFE4D6),
              Color(0xFFFFD4E5),
            ],
          ),
        );
      case 'fresh':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFFB2EBF2),
            ],
          ),
        );
      default:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        );
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Center(
              child: Text(
                baby.name.isNotEmpty ? baby.name[0] : '👶',
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
          const SizedBox(width: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${baby.name}的成长记录',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${baby.ageDisplay} · ${baby.gender}宝',
                style: const TextStyle(
                  fontSize: 40,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBabyInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('出生日期', '${baby.birthDate.year}.${baby.birthDate.month}.${baby.birthDate.day}'),
          _buildInfoItem('星座', _getZodiacSign(baby.birthDate)),
          _buildInfoItem('生肖', _getChineseZodiac(baby.birthDate.year)),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 32,
            color: Color(0xFF999999),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          value,
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthData() {
    return Container(
      margin: const EdgeInsets.all(60),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最新生长数据',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGrowthItem('体重', '${latestGrowth!.weight?.toStringAsFixed(1) ?? "--"}', 'kg', Icons.fitness_center),
              _buildGrowthItem('身高', '${latestGrowth!.height?.toStringAsFixed(0) ?? "--"}', 'cm', Icons.height),
              _buildGrowthItem('头围', '${latestGrowth!.headCircumference?.toStringAsFixed(0) ?? "--"}', 'cm', Icons.face),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthItem(String label, String value, String unit, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 64, color: AppColors.primary),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 36,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          label,
          style: const TextStyle(
            fontSize: 36,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestones() {
    if (milestones.isEmpty) return const SizedBox.shrink();

    final recentMilestones = milestones.take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最近完成的里程碑',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 32),
          ...recentMilestones.map((m) => _buildMilestoneItem(m)),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(MilestoneRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(36),
            ),
            child: const Icon(Icons.check, color: AppColors.success, size: 40),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '完成了新里程碑',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${record.completedDate.month}月${record.completedDate.day}日',
                  style: const TextStyle(
                    fontSize: 32,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Column(
        children: [
          const Text(
            '记录成长的每一个瞬间',
            style: TextStyle(
              fontSize: 40,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 36),
              const SizedBox(width: 16),
              Text(
                '宝宝成长记',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getZodiacSign(DateTime date) {
    final month = date.month;
    final day = date.day;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '白羊座';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '金牛座';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) return '双子座';
    if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) return '巨蟹座';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '狮子座';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '处女座';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 23)) return '天秤座';
    if ((month == 10 && day >= 24) || (month == 11 && day <= 22)) return '天蝎座';
    if ((month == 11 && day >= 23) || (month == 12 && day <= 21)) return '射手座';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return '摩羯座';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '水瓶座';
    return '双鱼座';
  }

  String _getChineseZodiac(int year) {
    final animals = ['猴', '鸡', '狗', '猪', '鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊'];
    return animals[year % 12];
  }
}

/// 时间轴海报 Widget
class TimelinePosterWidget extends StatelessWidget {
  final Baby baby;
  final List<TimelineItem> items;
  final DateTime? startDate;
  final DateTime? endDate;

  const TimelinePosterWidget({
    super.key,
    required this.baby,
    required this.items,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1080,
      height: 1920,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFAFAFA), Colors.white],
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildTimeline(),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        children: [
          Text(
            '${baby.name}的成长时光',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${_formatDate(startDate)} - ${_formatDate(endDate)}',
            style: TextStyle(
              fontSize: 36,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isLeft = index % 2 == 0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLeft) Expanded(child: _buildTimelineItem(item, true)),
            _buildTimelineLine(index),
            if (!isLeft) Expanded(child: _buildTimelineItem(item, false)),
          ],
        );
      },
    );
  }

  Widget _buildTimelineLine(int index) {
    return Container(
      width: 4,
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.3),
            AppColors.primary,
            AppColors.primary.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(TimelineItem item, bool isLeft) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 40,
        left: isLeft ? 0 : 20,
        right: isLeft ? 20 : 0,
      ),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            '${item.date.month}月${item.date.day}日',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          if (item.description != null) ...[
            const SizedBox(height: 12),
            Text(
              item.description!,
              style: const TextStyle(
                fontSize: 32,
                color: Color(0xFF666666),
              ),
            ),
          ],
          if (item.imagePath != null) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(item.imagePath!),
                width: 300,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '共 ${items.length} 个美好瞬间',
            style: const TextStyle(
              fontSize: 36,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '今天';
    return '${date.year}.${date.month}.${date.day}';
  }
}

/// 时间轴项目
class TimelineItem {
  final DateTime date;
  final String title;
  final String? description;
  final String? imagePath;
  final TimelineItemType type;

  TimelineItem({
    required this.date,
    required this.title,
    this.description,
    this.imagePath,
    this.type = TimelineItemType.other,
  });
}

enum TimelineItemType {
  growth,
  milestone,
  photo,
  record,
  other,
}
