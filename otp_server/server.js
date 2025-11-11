const express = require("express");
const nodemailer = require("nodemailer");
const bodyParser = require("body-parser");
const cors = require("cors");
const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcrypt');
require('dotenv').config();
console.log("OPENAI_API_KEY:", process.env.OPENAI_API_KEY ? "✅ Loaded" : "❌ Missing");

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

db.run(`
  CREATE TABLE IF NOT EXISTS conversations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    conversation_id TEXT,
    role TEXT,
    content TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
  )
`);

const app = express();
app.use(cors());
app.use(bodyParser.json());

let otpStore = {}; 
let verifiedEmails = {}; 

const transporter = nodemailer.createTransport({
  service: "Gmail",
  auth: {
    user: "amankosovmukagali1488@gmail.com", 
    pass: "lgzu abfs rsmp yjml",   
  },
});


app.post("/send-otp", async (req, res) => {
  const { email } = req.body;
  
  db.get(`SELECT * FROM users WHERE email = ?`, [email], async (err, user) => {
    if (err) {
      console.error(err.message);
      return res.status(500).json({ error: "Database error" });
    }
    
    if (user) {
      return res.status(400).json({ error: "Email already registered" });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    otpStore[email] = { otp, type: 'register', timestamp: Date.now() };

    const mailOptions = {
      from: '"Mind Tracker" <amankosovmukagali1488@gmail.com>',
      to: email,
      subject: "Your Verification Code",
      text: `Your OTP is ${otp}. It will expire in 5 minutes.`,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log(`Sent registration OTP ${otp} to ${email}`);
      res.status(200).json({ message: "OTP sent successfully" });
    } catch (error) {
      console.error("Error sending OTP:", error);
      res.status(500).json({ error: "Failed to send OTP" });
    }
  });
});

app.post("/send-reset-otp", async (req, res) => {
  const { email } = req.body;
  
  db.get(`SELECT * FROM users WHERE email = ?`, [email], async (err, user) => {
    if (err) {
      console.error(err.message);
      return res.status(500).json({ error: "Database error" });
    }
    
    if (!user) {
      return res.status(404).json({ error: "Email not found" });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    otpStore[email] = { otp, type: 'reset', timestamp: Date.now() };

    const mailOptions = {
      from: '"Mind Tracker" <amankosovmukagali1488@gmail.com>',
      to: email,
      subject: "Password Reset Verification Code",
      text: `Your OTP for password reset is ${otp}. It will expire in 5 minutes.`,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log(`Sent reset OTP ${otp} to ${email}`);
      res.status(200).json({ message: "OTP sent successfully" });
    } catch (error) {
      console.error("Error sending OTP:", error);
      res.status(500).json({ error: "Failed to send OTP" });
    }
  });
});

app.post("/verify-otp", (req, res) => {
  const { email, otp } = req.body;
  
  if (!otpStore[email]) {
    return res.status(400).json({ success: false, message: "OTP expired or not found" });
  }

  const storedData = otpStore[email];
  
  if (Date.now() - storedData.timestamp > 5 * 60 * 1000) {
    delete otpStore[email];
    return res.status(400).json({ success: false, message: "OTP expired" });
  }

  if (storedData.otp === otp && storedData.type === 'register') {
    delete otpStore[email];
    verifiedEmails[email] = { verified: true, timestamp: Date.now() };
    res.json({ success: true, message: "OTP verified successfully" });
  } else {
    res.status(400).json({ success: false, message: "Invalid OTP" });
  }
});

app.post("/verify-reset-otp", (req, res) => {
  const { email, otp } = req.body;
  
  if (!otpStore[email]) {
    return res.status(400).json({ success: false, message: "OTP expired or not found" });
  }

  const storedData = otpStore[email];
  
  if (Date.now() - storedData.timestamp > 5 * 60 * 1000) {
    delete otpStore[email];
    return res.status(400).json({ success: false, message: "OTP expired" });
  }

  if (storedData.otp === otp && storedData.type === 'reset') {
    delete otpStore[email];
    verifiedEmails[email] = { verified: true, timestamp: Date.now() };
    res.json({ success: true, message: "OTP verified successfully" });
  } else {
    res.status(400).json({ success: false, message: "Invalid OTP" });
  }
});

app.post("/register", async (req, res) => {
  const { name, surname, email, password } = req.body;

  if (!name || !surname || !email || !password) {
    return res.status(400).json({ success: false, message: "All fields required" });
  }

  if (!verifiedEmails[email] || !verifiedEmails[email].verified) {
    return res.status(403).json({ success: false, message: "Email not verified" });
  }

  if (Date.now() - verifiedEmails[email].timestamp > 10 * 60 * 1000) {
    delete verifiedEmails[email];
    return res.status(403).json({ success: false, message: "Verification expired" });
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
        delete verifiedEmails[email];
        res.json({ success: true, message: "User registered successfully" });
      }
    );
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

app.post("/reset", async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: "All fields required" });
  }

  if (!verifiedEmails[email] || !verifiedEmails[email].verified) {
    return res.status(403).json({ success: false, message: "Email not verified" });
  }

  if (Date.now() - verifiedEmails[email].timestamp > 10 * 60 * 1000) {
    delete verifiedEmails[email];
    return res.status(403).json({ success: false, message: "Verification expired" });
  }

  try {
    db.get(`SELECT * FROM users WHERE email = ?`, [email], async (err, user) => {
      if (err) {
        console.error(err.message);
        return res.status(500).json({ success: false, message: "Database error" });
      }

      if (!user) {
        return res.status(404).json({ success: false, message: "User not found" });
      }

      const hashedPassword = await bcrypt.hash(password, 10);

      db.run(
        `UPDATE users SET password = ? WHERE email = ?`,
        [hashedPassword, email],
        function (updateErr) {
          if (updateErr) {
            console.error(updateErr.message);
            return res.status(500).json({ success: false, message: "Failed to update password" });
          }

          delete verifiedEmails[email]; 
          return res.json({ success: true, message: "Password updated successfully" });
        }
      );
    });
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

app.get('/user', (req, res) => {
  const email = req.query.email;
  
  if (!email) {
    console.log('❌ Missing email parameter');
    return res.status(400).json({ error: 'Email parameter is required' });
  }
  
  console.log(`🔍 Looking up user with email: ${email}`);
  
  db.get('SELECT id, name, surname, email FROM users WHERE email = ?', [email], (err, row) => {
    if (err) {
      console.error('❌ Database error:', err.message);
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    if (!row) {
      console.log(`❌ User not found: ${email}`);
      return res.status(404).json({ error: 'User not found' });
    }
    
    console.log('✅ User found:', row);
    res.json(row);
  });
});

app.get('/test-db', (req, res) => {
  console.log('🔧 Testing database structure');
  
  db.all("PRAGMA table_info(users)", [], (err, columns) => {
    if (err) {
      console.error('❌ Error getting table info:', err.message);
      return res.status(500).json({ error: 'Database error', details: err.message });
    }
    
    db.get("SELECT COUNT(*) as count FROM users", [], (countErr, countResult) => {
      if (countErr) {
        console.error('❌ Error counting users:', countErr.message);
        return res.status(500).json({ error: 'Database error', details: countErr.message });
      }
      
      res.json({
        database: './users.db',
        table: 'users',
        columns: columns.map(col => ({ name: col.name, type: col.type })),
        row_count: countResult.count,
        status: 'connected'
      });
    });
  });
});


app.post('/api/chat', async (req, res) => {
  try {
    const { message, conversationId, userId } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    const getHistory = () => {
      return new Promise((resolve, reject) => {
        db.all(
          `SELECT role, content FROM conversations 
           WHERE conversation_id = ? AND user_id = ?
           ORDER BY timestamp ASC`,
          [conversationId, userId],
          (err, rows) => {
            if (err) reject(err);
            else resolve(rows || []);
          }
        );
      });
    };

    const history = await getHistory();

    const messages = [
      {
        role: 'system',
        content: 'You are a helpful, empathetic assistant for a mind tracker app. Help users reflect on their thoughts, feelings, and mental wellbeing. Be supportive, understanding, and provide thoughtful insights.'
      },
      ...history,
      {
        role: 'user',
        content: message
      }
    ];

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
      },
      body: JSON.stringify({
        model: 'gpt-3.5-turbo',
        messages: messages,
        temperature: 0.7,
        max_tokens: 500
        
      })
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error?.message || 'OpenAI API error');
    }

    const data = await response.json();
    const aiMessage = data.choices[0].message.content;

    if (userId) {
      db.run(
        `INSERT INTO conversations (user_id, conversation_id, role, content) VALUES (?, ?, ?, ?)`,
        [userId, conversationId, 'user', message]
      );

      db.run(
        `INSERT INTO conversations (user_id, conversation_id, role, content) VALUES (?, ?, ?, ?)`,
        [userId, conversationId, 'assistant', aiMessage]
      );
    }

    res.json({
      message: aiMessage,
      conversationId: conversationId
    });

  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ 
      error: 'Failed to get AI response',
      details: error.message 
    });
  }
});

app.get('/api/conversations/:userId', (req, res) => {
  const { userId } = req.params;

  db.all(
    `SELECT DISTINCT conversation_id, 
     MIN(timestamp) as started_at,
     MAX(timestamp) as last_message_at
     FROM conversations 
     WHERE user_id = ?
     GROUP BY conversation_id
     ORDER BY last_message_at DESC`,
    [userId],
    (err, rows) => {
      if (err) {
        console.error(err.message);
        return res.status(500).json({ error: 'Database error' });
      }
      res.json({ conversations: rows || [] });
    }
  );
});

app.get('/api/conversations/:userId/:conversationId', (req, res) => {
  const { userId, conversationId } = req.params;

  db.all(
    `SELECT role, content, timestamp 
     FROM conversations 
     WHERE user_id = ? AND conversation_id = ?
     ORDER BY timestamp ASC`,
    [userId, conversationId],
    (err, rows) => {
      if (err) {
        console.error(err.message);
        return res.status(500).json({ error: 'Database error' });
      }
      res.json({ messages: rows || [] });
    }
  );
});

app.delete('/api/conversations/:userId/:conversationId', (req, res) => {
  const { userId, conversationId } = req.params;

  db.run(
    `DELETE FROM conversations WHERE user_id = ? AND conversation_id = ?`,
    [userId, conversationId],
    function(err) {
      if (err) {
        console.error(err.message);
        return res.status(500).json({ error: 'Database error' });
      }
      res.json({ 
        message: 'Conversation deleted',
        deletedRows: this.changes 
      });
    }
  );
});

app.listen(PORT, 'https://mind-tracker.onrender.com', () => console.log(`Server running on https://mind-tracker.onrender.com`));
