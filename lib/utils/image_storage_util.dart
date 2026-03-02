import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 图片存储工具类
class ImageStorageUtil {
  /// 将临时图片复制到应用永久存储目录
  static Future<String?> saveImagePermanently(String? tempPath) async {
    if (tempPath == null || tempPath.isEmpty) {
      debugPrint('saveImagePermanently: tempPath is null or empty');
      return null;
    }
    
    try {
      // 获取应用目录
      final appDir = await getApplicationDocumentsDirectory();
      debugPrint('saveImagePermanently: appDir = ${appDir.path}');
      debugPrint('saveImagePermanently: tempPath = $tempPath');
      
      // 如果已经是应用目录内的路径，直接返回
      if (tempPath.startsWith(appDir.path)) {
        debugPrint('saveImagePermanently: already in app directory');
        return tempPath;
      }
      
      // 创建图片存储目录
      final imagesDir = Directory('${appDir.path}/images');
      if (!await imagesDir.exists()) {
        debugPrint('saveImagePermanently: creating images directory');
        await imagesDir.create(recursive: true);
      }
      
      // 生成唯一文件名
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(tempPath)}';
      final newPath = '${imagesDir.path}/$fileName';
      debugPrint('saveImagePermanently: newPath = $newPath');
      
      // 检查源文件是否存在
      final sourceFile = File(tempPath);
      final sourceExists = await sourceFile.exists();
      debugPrint('saveImagePermanently: source file exists = $sourceExists');
      
      if (sourceExists) {
        // 读取文件内容
        final bytes = await sourceFile.readAsBytes();
        debugPrint('saveImagePermanently: read ${bytes.length} bytes');
        
        // 写入新文件
        final newFile = File(newPath);
        await newFile.writeAsBytes(bytes);
        
        // 验证写入是否成功
        final destExists = await newFile.exists();
        final destSize = await newFile.length();
        debugPrint('saveImagePermanently: dest file exists = $destExists, size = $destSize');
        
        if (destExists && destSize > 0) {
          debugPrint('saveImagePermanently: success, returning $newPath');
          return newPath;
        } else {
          debugPrint('saveImagePermanently: failed to write destination file');
          return null;
        }
      }
      
      debugPrint('saveImagePermanently: source file does not exist');
      return null;
    } catch (e, stackTrace) {
      debugPrint('saveImagePermanently: error = $e');
      debugPrint('saveImagePermanently: stackTrace = $stackTrace');
      return null;
    }
  }
  
  /// 删除图片
  static Future<bool> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return false;
    
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('删除图片失败: $e');
      return false;
    }
  }
  
  /// 验证图片是否存在
  static Future<bool> imageExists(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return false;
    
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}