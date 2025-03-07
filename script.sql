CREATE DATABASE emarket
-- Create Users table with Avatar field
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(256) NOT NULL,
    PhoneNumber NVARCHAR(50) NOT NULL UNIQUE,
    Avatar NVARCHAR(255),
    FullName NVARCHAR(100),
    CreatedAt DATETIME DEFAULT GETDATE()
);


CREATE TABLE Addresses (
    AddressID INT PRIMARY KEY IDENTITY,
    City NVARCHAR(100) NOT NULL,
    District NVARCHAR(100) NOT NULL,
    Street NVARCHAR(255) NOT NULL,
    Ward NVARCHAR(100) NOT NULL,
    UserID INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- Create Categories table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY,
    CategoryName NVARCHAR(50) NOT NULL UNIQUE,
    ImageURL NVARCHAR(255) NOT NULL
);

-- Create Products table with DiscountedPrice field
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY,
    ProductName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(MAX),
    Price DECIMAL(10, 2) NOT NULL,
    DiscountedPrice DECIMAL(10, 2),
    Stock INT DEFAULT 0 CHECK (Stock >= 0),
    CategoryID INT,
    Rating INT,
    CreatedAt DATETIME DEFAULT GETDATE(),
    Image NVARCHAR(255),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID) ON DELETE SET NULL
);

-- Create Promotions table with date constraints
CREATE TABLE Promotions (
    PromotionID INT PRIMARY KEY IDENTITY,
    PromotionName NVARCHAR(100) NOT NULL,
    DiscountPercentage DECIMAL(5, 2) NOT NULL CHECK (DiscountPercentage BETWEEN 0 AND 100),
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NOT NULL,
    CHECK (EndDate > StartDate)
);

-- Create ProductPromotions table for linking products with promotions
CREATE TABLE ProductPromotions (
    ProductPromotionID INT PRIMARY KEY IDENTITY,
    ProductID INT NOT NULL,
    PromotionID INT NOT NULL,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    FOREIGN KEY (PromotionID) REFERENCES Promotions(PromotionID) ON DELETE CASCADE
);

-- Create Cart table
CREATE TABLE Cart (
    CartID INT PRIMARY KEY IDENTITY,
    UserID INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- Create CartItems table
CREATE TABLE CartItems (
    CartItemID INT PRIMARY KEY IDENTITY,
    CartID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (CartID) REFERENCES Cart(CartID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
);

-- Create Orders table with status constraint
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY,
    UserID INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Completed', 'Cancelled', 'Shipped')),
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- Create OrderItems table
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY IDENTITY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
);

-- Create Payments table
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY,
    OrderID INT NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    PaymentDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(50) NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE
);

-- Create Feedback table
CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY IDENTITY,
    ProductID INT NOT NULL,
    UserID INT NOT NULL,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);


-- Create Invoices table
CREATE TABLE Invoices (
    InvoiceID INT PRIMARY KEY IDENTITY,
    OrderID INT NOT NULL,
    InvoiceDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10, 2) NOT NULL,
    Status NVARCHAR(50) NOT NULL DEFAULT 'Unpaid' CHECK (Status IN ('Paid', 'Unpaid', 'Refunded')),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE
);

-- Tạo bảng SearchHistory không có cột SearchedAt
CREATE TABLE SearchHistory (
    SearchID INT PRIMARY KEY IDENTITY,
    UserID INT NOT NULL, -- ID của người dùng thực hiện tìm kiếm
    Query NVARCHAR(255) NOT NULL, -- Nội dung tìm kiếm
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

CREATE TABLE Wishlists (
    WishlistID INT PRIMARY KEY IDENTITY,
    UserID INT NOT NULL,
    ProductID INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
); 

GO
CREATE TRIGGER trg_CalculateDiscountedPrice
ON ProductPromotions
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Products
    SET DiscountedPrice = Price - (Price * (SELECT DiscountPercentage / 100.0 FROM Promotions WHERE PromotionID = (SELECT PromotionID FROM inserted)))
    WHERE ProductID IN (SELECT ProductID FROM inserted);
END;
GO-- Insert Users 
-- Insert Users
INSERT INTO Users (Username, Email, PhoneNumber, PasswordHash, Avatar, FullName) 
VALUES 
    ('alice_wonder', 'alice@example.com', '1234567890', '$2a$10$mc8TNjfxl/kgSefVmxsaOusd6qyw4EBgUnWZO4VMkjYx2DyCgluhK', 'avatar1.png', 'Alice Wonder'),
    ('bob_builder', 'bob@example.com', '2345678901', '$2a$10$mc8TNjfxl/kgSefVmxsaOusd6qyw4EBgUnWZO4VMkjYx2DyCgluhK', 'avatar2.png', 'Bob Builder'),
    ('charlie_doe', 'charlie@example.com', '3456789012', '$2a$10$mc8TNjfxl/kgSefVmxsaOusd6qyw4EBgUnWZO4VMkjYx2DyCgluhK', 'avatar3.png', 'Charlie Doe'),
    ('daisy_flower', 'daisy@example.com', '4567890123', '$2a$10$mc8TNjfxl/kgSefVmxsaOusd6qyw4EBgUnWZO4VMkjYx2DyCgluhK', 'avatar4.png', 'Daisy Flower'),
    ('eve_long', 'eve@example.com', '5678901234', '$2a$10$mc8TNjfxl/kgSefVmxsaOusd6qyw4EBgUnWZO4VMkjYx2DyCgluhK', 'avatar5.png', 'Eve Long'),
    ('frank_knight', 'frank@example.com', '6789012345', '$2a$10$mc8TNjfxl/kgSefVmxsaOusd6qyw4EBgUnWZO4VMkjYx2DyCgluhK', 'avatar6.png', 'Frank Knight'),
    ('grace_hopper', 'grace@example.com', '7890123456', '$2a$10$mc8TNjfxl/kgSefVmxsaOusd6qyw4EBgUnWZO4VMkjYx2DyCgluhK', 'avatar7.png', 'Grace Hopper'),
    ('hank_pym', 'hank@example.com', '8901234567', '$2a$10$mc8TNjfxl/kgSefVmxsaOusd6qyw4EBgUnWZO4VMkjYx2DyCgluhK', 'avatar8.png', 'Hank Pym'),
    ('kingsley', 'kingsley@gmail.com', '9012345678', '$2a$10$mc8TNjfxl/kgSefVmxsaOusd6qyw4EBgUnWZO4VMkjYx2DyCgluhK', 'avatar9.png', 'Kingsley Shacklebolt'),
    ('jane', 'jane@gmail.com', '0123456789', '$2a$10$mc8TNjfxl/kgSefVmxsaOusd6qyw4EBgUnWZO4VMkjYx2DyCgluhK', 'avatar10.png', 'Jane Doe');



-- Insert example addresses for users
INSERT INTO Addresses (City, District, Street, Ward, UserID)
VALUES
    ('Hanoi', 'Ba Dinh', '123 Hoang Hoa Tham', 'Phuc Xa', 1),
    ('Hanoi', 'Dong Da', '456 Thai Ha', 'Lang Ha', 1),
    ('Ho Chi Minh City', 'District 1', '789 Nguyen Hue', 'Ben Nghe', 2),
    ('Ho Chi Minh City', 'District 3', '101 Le Van Sy', 'Ward 7', 3),
    ('Da Nang', 'Hai Chau', '202 Tran Phu', 'Thach Thang', 4),
    ('Hanoi', 'Cau Giay', '303 Xuan Thuy', 'Dich Vong Hau', 5),
    ('Hanoi', 'Hai Ba Trung', '404 Minh Khai', 'Vinh Tuy', 6),
    ('Hue', 'Phu Hoi', '505 Tran Hung Dao', 'Ward 1', 7),
    ('Can Tho', 'Ninh Kieu', '606 Vo Van Kiet', 'An Hoa', 8),
    ('Hanoi', 'Thanh Xuan', '707 Nguyen Trai', 'Thanh Xuan Nam', 9);


-- Insert Categories
INSERT INTO Categories (CategoryName, ImageURL) 
VALUES 
    ('Electronics', 'Electronics.png'),
    ('Fashion', 'Fashion.png'),
    ('Beauty', 'Beauty.png'),
    ('Fresh Fruits', 'FreshFruit.png');

INSERT INTO Products (ProductName, Description, Price, Stock, CategoryID, Image, Rating) 
VALUES 
    -- Electronics Category
    ('Smartphone', 'High-performance smartphone', 799.99, 25, 1, 'smartphone.png', 5),
    ('Tablet', 'Multi-functional tablet', 499.99, 40, 1, 'tablet.png', 4),
    ('Camera', 'High-resolution digital camera', 299.99, 35, 1, 'camera.png', 4),
    ('Laptop', 'High-end gaming laptop', 1099.99, 15, 1, 'laptop.png', 5),
    ('Smartwatch', 'Smartwatch with fitness tracking', 199.99, 50, 1, 'smartwatch.png', 3),
    ('Headphones', 'Noise-canceling headphones', 149.99, 60, 1, 'headphones.png', 4),
    ('Bluetooth Speaker', 'Portable Bluetooth speaker', 89.99, 45, 1, 'speaker.png', 4),
    ('Monitor', '4K Ultra HD monitor', 249.99, 20, 1, 'monitor.png', 5),
    ('Printer', 'Wireless color printer', 129.99, 30, 1, 'printer.png', 3),
    ('Router', 'High-speed Wi-Fi router', 59.99, 70, 1, 'router.png', 4),

    -- Fashion Category
    ('Jacket', 'Warm winter jacket', 99.99, 20, 2, 'jacket.png', 4),
    ('Jeans', 'Classic blue jeans', 49.99, 100, 2, 'jeans.png', 5),
    ('Sunglasses', 'UV-protection sunglasses', 19.99, 150, 2, 'sunglasses.png', 4),
    ('T-shirt', '100% cotton T-shirt', 9.99, 200, 2, 'tshirt.png', 3),
    ('Shoes', 'Comfortable walking shoes', 79.99, 120, 2, 'shoes.png', 5),
    ('Backpack', 'Durable travel backpack', 59.99, 75, 2, 'backpack.png', 4),
    ('Hat', 'Sun hat with wide brim', 15.99, 50, 2, 'hat.png', 3),
    ('Belt', 'Leather belt', 19.99, 100, 2, 'belt.png', 4),
    ('Gloves', 'Winter gloves', 14.99, 80, 2, 'gloves.png', 4),
    ('Dress', 'Elegant evening dress', 49.99, 30, 2, 'dress.png', 5),

    -- Beauty Category
    ('Perfume', 'Long-lasting perfume', 59.99, 45, 3, 'perfume.png', 5),
    ('Lipstick', 'Smooth and long-lasting lipstick', 19.99, 100, 3, 'lipstick.png', 4),
    ('Foundation', 'High-coverage foundation', 29.99, 60, 3, 'foundation.png', 3),
    ('Mascara', 'Waterproof mascara', 15.99, 90, 3, 'mascara.png', 4),
    ('Eyeshadow Palette', 'Multi-color eyeshadow palette', 24.99, 70, 3, 'eyeshadow.png', 5),
    ('Nail Polish', 'Glossy nail polish', 4.99, 200, 3, 'nailpolish.png', 4),
    ('Hair Dryer', 'Powerful hair dryer', 39.99, 40, 3, 'hairdryer.png', 3),
    ('Shampoo', 'Moisturizing shampoo', 9.99, 150, 3, 'shampoo.png', 4),
    ('Conditioner', 'Silky smooth conditioner', 9.99, 150, 3, 'conditioner.png', 4),
    ('Face Mask', 'Refreshing face mask', 5.99, 100, 3, 'facemask.png', 3),

    -- Fresh Fruits Category
    ('Pear', 'Fresh juicy pear', 3.00, 150, 4, 'pear.png', 5),
    ('Avocado', 'Ripe avocado for salads', 4.00, 120, 4, 'avocado.png', 4),
    ('Cherry', 'Sweet cherries', 10.00, 90, 4, 'cherry.png', 5),
    ('Orange', 'Juicy fresh orange', 7.00, 180, 4, 'orange.png', 4),
    ('Peach', 'Sweet and ripe peach', 15.00, 70, 4, 'peach.png', 3),
    ('Pomegranate', 'Juicy pomegranate', 23.00, 60, 4, 'pomegranate.png', 4),
    ('Apples', 'Fresh organic apples', 2.99, 200, 4, 'apples.png', 5),
    ('Bananas', 'Ripe yellow bananas', 1.99, 300, 4, 'bananas.png', 4),
    ('Oranges', 'Juicy fresh oranges', 3.49, 150, 4, 'oranges.png', 4),
    ('Strawberries', 'Sweet strawberries', 4.99, 120, 4, 'strawberries.png', 5),
    ('Blueberries', 'Fresh blueberries', 5.99, 100, 4, 'blueberries.png', 4),
    ('Grapes', 'Seedless grapes', 3.99, 130, 4, 'grapes.png', 5),
    ('Mangoes', 'Tropical mangoes', 2.49, 180, 4, 'mangoes.png', 4),
    ('Watermelon', 'Juicy watermelon', 6.99, 70, 4, 'watermelon.png', 4),
    ('Pineapple', 'Fresh pineapple', 2.99, 110, 4, 'pineapple.png', 4),
    ('Papaya', 'Ripe papaya', 3.49, 90, 4, 'papaya.png', 3);

-- Insert Carts for selected Users
INSERT INTO Cart (UserID) 
VALUES 
    (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);

-- Insert CartItems
INSERT INTO CartItems (CartID, ProductID, Quantity, Price)
VALUES 
    (1, 1, 1, 799.99), 
    (1, 2, 2, 499.99), 
    (1, 3, 1, 299.99), 
    (2, 4, 1, 199.99),
    (2, 5, 1, 149.99),
    (3, 6, 2, 249.99), 
    (3, 7, 3, 59.99),
    (4, 8, 1, 999.99), 
    (5, 9, 4, 129.99), 
    (6, 10, 2, 49.99),
    (7, 11, 3, 99.99),
    (8, 12, 1, 89.99),
    (9, 13, 1, 159.99),
    (10, 14, 5, 9.99);

-- Insert Orders for selected Users
INSERT INTO Orders (UserID, Status) 
VALUES 
    (1, 'Completed'), 
    (2, 'Pending'), 
    (3, 'Cancelled'), 
    (4, 'Shipped'), 
    (5, 'Completed'),
    (6, 'Pending'),
    (7, 'Shipped'),
    (8, 'Completed'),
    (9, 'Pending'),
    (10, 'Cancelled');

-- Insert OrderItems linked to Orders
INSERT INTO OrderItems (OrderID, ProductID, Quantity, Price)
VALUES 
    (1, 1, 1, 799.99), 
    (1, 2, 1, 499.99), 
    (2, 3, 2, 299.99), 
    (3, 4, 1, 199.99), 
    (4, 5, 2, 149.99),
    (5, 6, 1, 249.99),
    (6, 7, 3, 59.99),
    (7, 8, 1, 999.99),
    (8, 9, 4, 129.99),
    (9, 10, 2, 49.99),
    (10, 11, 3, 99.99),
    (10, 12, 1, 89.99);

-- Insert Payments for Orders
INSERT INTO Payments (OrderID, PaymentMethod, Amount, Status)
VALUES 
    (1, 'Credit Card', 1299.99, 'Completed'),
    (2, 'PayPal', 599.98, 'Pending'),
    (3, 'Bank Transfer', 199.99, 'Cancelled'),
    (4, 'Credit Card', 299.98, 'Completed'),
    (5, 'Cash', 249.99, 'Completed'),
    (6, 'PayPal', 179.97, 'Pending'),
    (7, 'Credit Card', 999.99, 'Completed'),
    (8, 'Bank Transfer', 519.96, 'Completed'),
    (9, 'Cash', 99.98, 'Pending'),
    (10, 'PayPal', 89.99, 'Cancelled');

-- Insert Feedback
INSERT INTO Feedback (ProductID, UserID, Rating, Comment)
VALUES 
    (1, 1, 5, 'Excellent quality!'), 
    (2, 2, 4, 'Good value.'), 
    (3, 3, 3, 'Okay quality.'), 
    (4, 4, 5, 'Very comfortable.'),
    (5, 5, 4, 'Worth the price.'),
    (6, 6, 5, 'Superb product!'),
    (7, 7, 2, 'Not as expected.'),
    (8, 8, 4, 'Good performance.'),
    (9, 9, 5, 'Highly recommended!'),
    (10, 10, 3, 'Average quality.');

-- Insert sample invoices (for existing orders)
INSERT INTO Invoices (OrderID, TotalAmount, Status) 
VALUES 
    (1, 1299.99, 'Paid'),
    (2, 599.98, 'Unpaid'),
    (3, 199.99, 'Refunded'),
    (4, 299.98, 'Paid'),
    (5, 249.99, 'Paid'),
    (6, 179.97, 'Unpaid'),
    (7, 999.99, 'Paid'),
    (8, 519.96, 'Paid'),
    (9, 99.98, 'Unpaid'),
    (10, 89.99, 'Refunded'),
    (11, 129.99, 'Paid'),
    (12, 199.99, 'Paid'),
    (13, 399.99, 'Unpaid'),
    (14, 109.99, 'Refunded'),
    (15, 229.99, 'Paid'),
    (16, 289.99, 'Paid'),
    (17, 189.99, 'Unpaid'),
    (18, 329.99, 'Paid'),
    (19, 459.99, 'Paid'),
    (20, 119.99, 'Refunded');

INSERT INTO SearchHistory (UserID, Query) VALUES (1, 'smartphone sale');
INSERT INTO SearchHistory (UserID, Query) VALUES (2, 'cheap headphones');
INSERT INTO SearchHistory (UserID, Query) VALUES (3, 'gaming laptops 2024');
INSERT INTO SearchHistory (UserID, Query) VALUES (4, 'best monitors');
INSERT INTO SearchHistory (UserID, Query) VALUES (5, 'wireless printers');
INSERT INTO SearchHistory (UserID, Query) VALUES (6, 'fashion jackets');
INSERT INTO SearchHistory (UserID, Query) VALUES (7, 'summer shoes');
INSERT INTO SearchHistory (UserID, Query) VALUES (8, 'UV sunglasses');
INSERT INTO SearchHistory (UserID, Query) VALUES (9, 'perfume discounts');
INSERT INTO SearchHistory (UserID, Query) VALUES (10, 'fruit delivery');
INSERT INTO SearchHistory (UserID, Query) VALUES (1, 'smartwatches for kids');
INSERT INTO SearchHistory (UserID, Query) VALUES (2, 'tablets for students');
INSERT INTO SearchHistory (UserID, Query) VALUES (3, 'wireless routers');
INSERT INTO SearchHistory (UserID, Query) VALUES (4, 'high-resolution cameras');
INSERT INTO SearchHistory (UserID, Query) VALUES (5, 'gaming accessories');
INSERT INTO SearchHistory (UserID, Query) VALUES (6, 'leather belts');
INSERT INTO SearchHistory (UserID, Query) VALUES (7, 'winter gloves sale');
INSERT INTO SearchHistory (UserID, Query) VALUES (8, 'elegant evening dresses');
INSERT INTO SearchHistory (UserID, Query) VALUES (9, 'organic fruits online');
INSERT INTO SearchHistory (UserID, Query) VALUES (10, 'watermelon suppliers');


INSERT INTO Wishlists (UserID, ProductID) VALUES (1, 2);
INSERT INTO Wishlists (UserID, ProductID) VALUES (1, 5);
INSERT INTO Wishlists (UserID, ProductID) VALUES (1, 8);
INSERT INTO Wishlists (UserID, ProductID) VALUES (2, 3);
INSERT INTO Wishlists (UserID, ProductID) VALUES (2, 6);
INSERT INTO Wishlists (UserID, ProductID) VALUES (2, 9);
INSERT INTO Wishlists (UserID, ProductID) VALUES (3, 1);
INSERT INTO Wishlists (UserID, ProductID) VALUES (3, 4);
INSERT INTO Wishlists (UserID, ProductID) VALUES (3, 7);
INSERT INTO Wishlists (UserID, ProductID) VALUES (4, 2);
INSERT INTO Wishlists (UserID, ProductID) VALUES (4, 5);
INSERT INTO Wishlists (UserID, ProductID) VALUES (4, 8);
INSERT INTO Wishlists (UserID, ProductID) VALUES (5, 1);
INSERT INTO Wishlists (UserID, ProductID) VALUES (5, 3);
INSERT INTO Wishlists (UserID, ProductID) VALUES (5, 7);
INSERT INTO Wishlists (UserID, ProductID) VALUES (1, 10);
INSERT INTO Wishlists (UserID, ProductID) VALUES (2, 4);
INSERT INTO Wishlists (UserID, ProductID) VALUES (3, 6);
INSERT INTO Wishlists (UserID, ProductID) VALUES (4, 9);
INSERT INTO Wishlists (UserID, ProductID) VALUES (5, 8);


-- 1. Tạm thời vô hiệu hóa ràng buộc khóa ngoại
ALTER TABLE OrderItems NOCHECK CONSTRAINT ALL;
ALTER TABLE Payments NOCHECK CONSTRAINT ALL;
ALTER TABLE Feedback NOCHECK CONSTRAINT ALL;
ALTER TABLE Orders NOCHECK CONSTRAINT ALL;
ALTER TABLE Products NOCHECK CONSTRAINT ALL;

-- 2. Xóa dữ liệu theo thứ tự ngược lại
DELETE FROM OrderItems;
DELETE FROM Payments;
DELETE FROM Feedback;
DELETE FROM Orders;
DELETE FROM Products;
DELETE FROM Categories;
DELETE FROM Users;

-- 3. Kích hoạt lại ràng buộc khóa ngoại
ALTER TABLE OrderItems CHECK CONSTRAINT ALL;
ALTER TABLE Payments CHECK CONSTRAINT ALL;
ALTER TABLE Feedback CHECK CONSTRAINT ALL;
ALTER TABLE Orders CHECK CONSTRAINT ALL;
ALTER TABLE Products CHECK CONSTRAINT ALL;

UPDATE Categories
SET ImageURL = CASE 
    WHEN CategoryID = 1 THEN 'Electronics.png'
    WHEN CategoryID = 2 THEN 'Fashion.png'
    WHEN CategoryID = 3 THEN 'Beauty.png'
    WHEN CategoryID = 4 THEN 'FreshFruit.png'
    ELSE ImageURL
END;


