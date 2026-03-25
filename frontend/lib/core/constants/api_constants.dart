/// API Constants for the Dental Clinic application
class ApiConstants {
  ApiConstants._();

  // Backend Express API (for email, QR code features)
  // TODO: Update this to your deployed backend URL after deployment
  static const String backendBaseUrl = 'https://your-app.onrender.com';

  // Supabase Configuration
  static const String baseUrl = 'https://vnodgfveyntfktrrlbat.supabase.co';
  static const String supabaseKey =
      'sb_publishable_8RNFXWCB9p7eFiJJg_5x3w_ZdQ0sIH7';

  // Supabase API endpoints
  static const String supabaseAuth = '/auth/v1';
  static const String supabaseRest = '/rest/v1';

  // Endpoints - using Supabase REST API
  static const String login = '$supabaseAuth/token?grant_type=password';
  static const String register = '$supabaseAuth/signup';
  static const String refresh = '$supabaseAuth/token?grant_type=refresh_token';
  static const String logout = '$supabaseAuth/logout';

  // Table endpoints (Supabase REST)
  static const String patients = '$supabaseRest/patients';
  static const String patientSearch = '$supabaseRest/patients';
  static const String patientRecent = '$supabaseRest/patients';
  static const String patientFrequent = '$supabaseRest/patients';
  static const String patientIdentify = '$supabaseRest/patients';
  static const String patientEnroll = '$supabaseRest/patients';

  static const String appointments = '$supabaseRest/appointments';
  static const String appointmentsToday = '$supabaseRest/appointments';
  static const String appointmentsWeek = '$supabaseRest/appointments';

  // Note: Dashboard stats need to be computed client-side from patients/appointments
  static const String dashboardStats = '$supabaseRest/patients';
  static const String dashboardRecent = '$supabaseRest/patients';

  static const String treatments = '$supabaseRest/treatments';
  static const String payments = '$supabaseRest/payments';
  static const String users = '$supabaseRest/users';
  static const String userUpdate = '$supabaseAuth/user';
  static const String userProfile = '$supabaseAuth/v1/user';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Headers
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
  static const String apikey = 'apikey';
}
