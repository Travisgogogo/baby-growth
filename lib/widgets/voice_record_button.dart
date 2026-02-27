import 'dart:io';
import 'package:flutter/material.dart';
import '../services/baidu_voice_service.dart';
import '../services/nlp_parser.dart';

/// 语音记录按钮
/// 
/// 注意：语音识别功能暂时禁用，因为 record_android 插件使用 Kotlin sealed classes
/// 导致 Android 构建失败。需要升级 AGP 到 8.2+ 才能支持。
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
  bool _isRecording = false;
  bool _isProcessing = false;

  Future<void> _startRecording() async {
    // 语音功能暂时禁用
    _showFeatureDisabled();
  }

  Future<void> _stopRecording() async {
    // 语音功能暂时禁用
  }

  void _showFeatureDisabled() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎤 语音识别功能暂时禁用，请使用手动输入'),
        duration: Duration(seconds: 2),
      ),
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
                  : Colors.grey.shade400, // 禁用状态显示灰色
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isProcessing
              ? Icons.hourglass_top
              : _isRecording
                  ? Icons.mic
                  : Icons.mic_off, // 禁用状态显示 mic_off
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
