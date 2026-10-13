const mysql = require('mysql2/promise');
require('dotenv').config();

const dbConfig = {
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
};

let pool;

async function initDB() {
  try {
    // 1. Buat database jika belum ada
    const connection = await mysql.createConnection(dbConfig);
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${process.env.DB_NAME || 'rekanpabrik_db'}\`;`);
    await connection.end();

    // 2. Buat connection pool ke database
    pool = mysql.createPool({
      ...dbConfig,
      database: process.env.DB_NAME || 'rekanpabrik_db',
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
    });

    console.log('✅ Berhasil terhubung ke database MySQL:', process.env.DB_NAME || 'rekanpabrik_db');

    // 3. Buat tabel-tabel yang dibutuhkan
    await createTables();
  } catch (error) {
    console.error('❌ Gagal menginisialisasi database MySQL:', error.message);
    process.exit(1);
  }
}

async function createTables() {
  const queries = [
    `CREATE TABLE IF NOT EXISTS users (
      id INT AUTO_INCREMENT PRIMARY KEY,
      email VARCHAR(255) UNIQUE NOT NULL,
      username VARCHAR(100) UNIQUE,
      password VARCHAR(255) NOT NULL,
      role ENUM('pelamar', 'perusahaan') DEFAULT 'pelamar',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );`,

    `CREATE TABLE IF NOT EXISTS pelamar (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id INT NOT NULL,
      first_name VARCHAR(100) NOT NULL,
      last_name VARCHAR(100) NOT NULL,
      email VARCHAR(255) NOT NULL,
      username VARCHAR(100),
      about_me TEXT,
      profile_pict VARCHAR(255),
      cv_path VARCHAR(255),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );`,


    `CREATE TABLE IF NOT EXISTS perusahaan (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id INT NOT NULL,
      nama_perusahaan VARCHAR(255) NOT NULL,
      email VARCHAR(255) NOT NULL,
      alamat TEXT,
      deskripsi TEXT,
      profile_pict VARCHAR(255),
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );`,

    `CREATE TABLE IF NOT EXISTS jobs (
      id INT AUTO_INCREMENT PRIMARY KEY,
      id_perusahaan INT NOT NULL,
      posisi VARCHAR(255) NOT NULL,
      lokasi VARCHAR(255) NOT NULL,
      job_details TEXT,
      requirements TEXT,
      status VARCHAR(50) DEFAULT 'active',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (id_perusahaan) REFERENCES perusahaan(id) ON DELETE CASCADE
    );`,

    `CREATE TABLE IF NOT EXISTS saved_jobs (
      id INT AUTO_INCREMENT PRIMARY KEY,
      id_postingan INT NOT NULL,
      id_pelamar INT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (id_postingan) REFERENCES jobs(id) ON DELETE CASCADE,
      FOREIGN KEY (id_pelamar) REFERENCES pelamar(id) ON DELETE CASCADE
    );`,

    `CREATE TABLE IF NOT EXISTS applications (
      id INT AUTO_INCREMENT PRIMARY KEY,
      id_postingan INT NOT NULL,
      id_pelamar INT NOT NULL,
      status VARCHAR(50) DEFAULT 'pending',
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (id_postingan) REFERENCES jobs(id) ON DELETE CASCADE,
      FOREIGN KEY (id_pelamar) REFERENCES pelamar(id) ON DELETE CASCADE
    );`,

    `CREATE TABLE IF NOT EXISTS pengaduan (
      id INT AUTO_INCREMENT PRIMARY KEY,
      id_user INT NOT NULL,
      judul VARCHAR(255) NOT NULL,
      isi TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (id_user) REFERENCES users(id) ON DELETE CASCADE
    );`
  ];

  for (const q of queries) {
    await pool.query(q);
  }

  // Auto-migration jika tabel sudah ada sebelumnya
  try {
    const [colsUsers] = await pool.query("SHOW COLUMNS FROM users LIKE 'username'");
    if (colsUsers.length === 0) {
      await pool.query("ALTER TABLE users ADD COLUMN username VARCHAR(100) UNIQUE NULL AFTER email");
      console.log('✅ Kolom username berhasil ditambahkan ke tabel users');
    }
  } catch (err) {
    console.error('Migration error users username:', err.message);
  }

  try {
    const [colsPelamar] = await pool.query("SHOW COLUMNS FROM pelamar LIKE 'username'");
    if (colsPelamar.length === 0) {
      await pool.query("ALTER TABLE pelamar ADD COLUMN username VARCHAR(100) NULL AFTER email");
      console.log('✅ Kolom username berhasil ditambahkan ke tabel pelamar');
    }
  } catch (err) {
    console.error('Migration error pelamar username:', err.message);
  }

  console.log('✅ Semua tabel MySQL siap digunakan.');
}


module.exports = {
  initDB,
  getPool: () => pool,
};
