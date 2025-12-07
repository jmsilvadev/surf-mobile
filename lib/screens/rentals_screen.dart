import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/models/rental_model.dart';
import 'package:surf_mobile/screens/create_rental_dialog.dart';

class RentalsScreen extends StatefulWidget {
  const RentalsScreen({super.key});

  @override
  State<RentalsScreen> createState() => _RentalsScreenState();
}

class _RentalsScreenState extends State<RentalsScreen> {
  List<RentalModel> _rentals = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _studentId;
  bool _showAllRentals = false;

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  Future<void> _loadRentals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      
      // TODO: Get student ID from authenticated user
      // For now, using a placeholder. In production, this should come from Firebase Auth user metadata
      _studentId = 1; // This should be fetched from user profile or API
      
      List<RentalModel> rentals;
      if (_showAllRentals || _studentId == null) {
        rentals = await apiService.getRentals();
      } else {
        rentals = await apiService.getStudentRentals(_studentId!);
      }

      setState(() {
        _rentals = rentals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading rentals: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rentals'),
        actions: [
          if (_studentId != null)
            IconButton(
              icon: Icon(_showAllRentals ? Icons.person : Icons.people),
              onPressed: () {
                setState(() {
                  _showAllRentals = !_showAllRentals;
                });
                _loadRentals();
              },
              tooltip: _showAllRentals ? 'Show My Rentals' : 'Show All Rentals',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRentals,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: _studentId != null
          ? FloatingActionButton(
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) => CreateRentalDialog(
                    studentId: _studentId!,
                    schoolId: 1, // TODO: Get from user profile
                  ),
                );
                if (result == true) {
                  _loadRentals();
                }
              },
              tooltip: 'Create Rental',
              child: const Icon(Icons.add),
            )
          : null,
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
                        onPressed: _loadRentals,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _rentals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No rentals found',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRentals,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _rentals.length,
                        itemBuilder: (context, index) {
                          final rental = _rentals[index];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(rental.status),
                                child: const Icon(Icons.surfing, color: Colors.white),
                              ),
                              title: Text(
                                'Rental #${rental.id}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Equipment ID: ${rental.equipmentId}'),
                                  Text('Quantity: ${rental.quantity}'),
                                  Text(
                                    '${DateFormat('MMM dd, yyyy').format(rental.startDate)} - ${DateFormat('MMM dd, yyyy').format(rental.endDate)}',
                                  ),
                                  Text('Status: ${rental.status}'),
                                  if (rental.notes != null && rental.notes!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Notes: ${rental.notes}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Icon(
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

