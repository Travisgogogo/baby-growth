import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isRecorderReady = false;
  FlutterSoundRecorder? _recorder;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    try {
      _recorder = FlutterSoundRecorder();
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print('麦克风权限被拒绝');
        return;
      }
      await _recorder!.openRecorder();
      _isRecorderReady = true;
      print('录音器初始化成功');
    } catch (e) {
      print('录音器初始化失败: $e');
    }
  }

  Future<void> _startRecording() async {
    if (_isProcessing || _recorder == null || !_isRecorderReady) {
      print('录音器未准备好');
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // 使用 m4a 格式，百度 API 支持
      _audioPath = '${tempDir.path}/voice_record_$timestamp.m4a';

      print('开始录音: $_audioPath');
      
      await _recorder!.startRecorder(
        toFile: _audioPath,
        codec: Codec.aacMP4,  // m4a 格式，百度支持
        sampleRate: 16000,
        numChannels: 1,
      );
      
      print('录音已启动');
      setState(() => _isRecording = true);
    } catch (e) {
      print('开始录音错误: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _recorder == null) return;

    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    try {
      print('停止录音...');
      await _recorder!.stopRecorder();
      
      if (_audioPath != null) {
        final audioFile = File(_audioPath!);
        await Future.delayed(const Duration(milliseconds: 500));
        
        final fileSize = await audioFile.length();
        print('文件大小: $fileSize 字节');
        
        if (fileSize > 100) {
          final baiduService = BaiduVoiceService();
          final result = await baiduService.recognize(audioFile);
          final recognizedText = result[0];
          final errorMsg = result[1];
          
          if (recognizedText != null && recognizedText.isNotEmpty) {
            final parsedResult = NLPParser.parse(recognizedText);
            if (mounted) {
              widget.onResult(parsedResult);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🎤 ${errorMsg ?? "未能识别语音"}')),
              );
            }
          }
          await audioFile.delete();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🎤 录音时间太短')),
            );
          }
        }
      }
    } catch (e) {
      print('停止录音错误: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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
          color: _isProcessing ? Colors.grey : (_isRecording ? Colors.red : Theme.of(context).primaryColor),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isProcessing ? Icons.hourglass_top : (_isRecording ? Icons.mic : Icons.mic_none),
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    super.dispose();
  }
}
