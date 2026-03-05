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
  Future<String> _getAccessToken() async {
    if (_accessToken != null) return _accessToken!;
    
    final response = await http.post(
      Uri.parse(
        'https://aip.baidubce.com/oauth/2.0/token'
        '?grant_type=client_credentials'
        '&client_id=$_apiKey'
        '&client_secret=$_secretKey'
      ),
    );
    
    final result = jsonDecode(response.body);
    _accessToken = result['access_token'];
    return _accessToken!;
  }
  
  /// 识别音频文件
  /// [audioFile]: PCM 16kHz, 16bit, 单声道音频文件
  Future<String?> recognize(File audioFile) async {
    try {
      final token = await _getAccessToken();
      
      // 读取音频文件并转为 base64
      final bytes = await audioFile.readAsBytes();
      final base64Audio = base64Encode(bytes);
      
      // 发送识别请求
      final response = await http.post(
        Uri.parse(
          'https://vop.baidu.com/server_api'
          '?dev_pid=1537' // 普通话(纯中文识别)
          '&cuid=flutter_app'
          '&token=$token'
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'format': 'pcm',
          'rate': 16000,
          'channel': 1,
          'cuid': 'flutter_app',
          'token': token,
          'speech': base64Audio,
          'len': bytes.length,
        }),
      );
      
      final result = jsonDecode(response.body);
      
      // 解析结果
      if (result['err_no'] == 0) {
        final texts = result['result'] as List<dynamic>?;
        if (texts != null && texts.isNotEmpty) {
          return texts.first.toString();
        }
      } else {
        print('百度识别错误: ${result['err_msg']}');
      }
      
      return null;
    } catch (e) {
      print('语音识别错误: $e');
      return null;
    }
  }
}