import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_theme.dart';
import '../services/nutstore_service.dart';
import '../services/database_service.dart';

/// 云端备份页面
class CloudBackupScreen extends StatefulWidget {
  const CloudBackupScreen({super.key});

  @override
  State<CloudBackupScreen> createState() => _CloudBackupScreenState();
}

class _CloudBackupScreenState extends State<CloudBackupScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isConnected = false;
  String? _lastBackupTime;
  List<String> _backupFiles = [];
  bool _rememberCredentials = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastBackupTime = prefs.getString('last_backup_time');
      _rememberCredentials = prefs.getBool('nutstore_remember_credentials') ?? false;
      if (_rememberCredentials) {
        _usernameController.text = prefs.getString('nutstore_username') ?? '';
        _passwordController.text = prefs.getString('nutstore_password') ?? '';
      }
    });
    
    // 如果已有保存的凭据，自动尝试连接
    if (_rememberCredentials && _usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      _autoConnect();
    }
  }
  
  Future<void> _autoConnect() async {
    setState(() => _isLoading = true);
    
    nutstoreService.setCredentials(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );
    
    final result = await nutstoreService.testConnectionWithDetails();
    final connected = result['success'] as bool;
    
    setState(() {
      _isConnected = connected;
      _isLoading = false;
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('nutstore_remember_credentials', _rememberCredentials);
    if (_rememberCredentials) {
      await prefs.setString('nutstore_username', _usernameController.text.trim());
      await prefs.setString('nutstore_password', _passwordController.text.trim());
    } else {
      await prefs.remove('nutstore_username');
      await prefs.remove('nutstore_password');
    }
  }

  Future<void> _connect() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入用户名和密码')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    nutstoreService.setCredentials(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );
    
    final result = await nutstoreService.testConnectionWithDetails();
    final connected = result['success'] as bool;
    final error = result['error'] as String?;
    
    setState(() {
      _isConnected = connected;
      _isLoading = false;
    });
    
    if (connected) {
      // 保存凭据设置
      await _saveCredentials();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('连接成功')),
      );
      // 连接成功后加载备份列表
      await _loadBackupList();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('连接失败'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('错误信息：$error'),
              const SizedBox(height: 16),
              const Text('请检查以下设置：'),
              const SizedBox(height: 8),
              const Text('1. 用户名是坚果云邮箱'),
              const Text('2. 密码是应用密码（非登录密码）'),
              const Text('3. 在坚果云网页版生成应用密码'),
              const SizedBox(height: 8),
              const Text('生成应用密码步骤：'),
              const Text('网页版 → 安全设置 → 第三方应用管理 → 添加应用密码'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('知道了'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loadBackupList() async {
    // TODO: 实现列出备份文件
  }

  Future<void> _backup() async {
    setState(() => _isLoading = true);
    
    try {
      // 1. 导出所有数据
      final backupData = await _exportAllData();
      
      // 2. 转换为 JSON
      final jsonData = jsonEncode(backupData);
      final bytes = utf8.encode(jsonData);
      
      // 3. 生成文件名（带时间戳）
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'baby-growth-backup-$timestamp.json';
      
      // 4. 上传到坚果云
      final success = await nutstoreService.uploadFile(fileName, bytes);
      
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_backup_time', DateTime.now().toIso8601String());
        await _loadSavedData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('备份成功：$fileName')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('备份失败，请重试')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('备份出错：$e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  /// 导出所有数据
  Future<Map<String, dynamic>> _exportAllData() async {
    final db = await DatabaseService.instance.database;
    
    final babies = await db.query('babies');
    final growthRecords = await db.query('growth_records');
    final feedRecords = await db.query('feed_records');
    final sleepRecords = await db.query('sleep_records');
    final diaperRecords = await db.query('diaper_records');
    final milestones = await db.query('milestone_records');
    final photos = await db.query('photos');
    final illnessRecords = await db.query('illness_records');
    final vaccineRecords = await db.query('vaccine_records');
    
    return {
      'version': 1,
      'exportTime': DateTime.now().toIso8601String(),
      'babies': babies,
      'growth_records': growthRecords,
      'feed_records': feedRecords,
      'sleep_records': sleepRecords,
      'diaper_records': diaperRecords,
      'milestones': milestones,
      'photos': photos,
      'illness_records': illnessRecords,
      'vaccine_records': vaccineRecords,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('云端备份'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_lastBackupTime != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '上次备份',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _lastBackupTime!.substring(0, 19).replaceAll('T', ' '),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '坚果云用户名（邮箱）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '应用密码（非登录密码）',
                border: OutlineInputBorder(),
                helperText: '在坚果云网页版 → 安全设置 → 第三方应用管理 → 生成应用密码',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _rememberCredentials,
                  onChanged: (value) {
                    setState(() {
                      _rememberCredentials = value ?? false;
                    });
                  },
                ),
                const Text('记住账号密码'),
                const Spacer(),
                if (_rememberCredentials)
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('nutstore_username');
                      await prefs.remove('nutstore_password');
                      await prefs.setBool('nutstore_remember_credentials', false);
                      setState(() {
                        _rememberCredentials = false;
                        _usernameController.clear();
                        _passwordController.clear();
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已清除保存的账号密码')),
                        );
                      }
                    },
                    child: const Text('清除'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _connect,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isConnected ? '重新连接' : '连接'),
            ),
            if (_isConnected) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _backup,
                icon: const Icon(Icons.backup),
                label: const Text('立即备份'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
