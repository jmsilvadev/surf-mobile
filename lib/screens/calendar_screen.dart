import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/providers/class_pack_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/models/class_model.dart';
import 'package:surf_mobile/services/user_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<ClassModel> _classes = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _studentId;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _studentId = userProvider.studentId;
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final classes = await apiService.getClasses();
      // Filter out cancelled and completed classes.
      final filteredClasses = classes.where((classItem) {
        final status = classItem.status.toLowerCase();
        return status != 'cancelled' && status != 'completed';
      }).toList();
      setState(() {
        _classes = filteredClasses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading classes: $e';
        _isLoading = false;
      });
    }
  }

  List<ClassModel> _getClassesForDay(DateTime day) {
    return _classes.where((classItem) {
      final classDate = DateTime(
        classItem.startDatetime.year,
        classItem.startDatetime.month,
        classItem.startDatetime.day,
      );
      final selectedDate = DateTime(day.year, day.month, day.day);
      return classDate.isAtSameMomentAs(selectedDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClasses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadClasses,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    TableCalendar<ClassModel>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      calendarFormat: _calendarFormat,
                      eventLoader: _getClassesForDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarStyle: const CalendarStyle(
                        outsideDaysVisible: false,
                        todayDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),
                    const Divider(),
                    Expanded(
                      child: _buildClassList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildClassList() {
    final dayClasses = _getClassesForDay(_selectedDay);

    if (dayClasses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No classes scheduled for ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final packProvider = context.watch<ClassPackProvider>();
    if (!packProvider.hasCredits) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 12),
            const Text('You have no class credits'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/packs');
              },
              child: const Text('Buy a pack'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayClasses.length,
      itemBuilder: (context, index) {
        final classItem = dayClasses[index];
        final isEnrolled =
            _studentId != null && classItem.studentIds.contains(_studentId);
        final canJoin = _studentId != null &&
            !isEnrolled &&
            classItem.status == 'scheduled';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(classItem.status),
              child: const Icon(Icons.surfing, color: Colors.white),
            ),
            title: Text(
              'Class #${classItem.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('HH:mm').format(classItem.startDatetime)} - ${DateFormat('HH:mm').format(classItem.endDatetime)}',
                ),
                Text('Status: ${classItem.status}'),
                if (isEnrolled)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Chip(
                      label: const Text('Enrolled'),
                      backgroundColor: Colors.green.shade100,
                      labelStyle: TextStyle(color: Colors.green.shade900),
                    ),
                  ),
                if (classItem.notes != null && classItem.notes!.isNotEmpty)
                  Text(
                    'Notes: ${classItem.notes}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
            trailing: canJoin
                ? ElevatedButton.icon(
                    onPressed: () => _joinClass(classItem.id),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Join'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  )
                : Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                  ),
          ),
        );
      },
    );
  }

  Future<void> _joinClass(int classId) async {
    if (_studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student ID not found.')),
      );
      return;
    }

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.addStudentToClass(classId, _studentId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined the class!')),
        );
        _loadClasses();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining class: $e')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
