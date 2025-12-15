import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/services/api_service.dart';
import 'package:surf_mobile/services/auth_service.dart';
import 'package:surf_mobile/services/user_provider.dart';

class SchoolSelectionScreen extends StatefulWidget {
  const SchoolSelectionScreen({super.key});

  @override
  State<SchoolSelectionScreen> createState() => _SchoolSelectionScreenState();
}

class _SchoolSelectionScreenState extends State<SchoolSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _schools = [];
  List<Map<String, dynamic>> _filteredSchools = [];
  bool _loadingSchools = true;
  bool _saving = false;
  String? _errorMessage;
  int? _selectedSchoolId;
  bool _initializedSelection = false;

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedSelection) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _selectedSchoolId = userProvider.schoolId;
      _initializedSelection = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    setState(() {
      _loadingSchools = true;
      _errorMessage = null;
    });
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final schools = await api.getSchools();
      if (!mounted) return;
      setState(() {
        _schools = schools;
        _filteredSchools = List.from(schools);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erro ao carregar escolas: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingSchools = false;
        });
      }
    }
  }

  void _filterSchools(String query) {
    final normalized = query.trim().toLowerCase();
    setState(() {
      _filteredSchools = _schools.where((school) {
        final name = school['name']?.toString().toLowerCase() ?? '';
        final id = school['id']?.toString() ?? '';
        return name.contains(normalized) || id.contains(normalized);
      }).toList();
    });
  }

  Future<void> _saveSelection() async {
    if (_selectedSchoolId == null) {
      setState(() {
        _errorMessage = 'Selecione uma escola antes de continuar.';
      });
      return;
    }
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.assignSchool(_selectedSchoolId!);
    if (!mounted) return;

    if (!success) {
      setState(() {
        _errorMessage =
            userProvider.updateError ?? 'Não foi possível atualizar a escola.';
        _saving = false;
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Escola atualizada com sucesso.')),
    );
    setState(() {
      _saving = false;
    });
  }

  Future<void> _signOut() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Selecione sua escola'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sua conta está marcada como estudante mas não possui escola associada. '
                'Escolha uma escola existente para continuar usando o aplicativo.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar por nome ou ID',
                  border: OutlineInputBorder(),
                ),
                onChanged: _filterSchools,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loadingSchools
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredSchools.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.school_outlined, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage ??
                                      'Nenhuma escola encontrada.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _loadSchools,
                                  child: const Text('Recarregar'),
                                )
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadSchools,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _filteredSchools.length,
                              itemBuilder: (context, index) {
                                final school = _filteredSchools[index];
                                final id = school['id'] is int
                                    ? school['id'] as int
                                    : int.tryParse(school['id']?.toString() ?? '') ?? 0;
                                final name = school['name']?.toString() ?? 'Escola $id';
                                final subtitle = school['tax_number']?.toString();
                                final isSelected = _selectedSchoolId == id;
                                return ListTile(
                                  leading: Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                  ),
                                  title: Text(name),
                                  subtitle: subtitle != null ? Text('Tax ID: $subtitle') : null,
                                  onTap: () => setState(() => _selectedSchoolId = id),
                                );
                              },
                            ),
                          ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _saving ? null : _saveSelection,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirmar escola'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
