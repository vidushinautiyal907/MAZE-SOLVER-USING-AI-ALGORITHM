create database project;
use project;
CREATE TABLE CUSTOMER (
    cust_id INT PRIMARY KEY AUTO_INCREMENT,
    cust_name VARCHAR(50),
    email VARCHAR(50),
    phone VARCHAR(15)
);
CREATE TABLE PRODUCT (
    prod_id INT PRIMARY KEY AUTO_INCREMENT,
    prod_name VARCHAR(50),
    price DECIMAL(10,2),
    stock INT
);
CREATE TABLE CART (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    cust_id INT,
    prod_id INT,
    qty INT,
    total DECIMAL(10,2),
    FOREIGN KEY (cust_id) REFERENCES CUSTOMER(cust_id),
    FOREIGN KEY (prod_id) REFERENCES PRODUCT(prod_id)
);
CREATE TABLE ORDERS (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    cust_id INT,
    order_date DATETIME,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (cust_id) REFERENCES CUSTOMER(cust_id)
);
INSERT INTO CUSTOMER (cust_name, email, phone)
VALUES ('Vidushi', 'vidushi@gmail.com', '9876543210');

INSERT INTO PRODUCT (prod_name, price, stock)
VALUES 
('Laptop', 55000, 10),
('Headphones', 2000, 25),
('Mouse', 800, 40);

DELIMITER $$

CREATE PROCEDURE add_to_cart(
    IN p_cust_id INT,
    IN p_prod_id INT,
    IN p_qty INT
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;
    DECLARE v_total DECIMAL(10,2);

    SELECT price, stock INTO v_price, v_stock FROM product WHERE prod_id = p_prod_id;

    IF v_stock < p_qty THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock!';
    ELSE
        SET v_total = v_price * p_qty;
        INSERT INTO cart (cust_id, prod_id, qty, total)
        VALUES (p_cust_id, p_prod_id, p_qty, v_total);
    END IF;
END$$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER trg_update_stock
AFTER INSERT ON CART
FOR EACH ROW
BEGIN
    UPDATE PRODUCT
    SET stock = stock - NEW.qty
    WHERE prod_id = NEW.prod_id;
END$$

DELIMITER ;
DELIMITER $$

CREATE FUNCTION calc_total(p_cust_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT SUM(total) INTO v_total FROM CART WHERE cust_id = p_cust_id;
    RETURN IFNULL(v_total, 0);
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE place_order(IN p_cust_id INT)
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SET v_total = calc_total(p_cust_id);

    INSERT INTO ORDERS (cust_id, order_date, total_amount)
    VALUES (p_cust_id, NOW(), v_total);

    DELETE FROM CART WHERE cust_id = p_cust_id;  -- empty the cart
END$$

DELIMITER ;

CALL add_to_cart(1, 1, 1);   -- Laptop
CALL add_to_cart(1, 2, 2);   -- 2 Headphones

-- View cart
SELECT * FROM CART;

-- Check total
SELECT calc_total(1) AS 'Total Amount';

-- Place order
CALL place_order(1);

-- Check Orders
SELECT * FROM ORDERS;

-- Verify updated product stock
SELECT * FROM PRODUCT;
