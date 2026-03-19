# Dental Clinic Application

A comprehensive dental clinic management system with patient identification using face recognition and QR codes. This application consists of a **Node.js/Express backend API** and a **Flutter mobile application**.

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Database Setup](#database-setup)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [API Endpoints](#api-endpoints)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)

---

## Project Overview

This dental clinic application provides a complete solution for managing dental clinic operations including patient registration, appointments, treatments, and payments. The mobile app features advanced patient identification using QR codes and face recognition technology.

### Architecture

```mermaid
graph TB
    subgraph Mobile App Flutter
        UI[User Interface]
        BLOC[State Management<br/>flutter_bloc]
        API[API Client<br/>dio]
    end
    
    subgraph Backend API
        EXP[Express Server]
        AUTH[Authentication<br/>JWT]
        ROUTES[Routes]
        PRISMA[Prisma ORM]
    end
    
    subgraph Database
        PG[PostgreSQL]
    end
    
    UI --> BLOC
    BLOC --> API
    API --> EXP
    EXP --> AUTH
    AUTH --> ROUTES
    ROUTES --> PRISMA
    PRISMA --> PG
```

---

## Features

### Backend Features
- **Authentication**: JWT-based user authentication with role-based access control
- **Patient Management**: Full CRUD operations for patient records
- **Appointment Scheduling**: Create, update, and manage appointments
- **Treatment Records**: Track dental treatments and procedures
- **Payment Tracking**: Record and manage patient payments
- **Dashboard Statistics**: Real-time clinic statistics and metrics
- **Face Recognition**: Store and compare patient face data
- **QR Code Generation**: Generate unique QR codes for patient identification

### Mobile App Features
- **Secure Login**: Email/password authentication
- **Patient Registration**: Register new patients with full details
- **Patient Search**: Search patients by name, phone, or QR code
- **Face Recognition**: Identify patients using face detection
- **QR Code Scanning**: Quick patient lookup via QR code
- **Appointment Management**: View and manage appointments
- **Dashboard**: View clinic statistics and today's schedule
- **Offline Support**: Local database caching for offline access
- **Theme Support**: Light and dark mode switching

---

## Technology Stack

### Backend
| Technology | Purpose |
|------------|---------|
| Node.js | JavaScript runtime |
| Express.js | Web framework |
| Prisma | ORM for database |
| PostgreSQL | Relational database |
| JWT | Authentication |
| bcryptjs | Password hashing |
| QRCode | QR code generation |

### Frontend
| Technology | Purpose |
|------------|---------|
| Flutter | Mobile framework |
| flutter_bloc | State management |
| dio | HTTP client |
| drift | Local database |
| google_mlkit_face_detection | Face recognition |
| mobile_scanner | QR code scanning |
| flutter_secure_storage | Secure storage |

---

## Prerequisites

### Required Software
- **Node.js** (v18 or higher)
- **PostgreSQL** (v14 or higher)
- **Flutter SDK** (v3.0 or higher)
- **Git** (for version control)

### System Requirements
- At least 4GB RAM
- 10GB free disk space
- Windows 10/11, macOS, or Linux

---

## Installation

### 1. Clone the Repository

```bash
cd dental_clinic
```

### 2. Backend Setup

Navigate to the backend directory and install dependencies:

```bash
cd backend
npm install
```

### 3. Frontend Setup

Navigate to the frontend directory and install dependencies:

```bash
cd frontend
flutter pub get
```

---

## Database Setup

### 1. Install PostgreSQL

Download and install PostgreSQL from [postgresql.org](https://www.postgresql.org/download/).

### 2. Create Database

Open pgAdmin or use psql to create a new database:

```sql
CREATE DATABASE dental_clinic;
```

### 3. Configure Environment Variables

Copy the example environment file and update with your settings:

```bash
cd backend
cp .env.example .env
```

Edit the `.env` file with your database credentials:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
DATABASE_URL="postgresql://username:password@localhost:5432/dental_clinic?schema=public"

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production

# QR Code Configuration
QR_CODE_SECRET=your-qr-secret-key
```

**Important**: Replace `username`, `password` with your PostgreSQL credentials.

### 4. Run Database Migrations

Generate Prisma client and run migrations:

```bash
cd backend
npm run prisma:generate
npm run prisma:migrate
```

### 5. (Optional) Seed Database

Open Prisma Studio to manually add initial data:

```bash
npm run prisma:studio
```

---

## Configuration

### Backend Configuration

The backend is configured via environment variables in `backend/.env`:

| Variable | Description | Default |
|----------|-------------|---------|
| PORT | Server port number | 3000 |
| NODE_ENV | Environment | development |
| DATABASE_URL | PostgreSQL connection string | Required |
| JWT_SECRET | JWT signing secret | Required |
| QR_CODE_SECRET | QR code encryption key | Required |

### Frontend Configuration

The frontend API endpoint is configured in [`frontend/lib/core/constants/api_constants.dart`](frontend/lib/core/constants/api_constants.dart:6):

```dart
static const String baseUrl = 'http://localhost:3000/api';
```

**For production**, change this to your server's IP or domain:

```dart
static const String baseUrl = 'http://your-server-ip:3000/api';
```

---

## Running the Application

### Starting the Backend

1. Navigate to the backend directory:

```bash
cd backend
```

2. Start the development server:

```bash
npm run dev
```

The API will be available at `http://localhost:3000`

3. Verify the server is running:

```bash
curl http://localhost:3000/api/health
```

Expected response:
```json
{"status":"ok","timestamp":"2024-01-01T00:00:00.000Z"}
```

### Starting the Mobile App

1. Navigate to the frontend directory:

```bash
cd frontend
```

2. Run the app on a connected device or emulator:

```bash
flutter run
```

3. Select your target device (emulator or physical device)

### First Time Setup

1. **Create Admin User**: Use the registration endpoint or Prisma Studio to create your first user
2. **Login**: Use the mobile app to login with your credentials
3. **Start Managing Patients**: Begin registering patients and scheduling appointments

---

## API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | User login |
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/refresh` | Refresh access token |
| GET | `/api/auth/me` | Get current user |

### Patients

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/patients` | List all patients |
| GET | `/api/patients/:id` | Get patient by ID |
| POST | `/api/patients` | Create new patient |
| PUT | `/api/patients/:id` | Update patient |
| DELETE | `/api/patients/:id` | Delete patient |
| GET | `/api/patients/search?q=` | Search patients |
| POST | `/api/face/enroll` | Enroll patient face data |
| POST | `/api/face/identify` | Identify patient by face |

### Appointments

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/appointments` | List appointments |
| GET | `/api/appointments/today` | Get today's appointments |
| GET | `/api/appointments/week` | Get weekly appointments |
| POST | `/api/appointments` | Create appointment |
| PUT | `/api/appointments/:id` | Update appointment |
| DELETE | `/api/appointments/:id` | Cancel appointment |
| POST | `/api/appointments/:id/checkin` | Check in patient |

### Treatments

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/treatments` | List treatments |
| POST | `/api/treatments` | Create treatment record |
| PUT | `/api/treatments/:id` | Update treatment |

### Dashboard

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/dashboard/stats` | Get clinic statistics |
| GET | `/api/dashboard/recent` | Get recent activities |

### Health Check

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | API health status |

---

## Project Structure

```
dental_clinic/
├── backend/
│   ├── prisma/
│   │   └── schema.prisma        # Database schema
│   ├── src/
│   │   ├── app.js               # Express app entry point
│   │   └── routes/
│   │       ├── authRoutes.js    # Authentication routes
│   │       ├── patientRoutes.js # Patient management
│   │       ├── appointmentRoutes.js
│   │       ├── treatmentRoutes.js
│   │       └── dashboardRoutes.js
│   ├── .env.example            # Environment template
│   ├── package.json
│   └── ...
│
└── frontend/
    ├── lib/
    │   ├── main.dart            # App entry point
    │   ├── core/
    │   │   ├── constants/       # App constants
    │   │   ├── errors/          # Error handling
    │   │   ├── network/         # API client
    │   │   └── theme/           # App theme
    │   ├── data/
    │   │   └── models/          # Data models
    │   ├── di/                  # Dependency injection
    │   └── presentation/
    │       ├── blocs/           # BLoC state management
    │       └── pages/           # UI screens
    ├── pubspec.yaml
    └── ...
```

---

## Troubleshooting

### Backend Issues

#### Database Connection Failed
- Verify PostgreSQL is running: `pg_isready`
- Check DATABASE_URL in `.env` file
- Ensure database exists: `SELECT 1 FROM pg_database WHERE datname = 'dental_clinic'`

#### Port Already in Use
- Change PORT in `.env` to a different number (e.g., 3001)
- Or stop the process using port 3000

#### Prisma Errors
- Regenerate Prisma client: `npm run prisma:generate`
- Reset database: `npm run prisma:migrate reset`

### Frontend Issues

#### App Won't Connect to API
- Verify backend is running: `curl http://localhost:3000/api/health`
- Check API URL in [`api_constants.dart`](frontend/lib/core/constants/api_constants.dart:6)
- For physical devices, use computer's IP address instead of localhost

#### Camera Permission Denied
- Grant camera permission in device settings
- For Android, add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

#### Face Recognition Not Working
- Ensure good lighting conditions
- Face must be clearly visible
- Check if device has camera permission

### Common Solutions

1. **Clear all caches and reinstall**:
```bash
# Backend
cd backend
rm -rf node_modules package-lock.json
npm install

# Frontend
cd frontend
flutter clean
flutter pub get
```

2. **Check logs**:
- Backend: Terminal output where server is running
- Frontend: Run with `flutter run -v` for verbose output

3. **Verify environment variables**:
```bash
# Backend
cd backend
cat .env
```

---

## Security Considerations

1. **Change JWT_SECRET**: Use a strong, unique secret key in production
2. **HTTPS**: Enable HTTPS for production deployments
3. **Environment Variables**: Never commit `.env` files to version control
4. **Passwords**: Ensure strong password policies are enforced
5. **Database**: Use strong database passwords and restrict network access

---

## License

This project is for educational and demonstration purposes.

---

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review console/terminal logs for error messages
3. Verify all prerequisites are installed correctly
