# JWT Error Fix Plan

## Problem
After login, the Home tab displays: `Error: Expected 3 parts in JWT; got 1`

## Root Cause
The mock tokens generated during login (e.g., `mock-access-token-user-1`) are not valid JWT tokens. Valid JWT tokens have 3 parts separated by dots: `header.payload.signature`. When the app makes API calls to Supabase using these mock tokens, Supabase tries to validate them as JWT and fails.

## Solution (User Approved: Both)
1. **Solution 1**: Generate valid JWT format tokens for mock users
2. **Solution 2**: Bypass Supabase API calls when using mock credentials - return mock data directly

---

## Implementation Steps

### Step 1: Update mock_data_repository.dart to generate valid JWT tokens

**File**: `lib/data/repositories/mock_data_repository.dart`

**Changes needed**:
- Create a helper function to generate valid JWT format tokens
- JWT format: `base64(header).base64(payload).base64(signature)`
- Update the `authenticate()` method to use proper JWT format tokens

**JWT generation helper**:
```dart
String _generateMockJwt(String userId) {
  // Header
  final header = {
    'alg': 'HS256',
    'typ': 'JWT'
  };
  
  // Payload
  final payload = {
    'sub': userId,
    'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'exp': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
  };
  
  // Encode to base64url (without padding)
  final headerEncoded = base64UrlEncode(json.encode(header));
  final payloadEncoded = base64UrlEncode(json.encode(payload));
  final signatureEncoded = base64UrlEncode('mock_signature_$userId');
  
  return '$headerEncoded.$payloadEncoded.$signatureEncoded';
}
```

---

### Step 2: Add mock mode detection in ApiClient

**File**: `lib/core/network/api_client.dart`

**Changes needed**:
- Add a method to check if the current token is a mock token
- Add a flag to track mock mode
- When in mock mode, skip adding Authorization header (or use a different approach)

```dart
bool get isMockMode {
  // Check if the stored token is a mock token
  // This needs to be async or stored as a property
}
```

---

### Step 3: Update DashboardRepository to use mock data in mock mode

**File**: `lib/data/repositories/dashboard_repository.dart`

**Changes needed**:
- Inject MockDataRepository
- Check if in mock mode (token starts with "mock-")
- In mock mode, return computed stats from mock data instead of making API calls

```dart
class DashboardRepository {
  final ApiClient _apiClient;
  final MockDataRepository _mockDataRepo;
  
  // In mock mode, compute stats from mock data
  Future<DashboardStats> getStats() async {
    final token = await _apiClient.getAccessToken();
    if (token != null && token.startsWith('mock-')) {
      // Return mock stats
      return _computeMockStats();
    }
    // ... original API call
  }
  
  DashboardStats _computeMockStats() {
    final patients = _mockDataRepo.getAllPatients();
    final appointments = _mockDataRepo.getAllAppointments();
    final today = DateTime.now();
    final todayAppts = appointments.where((a) => 
      a.appointmentDate.year == today.year &&
      a.appointmentDate.month == today.month &&
      a.appointmentDate.day == today.day
    ).toList();
    
    return DashboardStats(
      totalPatients: patients.length,
      todayAppointments: todayAppts.length,
      completedToday: todayAppts.where((a) => a.status == 'completed').length,
      pendingPayments: 0,
    );
  }
}
```

---

### Step 4: Update PatientRepository to use mock data in mock mode

**File**: `lib/data/repositories/patient_repository.dart`

**Changes needed**:
- Inject MockDataRepository
- Check mock mode and return mock patients directly

```dart
Future<PaginatedPatients> getPatients({int page = 1, int limit = 20, String? search}) async {
  final token = await _apiClient.getAccessToken();
  if (token != null && token.startsWith('mock-')) {
    return _getMockPatients(page, limit, search);
  }
  // ... original API call
}

Future<List<PatientModel>> getRecentPatients({int limit = 5}) async {
  final token = await _apiClient.getAccessToken();
  if (token != null && token.startsWith('mock-')) {
    final patients = _mockDataRepo.getAllPatients();
    patients.sort((a, b) => (b.updatedAt ?? b.createdAt).compareTo(a.updatedAt ?? a.createdAt));
    return patients.take(limit).toList();
  }
  // ... original API call
}
```

---

### Step 5: Update AppointmentRepository to use mock data in mock mode

**File**: `lib/data/repositories/appointment_repository.dart`

**Changes needed**:
- Inject MockDataRepository
- Check mock mode and return mock appointments directly

```dart
Future<List<AppointmentModel>> getTodayAppointments() async {
  final token = await _apiClient.getAccessToken();
  if (token != null && token.startsWith('mock-')) {
    return _getMockTodayAppointments();
  }
  // ... original API call
}

List<AppointmentModel> _getMockTodayAppointments() {
  final allAppointments = _mockDataRepo.getAllAppointments();
  final today = DateTime.now();
  return allAppointments.where((a) => 
    a.appointmentDate.year == today.year &&
    a.appointmentDate.month == today.month &&
    a.appointmentDate.day == today.day
  ).toList();
}
```

---

## Files to Modify

1. `lib/data/repositories/mock_data_repository.dart` - Generate valid JWT tokens
2. `lib/data/repositories/dashboard_repository.dart` - Add mock mode support
3. `lib/data/repositories/patient_repository.dart` - Add mock mode support
4. `lib/data/repositories/appointment_repository.dart` - Add mock mode support

## Dependencies
- May need to add `dart:convert` for JSON encoding in mock_data_repository.dart (check if already imported)
- Base64 encoding should use base64url encoding (no padding)

---

## Testing Checklist

- [ ] Login with mock credentials (admin@dental.com / admin123) - should work without JWT error
- [ ] Home page should display stats correctly (from mock data)
- [ ] Recent patients should show mock patients
- [ ] Today's appointments should show mock appointments
- [ ] Patient list should show mock patients
- [ ] Appointment list should show mock appointments

---

## Mermaid Diagram: Flow After Fix

```mermaid
graph TD
    A[User Logs In] --> B{Using Mock Credentials?}
    B -->|Yes| C[Generate Valid JWT Token]
    B -->|No| D[Use Supabase Auth]
    C --> E[Store JWT in Secure Storage]
    D --> E
    E --> F[Home Page Loads]
    F --> G{Token is Mock?}
    G -->|Yes| H[Return Mock Data Directly]
    G -->|No| I[Make API Calls to Supabase]
    H --> J[Display Dashboard]
    I --> J