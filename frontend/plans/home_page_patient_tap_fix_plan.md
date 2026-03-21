# Home Page Patient Navigation Fix Plan

## Issue Summary

In [`home_page.dart`](lib/presentation/pages/home_page.dart), there are two non-functional elements:

1. **"See All" button** (line 243): Has empty callback `onPressed: () {}`
2. **Recent Patients list items** (line 286): Has empty callback `onTap: () {}`

---

## Analysis

### Current State

```dart
// Line 242-245 - See All button
TextButton(
  onPressed: () {},  // ❌ EMPTY - should navigate
  child: const Text('See All'),
),

// Line 264-287 - Recent Patient item
ListTile(
  // ...
  onTap: () {},  // ❌ EMPTY - should show details
),
```

### Root Cause

Both callbacks are empty, so tapping these elements does nothing.

---

## Solution Options

I will implement **both options** for you to choose from:

### Option A: Quick Navigation (Simpler)
- **See All**: Navigate to Patients tab (index 1 in bottom nav)
- **Patient Tap**: Navigate to PatientListPage

### Option B: Detail Modal (More polished)
- **See All**: Navigate to PatientListPage
- **Patient Tap**: Show modal bottom sheet with patient details

---

## Implementation Details

### Option A: Quick Navigation

**File**: [`home_page.dart`](lib/presentation/pages/home_page.dart:242)

**Changes:**

| Location | Current | Change To |
|----------|---------|-----------|
| Line 243 (See All) | `onPressed: () {}` | `onPressed: () => _navigateToTab(1)` |
| Line 286 (Patient tap) | `onTap: () {}` | `onTap: () => _navigateToPatientDetails(patient)` |

**New methods needed:**
- `_navigateToTab(int index)` - Use `DefaultTabController` or pass callback to parent
- `_navigateToPatientDetails(PatientModel patient)` - Navigate to PatientListPage with patient

### Option B: Detail Modal (Following appointment_list_page.dart pattern)

**File**: [`home_page.dart`](lib/presentation/pages/home_page.dart:79)

**Changes:**

| Location | Current | Change To |
|----------|---------|-----------|
| Line 80 | `List<dynamic> _recentPatients` | `List<PatientModel> _recentPatients` |
| Line 243 | `onPressed: () {}` | `onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientListPage()))` |
| Line 286 | `onTap: () {}` | `onTap: () => _showPatientDetails(context, patient)` |

**New methods needed:**
- `_showPatientDetails(BuildContext context, PatientModel patient)` - Similar to [`_showAppointmentDetails`](lib/presentation/pages/appointment/appointment_list_page.dart:79) in appointment_list_page.dart

**Patient Details to Display in Modal:**
| Field | Icon |
|-------|------|
| Name | `Icons.person` |
| Age / Gender | `Icons.cake` |
| Telephone | `Icons.phone` |
| Address | `Icons.location_on` |
| Email | `Icons.email` |
| Occupation | `Icons.work` |
| Status | `Icons.medical_information` |
| Complaint | `Icons.description` |
| Allergies | `Icons.warning_amber` |
| Emergency Contact | `Icons.emergency` |
| Last Visit | `Icons.calendar_today` |
| Frequent Patient | `Icons.star` |

---

## Mermaid Flow Diagram

```mermaid
graph TD
    A[User on Home Page] --> B{Taps "See All" or Patient}
    B --> C["See All" Tapped]
    B --> D[Patient Item Tapped]
    
    C --> E[Option A: Navigate to Patients Tab]
    C --> F[Option B: Navigate to PatientListPage]
    
    D --> G[Option A: Navigate to PatientListPage]
    D --> H[Option B: Show Modal Bottom Sheet]
    
    H --> I[Display Patient Details]
    I --> J[User can dismiss or tap outside]
```

---

## Files to Modify

| File | Changes |
|------|---------|
| [`lib/presentation/pages/home_page.dart`](lib/presentation/pages/home_page.dart) | Add navigation/modal logic, import PatientModel |

---

## Testing Checklist

- [ ] "See All" button navigates correctly
- [ ] Tapping a recent patient shows patient details
- [ ] Modal is dismissible by dragging down or tapping outside
- [ ] Modal shows all patient fields correctly
- [ ] UI matches Material Design 3 theme
