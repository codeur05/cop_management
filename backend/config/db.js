const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    let dbUrl = process.env.MONGO_URI;

    const conn = await mongoose.connect(dbUrl, {
      serverSelectionTimeoutMS: 10000,
    });

    console.log(`MongoDB Connected: ${conn.connection.host}`);

  } catch (error) {
    console.error(`Database Connection Error: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;
