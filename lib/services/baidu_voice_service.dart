import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
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
  
  /// 识别音频文件
  /// [audioFile]: WAV 音频文件 (flutter_sound 生成的是 WAV 格式)
  /// 返回: [识别文本, 错误信息] - 如果识别成功，错误信息为null；如果失败，识别文本为null
  Future<List<String?>> recognize(File audioFile) async {
    try {
      // 检查文件是否存在和大小
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
      
      // 读取音频文件 (WAV 格式)
      final bytes = await audioFile.readAsBytes();
      
      // 转为 base64
      final base64Audio = base64Encode(bytes);
      print('Base64 编码后大小: ${base64Audio.length} 字符');
      
      // 发送识别请求 - 使用 wav 格式
      print('正在发送识别请求...');
      final response = await http.post(
        Uri.parse(
          'https://vop.baidu.com/server_api'
          '?dev_pid=1537' // 普通话(纯中文识别)
          '&cuid=flutter_app'
          '&token=$token'
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'format': 'wav',
          'rate': 16000,
          'channel': 1,
          'cuid': 'flutter_app',
          'token': token,
          'speech': base64Audio,
          'len': bytes.length,
        }),
      );
      
      print('收到响应，状态码: ${response.statusCode}');
      final result = jsonDecode(response.body);
      print('百度语音识别结果: $result');
      
      // 解析结果
      if (result['err_no'] == 0) {
        final texts = result['result'] as List<dynamic>?;
        if (texts != null && texts.isNotEmpty) {
          final text = texts.first.toString();
          print('识别成功: $text');
          return [text, null];
        } else {
          return [null, '未能识别到语音内容，请尝试说话更清晰']; 
        }
      } else {
        final errMsg = result['err_msg'] ?? '未知错误';
        final errNo = result['err_no'];
        print('百度识别错误: $errMsg (错误码: $errNo)');
        
        // 根据错误码返回友好的错误信息
        String userFriendlyError;
        switch (errNo) {
          case 3300:
            userFriendlyError = '音频格式错误，请重试';
            break;
          case 3301:
            userFriendlyError = '音频质量不佳，请说话更清晰';
            break;
          case 3302:
            userFriendlyError = '授权验证失败，请检查网络';
            break;
          case 3303:
            userFriendlyError = '请求过于频繁，请稍后再试';
            break;
          case 3304:
            userFriendlyError = '音频文件过大';
            break;
          case 3305:
            userFriendlyError = '音频时长过长';
            break;
          case 3307:
            userFriendlyError = '未检测到语音，请说话声音大一些';
            break;
          case 3308:
            userFriendlyError = '音频文件为空';
            break;
          default:
            userFriendlyError = '识别失败: $errMsg';
        }
        return [null, userFriendlyError];
      }
    } catch (e, stackTrace) {
      print('语音识别错误: $e');
      print('堆栈: $stackTrace');
      return [null, '识别出错: $e'];
    }
  }
}
