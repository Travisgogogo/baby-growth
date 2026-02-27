import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:install_plugin/install_plugin.dart';

class UpdateService {
  static const String _repoOwner = 'Travisgogogo';
  static const String _repoName = 'baby-growth';
  static const String _apiUrl = 'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest';

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

  static Future<bool> requestInstallPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.requestInstallPackages.request();
      return status.isGranted;
    }
    return true;
  }

  static Future<String?> downloadApk(String apkUrl, Function(double) onProgress) async {
    final dir = await getTemporaryDirectory();
    final savePath = '${dir.path}/app-release.apk';
    
    final oldFile = File(savePath);
    if (await oldFile.exists()) await oldFile.delete();

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
        if (totalBytes > 0) onProgress(receivedBytes / totalBytes);
      },
      onDone: () async => await sink.close(),
      onError: (e) {
        sink.close();
        throw e;
      },
    ).asFuture();

    return savePath;
  }

  static Future<String?> installApk(String filePath) async {
    return await InstallPlugin.installApk(filePath, 'com.example.myapp');
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

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();

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
  bool _isInstalling = false;
  double _progress = 0;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('发现新版本'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('当前: ${widget.updateInfo.currentVersion}'),
          Text('最新: ${widget.updateInfo.latestVersion}'),
          if (_isDownloading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _progress),
            Text('${(_progress * 100).toInt()}%'),
          ],
          if (_error != null)
            Text('错误: $_error', style: const TextStyle(color: Colors.red)),
        ],
      ),
      actions: [
        if (!_isDownloading && !_isInstalling)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍后'),
          ),
        if (!_isDownloading && !_isInstalling)
          FilledButton(
            onPressed: _downloadAndInstall,
            child: const Text('立即更新'),
          ),
        if (_isInstalling)
          const FilledButton(
            onPressed: null,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  Future<void> _downloadAndInstall() async {
    final hasPermission = await UpdateService.requestInstallPermission();
    if (!hasPermission) {
      setState(() => _error = '需要安装权限');
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final path = await UpdateService.downloadApk(
        widget.updateInfo.apkUrl,
        (p) => setState(() => _progress = p),
      );

      setState(() {
        _isDownloading = false;
        _isInstalling = true;
      });

      await UpdateService.installApk(path!);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _isInstalling = false;
        _error = e.toString();
      });
    }
  }
}
