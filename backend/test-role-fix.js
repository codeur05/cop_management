const mongoose = require('mongoose');
const User = require('./models/User');
const dotenv = require('dotenv');
const { MongoMemoryServer } = require('mongodb-memory-server');

dotenv.config();

async function runTest() {
  let mongoServer;
  try {
    console.log('Starting Test...');
    mongoServer = await MongoMemoryServer.create();
    const uri = mongoServer.getUri();
    await mongoose.connect(uri);
    console.log('Connected to Mock DB');

    // 1. Create a user
    const userData = {
      firstName: 'Test',
      lastName: 'User',
      email: 'test@example.com',
      password: 'password123',
      role: 'Membre'
    };
    const user = await User.create(userData);
    console.log('User created with role:', user.role);

    // 2. Fetch user (WITHOUT password, as in controller)
    const fetchedUser = await User.findById(user._id);
    console.log('Fetched user ID:', fetchedUser._id);
    
    // 3. Update role
    console.log('Attempting to update role to Tresorier...');
    fetchedUser.role = 'Tresorier';
    
    // This previously failed because of pre-save hook missing return next()
    await fetchedUser.save();
    console.log('SUCCESS: Role updated to:', fetchedUser.role);

    await mongoose.disconnect();
    await mongoServer.stop();
    process.exit(0);
  } catch (err) {
    console.error('TEST FAILED!');
    console.error(err);
    if (mongoServer) await mongoServer.stop();
    process.exit(1);
  }
}

runTest();
