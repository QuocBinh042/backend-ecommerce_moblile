const express = require("express");
const router = express.Router();
const { sql } = require("../db");

router.post("/create", async (req, res) => {
  const { orderId, totalAmount } = req.body;

  try {
    const result = await sql.query`
      INSERT INTO Invoices (OrderID, TotalAmount, Status)
      OUTPUT INSERTED.InvoiceID, INSERTED.InvoiceDate, INSERTED.TotalAmount, INSERTED.Status
      VALUES (${orderId}, ${totalAmount}, 'Unpaid')
    `;

    res.json(result.recordset[0]); 
  } catch (error) {
    console.error("Error creating invoice:", error);
    res.status(500).json({ success: false, message: "Error creating invoice", error: error.message });
  }
});

module.exports = router;
