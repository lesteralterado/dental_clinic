const express = require('express');
const { PrismaClient } = require('@prisma/client');
const QRCode = require('qrcode');
const { v4: uuidv4 } = require('uuid');
const router = express.Router();
const prisma = new PrismaClient();

// Get all patients
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 20, search } = req.query;
    const skip = (page - 1) * limit;

    const where = search ? {
      OR: [
        { name: { contains: search, mode: 'insensitive' } },
        { telephone: { contains: search, mode: 'insensitive' } }
      ]
    } : {};

    const [patients, total] = await Promise.all([
      prisma.patient.findMany({
        where,
        skip,
        take: parseInt(limit),
        orderBy: { createdAt: 'desc' }
      }),
      prisma.patient.count({ where })
    ]);

    res.json({ patients, total, page: parseInt(page), totalPages: Math.ceil(total / limit) });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Search patients
router.get('/search', async (req, res) => {
  try {
    const { q } = req.query;
    const patients = await prisma.patient.findMany({
      where: {
        OR: [
          { name: { contains: q, mode: 'insensitive' } },
          { telephone: { contains: q, mode: 'insensitive' } }
        ]
      },
      take: 10
    });
    res.json(patients);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get recent patients
router.get('/recent', async (req, res) => {
  try {
    const patients = await prisma.patient.findMany({
      orderBy: { updatedAt: 'desc' },
      take: 5
    });
    res.json(patients);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get frequent patients
router.get('/frequent', async (req, res) => {
  try {
    const patients = await prisma.patient.findMany({
      where: { isFrequent: true },
      orderBy: { name: 'asc' }
    });
    res.json(patients);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get patient by ID
router.get('/:id', async (req, res) => {
  try {
    const patient = await prisma.patient.findUnique({
      where: { id: req.params.id },
      include: {
        treatments: { orderBy: { recordDate: 'desc' }, take: 10 },
        appointments: { orderBy: { appointmentDate: 'desc' }, take: 5 }
      }
    });
    if (!patient) {
      return res.status(404).json({ message: 'Patient not found' });
    }
    res.json(patient);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create patient
router.post('/', async (req, res) => {
  try {
    const { name, address, telephone, age, occupation, status, complaint, gender, email } = req.body;
    const qrCode = `DC-${uuidv4()}`;

    const patient = await prisma.patient.create({
      data: {
        name, address, telephone, age, occupation, status, complaint, gender, email, qrCode
      }
    });

    // Generate QR code
    const qrCodeData = await QRCode.toDataURL(JSON.stringify({ type: 'patient', id: patient.id }));

    res.status(201).json({ ...patient, qrCodeData });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update patient
router.put('/:id', async (req, res) => {
  try {
    const patient = await prisma.patient.update({
      where: { id: req.params.id },
      data: req.body
    });
    res.json(patient);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete patient
router.delete('/:id', async (req, res) => {
  try {
    await prisma.patient.delete({ where: { id: req.params.id } });
    res.json({ message: 'Patient deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get patient QR code
router.get('/:id/qr', async (req, res) => {
  try {
    const patient = await prisma.patient.findUnique({
      where: { id: req.params.id }
    });
    if (!patient) {
      return res.status(404).json({ message: 'Patient not found' });
    }

    const qrCodeData = await QRCode.toDataURL(JSON.stringify({
      type: 'patient',
      id: patient.id,
      timestamp: Date.now()
    }));

    res.json({ qrCode: patient.qrCode, qrCodeData });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Identify patient by face (stub - would integrate with face recognition)
router.post('/identify/face', async (req, res) => {
  try {
    const { faceData } = req.body;
    // This would compare faceData with stored templates
    // For now, return not found
    res.status(404).json({ message: 'No match found' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
