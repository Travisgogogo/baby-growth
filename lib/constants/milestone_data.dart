import '../models/milestone_record.dart';

/// 默认里程碑定义
class DefaultMilestones {
  static const Map<String, List<MilestoneDef>> milestonesByMonth = {
    '0-3个月': [
      MilestoneDef('m1', '追视移动物体'),
      MilestoneDef('m2', '对声音有反应'),
      MilestoneDef('m3', '俯卧抬头45度'),
      MilestoneDef('m4', '发出咕咕声'),
    ],
    '4-6个月': [
      MilestoneDef('m5', '翻身'),
      MilestoneDef('m6', '独坐片刻'),
      MilestoneDef('m7', '抓取玩具'),
      MilestoneDef('m8', '笑出声'),
    ],
    '7-9个月': [
      MilestoneDef('m9', '独坐稳定'),
      MilestoneDef('m10', '双手传递物品'),
      MilestoneDef('m11', '咿呀学语'),
      MilestoneDef('m12', '爬行'),
      MilestoneDef('m13', '理解"不"'),
    ],
    '10-12个月': [
      MilestoneDef('m14', '扶站'),
      MilestoneDef('m15', '挥手再见'),
      MilestoneDef('m16', '叫爸爸妈妈'),
      MilestoneDef('m17', '独站片刻'),
      MilestoneDef('m18', '牵手走路'),
    ],
    '1-2岁': [
      MilestoneDef('m19', '独走'),
      MilestoneDef('m20', '用勺子吃饭'),
      MilestoneDef('m21', '说10个词'),
      MilestoneDef('m22', '指认身体部位'),
      MilestoneDef('m23', '模仿动作'),
    ],
  };

  /// 获取所有里程碑总数
  static int get totalCount {
    int count = 0;
    milestonesByMonth.forEach((_, list) => count += list.length);
    return count;
  }
}

/// 里程碑定义数据类
class MilestoneDef {
  final String id;
  final String title;
  
  const MilestoneDef(this.id, this.title);
}
