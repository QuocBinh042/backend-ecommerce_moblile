const express = require("express");
const router = express.Router();
const { sql } = require("../db");

// Lấy toàn bộ lịch sử tìm kiếm của người dùng
router.get("/user/:userId", async (req, res) => {
    const { userId } = req.params;
    try {
        const { recordset } = await sql.query`
            SELECT Query FROM SearchHistory WHERE UserID = ${userId} ORDER BY SearchID DESC
        `;
        res.json({ success: true, history: recordset });
    } catch (err) {
        res.status(500).json({ success: false, message: "Error fetching search history.", error: err.message });
    }
});

// Lưu một truy vấn tìm kiếm mới
router.post("/", async (req, res) => {
    const { userId, query } = req.body;
    try {
        await sql.query`
            INSERT INTO SearchHistory (UserID, Query) VALUES (${userId}, ${query})
        `;
        res.json({ success: true, message: "Search history saved successfully." });
    } catch (err) {
        res.status(500).json({ success: false, message: "Error saving search history.", error: err.message });
    }
});

// Xóa toàn bộ lịch sử tìm kiếm
router.delete("/user/:userId", async (req, res) => {
    const { userId } = req.params;
    try {
        await sql.query`
            DELETE FROM SearchHistory WHERE UserID = ${userId}
        `;
        res.json({ success: true, message: "Search history cleared successfully." });
    } catch (err) {
        res.status(500).json({ success: false, message: "Error clearing search history.", error: err.message });
    }
});

module.exports = router;
