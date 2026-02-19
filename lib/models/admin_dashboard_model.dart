class AdminDashboardStats {
  final int students;
  final int teachers;
  final int classesCreated;
  final int classesCompleted;
  final double avgStudentsPerClass;
  final int rentals;
  final double revenue;

  AdminDashboardStats({
    required this.students,
    required this.teachers,
    required this.classesCreated,
    required this.classesCompleted,
    required this.avgStudentsPerClass,
    required this.rentals,
    required this.revenue,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      students: json['students'] ?? 0,
      teachers: json['teachers'] ?? 0,
      classesCreated: json['classes_created'] ?? 0,
      classesCompleted: json['classes_completed'] ?? 0,
      avgStudentsPerClass: (json['avg_students_per_class'] ?? 0).toDouble(),
      rentals: json['rentals'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

class ClassesPerMonth {
  final String month;
  final int count;

  ClassesPerMonth({
    required this.month,
    required this.count,
  });

  factory ClassesPerMonth.fromJson(Map<String, dynamic> json) {
    return ClassesPerMonth(
      month: json['month'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class RevenueByType {
  final String type;
  final double amount;

  RevenueByType({
    required this.type,
    required this.amount,
  });

  factory RevenueByType.fromJson(Map<String, dynamic> json) {
    return RevenueByType(
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class TopEquipment {
  final String name;
  final int count;

  TopEquipment({
    required this.name,
    required this.count,
  });

  factory TopEquipment.fromJson(Map<String, dynamic> json) {
    return TopEquipment(
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class Charts {
  final List<ClassesPerMonth> classesPerMonth;
  final List<RevenueByType> revenueByType;
  final List<TopEquipment> topEquipment;

  Charts({
    required this.classesPerMonth,
    required this.revenueByType,
    required this.topEquipment,
  });
}

class AdminDashboardResponse {
  final AdminDashboardStats stats;

  final Charts charts;

  AdminDashboardResponse({
    required this.stats,
    required this.charts,
  });

  factory AdminDashboardResponse.fromJson(Map<String, dynamic> json) {
    final chartsJson = json['charts'] ?? {};

    return AdminDashboardResponse(
      stats: AdminDashboardStats.fromJson(json['stats'] ?? {}),
      charts: Charts(
        classesPerMonth:
            (chartsJson['classes_per_month'] as List<dynamic>? ?? [])
                .map((e) => ClassesPerMonth.fromJson(e))
                .toList(),
        revenueByType: (chartsJson['revenue_by_type'] as List<dynamic>? ?? [])
            .map((e) => RevenueByType.fromJson(e))
            .toList(),
        topEquipment: (chartsJson['top_equipment'] as List<dynamic>? ?? [])
            .map((e) => TopEquipment.fromJson(e))
            .toList(),
      ),
    );
  }
}
