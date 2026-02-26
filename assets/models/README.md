# Paraformer 模型下载说明

## 模型文件
- **文件名**: paraformer-zh-tiny.onnx
- **大小**: 约 27MB
- **格式**: ONNX

## 下载地址

### 方式1: HuggingFace (官方)
```bash
curl -L -o paraformer-zh-tiny.onnx \
  "https://huggingface.co/csukuangfj/sherpa-onnx-paraformer-zh-2023-09-14/resolve/main/model.onnx"
```

### 方式2: GitHub Release
```bash
wget -O sherpa-onnx-paraformer-zh-2023-09-14.tar.bz2 \
  "https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-paraformer-zh-2023-09-14.tar.bz2"
tar -xjf sherpa-onnx-paraformer-zh-2023-09-14.tar.bz2
cp sherpa-onnx-paraformer-zh-2023-09-14/model.onnx paraformer-zh-tiny.onnx
```

### 方式3: 手动下载
1. 访问 https://huggingface.co/csukuangfj/sherpa-onnx-paraformer-zh-2023-09-14
2. 点击 "Files and versions"
3. 下载 model.onnx
4. 重命名为 paraformer-zh-tiny.onnx
5. 放到 assets/models/ 目录

## 放置位置
```
assets/models/
└── paraformer-zh-tiny.onnx
```

## 验证
文件大小应该约为 27MB。
