import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

/// 版本信息工具类
class VersionUtil {
  static String? _version;
  
  /// 从 pubspec.yaml 读取版本号
  static Future<String> getVersion() async {
    if (_version != null) return _version!;
    
    try {
      final pubspec = await rootBundle.loadString('pubspec.yaml');
      final yaml = loadYaml(pubspec);
      _version = yaml['version']?.toString().split('+')[0] ?? '1.0.0';
      return _version!;
    } catch (e) {
      return '1.7.9';
    }
  }
}