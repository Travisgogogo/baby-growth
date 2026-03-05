/// Paraformer 语音识别服务（占位符版本）
/// 
/// 语音识别功能暂时禁用
class ParaformerService {
  static final ParaformerService _instance = ParaformerService._internal();
  factory ParaformerService() => _instance;
  ParaformerService._internal();

  Future<void> initialize() async {
    // 暂时禁用
  }

  Future<String> recognize(List<int> audioData) async {
    return '';
  }

  void dispose() {}
}
