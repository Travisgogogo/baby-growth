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
  List<Map<String, dynamic>> _backupFiles = [];
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
    
    if (connected) {
      await _loadBackupList();
    }
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
    setState(() => _isLoading = true);
    
    try {
      final files = await nutstoreService.listBackupFiles();
      setState(() {
        _backupFiles = files;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载备份列表失败：$e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
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
        
        // 备份成功后刷新列表
        try {
          await _loadBackupList();
        } catch (e) {
          print('刷新备份列表失败: $e');
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  /// 导出所有数据
  Future<Map<String, dynamic>> _exportAllData() async {
    try {
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
    } catch (e) {
      print('导出数据失败: $e');
      throw Exception('导出数据失败: $e');
    }
  }
  
  /// 从云端恢复数据
  Future<void> _restoreFromBackup(Map<String, dynamic> fileInfo) async {
    final fileName = fileInfo['name'] as String;
    
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认恢复'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '恢复备份将覆盖当前所有数据！',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('备份文件：$fileName'),
            Text('备份时间：${_formatBackupTime(fileInfo['lastModified'] ?? '')}'),
            const SizedBox(height: 16),
            const Text('建议先备份当前数据，以防万一。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认恢复'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() => _isLoading = true);
    
    try {
      // 1. 下载备份文件
      final bytes = await nutstoreService.downloadFile(fileName);
      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('下载备份文件失败')),
          );
        }
        return;
      }
      
      // 2. 解析 JSON
      final jsonString = utf8.decode(bytes);
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // 3. 恢复数据到数据库
      await _importAllData(backupData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据恢复成功！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('恢复失败：$e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  /// 导入所有数据
  Future<void> _importAllData(Map<String, dynamic> backupData) async {
    final db = await DatabaseService.instance.database;
    
    await db.transaction((txn) async {
      // 清空现有数据
      await txn.delete('vaccine_records');
      await txn.delete('illness_records');
      await txn.delete('photos');
      await txn.delete('milestone_records');
      await txn.delete('diaper_records');
      await txn.delete('sleep_records');
      await txn.delete('feed_records');
      await txn.delete('growth_records');
      await txn.delete('babies');
      
      // 导入宝宝信息
      final babies = backupData['babies'] as List<dynamic>?;
      if (babies != null) {
        for (final baby in babies) {
          await txn.insert('babies', baby as Map<String, dynamic>);
        }
      }
      
      // 导入生长记录
      final growthRecords = backupData['growth_records'] as List<dynamic>?;
      if (growthRecords != null) {
        for (final record in growthRecords) {
          await txn.insert('growth_records', record as Map<String, dynamic>);
        }
      }
      
      // 导入喂养记录
      final feedRecords = backupData['feed_records'] as List<dynamic>?;
      if (feedRecords != null) {
        for (final record in feedRecords) {
          await txn.insert('feed_records', record as Map<String, dynamic>);
        }
      }
      
      // 导入睡眠记录
      final sleepRecords = backupData['sleep_records'] as List<dynamic>?;
      if (sleepRecords != null) {
        for (final record in sleepRecords) {
          await txn.insert('sleep_records', record as Map<String, dynamic>);
        }
      }
      
      // 导入换尿布记录
      final diaperRecords = backupData['diaper_records'] as List<dynamic>?;
      if (diaperRecords != null) {
        for (final record in diaperRecords) {
          await txn.insert('diaper_records', record as Map<String, dynamic>);
        }
      }
      
      // 导入里程碑
      final milestones = backupData['milestones'] as List<dynamic>?;
      if (milestones != null) {
        for (final milestone in milestones) {
          await txn.insert('milestone_records', milestone as Map<String, dynamic>);
        }
      }
      
      // 导入照片
      final photos = backupData['photos'] as List<dynamic>?;
      if (photos != null) {
        for (final photo in photos) {
          await txn.insert('photos', photo as Map<String, dynamic>);
        }
      }
      
      // 导入疾病记录
      final illnessRecords = backupData['illness_records'] as List<dynamic>?;
      if (illnessRecords != null) {
        for (final record in illnessRecords) {
          await txn.insert('illness_records', record as Map<String, dynamic>);
        }
      }
      
      // 导入疫苗记录
      final vaccineRecords = backupData['vaccine_records'] as List<dynamic>?;
      if (vaccineRecords != null) {
        for (final record in vaccineRecords) {
          await txn.insert('vaccine_records', record as Map<String, dynamic>);
        }
      }
    });
  }
  
  /// 删除备份文件
  Future<void> _deleteBackup(Map<String, dynamic> fileInfo) async {
    final fileName = fileInfo['name'] as String;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除备份文件 "$fileName" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() => _isLoading = true);
    
    try {
      final success = await nutstoreService.deleteFile(fileName);
      if (success) {
        await _loadBackupList();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('备份已删除')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除出错：$e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  /// 格式化备份时间
  String _formatBackupTime(String lastModified) {
    if (lastModified.isEmpty) return '未知';
    
    try {
      // 解析 HTTP date format: Mon, 01 Mar 2026 08:30:00 GMT
      final date = HttpDate.parse(lastModified);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
             '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return lastModified;
    }
  }
  
  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('云端备份'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _backup,
                            icon: const Icon(Icons.backup),
                            label: const Text('立即备份'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _loadBackupList,
                            icon: const Icon(Icons.refresh),
                            label: const Text('刷新列表'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '云端备份列表',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_backupFiles.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              '暂无备份文件',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _backupFiles.length,
                        itemBuilder: (context, index) {
                          final file = _backupFiles[index];
                          final fileName = file['name'] as String;
                          final lastModified = file['lastModified'] as String;
                          final size = file['size'] as int;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.backup, color: AppColors.primary),
                              title: Text(
                                fileName,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${_formatBackupTime(lastModified)} · ${_formatFileSize(size)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.restore, color: Colors.blue),
                                    tooltip: '恢复此备份',
                                    onPressed: () => _restoreFromBackup(file),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: '删除',
                                    onPressed: () => _deleteBackup(file),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}
