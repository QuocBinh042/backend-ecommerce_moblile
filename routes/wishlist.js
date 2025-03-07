const express = require("express");
const router = express.Router();
const { sql } = require("../db");

// Lấy tất cả Wishlist của người dùng
router.get("/:userId", async (req, res) => {
  const { userId } = req.params;
  try {
    const result = await sql.query`
      SELECT w.WishlistID, w.ProductID, p.ProductName, p.Price, p.Image 
      FROM Wishlists w
      JOIN Products p ON w.ProductID = p.ProductID
      WHERE w.UserID = ${userId}
    `;
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Error fetching wishlist: " + err.message);
  }
});

router.post("/", async (req, res) => {
  const { userId, productId } = req.body;

  // Kiểm tra đầu vào
  if (!userId || !productId) {
    return res.status(400).json({ error: "User ID and Product ID are required" });
  }

  try {
    // Kiểm tra xem sản phẩm đã có trong wishlist chưa
    const checkExist = await sql.query`
      SELECT * FROM Wishlists WHERE UserID = ${userId} AND ProductID = ${productId}
    `;

    if (checkExist.recordset.length > 0) {
      // Sản phẩm đã tồn tại, không thêm mới, trả về thông báo như đã thêm
      return res.status(200).json({ message: "Product added to wishlist successfully" });
    }

    // Nếu chưa tồn tại, thêm vào wishlist
    await sql.query`
      INSERT INTO Wishlists (UserID, ProductID)
      VALUES (${userId}, ${productId})
    `;

    // Trả về phản hồi JSON
    res.status(201).json({ message: "Product added to wishlist successfully" });
  } catch (err) {
    // Xử lý lỗi khác
    res.status(500).json({ error: "Error adding product to wishlist", details: err.message });
  }
});



router.delete("/:id", async (req, res) => {
  const { id } = req.params;

  if (!id || isNaN(id)) {
    return res.status(400).json({ message: "Invalid or missing wishlist ID" });
  }

  try {
    const result = await sql.query`
      DELETE FROM Wishlists
      WHERE WishlistID = ${id}
    `;
    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ message: "Wishlist item not found" });
    }
    res.json({ message: "Product removed from wishlist successfully" }); // JSON phản hồi
  } catch (err) {
    res.status(500).json({ message: "Error removing product from wishlist", error: err.message });
  }
});


module.exports = router;
