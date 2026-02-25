import 'package:flutter/material.dart';
import '../models/baby.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Baby? _baby;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // 宝宝信息卡片
          _buildBabyCard(),
          
          const SizedBox(height: 16),
          
          // 功能列表
          _buildSectionTitle('宝宝管理'),
          _buildMenuItem(Icons.child_care, '宝宝资料', () => _editBabyProfile()),
          _buildMenuItem(Icons.swap_horiz, '切换宝宝', () => _switchBaby()),
          _buildMenuItem(Icons.add_circle, '添加宝宝', () => _addBaby()),
          
          const SizedBox(height: 16),
          
          _buildSectionTitle('设置'),
          _buildMenuItem(Icons.notifications, '提醒设置', () => _showReminderSettings()),
          _buildMenuItem(Icons.backup, '数据备份', () => _backupData()),
          _buildMenuItem(Icons.restore, '数据恢复', () => _restoreData()),
          _buildMenuItem(Icons.share, '分享成长', () => _shareGrowth()),
          
          const SizedBox(height: 16),
          
          _buildSectionTitle('关于'),
          _buildMenuItem(Icons.help, '使用帮助', () => _showHelp()),
          _buildMenuItem(Icons.star, '给我们评分', () => _rateApp()),
          _buildMenuItem(Icons.info, '关于我们', () => _showAbout()),
          
          const SizedBox(height: 32),
          
          // 版本号
          Center(
            child: Text(
              '宝宝成长记 v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBabyCard() {
    if (_baby == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            '暂无宝宝信息',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Center(
              child: Text('👶', style: TextStyle(fontSize: 32)),
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
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_baby!.gender}宝 · ${_baby!.ageDisplay}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '出生: ${_formatDate(_baby!.birthDate)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _editBabyProfile(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF667eea)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _editBabyProfile() {
    if (_baby == null) return;
    
    final nameController = TextEditingController(text: _baby!.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑宝宝资料'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '宝宝姓名',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _baby = _baby!.copyWith(name: nameController.text);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('资料已更新')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _switchBaby() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('切换宝宝'),
        content: const Text('当前只有一个宝宝'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _addBaby() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加宝宝'),
        content: const Text('添加多个宝宝功能即将上线'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showReminderSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提醒设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('喂奶提醒'),
              value: true,
              onChanged: (v) {},
            ),
            SwitchListTile(
              title: const Text('睡眠提醒'),
              value: false,
              onChanged: (v) {},
            ),
            SwitchListTile(
              title: const Text('里程碑提醒'),
              value: true,
              onChanged: (v) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _backupData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('数据备份'),
        content: const Text('数据已备份到本地'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _restoreData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('数据恢复'),
        content: const Text('请选择备份文件'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据已恢复')),
              );
            },
            child: const Text('恢复'),
          ),
        ],
      ),
    );
  }

  void _shareGrowth() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('分享成长'),
        content: const Text('生成成长报告并分享'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已生成分享图片')),
              );
            },
            child: const Text('生成'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用帮助'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. 首页可以快捷记录喂奶、睡眠等'),
              SizedBox(height: 8),
              Text('2. 生长曲线查看宝宝发育趋势'),
              SizedBox(height: 8),
              Text('3. 里程碑记录宝宝成长时刻'),
              SizedBox(height: 8),
              Text('4. 数据自动保存到本地'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('给我们评分'),
        content: const Text('如果您喜欢我们的应用，请给我们五星好评！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('感谢您的支持！')),
              );
            },
            child: const Text('去评分'),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于我们'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('👶 宝宝成长记', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('记录宝宝成长的每一个瞬间'),
            SizedBox(height: 16),
            Text('版本: 1.0.0', style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}
