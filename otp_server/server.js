const express = require("express");
const nodemailer = require("nodemailer");
const bodyParser = require("body-parser");
const cors = require("cors");
const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcrypt');
require('dotenv').config();
console.log("OPENAI_API_KEY:", process.env.OPENAI_API_KEY ? "✅ Loaded" : "❌ Missing");
const ZEN_QUOTES_URL = "https://zenquotes.io/api/random";
const QUOTABLE_URL = "https://api.quotable.io/random?tags=inspirational";
const QUOTESLATE_URL = "https://quoteslate.vercel.app/api/quotes/random";


const PORT = process.env.PORT || 3000;

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

db.run(`
  CREATE TABLE IF NOT EXISTS day_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT UNIQUE NOT NULL,
    morning_mood INTEGER CHECK(morning_mood >= 1 AND morning_mood <= 10),
    day_mood INTEGER CHECK(day_mood >= 1 AND day_mood <= 10),
    evening_mood INTEGER CHECK(evening_mood >= 1 AND evening_mood <= 10),
    night_mood INTEGER CHECK(night_mood >= 1 AND night_mood <= 10),
    diary_note TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
  )
`);
db.run(`
  CREATE TABLE IF NOT EXISTS daily_quotes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT UNIQUE NOT NULL,
    quote TEXT NOT NULL,
    author TEXT,
    created_at TEXT NOT NULL
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

app.get("/mental-health-quote/:date", async (req, res) => {
  const date = req.params.date;

  db.get(
    `SELECT quote, author FROM daily_quotes WHERE date = ?`,
    [date],
    async (err, row) => {
      if (err) return res.status(500).json({ error: "DB error" });

      if (row) {
        return res.json({ quote: row.quote, author: row.author });
      }

      try {
        const response = await fetch(ZEN_QUOTES_URL);
        const data = await response.json();

        const quote = data[0]?.q || data.content;
        const author = data[0]?.a || data.author;

        db.run(
          `INSERT INTO daily_quotes (date, quote, author, created_at) VALUES (?, ?, ?, datetime('now'))`,
          [date, quote, author]
        );

        return res.json({ quote, author });
      } catch (error) {
        return res.status(500).json({ error: "Failed to fetch quote" });
      }
    }
  );
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

app.get('/api/entries', (req, res) => {
  const { start, end } = req.query;
  
  if (!start || !end) {
    return res.status(400).json({ error: 'Start and end dates required' });
  }

  db.all(
    `SELECT * FROM day_entries WHERE date BETWEEN ? AND ? ORDER BY date ASC`,
    [start, end],
    (err, rows) => {
      if (err) {
        console.error(err.message);
        return res.status(500).json({ error: 'Database error' });
      }
      res.json(rows || []);
    }
  );
});

app.get('/api/entries/:date', (req, res) => {
  const { date } = req.params;

  db.get(
    `SELECT * FROM day_entries WHERE date = ?`,
    [date],
    (err, row) => {
      if (err) {
        console.error(err.message);
        return res.status(500).json({ error: 'Database error' });
      }
      
      if (!row) {
        return res.status(404).json({ error: 'Entry not found' });
      }
      
      res.json(row);
    }
  );
});

app.patch('/api/entries/:date/mood', (req, res) => {
  const { date } = req.params;
  const { mood_type, value } = req.body;

  console.log(`Updating mood for ${date}: ${mood_type} = ${value}`);

  if (!mood_type || value === undefined || value === null) {
    console.error('❌ Missing mood_type or value');
    return res.status(400).json({ error: 'mood_type and value required' });
  }

  if (value < 1 || value > 10) {
    console.error('❌ Invalid value range:', value);
    return res.status(400).json({ error: 'Value must be between 1 and 10' });
  }

  const moodTypeMap = {
    'morning': 'morning_mood',
    'day': 'day_mood',
    'evening': 'evening_mood',
    'night': 'night_mood',
    'morning_mood': 'morning_mood',
    'day_mood': 'day_mood',
    'evening_mood': 'evening_mood',
    'night_mood': 'night_mood'
  };

  const dbMoodType = moodTypeMap[mood_type];
  
  if (!dbMoodType) {
    console.error('❌ Invalid mood_type:', mood_type);
    return res.status(400).json({ error: 'Invalid mood_type' });
  }

  console.log(`Mapped mood_type: ${mood_type} -> ${dbMoodType}`);

  const now = new Date().toISOString();

  db.get(`SELECT * FROM day_entries WHERE date = ?`, [date], (err, row) => {
    if (err) {
      console.error('❌ Database error:', err.message);
      return res.status(500).json({ error: 'Database error', details: err.message });
    }

    if (row) {
      console.log(`Updating existing entry for ${date}`);
      db.run(
        `UPDATE day_entries SET ${dbMoodType} = ?, updated_at = ? WHERE date = ?`,
        [value, now, date],
        function(updateErr) {
          if (updateErr) {
            console.error('❌ Update error:', updateErr.message);
            return res.status(500).json({ error: 'Failed to update entry', details: updateErr.message });
          }

          console.log(`✅ Updated ${dbMoodType} successfully`);

          db.get(`SELECT * FROM day_entries WHERE date = ?`, [date], (getErr, updatedRow) => {
            if (getErr) {
              console.error('❌ Error fetching updated row:', getErr.message);
              return res.status(500).json({ error: 'Database error', details: getErr.message });
            }
            console.log('✅ Returning updated entry:', updatedRow);
            res.json(updatedRow);
          });
        }
      );
    } else {
      console.log(`Creating new entry for ${date}`);
      db.run(
        `INSERT INTO day_entries (date, ${dbMoodType}, created_at, updated_at) 
         VALUES (?, ?, ?, ?)`,
        [date, value, now, now],
        function(insertErr) {
          if (insertErr) {
            console.error('❌ Insert error:', insertErr.message);
            return res.status(500).json({ error: 'Failed to create entry', details: insertErr.message });
          }

          console.log(`✅ Created new entry with ${dbMoodType}`);

          db.get(`SELECT * FROM day_entries WHERE date = ?`, [date], (getErr, newRow) => {
            if (getErr) {
              console.error('❌ Error fetching new row:', getErr.message);
              return res.status(500).json({ error: 'Database error', details: getErr.message });
            }
            console.log('✅ Returning new entry:', newRow);
            res.json(newRow);
          });
        }
      );
    }
  });
});

app.patch('/api/entries/:date/diary', (req, res) => {
  const { date } = req.params;
  const { diary_note } = req.body;

  console.log(`Updating diary for ${date}: "${diary_note}"`);

  const now = new Date().toISOString();

  db.get(`SELECT * FROM day_entries WHERE date = ?`, [date], (err, row) => {
    if (err) {
      console.error('Database error:', err.message);
      return res.status(500).json({ error: 'Database error', details: err.message });
    }

    if (row) {
      db.run(
        `UPDATE day_entries SET diary_note = ?, updated_at = ? WHERE date = ?`,
        [diary_note, now, date],
        function(updateErr) {
          if (updateErr) {
            console.error('Update error:', updateErr.message);
            return res.status(500).json({ error: 'Failed to update diary note', details: updateErr.message });
          }
          console.log('✅ Diary note updated successfully');
          res.json({ message: 'Diary note updated successfully' });
        }
      );
    } else {
      db.run(
        `INSERT INTO day_entries (date, diary_note, created_at, updated_at) 
         VALUES (?, ?, ?, ?)`,
        [date, diary_note, now, now],
        function(insertErr) {
          if (insertErr) {
            console.error('Insert error:', insertErr.message);
            return res.status(500).json({ error: 'Failed to create entry', details: insertErr.message });
          }
          console.log('✅ Diary note created successfully');
          res.json({ message: 'Diary note created successfully' });
        }
      );
    }
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

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));