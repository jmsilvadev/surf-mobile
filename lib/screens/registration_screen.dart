import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/services/auth_service.dart';
import 'package:surf_mobile/services/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _manualController = TextEditingController();
  final _taxController = TextEditingController();
  final _searchController = TextEditingController();

  bool _loading = false;
  String? _error;

  List<Map<String, dynamic>> _schools = [];
  List<Map<String, dynamic>> _filteredSchools = [];
  int? _selectedSchoolId;
  bool _manualMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSchools());
  }

  @override
  void dispose() {
    _manualController.dispose();
    _taxController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final list = await api.getSchools();
      if (mounted) {
        setState(() {
          _schools = list;
          _filteredSchools = List.from(_schools);
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error loading schools: $e');
      if (mounted) {
        setState(() {
          _schools = [];
          _filteredSchools = [];
        });
      }
    }
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = Provider.of<AuthService>(context, listen: false);
    final tax = _taxController.text.trim();
    String schoolText = _manualController.text.trim();

    if (!_manualMode) {
      if (_selectedSchoolId == null) {
        setState(() {
          _error = 'Escolha uma escola.';
          _loading = false;
        });
        return;
      }
      schoolText = _selectedSchoolId.toString();
    }

    int? schoolId;
    try {
      schoolId = int.parse(schoolText);
    } catch (_) {
      setState(() {
        _error = 'Informe um ID de escola numérico.';
        _loading = false;
      });
      return;
    }

    if (tax.isEmpty) {
      setState(() {
        _error = 'Informe o tax number.';
        _loading = false;
      });
      return;
    }

    final ok = await auth.completeRegistration(schoolId: schoolId, taxNumber: tax);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registro concluído')));
    } else {
      setState(() {
        _error = 'Falha no registro. Tente novamente.';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  void _onSearchChanged(String q) {
    final lower = q.toLowerCase();
    setState(() {
      _filteredSchools = _schools.where((s) => (s['name']?.toString() ?? '').toLowerCase().contains(lower)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completar registro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Sua conta precisa de uma escola atribuída. Escolha a escola e informe o tax number:'),
            const SizedBox(height: 12),

            // Schools list or manual input
            if (_schools.isEmpty || _manualMode) ...[
              TextField(
                controller: _manualController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'School ID (manual)'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() {
                  _manualMode = !_manualMode;
                  _filteredSchools = List.from(_schools);
                }),
                child: Text(_manualMode ? 'Voltar à lista' : 'Não encontrou? Informe manualmente'),
              ),
            ] else ...[
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar escolas...'),
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _filteredSchools.isEmpty
                    ? const Text('Nenhuma escola encontrada.')
                    : ListView(
                        shrinkWrap: true,
                        children: _filteredSchools.map((s) {
                          final id = s['id'] is int ? s['id'] as int : int.tryParse(s['id']?.toString() ?? '0') ?? 0;
                          return RadioListTile<int>(
                            title: Text(s['name']?.toString() ?? 'Escola $id'),
                            value: id,
                            groupValue: _selectedSchoolId,
                            onChanged: (v) => setState(() => _selectedSchoolId = v),
                          );
                        }).toList(),
                      ),
              ),
              TextButton(
                onPressed: () => setState(() => _manualMode = true),
                child: const Text('Não encontrou? Informe manualmente'),
              ),
            ],

            const SizedBox(height: 8),
            TextField(
              controller: _taxController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(labelText: 'Tax Number'),
            ),
            const SizedBox(height: 12),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
