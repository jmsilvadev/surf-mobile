import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/models/class_student_model.dart';
import 'package:surf_mobile/models/class_model.dart';

class RegistrationsScreen extends StatefulWidget {
  const RegistrationsScreen({super.key});

  @override
  State<RegistrationsScreen> createState() => _RegistrationsScreenState();
}

class _RegistrationsScreenState extends State<RegistrationsScreen> {
  List<ClassStudentModel> _registrations = [];
  Map<int, ClassModel> _classDetails = {};
  bool _isLoading = true;
  String? _errorMessage;
  int? _studentId;

  @override
  void initState() {
    super.initState();
    _loadRegistrations();
  }

  Future<void> _loadRegistrations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      
      // TODO: Get student ID from authenticated user
      // For now, using a placeholder. In production, this should come from Firebase Auth user metadata
      _studentId = 1; // This should be fetched from user profile or API
      
      if (_studentId == null) {
        setState(() {
          _errorMessage = 'Student ID not found.';
          _isLoading = false;
        });
        return;
      }

      final registrations = await apiService.getStudentClasses(_studentId!);
      
      // Fetch class details for each registration
      final allClasses = await apiService.getClasses();
      final classMap = <int, ClassModel>{};
      for (var classItem in allClasses) {
        classMap[classItem.id] = classItem;
      }

      setState(() {
        _registrations = registrations;
        _classDetails = classMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading registrations: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Registrations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRegistrations,
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
                        onPressed: _loadRegistrations,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _registrations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No registrations found',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRegistrations,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _registrations.length,
                        itemBuilder: (context, index) {
                          final registration = _registrations[index];
                          final classDetail = _classDetails[registration.classId];

                          final canLeave = classDetail != null && 
                                          classDetail.status == 'scheduled';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: classDetail != null
                                    ? _getStatusColor(classDetail.status)
                                    : Colors.grey,
                                child: const Icon(Icons.surfing, color: Colors.white),
                              ),
                              title: Text(
                                classDetail != null
                                    ? 'Class #${classDetail.id}'
                                    : 'Class #${registration.classId}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: classDetail != null
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(
                                            classDetail.startDatetime,
                                          ),
                                        ),
                                        Text(
                                          '${DateFormat('HH:mm').format(classDetail.startDatetime)} - ${DateFormat('HH:mm').format(classDetail.endDatetime)}',
                                        ),
                                        Text('Status: ${classDetail.status}'),
                                      ],
                                    )
                                  : Text(
                                      'Registered: ${DateFormat('MMM dd, yyyy').format(registration.createdAt)}',
                                    ),
                              trailing: canLeave
                                  ? IconButton(
                                      icon: const Icon(Icons.exit_to_app, color: Colors.red),
                                      onPressed: () => _leaveClass(registration.classId),
                                      tooltip: 'Leave Class',
                                    )
                                  : Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey.shade400,
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Future<void> _leaveClass(int classId) async {
    if (!mounted) return;
    
    if (_studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student ID not found.')),
      );
      return;
    }

    if (!mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Class'),
        content: const Text('Are you sure you want to leave this class?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    
    if (confirmed != true) {
      return;
    }

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.removeStudentFromClass(classId, _studentId!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully left the class.')),
        );
        _loadRegistrations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error leaving class: $e')),
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

