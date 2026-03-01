import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_theme.dart';

/// 图片选择工具类
class ImagePickerUtil {
  static final ImagePicker _picker = ImagePicker();

  /// 显示图片选择底部弹窗
  static Future<void> showPickerOptions(
    BuildContext context, {
    required String title,
    required Function(String path) onImageSelected,
    double? maxWidth = 1200,
    double? maxHeight = 1200,
    int imageQuality = 85,
  }) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(title, style: AppTextStyles.subtitle),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('拍照'),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await pickImage(
                    source: ImageSource.camera,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    imageQuality: imageQuality,
                  );
                  if (path != null) {
                    onImageSelected(path);
                  }
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library, color: AppColors.primary),
                ),
                title: const Text('从相册选择'),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await pickImage(
                    source: ImageSource.gallery,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    imageQuality: imageQuality,
                  );
                  if (path != null) {
                    onImageSelected(path);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 选择图片
  static Future<String?> pickImage({
    required ImageSource source,
    double? maxWidth = 1200,
    double? maxHeight = 1200,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      return image?.path;
    } catch (e) {
      print('选择图片失败: $e');
      return null;
    }
  }

  /// 拍照
  static Future<String?> takePhoto({
    double? maxWidth = 1200,
    double? maxHeight = 1200,
    int imageQuality = 85,
  }) async {
    return pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }

  /// 从相册选择
  static Future<String?> pickFromGallery({
    double? maxWidth = 1200,
    double? maxHeight = 1200,
    int imageQuality = 85,
  }) async {
    return pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }
}
