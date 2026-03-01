import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../constants/app_theme.dart';
import '../constants/milestone_data.dart';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../models/milestone.dart';

/// 成长海报生成服务
class SharePosterService {
  /// 生成成长海报并返回文件
  /// 使用传入的 GlobalKey 捕获 Widget 图片
  static Future<File?> generateGrowthPoster({
    required GlobalKey repaintKey,
  }) async {
    try {
      // 等待渲染完成
      await Future.delayed(const Duration(milliseconds: 100));
      
      final renderObject = repaintKey.currentContext?.findRenderObject();
      if (renderObject == null) {
        print('错误: 无法找到 RenderObject');
        return null;
      }
      
      final boundary = renderObject as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        print('错误: 无法获取图片数据');
        return null;
      }
      
      final imageBytes = byteData.buffer.asUint8List();
      
      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final fileName = 'growth_poster_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);
      
      print('海报生成成功: ${file.path}');
      return file;
    } catch (e, stackTrace) {
      print('生成海报失败: $e');
      print('堆栈: $stackTrace');
      return null;
    }
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
    this.milestones = const [],
    this.template = 'default',
  });

  @override
  Widget build(BuildContext context) {
    final templateConfig = _getTemplateConfig(template);
    
    return Container(
      width: 1080,
      height: 1920,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: templateConfig.colors,
        ),
      ),
      child: Column(
        children: [
          _buildHeader(templateConfig),
          _buildBabyInfo(),
          if (latestGrowth != null) _buildGrowthInfo(),
          if (milestones.isNotEmpty) _buildMilestones(),
          const Spacer(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(TemplateConfig config) {
    return Container(
      padding: const EdgeInsets.only(top: 80, left: 60, right: 60, bottom: 40),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: config.accentColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.child_care,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '宝宝成长记录',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: config.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${DateTime.now().year}年${DateTime.now().month}月',
                  style: TextStyle(
                    fontSize: 28,
                    color: config.textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBabyInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                baby.name.isNotEmpty ? baby.name[0] : '👶',
                style: const TextStyle(
                  fontSize: 60,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  baby.name,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${baby.gender} · ${baby.ageDisplay}',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthInfo() {
    return Container(
      margin: const EdgeInsets.all(60),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最新生长数据',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (latestGrowth?.weight != null)
                _buildGrowthItem('体重', '${latestGrowth!.weight!.toStringAsFixed(1)}', 'kg'),
              if (latestGrowth?.height != null)
                _buildGrowthItem('身高', '${latestGrowth!.height!.toStringAsFixed(1)}', 'cm'),
              if (latestGrowth?.headCircumference != null)
                _buildGrowthItem('头围', '${latestGrowth!.headCircumference!.toStringAsFixed(1)}', 'cm'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 28,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMilestones() {
    // MilestoneRecord 有 completedDate 就表示已完成
    final recentMilestones = milestones.where((m) => m.completedDate != null).take(3).toList();
    if (recentMilestones.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '最近达成里程碑',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 24),
          ...recentMilestones.map((m) => _buildMilestoneItem(m)),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(MilestoneRecord milestone) {
    // 从 MilestoneData 获取里程碑标题
    final milestoneData = MilestoneData.getMilestoneById(milestone.milestoneId);
    final title = milestoneData?.title ?? '里程碑';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.success,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                color: Color(0xFF333333),
              ),
            ),
          ),
          if (milestone.completedDate != null)
            Text(
              '${milestone.completedDate!.month}/${milestone.completedDate!.day}',
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite,
            color: Colors.red,
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            '记录成长的每一个瞬间',
            style: TextStyle(
              fontSize: 28,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  TemplateConfig _getTemplateConfig(String template) {
    switch (template) {
      case 'warm':
        return TemplateConfig(
          colors: [const Color(0xFFFFE4D6), const Color(0xFFFFD4E5)],
          accentColor: const Color(0xFFFF8A80),
          textColor: const Color(0xFF5D4037),
        );
      case 'fresh':
        return TemplateConfig(
          colors: [const Color(0xFFE0F7FA), const Color(0xFFB2EBF2)],
          accentColor: const Color(0xFF00BCD4),
          textColor: const Color(0xFF006064),
        );
      default:
        return TemplateConfig(
          colors: [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
          accentColor: AppColors.primary,
          textColor: const Color(0xFF1565C0),
        );
    }
  }
}

/// 模板配置
class TemplateConfig {
  final List<Color> colors;
  final Color accentColor;
  final Color textColor;

  TemplateConfig({
    required this.colors,
    required this.accentColor,
    required this.textColor,
  });
}
