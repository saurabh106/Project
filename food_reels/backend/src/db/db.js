// Only write logic in this and export it and exceuted in the server.js file
const mongoose = require("mongoose");
require('dotenv').config({ quiet: true });

function connectDB() {
  mongoose
    .connect(process.env.MONGO_URL)
    .then(() => {
      console.log("MongoDB Connected");
    })
    .catch((err) => {
      console.error("Error connecting to MongoDB:", err);
    });
}

module.exports = connectDB;
