import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateService {
  static const String _repoOwner = 'Travisgogogo';
  static const String _repoName = 'baby-growth';
  static const String _apiUrl = 'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest';
  static const platform = MethodChannel('com.example.myapp/update');

  static Future<UpdateInfo?> checkUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final latestVersion = data['tag_name']?.toString().replaceFirst('v', '');
      final changelog = data['body'] ?? '';
      
      String? apkUrl;
      final assets = data['assets'] as List<dynamic>?;
      if (assets != null) {
        for (final asset in assets) {
          final name = asset['name'] as String?;
          if (name != null && name.endsWith('.apk')) {
            apkUrl = asset['browser_download_url'] as String?;
            break;
          }
        }
      }

      if (latestVersion == null || apkUrl == null) return null;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final hasUpdate = _compareVersion(latestVersion, currentVersion) > 0;

      return UpdateInfo(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        changelog: changelog,
        apkUrl: apkUrl,
        hasUpdate: hasUpdate,
      );
    } catch (e) {
      print('检查更新错误: $e');
      return null;
    }
  }

  static int _compareVersion(String v1, String v2) {
    final parts1 = v1.split('.').map(int.tryParse).whereType<int>().toList();
    final parts2 = v2.split('.').map(int.tryParse).whereType<int>().toList();
    for (int i = 0; i < parts1.length && i < parts2.length; i++) {
      if (parts1[i] > parts2[i]) return 1;
      if (parts1[i] < parts2[i]) return -1;
    }
    return parts1.length.compareTo(parts2.length);
  }

  /// 请求存储权限
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  /// 调用原生方法下载并安装 APK
  static Future<void> downloadAndInstall(String apkUrl) async {
    try {
      await platform.invokeMethod('downloadAndInstallApk', {
        'url': apkUrl,
        'fileName': 'baby-growth-update.apk',
      });
    } on PlatformException catch (e) {
      print('下载安装失败: ${e.message}');
      throw Exception('下载安装失败: ${e.message}');
    }
  }
}

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String changelog;
  final String apkUrl;
  final bool hasUpdate;

  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.changelog,
    required this.apkUrl,
    required this.hasUpdate,
  });
}

class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;
  const UpdateDialog({super.key, required this.updateInfo});

  static Future<void> show(BuildContext context, UpdateInfo info) {
    return showDialog(
      context: context,
      barrierDismissible: !info.hasUpdate,
      builder: (_) => UpdateDialog(updateInfo: info),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('发现新版本'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('当前: ${widget.updateInfo.currentVersion}'),
          Text('最新: ${widget.updateInfo.latestVersion}',
              style: TextStyle(color: Theme.of(context).primaryColor)),
          if (widget.updateInfo.changelog.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('更新内容:', style: TextStyle(fontWeight: FontWeight.w500)),
            Container(
              constraints: const BoxConstraints(maxHeight: 100),
              child: SingleChildScrollView(
                child: Text(widget.updateInfo.changelog, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!_isUpdating)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后'),
          ),
        if (!_isUpdating)
          FilledButton(
            onPressed: _startUpdate,
            child: const Text('立即更新'),
          ),
        if (_isUpdating)
          const FilledButton(
            onPressed: null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 8),
                Text('准备中...'),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _startUpdate() async {
    // 请求权限
    final hasPermission = await UpdateService.requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('需要存储权限才能下载更新')),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      await UpdateService.downloadAndInstall(widget.updateInfo.apkUrl);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新失败: $e')),
      );
    }
  }
}
