import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_theme.dart';
import '../widgets/animations.dart';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../models/milestone.dart';
import '../services/database_service.dart';
import '../services/share_poster_service.dart';

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
  File? _generatedPoster;
  String _selectedTemplate = 'default';

  final List<_TemplateItem> _templates = [
    _TemplateItem('default', '默认', [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)]),
    _TemplateItem('warm', '温暖', [const Color(0xFFFFE4D6), const Color(0xFFFFD4E5)]),
    _TemplateItem('fresh', '清新', [const Color(0xFFE0F7FA), const Color(0xFFB2EBF2)]),
  ];

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

  Future<void> _generatePoster() async {
    if (_baby == null) return;
    
    setState(() => _isGenerating = true);
    
    try {
      final poster = await SharePosterService.generateGrowthPoster(
        baby: _baby!,
        latestGrowth: _latestGrowth,
        milestones: _milestones,
        template: _selectedTemplate,
      );
      
      setState(() => _generatedPoster = poster);
      
      if (poster != null && mounted) {
        _showPosterPreview(poster);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成海报失败: $e')),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _showPosterPreview(File posterFile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      '成长海报',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Center(
                  child: Image.file(
                    posterFile,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _savePoster(posterFile),
                      icon: const Icon(Icons.download),
                      label: const Text('保存到相册'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _sharePoster(posterFile),
                      icon: const Icon(Icons.share),
                      label: const Text('分享'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePoster(File posterFile) async {
    try {
      // 使用 share_plus 保存到相册
      await Share.shareXFiles(
        [XFile(posterFile.path)],
        text: '${_baby?.name}的成长记录',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已保存')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  Future<void> _sharePoster(File posterFile) async {
    try {
      await Share.shareXFiles(
        [XFile(posterFile.path)],
        text: '看看${_baby?.name}的成长记录！',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: $e')),
        );
      }
    }
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
                      _buildSectionTitle('选择模板'),
                      const SizedBox(height: 12),
                      _buildPosterTemplates(),
                      const SizedBox(height: 32),
                      _buildGenerateButton(),
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
    return Row(
      children: _templates.map((template) {
        final isSelected = _selectedTemplate == template.id;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTemplate = template.id),
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
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 3)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    template.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  if (isSelected)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isGenerating ? null : _generatePoster,
        icon: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(_isGenerating ? '生成中...' : '生成成长海报'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTimelineCard() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('时光轴功能开发中')),
        );
      },
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.timeline,
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
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
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
