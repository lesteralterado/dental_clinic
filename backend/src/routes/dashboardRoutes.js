const express = require('express');
const { PrismaClient } = require('@prisma/client');
const router = express.Router();
const prisma = new PrismaClient();

// Get dashboard statistics
router.get('/stats', async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const [
      totalPatients,
      todayAppointments,
      completedToday,
      pendingPayments
    ] = await Promise.all([
      prisma.patient.count(),
      prisma.appointment.count({
        where: { appointmentDate: { gte: today, lt: tomorrow } }
      }),
      prisma.appointment.count({
        where: {
          appointmentDate: { gte: today, lt: tomorrow },
          status: 'COMPLETED'
        }
      }),
      prisma.treatmentRecord.count({
        where: {
          debit: { gt: prisma.treatmentRecord.fields.credit }
        }
      })
    ]);

    res.json({
      totalPatients,
      todayAppointments,
      completedToday,
      pendingPayments,
      date: new Date()
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get recent patients
router.get('/recent', async (req, res) => {
  try {
    const patients = await prisma.patient.findMany({
      orderBy: { updatedAt: 'desc' },
      take: 5,
      include: {
        appointments: {
          orderBy: { appointmentDate: 'desc' },
          take: 1
        }
      }
    });
    res.json(patients);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
