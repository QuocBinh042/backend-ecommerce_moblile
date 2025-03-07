const express = require("express");
const router = express.Router();
const { sql } = require("../db");
const bcrypt = require("bcrypt");
const multer = require("multer");
const fs = require("fs");
const path = require("path");
const saltRounds = 10;

// Function to hash passwords
const hashPassword = (password) => bcrypt.hash(password, saltRounds);

// Fetch all users
router.get("/users", async (req, res) => {
  try {
    const { recordset } = await sql.query`SELECT * FROM Users`;
    res.json(recordset);
  } catch (err) {
    res.status(500).json({
      success: false,
      message: "Error fetching users",
      error: err.message,
    });
  }
});

// User login
router.post("/login", async (req, res) => {
  const { username, password } = req.body;
  try {
    const user = await sql.query`SELECT * FROM Users WHERE Username = ${username}`;
    if (!user.recordset.length) {
      return res.status(400).json({ success: false, message: "User not found" });
    }

    const storedPassword = user.recordset[0].PasswordHash;
    const isMatch =
      storedPassword.startsWith("$2b$") || storedPassword.startsWith("$2a$")
        ? await bcrypt.compare(password, storedPassword)
        : password === storedPassword;

    if (!isMatch) {
      return res.status(400).json({ success: false, message: "Invalid password" });
    }

    res.json({
      success: true,
      message: "Login successful",
      user: {
        userId: user.recordset[0].UserID,
        username: user.recordset[0].Username,
        phoneNumber: user.recordset[0].PhoneNumber,
        fullName: user.recordset[0].FullName,
        email: user.recordset[0].Email,
        avatar: user.recordset[0].Avatar,
      },
    });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: "Error logging in",
      error: err.message,
    });
  }
});


// Create a new user
router.post("/users", async (req, res) => {
  const { username, email, password, phoneNumber } = req.body;
  try {
    const hashedPassword = await hashPassword(password);
    await sql.query`
      INSERT INTO Users (Username, Email, PasswordHash, Phone)
      VALUES (${username}, ${email}, ${hashedPassword}, ${phoneNumber})
    `;
    res.status(201).json({ success: true, message: "User created successfully" });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: "Error creating user",
      error: err.message,
    });
  }
});


// Cấu hình Multer để lưu ảnh vào thư mục avatars
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadPath = path.join(__dirname, "../public/images/avatars");
    // Tạo thư mục nếu chưa tồn tại
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    cb(null, uploadPath); // Thư mục lưu ảnh
  },
  filename: (req, file, cb) => {
    const uniqueName = `${Date.now()}-${file.originalname}`;
    cb(null, uniqueName); // Đặt tên file: timestamp + tên gốc
  },
});

const upload = multer({ storage }); // Khởi tạo Multer

router.post("/:userId/avatar", upload.single("avatar"), async (req, res) => {
  try {
      const userId = req.params.userId;

      if (!req.file) {
          return res.status(400).json({
              success: false,
              message: "No file uploaded.",
          });
      }

      const fileName = req.file.filename; // Tên file vừa được lưu
      // const relativePath = `avatars/${fileName}`; // Đường dẫn tương đối

      // Lưu tên file vào database
      await sql.query`UPDATE Users SET Avatar = ${fileName} WHERE UserID = ${userId}`;

      res.json({
          success: true,
          message: "Avatar uploaded successfully.",
          avatar: fileName,
      });
  } catch (error) {
      console.error("Error uploading avatar:", error.message);
      res.status(500).json({
          success: false,
          message: "Error uploading avatar.",
      });
  }
});


// Update user
router.patch("/users/:id", async (req, res) => {
  const { id } = req.params;
  const { email, phoneNumber, username, avatar } = req.body; 

  try {
    // Kiểm tra nếu các trường cần thiết không tồn tại
    if (!email || !phoneNumber || !username) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields: email, phoneNumber, or username.",
      });
    }

    await sql.query`
      UPDATE Users
      SET 
        Email = ${email},
        PhoneNumber = ${phoneNumber},
        Username = ${username},
        Avatar = ${avatar || null} -- Nếu avatar không có, đặt null
      WHERE UserID = ${id}
    `;
    res.json({ success: true, message: "User updated successfully" });
  } catch (err) {
    console.error("Error updating user:", err.message);
    res.status(500).json({
      success: false,
      message: "Error updating user",
      error: err.message,
    });
  }
});



// Delete user
router.delete("/users/:id", async (req, res) => {
  const { id } = req.params;
  try {
    await sql.query`DELETE FROM Users WHERE UserID = ${id}`;
    res.json({ success: true, message: "User deleted successfully" });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: "Error deleting user",
      error: err.message,
    });
  }
});



module.exports = router;
