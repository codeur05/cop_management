const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');
const path = require('path');

// Load environment variables from .env
dotenv.config();

// PRODUCTION URI - You can also paste it directly here if .env is not set
const MONGO_URI = 'mongodb+srv://admin_coop:Admin12345@cluster0.bx2dzhh.mongodb.net/digital-coop?retryWrites=true&w=majority';

const resetAdmin = async () => {
    try {
        console.log('Connecting to production database...');
        await mongoose.connect(MONGO_URI);
        console.log('Connected!');

        const email = 'efraimkantagba16@gmail.com';
        const password = 'Bonjour@2005';
        const hashedPassword = await bcrypt.hash(password, 10);

        const result = await mongoose.connection.db.collection('users').updateOne(
            { email: email },
            { 
                $set: { 
                    password: hashedPassword,
                    isVerified: true,
                    role: 'Admin',
                    firstName: 'Admin',
                    lastName: 'Cooperative'
                } 
            },
            { upsert: true }
        );

        if (result.upsertedCount > 0) {
            console.log(`Admin user CREATED with email: ${email} and password: ${password}`);
        } else {
            console.log(`Admin user UPDATED with email: ${email} and password: ${password}`);
        }

        process.exit(0);
    } catch (error) {
        console.error('Error:', error);
        process.exit(1);
    }
};

resetAdmin();
