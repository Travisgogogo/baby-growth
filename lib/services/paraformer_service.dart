import 'dart:typed_data';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Paraformer 语音识别服务
class ParaformerService {
  static final ParaformerService _instance = ParaformerService._internal();
  factory ParaformerService() => _instance;
  ParaformerService._internal();

  OrtSession? _session;
  bool _isInitialized = false;

  /// 初始化模型
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 加载模型文件
      final modelData = await rootBundle.load('assets/models/paraformer-zh-tiny.onnx');
      final modelBytes = modelData.buffer.asUint8List();

      // 创建 ONNX 会话
      final sessionOptions = OrtSessionOptions();
      _session = OrtSession.fromBuffer(modelBytes, sessionOptions);

      _isInitialized = true;
      print('Paraformer 模型加载成功');
    } catch (e) {
      print('Paraformer 模型加载失败: $e');
      rethrow;
    }
  }

  /// 识别音频数据
  /// [audioData]: PCM 16kHz, 16bit, 单声道音频数据
  Future<String> recognize(Uint8List audioData) async {
    if (!_isInitialized || _session == null) {
      throw Exception('模型未初始化');
    }

    try {
      // 将音频数据转换为 float32 数组
      final audioFloat = _convertToFloat32(audioData);

      // 创建输入张量
      final inputShape = [1, audioFloat.length];
      final inputTensor = OrtValueTensor.createTensor(audioFloat, inputShape);

      // 运行推理
      final inputs = {'input': inputTensor};
      final outputs = await _session!.run(inputs);

      // 获取输出
      final outputTensor = outputs[0] as OrtValueTensor;
      final outputData = outputTensor.data as List<List<int>>;

      // 解码为文本
      final text = _decodeOutput(outputData);

      // 释放资源
      inputTensor.release();
      outputTensor.release();

      return text;
    } catch (e) {
      print('识别失败: $e');
      return '';
    }
  }

  /// 将 PCM 16bit 数据转换为 float32
  List<double> _convertToFloat32(Uint8List pcmData) {
    final result = <double>[];
    final byteData = ByteData.sublistView(pcmData);

    for (var i = 0; i < pcmData.length; i += 2) {
      final sample = byteData.getInt16(i, Endian.little);
      // 归一化到 [-1, 1]
      result.add(sample / 32768.0);
    }

    return result;
  }

  /// 解码模型输出为文本
  String _decodeOutput(List<List<int>> output) {
    // 简化的解码逻辑
    // 实际实现需要根据模型的 token 映射表
    final buffer = StringBuffer();
    for (final token in output[0]) {
      if (token == 0) break; // 结束符
      final char = _tokenToChar(token);
      if (char != null) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Token ID 转字符 (简化版)
  String? _tokenToChar(int token) {
    // 实际实现需要完整的词典映射
    // 这里使用简化逻辑
    if (token >= 0 && token < _vocab.length) {
      return _vocab[token];
    }
    return null;
  }

  /// 简化词典 (实际需要完整的中文词典)
  static const List<String> _vocab = [
    '<blank>', '<unk>', '奶', '粉', '母', '乳', '喂', '吃', '喝',
    '睡', '觉', '小', '时', '分', '钟', '尿', '布', '换', '大',
    '便', '体', '重', '身', '高', '量', '了', '宝', '宝', '刚',
    '才', '一', '二', '三', '四', '五', '六', '七', '八', '九',
    '十', '百', '毫', '升', '厘', '米', '公', '斤', '克',
  ];

  /// 释放资源
  void dispose() {
    _session?.release();
    _session = null;
    _isInitialized = false;
  }
}