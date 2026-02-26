/// 默认疫苗定义
class DefaultVaccines {
  static const List<VaccineDef> vaccines = [
    VaccineDef('v1', '乙肝疫苗第1剂', '出生'),
    VaccineDef('v2', '卡介苗', '出生'),
    VaccineDef('v3', '乙肝疫苗第2剂', '1月龄'),
    VaccineDef('v4', '脊灰疫苗第1剂', '2月龄'),
    VaccineDef('v5', '脊灰疫苗第2剂', '3月龄'),
    VaccineDef('v6', '百白破疫苗第1剂', '3月龄'),
    VaccineDef('v7', '脊灰疫苗第3剂', '4月龄'),
    VaccineDef('v8', '百白破疫苗第2剂', '4月龄'),
    VaccineDef('v9', '百白破疫苗第3剂', '5月龄'),
    VaccineDef('v10', '乙肝疫苗第3剂', '6月龄'),
    VaccineDef('v11', 'A群流脑疫苗第1剂', '6月龄'),
    VaccineDef('v12', '麻腮风疫苗第1剂', '8月龄'),
    VaccineDef('v13', '乙脑减毒活疫苗第1剂', '8月龄'),
    VaccineDef('v14', 'A群流脑疫苗第2剂', '9月龄'),
    VaccineDef('v15', '百白破疫苗第4剂', '18月龄'),
    VaccineDef('v16', '麻腮风疫苗第2剂', '18月龄'),
    VaccineDef('v17', '甲肝减毒活疫苗', '18月龄'),
    VaccineDef('v18', '乙脑减毒活疫苗第2剂', '2岁'),
    VaccineDef('v19', 'A群C群流脑疫苗第1剂', '3岁'),
    VaccineDef('v20', '脊灰疫苗第4剂', '4岁'),
    VaccineDef('v21', '白破疫苗', '6岁'),
    VaccineDef('v22', 'A群C群流脑疫苗第2剂', '6岁'),
  ];

  static int get totalCount => vaccines.length;
}

/// 疫苗定义数据类
class VaccineDef {
  final String id;
  final String name;
  final String scheduledTime;
  
  const VaccineDef(this.id, this.name, this.scheduledTime);
}
