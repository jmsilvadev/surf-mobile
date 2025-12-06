import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/models/equipment_model.dart';
import 'package:surf_mobile/models/price_model.dart';

class CreateRentalDialog extends StatefulWidget {
  final int studentId;
  final int schoolId;

  const CreateRentalDialog({
    super.key,
    required this.studentId,
    required this.schoolId,
  });

  @override
  State<CreateRentalDialog> createState() => _CreateRentalDialogState();
}

class _CreateRentalDialogState extends State<CreateRentalDialog> {
  final _formKey = GlobalKey<FormState>();
  EquipmentModel? _selectedEquipment;
  DateTime? _startDate;
  DateTime? _endDate;
  int _quantity = 1;
  final _notesController = TextEditingController();
  List<EquipmentModel> _equipmentList = [];
  Map<int, PriceModel> _equipmentPrices = {}; // Maps equipment school_id to price
  bool _isLoading = false;
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      // First get prices with type "equipment".
      final prices = await apiService.getPrices(type: 'equipment');
      final activePrices = prices.where((p) => p.active).toList();
      
      if (activePrices.isEmpty) {
        setState(() {
          _loadingData = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No equipment prices available.')),
          );
        }
        return;
      }
      
      // Create a map of school_id to price (use first available price per school).
      final priceMap = <int, PriceModel>{};
      for (var price in activePrices) {
        if (!priceMap.containsKey(price.schoolId)) {
          priceMap[price.schoolId] = price;
        }
      }
      
      // Then get equipment and filter by schools that have equipment prices.
      final equipment = await apiService.getEquipment();
      final availableEquipment = equipment.where((e) {
        return e.active && 
               e.availableQuantity > 0 && 
               priceMap.containsKey(e.schoolId);
      }).toList();
      
      setState(() {
        _equipmentList = availableEquipment;
        _equipmentPrices = priceMap;
        _loadingData = false;
      });
    } catch (e) {
      setState(() {
        _loadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedEquipment == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    // Get the price for the selected equipment's school.
    final price = _equipmentPrices[_selectedEquipment!.schoolId];
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No price available for this equipment.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      await apiService.createRental(
        schoolId: widget.schoolId,
        studentId: widget.studentId,
        equipmentId: _selectedEquipment!.id,
        priceId: price.id,
        startDate: _startDate!,
        endDate: _endDate!,
        quantity: _quantity,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rental created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating rental: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Rental'),
      content: SizedBox(
        width: double.maxFinite,
        child: _loadingData
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<EquipmentModel>(
                        value: _selectedEquipment,
                        decoration: const InputDecoration(
                          labelText: 'Equipment *',
                          border: OutlineInputBorder(),
                        ),
                        items: _equipmentList.map((equipment) {
                          final price = _equipmentPrices[equipment.schoolId];
                          return DropdownMenuItem(
                            value: equipment,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(equipment.name),
                                Text(
                                  price != null
                                      ? '${equipment.availableQuantity} available - \$${price.amount.toStringAsFixed(2)}'
                                      : '${equipment.availableQuantity} available',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedEquipment = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select equipment.';
                          }
                          return null;
                        },
                      ),
                      if (_selectedEquipment != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Price: \$${(_equipmentPrices[_selectedEquipment!.schoolId]?.amount ?? 0).toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, true),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Start Date *',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _startDate != null
                                      ? DateFormat('MMM dd, yyyy').format(_startDate!)
                                      : 'Select date',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, false),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'End Date *',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _endDate != null
                                      ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                      : 'Select date',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _quantity.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Quantity *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final qty = int.tryParse(value);
                          if (qty != null && qty > 0) {
                            setState(() {
                              _quantity = qty;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity.';
                          }
                          final qty = int.tryParse(value);
                          if (qty == null || qty < 1) {
                            return 'Quantity must be at least 1.';
                          }
                          if (_selectedEquipment != null && qty > _selectedEquipment!.availableQuantity) {
                            return 'Quantity exceeds available equipment.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}

