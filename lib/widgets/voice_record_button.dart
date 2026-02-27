import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../services/baidu_voice_service.dart';
import '../services/nlp_parser.dart';

/// 语音记录按钮
/// 
/// 使用 record 插件进行录音，并通过百度语音识别服务进行语音转文字
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
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _audioPath;

  Future<void> _startRecording() async {
    if (_isProcessing) return;

    try {
      // 请求录音权限
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎤 需要麦克风权限才能使用语音功能'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // 请求存储权限（Android 需要）
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.request();
        // 某些 Android 版本需要管理外部存储权限
        if (storageStatus != PermissionStatus.granted) {
          // 尝试请求管理外部存储权限（Android 11+）
          await Permission.manageExternalStorage.request();
        }
      }

      // 检查录音器是否可用
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎤 没有录音权限'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _audioPath = '${tempDir.path}/voice_record_$timestamp.wav';

      // 配置录音参数 - 使用 WAV 格式，16kHz，16bit，单声道
      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      );

      // 开始录音
      await _audioRecorder.start(config, path: _audioPath!);

      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('开始录音错误: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎤 录音启动失败: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    try {
      // 停止录音
      final path = await _audioRecorder.stop();
      
      if (path != null && _audioPath != null) {
        final audioFile = File(_audioPath!);
        
        if (await audioFile.exists()) {
          // 调用百度语音识别
          final baiduService = BaiduVoiceService();
          final recognizedText = await baiduService.recognize(audioFile);
          
          if (recognizedText != null && recognizedText.isNotEmpty) {
            // 解析语音文本
            final parsedResult = NLPParser.parse(recognizedText);
            
            if (mounted) {
              if (parsedResult != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎤 识别到: "$recognizedText"'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎤 识别到: "$recognizedText"，但未能解析'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              
              // 返回解析结果
              widget.onResult(parsedResult);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🎤 未能识别语音，请重试'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
          
          // 清理临时文件
          try {
            await audioFile.delete();
          } catch (e) {
            print('删除临时文件失败: $e');
          }
        }
      }
    } catch (e) {
      print('停止录音错误: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎤 语音识别失败: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
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
    // 清理录音器资源
    _audioRecorder.dispose();
    super.dispose();
  }
}
