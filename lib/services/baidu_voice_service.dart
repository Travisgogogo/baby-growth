import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 百度语音识别服务
class BaiduVoiceService {
  static final BaiduVoiceService _instance = BaiduVoiceService._internal();
  factory BaiduVoiceService() => _instance;
  BaiduVoiceService._internal();

  // 百度 API 密钥
  static const String _apiKey = 'ds7dUbnap8IoZ3znZHM6LFk6';
  static const String _secretKey = 'pSXxSPbKZG7UK4Brc0WFPSqepA0OSoWm';
  
  String? _accessToken;
  
  /// 获取 Access Token
  Future<String?> _getAccessToken() async {
    if (_accessToken != null) return _accessToken!;
    
    try {
      final response = await http.post(
        Uri.parse(
          'https://aip.baidubce.com/oauth/2.0/token'
          '?grant_type=client_credentials'
          '&client_id=$_apiKey'
          '&client_secret=$_secretKey'
        ),
      );
      
      final result = jsonDecode(response.body);
      if (result['access_token'] != null) {
        _accessToken = result['access_token'];
        print('获取 Access Token 成功');
        return _accessToken!;
      } else {
        print('获取 Access Token 失败: ${result['error_description']}');
        return null;
      }
    } catch (e) {
      print('获取 Access Token 错误: $e');
      return null;
    }
  }
  
  /// 识别音频文件 - 使用 RAW 方式上传
  Future<List<String?>> recognize(File audioFile) async {
    try {
      // 检查文件
      if (!await audioFile.exists()) {
        return [null, '音频文件不存在'];
      }
      
      final fileSize = await audioFile.length();
      print('音频文件大小: $fileSize 字节');
      
      if (fileSize < 1000) {
        return [null, '录音时间太短，请长按说话按钮至少1秒'];
      }
      
      // 获取 Access Token
      final token = await _getAccessToken();
      if (token == null) {
        return [null, '无法获取百度语音服务授权'];
      }
      
      // 读取音频文件
      final bytes = await audioFile.readAsBytes();
      print('读取到的字节数: ${bytes.length}');
      
      if (bytes.isEmpty) {
        print('音频文件内容为空');
        return [null, '音频文件内容为空'];
      }
      
      print('音频前10字节: ${bytes.take(10).toList()}');
      
      // 判断格式
      final fileName = audioFile.path.toLowerCase();
      String contentType;
      if (fileName.endsWith('.wav')) {
        contentType = 'audio/wav;rate=16000';
      } else if (fileName.endsWith('.m4a')) {
        contentType = 'audio/m4a;rate=16000';
      } else if (fileName.endsWith('.amr')) {
        contentType = 'audio/amr;rate=16000';
      } else {
        contentType = 'audio/pcm;rate=16000';
      }
      
      print('使用 RAW 方式上传，Content-Type: $contentType, 数据大小: ${bytes.length}');
      
      // 使用 RAW 方式上传 - 参数放在 URL 中
      final response = await http.post(
        Uri.parse(
          'https://vop.baidu.com/server_api'
          '?dev_pid=1537'
          '&cuid=flutter_app'
          '&token=$token'
        ),
        headers: {
          'Content-Type': contentType,
        },
        body: bytes,  // 直接发送二进制数据
      );
      
      print('响应状态码: ${response.statusCode}');
      final result = jsonDecode(response.body);
      print('百度语音识别结果: $result');
      
      // 解析结果
      if (result['err_no'] == 0) {
        final texts = result['result'] as List<dynamic>?;
        if (texts != null && texts.isNotEmpty) {
          return [texts.first.toString(), null];
        } else {
          return [null, '未能识别到语音内容'];
        }
      } else {
        final errMsg = result['err_msg'] ?? '未知错误';
        final errNo = result['err_no'];
        print('识别错误: $errMsg (错误码: $errNo)');
        
        // 根据错误码返回友好提示
        String userError;
        switch (errNo) {
          case 3300:
            userError = '音频格式错误';
            break;
          case 3301:
            userError = '音频质量不佳，请说话更清晰';
            break;
          case 3302:
            userError = '授权验证失败';
            break;
          case 3303:
            userError = '请求过于频繁，请稍后再试';
            break;
          case 3304:
            userError = '音频文件过大';
            break;
          case 3305:
            userError = '音频时长过长';
            break;
          case 3307:
            userError = '未检测到语音，请说话声音大一些';
            break;
          case 3308:
            userError = '音频文件为空';
            break;
          default:
            userError = '识别失败: $errMsg';
        }
        return [null, userError];
      }
    } catch (e, stackTrace) {
      print('语音识别错误: $e');
      print('堆栈: $stackTrace');
      return [null, '识别出错: $e'];
    }
  }
}
