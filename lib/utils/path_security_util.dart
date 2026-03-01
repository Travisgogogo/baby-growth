import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 文件路径安全工具类
class PathSecurityUtil {
  static List<String>? _allowedPrefixes;

  /// 初始化允许的路径前缀
  static Future<void> initialize() async {
    if (_allowedPrefixes != null) return;
    
    final appDir = await getApplicationDocumentsDirectory();
    final tempDir = await getTemporaryDirectory();
    final cacheDir = await getApplicationCacheDirectory();
    
    _allowedPrefixes = [
      appDir.path,
      tempDir.path,
      cacheDir.path,
    ];
  }

  /// 验证文件路径是否在应用沙箱内
  static bool isPathSecure(String? path) {
    if (path == null || path.isEmpty) return true; // null 视为安全（无路径）
    if (_allowedPrefixes == null) {
      // 未初始化时的简单检查
      return !path.contains('..') && 
             !path.startsWith('/') && 
             !path.startsWith('\\');
    }
    
    // 检查路径是否在允许的目录内
    for (final prefix in _allowedPrefixes!) {
      if (path.startsWith(prefix)) {
        // 额外检查路径遍历攻击
        final normalizedPath = File(path).absolute.path;
        if (!normalizedPath.contains('..')) {
          return true;
        }
      }
    }
    
    return false;
  }

  /// 获取安全的文件路径（如果不安全则返回 null）
  static String? getSecurePath(String? path) {
    if (isPathSecure(path)) {
      return path;
    }
    return null;
  }

  /// 验证并清理图片路径列表
  static List<String> filterSecurePaths(List<String>? paths) {
    if (paths == null) return [];
    return paths.where(isPathSecure).toList();
  }
}
