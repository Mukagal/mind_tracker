const express = require("express");
const nodemailer = require("nodemailer");
const bodyParser = require("body-parser");
const cors = require("cors");
const sqlite3 = require('sqlite3').verbose();
const bcrypt = require('bcrypt');
require('dotenv').config();
console.log("OPENAI_API_KEY:", process.env.OPENAI_API_KEY ? "✅ Loaded" : "❌ Missing");
const ZEN_QUOTES_URL = "https://zenquotes.io/api/random";
const multer = require("multer");
const path = require("path");
const Stripe = require("stripe");
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);


const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, "uploads")); 
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `user_${req.params.id}${ext}`);
  }
});

const upload = multer({ storage });

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
    password TEXT,
    profile_image Text
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
  user_id INTEGER,
  date TEXT NOT NULL,
  morning_mood INTEGER CHECK(morning_mood >= 1 AND morning_mood <= 10),
  day_mood INTEGER CHECK(day_mood >= 1 AND day_mood <= 10),
  evening_mood INTEGER CHECK(evening_mood >= 1 AND evening_mood <= 10),
  night_mood INTEGER CHECK(night_mood >= 1 AND night_mood <= 10),
  diary_note TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
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

db.run(`
    CREATE TABLE IF NOT EXISTS transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      stripe_payment_intent_id TEXT UNIQUE,
      amount REAL NOT NULL,
      currency TEXT DEFAULT 'usd',
      status TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
`);

db.run(`
    CREATE TABLE IF NOT EXISTS insights (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      date TEXT NOT NULL,
      url TEXT,
      image_url TEXT,
      full_content TEXT
    )
  `);

const app = express();
app.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  console.log('🔔 Webhook received');

  try {
    const event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
    
    console.log(`✅ Event type: ${event.type}`);

    if (event.type === 'payment_intent.succeeded') {
      const paymentIntent = event.data.object;
      const userId = paymentIntent.metadata.user_id;

      console.log(`💰 Payment succeeded for user ${userId}`);

      db.run(
        'UPDATE users SET is_premium = 1, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [userId],
        function(err) {
          if (err) {
            console.error('❌ Database error:', err);
          } else {
            console.log(`✅ Updated ${this.changes} rows`);
          }
        }
      );

      db.run(
        'UPDATE transactions SET status = ? WHERE stripe_payment_intent_id = ?',
        ['completed', paymentIntent.id],
        function(err) {
          if (err) console.error('❌ Transaction update error:', err);
        }
      );
    }

    if (event.type === 'checkout.session.completed') {
      const session = event.data.object;
      const userId = session.metadata.user_id;

      console.log(`💳 Checkout completed for user ${userId}`);

      db.run(
        'UPDATE users SET is_premium = 1, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [userId],
        function(err) {
          if (err) {
            console.error('❌ Database error:', err);
          } else {
            console.log(`✅ Updated ${this.changes} rows`);
          }
        }
      );

      db.run(
        `INSERT INTO transactions (user_id, stripe_checkout_session_id, amount, currency, status)
         VALUES (?, ?, ?, ?, ?)`,
        [userId, session.id, session.amount_total, session.currency, 'completed'],
        function(err) {
          if (err) console.error('❌ Transaction insert error:', err);
        }
      );
    }

    res.json({ received: true });
  } catch (err) {
    console.error('❌ Webhook error:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }
});

app.use(cors());
app.use(bodyParser.json());
app.use("/uploads", express.static(path.join(__dirname, "uploads")));
const fs = require('fs');
const MUSIC_DIR = path.join(__dirname, 'musics');


if (!fs.existsSync(MUSIC_DIR)) {
  fs.mkdirSync(MUSIC_DIR, { recursive: true });
}
app.use('/musics', express.static(MUSIC_DIR));


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
  let date = req.params.date;

  const parts = date.split('-');
  if (parts.length === 3) {
    const year = parts[0];
    const month = parts[1].padStart(2, '0');
    const day = parts[2].padStart(2, '0');
    date = `${year}-${month}-${day}`;
  }

  db.get(
    `SELECT quote, author FROM daily_quotes WHERE date = ?`,
    [date],
    async (err, row) => {

      if (err){
        console.error("❌ DB ERROR in /mental-health-quote:", err);
        return res.status(500).json({ error: "DB error", details: err.message });
      } 

      if (row) {
        return res.json({ quote: row.quote, author: row.author });
      }

      try {
        const response = await fetch(ZEN_QUOTES_URL);

        if (!response.ok) {
            console.error("❌ Quote API returned non-200:", response.status);
          return res.status(500).json({
            error: "Failed to fetch quote",
            details: `HTTP ${response.status}`
          });
        }

        let data;
        try {
          data = await response.json();
        } catch (parseErr) {
            console.error("❌ Failed to parse quote API JSON:", parseErr);

          return res.status(500).json({
            error: "Invalid API response",
            details: parseErr.message
          });
        }

        if (!Array.isArray(data) || data.length === 0) {
            console.error("❌ Quote API returned empty data:", data);

          return res.status(500).json({
            error: "Quote API returned empty or invalid data"
          });
        }

        const dateHash = date.split('-').reduce((acc, val) => acc + parseInt(val), 0);
        const index = dateHash % data.length;

        const quote = data[index]?.q || "Stay motivated!";
        const author = data[index]?.a || "Unknown";

        db.run(
          `INSERT INTO daily_quotes (date, quote, author, created_at) VALUES (?, ?, ?, datetime('now'))`,
          [date, quote, author]
        );

        return res.json({ quote, author });

      } catch (error) {
          console.error("❌ Final catch — fetch failed:", error);

        return res.status(500).json({
          error: "Failed to fetch quote" + error,
          details: error.message
        });
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

app.post("/api/upload-profile/:id", upload.single("profile"), (req, res) => {
  const userId = req.params.id;
  const filePath = `/uploads/${req.file.filename}`;

  db.get("SELECT profile_image FROM users WHERE id = ?", [userId], (err, row) => {
    if (err) return res.status(500).json({ error: err.message });

    if (row && row.profile_image) {
      const oldFilePath = path.join(__dirname, row.profile_image);
      fs.unlink(oldFilePath, (unlinkErr) => {
        if (unlinkErr) console.log("Old file not found or already deleted");
      });
    }

    db.run(
      "UPDATE users SET profile_image = ? WHERE id = ?",
      [filePath, userId],
      (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ success: true, path: filePath });
      }
    );
  });
});


app.get('/user', (req, res) => {
  const email = req.query.email;
  
  if (!email) {
    console.log('❌ Missing email parameter');
    return res.status(400).json({ error: 'Email parameter is required' });
  }
  
  console.log(`🔍 Looking up user with email: ${email}`);
  
  db.get('SELECT id, name, surname, email, is_premium FROM users WHERE email = ?', [email], (err, row) => {
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
    const { user_id, start, end } = req.query;

  if (!start || !end) {
    return res.status(400).json({ error: 'Start and end dates required' });
  }


  db.all(
    `SELECT * FROM day_entries 
    WHERE user_id = ? AND date BETWEEN ? AND ? 
    ORDER BY date ASC`,
    [user_id, start, end],

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
  const { user_id } = req.query;

db.get(
  `SELECT * FROM day_entries WHERE user_id = ? AND date = ?`,
  [user_id, date],
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
  const { mood_type, value, user_id } = req.body;
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
  db.get(`SELECT * FROM day_entries WHERE user_id = ? AND date = ?`, [user_id, date], (err, row) => {
      if (err) {
      console.error('❌ Database error:', err.message);
      return res.status(500).json({ error: 'Database error', details: err.message });
    }

    if (row) {
      console.log(`Updating existing entry for ${date}`);
      db.run(
        `UPDATE day_entries SET ${dbMoodType} = ?, updated_at = ? WHERE user_id = ? AND date = ?`,
        [value, now, user_id, date],
        function(updateErr) {
          if (updateErr) {
            console.error('❌ Update error:', updateErr.message);
            return res.status(500).json({ error: 'Failed to update entry', details: updateErr.message });
          }

          console.log(`✅ Updated ${dbMoodType} successfully`);

          db.get(`SELECT * FROM day_entries WHERE user_id = ? AND date = ?`, [user_id, date], (getErr, updatedRow) => {
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
        `INSERT INTO day_entries (user_id, date, ${dbMoodType}, created_at, updated_at) 
 VALUES (?, ?, ?, ?, ?)`,
[user_id, date, value, now, now],
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
  const { diary_note, user_id } = req.body;


  console.log(`Updating diary for ${date}: "${diary_note}"`);

  const now = new Date().toISOString();

  db.get(`SELECT * FROM day_entries WHERE user_id = ? AND date = ?`, [user_id, date], (err, row) => {
    if (err) {
      console.error('Database error:', err.message);
      return res.status(500).json({ error: 'Database error', details: err.message });
    }

    if (row) {
      db.run(
        `UPDATE day_entries SET diary_note = ?, updated_at = ? WHERE user_id = ? AND date = ?`,
[diary_note, now, user_id, date],
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
        `INSERT INTO day_entries (user_id, date, diary_note, created_at, updated_at) 
 VALUES (?, ?, ?, ?, ?)`,
[user_id, date, diary_note, now, now],
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

const getUserStatus = (userId) => {
  return new Promise((resolve, reject) => {
    db.get(
      `SELECT is_premium FROM users WHERE id = ?`,
      [userId],
      (err, row) => {
        if (err) reject(err);
        else resolve(row?.is_premium === 1); 
      }
    );
  });
};

app.get('/api/user/:id/status', async (req, res) => {
  try {
    const userId = req.params.id;
    const isPremium = await getUserStatus(userId);

    res.json({ is_premium: isPremium });
  } catch (err) {
    res.status(500).json({ error: 'Database error' });
  }
});


app.post('/api/chat', async (req, res) => {
  try {
    const { message, conversationId, userId } = req.body;
    if (!message) return res.status(400).json({ error: 'Message is required' });

    const isPremium = userId ? await getUserStatus(userId) : false;

    const getHistory = () => {
      return new Promise((resolve, reject) => {
        db.all(
          `SELECT role, content FROM conversations 
           WHERE conversation_id = ? AND user_id = ?
           ORDER BY timestamp ASC`,
          [conversationId, userId],
          (err, rows) => (err ? reject(err) : resolve(rows || []))
        );
      });
    };

    const history = await getHistory();

    const baseSystemPrompt = `
      You are a supportive assistant for a mental wellbeing app.
      Help users reflect, express feelings, and grow emotionally.
      Reply kindly, ask meaningful questions, and offer grounding suggestions.
    `;

    const premiumAddition = `
      Since this user is a premium member, provide deeper emotional insights,
      more personalized coping strategies, and extended reflective analysis.
    `;

    const messages = [
      { role: "system", content: isPremium ? baseSystemPrompt + premiumAddition : baseSystemPrompt },
      ...history,
      { role: "user", content: message }
    ];

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
      },
      body: JSON.stringify({
        model: isPremium ? 'gpt-4.1' : 'gpt-3.5-turbo',  
        messages,
        temperature: isPremium ? 0.9 : 0.6,
        max_tokens: isPremium ? 1200 : 400              
      })
    });

    const data = await response.json();
    const aiMessage = data.choices[0].message.content;

    db.run(`INSERT INTO conversations (user_id, conversation_id, role, content) VALUES (?, ?, ?, ?)`,
      [userId, conversationId, 'user', message]);
    db.run(`INSERT INTO conversations (user_id, conversation_id, role, content) VALUES (?, ?, ?, ?)`,
      [userId, conversationId, 'assistant', aiMessage]);

    res.json({ 
      message: aiMessage, 
      conversationId 
    });

  } catch (error) {
    console.error("Chat Error:", error);
    res.status(500).json({ 
      error: "Failed to get AI response", 
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


app.use('/musics', express.static(MUSIC_DIR, {
  setHeaders: (res, filePath) => {
    const ext = path.extname(filePath).toLowerCase();
    const mimeTypes = {
      '.mp3': 'audio/mpeg',
      '.wav': 'audio/wav',
      '.m4a': 'audio/mp4',
      '.ogg': 'audio/ogg',
      '.aac': 'audio/aac'
    };
    
    if (mimeTypes[ext]) {
      res.setHeader('Content-Type', mimeTypes[ext]);
      res.setHeader('Accept-Ranges', 'bytes');
      res.setHeader('Cache-Control', 'public, max-age=31536000');
    }
  }
}));

app.get('/api/music/list', (req, res) => {
  try {
    const files = fs.readdirSync(MUSIC_DIR);
    const musicFiles = files.filter(file => {
      const ext = path.extname(file).toLowerCase();
      return ['.mp3', '.wav', '.m4a', '.ogg', '.aac'].includes(ext);
    });

    const musicList = musicFiles.map(file => ({
      id: file,
      name: path.parse(file).name,
      filename: file,
      path: `/musics/${encodeURIComponent(file)}`, 
      size: fs.statSync(path.join(MUSIC_DIR, file)).size
    }));

    res.json({
      success: true,
      count: musicList.length,
      music: musicList
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

app.get('/api/music/:filename', (req, res) => {
  try {
    const { filename } = req.params;
    const filePath = path.join(MUSIC_DIR, filename);

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        success: false,
        error: 'Music file not found'
      });
    }

    const stats = fs.statSync(filePath);
    res.json({
      success: true,
      music: {
        id: filename,
        name: path.parse(filename).name,
        filename: filename,
        path: `/musics/${encodeURIComponent(filename)}`,
        size: stats.size
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});


app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.post('/api/create-payment-intent', async (req, res) => {
  try {
    const { user_id, amount, currency } = req.body;

    const user = await new Promise((resolve, reject) => {
      db.get('SELECT * FROM users WHERE id = ?', [user_id], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    let customerId = user.stripe_customer_id;
    
    if (!customerId) {
      const customer = await stripe.customers.create({
        email: user.email,
        metadata: { user_id: user_id.toString() },
      });
      customerId = customer.id;

      await new Promise((resolve, reject) => {
        db.run(
          'UPDATE users SET stripe_customer_id = ? WHERE id = ?',
          [customerId, user_id],
          (err) => err ? reject(err) : resolve()
        );
      });
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: currency || 'usd',
      customer: customerId,
      metadata: { user_id: user_id.toString() },
      automatic_payment_methods: { enabled: true },
    });

    // Create transaction record
    await new Promise((resolve, reject) => {
      db.run(
        `INSERT INTO transactions (user_id, stripe_payment_intent_id, amount, currency, status)
         VALUES (?, ?, ?, ?, ?)`,
        [user_id, paymentIntent.id, amount, currency || 'usd', 'pending'],
        (err) => err ? reject(err) : resolve()
      );
    });

    res.json({
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

app.post('/api/create-checkout-session', async (req, res) => {
  const { user_id, amount, currency } = req.body;

  try {
    const domain = process.env.FRONTEND_URL || 'http://localhost:3000';
    
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: currency || 'usd',
            product_data: {
              name: 'Premium Subscription',
            },
            unit_amount: amount, 
          },
          quantity: 1,
        },
      ],
      mode: 'payment',
      success_url: `${domain}/premium-upgrade?session_id={CHECKOUT_SESSION_ID}`, 
      cancel_url: `${domain}/payment-cancel`,
      metadata: {
        user_id: user_id.toString(),
      },
    });

    res.json({ url: session.url, sessionId: session.id });
  } catch (error) {
    console.error('Checkout session error:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/verify-checkout-session/:sessionId', async (req, res) => {
  try {
    const { sessionId } = req.params;
    const session = await stripe.checkout.sessions.retrieve(sessionId);

    const userId = session.metadata.user_id;
    const user = await new Promise((resolve, reject) => {
      db.get('SELECT is_premium FROM users WHERE id = ?', [userId], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });

    res.json({
      success: session.payment_status === 'paid',
      is_premium: Boolean(user?.is_premium),
      payment_status: session.payment_status,
    });
  } catch (error) {
    console.error('Checkout verification error:', error);
    res.status(500).json({ error: 'Verification failed' });
  }
});

app.post('/api/verify-payment', async (req, res) => {
  try {
    const { payment_intent_id } = req.body;

    if (!payment_intent_id) {
      return res.status(400).json({ error: 'Payment intent ID is required' });
    }

    const paymentIntent = await stripe.paymentIntents.retrieve(payment_intent_id);
    const userId = paymentIntent.metadata.user_id;

    const user = await new Promise((resolve, reject) => {
      db.get('SELECT is_premium FROM users WHERE id = ?', [userId], (err, row) => {
        if (err) reject(err);
        else resolve(row);
      });
    });

    res.json({
      success: paymentIntent.status === 'succeeded',
      is_premium: Boolean(user?.is_premium),
      status: paymentIntent.status,
    });
  } catch (error) {
    console.error('Verification error:', error);
    res.status(500).json({ error: 'Verification failed' });
  }
});

app.get('/api/premium-status/:userId', (req, res) => {
  const { userId } = req.params;

  db.get(
    'SELECT is_premium, premium_expires_at FROM users WHERE id = ?',
    [userId],
    (err, row) => {
      if (err) {
        console.error('Database error:', err);
        return res.status(500).json({ error: 'Database error' });
      }
      if (!row) {
        return res.status(404).json({ error: 'User not found' });
      }

      res.json({
        is_premium: Boolean(row.is_premium),
        premium_expires_at: row.premium_expires_at,
      });
    }
  );
});

async function fetchNHSInsights() {
  try {
    const topics = ['anxiety', 'depression', 'stress', 'mindfulness', 'sleep'];
    const randomTopic = topics[Math.floor(Math.random() * topics.length)];
    
    const response = await axios.get(
      `https://api.nhs.uk/conditions/?category=mental-health&search=${randomTopic}`,
      {
        headers: {
          'subscription-key': process.env.NHS_API_KEY || 'your-api-key-here'
        }
      }
    );

    return response.data;
  } catch (error) {
    console.error('Error fetching NHS data:', error.message);

    return getMockInsights();
  }
}

function getMockInsights() {
  return [
    {
      name: 'Managing Daily Stress',
      description: 'Learn effective techniques to manage stress in your daily life, including breathing exercises and mindfulness practices.',
      url: 'https://www.nhs.uk/mental-health/self-help/guides-tools-and-activities/tips-to-reduce-stress/',
      category: 'Stress Management',
      fullContent: 'Stress is a natural response to challenging situations. Here are evidence-based techniques: 1) Practice deep breathing for 5 minutes daily. 2) Engage in regular physical activity. 3) Maintain a consistent sleep schedule. 4) Connect with supportive friends and family. 5) Set realistic goals and priorities.'
    },
    {
      name: 'Better Sleep Hygiene',
      description: 'Discover how to improve your sleep quality through proven sleep hygiene practices and routine building.',
      url: 'https://www.nhs.uk/live-well/sleep-and-tiredness/how-to-get-to-sleep/',
      category: 'Sleep & Wellbeing',
      fullContent: 'Quality sleep is essential for mental health. Key practices include: keeping a regular sleep schedule, creating a relaxing bedtime routine, making your bedroom comfortable and cool, avoiding caffeine and screens before bed, and getting regular exercise during the day.'
    },
    {
      name: 'Mindfulness for Beginners',
      description: 'An introduction to mindfulness meditation and its benefits for mental wellbeing and emotional regulation.',
      url: 'https://www.nhs.uk/mental-health/self-help/tips-and-support/mindfulness/',
      category: 'Mindfulness',
      fullContent: 'Mindfulness means paying attention to the present moment without judgment. Start with just 5 minutes daily: find a quiet space, focus on your breath, notice when your mind wanders, and gently return attention to breathing. Regular practice can reduce anxiety and improve emotional wellbeing.'
    }
  ];
}

app.get('/api/insights/:date', async (req, res) => {
  const { date } = req.params;

  db.all(
    'SELECT * FROM insights WHERE date = ? LIMIT 3',
    [date],
    async (err, rows) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }

      if (rows.length === 0) {
        const nhsData = await fetchNHSInsights();
        const insights = Array.isArray(nhsData) ? nhsData : getMockInsights();
        const insightsToStore = insights.slice(0, 3);

        const stmt = db.prepare(`
          INSERT INTO insights (title, description, category, date, url, full_content)
          VALUES (?, ?, ?, ?, ?, ?)
        `);

        const storedInsights = [];
        for (const insight of insightsToStore) {
          await new Promise((resolve, reject) => {
            stmt.run(
              insight.name || insight.title,
              insight.description,
              insight.category || 'Mental Health',
              date,
              insight.url,
              insight.fullContent || insight.description,
              function(err) {
                if (err) reject(err);
                else {
                  storedInsights.push({
                    id: this.lastID,
                    title: insight.name || insight.title,
                    description: insight.description,
                    category: insight.category || 'Mental Health',
                    date: date,
                    url: insight.url,
                    fullContent: insight.fullContent || insight.description
                  });
                  resolve();
                }
              }
            );
          });
        }

        stmt.finalize();
        return res.json(storedInsights);
      }

      res.json(rows);
    }
  );
});

app.get('/api/insight/:id', (req, res) => {
  const { id } = req.params;

  db.get(
    'SELECT * FROM insights WHERE id = ?',
    [id],
    (err, row) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
      if (!row) {
        return res.status(404).json({ error: 'Insight not found' });
      }
      res.json(row);
    }
  );
});

app.delete('/api/insights/cleanup', (req, res) => {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - 30);
  const dateString = cutoffDate.toISOString().split('T')[0];

  db.run(
    'DELETE FROM insights WHERE date < ?',
    [dateString],
    function(err) {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
      res.json({ deleted: this.changes });
    }
  );
});

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));