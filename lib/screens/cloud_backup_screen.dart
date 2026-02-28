import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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
    
    final connected = await nutstoreService.testConnection();
    setState(() {
      _isConnected = connected;
      _isLoading = false;
    });
    
    if (connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('连接成功')),
      );
    } else {
      // 显示详细错误信息
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('连接失败'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('请检查以下设置：'),
              SizedBox(height: 8),
              Text('1. 用户名是坚果云邮箱'),
              Text('2. 密码是应用密码（非登录密码）'),
              Text('3. 在坚果云网页版生成应用密码'),
              SizedBox(height: 8),
              Text('生成应用密码步骤：'),
              Text('网页版 → 安全设置 → 第三方应用管理 → 添加应用密码'),
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

  Future<void> _backup() async {
    setState(() => _isLoading = true);
    // 备份逻辑
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('备份功能开发中')),
    );
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
          children: [
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _connect,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('连接'),
            ),
            if (_isConnected) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _backup,
                child: const Text('立即备份'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
