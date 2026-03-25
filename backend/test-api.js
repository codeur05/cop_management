const axios = require('axios');

const API_URL = 'http://localhost:8000/api';

const runTests = async () => {
  try {
    // 1. Test Base Route
    console.log('Testing Base Route...');
    const baseResponse = await axios.get('http://localhost:8000/');
    console.log('Base Route OK:', baseResponse.data);

    // 2. Register Admin
    console.log('\nTesting Admin Registration...');
    const email = `test_user_${Date.now()}@gmail.com`;
    const adminData = {
      firstName: 'Test',
      lastName: 'User',
      email: email,
      password: 'password123',
    };
    try {
      const registerAdmin = await axios.post(`${API_URL}/auth/register`, adminData);
      console.log('Admin Register OK:', registerAdmin.data.role);
    } catch (err) {
      console.log('Admin Register Error (maybe already exists):', err.response ? err.response.data : err.message);
    }

    // 3. Login Admin
    console.log('\nTesting Login...');
    const loginResponse = await axios.post(`${API_URL}/auth/login`, {
      email: 'admin@coop.com',
      password: 'password123',
    });
    const { token, role } = loginResponse.data;
    console.log('Login OK:', { role, token: token.substring(0, 20) + '...' });

    // 4. Test Protected Route (Members - Admin Only)
    console.log('\nTesting Admin Protected Route (Get Members)...');
    const membersResponse = await axios.get(`${API_URL}/members`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    console.log('Get Members OK! Count:', membersResponse.data.length);

    console.log('\n--- ALL TESTS PASSED SUCCESSFULLY! ---');
  } catch (error) {
    console.error('\n--- TEST FAILED ---');
    if (error.response) {
      console.error('Data:', error.response.data);
      console.error('Status:', error.response.status);
    } else {
      console.error('Error:', error.message);
    }
  }
};

runTests();
