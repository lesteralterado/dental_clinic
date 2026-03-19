const express = require('express');
const { PrismaClient } = require('@prisma/client');
const router = express.Router();
const prisma = new PrismaClient();

// Get all appointments
router.get('/', async (req, res) => {
  try {
    const { date, dentistId, status } = req.query;
    const where = {};
    
    if (date) {
      const startOfDay = new Date(date);
      startOfDay.setHours(0, 0, 0, 0);
      const endOfDay = new Date(date);
      endOfDay.setHours(23, 59, 59, 999);
      where.appointmentDate = { gte: startOfDay, lte: endOfDay };
    }
    if (dentistId) where.dentistId = dentistId;
    if (status) where.status = status;

    const appointments = await prisma.appointment.findMany({
      where,
      include: { patient: true },
      orderBy: { appointmentTime: 'asc' }
    });
    res.json(appointments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get today's appointments
router.get('/today', async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const appointments = await prisma.appointment.findMany({
      where: {
        appointmentDate: { gte: today, lt: tomorrow }
      },
      include: { patient: true },
      orderBy: { appointmentTime: 'asc' }
    });
    res.json(appointments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get weekly schedule
router.get('/week', async (req, res) => {
  try {
    const { start } = req.query;
    const startDate = start ? new Date(start) : new Date();
    startDate.setHours(0, 0, 0, 0);
    
    const endDate = new Date(startDate);
    endDate.setDate(endDate.getDate() + 7);

    const appointments = await prisma.appointment.findMany({
      where: {
        appointmentDate: { gte: startDate, lt: endDate }
      },
      include: { patient: true },
      orderBy: { appointmentDate: 'asc' }
    });
    res.json(appointments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get appointment by ID
router.get('/:id', async (req, res) => {
  try {
    const appointment = await prisma.appointment.findUnique({
      where: { id: req.params.id },
      include: { patient: true }
    });
    if (!appointment) {
      return res.status(404).json({ message: 'Appointment not found' });
    }
    res.json(appointment);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create appointment
router.post('/', async (req, res) => {
  try {
    const { patientId, dentistId, appointmentDate, appointmentTime, duration, reason, notes } = req.body;
    
    const appointment = await prisma.appointment.create({
      data: {
        patientId,
        dentistId,
        appointmentDate: new Date(appointmentDate),
        appointmentTime,
        duration: duration || 30,
        reason,
        notes,
        status: 'SCHEDULED'
      },
      include: { patient: true }
    });
    res.status(201).json(appointment);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update appointment
router.put('/:id', async (req, res) => {
  try {
    const appointment = await prisma.appointment.update({
      where: { id: req.params.id },
      data: req.body,
      include: { patient: true }
    });
    res.json(appointment);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Cancel appointment
router.delete('/:id', async (req, res) => {
  try {
    await prisma.appointment.update({
      where: { id: req.params.id },
      data: { status: 'CANCELLED' }
    });
    res.json({ message: 'Appointment cancelled' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Check-in patient
router.post('/:id/checkin', async (req, res) => {
  try {
    const appointment = await prisma.appointment.update({
      where: { id: req.params.id },
      data: {
        isCheckedIn: true,
        checkedInAt: new Date(),
        status: 'CONFIRMED'
      },
      include: { patient: true }
    });
    res.json(appointment);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
