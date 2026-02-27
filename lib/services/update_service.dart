import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

/// GitHub Releases 更新服务
class UpdateService {
  static const String _repoOwner = 'Travisgogogo';
  static const String _repoName = 'baby-growth';
  static const String _apiUrl = 'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest';
  static const String _apkName = 'app-release.apk';

  /// 检查更新
  static Future<UpdateInfo?> checkUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode != 200) {
        print('检查更新失败: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      final latestVersion = data['tag_name']?.toString().replaceFirst('v', '');
      final changelog = data['body'] ?? '';
      
      // 查找 APK 下载链接
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

      if (latestVersion == null || apkUrl == null) {
        return null;
      }

      // 获取当前版本
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // 比较版本
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

  /// 版本号比较
  /// 返回: 1=新版本更大, 0=相同, -1=旧版本更大
  static int _compareVersion(String v1, String v2) {
    final parts1 = v1.split('.').map(int.tryParse).whereType<int>().toList();
    final parts2 = v2.split('.').map(int.tryParse).whereType<int>().toList();

    for (int i = 0; i < parts1.length && i < parts2.length; i++) {
      if (parts1[i] > parts2[i]) return 1;
      if (parts1[i] < parts2[i]) return -1;
    }

    if (parts1.length > parts2.length) return 1;
    if (parts1.length < parts2.length) return -1;
    return 0;
  }

  /// 下载并安装 APK
  static Future<void> downloadAndInstall(
    String apkUrl,
    Function(double progress) onProgress,
  ) async {
    try {
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/$_apkName';

      // 删除旧文件
      final oldFile = File(savePath);
      if (await oldFile.exists()) {
        await oldFile.delete();
      }

      // 下载文件
      final request = http.Request('GET', Uri.parse(apkUrl));
      final response = await request.send();
      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      final file = File(savePath);
      final sink = file.openWrite();

      await response.stream.listen(
        (chunk) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          if (totalBytes > 0) {
            onProgress(receivedBytes / totalBytes);
          }
        },
        onDone: () async {
          await sink.close();
          // 安装 APK
          final result = await OpenFile.open(savePath);
          print('安装结果: $result');
        },
        onError: (e) {
          sink.close();
          throw e;
        },
      ).asFuture();
    } catch (e) {
      print('下载安装错误: $e');
      rethrow;
    }
  }
}

/// 更新信息
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

/// 更新对话框
class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;

  const UpdateDialog({super.key, required this.updateInfo});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();

  /// 显示更新对话框
  static Future<void> show(BuildContext context, UpdateInfo info) {
    return showDialog(
      context: context,
      barrierDismissible: !info.hasUpdate,
      builder: (_) => UpdateDialog(updateInfo: info),
    );
  }
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.system_update, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          const Text('发现新版本'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前版本: ${widget.updateInfo.currentVersion}',
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            '最新版本: ${widget.updateInfo.latestVersion}',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (widget.updateInfo.changelog.isNotEmpty) ...[
            const Text(
              '更新内容:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  widget.updateInfo.changelog,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
          if (_isDownloading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 8),
            Text(
              '下载中... ${(_progress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              '错误: $_error',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        if (!widget.updateInfo.hasUpdate)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          )
        else if (!_isDownloading)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后更新'),
          ),
        if (widget.updateInfo.hasUpdate && !_isDownloading)
          FilledButton(
            onPressed: _startDownload,
            child: const Text('立即更新'),
          ),
      ],
    );
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _error = null;
    });

    try {
      await UpdateService.downloadAndInstall(
        widget.updateInfo.apkUrl,
        (progress) => setState(() => _progress = progress),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _error = e.toString();
      });
    }
  }
}
