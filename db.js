// db.js
const sql = require("mssql");

// Cấu hình kết nối đến SQL Server
const dbConfig = {
  user: 'sa',
  password: 'sapassword',
  server: 'localhost',
  database: 'emarket',
  port: 1433,
  options: {
    encrypt: true,
    trustServerCertificate: true
  }
};

// Hàm kết nối cơ sở dữ liệu
async function connectDB() {
  try {
    await sql.connect(dbConfig);
    console.log("Connected to SQL Server successfully");
  } catch (err) {
    console.error("Database connection failed:", err);
  }
}

// Export đối tượng `sql` và hàm `connectDB`
module.exports = { sql, connectDB };
