# Paraformer 语音识别实现方案

## 模型信息
- **模型**: Paraformer-zh tiny
- **大小**: 27MB
- **语言**: 中文优化
- **格式**: ONNX

## 实现步骤

### 1. 添加依赖
```yaml
dependencies:
  onnxruntime: ^1.4.0
  permission_handler: ^11.3.0
  path_provider: ^2.1.2
  record: ^5.0.4
```

### 2. 下载模型
- 模型文件: paraformer-zh-tiny.onnx
- 放置位置: assets/models/

### 3. 核心功能
- 录音 (PCM 16kHz, 16bit, 单声道)
- ONNX 推理
- 文本后处理
- NLP 解析

### 4. UI 组件
- 语音按钮 (按住录音)
- 波形动画
- 识别结果确认对话框
