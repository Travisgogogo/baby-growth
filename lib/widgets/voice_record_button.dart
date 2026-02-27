import 'package:flutter/material.dart';

/// 语音记录按钮 (禁用版本)
/// 
/// 由于 record 和 permission_handler 插件导致 CI 构建失败，
/// 暂时禁用语音功能，使用占位按钮替代。
class VoiceRecordButton extends StatefulWidget {
  final Function(dynamic)? onResult;

  const VoiceRecordButton({
    super.key,
    this.onResult,
  });

  @override
  State<VoiceRecordButton> createState() => _VoiceRecordButtonState();
}

class _VoiceRecordButtonState extends State<VoiceRecordButton> {
  bool _isRecording = false;
  bool _isProcessing = false;

  Future<void> _showDisabledMessage() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎤 语音功能暂时禁用，请手动输入记录'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isRecording = true),
      onTapUp: (_) {
        setState(() => _isRecording = false);
        _showDisabledMessage();
      },
      onTapCancel: () => setState(() => _isRecording = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(_isRecording ? 24 : 16),
        decoration: BoxDecoration(
          color: _isProcessing
              ? Colors.grey
              : _isRecording
                  ? Colors.red
                  : Colors.grey[400], // 禁用状态使用灰色
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isProcessing
              ? Icons.hourglass_top
              : _isRecording
                  ? Icons.mic
                  : Icons.mic_off, // 禁用状态使用 mic_off 图标
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
