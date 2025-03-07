const express = require("express");
const cors = require("cors");
const { connectDB } = require("./db");
const productRoutes = require("./routes/product");
const categoryRoutes = require("./routes/category");
const userRoutes = require("./routes/user")
const cartRoutes = require("./routes/cart")
const orderRoutes = require('./routes/order')
const invoiceRoutes = require('./routes/invoice')
const addressRoutes = require("./routes/address")
const app = express();
const path = require("path");
const searchHistoryRoutes = require("./routes/searchHistory");
const wishlistRoutes = require("./routes/wishlist");

const PORT = 3002;

// Middleware
app.use(cors());
app.use(express.json());

// Kết nối đến cơ sở dữ liệu
connectDB();

// Sử dụng route cho sản phẩm và danh mục
app.use("/user", userRoutes)
app.use("/products", productRoutes);
app.use("/categories", categoryRoutes);
app.use("/cart", cartRoutes)
app.use("/invoices", invoiceRoutes);
app.use("/orders", orderRoutes);
app.use("/address", addressRoutes);
app.use("/searchHistory", searchHistoryRoutes);
app.use("/wishlist", wishlistRoutes);
app.use("/images", express.static(path.join(__dirname, "public/images")));


// Khởi động server
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
