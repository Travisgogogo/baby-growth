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
        date: DateTime.parse(record.date),
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
        title: const Text('分享成长'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _baby == null
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('成长海报'),
                      const SizedBox(height: 12),
                      _buildPosterTemplates(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('时光轴回顾'),
                      const SizedBox(height: 12),
                      _buildTimelineCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.child_care, size: 80, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            '请先添加宝宝信息',
            style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headline.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPosterTemplates() {
    final templates = [
      _TemplateItem('default', '默认', [Color(0xFFE3F2FD), Color(0xFFBBDEFB)]),
      _TemplateItem('warm', '温暖', [Color(0xFFFFE4D6), Color(0xFFFFD4E5)]),
      _TemplateItem('fresh', '清新', [Color(0xFFE0F7FA), Color(0xFFB2EBF2)]),
    ];

    return Row(
      children: templates.map((template) {
        return Expanded(
          child: AnimatedButton(
            onTap: () => _generateAndSharePoster(template.id),
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: template.colors,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _isGenerating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        template.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimelineCard() {
    return AnimatedCard(
      onTap: _generateTimelinePoster,
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.timeline,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '生成时光轴',
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '回顾宝宝的成长历程',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          _isGenerating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

class _TemplateItem {
  final String id;
  final String name;
  final List<Color> colors;

  _TemplateItem(this.id, this.name, this.colors);
}
