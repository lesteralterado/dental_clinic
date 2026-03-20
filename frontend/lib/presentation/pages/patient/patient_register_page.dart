import 'package:flutter/material.dart';

class PatientRegisterPage extends StatefulWidget {
  const PatientRegisterPage({super.key});

  @override
  State<PatientRegisterPage> createState() => _PatientRegisterPageState();
}

class _PatientRegisterPageState extends State<PatientRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  final _complaintController = TextEditingController();
  String? _selectedStatus;
  String? _selectedGender;

  final List<String> _statusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed'
  ];
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  void _savePatient() {
    if (_formKey.currentState!.validate()) {
      // Save patient logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Patient registered successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Patient'),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Personal Information Section
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Full Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Full name is required' : null,
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address *',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Address is required' : null,
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Phone number is required' : null,
            ),
            const SizedBox(height: 16),

            // Age and Gender Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age *',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.wc_outlined),
                    ),
                    items: _genderOptions
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedGender = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Occupation
            TextFormField(
              controller: _occupationController,
              decoration: const InputDecoration(
                labelText: 'Occupation',
                prefixIcon: Icon(Icons.work_outline),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Marital Status
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Marital Status',
                prefixIcon: Icon(Icons.favorite_outline),
              ),
              items: _statusOptions
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedStatus = v),
            ),
            const SizedBox(height: 24),

            // Complaint Section
            Text(
              'Complaint',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _complaintController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Initial Complaint',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.medical_services_outlined),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Register Button
            FilledButton.icon(
              onPressed: _savePatient,
              icon: const Icon(Icons.person_add),
              label: const Text('Register Patient'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
