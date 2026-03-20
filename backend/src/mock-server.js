const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const QRCode = require('qrcode');

const app = express();
const PORT = 3000;
const JWT_SECRET = 'mock-jwt-secret-key';

// Middleware
app.use(cors());
app.use(express.json());

// Mock Database
const mockDb = {
  users: [
    {
      id: 'user-1',
      email: 'admin@dental.com',
      passwordHash: '$2a$10$XQwKzGkQ2RkG9.H.2.5gXOQ5.1.2.3.4.5.6.7.8.9.0', // password: admin123
      name: 'Admin User',
      role: 'ADMIN',
      isActive: true,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    }
  ],
  patients: [
    {
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
      lastVisit: new Date().toISOString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    },
    {
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
      lastVisit: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    }
  ],
  appointments: [
    {
      id: 'apt-1',
      patientId: 'patient-1',
      dentistId: 'user-1',
      appointmentDate: new Date().toISOString(),
      appointmentTime: '09:00',
      duration: 30,
      status: 'SCHEDULED',
      reason: 'Tooth extraction',
      notes: 'First visit',
      isCheckedIn: false,
      checkedInAt: null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    },
    {
      id: 'apt-2',
      patientId: 'patient-2',
      dentistId: 'user-1',
      appointmentDate: new Date().toISOString(),
      appointmentTime: '10:30',
      duration: 30,
      status: 'CONFIRMED',
      reason: 'Regular checkup',
      notes: null,
      isCheckedIn: true,
      checkedInAt: new Date().toISOString(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    }
  ],
  treatments: [
    {
      id: 'treatment-1',
      patientId: 'patient-1',
      dentistId: 'user-1',
      recordDate: new Date().toISOString(),
      recordNo: 1,
      description: 'Tooth extraction',
      treatmentTime: '30 minutes',
      debit: 1500.00,
      credit: 0.00,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    }
  ]
};

// Helper functions
const generateToken = (userId) => jwt.sign({ userId }, JWT_SECRET, { expiresIn: '1d' });

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ message: 'No token provided' });
  }
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid token' });
  }
};

// Auth Routes
app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  
  // For testing, accept any login with email "admin@dental.com" and password "admin123"
  const user = mockDb.users.find(u => u.email === email);
  
  if (!user || !user.isActive) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }
  
  // Accept password "admin123" for admin user, or any password for other users
  const isValidPassword = password === 'admin123' || password.length >= 6;
  if (!isValidPassword) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }
  
  const accessToken = generateToken(user.id);
  const refreshToken = generateToken(user.id);
  
  const { passwordHash, ...userWithoutPassword } = user;
  res.json({ accessToken, refreshToken, user: userWithoutPassword });
});

app.post('/api/auth/register', async (req, res) => {
  const { email, password, name, role } = req.body;
  
  const existingUser = mockDb.users.find(u => u.email === email);
  if (existingUser) {
    return res.status(400).json({ message: 'Email already registered' });
  }
  
  const newUser = {
    id: uuidv4(),
    email,
    passwordHash: await bcrypt.hash(password, 10),
    name,
    role: role || 'RECEPTIONIST',
    isActive: true,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };
  
  mockDb.users.push(newUser);
  const { passwordHash, ...userWithoutPassword } = newUser;
  res.status(201).json(userWithoutPassword);
});

app.post('/api/auth/refresh', (req, res) => {
  const { refreshToken } = req.body;
  
  try {
    const decoded = jwt.verify(refreshToken, JWT_SECRET);
    const user = mockDb.users.find(u => u.id === decoded.userId);
    
    if (!user || !user.isActive) {
      return res.status(401).json({ message: 'Invalid token' });
    }
    
    const accessToken = generateToken(user.id);
    res.json({ accessToken });
  } catch (error) {
    res.status(401).json({ message: 'Invalid token' });
  }
});

app.get('/api/auth/me', authenticateToken, (req, res) => {
  const user = mockDb.users.find(u => u.id === req.user.userId);
  
  if (!user) {
    return res.status(404).json({ message: 'User not found' });
  }
  
  const { passwordHash, ...userWithoutPassword } = user;
  res.json(userWithoutPassword);
});

// Patient Routes
app.get('/api/patients', (req, res) => {
  const { page = 1, limit = 20, search } = req.query;
  let patients = [...mockDb.patients];
  
  if (search) {
    const searchLower = search.toLowerCase();
    patients = patients.filter(p => 
      p.name.toLowerCase().includes(searchLower) || 
      p.telephone.includes(search)
    );
  }
  
  const total = patients.length;
  const startIndex = (page - 1) * limit;
  patients = patients.slice(startIndex, startIndex + parseInt(limit));
  
  res.json({ patients, total, page: parseInt(page), totalPages: Math.ceil(total / limit) });
});

app.get('/api/patients/search', (req, res) => {
  const { q } = req.query;
  const patients = mockDb.patients.filter(p => 
    p.name.toLowerCase().includes(q.toLowerCase()) || 
    p.telephone.includes(q)
  );
  res.json(patients.slice(0, 10));
});

app.get('/api/patients/recent', (req, res) => {
  const patients = [...mockDb.patients]
    .sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt))
    .slice(0, 5);
  res.json(patients);
});

app.get('/api/patients/frequent', (req, res) => {
  const patients = mockDb.patients.filter(p => p.isFrequent);
  res.json(patients);
});

app.get('/api/patients/:id', (req, res) => {
  const patient = mockDb.patients.find(p => p.id === req.params.id);
  if (!patient) {
    return res.status(404).json({ message: 'Patient not found' });
  }
  res.json(patient);
});

app.post('/api/patients', async (req, res) => {
  const { name, address, telephone, age, occupation, status, complaint, gender, email } = req.body;
  const qrCode = `DC-${uuidv4()}`;
  
  const newPatient = {
    id: uuidv4(),
    qrCode,
    name,
    address,
    telephone,
    age,
    occupation,
    status,
    complaint,
    gender,
    email,
    emergencyContact: null,
    emergencyPhone: null,
    medicalNotes: null,
    allergies: null,
    isFrequent: false,
    lastVisit: null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };
  
  mockDb.patients.push(newPatient);
  
  const qrCodeData = await QRCode.toDataURL(JSON.stringify({ type: 'patient', id: newPatient.id }));
  res.status(201).json({ ...newPatient, qrCodeData });
});

app.put('/api/patients/:id', (req, res) => {
  const index = mockDb.patients.findIndex(p => p.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ message: 'Patient not found' });
  }
  
  mockDb.patients[index] = { ...mockDb.patients[index], ...req.body, updatedAt: new Date().toISOString() };
  res.json(mockDb.patients[index]);
});

app.delete('/api/patients/:id', (req, res) => {
  const index = mockDb.patients.findIndex(p => p.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ message: 'Patient not found' });
  }
  
  mockDb.patients.splice(index, 1);
  res.json({ message: 'Patient deleted' });
});

app.get('/api/patients/:id/qr', async (req, res) => {
  const patient = mockDb.patients.find(p => p.id === req.params.id);
  if (!patient) {
    return res.status(404).json({ message: 'Patient not found' });
  }
  
  const qrCodeData = await QRCode.toDataURL(JSON.stringify({
    type: 'patient',
    id: patient.id,
    timestamp: Date.now()
  }));
  
  res.json({ qrCode: patient.qrCode, qrCodeData });
});

// Appointment Routes
app.get('/api/appointments', (req, res) => {
  const { date, dentistId, status } = req.query;
  let appointments = [...mockDb.appointments];
  
  if (date) {
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);
    appointments = appointments.filter(a => 
      new Date(a.appointmentDate) >= startOfDay && new Date(a.appointmentDate) <= endOfDay
    );
  }
  
  if (dentistId) appointments = appointments.filter(a => a.dentistId === dentistId);
  if (status) appointments = appointments.filter(a => a.status === status);
  
  const appointmentsWithPatients = appointments.map(a => ({
    ...a,
    patient: mockDb.patients.find(p => p.id === a.patientId)
  }));
  
  res.json(appointmentsWithPatients);
});

app.get('/api/appointments/today', (req, res) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const tomorrow = new Date(today);
  tomorrow.setDate(tomorrow.getDate() + 1);
  
  const appointments = mockDb.appointments.filter(a => 
    new Date(a.appointmentDate) >= today && new Date(a.appointmentDate) < tomorrow
  ).map(a => ({
    ...a,
    patient: mockDb.patients.find(p => p.id === a.patientId)
  }));
  
  res.json(appointments);
});

app.get('/api/appointments/week', (req, res) => {
  const { start } = req.query;
  const startDate = start ? new Date(start) : new Date();
  startDate.setHours(0, 0, 0, 0);
  
  const endDate = new Date(startDate);
  endDate.setDate(endDate.getDate() + 7);
  
  const appointments = mockDb.appointments.filter(a => 
    new Date(a.appointmentDate) >= startDate && new Date(a.appointmentDate) < endDate
  ).map(a => ({
    ...a,
    patient: mockDb.patients.find(p => p.id === a.patientId)
  }));
  
  res.json(appointments);
});

app.get('/api/appointments/:id', (req, res) => {
  const appointment = mockDb.appointments.find(a => a.id === req.params.id);
  if (!appointment) {
    return res.status(404).json({ message: 'Appointment not found' });
  }
  
  res.json({
    ...appointment,
    patient: mockDb.patients.find(p => p.id === appointment.patientId)
  });
});

app.post('/api/appointments', (req, res) => {
  const { patientId, dentistId, appointmentDate, appointmentTime, duration, reason, notes } = req.body;
  
  const newAppointment = {
    id: uuidv4(),
    patientId,
    dentistId,
    appointmentDate: new Date(appointmentDate),
    appointmentTime,
    duration: duration || 30,
    status: 'SCHEDULED',
    reason,
    notes,
    isCheckedIn: false,
    checkedInAt: null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };
  
  mockDb.appointments.push(newAppointment);
  
  res.status(201).json({
    ...newAppointment,
    patient: mockDb.patients.find(p => p.id === patientId)
  });
});

app.put('/api/appointments/:id', (req, res) => {
  const index = mockDb.appointments.findIndex(a => a.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ message: 'Appointment not found' });
  }
  
  mockDb.appointments[index] = { 
    ...mockDb.appointments[index], 
    ...req.body, 
    updatedAt: new Date().toISOString() 
  };
  
  res.json({
    ...mockDb.appointments[index],
    patient: mockDb.patients.find(p => p.id === mockDb.appointments[index].patientId)
  });
});

app.delete('/api/appointments/:id', (req, res) => {
  const index = mockDb.appointments.findIndex(a => a.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ message: 'Appointment not found' });
  }
  
  mockDb.appointments[index].status = 'CANCELLED';
  res.json({ message: 'Appointment cancelled' });
});

app.post('/api/appointments/:id/checkin', (req, res) => {
  const index = mockDb.appointments.findIndex(a => a.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ message: 'Appointment not found' });
  }
  
  mockDb.appointments[index] = {
    ...mockDb.appointments[index],
    isCheckedIn: true,
    checkedInAt: new Date().toISOString(),
    status: 'CONFIRMED',
    updatedAt: new Date().toISOString()
  };
  
  res.json({
    ...mockDb.appointments[index],
    patient: mockDb.patients.find(p => p.id === mockDb.appointments[index].patientId)
  });
});

// Treatment Routes
app.get('/api/treatments/patient/:patientId', (req, res) => {
  const treatments = mockDb.treatments.filter(t => t.patientId === req.params.patientId);
  res.json(treatments);
});

app.get('/api/treatments/:id', (req, res) => {
  const treatment = mockDb.treatments.find(t => t.id === req.params.id);
  if (!treatment) {
    return res.status(404).json({ message: 'Treatment not found' });
  }
  
  res.json({
    ...treatment,
    patient: mockDb.patients.find(p => p.id === treatment.patientId)
  });
});

app.post('/api/treatments', (req, res) => {
  const { patientId, dentistId, recordDate, recordNo, description, treatmentTime, debit, credit } = req.body;
  
  const lastTreatment = mockDb.treatments
    .filter(t => t.patientId === patientId)
    .sort((a, b) => b.recordNo - a.recordNo)[0];
  
  const newTreatment = {
    id: uuidv4(),
    patientId,
    dentistId,
    recordDate: new Date(recordDate),
    recordNo: recordNo || (lastTreatment ? lastTreatment.recordNo + 1 : 1),
    description,
    treatmentTime,
    debit: debit || 0,
    credit: credit || 0,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };
  
  mockDb.treatments.push(newTreatment);
  
  res.status(201).json({
    ...newTreatment,
    patient: mockDb.patients.find(p => p.id === patientId)
  });
});

app.put('/api/treatments/:id', (req, res) => {
  const index = mockDb.treatments.findIndex(t => t.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ message: 'Treatment not found' });
  }
  
  mockDb.treatments[index] = { 
    ...mockDb.treatments[index], 
    ...req.body, 
    updatedAt: new Date().toISOString() 
  };
  
  res.json({
    ...mockDb.treatments[index],
    patient: mockDb.patients.find(p => p.id === mockDb.treatments[index].patientId)
  });
});

app.delete('/api/treatments/:id', (req, res) => {
  const index = mockDb.treatments.findIndex(t => t.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ message: 'Treatment not found' });
  }
  
  mockDb.treatments.splice(index, 1);
  res.json({ message: 'Treatment deleted' });
});

// Dashboard Routes
app.get('/api/dashboard/stats', (req, res) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const tomorrow = new Date(today);
  tomorrow.setDate(tomorrow.getDate() + 1);
  
  const todayAppointments = mockDb.appointments.filter(a => 
    new Date(a.appointmentDate) >= today && new Date(a.appointmentDate) < tomorrow
  );
  
  const completedToday = todayAppointments.filter(a => a.status === 'COMPLETED').length;
  
  res.json({
    totalPatients: mockDb.patients.length,
    todayAppointments: todayAppointments.length,
    completedToday,
    pendingPayments: mockDb.treatments.filter(t => t.debit > t.credit).length,
    date: new Date()
  });
});

app.get('/api/dashboard/recent', (req, res) => {
  const patients = [...mockDb.patients]
    .sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt))
    .slice(0, 5)
    .map(p => ({
      ...p,
      appointments: mockDb.appointments
        .filter(a => a.patientId === p.id)
        .sort((a, b) => new Date(b.appointmentDate) - new Date(a.appointmentDate))
        .slice(0, 1)
    }));
  
  res.json(patients);
});

// Health Check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString(), mode: 'mock' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!', error: err.message });
});

// Start server
app.listen(PORT, () => {
  console.log(`Dental Clinic Mock API running on port ${PORT}`);
});

module.exports = app;
