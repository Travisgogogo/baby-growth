import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../services/baidu_voice_service.dart';
import '../services/nlp_parser.dart';

/// 语音记录按钮
class VoiceRecordButton extends StatefulWidget {
  final Function(ParsedRecord?) onResult;

  const VoiceRecordButton({
    super.key,
    required this.onResult,
  });

  @override
  State<VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<VoiceRecordButton> {
  final _audioRecorder = AudioRecorder();
  final _voiceService = BaiduVoiceService();
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _recordPath;

  @override
  void initState() {
    super.initState();
    // 百度服务无需预初始化
  }

  Future<void> _startRecording() async {
    try {
      // 检查权限
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要录音权限')),
        );
        return;
      }

      // 创建临时文件
      final dir = await getTemporaryDirectory();
      _recordPath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.pcm';

      // 开始录音 (PCM 16kHz, 16bit, 单声道)
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _recordPath!,
      );

      setState(() => _isRecording = true);
    } catch (e) {
      print('录音启动失败: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      setState(() => _isRecording = false);

      // 停止录音
      final path = await _audioRecorder.stop();
      if (path == null) return;

      setState(() => _isProcessing = true);

      // 读取音频文件
      final audioFile = File(path);

      // 语音识别（百度API）
      final text = await _voiceService.recognize(audioFile);

      setState(() => _isProcessing = false);

      if (text.isEmpty) {
        _showError('识别失败，请重试');
        return;
      }

      // NLP 解析
      final record = NLPParser.parse(text);

      // 显示确认对话框
      _showConfirmDialog(text, record);
    } catch (e) {
      setState(() => _isProcessing = false);
      print('录音处理失败: $e');
      _showError('处理失败，请重试');
    }
  }

  void _showConfirmDialog(String text, ParsedRecord? record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎤 识别结果'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('识别文本: $text'),
            const SizedBox(height: 16),
            if (record != null) ...[
              Text('类型: ${_getTypeName(record.type)}'),
              Text('数据: ${record.data}'),
            ] else
              const Text('⚠️ 无法理解，请换种说法'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          if (record != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onResult(record);
              },
              child: const Text('确认保存'),
            ),
        ],
      ),
    );
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'feed':
        return '喂奶';
      case 'sleep':
        return '睡眠';
      case 'diaper':
        return '换尿布';
      case 'growth':
        return '生长记录';
      default:
        return '未知';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startRecording(),
      onTapUp: (_) => _stopRecording(),
      onTapCancel: () => _stopRecording(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(_isRecording ? 24 : 16),
        decoration: BoxDecoration(
          color: _isProcessing
              ? Colors.grey
              : _isRecording
                  ? Colors.red
                  : Theme.of(context).primaryColor,
          shape: BoxShape.circle,
          boxShadow: _isRecording
              ? [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ]
              : null,
        ),
        child: Icon(
          _isProcessing
              ? Icons.hourglass_top
              : _isRecording
                  ? Icons.mic
                  : Icons.mic_none,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
}