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
  DateTime? _recordStartTime;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    try {
      print('初始化录音器...');
      _recorder = FlutterSoundRecorder();
      
      // 请求录音权限
      final micStatus = await Permission.microphone.request();
      print('麦克风权限: $micStatus');
      
      if (micStatus != PermissionStatus.granted) {
        print('麦克风权限被拒绝');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎤 需要麦克风权限')),
          );
        }
        return;
      }

      // 请求存储权限
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.request();
        print('存储权限: $storageStatus');
      }
      
      // 打开录音器
      await _recorder!.openRecorder();
      _isRecorderReady = true;
      print('录音器初始化成功');
    } catch (e, stackTrace) {
      print('录音器初始化失败: $e');
      print('堆栈: $stackTrace');
    }
  }

  Future<void> _startRecording() async {
    if (_isProcessing || _recorder == null || !_isRecorderReady) {
      print('录音器未准备好: _isRecorderReady=$_isRecorderReady');
      if (!_isRecorderReady) {
        // 尝试重新初始化
        await _initRecorder();
      }
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // 使用 m4a 格式，百度 API 支持
      _audioPath = '${tempDir.path}/voice_record_$timestamp.m4a';

      print('开始录音: $_audioPath');
      print('录音参数: codec=aacMP4, sampleRate=16000, numChannels=1');
      
      await _recorder!.startRecorder(
        toFile: _audioPath,
        codec: Codec.aacMP4,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 48000,  // 百度推荐 48000
      );
      
      _recordStartTime = DateTime.now();
      print('录音已启动');
      setState(() => _isRecording = true);
    } catch (e, stackTrace) {
      print('开始录音错误: $e');
      print('堆栈: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🎤 录音启动失败: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _recorder == null) return;

    // 计算录音时长
    final recordDuration = _recordStartTime != null 
        ? DateTime.now().difference(_recordStartTime!).inMilliseconds 
        : 0;
    print('录音时长: $recordDuration ms');

    setState(() {
      _isRecording = false;
      _isProcessing = true;
    });

    try {
      print('停止录音...');
      final recordedPath = await _recorder!.stopRecorder();
      print('录音已停止，返回路径: $recordedPath');
      
      if (_audioPath != null) {
        final audioFile = File(_audioPath!);
        
        // 等待文件写入完成
        await Future.delayed(const Duration(milliseconds: 800));
        
        final fileExists = await audioFile.exists();
        final fileSize = fileExists ? await audioFile.length() : 0;
        print('文件存在: $fileExists, 文件大小: $fileSize 字节');
        
        if (fileExists && fileSize > 1000) {
          print('调用百度语音识别...');
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
          print('录音文件太小: $fileSize 字节');
          if (mounted) {
            String errorMsg = '录音时间太短';
            if (fileSize == 0) {
              errorMsg = '录音失败，请检查麦克风权限';
            } else if (recordDuration < 500) {
              errorMsg = '录音时间太短，请长按至少1秒';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('🎤 $errorMsg')),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      print('停止录音错误: $e');
      print('堆栈: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🎤 语音识别失败: $e')),
        );
      }
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
