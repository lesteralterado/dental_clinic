const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  const email = 'admin@dentalclinic.com';
  const password = 'admin123';
  const name = 'Administrator';

  // Check if user already exists
  const existingUser = await prisma.user.findUnique({
    where: { email },
  });

  if (existingUser) {
    console.log('Admin user already exists!');
    return;
  }

  // Hash the password
  const passwordHash = await bcrypt.hash(password, 10);

  // Create the admin user
  const user = await prisma.user.create({
    data: {
      email,
      passwordHash,
      name,
      role: 'ADMIN',
      isActive: true,
    },
  });

  console.log('Admin user created successfully!');
  console.log('Email:', email);
  console.log('Password:', password);
  console.log('Role: ADMIN');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
