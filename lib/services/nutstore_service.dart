import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// 坚果云 WebDAV 服务
class NutstoreService {
  static const String _baseUrl = 'https://dav.jianguoyun.com/dav';
  
  String? _username;
  String? _password;
  
  /// 设置认证信息
  void setCredentials(String username, String password) {
    _username = username;
    _password = password;
  }
  
  /// 检查是否已设置认证
  bool get isAuthenticated => _username != null && _password != null;
  
  /// 测试连接
  Future<bool> testConnection() async {
    if (!isAuthenticated) return false;
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/'),
        headers: _getAuthHeaders(),
      );
      print('坚果云连接测试: status=${response.statusCode}');
      if (response.statusCode == 401) {
        print('认证失败: 请检查用户名和应用密码');
      }
      return response.statusCode == 200 || response.statusCode == 207;
    } catch (e) {
      print('连接测试失败: $e');
      return false;
    }
  }
  
  /// 上传文件
  Future<bool> uploadFile(String remotePath, List<int> data) async {
    if (!isAuthenticated) return false;
    
    try {
      // 先创建目录
      await _createDirectory('baby-growth-backup');
      
      final response = await http.put(
        Uri.parse('$_baseUrl/baby-growth-backup/$remotePath'),
        headers: {
          ..._getAuthHeaders(),
          'Content-Type': 'application/octet-stream',
        },
        body: data,
      );
      
      return response.statusCode == 201 || response.statusCode == 204;
    } catch (e) {
      print('上传失败: $e');
      return false;
    }
  }
  
  /// 下载文件
  Future<List<int>?> downloadFile(String remotePath) async {
    if (!isAuthenticated) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/baby-growth-backup/$remotePath'),
        headers: _getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      print('下载失败: $e');
      return null;
    }
  }
  
  /// 列出文件
  Future<List<String>> listFiles() async {
    if (!isAuthenticated) return [];
    
    try {
      final client = http.Client();
      final request = http.Request('PROPFIND', Uri.parse('$_baseUrl/baby-growth-backup/'));
      request.headers.addAll({
        ..._getAuthHeaders(),
        'Depth': '1',
      });
      
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 207) {
        // 解析 WebDAV 响应
        return _parsePropfindResponse(response.body);
      }
      return [];
    } catch (e) {
      print('列出文件失败: $e');
      return [];
    }
  }
  
  /// 删除文件
  Future<bool> deleteFile(String remotePath) async {
    if (!isAuthenticated) return false;
    
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/baby-growth-backup/$remotePath'),
        headers: _getAuthHeaders(),
      );
      
      return response.statusCode == 204;
    } catch (e) {
      print('删除失败: $e');
      return false;
    }
  }
  
  /// 获取认证头
  Map<String, String> _getAuthHeaders() {
    final auth = base64Encode(utf8.encode('$_username:$_password'));
    return {
      'Authorization': 'Basic $auth',
    };
  }
  
  /// 创建目录
  Future<bool> _createDirectory(String dirName) async {
    try {
      final client = http.Client();
      final request = http.Request('MKCOL', Uri.parse('$_baseUrl/$dirName'));
      request.headers.addAll(_getAuthHeaders());
      
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      
      return response.statusCode == 201 || response.statusCode == 405; // 405 表示已存在
    } catch (e) {
      return false;
    }
  }
  
  /// 解析 PROPFIND 响应
  List<String> _parsePropfindResponse(String xml) {
    final files = <String>[];
    // 简单解析，提取文件名
    final regex = RegExp(r'<d:href>([^<]+)</d:href>');
    final matches = regex.allMatches(xml);
    for (final match in matches) {
      final path = match.group(1);
      if (path != null && path != '/baby-growth-backup/') {
        files.add(path.split('/').last);
      }
    }
    return files;
  }
}

/// 单例实例
final nutstoreService = NutstoreService();
