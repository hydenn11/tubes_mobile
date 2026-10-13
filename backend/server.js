const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
require('dotenv').config();

const { initDB, getPool } = require('./db');

const app = express();
const PORT = process.env.PORT || 8000;
const JWT_SECRET = process.env.JWT_SECRET || 'secretkey';

// Setup Uploads folder
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  },
});
const upload = multer({ storage });

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(uploadDir));

// Middleware Auth JWT
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ status: false, message: 'Token otentikasi tidak ditemukan' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ status: false, message: 'Token tidak valid' });
    }
    req.user = user;
    next();
  });
}

// ==========================================
// 1. AUTH ROUTES
// ==========================================

// Register Pelamar
app.post('/auth/register/pelamar', async (req, res) => {
  try {
    const { email, username, password, first_name, last_name } = req.body;
    if (!email || !password || !first_name) {
      return res.status(400).json({ status: false, message: 'Data tidak lengkap' });
    }

    const trimmedEmail = email.trim().toLowerCase();
    const trimmedUsername = username ? username.trim().toLowerCase() : null;

    const pool = getPool();
    // Cek apakah email sudah terdaftar
    const [existing] = await pool.query('SELECT * FROM users WHERE email = ?', [trimmedEmail]);
    if (existing.length > 0) {
      return res.status(400).json({ status: false, message: 'Email sudah terdaftar' });
    }

    // Cek apakah username sudah terdaftar
    if (trimmedUsername) {
      const [existingUser] = await pool.query('SELECT * FROM users WHERE username = ?', [trimmedUsername]);
      if (existingUser.length > 0) {
        return res.status(400).json({ status: false, message: 'Username sudah digunakan, silakan pilih username lain' });
      }
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const [userResult] = await pool.query(
      'INSERT INTO users (email, username, password, role) VALUES (?, ?, ?, ?)',
      [trimmedEmail, trimmedUsername, hashedPassword, 'pelamar']
    );

    const userId = userResult.insertId;
    await pool.query(
      'INSERT INTO pelamar (user_id, first_name, last_name, email, username) VALUES (?, ?, ?, ?, ?)',
      [userId, first_name, last_name || '', trimmedEmail, trimmedUsername]
    );

    return res.status(201).json({
      status: true,
      message: 'Akun pelamar berhasil dibuat',
    });
  } catch (error) {
    console.error('Register Pelamar Error:', error);
    return res.status(500).json({ status: false, message: error.message });
  }
});

// Register Perusahaan / HRD
app.post('/auth/register/perusahaan', async (req, res) => {
  try {
    const { email, password, nama_perusahaan, alamat } = req.body;
    if (!email || !password || !nama_perusahaan) {
      return res.status(400).json({ status: false, message: 'Data tidak lengkap' });
    }

    const pool = getPool();
    const [existing] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return res.status(400).json({ status: false, message: 'Email sudah terdaftar' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const [userResult] = await pool.query(
      'INSERT INTO users (email, password, role) VALUES (?, ?, ?)',
      [email, hashedPassword, 'perusahaan']
    );

    const userId = userResult.insertId;
    await pool.query(
      'INSERT INTO perusahaan (user_id, nama_perusahaan, email, alamat) VALUES (?, ?, ?, ?)',
      [userId, nama_perusahaan, email, alamat || '']
    );

    return res.status(201).json({
      status: true,
      message: 'Akun perusahaan berhasil dibuat',
    });
  } catch (error) {
    console.error('Register Perusahaan Error:', error);
    return res.status(500).json({ status: false, message: error.message });
  }
});

// Login (bisa menggunakan email ATAU username)
app.post('/auth/login', async (req, res) => {
  try {
    const identifier = (req.body.email || req.body.username || req.body.identifier || '').trim().toLowerCase();
    const { password } = req.body;
    if (!identifier || !password) {
      return res.status(400).json({ status: false, message: 'Email/Username dan password wajib diisi' });
    }

    const pool = getPool();

    const [users] = await pool.query(
      'SELECT * FROM users WHERE LOWER(email) = ? OR LOWER(username) = ?',
      [identifier, identifier]
    );
    if (users.length === 0) {
      return res.status(400).json({ status: false, message: 'Email/Username atau password salah' });
    }

    const user = users[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ status: false, message: 'Email/Username atau password salah' });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, username: user.username, role: user.role },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    return res.status(200).json({
      status: true,
      token: token,
      role: user.role,
      username: user.username,
    });
  } catch (error) {
    console.error('Login Error:', error);
    return res.status(500).json({ status: false, message: error.message });
  }
});

// Get Current User Profile (Me)
app.get('/auth/me', authenticateToken, async (req, res) => {
  try {
    const pool = getPool();
    const userId = req.user.id;
    const role = req.user.role;

    if (role === 'pelamar') {
      const [rows] = await pool.query('SELECT * FROM pelamar WHERE user_id = ?', [userId]);
      if (rows.length === 0) {
        return res.status(404).json({ status: false, message: 'Profil pelamar tidak ditemukan' });
      }
      return res.status(200).json({
        status: true,
        data: {
          id: req.user.id,
          id_pelamar: rows[0].id,
          email: req.user.email,
          username: req.user.username || rows[0].username || '',
          role: 'pelamar',
          first_name: rows[0].first_name,
          last_name: rows[0].last_name,
          aboutMe: rows[0].about_me || '',
          about_me: rows[0].about_me || '',
          profile_pict: rows[0].profile_pict,
          cv_path: rows[0].cv_path,
        },
      });
    } else {
      const [rows] = await pool.query('SELECT * FROM perusahaan WHERE user_id = ?', [userId]);
      if (rows.length === 0) {
        return res.status(404).json({ status: false, message: 'Profil perusahaan tidak ditemukan' });
      }

      return res.status(200).json({
        status: true,
        data: {
          id: req.user.id,
          id_perusahaan: rows[0].id,
          email: req.user.email,
          role: 'perusahaan',
          nama_perusahaan: rows[0].nama_perusahaan,
          alamat: rows[0].alamat || '',
          deskripsi: rows[0].deskripsi || '',
          about_me: rows[0].deskripsi || '',
          aboutMe: rows[0].deskripsi || '',
          profile_pict: rows[0].profile_pict,
        },
      });
    }
  } catch (error) {
    console.error('Me Error:', error);
    return res.status(500).json({ status: false, message: error.message });
  }
});

// ==========================================
// 2. PELAMAR ROUTES
// ==========================================

app.get('/pelamar/:id', authenticateToken, async (req, res) => {
  try {
    const pool = getPool();
    const [rows] = await pool.query('SELECT * FROM pelamar WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ status: false, message: 'Pelamar tidak ditemukan' });
    }
    return res.status(200).json({ status: true, data: rows[0] });
  } catch (error) {
    return res.status(500).json({ status: false, message: error.message });
  }
});

app.put('/pelamar/:id', authenticateToken, async (req, res) => {
  try {
    const { first_name, last_name, email } = req.body;
    const about_me = req.body.aboutMe !== undefined ? req.body.aboutMe : (req.body.about_me !== undefined ? req.body.about_me : '');
    const pool = getPool();

    const [existing] = await pool.query('SELECT * FROM pelamar WHERE id = ?', [req.params.id]);
    if (existing.length === 0) {
      return res.status(404).json({ status: false, message: 'Pelamar tidak ditemukan' });
    }

    const current = existing[0];
    const newFirstName = (first_name !== undefined && first_name.trim() !== '') ? first_name.trim() : current.first_name;
    const newLastName = (last_name !== undefined) ? last_name.trim() : current.last_name;
    const newEmail = (email !== undefined && email.trim() !== '') ? email.trim() : current.email;
    const newAboutMe = (about_me !== undefined) ? about_me : (current.about_me || '');

    await pool.query(
      'UPDATE pelamar SET first_name = ?, last_name = ?, email = ?, about_me = ? WHERE id = ?',
      [newFirstName, newLastName, newEmail, newAboutMe, req.params.id]
    );

    if (newEmail && newEmail !== current.email) {
      await pool.query('UPDATE users SET email = ? WHERE id = ?', [newEmail, current.user_id]);
    }

    return res.status(200).json({ status: true, message: 'Data pelamar berhasil diperbarui' });
  } catch (error) {
    console.error('Update pelamar error:', error);
    return res.status(500).json({ status: false, message: error.message });
  }
});


app.patch('/pelamar/:id/profile-picture', authenticateToken, upload.single('profile_pict'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ status: false, message: 'Gambar tidak ditemukan' });
    }
    const pool = getPool();
    const fileUrl = `/uploads/${req.file.filename}`;
    await pool.query('UPDATE pelamar SET profile_pict = ? WHERE id = ?', [fileUrl, req.params.id]);
    return res.status(200).json({ status: true, message: 'Foto profil berhasil diubah', fileUrl });
  } catch (error) {
    return res.status(500).json({ status: false, message: error.message });
  }
});

app.patch('/pelamar/:id/cv', authenticateToken, upload.single('CV'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ status: false, message: 'File CV tidak ditemukan' });
    }
    const pool = getPool();
    const fileUrl = `/uploads/${req.file.filename}`;
    await pool.query('UPDATE pelamar SET cv_path = ? WHERE id = ?', [fileUrl, req.params.id]);
    return res.status(200).json({ status: true, message: 'CV berhasil diupload', fileUrl });
  } catch (error) {
    return res.status(500).json({ status: false, message: error.message });
  }
});

// ==========================================
// 3. JOBS / LOWONGAN ROUTES
// ==========================================

app.get('/jobs', async (req, res) => {
  try {
    const pool = getPool();
    const [rows] = await pool.query(`
      SELECT j.*, p.nama_perusahaan, p.profile_pict as company_logo 
      FROM jobs j 
      JOIN perusahaan p ON j.id_perusahaan = p.id 
      ORDER BY j.created_at DESC
    `);
    return res.status(200).json({ status: true, data: rows });
  } catch (error) {
    return res.status(500).json({ status: false, message: error.message });
  }
});

app.get('/jobs/company/:id', authenticateToken, async (req, res) => {
  try {
    const pool = getPool();
    const [rows] = await pool.query('SELECT * FROM jobs WHERE id_perusahaan = ?', [req.params.id]);
    return res.status(200).json({ status: true, data: rows });
  } catch (error) {
    return res.status(500).json({ status: false, message: error.message });
  }
});

app.get('/jobs/:id', async (req, res) => {
  try {
    const pool = getPool();
    const [rows] = await pool.query(`
      SELECT j.*, p.nama_perusahaan, p.alamat as alamat_perusahaan, p.deskripsi as deskripsi_perusahaan, p.profile_pict 
      FROM jobs j 
      JOIN perusahaan p ON j.id_perusahaan = p.id 
      WHERE j.id = ?
    `, [req.params.id]);
    return res.status(200).json({ status: true, data: rows });
  } catch (error) {
    return res.status(500).json({ status: false, message: error.message });
  }
});

app.post('/jobs', authenticateToken, async (req, res) => {
  try {
    const { idPerusahaan, posisi, lokasi, jobDetails, requirements } = req.body;
    const pool = getPool();
    await pool.query(
      'INSERT INTO jobs (id_perusahaan, posisi, lokasi, job_details, requirements) VALUES (?, ?, ?, ?, ?)',
      [idPerusahaan, posisi, lokasi, jobDetails, requirements]
    );
    return res.status(201).json({ status: true, message: 'Lowongan berhasil diposting' });
  } catch (error) {
    return res.status(500).json({ status: false, message: error.message });
  }
});

// ==========================================
// 4. PERUSAHAAN ROUTES
// ==========================================

app.get('/perusahaan', async (req, res) => {
  try {
    const pool = getPool();
    const [rows] = await pool.query('SELECT * FROM perusahaan');
    return res.status(200).json({ status: true, data: rows });
  } catch (error) {
    return res.status(500).json({ status: false, message: error.message });
  }
});

app.get('/perusahaan/:id', async (req, res) => {
  try {
    const pool = getPool();
    const [rows] = await pool.query('SELECT * FROM perusahaan WHERE id = ?', [req.params.id]);
    return res.status(200).json({ status: true, data: rows[0] || null });
  } catch (error) {
    return res.status(500).json({ status: false, message: error.message });
  }
});

app.get('/perusahaan/:id/applications', authenticateToken, async (req, res) => {
  try {
    const pool = getPool();
    const [rows] = await pool.query(`
      SELECT a.*, p.first_name, p.last_name, p.email, p.cv_path, j.posisi
      FROM applications a
      JOIN pelamar p ON a.id_pelamar = p.id
      JOIN jobs j ON a.id_postingan = j.id
      WHERE j.id_perusahaan = ?
    `, [req.params.id]);
    return res.status(200).json({ status: true, data: rows });
  } catch (error) {
    return res.status(500).json({ status: false, message: error.message });
  }
});

app.put('/perusahaan/updateDataPerusahaan', authenticateToken, async (req, res) => {
  try {
    const { idPerusahaan, email, nama_perusahaan, aboutMe, alamat } = req.body;
    const deskripsi = aboutMe || req.body.deskripsi || '';
    const pool = getPool();
    await pool.query(
      'UPDATE perusahaan SET email = ?, nama_perusahaan = ?, deskripsi = ?, alamat = ? WHERE id = ?',
      [email, nama_perusahaan, deskripsi, alamat || '', idPerusahaan]
    );
    if (email) {
      await pool.query('UPDATE users SET email = ? WHERE id = ?', [email, req.user.id]);
    }
    return res.status(200).json({ status: true, message: 'Data perusahaan berhasil diperbarui' });
  } catch (error) {
    return res.status(500).json({ status: false, message: error.message });
  }
});


// ==========================================
// 5. SAVED JOBS ROUTES
// ==========================================

app.get('/saved-jobs/pelamar/:id', authenticateToken, async (req, res) => {
  try {
    const pool = getPool();
    const [rows] = await pool.query(`
      SELECT sj.id as id_saved, j.*, p.nama_perusahaan 
      FROM saved_jobs sj 
      JOIN jobs j ON sj.id_postingan = j.id 
      JOIN perusahaan p ON j.id_perusahaan = p.id 
      WHERE sj.id_pelamar = ?
    `, [req.params.id]);
    return res.status(200).json({ status: true, data: rows });
  } catch (error) {
    return res.status(500).json({ status: false, message: error.message });
  }
});

// Start Server
async function startServer() {
  await initDB();
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server backend RekanPabrik berjalan di http://localhost:${PORT}`);
  });
}

startServer();
