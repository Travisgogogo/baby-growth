import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 图片存储工具类
class ImageStorageUtil {
  /// 将临时图片复制到应用永久存储目录
  static Future<String?> saveImagePermanently(String? tempPath) async {
    if (tempPath == null || tempPath.isEmpty) return null;
    
    try {
      // 如果已经是应用目录内的路径，直接返回
      final appDir = await getApplicationDocumentsDirectory();
      if (tempPath.startsWith(appDir.path)) {
        return tempPath;
      }
      
      // 创建图片存储目录
      final imagesDir = Directory('${appDir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      // 生成唯一文件名
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(tempPath)}';
      final newPath = '${imagesDir.path}/$fileName';
      
      // 复制文件
      final sourceFile = File(tempPath);
      if (await sourceFile.exists()) {
        final newFile = await sourceFile.copy(newPath);
        return newFile.path;
      }
      
      return null;
    } catch (e) {
      print('保存图片失败: $e');
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
      print('删除图片失败: $e');
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
