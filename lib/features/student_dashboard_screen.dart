import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/features/models/student_pack_dashboard_item.dart';
import 'package:surf_mobile/features/widgets/classes_selection.dart';
import 'package:surf_mobile/features/widgets/kpi_cards.dart';
import 'package:surf_mobile/features/widgets/packs_section.dart';
import 'package:surf_mobile/features/widgets/payments_section.dart';
import 'package:surf_mobile/features/widgets/quick_actions.dart';
import 'package:surf_mobile/features/widgets/rentals_section.dart';
import 'package:surf_mobile/features/widgets/student_header.dart';
import 'package:surf_mobile/models/class_model.dart';
import 'package:surf_mobile/models/student_deposit_model.dart';
import 'package:surf_mobile/providers/class_pack_provider.dart';
import 'package:surf_mobile/providers/rentals_provider.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/services/auth_service.dart';

class StudentDashboardPage extends StatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  bool loading = true;

  List<StudentPackDashboardItem> packs = [];
  List<StudentDeposit> deposits = [];
  List<ClassModel> classes = [];
  // List<RentalModel> rentals = [];

  @override
  void initState() {
    super.initState();

    final session = context.read<AuthService>().session!;
    final schoolId = session.profile!.schoolId;
    final studentId = session.profile!.id;

    context.read<ClassPackProvider>().load(schoolId);

    // carrega rentals via provider
    context.read<RentalsProvider>().loadStudentRentals(studentId);

    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final session = context.read<AuthService>().session!;
    final studentId = session.profile!.id;
    final api = context.read<ApiService>();

    try {
      final results = await Future.wait([
        //  api.getStudentPacks(studentId),
        api.getStudentDeposits(studentId),
        api.getClasses(),
      ]);

      setState(() {
        //   packs = results[0] as List<StudentPackDashboardItem>;
        deposits = results[0] as List<StudentDeposit>;
        classes = (results[1] as List<ClassModel>)
            .where((c) => c.studentIds?.contains(studentId) ?? false)
            .toList();
        loading = false;
      });
    } catch (e) {
      debugPrint('Dashboard error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rentalsProvider = context.watch<RentalsProvider>();
    if (loading || rentalsProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final packProvider = context.watch<ClassPackProvider>();

    final dashboardPacks = packProvider.dashboardItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const StudentHeader(),
            const SizedBox(height: 16),
            KpiCards(packs: dashboardPacks, classes: classes),
            const SizedBox(height: 16),
            const QuickActions(),
            const SizedBox(height: 24),
            PacksSection(packs: dashboardPacks),
            ClassesSection(classes: classes),
            RentalsSection(rentals: rentalsProvider.rentals),
            PaymentsSection(deposits: deposits),
          ],
        ),
      ),
    );
  }
}
