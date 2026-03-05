import 'package:flutter/material.dart';

/// 语音记录按钮（占位符版本）
/// 
/// 语音识别功能暂时禁用，因为 record 插件导致 CI 构建失败
class VoiceRecordButton extends StatelessWidget {
  final Function(dynamic)? onResult;

  const VoiceRecordButton({
    super.key,
    this.onResult,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎤 语音功能暂时不可用'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.mic_off,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
