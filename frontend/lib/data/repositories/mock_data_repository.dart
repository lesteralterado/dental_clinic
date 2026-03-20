import '../models/user_model.dart';
import '../models/patient_model.dart';
import '../models/appointment_model.dart';

/// Mock data repository for hardcoded data
/// This replaces all API calls with local hardcoded data
class MockDataRepository {
  // Singleton pattern
  static final MockDataRepository _instance = MockDataRepository._internal();
  factory MockDataRepository() => _instance;
  MockDataRepository._internal();

  // Hardcoded users for login
  // Email: admin@dental.com, Password: admin123
  final List<Map<String, dynamic>> _users = [
    {
      'id': 'user-1',
      'email': 'admin@dental.com',
      'password': 'admin123',
      'name': 'Admin User',
      'role': 'admin',
      'isActive': true,
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
    },
    {
      'id': 'user-2',
      'email': 'doctor@dental.com',
      'password': 'doctor123',
      'name': 'Dr. Sarah Johnson',
      'role': 'doctor',
      'isActive': true,
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
    },
    {
      'id': 'user-3',
      'email': 'receptionist@dental.com',
      'password': 'reception123',
      'name': 'Maria Garcia',
      'role': 'receptionist',
      'isActive': true,
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
    },
  ];

  // Hardcoded patients
  final List<PatientModel> patients = [
    PatientModel(
      id: 'patient-1',
      qrCode: 'DC-12345678-1234-1234-1234-123456789012',
      name: 'John Doe',
      address: '123 Main St, City',
      telephone: '09123456789',
      age: 35,
      occupation: 'Engineer',
      status: 'Active',
      complaint: 'Toothache',
      gender: 'Male',
      email: 'john.doe@example.com',
      emergencyContact: 'Jane Doe',
      emergencyPhone: '09876543210',
      medicalNotes: 'No allergies',
      allergies: null,
      isFrequent: true,
      lastVisit: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    PatientModel(
      id: 'patient-2',
      qrCode: 'DC-12345678-1234-1234-1234-123456789013',
      name: 'Jane Smith',
      address: '456 Oak Ave, City',
      telephone: '09123456780',
      age: 28,
      occupation: 'Teacher',
      status: 'Active',
      complaint: 'Regular checkup',
      gender: 'Female',
      email: 'jane.smith@example.com',
      emergencyContact: 'John Smith',
      emergencyPhone: '09876543211',
      medicalNotes: 'Allergic to penicillin',
      allergies: 'Penicillin',
      isFrequent: true,
      lastVisit: DateTime.now().subtract(const Duration(days: 7)),
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    PatientModel(
      id: 'patient-3',
      qrCode: 'DC-12345678-1234-1234-1234-123456789014',
      name: 'Michael Brown',
      address: '789 Pine Rd, City',
      telephone: '09123456781',
      age: 45,
      occupation: 'Businessman',
      status: 'Active',
      complaint: 'Dental cleaning',
      gender: 'Male',
      email: 'michael.brown@example.com',
      emergencyContact: 'Susan Brown',
      emergencyPhone: '09876543212',
      medicalNotes: 'Diabetes type 2',
      allergies: null,
      isFrequent: false,
      lastVisit: DateTime.now().subtract(const Duration(days: 14)),
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    PatientModel(
      id: 'patient-4',
      qrCode: 'DC-12345678-1234-1234-1234-123456789015',
      name: 'Emily Davis',
      address: '321 Elm St, City',
      telephone: '09123456782',
      age: 23,
      occupation: 'Student',
      status: 'Active',
      complaint: 'Wisdom tooth pain',
      gender: 'Female',
      email: 'emily.davis@example.com',
      emergencyContact: 'Robert Davis',
      emergencyPhone: '09876543213',
      medicalNotes: 'No known allergies',
      allergies: null,
      isFrequent: true,
      lastVisit: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    PatientModel(
      id: 'patient-5',
      qrCode: 'DC-12345678-1234-1234-1234-123456789016',
      name: 'Robert Wilson',
      address: '654 Maple Dr, City',
      telephone: '09123456783',
      age: 52,
      occupation: 'Accountant',
      status: 'Active',
      complaint: 'Cavity treatment',
      gender: 'Male',
      email: 'robert.wilson@example.com',
      emergencyContact: 'Mary Wilson',
      emergencyPhone: '09876543214',
      medicalNotes: 'High blood pressure',
      allergies: 'Aspirin',
      isFrequent: false,
      lastVisit: DateTime.now().subtract(const Duration(days: 21)),
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now().subtract(const Duration(days: 21)),
    ),
    PatientModel(
      id: 'patient-6',
      qrCode: 'DC-12345678-1234-1234-1234-123456789017',
      name: 'Lisa Anderson',
      address: '987 Cedar Ln, City',
      telephone: '09123456784',
      age: 31,
      occupation: 'Nurse',
      status: 'Active',
      complaint: 'Root canal',
      gender: 'Female',
      email: 'lisa.anderson@example.com',
      emergencyContact: 'Tom Anderson',
      emergencyPhone: '09876543215',
      medicalNotes: 'Healthy',
      allergies: null,
      isFrequent: true,
      lastVisit: DateTime.now().subtract(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PatientModel(
      id: 'patient-7',
      qrCode: 'DC-12345678-1234-1234-1234-123456789018',
      name: 'David Martinez',
      address: '147 Birch St, City',
      telephone: '09123456785',
      age: 40,
      occupation: 'Architect',
      status: 'Active',
      complaint: 'Dental crown',
      gender: 'Male',
      email: 'david.martinez@example.com',
      emergencyContact: 'Ana Martinez',
      emergencyPhone: '09876543216',
      medicalNotes: 'No allergies',
      allergies: null,
      isFrequent: false,
      lastVisit: DateTime.now().subtract(const Duration(days: 10)),
      createdAt: DateTime.now().subtract(const Duration(days: 75)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    PatientModel(
      id: 'patient-8',
      qrCode: 'DC-12345678-1234-1234-1234-123456789019',
      name: 'Jennifer Taylor',
      address: '258 Willow Ave, City',
      telephone: '09123456786',
      age: 29,
      occupation: 'Lawyer',
      status: 'Active',
      complaint: 'Teeth whitening',
      gender: 'Female',
      email: 'jennifer.taylor@example.com',
      emergencyContact: 'Mark Taylor',
      emergencyPhone: '09876543217',
      medicalNotes: 'Asthma',
      allergies: null,
      isFrequent: true,
      lastVisit: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 55)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    PatientModel(
      id: 'patient-9',
      qrCode: 'DC-12345678-1234-1234-1234-123456789020',
      name: 'Christopher Lee',
      address: '369 Spruce Rd, City',
      telephone: '09123456787',
      age: 55,
      occupation: 'Professor',
      status: 'Active',
      complaint: 'Denture fitting',
      gender: 'Male',
      email: 'christopher.lee@example.com',
      emergencyContact: 'Linda Lee',
      emergencyPhone: '09876543218',
      medicalNotes: 'Heart condition',
      allergies: 'Codeine',
      isFrequent: false,
      lastVisit: DateTime.now().subtract(const Duration(days: 28)),
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      updatedAt: DateTime.now().subtract(const Duration(days: 28)),
    ),
    PatientModel(
      id: 'patient-10',
      qrCode: 'DC-12345678-1234-1234-1234-123456789021',
      name: 'Sarah Thompson',
      address: '741 Ash Dr, City',
      telephone: '09123456788',
      age: 38,
      occupation: 'Marketing Manager',
      status: 'Active',
      complaint: 'Regular checkup',
      gender: 'Female',
      email: 'sarah.thompson@example.com',
      emergencyContact: 'James Thompson',
      emergencyPhone: '09876543219',
      medicalNotes: 'Healthy',
      allergies: null,
      isFrequent: true,
      lastVisit: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Hardcoded appointments
  List<AppointmentModel> get appointments {
    final now = DateTime.now();
    return [
      AppointmentModel(
        id: 'apt-1',
        patientId: 'patient-1',
        dentistId: 'user-1',
        appointmentDate: now,
        appointmentTime: '09:00',
        duration: 30,
        status: AppointmentStatus.scheduled,
        reason: 'Tooth extraction',
        notes: 'First visit',
        isCheckedIn: false,
        checkedInAt: null,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
        patient: patients[0],
      ),
      AppointmentModel(
        id: 'apt-2',
        patientId: 'patient-2',
        dentistId: 'user-1',
        appointmentDate: now,
        appointmentTime: '10:30',
        duration: 30,
        status: AppointmentStatus.confirmed,
        reason: 'Regular checkup',
        notes: null,
        isCheckedIn: true,
        checkedInAt: now.subtract(const Duration(minutes: 30)),
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        patient: patients[1],
      ),
      AppointmentModel(
        id: 'apt-3',
        patientId: 'patient-4',
        dentistId: 'user-2',
        appointmentDate: now,
        appointmentTime: '11:00',
        duration: 45,
        status: AppointmentStatus.inProgress,
        reason: 'Wisdom tooth extraction',
        notes: 'Patient has anxiety',
        isCheckedIn: true,
        checkedInAt: now.subtract(const Duration(minutes: 15)),
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now,
        patient: patients[3],
      ),
      AppointmentModel(
        id: 'apt-4',
        patientId: 'patient-6',
        dentistId: 'user-1',
        appointmentDate: now,
        appointmentTime: '14:00',
        duration: 60,
        status: AppointmentStatus.scheduled,
        reason: 'Root canal treatment',
        notes: 'Second session',
        isCheckedIn: false,
        checkedInAt: null,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 2)),
        patient: patients[5],
      ),
      AppointmentModel(
        id: 'apt-5',
        patientId: 'patient-8',
        dentistId: 'user-2',
        appointmentDate: now,
        appointmentTime: '15:30',
        duration: 30,
        status: AppointmentStatus.scheduled,
        reason: 'Teeth cleaning',
        notes: null,
        isCheckedIn: false,
        checkedInAt: null,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 1)),
        patient: patients[7],
      ),
      AppointmentModel(
        id: 'apt-6',
        patientId: 'patient-3',
        dentistId: 'user-1',
        appointmentDate: now.add(const Duration(days: 1)),
        appointmentTime: '09:30',
        duration: 30,
        status: AppointmentStatus.scheduled,
        reason: 'Dental cleaning',
        notes: null,
        isCheckedIn: false,
        checkedInAt: null,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
        patient: patients[2],
      ),
      AppointmentModel(
        id: 'apt-7',
        patientId: 'patient-5',
        dentistId: 'user-2',
        appointmentDate: now.add(const Duration(days: 1)),
        appointmentTime: '11:00',
        duration: 45,
        status: AppointmentStatus.scheduled,
        reason: 'Cavity filling',
        notes: 'Multiple cavities',
        isCheckedIn: false,
        checkedInAt: null,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
        patient: patients[4],
      ),
      AppointmentModel(
        id: 'apt-8',
        patientId: 'patient-7',
        dentistId: 'user-1',
        appointmentDate: now.add(const Duration(days: 2)),
        appointmentTime: '10:00',
        duration: 60,
        status: AppointmentStatus.scheduled,
        reason: 'Crown placement',
        notes: 'Temporary crown in place',
        isCheckedIn: false,
        checkedInAt: null,
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 14)),
        patient: patients[6],
      ),
      AppointmentModel(
        id: 'apt-9',
        patientId: 'patient-9',
        dentistId: 'user-2',
        appointmentDate: now.add(const Duration(days: 3)),
        appointmentTime: '13:00',
        duration: 45,
        status: AppointmentStatus.scheduled,
        reason: 'Denture adjustment',
        notes: 'New dentures',
        isCheckedIn: false,
        checkedInAt: null,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
        patient: patients[8],
      ),
      AppointmentModel(
        id: 'apt-10',
        patientId: 'patient-10',
        dentistId: 'user-1',
        appointmentDate: now.add(const Duration(days: 4)),
        appointmentTime: '09:00',
        duration: 30,
        status: AppointmentStatus.scheduled,
        reason: 'Regular checkup',
        notes: null,
        isCheckedIn: false,
        checkedInAt: null,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        patient: patients[9],
      ),
    ];
  }

  // Authenticate user with email and password
  Map<String, dynamic>? authenticate(String email, String password) {
    final user = _users.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => <String, dynamic>{},
    );

    if (user.isEmpty) {
      return null;
    }

    // Return user data without password
    return {
      'id': user['id'],
      'email': user['email'],
      'name': user['name'],
      'role': user['role'],
      'isActive': user['isActive'],
      'createdAt': user['createdAt'],
      'updatedAt': user['updatedAt'],
      'accessToken': 'mock-access-token-${user['id']}',
      'refreshToken': 'mock-refresh-token-${user['id']}',
    };
  }

  // Get all patients
  List<PatientModel> getAllPatients() {
    return patients;
  }

  // Get patient by ID
  PatientModel? getPatientById(String id) {
    try {
      return patients.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search patients
  List<PatientModel> searchPatients(String query) {
    final lowerQuery = query.toLowerCase();
    return patients.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          p.telephone.contains(query) ||
          (p.email?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Get recent patients
  List<PatientModel> getRecentPatients({int limit = 5}) {
    final sorted = List<PatientModel>.from(patients)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(limit).toList();
  }

  // Get frequent patients
  List<PatientModel> getFrequentPatients() {
    return patients.where((p) => p.isFrequent).toList();
  }

  // Get all appointments
  List<AppointmentModel> getAllAppointments() {
    return appointments;
  }

  // Get appointments for today
  List<AppointmentModel> getTodayAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return appointments.where((a) {
      final aptDate = DateTime(
        a.appointmentDate.year,
        a.appointmentDate.month,
        a.appointmentDate.day,
      );
      return aptDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Get appointments by date
  List<AppointmentModel> getAppointmentsByDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);

    return appointments.where((a) {
      final aptDate = DateTime(
        a.appointmentDate.year,
        a.appointmentDate.month,
        a.appointmentDate.day,
      );
      return aptDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  // Get appointments by patient ID
  List<AppointmentModel> getAppointmentsByPatientId(String patientId) {
    return appointments.where((a) => a.patientId == patientId).toList();
  }

  // Get dashboard stats
  Map<String, int> getDashboardStats() {
    return {
      'totalPatients': patients.length,
      'todayAppointments': getTodayAppointments().length,
      'frequentPatients': getFrequentPatients().length,
      'completedAppointments': appointments
          .where((a) => a.status == AppointmentStatus.completed)
          .length,
    };
  }
}
