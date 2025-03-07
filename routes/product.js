const express = require("express");
const router = express.Router();
const { sql } = require("../db");

// Lấy tất cả sản phẩm
router.get("/all", async (req, res) => {
  try {
    const result = await sql.query`SELECT * FROM Products`;
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Error fetching products: " + err.message);
  }
});

// Lấy sản phẩm theo CategoryID
router.get("/", async (req, res) => {
  const categoryId = Number(req.query.categoryId); // Sử dụng chữ thường "categoryId"

  if (isNaN(categoryId) || categoryId <= 0) {
    return res.status(400).send("Invalid CategoryID");
  }

  try {
    const result = await sql.query`SELECT * FROM Products WHERE CategoryID = ${categoryId}`;
    res.json(result.recordset);
  } catch (err) {
    res.status(500).send("Error fetching products by category: " + err.message);
  }
});



// Thêm sản phẩm mới
router.post("/", async (req, res) => {
  const { productName, description, price, stock, categoryID } = req.body;
  try {
    await sql.query`
      INSERT INTO Products (ProductName, Description, Price, Stock, CategoryID)
      VALUES (${productName}, ${description}, ${price}, ${stock}, ${categoryID})
    `;
    res.status(201).send("Product created successfully");
  } catch (err) {
    res.status(500).send("Error creating product: " + err.message);
  }
});

// Cập nhật sản phẩm
router.patch("/:id", async (req, res) => {
  const { id } = req.params;
  const { productName, description, price, stock, categoryID } = req.body;
  try {
    await sql.query`
      UPDATE Products
      SET ProductName = ${productName},
          Description = ${description},
          Price = ${price},
          Stock = ${stock},
          CategoryID = ${categoryID}
      WHERE ProductID = ${id}
    `;
    res.send("Product updated successfully");
  } catch (err) {
    res.status(500).send("Error updating product: " + err.message);
  }
});

// Xóa sản phẩm
router.delete("/:id", async (req, res) => {
  const { id } = req.params;
  try {
    await sql.query`DELETE FROM Products WHERE ProductID = ${id}`;
    res.send("Product deleted successfully");
  } catch (err) {
    res.status(500).send("Error deleting product: " + err.message);
  }
});

module.exports = router;
