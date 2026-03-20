import 'package:flutter/material.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/mock_data_repository.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final _searchController = TextEditingController();
  final _mockRepo = MockDataRepository();
  List<PatientModel> _patients = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  void _loadPatients() {
    setState(() {
      _patients = _mockRepo.getAllPatients();
    });
  }

  List<PatientModel> get _filteredPatients {
    if (_searchQuery.isEmpty) {
      return _patients;
    }
    return _mockRepo.searchPatients(_searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search patients...',
              leading: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              trailing: _searchController.text.isNotEmpty
                  ? [
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                    ]
                  : null,
              onChanged: (value) => setState(() => _searchQuery = value),
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(
                colorScheme.surfaceContainerHighest.withOpacity(0.5),
              ),
            ),
          ),

          // Patient List
          Expanded(
            child: _filteredPatients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No patients found',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant
                                        .withOpacity(0.7),
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = _filteredPatients[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          elevation: 0,
                          color: colorScheme.surfaceContainerLow,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              radius: 24,
                              child: Text(
                                patient.initials,
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            title: Text(
                              patient.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            subtitle: Text(
                              'Age: ${patient.age} • ${patient.telephone}',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: patient.isFrequent
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.chevron_right,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ],
                                  )
                                : Icon(
                                    Icons.chevron_right,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            onTap: () {},
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/patient/register'),
        icon: const Icon(Icons.add),
        label: const Text('Add Patient'),
      ),
    );
  }
}
