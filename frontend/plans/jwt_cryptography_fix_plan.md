# Fix Plan: JWT Cryptography Operation Failed Error

## Problem Analysis

The error "JWT Cryptography operation failed" occurs after registering a new patient when the app tries to make an authenticated API call. This is a Supabase authentication error that typically happens when:

1. The JWT token is invalid or corrupted
2. There's a mismatch in how the JWT was created vs how it's being validated
3. The `flutter_secure_storage` is unable to properly store/retrieve the token on the Android platform

## Root Cause

Based on code analysis:

1. **Login Flow** (auth_repository.dart lines 20-39):
   - For mock users, tokens are generated locally via `_generateMockJwt()` in mock_data_repository.dart
   - For real Supabase users, tokens come from Supabase auth endpoint

2. **Patient Registration** (patient_repository.dart lines 220-249):
   - Uses the `ApiClient` which reads the token from secure storage
   - Adds the token to Authorization header via interceptor

3. **Token Storage** (api_client.dart lines 105-107):
   - Uses `FlutterSecureStorage` to store tokens
   - On Android, this uses AES encryption

The issue is likely that:
- Either the token stored is corrupted/invalid
- Or there's an issue with how the secure storage reads/writes the token
- Or the token refresh mechanism is failing

## Solution Plan

### Step 1: Add Error Handling in ApiClient Interceptor
Modify [`lib/core/network/api_client.dart`](lib/core/network/api_client.dart) to add better error handling:

- Add try-catch around token reading in the onRequest interceptor
- Add logging to identify the exact point of failure
- Handle specific DioException types more gracefully

### Step 2: Improve Token Storage
Add fallback handling in [`lib/core/network/api_client.dart`](lib/core/network/api_client.dart):

- Check if token is valid before adding to header
- Add a method to validate JWT format
- Clear invalid tokens and redirect to login

### Step 3: Enhance PatientRepository Error Handling
Modify [`lib/data/repositories/patient_repository.dart`](lib/data/repositories/patient_repository.dart):

- Add better error parsing in `_handleError()` method
- Handle specific Supabase errors like JWT expiration
- Provide clearer error messages

### Step 4: Improve User-Facing Error Messages
Modify [`lib/presentation/pages/patient/patient_register_page.dart`](lib/presentation/pages/patient/patient_register_page.dart):

- Show more user-friendly error messages
- Handle auth-related errors by prompting re-login
- Add retry functionality

## Implementation Notes

The key changes will be:
1. **api_client.dart**: Add token validation and better error handling in interceptors
2. **patient_repository.dart**: Improve error parsing and handling
3. **patient_register_page.dart**: Handle auth errors gracefully

This will prevent the cryptography error from appearing and provide better UX when token issues occur.
