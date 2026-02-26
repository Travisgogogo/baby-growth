# Baby Growth App 👶

宝宝成长记录 App - 记录宝宝成长的每一个瞬间

[![Build Status](https://github.com/Travisgogogo/baby-growth/actions/workflows/build.yml/badge.svg)](https://github.com/Travisgogogo/baby-growth/actions)

## 📱 功能特性

### 核心功能
- 📊 **生长曲线** - 记录身高、体重、头围，可视化生长趋势
- 🍼 **喂养记录** - 母乳、配方奶、辅食记录，追踪喂养规律
- 😴 **睡眠记录** - 记录睡眠时长和质量，培养良好作息
- 💩 **排泄记录** - 大小便记录，关注宝宝健康
- 🎯 **发育里程碑** - 23个关键里程碑，追踪发育进度
- 💉 **疫苗接种** - 22种疫苗接种计划，按时提醒
- 🏥 **健康记录** - 疾病、用药记录，健康管理

### 数据管理
- 💾 **本地存储** - SQLite 数据库，数据安全不丢失
- 📤 **数据备份** - 一键备份所有记录
- 📥 **数据恢复** - 支持从备份恢复数据

## 🛠 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Flutter | 3.24.0 | 跨平台 UI 框架 |
| Dart | 3.x | 编程语言 |
| SQLite | - | 本地数据存储 |
| sqflite | ^2.3.0 | SQLite Flutter 插件 |
| fl_chart | ^0.66.0 | 图表可视化 |

## 📁 项目结构

```
lib/
├── constants/          # 常量定义
│   ├── app_theme.dart      # 主题色、文本样式
│   ├── milestone_data.dart # 里程碑数据
│   └── vaccine_data.dart   # 疫苗数据
├── models/             # 数据模型
│   ├── baby.dart
│   ├── feed_record.dart
│   ├── growth_record.dart
│   ├── sleep_record.dart
│   ├── diaper_record.dart
│   ├── milestone_record.dart
│   ├── illness_record.dart
│   ├── vaccine_record.dart
│   └── photo.dart
├── screens/            # 页面
│   ├── home_screen.dart
│   ├── growth_chart_screen.dart
│   ├── records_screen.dart
│   ├── milestones_screen.dart
│   ├── health_screen.dart
│   └── profile_screen.dart
├── services/           # 服务层
│   └── database_service.dart
├── widgets/            # 组件
│   └── confirm_dialog.dart
└── main.dart
```

## 🚀 快速开始

### 环境要求
- Flutter SDK >= 3.24.0
- Dart SDK >= 3.0.0
- Android SDK (构建 APK)
- Xcode (构建 iOS)

### 安装依赖
```bash
flutter pub get
```

### 运行开发版本
```bash
flutter run
```

### 构建发布版本

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📊 数据库结构

### 表结构

| 表名 | 说明 |
|------|------|
| babies | 宝宝基本信息 |
| growth_records | 生长记录（身高、体重、头围） |
| feed_records | 喂养记录 |
| sleep_records | 睡眠记录 |
| diaper_records | 排泄记录 |
| milestone_records | 里程碑完成记录 |
| illness_records | 疾病记录 |
| vaccine_records | 疫苗接种记录 |
| photos | 照片记录 |

### 数据库版本
- 当前版本: v2
- 升级策略: onUpgrade 回调处理迁移

## 🔄 CI/CD

使用 GitHub Actions 自动构建：

- **触发条件**: push 到 main 分支
- **构建目标**: Android APK + iOS
- **Flutter 版本**: 3.24.0
- **构建产物**: 自动上传到 Artifacts

查看构建状态: [GitHub Actions](https://github.com/Travisgogogo/baby-growth/actions)

## 📝 更新日志

### 2026-02-26
- ✅ 修复首次安装无限转圈问题
- ✅ 添加数据库错误处理
- ✅ 修复空安全问题
- ✅ 提取硬编码数据到常量
- ✅ 添加主题常量系统

### 2026-02-25
- ✅ 实现数据持久化
- ✅ 添加生长曲线图表
- ✅ 实现喂养、睡眠、排泄记录
- ✅ 添加里程碑追踪
- ✅ 添加疫苗接种计划

## 🐛 已知问题

- [ ] 数据库版本管理需要更完善
- [ ] 需要添加单元测试
- [ ] 里程碑和疫苗定义考虑可配置化

## 🔮 未来计划

- [ ] 数据导出/导入功能
- [ ] 云端同步
- [ ] 多宝宝支持
- [ ] 国际化支持
- [ ] 推送提醒

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request!

---

Made with ❤️ for babies
