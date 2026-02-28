import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 坚果云 WebDAV 服务
class NutstoreService {
  static const String _baseUrl = 'https://dav.jianguoyun.com/dav';
  
  String? _username;
  String? _password;
  
  /// 设置认证信息
  void setCredentials(String username, String password) {
    _username = username.trim();
    _password = password.trim();
  }
  
  /// 检查是否已设置认证
  bool get isAuthenticated => _username != null && _password != null;
  
  /// 获取认证头
  Map<String, String> _getAuthHeaders() {
    final auth = base64Encode(utf8.encode('$_username:$_password'));
    return {
      'Authorization': 'Basic $auth',
    };
  }
  
  /// 测试连接 - 返回详细错误信息
  Future<Map<String, dynamic>> testConnectionWithDetails() async {
    if (!isAuthenticated) {
      return {'success': false, 'error': '未设置认证信息'};
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/'),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 207 || response.statusCode == 200) {
        return {'success': true, 'error': null};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': '认证失败：用户名或密码错误'};
      } else {
        return {'success': false, 'error': '服务器返回错误：${response.statusCode}'};
      }
    } on SocketException catch (e) {
      return {'success': false, 'error': '网络连接失败，请检查网络权限'};
    } on FormatException catch (e) {
      return {'success': false, 'error': '响应格式错误：$e'};
    } catch (e) {
      return {'success': false, 'error': '连接失败：$e'};
    }
  }
  
  /// 测试连接（兼容旧接口）
  Future<bool> testConnection() async {
    final result = await testConnectionWithDetails();
    return result['success'] as bool;
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
      ).timeout(const Duration(seconds: 30));
      
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
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      print('下载失败: $e');
      return null;
    }
  }
  
  /// 创建目录
  Future<bool> _createDirectory(String dirName) async {
    try {
      // 使用 http Client 发送 MKCOL 请求
      final client = http.Client();
      final request = http.Request('MKCOL', Uri.parse('$_baseUrl/$dirName'));
      request.headers.addAll(_getAuthHeaders());
      
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      
      // 201 创建成功，405 目录已存在
      return response.statusCode == 201 || response.statusCode == 405;
    } catch (e) {
      print('创建目录失败: $e');
      return false;
    }
  }
}

/// 单例实例
final nutstoreService = NutstoreService();
