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
      // 坚果云 WebDAV 需要使用 PROPFIND 方法测试根目录
      final client = http.Client();
      final request = http.Request('PROPFIND', Uri.parse('$_baseUrl/'));
      request.headers.addAll({
        ..._getAuthHeaders(),
        'Depth': '0',
      });
      
      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 10));
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 207 || response.statusCode == 200) {
        return {'success': true, 'error': null};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': '认证失败：用户名或密码错误'};
      } else if (response.statusCode == 403) {
        return {'success': false, 'error': '403 禁止访问：请确认应用密码有 WebDAV 权限'};
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
  
  /// 列出备份文件
  Future<List<Map<String, dynamic>>> listBackupFiles() async {
    if (!isAuthenticated) return [];
    
    try {
      final client = http.Client();
      final request = http.Request('PROPFIND', Uri.parse('$_baseUrl/baby-growth-backup/'));
      request.headers.addAll({
        ..._getAuthHeaders(),
        'Depth': '1',
      });
      
      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 10));
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 207) {
        // 解析 WebDAV 响应
        return _parseWebDAVResponse(response.body);
      }
      return [];
    } catch (e) {
      print('列出文件失败: $e');
      return [];
    }
  }
  
  /// 解析 WebDAV PROPFIND 响应
  List<Map<String, dynamic>> _parseWebDAVResponse(String xmlBody) {
    final files = <Map<String, dynamic>>[];
    
    // 简单的正则解析，提取文件名和修改时间
    final responseRegex = RegExp(r'<response>(.*?)</response>', dotAll: true);
    final hrefRegex = RegExp(r'<href>(.*?)</href>');
    final displayNameRegex = RegExp(r'<displayname>(.*?)</displayname>');
    final lastModifiedRegex = RegExp(r'<getlastmodified>(.*?)</getlastmodified>');
    final contentLengthRegex = RegExp(r'<getcontentlength>(.*?)</getcontentlength>');
    
    for (final match in responseRegex.allMatches(xmlBody)) {
      final responseBlock = match.group(1) ?? '';
      final href = hrefRegex.firstMatch(responseBlock)?.group(1) ?? '';
      final displayName = displayNameRegex.firstMatch(responseBlock)?.group(1) ?? '';
      final lastModified = lastModifiedRegex.firstMatch(responseBlock)?.group(1) ?? '';
      final contentLength = contentLengthRegex.firstMatch(responseBlock)?.group(1) ?? '0';
      
      // 跳过目录本身
      if (displayName.isEmpty || displayName == 'baby-growth-backup') continue;
      
      files.add({
        'href': href,
        'name': displayName,
        'lastModified': lastModified,
        'size': int.tryParse(contentLength) ?? 0,
      });
    }
    
    // 按修改时间倒序排列
    files.sort((a, b) => (b['lastModified'] ?? '').compareTo(a['lastModified'] ?? ''));
    
    return files;
  }
  
  /// 删除文件
  Future<bool> deleteFile(String remotePath) async {
    if (!isAuthenticated) return false;
    
    try {
      final client = http.Client();
      final request = http.Request('DELETE', Uri.parse('$_baseUrl/baby-growth-backup/$remotePath'));
      request.headers.addAll(_getAuthHeaders());
      
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('删除文件失败: $e');
      return false;
    }
  }
}

/// 单例实例
final nutstoreService = NutstoreService();
