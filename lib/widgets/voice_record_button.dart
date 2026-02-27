import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../services/baidu_voice_service.dart';
import '../services/nlp_parser.dart';

/// 语音记录按钮
/// 
/// 使用 flutter_sound 插件进行录音，并通过百度语音识别服务进行语音转文字
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
  FlutterSoundRecorder? _recorder;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();
    
    // 请求录音权限
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print('麦克风权限被拒绝');
      return;
    }
    
    // 打开录音器
    await _recorder!.openRecorder();
    print('录音器初始化成功');
  }

  Future<void> _startRecording() async {
    if (_isProcessing || _recorder == null) return;

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
        await Permission.storage.request();
      }

      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _audioPath = '${tempDir.path}/voice_record_$timestamp.wav';

      print('开始录音，保存到: $_audioPath');
      
      // 开始录音 - WAV 格式
      await _recorder!.startRecorder(
        toFile: _audioPath,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
      );
      
      print('录音已启动');

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
    if (!_isRecording || _recorder == null) return;

    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    try {
      print('停止录音...');
      // 停止录音
      await _recorder!.stopRecorder();
      print('录音已停止，文件路径: $_audioPath');
      
      if (_audioPath != null) {
        final audioFile = File(_audioPath!);
        
        // 等待文件写入完成
        await Future.delayed(const Duration(milliseconds: 500));
        
        final fileExists = await audioFile.exists();
        final fileSize = fileExists ? await audioFile.length() : 0;
        print('文件存在: $fileExists, 文件大小: $fileSize 字节');
        
        if (fileExists && fileSize > 0) {
          // 调用百度语音识别
          final baiduService = BaiduVoiceService();
          final result = await baiduService.recognize(audioFile);
          final recognizedText = result[0];
          final errorMsg = result[1];
          
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
            // 显示具体的错误信息
            if (mounted) {
              String displayError = errorMsg ?? "未能识别语音，请重试";
              if (fileSize == 0) {
                displayError = "录音文件为空，请检查麦克风权限";
              } else if (fileSize < 1000) {
                displayError = "录音时间太短，请长按说话按钮至少1秒";
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎤 $displayError'),
                  duration: const Duration(seconds: 3),
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
    _recorder?.closeRecorder();
    _recorder = null;
    super.dispose();
  }
}
