import 'dart:io';
import 'package:flutter/material.dart';

/// 解析结果
class ParsedRecord {
  final String type; // feed, sleep, diaper, growth
  final Map<String, dynamic> data;

  ParsedRecord({required this.type, required this.data});
}

/// NLP 解析服务
class NLPParser {
  /// 解析语音文本
  static ParsedRecord? parse(String text) {
    final lowerText = text.toLowerCase();

    // 喂养记录
    if (_containsAny(lowerText, ['奶', '喝', '吃', '喂', 'ml', '毫升'])) {
      return _parseFeed(text);
    }

    // 睡眠记录
    if (_containsAny(lowerText, ['睡', '觉', '小时', '分钟'])) {
      return _parseSleep(text);
    }

    // 换尿布
    if (_containsAny(lowerText, ['尿布', '尿', '拉', '臭', '便便'])) {
      return _parseDiaper(text);
    }

    // 生长记录
    if (_containsAny(lowerText, ['体重', '身高', '量', '称', 'kg', 'cm'])) {
      return _parseGrowth(text);
    }

    return null;
  }

  /// 解析喂养记录
  static ParsedRecord? _parseFeed(String text) {
    // 提取奶量
    final amountRegex = RegExp(r'(\d+)\s*(ml|毫升|m)');
    final amountMatch = amountRegex.firstMatch(text);
    final amount = amountMatch != null
        ? double.tryParse(amountMatch.group(1) ?? '')
        : null;

    // 判断喂养类型
    String type = '母乳';
    if (text.contains('奶粉') || text.contains('配方')) {
      type = '奶粉';
    } else if (text.contains('辅食')) {
      type = '辅食';
    }

    return ParsedRecord(
      type: 'feed',
      data: {
        'type': type,
        'amount': amount,
        'time': DateTime.now(),
      },
    );
  }

  /// 解析睡眠记录
  static ParsedRecord? _parseSleep(String text) {
    // 提取时长
    final hourRegex = RegExp(r'(\d+)\s*小时');
    final minuteRegex = RegExp(r'(\d+)\s*分钟');

    int durationMinutes = 0;

    final hourMatch = hourRegex.firstMatch(text);
    if (hourMatch != null) {
      durationMinutes +=
          (int.tryParse(hourMatch.group(1) ?? '0') ?? 0) * 60;
    }

    final minuteMatch = minuteRegex.firstMatch(text);
    if (minuteMatch != null) {
      durationMinutes += int.tryParse(minuteMatch.group(1) ?? '0') ?? 0;
    }

    if (durationMinutes == 0) return null;

    return ParsedRecord(
      type: 'sleep',
      data: {
        'duration': durationMinutes,
        'startTime': DateTime.now()
            .subtract(Duration(minutes: durationMinutes)),
        'endTime': DateTime.now(),
      },
    );
  }

  /// 解析换尿布
  static ParsedRecord? _parseDiaper(String text) {
    String type = '尿';
    if (text.contains('臭') || text.contains('便') || text.contains('屎')) {
      type = '大便';
    } else if (text.contains('both') || text.contains('都')) {
      type = '大小便';
    }

    return ParsedRecord(
      type: 'diaper',
      data: {
        'type': type,
        'time': DateTime.now(),
      },
    );
  }

  /// 解析生长记录
  static ParsedRecord? _parseGrowth(String text) {
    // 提取体重
    final weightRegex = RegExp(r'体重.*?(\d+\.?\d*)\s*(kg|千克|公斤)');
    final weightMatch = weightRegex.firstMatch(text);
    final weight = weightMatch != null
        ? double.tryParse(weightMatch.group(1) ?? '')
        : null;

    // 提取身高
    final heightRegex = RegExp(r'身高.*?(\d+\.?\d*)\s*(cm|厘米)');
    final heightMatch = heightRegex.firstMatch(text);
    final height = heightMatch != null
        ? double.tryParse(heightMatch.group(1) ?? '')
        : null;

    if (weight == null && height == null) return null;

    return ParsedRecord(
      type: 'growth',
      data: {
        'weight': weight,
        'height': height,
        'date': DateTime.now(),
      },
    );
  }

  /// 检查是否包含任意关键词
  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }
}