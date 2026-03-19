USE source_shop;

INSERT INTO customers (customer_id, first_name, last_name, email, phone, created_at) VALUES
(1, 'Alice', 'Brown', 'alice.brown@example.com', '+39-100000001', '2026-03-01 09:00:00'),
(2, 'Marco', 'Rossi', 'marco.rossi@example.com', '+39-100000002', '2026-03-02 10:15:00'),
(3, 'Julia', 'White', 'julia.white@example.com', '+39-100000003', '2026-03-03 11:20:00'),
(4, 'Luca', 'Verdi', 'luca.verdi@example.com', '+39-100000004', '2026-03-04 14:30:00');

INSERT INTO categories (category_id, category_name) VALUES
(1, 'Electronics'),
(2, 'Accessories'),
(3, 'Home');

INSERT INTO products (product_id, category_id, product_name, sku, unit_price, is_active, created_at) VALUES
(1, 1, 'Wireless Mouse', 'ELEC-MOUSE-01', 29.99, 1, '2026-03-01 08:00:00'),
(2, 1, 'Mechanical Keyboard', 'ELEC-KEYB-01', 89.99, 1, '2026-03-01 08:10:00'),
(3, 2, 'USB-C Cable', 'ACC-CABL-01', 9.99, 1, '2026-03-01 08:20:00'),
(4, 3, 'Desk Lamp', 'HOME-LAMP-01', 39.99, 1, '2026-03-01 08:30:00'),
(5, 2, 'Laptop Stand', 'ACC-STND-01', 49.99, 1, '2026-03-01 08:40:00');

INSERT INTO customers_addresses (address_id, customer_id, address_line1, city, state_region, postal_code, country, is_default) VALUES
(1, 1, 'Via Roma 10', 'Milan', 'MI', '20100', 'Italy', 1),
(2, 2, 'Corso Torino 25', 'Turin', 'TO', '10100', 'Italy', 1),
(3, 3, 'Via Dante 18', 'Florence', 'FI', '50100', 'Italy', 1),
(4, 4, 'Piazza Duomo 5', 'Naples', 'NA', '80100', 'Italy', 1);

INSERT INTO orders (order_id, customer_id, order_date, order_status) VALUES
(1, 1, '2026-03-15 10:35:00', 'completed'),
(2, 2, '2026-03-15 14:15:00', 'pending'),
(3, 3, '2026-03-16 09:25:00', 'completed'),
(4, 1, '2026-03-16 16:50:00', 'refunded'),
(5, 4, '2026-03-17 11:05:00', 'completed'),
(6, 2, '2026-03-17 13:45:00', 'completed');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price, line_total) VALUES
(1, 1, 1, 2, 29.99, 59.98),
(2, 1, 3, 4, 9.99, 39.96),
(3, 2, 1, 1, 29.99, 29.99),
(4, 3, 2, 2, 89.99, 179.98),
(5, 3, 3, 4, 9.99, 39.96),
(6, 4, 3, 1, 9.99, 9.99),
(7, 5, 5, 1, 49.99, 49.99),
(8, 5, 3, 2, 9.99, 19.98),
(9, 6, 4, 1, 39.99, 39.99);

INSERT INTO payments (payment_id, order_id, payment_date, payment_method, payment_status, amount) VALUES
(1, 1, '2026-03-15 10:35:00', 'credit_card', 'paid', 99.94),
(2, 2, '2026-03-15 14:15:00', 'paypal', 'waiting', 29.99),
(3, 3, '2026-03-16 09:25:00', 'credit_card', 'paid', 219.94),
(4, 4, '2026-03-16 16:50:00', 'credit_card', 'refunded', 9.99),
(5, 5, '2026-03-17 11:05:00', 'debit_card', 'paid', 69.97),
(6, 6, '2026-03-17 13:45:00', 'paypal', 'paid', 39.99);
