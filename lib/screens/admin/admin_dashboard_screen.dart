import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/providers/admin_dashboard_provider.dart';
import 'package:surf_mobile/widgets/kip_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminDashboardProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text(provider.error!));
    }

    final stats = provider.stats;

    if (stats == null) {
      return const Center(child: Text('No data'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Dashboard',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              KpiCard(
                title: 'Students',
                value: stats.students.toString(),
                icon: Icons.people,
                color: Colors.blue,
              ),
              KpiCard(
                title: 'Teachers',
                value: stats.teachers.toString(),
                icon: Icons.school,
                color: Colors.green,
              ),
              KpiCard(
                title: 'Classes Created',
                value: stats.classesCreated.toString(),
                icon: Icons.class_,
                color: Colors.orange,
              ),
              KpiCard(
                title: 'Revenue',
                value: '€ ${stats.revenue.toStringAsFixed(2)}',
                icon: Icons.euro,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            'Classes per Month',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: provider.classesPerMonth
                    .asMap()
                    .entries
                    .map(
                      (entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.count.toDouble(),
                            width: 18,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    )
                    .toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= provider.classesPerMonth.length) {
                          return const SizedBox();
                        }
                        final month = provider.classesPerMonth[index].month;
                        return Text(
                          month.substring(5), // pega só MM
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Revenue by Type',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: provider.revenueByType.map((item) {
                  return PieChartSectionData(
                    value: item.amount,
                    title: item.type,
                    radius: 80,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
