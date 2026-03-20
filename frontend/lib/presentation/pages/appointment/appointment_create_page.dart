import 'package:flutter/material.dart';
import '../../../data/models/patient_model.dart';
import '../../../data/repositories/patient_repository.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../../di/injection_container.dart';

class AppointmentCreatePage extends StatefulWidget {
  const AppointmentCreatePage({super.key});

  @override
  State<AppointmentCreatePage> createState() => _AppointmentCreatePageState();
}

class _AppointmentCreatePageState extends State<AppointmentCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final PatientRepository _patientRepo = sl<PatientRepository>();
  final AppointmentRepository _appointmentRepo = sl<AppointmentRepository>();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  PatientModel? _selectedPatient;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _selectedDuration = 30;
  List<PatientModel> _patients = [];
  bool _isLoading = true;
  bool _isSaving = false;

  final List<int> _durationOptions = [15, 30, 45, 60, 90];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final result = await _patientRepo.getPatients(limit: 100);
      setState(() {
        _patients = result.patients;
        _isLoading = false;
        if (_patients.isNotEmpty) {
          _selectedPatient = _patients.first;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveAppointment() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPatient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a patient'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final timeString =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

      _appointmentRepo.createAppointment(
        patientId: _selectedPatient!.id,
        appointmentDate: _selectedDate,
        appointmentTime: timeString,
        duration: _selectedDuration,
        reason:
            _reasonController.text.isNotEmpty ? _reasonController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Appointment created successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.pop(
          context, true); // Return true to indicate appointment was created
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final patients = _patients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Appointment'),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Patient Selection Section
            Text(
              'Patient Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Patient Dropdown
            DropdownButtonFormField<PatientModel>(
              value: _selectedPatient,
              decoration: const InputDecoration(
                labelText: 'Select Patient *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: patients
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.name),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedPatient = v),
              validator: (v) => v == null ? 'Please select a patient' : null,
            ),
            const SizedBox(height: 24),

            // Schedule Section
            Text(
              'Schedule',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Date Picker
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date *',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time Picker
            InkWell(
              onTap: _selectTime,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Time *',
                  prefixIcon: Icon(Icons.access_time_outlined),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime.format(context),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Duration Dropdown
            DropdownButtonFormField<int>(
              value: _selectedDuration,
              decoration: const InputDecoration(
                labelText: 'Duration',
                prefixIcon: Icon(Icons.timer_outlined),
              ),
              items: _durationOptions
                  .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text('$d minutes'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedDuration = v ?? 30),
            ),
            const SizedBox(height: 24),

            // Appointment Details Section
            Text(
              'Appointment Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Reason
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Visit',
                prefixIcon: Icon(Icons.medical_services_outlined),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.notes_outlined),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Create Button
            FilledButton.icon(
              onPressed: _saveAppointment,
              icon: const Icon(Icons.add),
              label: const Text('Create Appointment'),
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
