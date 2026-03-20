const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  // Seed users matching the mock data
  const users = [
    { email: 'admin@dental.com', password: 'admin123', name: 'Admin User', role: 'ADMIN' },
    { email: 'doctor@dental.com', password: 'doctor123', name: 'Dr. Sarah Johnson', role: 'DOCTOR' },
    { email: 'receptionist@dental.com', password: 'reception123', name: 'Maria Garcia', role: 'RECEPTIONIST' },
  ];

  for (const userData of users) {
    const existingUser = await prisma.user.findUnique({
      where: { email: userData.email },
    });

    if (!existingUser) {
      const passwordHash = await bcrypt.hash(userData.password, 10);
      await prisma.user.create({
        data: {
          email: userData.email,
          passwordHash,
          name: userData.name,
          role: userData.role,
          isActive: true,
        },
      });
      console.log(`Created user: ${userData.email} (${userData.role})`);
    } else {
      console.log(`User ${userData.email} already exists`);
    }
  }

  console.log('Seed completed successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
