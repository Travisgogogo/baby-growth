// WHO儿童生长标准数据 (0-36个月)
// 数据来源: WHO Multicentre Growth Reference Study
// https://www.who.int/tools/child-growth-standards

/// WHO生长曲线数据点
class WHOGrowthDataPoint {
  final int ageInMonths;  // 月龄
  final double p3;        // 第3百分位
  final double p15;       // 第15百分位
  final double p50;       // 第50百分位 (中位数)
  final double p85;       // 第85百分位
  final double p97;       // 第97百分位

  const WHOGrowthDataPoint({
    required this.ageInMonths,
    required this.p3,
    required this.p15,
    required this.p50,
    required this.p85,
    required this.p97,
  });
}

/// WHO生长标准数据
class WHOGrowthData {
  // ==================== 男孩体重-for-年龄 (kg, 0-36月) ====================
  static const List<WHOGrowthDataPoint> boyWeightForAge = [
    WHOGrowthDataPoint(ageInMonths: 0, p3: 2.5, p15: 2.9, p50: 3.3, p85: 3.9, p97: 4.3),
    WHOGrowthDataPoint(ageInMonths: 1, p3: 3.4, p15: 3.9, p50: 4.5, p85: 5.1, p97: 5.7),
    WHOGrowthDataPoint(ageInMonths: 2, p3: 4.3, p15: 4.9, p50: 5.6, p85: 6.3, p97: 7.1),
    WHOGrowthDataPoint(ageInMonths: 3, p3: 5.0, p15: 5.7, p50: 6.4, p85: 7.2, p97: 8.0),
    WHOGrowthDataPoint(ageInMonths: 4, p3: 5.6, p15: 6.4, p50: 7.0, p85: 7.8, p97: 8.6),
    WHOGrowthDataPoint(ageInMonths: 5, p3: 6.0, p15: 6.9, p50: 7.5, p85: 8.4, p97: 9.2),
    WHOGrowthDataPoint(ageInMonths: 6, p3: 6.4, p15: 7.3, p50: 7.9, p85: 8.8, p97: 9.6),
    WHOGrowthDataPoint(ageInMonths: 7, p3: 6.7, p15: 7.6, p50: 8.3, p85: 9.2, p97: 10.0),
    WHOGrowthDataPoint(ageInMonths: 8, p3: 6.9, p15: 7.9, p50: 8.6, p85: 9.5, p97: 10.4),
    WHOGrowthDataPoint(ageInMonths: 9, p3: 7.1, p15: 8.1, p50: 8.9, p85: 9.8, p97: 10.7),
    WHOGrowthDataPoint(ageInMonths: 10, p3: 7.4, p15: 8.4, p50: 9.2, p85: 10.1, p97: 11.0),
    WHOGrowthDataPoint(ageInMonths: 11, p3: 7.6, p15: 8.6, p50: 9.4, p85: 10.4, p97: 11.3),
    WHOGrowthDataPoint(ageInMonths: 12, p3: 7.7, p15: 8.8, p50: 9.6, p85: 10.6, p97: 11.5),
    WHOGrowthDataPoint(ageInMonths: 13, p3: 7.9, p15: 9.0, p50: 9.9, p85: 10.9, p97: 11.8),
    WHOGrowthDataPoint(ageInMonths: 14, p3: 8.1, p15: 9.2, p50: 10.1, p85: 11.1, p97: 12.1),
    WHOGrowthDataPoint(ageInMonths: 15, p3: 8.3, p15: 9.4, p50: 10.3, p85: 11.3, p97: 12.3),
    WHOGrowthDataPoint(ageInMonths: 16, p3: 8.4, p15: 9.6, p50: 10.5, p85: 11.5, p97: 12.5),
    WHOGrowthDataPoint(ageInMonths: 17, p3: 8.6, p15: 9.8, p50: 10.7, p85: 11.7, p97: 12.7),
    WHOGrowthDataPoint(ageInMonths: 18, p3: 8.8, p15: 10.0, p50: 10.9, p85: 11.9, p97: 12.9),
    WHOGrowthDataPoint(ageInMonths: 19, p3: 8.9, p15: 10.2, p50: 11.1, p85: 12.1, p97: 13.1),
    WHOGrowthDataPoint(ageInMonths: 20, p3: 9.1, p15: 10.3, p50: 11.3, p85: 12.3, p97: 13.3),
    WHOGrowthDataPoint(ageInMonths: 21, p3: 9.2, p15: 10.5, p50: 11.5, p85: 12.5, p97: 13.5),
    WHOGrowthDataPoint(ageInMonths: 22, p3: 9.4, p15: 10.7, p50: 11.7, p85: 12.7, p97: 13.7),
    WHOGrowthDataPoint(ageInMonths: 23, p3: 9.5, p15: 10.8, p50: 11.8, p85: 12.9, p97: 13.9),
    WHOGrowthDataPoint(ageInMonths: 24, p3: 9.7, p15: 11.0, p50: 12.0, p85: 13.1, p97: 14.1),
    WHOGrowthDataPoint(ageInMonths: 25, p3: 9.8, p15: 11.2, p50: 12.2, p85: 13.3, p97: 14.3),
    WHOGrowthDataPoint(ageInMonths: 26, p3: 10.0, p15: 11.3, p50: 12.4, p85: 13.5, p97: 14.5),
    WHOGrowthDataPoint(ageInMonths: 27, p3: 10.1, p15: 11.5, p50: 12.5, p85: 13.7, p97: 14.7),
    WHOGrowthDataPoint(ageInMonths: 28, p3: 10.2, p15: 11.6, p50: 12.7, p85: 13.8, p97: 14.9),
    WHOGrowthDataPoint(ageInMonths: 29, p3: 10.4, p15: 11.8, p50: 12.8, p85: 14.0, p97: 15.1),
    WHOGrowthDataPoint(ageInMonths: 30, p3: 10.5, p15: 11.9, p50: 13.0, p85: 14.2, p97: 15.3),
    WHOGrowthDataPoint(ageInMonths: 31, p3: 10.7, p15: 12.1, p50: 13.2, p85: 14.3, p97: 15.5),
    WHOGrowthDataPoint(ageInMonths: 32, p3: 10.8, p15: 12.2, p50: 13.3, p85: 14.5, p97: 15.7),
    WHOGrowthDataPoint(ageInMonths: 33, p3: 10.9, p15: 12.4, p50: 13.5, p85: 14.7, p97: 15.8),
    WHOGrowthDataPoint(ageInMonths: 34, p3: 11.0, p15: 12.5, p50: 13.6, p85: 14.8, p97: 16.0),
    WHOGrowthDataPoint(ageInMonths: 35, p3: 11.2, p15: 12.7, p50: 13.8, p85: 15.0, p97: 16.2),
    WHOGrowthDataPoint(ageInMonths: 36, p3: 11.3, p15: 12.8, p50: 13.9, p85: 15.2, p97: 16.4),
  ];

  // ==================== 女孩体重-for-年龄 (kg, 0-36月) ====================
  static const List<WHOGrowthDataPoint> girlWeightForAge = [
    WHOGrowthDataPoint(ageInMonths: 0, p3: 2.4, p15: 2.8, p50: 3.2, p85: 3.7, p97: 4.2),
    WHOGrowthDataPoint(ageInMonths: 1, p3: 3.2, p15: 3.7, p50: 4.2, p85: 4.8, p97: 5.4),
    WHOGrowthDataPoint(ageInMonths: 2, p3: 4.0, p15: 4.5, p50: 5.1, p85: 5.8, p97: 6.5),
    WHOGrowthDataPoint(ageInMonths: 3, p3: 4.6, p15: 5.2, p50: 5.8, p85: 6.6, p97: 7.3),
    WHOGrowthDataPoint(ageInMonths: 4, p3: 5.1, p15: 5.7, p50: 6.4, p85: 7.2, p97: 7.9),
    WHOGrowthDataPoint(ageInMonths: 5, p3: 5.5, p15: 6.1, p50: 6.9, p85: 7.7, p97: 8.5),
    WHOGrowthDataPoint(ageInMonths: 6, p3: 5.8, p15: 6.5, p50: 7.3, p85: 8.2, p97: 9.0),
    WHOGrowthDataPoint(ageInMonths: 7, p3: 6.1, p15: 6.8, p50: 7.6, p85: 8.5, p97: 9.4),
    WHOGrowthDataPoint(ageInMonths: 8, p3: 6.3, p15: 7.0, p50: 7.9, p85: 8.8, p97: 9.7),
    WHOGrowthDataPoint(ageInMonths: 9, p3: 6.5, p15: 7.3, p50: 8.2, p85: 9.1, p97: 10.0),
    WHOGrowthDataPoint(ageInMonths: 10, p3: 6.7, p15: 7.5, p50: 8.4, p85: 9.4, p97: 10.3),
    WHOGrowthDataPoint(ageInMonths: 11, p3: 6.9, p15: 7.7, p50: 8.6, p85: 9.6, p97: 10.6),
    WHOGrowthDataPoint(ageInMonths: 12, p3: 7.0, p15: 7.9, p50: 8.9, p85: 9.8, p97: 10.8),
    WHOGrowthDataPoint(ageInMonths: 13, p3: 7.2, p15: 8.1, p50: 9.1, p85: 10.0, p97: 11.0),
    WHOGrowthDataPoint(ageInMonths: 14, p3: 7.4, p15: 8.3, p50: 9.2, p85: 10.2, p97: 11.2),
    WHOGrowthDataPoint(ageInMonths: 15, p3: 7.5, p15: 8.4, p50: 9.4, p85: 10.4, p97: 11.4),
    WHOGrowthDataPoint(ageInMonths: 16, p3: 7.7, p15: 8.6, p50: 9.6, p85: 10.6, p97: 11.6),
    WHOGrowthDataPoint(ageInMonths: 17, p3: 7.8, p15: 8.8, p50: 9.8, p85: 10.8, p97: 11.8),
    WHOGrowthDataPoint(ageInMonths: 18, p3: 8.0, p15: 9.0, p50: 9.9, p85: 10.9, p97: 11.9),
    WHOGrowthDataPoint(ageInMonths: 19, p3: 8.1, p15: 9.1, p50: 10.1, p85: 11.1, p97: 12.1),
    WHOGrowthDataPoint(ageInMonths: 20, p3: 8.2, p15: 9.3, p50: 10.3, p85: 11.3, p97: 12.3),
    WHOGrowthDataPoint(ageInMonths: 21, p3: 8.4, p15: 9.4, p50: 10.4, p85: 11.4, p97: 12.4),
    WHOGrowthDataPoint(ageInMonths: 22, p3: 8.5, p15: 9.6, p50: 10.6, p85: 11.6, p97: 12.6),
    WHOGrowthDataPoint(ageInMonths: 23, p3: 8.6, p15: 9.7, p50: 10.7, p85: 11.7, p97: 12.8),
    WHOGrowthDataPoint(ageInMonths: 24, p3: 8.8, p15: 9.9, p50: 10.9, p85: 11.9, p97: 12.9),
    WHOGrowthDataPoint(ageInMonths: 25, p3: 8.9, p15: 10.0, p50: 11.0, p85: 12.1, p97: 13.1),
    WHOGrowthDataPoint(ageInMonths: 26, p3: 9.0, p15: 10.1, p50: 11.2, p85: 12.2, p97: 13.2),
    WHOGrowthDataPoint(ageInMonths: 27, p3: 9.1, p15: 10.3, p50: 11.3, p85: 12.4, p97: 13.4),
    WHOGrowthDataPoint(ageInMonths: 28, p3: 9.2, p15: 10.4, p50: 11.4, p85: 12.5, p97: 13.5),
    WHOGrowthDataPoint(ageInMonths: 29, p3: 9.4, p15: 10.5, p50: 11.6, p85: 12.6, p97: 13.7),
    WHOGrowthDataPoint(ageInMonths: 30, p3: 9.5, p15: 10.6, p50: 11.7, p85: 12.8, p97: 13.8),
    WHOGrowthDataPoint(ageInMonths: 31, p3: 9.6, p15: 10.8, p50: 11.8, p85: 12.9, p97: 14.0),
    WHOGrowthDataPoint(ageInMonths: 32, p3: 9.7, p15: 10.9, p50: 12.0, p85: 13.0, p97: 14.1),
    WHOGrowthDataPoint(ageInMonths: 33, p3: 9.8, p15: 11.0, p50: 12.1, p85: 13.2, p97: 14.3),
    WHOGrowthDataPoint(ageInMonths: 34, p3: 9.9, p15: 11.1, p50: 12.2, p85: 13.3, p97: 14.4),
    WHOGrowthDataPoint(ageInMonths: 35, p3: 10.0, p15: 11.2, p50: 12.3, p85: 13.4, p97: 14.5),
    WHOGrowthDataPoint(ageInMonths: 36, p3: 10.1, p15: 11.3, p50: 12.4, p85: 13.5, p97: 14.6),
  ];

  // ==================== 男孩身高-for-年龄 (cm, 0-36月) ====================
  static const List<WHOGrowthDataPoint> boyHeightForAge = [
    WHOGrowthDataPoint(ageInMonths: 0, p3: 46.3, p15: 47.9, p50: 49.9, p85: 51.8, p97: 53.4),
    WHOGrowthDataPoint(ageInMonths: 1, p3: 50.8, p15: 52.7, p50: 54.7, p85: 56.7, p97: 58.6),
    WHOGrowthDataPoint(ageInMonths: 2, p3: 54.4, p15: 56.4, p50: 58.4, p85: 60.4, p97: 62.4),
    WHOGrowthDataPoint(ageInMonths: 3, p3: 57.3, p15: 59.4, p50: 61.4, p85: 63.5, p97: 65.5),
    WHOGrowthDataPoint(ageInMonths: 4, p3: 59.7, p15: 61.8, p50: 63.9, p85: 65.9, p97: 68.0),
    WHOGrowthDataPoint(ageInMonths: 5, p3: 61.7, p15: 63.8, p50: 65.9, p85: 67.9, p97: 70.0),
    WHOGrowthDataPoint(ageInMonths: 6, p3: 63.3, p15: 65.5, p50: 67.6, p85: 69.6, p97: 71.7),
    WHOGrowthDataPoint(ageInMonths: 7, p3: 64.8, p15: 66.9, p50: 69.0, p85: 71.1, p97: 73.2),
    WHOGrowthDataPoint(ageInMonths: 8, p3: 66.2, p15: 68.3, p50: 70.4, p85: 72.5, p97: 74.6),
    WHOGrowthDataPoint(ageInMonths: 9, p3: 67.5, p15: 69.6, p50: 71.7, p85: 73.8, p97: 75.9),
    WHOGrowthDataPoint(ageInMonths: 10, p3: 68.7, p15: 70.8, p50: 72.9, p85: 75.0, p97: 77.1),
    WHOGrowthDataPoint(ageInMonths: 11, p3: 69.9, p15: 72.0, p50: 74.1, p85: 76.2, p97: 78.3),
    WHOGrowthDataPoint(ageInMonths: 12, p3: 71.0, p15: 73.1, p50: 75.2, p85: 77.3, p97: 79.4),
    WHOGrowthDataPoint(ageInMonths: 13, p3: 72.1, p15: 74.2, p50: 76.3, p85: 78.4, p97: 80.5),
    WHOGrowthDataPoint(ageInMonths: 14, p3: 73.1, p15: 75.2, p50: 77.3, p85: 79.4, p97: 81.5),
    WHOGrowthDataPoint(ageInMonths: 15, p3: 74.1, p15: 76.2, p50: 78.3, p85: 80.4, p97: 82.5),
    WHOGrowthDataPoint(ageInMonths: 16, p3: 75.0, p15: 77.2, p50: 79.3, p85: 81.4, p97: 83.5),
    WHOGrowthDataPoint(ageInMonths: 17, p3: 76.0, p15: 78.1, p50: 80.2, p85: 82.3, p97: 84.4),
    WHOGrowthDataPoint(ageInMonths: 18, p3: 76.9, p15: 79.0, p50: 81.1, p85: 83.2, p97: 85.3),
    WHOGrowthDataPoint(ageInMonths: 19, p3: 77.7, p15: 79.9, p50: 82.0, p85: 84.1, p97: 86.2),
    WHOGrowthDataPoint(ageInMonths: 20, p3: 78.6, p15: 80.7, p50: 82.8, p85: 84.9, p97: 87.0),
    WHOGrowthDataPoint(ageInMonths: 21, p3: 79.4, p15: 81.5, p50: 83.6, p85: 85.7, p97: 87.8),
    WHOGrowthDataPoint(ageInMonths: 22, p3: 80.2, p15: 82.3, p50: 84.4, p85: 86.5, p97: 88.6),
    WHOGrowthDataPoint(ageInMonths: 23, p3: 81.0, p15: 83.1, p50: 85.2, p85: 87.3, p97: 89.4),
    WHOGrowthDataPoint(ageInMonths: 24, p3: 81.7, p15: 83.8, p50: 85.9, p85: 88.0, p97: 90.1),
    WHOGrowthDataPoint(ageInMonths: 25, p3: 82.4, p15: 84.6, p50: 86.7, p85: 88.8, p97: 90.9),
    WHOGrowthDataPoint(ageInMonths: 26, p3: 83.1, p15: 85.3, p50: 87.4, p85: 89.5, p97: 91.6),
    WHOGrowthDataPoint(ageInMonths: 27, p3: 83.8, p15: 86.0, p50: 88.1, p85: 90.2, p97: 92.3),
    WHOGrowthDataPoint(ageInMonths: 28, p3: 84.5, p15: 86.7, p50: 88.8, p85: 90.9, p97: 93.0),
    WHOGrowthDataPoint(ageInMonths: 29, p3: 85.2, p15: 87.3, p50: 89.4, p85: 91.5, p97: 93.6),
    WHOGrowthDataPoint(ageInMonths: 30, p3: 85.8, p15: 88.0, p50: 90.1, p85: 92.2, p97: 94.3),
    WHOGrowthDataPoint(ageInMonths: 31, p3: 86.4, p15: 88.6, p50: 90.7, p85: 92.8, p97: 94.9),
    WHOGrowthDataPoint(ageInMonths: 32, p3: 87.0, p15: 89.2, p50: 91.3, p85: 93.4, p97: 95.5),
    WHOGrowthDataPoint(ageInMonths: 33, p3: 87.6, p15: 89.8, p50: 91.9, p85: 94.0, p97: 96.1),
    WHOGrowthDataPoint(ageInMonths: 34, p3: 88.2, p15: 90.4, p50: 92.5, p85: 94.6, p97: 96.7),
    WHOGrowthDataPoint(ageInMonths: 35, p3: 88.8, p15: 91.0, p50: 93.1, p85: 95.2, p97: 97.3),
    WHOGrowthDataPoint(ageInMonths: 36, p3: 89.3, p15: 91.5, p50: 93.6, p85: 95.7, p97: 97.8),
  ];

  // ==================== 女孩身高-for-年龄 (cm, 0-36月) ====================
  static const List<WHOGrowthDataPoint> girlHeightForAge = [
    WHOGrowthDataPoint(ageInMonths: 0, p3: 45.6, p15: 47.2, p50: 49.1, p85: 51.1, p97: 52.7),
    WHOGrowthDataPoint(ageInMonths: 1, p3: 49.8, p15: 51.7, p50: 53.7, p85: 55.6, p97: 57.6),
    WHOGrowthDataPoint(ageInMonths: 2, p3: 53.0, p15: 55.0, p50: 57.1, p85: 59.1, p97: 61.1),
    WHOGrowthDataPoint(ageInMonths: 3, p3: 55.6, p15: 57.7, p50: 59.8, p85: 61.9, p97: 63.9),
    WHOGrowthDataPoint(ageInMonths: 4, p3: 57.8, p15: 59.9, p50: 62.1, p85: 64.2, p97: 66.3),
    WHOGrowthDataPoint(ageInMonths: 5, p3: 59.6, p15: 61.8, p50: 64.0, p85: 66.1, p97: 68.3),
    WHOGrowthDataPoint(ageInMonths: 6, p3: 61.2, p15: 63.5, p50: 65.7, p85: 67.9, p97: 80.1),
    WHOGrowthDataPoint(ageInMonths: 7, p3: 62.7, p15: 65.0, p50: 67.3, p85: 69.5, p97: 81.7),
    WHOGrowthDataPoint(ageInMonths: 8, p3: 64.0, p15: 66.4, p50: 68.7, p85: 70.9, p97: 83.2),
    WHOGrowthDataPoint(ageInMonths: 9, p3: 65.3, p15: 67.7, p50: 70.1, p85: 72.3, p97: 84.6),
    WHOGrowthDataPoint(ageInMonths: 10, p3: 66.5, p15: 68.9, p50: 71.3, p85: 73.6, p97: 85.9),
    WHOGrowthDataPoint(ageInMonths: 11, p3: 67.7, p15: 70.1, p50: 72.5, p85: 74.8, p97: 87.1),
    WHOGrowthDataPoint(ageInMonths: 12, p3: 68.9, p15: 71.3, p50: 73.7, p85: 76.0, p97: 88.3),
    WHOGrowthDataPoint(ageInMonths: 13, p3: 70.0, p15: 72.4, p50: 74.8, p85: 77.2, p97: 89.5),
    WHOGrowthDataPoint(ageInMonths: 14, p3: 71.0, p15: 73.5, p50: 75.9, p85: 78.3, p97: 90.6),
    WHOGrowthDataPoint(ageInMonths: 15, p3: 72.0, p15: 74.5, p50: 76.9, p85: 79.3, p97: 91.7),
    WHOGrowthDataPoint(ageInMonths: 16, p3: 73.0, p15: 75.5, p50: 77.9, p85: 80.3, p97: 92.7),
    WHOGrowthDataPoint(ageInMonths: 17, p3: 74.0, p15: 76.5, p50: 78.9, p85: 81.3, p97: 93.7),
    WHOGrowthDataPoint(ageInMonths: 18, p3: 74.9, p15: 77.4, p50: 79.8, p85: 82.2, p97: 94.6),
    WHOGrowthDataPoint(ageInMonths: 19, p3: 75.8, p15: 78.3, p50: 80.7, p85: 83.1, p97: 95.5),
    WHOGrowthDataPoint(ageInMonths: 20, p3: 76.7, p15: 79.1, p50: 81.5, p85: 83.9, p97: 96.3),
    WHOGrowthDataPoint(ageInMonths: 21, p3: 77.5, p15: 79.9, p50: 82.3, p85: 84.7, p97: 97.1),
    WHOGrowthDataPoint(ageInMonths: 22, p3: 78.3, p15: 80.7, p50: 83.1, p85: 85.5, p97: 97.9),
    WHOGrowthDataPoint(ageInMonths: 23, p3: 79.1, p15: 81.5, p50: 83.9, p85: 86.3, p97: 98.6),
    WHOGrowthDataPoint(ageInMonths: 24, p3: 79.8, p15: 82.2, p50: 84.6, p85: 87.0, p97: 99.3),
    WHOGrowthDataPoint(ageInMonths: 25, p3: 80.5, p15: 82.9, p50: 85.3, p85: 87.7, p97: 100.0),
    WHOGrowthDataPoint(ageInMonths: 26, p3: 81.2, p15: 83.6, p50: 86.0, p85: 88.4, p97: 100.7),
    WHOGrowthDataPoint(ageInMonths: 27, p3: 81.9, p15: 84.3, p50: 86.7, p85: 89.1, p97: 101.4),
    WHOGrowthDataPoint(ageInMonths: 28, p3: 82.6, p15: 85.0, p50: 87.4, p85: 89.7, p97: 102.0),
    WHOGrowthDataPoint(ageInMonths: 29, p3: 83.2, p15: 85.6, p50: 88.0, p85: 90.4, p97: 102.6),
    WHOGrowthDataPoint(ageInMonths: 30, p3: 83.8, p15: 86.2, p50: 88.6, p85: 91.0, p97: 103.2),
    WHOGrowthDataPoint(ageInMonths: 31, p3: 84.4, p15: 86.8, p50: 89.2, p85: 91.6, p97: 103.8),
    WHOGrowthDataPoint(ageInMonths: 32, p3: 85.0, p15: 87.4, p50: 89.8, p85: 92.2, p97: 104.4),
    WHOGrowthDataPoint(ageInMonths: 33, p3: 85.6, p15: 88.0, p50: 90.4, p85: 92.7, p97: 105.0),
    WHOGrowthDataPoint(ageInMonths: 34, p3: 86.2, p15: 88.5, p50: 90.9, p85: 93.3, p97: 105.5),
    WHOGrowthDataPoint(ageInMonths: 35, p3: 86.7, p15: 89.1, p50: 91.4, p85: 93.8, p97: 106.0),
    WHOGrowthDataPoint(ageInMonths: 36, p3: 87.3, p15: 89.6, p50: 92.0, p85: 94.3, p97: 106.6),
  ];

  // ==================== 男孩头围-for-年龄 (cm, 0-36月) ====================
  static const List<WHOGrowthDataPoint> boyHeadCircumferenceForAge = [
    WHOGrowthDataPoint(ageInMonths: 0, p3: 32.1, p15: 33.1, p50: 34.5, p85: 35.8, p97: 36.9),
    WHOGrowthDataPoint(ageInMonths: 1, p3: 35.1, p15: 36.1, p50: 37.3, p85: 38.5, p97: 39.5),
    WHOGrowthDataPoint(ageInMonths: 2, p3: 37.1, p15: 38.0, p50: 39.1, p85: 40.2, p97: 41.1),
    WHOGrowthDataPoint(ageInMonths: 3, p3: 38.4, p15: 39.3, p50: 40.5, p85: 41.6, p97: 42.5),
    WHOGrowthDataPoint(ageInMonths: 4, p3: 39.6, p15: 40.5, p50: 41.6, p85: 42.7, p97: 43.6),
    WHOGrowthDataPoint(ageInMonths: 5, p3: 40.5, p15: 41.4, p50: 42.5, p85: 43.6, p97: 44.5),
    WHOGrowthDataPoint(ageInMonths: 6, p3: 41.3, p15: 42.2, p50: 43.3, p85: 44.4, p97: 45.3),
    WHOGrowthDataPoint(ageInMonths: 7, p3: 42.0, p15: 42.9, p50: 44.0, p85: 45.1, p97: 46.0),
    WHOGrowthDataPoint(ageInMonths: 8, p3: 42.6, p15: 43.5, p50: 44.6, p85: 45.7, p97: 46.6),
    WHOGrowthDataPoint(ageInMonths: 9, p3: 43.1, p15: 44.0, p50: 45.1, p85: 46.2, p97: 47.1),
    WHOGrowthDataPoint(ageInMonths: 10, p3: 43.6, p15: 44.5, p50: 45.6, p85: 46.7, p97: 47.6),
    WHOGrowthDataPoint(ageInMonths: 11, p3: 44.0, p15: 44.9, p50: 46.0, p85: 47.1, p97: 48.0),
    WHOGrowthDataPoint(ageInMonths: 12, p3: 44.4, p15: 45.3, p50: 46.4, p85: 47.5, p97: 48.4),
    WHOGrowthDataPoint(ageInMonths: 13, p3: 44.7, p15: 45.6, p50: 46.7, p85: 47.8, p97: 48.7),
    WHOGrowthDataPoint(ageInMonths: 14, p3: 45.0, p15: 45.9, p50: 47.0, p85: 48.1, p97: 49.0),
    WHOGrowthDataPoint(ageInMonths: 15, p3: 45.3, p15: 46.2, p50: 47.3, p85: 48.4, p97: 49.3),
    WHOGrowthDataPoint(ageInMonths: 16, p3: 45.6, p15: 46.5, p50: 47.6, p85: 48.7, p97: 49.6),
    WHOGrowthDataPoint(ageInMonths: 17, p3: 45.8, p15: 46.7, p50: 47.8, p85: 48.9, p97: 49.8),
    WHOGrowthDataPoint(ageInMonths: 18, p3: 46.0, p15: 46.9, p50: 48.0, p85: 49.1, p97: 50.0),
    WHOGrowthDataPoint(ageInMonths: 19, p3: 46.2, p15: 47.1, p50: 48.2, p85: 49.3, p97: 50.2),
    WHOGrowthDataPoint(ageInMonths: 20, p3: 46.4, p15: 47.3, p50: 48.4, p85: 49.5, p97: 50.4),
    WHOGrowthDataPoint(ageInMonths: 21, p3: 46.6, p15: 47.5, p50: 48.6, p85: 49.7, p97: 50.6),
    WHOGrowthDataPoint(ageInMonths: 22, p3: 46.7, p15: 47.6, p50: 48.7, p85: 49.8, p97: 50.7),
    WHOGrowthDataPoint(ageInMonths: 23, p3: 46.9, p15: 47.8, p50: 48.9, p85: 50.0, p97: 50.9),
    WHOGrowthDataPoint(ageInMonths: 24, p3: 47.0, p15: 47.9, p50: 49.0, p85: 50.1, p97: 51.0),
    WHOGrowthDataPoint(ageInMonths: 25, p3: 47.1, p15: 48.0, p50: 49.1, p85: 50.2, p97: 51.1),
    WHOGrowthDataPoint(ageInMonths: 26, p3: 47.2, p15: 48.1, p50: 49.2, p85: 50.3, p97: 51.2),
    WHOGrowthDataPoint(ageInMonths: 27, p3: 47.3, p15: 48.2, p50: 49.3, p85: 50.4, p97: 51.3),
    WHOGrowthDataPoint(ageInMonths: 28, p3: 47.4, p15: 48.3, p50: 49.4, p85: 50.5, p97: 51.4),
    WHOGrowthDataPoint(ageInMonths: 29, p3: 47.5, p15: 48.4, p50: 49.5, p85: 50.6, p97: 51.5),
    WHOGrowthDataPoint(ageInMonths: 30, p3: 47.6, p15: 48.5, p50: 49.6, p85: 50.7, p97: 51.6),
    WHOGrowthDataPoint(ageInMonths: 31, p3: 47.7, p15: 48.6, p50: 49.7, p85: 50.8, p97: 51.7),
    WHOGrowthDataPoint(ageInMonths: 32, p3: 47.8, p15: 48.7, p50: 49.8, p85: 50.9, p97: 51.8),
    WHOGrowthDataPoint(ageInMonths: 33, p3: 47.9, p15: 48.8, p50: 49.9, p85: 51.0, p97: 51.9),
    WHOGrowthDataPoint(ageInMonths: 34, p3: 48.0, p15: 48.9, p50: 50.0, p85: 51.1, p97: 52.0),
    WHOGrowthDataPoint(ageInMonths: 35, p3: 48.0, p15: 49.0, p50: 50.1, p85: 51.2, p97: 52.1),
    WHOGrowthDataPoint(ageInMonths: 36, p3: 48.1, p15: 49.0, p50: 50.1, p85: 51.2, p97: 52.1),
  ];

  // ==================== 女孩头围-for-年龄 (cm, 0-36月) ====================
  static const List<WHOGrowthDataPoint> girlHeadCircumferenceForAge = [
    WHOGrowthDataPoint(ageInMonths: 0, p3: 31.7, p15: 32.7, p50: 34.0, p85: 35.4, p97: 36.5),
    WHOGrowthDataPoint(ageInMonths: 1, p3: 34.5, p15: 35.5, p50: 36.7, p85: 37.9, p97: 38.9),
    WHOGrowthDataPoint(ageInMonths: 2, p3: 36.3, p15: 37.3, p50: 38.4, p85: 39.5, p97: 40.4),
    WHOGrowthDataPoint(ageInMonths: 3, p3: 37.5, p15: 38.5, p50: 39.6, p85: 40.7, p97: 41.6),
    WHOGrowthDataPoint(ageInMonths: 4, p3: 38.6, p15: 39.6, p50: 40.7, p85: 41.7, p97: 42.6),
    WHOGrowthDataPoint(ageInMonths: 5, p3: 39.4, p15: 40.4, p50: 41.5, p85: 42.5, p97: 43.4),
    WHOGrowthDataPoint(ageInMonths: 6, p3: 40.1, p15: 41.1, p50: 42.2, p85: 43.2, p97: 44.1),
    WHOGrowthDataPoint(ageInMonths: 7, p3: 40.7, p15: 41.7, p50: 42.8, p85: 43.8, p97: 44.7),
    WHOGrowthDataPoint(ageInMonths: 8, p3: 41.2, p15: 42.2, p50: 43.3, p85: 44.3, p97: 45.2),
    WHOGrowthDataPoint(ageInMonths: 9, p3: 41.7, p15: 42.7, p50: 43.8, p85: 44.8, p97: 45.7),
    WHOGrowthDataPoint(ageInMonths: 10, p3: 42.1, p15: 43.1, p50: 44.2, p85: 45.2, p97: 46.1),
    WHOGrowthDataPoint(ageInMonths: 11, p3: 42.4, p15: 43.4, p50: 44.5, p85: 45.5, p97: 46.4),
    WHOGrowthDataPoint(ageInMonths: 12, p3: 42.7, p15: 43.7, p50: 44.8, p85: 45.8, p97: 46.7),
    WHOGrowthDataPoint(ageInMonths: 13, p3: 43.0, p15: 44.0, p50: 45.1, p85: 46.1, p97: 47.0),
    WHOGrowthDataPoint(ageInMonths: 14, p3: 43.2, p15: 44.2, p50: 45.3, p85: 46.3, p97: 47.2),
    WHOGrowthDataPoint(ageInMonths: 15, p3: 43.5, p15: 44.5, p50: 45.6, p85: 46.6, p97: 47.5),
    WHOGrowthDataPoint(ageInMonths: 16, p3: 43.7, p15: 44.7, p50: 45.8, p85: 46.8, p97: 47.7),
    WHOGrowthDataPoint(ageInMonths: 17, p3: 43.9, p15: 44.9, p50: 46.0, p85: 47.0, p97: 47.9),
    WHOGrowthDataPoint(ageInMonths: 18, p3: 44.1, p15: 45.1, p50: 46.2, p85: 47.2, p97: 48.1),
    WHOGrowthDataPoint(ageInMonths: 19, p3: 44.2, p15: 45.2, p50: 46.3, p85: 47.3, p97: 48.2),
    WHOGrowthDataPoint(ageInMonths: 20, p3: 44.4, p15: 45.4, p50: 46.5, p85: 47.5, p97: 48.4),
    WHOGrowthDataPoint(ageInMonths: 21, p3: 44.5, p15: 45.5, p50: 46.6, p85: 47.6, p97: 48.5),
    WHOGrowthDataPoint(ageInMonths: 22, p3: 44.7, p15: 45.7, p50: 46.8, p85: 47.8, p97: 48.7),
    WHOGrowthDataPoint(ageInMonths: 23, p3: 44.8, p15: 45.8, p50: 46.9, p85: 47.9, p97: 48.8),
    WHOGrowthDataPoint(ageInMonths: 24, p3: 44.9, p15: 45.9, p50: 47.0, p85: 48.0, p97: 48.9),
    WHOGrowthDataPoint(ageInMonths: 25, p3: 45.0, p15: 46.0, p50: 47.1, p85: 48.1, p97: 49.0),
    WHOGrowthDataPoint(ageInMonths: 26, p3: 45.1, p15: 46.1, p50: 47.2, p85: 48.2, p97: 49.1),
    WHOGrowthDataPoint(ageInMonths: 27, p3: 45.2, p15: 46.2, p50: 47.3, p85: 48.3, p97: 49.2),
    WHOGrowthDataPoint(ageInMonths: 28, p3: 45.3, p15: 46.3, p50: 47.4, p85: 48.4, p97: 49.3),
    WHOGrowthDataPoint(ageInMonths: 29, p3: 45.4, p15: 46.4, p50: 47.5, p85: 48.5, p97: 49.4),
    WHOGrowthDataPoint(ageInMonths: 30, p3: 45.5, p15: 46.5, p50: 47.6, p85: 48.6, p97: 49.5),
    WHOGrowthDataPoint(ageInMonths: 31, p3: 45.6, p15: 46.6, p50: 47.7, p85: 48.7, p97: 49.6),
    WHOGrowthDataPoint(ageInMonths: 32, p3: 45.7, p15: 46.7, p50: 47.8, p85: 48.8, p97: 49.7),
    WHOGrowthDataPoint(ageInMonths: 33, p3: 45.7, p15: 46.7, p50: 47.8, p85: 48.8, p97: 49.7),
    WHOGrowthDataPoint(ageInMonths: 34, p3: 45.8, p15: 46.8, p50: 47.9, p85: 48.9, p97: 49.8),
    WHOGrowthDataPoint(ageInMonths: 35, p3: 45.9, p15: 46.9, p50: 48.0, p85: 49.0, p97: 49.9),
    WHOGrowthDataPoint(ageInMonths: 36, p3: 46.0, p15: 47.0, p50: 48.1, p85: 49.1, p97: 50.0),
  ];

  /// 获取指定性别和月龄的体重参考数据
  static WHOGrowthDataPoint? getWeightForAge(String gender, int ageInMonths) {
    final data = gender.toLowerCase() == '男' ? boyWeightForAge : girlWeightForAge;
    if (ageInMonths < 0 || ageInMonths > 36) return null;
    return data[ageInMonths];
  }

  /// 获取指定性别和月龄的身高参考数据
  static WHOGrowthDataPoint? getHeightForAge(String gender, int ageInMonths) {
    final data = gender.toLowerCase() == '男' ? boyHeightForAge : girlHeightForAge;
    if (ageInMonths < 0 || ageInMonths > 36) return null;
    return data[ageInMonths];
  }

  /// 获取指定性别和月龄的头围参考数据
  static WHOGrowthDataPoint? getHeadCircumferenceForAge(String gender, int ageInMonths) {
    final data = gender.toLowerCase() == '男' ? boyHeadCircumferenceForAge : girlHeadCircumferenceForAge;
    if (ageInMonths < 0 || ageInMonths > 36) return null;
    return data[ageInMonths];
  }

  /// 线性插值获取指定月龄的数据
  static WHOGrowthDataPoint? interpolateForAge(
    List<WHOGrowthDataPoint> data,
    double ageInMonths,
  ) {
    if (ageInMonths < 0 || ageInMonths > 36) return null;
    
    final lowerIndex = ageInMonths.floor();
    final upperIndex = ageInMonths.ceil();
    final fraction = ageInMonths - lowerIndex;
    
    if (lowerIndex == upperIndex) {
      return data[lowerIndex];
    }
    
    final lower = data[lowerIndex];
    final upper = data[upperIndex];
    
    return WHOGrowthDataPoint(
      ageInMonths: ageInMonths.round(),
      p3: _lerp(lower.p3, upper.p3, fraction),
      p15: _lerp(lower.p15, upper.p15, fraction),
      p50: _lerp(lower.p50, upper.p50, fraction),
      p85: _lerp(lower.p85, upper.p85, fraction),
      p97: _lerp(lower.p97, upper.p97, fraction),
    );
  }

  /// 线性插值
  static double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// 获取完整曲线数据 (用于图表显示)
  static List<WHOGrowthDataPoint> getWeightCurveData(String gender) {
    return gender.toLowerCase() == '男' ? boyWeightForAge : girlWeightForAge;
  }

  static List<WHOGrowthDataPoint> getHeightCurveData(String gender) {
    return gender.toLowerCase() == '男' ? boyHeightForAge : girlHeightForAge;
  }

  static List<WHOGrowthDataPoint> getHeadCircumferenceCurveData(String gender) {
    return gender.toLowerCase() == '男' ? boyHeadCircumferenceForAge : girlHeadCircumferenceForAge;
  }
}

/// 百分位等级枚举
enum PercentileLevel {
  belowP3,    // < P3
  p3toP15,    // P3 - P15
  p15toP50,   // P15 - P50
  p50toP85,   // P50 - P85
  p85toP97,   // P85 - P97
  aboveP97,   // > P97
}

/// 生长评估结果
class GrowthAssessment {
  final PercentileLevel percentileLevel;
  final double percentile;  // 估算的百分位值
  final String status;      // 评估状态描述
  final String description; // 详细描述
  final String? trend;      // 生长趋势

  const GrowthAssessment({
    required this.percentileLevel,
    required this.percentile,
    required this.status,
    required this.description,
    this.trend,
  });

  /// 获取状态颜色
  String get statusColor {
    switch (percentileLevel) {
      case PercentileLevel.belowP3:
        return 'danger';     // 红色 - 需关注
      case PercentileLevel.p3toP15:
        return 'warning';    // 橙色 - 偏低
      case PercentileLevel.p15toP50:
      case PercentileLevel.p50toP85:
        return 'normal';     // 绿色 - 正常
      case PercentileLevel.p85toP97:
        return 'warning';    // 橙色 - 偏高
      case PercentileLevel.aboveP97:
        return 'danger';     // 红色 - 需关注
    }
  }
}

/// 生长评估工具类
class GrowthAssessmentUtil {
  /// 评估体重
  static GrowthAssessment assessWeight(String gender, int ageInMonths, double weight) {
    final data = WHOGrowthData.getWeightForAge(gender, ageInMonths);
    if (data == null) {
      return const GrowthAssessment(
        percentileLevel: PercentileLevel.p15toP50,
        percentile: 50,
        status: '无法评估',
        description: '超出评估年龄范围',
      );
    }
    return _assessValue(weight, data, '体重');
  }

  /// 评估身高
  static GrowthAssessment assessHeight(String gender, int ageInMonths, double height) {
    final data = WHOGrowthData.getHeightForAge(gender, ageInMonths);
    if (data == null) {
      return const GrowthAssessment(
        percentileLevel: PercentileLevel.p15toP50,
        percentile: 50,
        status: '无法评估',
        description: '超出评估年龄范围',
      );
    }
    return _assessValue(height, data, '身高');
  }

  /// 评估头围
  static GrowthAssessment assessHeadCircumference(String gender, int ageInMonths, double headCircumference) {
    final data = WHOGrowthData.getHeadCircumferenceForAge(gender, ageInMonths);
    if (data == null) {
      return const GrowthAssessment(
        percentileLevel: PercentileLevel.p15toP50,
        percentile: 50,
        status: '无法评估',
        description: '超出评估年龄范围',
      );
    }
    return _assessValue(headCircumference, data, '头围');
  }

  /// 通用评估方法
  static GrowthAssessment _assessValue(double value, WHOGrowthDataPoint data, String metricName) {
    PercentileLevel level;
    double percentile;
    String status;
    String description;

    if (value < data.p3) {
      level = PercentileLevel.belowP3;
      percentile = 2;
      status = '偏低';
      description = '$metricName低于第3百分位，建议咨询医生';
    } else if (value < data.p15) {
      level = PercentileLevel.p3toP15;
      percentile = 10;
      status = '偏低';
      description = '$metricName处于第3-15百分位，略低于平均水平';
    } else if (value < data.p50) {
      level = PercentileLevel.p15toP50;
      percentile = 30;
      status = '正常';
      description = '$metricName处于第15-50百分位，在正常范围内';
    } else if (value < data.p85) {
      level = PercentileLevel.p50toP85;
      percentile = 65;
      status = '正常';
      description = '$metricName处于第50-85百分位，在正常范围内';
    } else if (value < data.p97) {
      level = PercentileLevel.p85toP97;
      percentile = 90;
      status = '偏高';
      description = '$metricName处于第85-97百分位，略高于平均水平';
    } else {
      level = PercentileLevel.aboveP97;
      percentile = 98;
      status = '偏高';
      description = '$metricName高于第97百分位，建议咨询医生';
    }

    return GrowthAssessment(
      percentileLevel: level,
      percentile: percentile,
      status: status,
      description: description,
    );
  }

  /// 计算生长趋势
  static String? calculateTrend(List<double> values, List<DateTime> dates) {
    if (values.length < 2 || dates.length < 2) return null;
    
    // 按日期排序
    final sortedIndices = List<int>.generate(dates.length, (i) => i)
      ..sort((a, b) => dates[a].compareTo(dates[b]));
    
    final sortedValues = sortedIndices.map((i) => values[i]).toList();
    final sortedDates = sortedIndices.map((i) => dates[i]).toList();
    
    // 计算最近两次的变化率
    final lastValue = sortedValues.last;
    final prevValue = sortedValues[sortedValues.length - 2];
    final lastDate = sortedDates.last;
    final prevDate = sortedDates[sortedDates.length - 2];
    
    final daysDiff = lastDate.difference(prevDate).inDays;
    if (daysDiff == 0) return null;
    
    final valueChange = lastValue - prevValue;
    final dailyChange = valueChange / daysDiff;
    
    if (dailyChange > 0.05) {
      return '增长较快';
    } else if (dailyChange > 0.01) {
      return '稳定增长';
    } else if (dailyChange > -0.01) {
      return '基本稳定';
    } else if (dailyChange > -0.05) {
      return '增长放缓';
    } else {
      return '下降明显';
    }
  }
}
