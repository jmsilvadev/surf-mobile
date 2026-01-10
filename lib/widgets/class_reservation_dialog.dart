import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/models/class_model.dart';
import 'package:surf_mobile/providers/navigation_provider.dart';
import 'package:surf_mobile/utils/enrollment_receipt_pdf.dart';
import '../models/class_rule_model.dart';
import '../models/class_pack_purchase_model.dart';
import '../services/api_service.dart';
import '../services/user_provider.dart';

class ClassReservationDialog extends StatefulWidget {
  final int classId;
  final int studentId;
  final VoidCallback onSuccess;

  const ClassReservationDialog({
    super.key,
    required this.classId,
    required this.studentId,
    required this.onSuccess,
  });

  @override
  State<ClassReservationDialog> createState() => _ClassReservationDialogState();
}

class _ClassReservationDialogState extends State<ClassReservationDialog> {
  ClassModel? _class;
  List<ClassRule> rules = [];
  List<ClassPackPurchase> packs = [];
  bool accepted = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final api = context.read<ApiService>();

    final results = await Future.wait([
      api.getClassRules(widget.classId),
      api.getStudentPacks(widget.studentId),
      api.getClassById(widget.classId),
    ]);

    setState(() {
      rules = results[0] as List<ClassRule>;
      packs = (results[1] as List<ClassPackPurchase>)
          .where((p) => p.status == 'pending')
          .toList();
      _class = results[2] as ClassModel;
      loading = false;
    });
  }

  int get totalBalance => packs.fold(
        0,
        (sum, p) => sum + (p.lessonsTotal - p.lessonsUsed),
      );

  Future<void> _reserve() async {
    if (!accepted || totalBalance <= 0) return;

    final userProvider = context.read<UserProvider>();
    final api = context.read<ApiService>();
    setState(() => loading = true);

    try {
      await api.enrollStudentInClass(
        classId: widget.classId,
        studentId: widget.studentId,
      );

      final profile = userProvider.profile;
      final student = profile?.student;

      // 🧾 GERA PDF (igual ao frontend)
      await EnrollmentReceiptPdf.generate(
        schoolName: student?.school.name ?? 'Ocean Dojo School',
        studentName: student?.name ?? '',
        studentLevel: student?.skillLevel?.name ?? '',
        classId: _class!.id,
        teacherName: _class!.teacher.name,
        startDateTime: _class!.startDatetime,
      );

      widget.onSuccess();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to enroll in class')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Class Rules'),
      content: loading
          ? const CircularProgressIndicator()
          : SingleChildScrollView(
              child: Column(
                children: [
                  ...rules.map(
                    (r) => ListTile(
                      title: Text(r.title),
                      subtitle:
                          r.description != null ? Text(r.description!) : null,
                      trailing: r.mandatory
                          ? const Chip(
                              label: Text('Mandatory'),
                              backgroundColor: Colors.redAccent,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Lessons available: $totalBalance'),
                  CheckboxListTile(
                    value: accepted,
                    onChanged: (v) => setState(() => accepted = v ?? false),
                    title: const Text('I have read and accept the rules'),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () {
            context.read<NavigationProvider>().setIndex(0);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: accepted && totalBalance > 0 && !loading ? _reserve : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Accept & Reserve'),
        ),
      ],
    );
  }
}
