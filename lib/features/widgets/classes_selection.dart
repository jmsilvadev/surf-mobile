import 'package:flutter/material.dart';
import 'package:surf_mobile/models/class_model.dart';

class ClassesSection extends StatelessWidget {
  final List<ClassModel> classes;

  const ClassesSection({super.key, required this.classes});

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('My Classes', style: TextStyle(fontSize: 18)),
        ...classes.map(
          (c) => ListTile(
            title: Text(c.price.type),
            subtitle: Text(c.teacher.name),
          ),
        ),
      ],
    );
  }
}
