import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_theme.dart';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../models/milestone.dart';
import '../services/database_service.dart';
import '../services/share_poster_service.dart';
import '../widgets/animations.dart';

/// 分享页面
class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  Baby? _baby;
  GrowthRecord? _latestGrowth;
  List<MilestoneRecord> _milestones = [];
  bool _isLoading = true;
  bool _isGenerating = false;

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
        
        final growthRecords = await DatabaseService.instance.getGrowthRecords(babyId);
        if (growthRecords.isNotEmpty) {
          setState(() => _latestGrowth = growthRecords.first);
        }
        
        final milestones = await DatabaseService.instance.getMilestoneRecords(babyId);
        setState(() => _milestones = milestones);
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _generateAndSharePoster(String template) async {
    if (_baby == null) return;
    
    setState(() => _isGenerating = true);
    
    try {
      final file = await SharePosterService.generateGrowthPoster(
        baby: _baby!,
        latestGrowth: _latestGrowth,
        milestones: _milestones,
        template: template,
      );
      
      if (file != null) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: '${_baby!.name}的成长记录 - 宝宝成长记',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('生成海报失败: $e')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateTimelinePoster() async {
    if (_baby == null) return;
    
    setState(() => _isGenerating = true);
    
    try {
      // 构建时间轴数据
      final items = await _buildTimelineItems();
      
      final file = await SharePosterService.generateTimelinePoster(
        baby: _baby!,
        items: items,
        startDate: _baby!.birthDate,
        endDate: DateTime.now(),
      );
      
      if (file != null) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: '${_baby!.name}的成长时光轴 - 宝宝成长记',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('生成时光轴失败: $e')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<List<TimelineItem>> _buildTimelineItems() async {
    final items = <TimelineItem>[];
    
    if (_baby == null) return items;
    
    final babyId = _baby!.id;
    if (babyId == null) return items;
    
    // 添加里程碑记录
    for (final record in _milestones) {
      items.add(TimelineItem(
        date: record.completedDate,
        title: '完成了新里程碑',
        description: record.note,
        imagePath: record.photoPath,
        type: TimelineItemType.milestone,
      ));
    }
    
    // 添加生长记录
    final growthRecords = await DatabaseService.instance.getGrowthRecords(babyId);
    for (final record in growthRecords.take(5)) {
      items.add(TimelineItem(
        date: record.date,  // 修复：record.date 已经是 DateTime 类型
        title: '测量了身高体重',
        description: '体重: ${record.weight?.toStringAsFixed(1)}kg, 身高: ${record.height?.toStringAsFixed(0)}cm',
        type: TimelineItemType.growth,
      ));
    }
    
    // 按时间排序
    items.sort((a, b) => b.date.compareTo(a.date));
    
    return items.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '分享成长',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _baby == null
              ? _buildNoBabyView()
              : _buildShareContent(),
    );
  }

  Widget _buildNoBabyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.baby_changing_station,
            size: 80,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            '还没有添加宝宝信息',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '先去添加宝宝信息吧',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 宝宝信息卡片
          _buildBabyInfoCard(),
          const SizedBox(height: 24),
          
          // 分享海报选项
          const Text(
            '生成分享海报',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          // 海报模板选择
          _buildPosterTemplates(),
          const SizedBox(height: 24),
          
          // 时光轴分享
          const Text(
            '成长时光轴',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildTimelineCard(),
          
          if (_isGenerating) ...[
            const SizedBox(height: 24),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text(
                    '正在生成海报...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBabyInfoCard() {
    return FadeInAnimation(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF7043).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.child_care,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _baby!.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_baby!.ageText} · ${_baby!.genderText}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  if (_latestGrowth != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '身高: ${_latestGrowth!.height?.toStringAsFixed(1) ?? "--"}cm  体重: ${_latestGrowth!.weight?.toStringAsFixed(2) ?? "--"}kg',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterTemplates() {
    final templates = [
      {'name': '简约', 'color': const Color(0xFF81C784)},
      {'name': '可爱', 'color': const Color(0xFFFFB74D)},
      {'name': '温馨', 'color': const Color(0xFF64B5F6)},
    ];

    return Row(
      children: templates.map((template) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ScaleTapAnimation(
              onTap: () => _generateAndSharePoster(template['name'] as String),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: (template['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (template['color'] as Color).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 32,
                      color: template['color'] as Color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      template['name'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: template['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimelineCard() {
    return ScaleTapAnimation(
      onTap: _generateTimelinePoster,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.timeline,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '成长时光轴',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '回顾${_baby!.name}的成长历程',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
