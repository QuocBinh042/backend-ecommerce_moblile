const express = require("express");
const router = express.Router();
const { sql } = require("../db");

// Lấy danh sách danh mục
router.get("/", async (req, res) => {
  try {
    const result = await sql.query`SELECT * FROM Categories`;
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Error fetching categories: " + err.message);
  }
});

// Thêm danh mục mới
router.post("/", async (req, res) => {
  const { categoryName } = req.body;
  try {
    await sql.query`
      INSERT INTO Categories (CategoryName)
      VALUES (${categoryName})
    `;
    res.status(201).send("Category created successfully");
  } catch (err) {
    res.status(500).send("Error creating category: " + err.message);
  }
});


module.exports = router;
