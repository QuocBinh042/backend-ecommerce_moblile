const express = require("express");
const router = express.Router();
const { sql } = require("../db");

// Add a product to the cart
router.post("/add", async (req, res) => {
  const { userId, productId } = req.body;

  try {
    const productResult = await sql.query`SELECT Price FROM Products WHERE ProductID = ${productId}`;
    if (productResult.recordset.length === 0) {
      return res.status(400).json({ success: false, message: "Product not found" });
    }

    const productPrice = productResult.recordset[0].Price;

    // Get or create the cart for the user
    let cartResult = await sql.query`SELECT CartID FROM Cart WHERE UserID = ${userId}`;
    let cartId = cartResult.recordset[0]?.CartID;

    if (!cartId) {
      const newCartResult = await sql.query`
        INSERT INTO Cart (UserID)
        OUTPUT INSERTED.CartID
        VALUES (${userId})
      `;
      cartId = newCartResult.recordset[0].CartID;
    }

    // Check if the product is already in the cart
    const cartItemResult = await sql.query`
      SELECT Quantity 
      FROM CartItems 
      WHERE CartID = ${cartId} AND ProductID = ${productId}
    `;

    if (cartItemResult.recordset.length > 0) {
      // If the product is already in the cart, update the quantity
      const currentQuantity = cartItemResult.recordset[0].Quantity;
      await sql.query`
        UPDATE CartItems
        SET Quantity = ${currentQuantity + 1}
        WHERE CartID = ${cartId} AND ProductID = ${productId}
      `;
      res.json({ success: false, message: "Quantity updated for existing item" });
    } else {
      // Add the product to the cart with an initial quantity of 1
      await sql.query`
        INSERT INTO CartItems (CartID, ProductID, Quantity, Price)
        VALUES (${cartId}, ${productId}, 1, ${productPrice})
      `;
      res.json({ success: true, message: "Product added as new unique item" });
    }
  } catch (err) {
    console.error("Error adding product to cart:", err);
    res.status(500).json({ success: false, message: "Internal Server Error", error: err.message });
  }
});

// Get all cart items for a specific user
router.get("/:userId", async (req, res) => {
  const { userId } = req.params;

  try {
    const cartResult = await sql.query`SELECT CartID FROM Cart WHERE UserID = ${userId}`;
    if (cartResult.recordset.length === 0) {
      return res.json([]); // Return empty array if no cart exists
    }

    const cartId = cartResult.recordset[0].CartID;

    const result = await sql.query`
      SELECT ci.CartItemID, p.ProductID, p.ProductName, p.Description, p.Image, 
             ci.Quantity, ci.Price
      FROM CartItems ci
      JOIN Products p ON ci.ProductID = p.ProductID
      WHERE ci.CartID = ${cartId}
    `;
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({
      success: false,
      message: "Error fetching cart items",
      error: err.message,
    });
  }
});

// Update quantity of a product in the cart
router.patch("/update-quantity", async (req, res) => {
  const { userId, productId, quantity } = req.body;

  try {
    const cartResult = await sql.query`SELECT CartID FROM Cart WHERE UserID = ${userId}`;
    if (cartResult.recordset.length === 0) {
      return res.status(404).json({ success: false, message: "Cart not found" });
    }
    const cartId = cartResult.recordset[0].CartID;

    await sql.query`
      UPDATE CartItems 
      SET Quantity = ${quantity}
      WHERE CartID = ${cartId} AND ProductID = ${productId}
    `;

    res.json({ success: true, message: "Product quantity updated" });
  } catch (err) {
    res.status(500).json({
      success: false,
      message: "Error updating product quantity",
      error: err.message,
    });
  }
});

// Remove a product from the cart
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

// Get the count of unique items in the cart for a specific user
router.get("/:userId/count", async (req, res) => {
  const { userId } = req.params;

  try {
    const cartResult = await sql.query`SELECT CartID FROM Cart WHERE UserID = ${userId}`;
    if (cartResult.recordset.length === 0) {
      return res.json({ count: 0 }); // If no cart exists, return count as 0
    }

    const cartId = cartResult.recordset[0].CartID;

    const countResult = await sql.query`
      SELECT COUNT(*) AS count
      FROM CartItems
      WHERE CartID = ${cartId}
    `;
    
    res.json(countResult.recordset[0]); // Expected response: { count: <number> }
  } catch (err) {
    console.error("Error fetching cart item count:", err);
    res.status(500).json({
      success: false,
      message: "Error fetching cart item count",
      error: err.message,
    });
  }
});

module.exports = router;
