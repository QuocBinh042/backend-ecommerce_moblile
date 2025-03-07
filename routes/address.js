const express = require("express");
const router = express.Router();
const { sql } = require("../db");

// Lấy danh sách địa chỉ theo UserID
router.get("/user/:userId", async (req, res) => {
    const { userId } = req.params;
    try {
        const { recordset } = await sql.query`
            SELECT * FROM Addresses WHERE UserID = ${userId}
        `;
        res.json({ success: true, addresses: recordset });
    } catch (err) {
        res.status(500).json({ success: false, message: "Error fetching addresses.", error: err.message });
    }
});

// Xóa địa chỉ theo AddressID
router.delete("/:addressId", async (req, res) => {
    const { addressId } = req.params;
    try {
        await sql.query`DELETE FROM Addresses WHERE AddressID = ${addressId}`;
        res.json({ success: true, message: "Address deleted successfully." });
    } catch (err) {
        res.status(500).json({ success: false, message: "Error deleting address.", error: err.message });
    }
});

router.post("/", async (req, res) => {
    try {
        console.log("Received request body:", req.body); // Log the incoming request data
        const { City, District, Street, Ward, userId } = req.body;

        // Validate the incoming data
        if (!City || !District || !Street || !Ward || !userId) {
            console.error("Missing required fields in request body.");
            return res.status(400).json({ success: false, message: "Missing required fields." });
        }

        console.log("Attempting to insert into database...");
        await sql.query`
            INSERT INTO Addresses (City, District, Street, Ward, UserID) 
            VALUES (${City}, ${District}, ${Street}, ${Ward}, ${userId})
        `;

        console.log("Insert successful.");
        res.json({ success: true, message: "Address added successfully." });
    } catch (err) {
        console.error("Error during insertion:", err.message); // Log the exact error message
        res.status(500).json({ success: false, message: "Error adding address.", error: err.message });
    }
});

router.patch("/:addressId", async (req, res) => {
    try {
        // Check if the address exists
        const { recordset } = await sql.query`
            SELECT * FROM Addresses WHERE AddressID = ${addressId}
        `;

        if (recordset.length === 0) {
            return res.status(404).json({ success: false, message: "Address not found." });
        }

        // Update the address
        await sql.query`
            UPDATE Addresses
            SET City = ${updatedAddress.City},
                District = ${updatedAddress.District},
                Ward = ${updatedAddress.Ward},
                Street = ${updatedAddress.Street}
            WHERE AddressID = ${addressId}
        `;

        res.json({ success: true, message: "Address updated successfully" });
    } catch (error) {
        console.error("Error updating address:", error.message);
        res.status(500).json({ success: false, message: "Failed to update address", error: error.message });
    }
});


  
module.exports = router;
