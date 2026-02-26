import '../models/milestone.dart';

/// 里程碑数据常量
/// 包含0-36个月宝宝各发展领域的里程碑定义
class MilestoneData {
  MilestoneData._();

  /// 所有里程碑列表
  static final List<Milestone> allMilestones = [
    // ==================== 大运动里程碑 (10个) ====================
    ...grossMotorMilestones,
    // ==================== 精细动作里程碑 (8个) ====================
    ...fineMotorMilestones,
    // ==================== 语言发展里程碑 (8个) ====================
    ...languageMilestones,
    // ==================== 社交情绪里程碑 (6个) ====================
    ...socialEmotionMilestones,
  ];

  /// 大运动里程碑 (Gross Motor)
  /// 涵盖：抬头、翻身、坐立、爬行、站立、行走、跑跳等
  static final List<Milestone> grossMotorMilestones = [
    const Milestone(
      id: 'gm_001',
      category: MilestoneCategory.grossMotor,
      minMonth: 0,
      maxMonth: 3,
      title: '俯卧抬头',
      description: '俯卧时能抬头45-90度，保持头部稳定，腿部蹬踏有力。这是宝宝颈部和背部肌肉发展的第一个重要里程碑。',
      trainingTip: '每天累计至少30分钟俯趴时间，在宝宝清醒、有成人监护时进行。可以在宝宝胸前垫一个小毛巾卷帮助支撑。',
    ),
    const Milestone(
      id: 'gm_002',
      category: MilestoneCategory.grossMotor,
      minMonth: 3,
      maxMonth: 6,
      title: '翻身',
      description: '能从仰卧翻到俯卧，或从俯卧翻到仰卧。这是宝宝躯干力量和协调性的重要体现。',
      trainingTip: '用玩具引导宝宝从仰卧翻到俯卧，在宝宝侧面放置有趣的玩具吸引注意力，鼓励宝宝尝试翻身。',
    ),
    const Milestone(
      id: 'gm_003',
      category: MilestoneCategory.grossMotor,
      minMonth: 5,
      maxMonth: 7,
      title: '独坐片刻',
      description: '能靠坐或短暂独坐，背部挺直，双手可以自由活动。这标志着核心肌群的发展。',
      trainingTip: '让宝宝靠坐在沙发角或靠垫中，逐渐减少支撑，练习平衡能力。注意周围做好安全防护。',
    ),
    const Milestone(
      id: 'gm_004',
      category: MilestoneCategory.grossMotor,
      minMonth: 6,
      maxMonth: 10,
      title: '爬行',
      description: '能用手和膝盖支撑身体，协调地向前爬行。爬行是大脑双侧协调的重要训练。',
      trainingTip: '创造安全爬行环境，鼓励多爬。可以设置小障碍物或隧道，增加爬行乐趣和挑战。',
    ),
    const Milestone(
      id: 'gm_005',
      category: MilestoneCategory.grossMotor,
      minMonth: 8,
      maxMonth: 12,
      title: '扶站',
      description: '能扶着家具或栏杆站立，腿部有力支撑身体重量。这是行走前的重要准备。',
      trainingTip: '提供稳固的家具让宝宝练习扶站，确保家具不会滑动。可以站在宝宝对面鼓励站立。',
    ),
    const Milestone(
      id: 'gm_006',
      category: MilestoneCategory.grossMotor,
      minMonth: 10,
      maxMonth: 14,
      title: '独站',
      description: '能不扶任何物体独立站立几秒钟，保持身体平衡。这是独走前的关键能力。',
      trainingTip: '让宝宝扶着家具站立，然后递玩具吸引宝宝松开一只手，逐渐练习不扶物站立。',
    ),
    const Milestone(
      id: 'gm_007',
      category: MilestoneCategory.grossMotor,
      minMonth: 11,
      maxMonth: 16,
      title: '独走',
      description: '能独立行走几步到十几步，虽然可能还不稳，但已具备独立移动的能力。',
      trainingTip: '让宝宝推着学步车或扶着沙发边走，逐渐减少支撑。在安全的开阔空间鼓励宝宝自己走。',
    ),
    const Milestone(
      id: 'gm_008',
      category: MilestoneCategory.grossMotor,
      minMonth: 15,
      maxMonth: 24,
      title: '跑和上下楼梯',
      description: '能稳定地跑步，扶着栏杆上下楼梯，踢球等。活动能力和协调性大幅提升。',
      trainingTip: '户外游戏时间增加，追泡泡、踢球、玩滑梯。上下楼梯时让宝宝自己扶着栏杆练习。',
    ),
    const Milestone(
      id: 'gm_009',
      category: MilestoneCategory.grossMotor,
      minMonth: 24,
      maxMonth: 30,
      title: '双脚跳',
      description: '能双脚同时离地跳跃，单脚站立短暂时间。这是下肢力量和平衡能力的进一步发展。',
      trainingTip: '设置简单的运动游戏，如跳格子、跳小障碍、在垫子上跳跃。玩"小兔子跳跳"游戏。',
    ),
    const Milestone(
      id: 'gm_010',
      category: MilestoneCategory.grossMotor,
      minMonth: 30,
      maxMonth: 36,
      title: '骑三轮车',
      description: '能骑三轮车或用脚蹬地滑行，单脚站立更稳定，能踮起脚尖。',
      trainingTip: '提供适合身高的三轮车，在平坦安全的地方练习。也可以玩平衡车或滑板车。',
    ),
  ];

  /// 精细动作里程碑 (Fine Motor)
  /// 涵盖：抓握、捏取、涂鸦、使用工具等
  static final List<Milestone> fineMotorMilestones = [
    const Milestone(
      id: 'fm_001',
      category: MilestoneCategory.fineMotor,
      minMonth: 0,
      maxMonth: 3,
      title: '无意识抓握',
      description: '能反射性地握住放入手中的物品，把手放进嘴里探索。这是手部动作发展的起点。',
      trainingTip: '提供不同质地的玩具让宝宝抓握，如布书、摇铃、软球等，鼓励宝宝把手放进嘴里探索。',
    ),
    const Milestone(
      id: 'fm_002',
      category: MilestoneCategory.fineMotor,
      minMonth: 3,
      maxMonth: 6,
      title: '主动抓握',
      description: '能主动伸手抓握物品，双手可以传递物品，开始有意识地控制手部动作。',
      trainingTip: '提供容易抓握的摇铃、布书，在宝宝面前晃动吸引抓取。练习双手传递玩具。',
    ),
    const Milestone(
      id: 'fm_003',
      category: MilestoneCategory.fineMotor,
      minMonth: 7,
      maxMonth: 10,
      title: '拇指食指对捏',
      description: '能用拇指和食指捏起小物品（钳形抓握），会拍手。这是精细动作的重要飞跃。',
      trainingTip: '提供小颗粒食物（如泡芙）练习捏取，玩拍手游戏，提供手指食物锻炼手眼协调。',
    ),
    const Milestone(
      id: 'fm_004',
      category: MilestoneCategory.fineMotor,
      minMonth: 9,
      maxMonth: 12,
      title: '放物品入容器',
      description: '能把物品放入容器中，用手指指物，会挥手"再见"。手部控制更加精准。',
      trainingTip: '玩积木敲击、套圈、把积木放进盒子再倒出来。练习挥手"再见"等手势。',
    ),
    const Milestone(
      id: 'fm_005',
      category: MilestoneCategory.fineMotor,
      minMonth: 12,
      maxMonth: 18,
      title: '叠积木和翻书',
      description: '能叠2-4块积木，翻厚纸板书，握笔涂鸦，尝试用勺子吃饭。',
      trainingTip: '提供大颗粒积木、厚纸板书、粗蜡笔。让宝宝自己用勺子吃饭，允许弄脏。',
    ),
    const Milestone(
      id: 'fm_006',
      category: MilestoneCategory.fineMotor,
      minMonth: 18,
      maxMonth: 24,
      title: '握笔涂鸦',
      description: '能模仿画横线竖线，叠6块以上积木，拧开瓶盖，穿大珠子。',
      trainingTip: '提供大纸张和粗蜡笔让宝宝自由涂鸦。玩串珠玩具、拧瓶盖游戏。',
    ),
    const Milestone(
      id: 'fm_007',
      category: MilestoneCategory.fineMotor,
      minMonth: 24,
      maxMonth: 30,
      title: '画简单图形',
      description: '能模仿画圆形、横线、竖线，穿珠子更熟练，使用剪刀剪纸（需监督）。',
      trainingTip: '示范画简单图形让宝宝模仿。提供安全剪刀和纸练习剪纸。玩简单拼图。',
    ),
    const Milestone(
      id: 'fm_008',
      category: MilestoneCategory.fineMotor,
      minMonth: 30,
      maxMonth: 36,
      title: '画简单人形',
      description: '能画简单的人形（头+身体），沿直线剪纸，扣扣子，使用儿童剪刀熟练。',
      trainingTip: '鼓励宝宝画"我的家"或"爸爸妈妈"，提供需要扣扣子的衣服练习。',
    ),
  ];

  /// 语言发展里程碑 (Language)
  /// 涵盖：发音、词汇、句子、理解能力等
  static final List<Milestone> languageMilestones = [
    const Milestone(
      id: 'lg_001',
      category: MilestoneCategory.language,
      minMonth: 0,
      maxMonth: 3,
      title: '发出元音',
      description: '发出咕咕、啊啊等元音，对声音有反应，开始辨别熟悉的声音。',
      trainingTip: '多和宝宝说话、唱歌，回应宝宝的发声。用夸张的语调和表情与宝宝交流。',
    ),
    const Milestone(
      id: 'lg_002',
      category: MilestoneCategory.language,
      minMonth: 3,
      maxMonth: 6,
      title: '咿呀学语',
      description: '发出辅音（b、m、p），咿呀学语，对声音来源转头，对语调有反应。',
      trainingTip: '模仿宝宝的声音，进行"对话"。多叫宝宝的名字，让宝宝熟悉自己的名字。',
    ),
    const Milestone(
      id: 'lg_003',
      category: MilestoneCategory.language,
      minMonth: 6,
      maxMonth: 9,
      title: '重复音节',
      description: '发出"爸爸""妈妈"等重复音节，理解"不"的含义，对名字有明确反应。',
      trainingTip: '指认日常物品并命名，读简单绘本。当宝宝说"爸爸"时，回应"对，爸爸在这里"。',
    ),
    const Milestone(
      id: 'lg_004',
      category: MilestoneCategory.language,
      minMonth: 9,
      maxMonth: 12,
      title: '有意识称呼',
      description: '能有意识地叫"爸爸""妈妈"，听懂简单指令（如"把球给妈妈"），理解常见物品名称。',
      trainingTip: '多给简单指令，扩展宝宝的词汇。每天亲子阅读，指认书中的物品。',
    ),
    const Milestone(
      id: 'lg_005',
      category: MilestoneCategory.language,
      minMonth: 12,
      maxMonth: 18,
      title: '说单词',
      description: '能说10-50个词，用手指指想要的物品，模仿新词汇，理解更多指令。',
      trainingTip: '每天亲子阅读，描述日常活动。不要纠正发音，重复正确的说法即可。',
    ),
    const Milestone(
      id: 'lg_006',
      category: MilestoneCategory.language,
      minMonth: 18,
      maxMonth: 24,
      title: '说双词短语',
      description: '能说两个词的短语（如"妈妈抱""喝水"），词汇量快速增长，开始问"这是什么"。',
      trainingTip: '当宝宝说"妈妈"时，扩展为"妈妈在这里"。鼓励宝宝描述看到的事物。',
    ),
    const Milestone(
      id: 'lg_007',
      category: MilestoneCategory.language,
      minMonth: 24,
      maxMonth: 30,
      title: '说简单句子',
      description: '能说3-5个词的句子，问"为什么"，陌生人能听懂大部分话，理解方位词。',
      trainingTip: '多讲故事，鼓励宝宝描述经历。认真回答宝宝的提问，扩展句子复杂度。',
    ),
    const Milestone(
      id: 'lg_008',
      category: MilestoneCategory.language,
      minMonth: 30,
      maxMonth: 36,
      title: '流利表达',
      description: '能进行简单对话，使用代词（我、你），理解过去和未来概念，喜欢讲故事。',
      trainingTip: '鼓励宝宝讲述今天发生的事情，玩角色扮演游戏，培养叙事能力。',
    ),
  ];

  /// 社交情绪里程碑 (Social & Emotion)
  /// 涵盖：微笑、认生、自我意识、情绪调节等
  static final List<Milestone> socialEmotionMilestones = [
    const Milestone(
      id: 'se_001',
      category: MilestoneCategory.socialEmotion,
      minMonth: 0,
      maxMonth: 3,
      title: '社会性微笑',
      description: '开始社会性微笑，能短暂注视人脸，用哭声表达不同需求（饿、累、不舒服）。',
      trainingTip: '多进行面对面交流，及时回应宝宝的需求。宝宝微笑时，热情地回应和模仿。',
    ),
    const Milestone(
      id: 'se_002',
      category: MilestoneCategory.socialEmotion,
      minMonth: 3,
      maxMonth: 6,
      title: '区分熟悉与陌生',
      description: '能区分熟悉和陌生人，喜欢与人互动，开始大笑，表达开心和无聊。',
      trainingTip: '带宝宝接触不同的人，建立安全感。当宝宝表现出情绪时，用语言帮宝宝表达。',
    ),
    const Milestone(
      id: 'se_003',
      category: MilestoneCategory.socialEmotion,
      minMonth: 6,
      maxMonth: 10,
      title: '分离焦虑和认生',
      description: '出现分离焦虑，认生明显，喜欢照镜子，对陌生人表现出谨慎或哭泣。',
      trainingTip: '玩躲猫猫游戏帮助理解物体恒存性。短暂分离时告诉宝宝会回来，建立信任。',
    ),
    const Milestone(
      id: 'se_004',
      category: MilestoneCategory.socialEmotion,
      minMonth: 10,
      maxMonth: 15,
      title: '模仿和互动',
      description: '会挥手"再见"，模仿大人动作，测试边界（故意扔东西），有偏好和选择。',
      trainingTip: '建立固定的告别仪式。通过游戏教宝宝模仿动作，设置简单一致的规则。',
    ),
    const Milestone(
      id: 'se_005',
      category: MilestoneCategory.socialEmotion,
      minMonth: 15,
      maxMonth: 24,
      title: '自我意识',
      description: '出现自我意识，说"我的"，开始平行游戏（和其他孩子各玩各的），有独立意愿。',
      trainingTip: '提供与同龄孩子接触的机会，尊重孩子的物权。让宝宝做简单的选择（选红色还是蓝色杯子）。',
    ),
    const Milestone(
      id: 'se_006',
      category: MilestoneCategory.socialEmotion,
      minMonth: 24,
      maxMonth: 36,
      title: '合作与想象力',
      description: '开始合作游戏，有丰富想象力，情绪调节能力增强，表现出同情心。',
      trainingTip: '鼓励角色扮演游戏，教宝宝用语言表达情绪（"我生气了"）。培养分享和轮流的概念。',
    ),
  ];

  // ==================== 便捷查询方法 ====================

  /// 根据ID获取里程碑
  static Milestone? getById(String id) {
    try {
      return allMilestones.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 根据分类获取里程碑
  static List<Milestone> getByCategory(MilestoneCategory category) {
    return allMilestones.where((m) => m.category == category).toList();
  }

  /// 根据月龄范围获取里程碑
  static List<Milestone> getByMonthRange(int minMonth, int maxMonth) {
    return allMilestones.where((m) {
      return (m.minMonth >= minMonth && m.minMonth <= maxMonth) ||
             (m.maxMonth >= minMonth && m.maxMonth <= maxMonth) ||
             (m.minMonth <= minMonth && m.maxMonth >= maxMonth);
    }).toList();
  }

  /// 获取指定月龄应该关注的里程碑
  static List<Milestone> getByCurrentMonth(int month) {
    return allMilestones.where((m) => m.isInRange(month)).toList();
  }

  /// 获取各分类的里程碑数量（兼容旧代码）
  static Map<MilestoneCategory, int> get countByCategory => categoryCounts;

  /// 获取各分类的里程碑数量
  static Map<MilestoneCategory, int> get categoryCounts {
    final Map<MilestoneCategory, int> counts = {};
    for (final category in MilestoneCategory.values) {
      counts[category] = getByCategory(category).length;
    }
    return counts;
  }

  /// 根据ID获取里程碑
  static Milestone? getMilestoneById(String id) {
    try {
      return allMilestones.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取指定月龄的里程碑
  static List<Milestone> getMilestonesForAge(int month) {
    return getByCurrentMonth(month);
  }

  /// 获取发育预警信号
  static List<String> getDevelopmentWarnings(int month) {
    return getWarningSigns(month);
  }

  /// 获取里程碑总数
  static int get totalCount => allMilestones.length;

  /// 获取预警信号列表（根据月龄检查是否达成相应里程碑）
  static List<String> getWarningSigns(int month) {
    final List<String> warnings = [];
    
    // 大运动预警信号
    if (month >= 9) warnings.add('超过9个月还不会坐');
    if (month >= 12) warnings.add('1周岁还不能扶站');
    if (month >= 18) warnings.add('1岁半还不能独走');
    if (month >= 24) warnings.add('2岁不能跑或双脚跳');
    
    // 精细动作预警信号
    if (month >= 6) warnings.add('6月龄仍紧握拳头、不会主动抓握');
    if (month >= 12) warnings.add('12月龄不能拇指食指对捏');
    if (month >= 24) warnings.add('2岁还不会用勺子');
    
    // 语言预警信号
    if (month >= 12) warnings.add('12月龄对名字无反应、不会咿呀学语');
    if (month >= 18) warnings.add('18月龄不会说任何单词');
    if (month >= 24) warnings.add('2岁词汇量少于50个或不会说两词短语');
    
    // 社交情绪预警信号
    if (month >= 6) warnings.add('6月龄不会社会性微笑');
    if (month >= 12) warnings.add('12月龄对呼唤名字无反应');
    if (month >= 18) warnings.add('18月龄不会指物');
    if (month >= 24) warnings.add('2岁不会模仿动作');
    if (month >= 36) warnings.add('3岁不会与同龄孩子互动');
    
    return warnings;
  }
}

/// 别名类，用于兼容旧代码引用
class DefaultMilestones {
  DefaultMilestones._();
  
  static List<Milestone> get all => MilestoneData.allMilestones;
  static int get totalCount => all.length;
  static Map<MilestoneCategory, int> get countByCategory => MilestoneData.countByCategory;
  
  static Milestone? getMilestoneById(String id) => MilestoneData.getMilestoneById(id);
  static List<Milestone> getMilestonesForAge(int month) => MilestoneData.getMilestonesForAge(month);
  static List<String> getDevelopmentWarnings(int month) => MilestoneData.getDevelopmentWarnings(month);
}
