// src/routes/orders.js
const express = require("express");
const router = express.Router();
const { sql } = require("../db");

router.post("/", async (req, res) => {
  const { userId, itemIds } = req.body;

  console.log("Request body:", req.body); // Log để kiểm tra dữ liệu nhận được

  if (!userId || !Array.isArray(itemIds) || itemIds.length === 0) {
    return res.status(400).json({ error: "Invalid order data" });
  }

  const transaction = new sql.Transaction();

  try {
    await transaction.begin();

    const { recordset } = await transaction.request()
      .input("userId", sql.Int, userId)
      .query("INSERT INTO Orders (UserID, Status) OUTPUT INSERTED.OrderID VALUES (@userId, 'Pending')");
    
    const orderId = recordset[0].OrderID;
    console.log("Order ID created:", orderId); // Log để xác nhận Order ID được tạo

    for (const { productId, quantity, price } of itemIds) {
      if (!productId || !quantity || price == null) { // Kiểm tra kỹ `price`
        throw new Error("Invalid item data");
      }

      await transaction.request()
        .input("orderId", sql.Int, orderId)
        .input("productId", sql.Int, productId)
        .input("quantity", sql.Int, quantity)
        .input("price", sql.Decimal(10, 2), price)
        .query("INSERT INTO OrderItems (OrderID, ProductID, Quantity, Price) VALUES (@orderId, @productId, @quantity, @price)");
    }

    await transaction.commit();
    res.status(201).json({ orderId, message: "Order created successfully" });
  } catch (error) {
    await transaction.rollback();
    console.error("Error creating order:", error); // Log để kiểm tra lỗi
    res.status(500).json({ error: "Failed to create order" });
  }
});


// Xóa sản phẩm khỏi giỏ hàng
router.delete("/remove", async (req, res) => {
  const { userId, productId } = req.query;

  try {
    const cartResult = await sql.query`SELECT CartID FROM Cart WHERE UserID = ${userId}`;
    if (cartResult.recordset.length === 0) {
      return res.status(404).json({ success: false, message: "Cart not found" });
    }
    const cartId = cartResult.recordset[0].CartID;

    await sql.query`DELETE FROM CartItems WHERE CartID = ${cartId} AND ProductID = ${productId}`;
    res.json({ success: true, message: "Product removed from cart" });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: "Error removing product from cart",
      error: err.message,
    });
  }
});
module.exports = router;
