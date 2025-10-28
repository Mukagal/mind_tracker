const express = require("express");
const nodemailer = require("nodemailer");
const bodyParser = require("body-parser");
const cors = require("cors");
const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcrypt');

const db = new sqlite3.Database('./users.db', (err) => {
  if (err) console.error(err.message);
  else console.log('Connected to SQLite database.');
});

db.run(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    surname TEXT,
    email TEXT UNIQUE,
    password TEXT
  )
`);


const app = express();
app.use(cors());
app.use(bodyParser.json());

let otpStore = {}; 

const transporter = nodemailer.createTransport({
  service: "Gmail",
  auth: {
    user: "amankosovmukagali1488@gmail.com", 
    pass: "lgzu abfs rsmp yjml",   
  },
});

app.post("/send-otp", async (req, res) => {
  const { email } = req.body;
  const otp = Math.floor(100000 + Math.random() * 900000).toString();

  otpStore[email] = otp;

  const mailOptions = {
    from: '"Mind Tracker" <amankosovmukagali1488@gmail.com>',
    to: email,
    subject: "Your Verification Code",
    text: `Your OTP is ${otp}. It will expire in 5 minutes.`,
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`Sent OTP ${otp} to ${email}`);
    res.status(200).json({ message: "OTP sent successfully" });
  } catch (error) {
    console.error("Error sending OTP:", error);
    res.status(500).json({ error: "Failed to send OTP" });
  }
});

app.post("/verify-otp", (req, res) => {
  const { email, otp } = req.body;
  if (otpStore[email] && otpStore[email] === otp) {
    delete otpStore[email]; 
    res.json({ success: true });
  } else {
    res.json({ success: false, message: "Invalid OTP" });
  }
});
app.post("/register", async (req, res) => {
  const { name, surname, email, password } = req.body;

  if (!name || !surname || !email || !password) {
    return res.status(400).json({ success: false, message: "All fields required" });
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);

    db.run(
      `INSERT INTO users (name, surname, email, password) VALUES (?, ?, ?, ?)`,
      [name, surname, email, hashedPassword],
      function(err) {
        if (err) {
          console.error(err.message);
          return res.status(400).json({ success: false, message: "User already exists" });
        }
        res.json({ success: true, message: "User registered successfully" });
      }
    );
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.post("/login", (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: "Email and password required" });
  }

  db.get(`SELECT * FROM users WHERE email = ?`, [email], async (err, user) => {
    if (err) {
      console.error(err.message);
      return res.status(500).json({ success: false, message: "Database error" });
    }

    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    try {
      const match = await bcrypt.compare(password, user.password);

      if (match) {
        res.json({
          success: true,
          message: "Login successful",
          user: {
            id: user.id,
            name: user.name,
            surname: user.surname,
            email: user.email
          }
        });
      } else {
        res.status(401).json({ success: false, message: "Invalid password" });
      }
    } catch (error) {
      console.error(error);
      res.status(500).json({ success: false, message: "Server error" });
    }
  });
});


const PORT = 3000;
app.listen(PORT, 'localhost', () => console.log(`Server running on http://localhost:${PORT}`));
