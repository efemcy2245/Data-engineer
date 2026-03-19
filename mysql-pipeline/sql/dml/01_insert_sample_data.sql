USE de_learning;

INSERT INTO customers (full_name, email, country, signup_date) VALUES
('Alice Rossi', 'alice@example.com', 'Italy', '2025-01-10'),
('Marco Bianchi', 'marco@example.com', 'Italy', '2025-01-15'),
('John Smith', 'john@example.com', 'UK', '2025-02-01'),
('Sofia Muller', 'sofia@example.com', 'Germany', '2025-02-10');

INSERT INTO products (product_name, category, unit_price) VALUES
('Mechanical Keyboard', 'Tech', 89.99),
('Wireless Mouse', 'Tech', 39.99),
('Office Chair', 'Furniture', 199.99),
('Notebook Pack', 'Stationery', 12.50),
('Desk Lamp', 'Furniture', 45.00);

INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2025-03-01 10:15:00', 'paid'),
(2, '2025-03-02 14:20:00', 'shipped'),
(1, '2025-03-05 09:00:00', 'paid'),
(3, '2025-03-06 16:40:00', 'cancelled'),
(4, '2025-03-08 11:30:00', 'paid');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 89.99),
(1, 2, 2, 39.99),
(2, 3, 1, 199.99),
(2, 4, 3, 12.50),
(3, 5, 2, 45.00),
(3, 2, 1, 39.99),
(4, 1, 1, 89.99),
(5, 3, 1, 199.99),
(5, 5, 1, 45.00);

INSERT INTO payments (order_id, payment_date, payment_method, amount) VALUES
(1, '2025-03-01 10:20:00', 'card', 169.97),
(2, '2025-03-02 14:25:00', 'paypal', 237.49),
(3, '2025-03-05 09:10:00', 'card', 129.99),
(5, '2025-03-08 11:35:00', 'bank_transfer', 244.99);
