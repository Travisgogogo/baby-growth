import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// 隐私政策页面
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('隐私政策'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('隐私政策', style: AppTextStyles.headline),
            const SizedBox(height: 8),
            Text('最后更新日期：2024年3月', style: AppTextStyles.caption),
            const SizedBox(height: 24),
            _buildSection('1. 数据收集', 
              '本应用收集以下数据用于记录宝宝成长：\n'
              '• 宝宝基本信息（姓名、出生日期、性别等）\n'
              '• 生长记录（身高、体重、头围等）\n'
              '• 日常记录（喂养、睡眠、换尿布等）\n'
              '• 照片（头像、出生照片、手印脚印等）\n\n'
              '所有数据仅存储在您的设备本地，我们不会收集或上传任何数据到我们的服务器。'),
            _buildSection('2. 数据存储', 
              '• 所有数据使用 SQLite 数据库存储在应用沙箱内\n'
              '• 照片存储在应用私有目录\n'
              '• 云端备份功能仅在您主动配置后使用，数据存储在您指定的云服务（坚果云）\n'
              '• 我们不会访问、查看或使用您的任何数据'),
            _buildSection('3. 权限使用', 
              '本应用需要以下权限：\n'
              '• 相机权限：用于拍摄宝宝照片\n'
              '• 存储权限：用于保存照片到设备\n'
              '• 网络权限：用于云端备份功能\n\n'
              '所有权限仅用于上述目的，不会用于其他用途。'),
            _buildSection('4. 数据安全', 
              '• 应用使用 HTTPS 进行云端备份数据传输\n'
              '• 云端备份使用您自己配置的云服务账号\n'
              '• 建议您定期备份数据以防丢失\n'
              '• 卸载应用将删除所有本地数据'),
            _buildSection('5. 第三方服务', 
              '本应用使用以下第三方服务：\n'
              '• GitHub：用于检查应用更新\n'
              '• 坚果云（可选）：用于云端备份（仅在您配置后使用）\n\n'
              '这些服务有其独立的隐私政策。'),
            _buildSection('6. 联系我们', 
              '如果您对隐私政策有任何疑问，请通过以下方式联系我们：\n'
              '• 在 GitHub 上提交 Issue\n'
              '• 发送邮件至开发者邮箱'),
            const SizedBox(height: 32),
            Center(
              child: Text(
                '感谢您使用宝宝成长记',
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: 8),
          Text(content, style: AppTextStyles.body.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}
