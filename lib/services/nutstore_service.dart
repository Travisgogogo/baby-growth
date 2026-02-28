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
      'Content-Type': 'application/xml',
    };
  }
  
  /// 测试连接 - 使用简单的 GET 请求测试根目录
  Future<bool> testConnection() async {
    if (!isAuthenticated) {
      print('未设置认证信息');
      return false;
    }
    
    print('测试连接: $_baseUrl/');
    print('用户名: $_username');
    
    try {
      // 使用 http 包的 get 方法测试
      final response = await http.get(
        Uri.parse('$_baseUrl/'),
        headers: _getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));
      
      print('响应状态码: ${response.statusCode}');
      
      // 207 是 WebDAV 成功状态码，401 是认证失败
      if (response.statusCode == 207 || response.statusCode == 200) {
        print('连接成功');
        return true;
      } else if (response.statusCode == 401) {
        print('认证失败: 用户名或密码错误');
        return false;
      } else {
        print('连接失败: ${response.statusCode}');
        print('响应: ${response.body}');
        return false;
      }
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
