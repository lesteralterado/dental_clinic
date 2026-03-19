const express = require('express');
const { PrismaClient } = require('@prisma/client');
const router = express.Router();
const prisma = new PrismaClient();

// Get treatments for a patient
router.get('/patient/:patientId', async (req, res) => {
  try {
    const treatments = await prisma.treatmentRecord.findMany({
      where: { patientId: req.params.patientId },
      orderBy: { recordDate: 'desc' }
    });
    res.json(treatments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get treatment by ID
router.get('/:id', async (req, res) => {
  try {
    const treatment = await prisma.treatmentRecord.findUnique({
      where: { id: req.params.id },
      include: { patient: true }
    });
    if (!treatment) {
      return res.status(404).json({ message: 'Treatment not found' });
    }
    res.json(treatment);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create treatment
router.post('/', async (req, res) => {
  try {
    const { patientId, dentistId, recordDate, recordNo, description, treatmentTime, debit, credit } = req.body;
    
    // Get the next record number if not provided
    let finalRecordNo = recordNo;
    if (!finalRecordNo) {
      const lastTreatment = await prisma.treatmentRecord.findFirst({
        where: { patientId },
        orderBy: { recordNo: 'desc' }
      });
      finalRecordNo = lastTreatment ? lastTreatment.recordNo + 1 : 1;
    }

    const treatment = await prisma.treatmentRecord.create({
      data: {
        patientId,
        dentistId,
        recordDate: new Date(recordDate),
        recordNo: finalRecordNo,
        description,
        treatmentTime,
        debit: debit || 0,
        credit: credit || 0
      },
      include: { patient: true }
    });
    res.status(201).json(treatment);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update treatment
router.put('/:id', async (req, res) => {
  try {
    const treatment = await prisma.treatmentRecord.update({
      where: { id: req.params.id },
      data: req.body,
      include: { patient: true }
    });
    res.json(treatment);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete treatment
router.delete('/:id', async (req, res) => {
  try {
    await prisma.treatmentRecord.delete({ where: { id: req.params.id } });
    res.json({ message: 'Treatment deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
