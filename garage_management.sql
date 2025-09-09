-- Create Database
CREATE DATABASE GarageDB;
USE GarageDB;

-- Garage Owner Table
CREATE TABLE Garage_Owner (
    owner_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    contact VARCHAR(15),
    email VARCHAR(100) UNIQUE
);

-- Customer Table (Merged with Vehicle_Owner)
CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    contact VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    address TEXT
);

-- Vehicle Table
CREATE TABLE Vehicle (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    model VARCHAR(100),
    registration_number VARCHAR(20) UNIQUE,
    vehicle_type VARCHAR(50),
    last_service_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
);

-- Specialist Table
CREATE TABLE Specialist (
    specialist_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    expertise VARCHAR(100),
    contact VARCHAR(15)
);

-- Worker Table
CREATE TABLE Worker (
    worker_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    assigned_specialist_id INT,
    contact VARCHAR(15),
    FOREIGN KEY (assigned_specialist_id) REFERENCES Specialist(specialist_id) ON DELETE SET NULL
);

-- Service Request Table
CREATE TABLE Service_Request (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT,
    specialist_id INT,
    worker_id INT,
    service_type VARCHAR(100),
    cost DECIMAL(10,2),
    status ENUM('Pending', 'In Progress', 'Completed'),
    payment_status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    date DATE,
    FOREIGN KEY (vehicle_id) REFERENCES Vehicle(vehicle_id) ON DELETE CASCADE,
    FOREIGN KEY (specialist_id) REFERENCES Specialist(specialist_id) ON DELETE SET NULL,
    FOREIGN KEY (worker_id) REFERENCES Worker(worker_id) ON DELETE SET NULL
);

-- Insert sample Garage Owner
INSERT INTO Garage_Owner (name, contact, email) VALUES 
('Rajesh Sharma', '9876543210', 'rajesh.sharma@example.com');

-- Insert sample Customers
INSERT INTO Customer (name, contact, email, address) VALUES 
('Amit Verma', '9123456789', 'amit.verma@example.com', 'Sector 21, Gurugram, Haryana'),
('Pooja Iyer', '9898989898', 'pooja.iyer@example.com', 'Koramangala, Bengaluru, Karnataka');

-- Insert sample Vehicles
INSERT INTO Vehicle (customer_id, model, registration_number, vehicle_type, last_service_date) VALUES 
(1, 'Maruti Suzuki Swift', 'DL3CAP1234', 'Hatchback', '2025-03-10'),
(2, 'Hyundai Creta', 'KA01MK5678', 'SUV', '2025-02-20');

-- Insert sample Specialists
INSERT INTO Specialist (name, expertise, contact) VALUES 
('Sandeep Yadav', 'Engine Repair', '9000011122'),
('Manish Tiwari', 'Electrical Work', '9112233445');

-- Insert sample Workers
INSERT INTO Worker (name, assigned_specialist_id, contact) VALUES 
('Ravi Kumar', 1, '9223344556'),
('Anjali Mehta', 2, '9556677889');

-- Insert sample Service Requests
INSERT INTO Service_Request (vehicle_id, specialist_id, worker_id, service_type, cost, status, payment_status, date) VALUES 
(1, 1, 1, 'Clutch Overhaul', 8500.00, 'Pending', 'Pending', '2025-04-01'),
(2, 2, 2, 'Battery Replacement', 3200.00, 'In Progress', 'Completed', '2025-04-02');

 -- INSERT, UPDATE, DELETE Queries
 -- INSERT: Add a new customer
INSERT INTO Customer (name, contact, email, address) 
VALUES ('Neha Singh', '9871234560', 'neha.singh@example.com', 'Vashi, Navi Mumbai');

-- UPDATE: Change the status of a service
UPDATE Service_Request 
SET status = 'Completed', payment_status = 'Completed' 
WHERE service_id = 1;

-- DELETE: Remove a vehicle record
DELETE FROM Vehicle 
WHERE registration_number = 'DL3CAP1234';

-- Aggregate Functions
-- Total revenue from completed services
SELECT SUM(cost) AS total_revenue 
FROM Service_Request 
WHERE status = 'Completed';

-- Average service cost by status
SELECT status, AVG(cost) AS avg_cost 
FROM Service_Request 
GROUP BY status;

-- Number of vehicles per customer
SELECT customer_id, COUNT(*) AS total_vehicles 
FROM Vehicle 
GROUP BY customer_id;

-- Nested (Subqueries)
-- Get customers who own vehicles with service cost > ₹5000
SELECT name 
FROM Customer 
WHERE customer_id IN (
    SELECT v.customer_id 
    FROM Vehicle v
    JOIN Service_Request sr ON v.vehicle_id = sr.vehicle_id
    WHERE sr.cost > 5000
);

-- Get the model of the most expensive service
SELECT model 
FROM Vehicle 
WHERE vehicle_id = (
    SELECT vehicle_id 
    FROM Service_Request 
    ORDER BY cost DESC 
    LIMIT 1
);

-- JOIN Types
-- INNER JOIN: Vehicle info with their owners
SELECT v.model, v.registration_number, c.name AS owner_name
FROM Vehicle v
INNER JOIN Customer c ON v.customer_id = c.customer_id;

-- LEFT JOIN: List all workers with their assigned specialist info (if any)
SELECT w.name AS worker_name, s.name AS specialist_name, s.expertise
FROM Worker w
LEFT JOIN Specialist s ON w.assigned_specialist_id = s.specialist_id;

-- RIGHT JOIN: All specialists and any assigned workers (if any)
SELECT s.name AS specialist_name, w.name AS worker_name
FROM Specialist s
RIGHT JOIN Worker w ON s.specialist_id = w.assigned_specialist_id;

-- FULL OUTER JOIN simulation using UNION (MySQL doesn't directly support FULL OUTER JOIN)
SELECT c.name AS customer_name, v.model 
FROM Customer c 
LEFT JOIN Vehicle v ON c.customer_id = v.customer_id

UNION

SELECT c.name AS customer_name, v.model 
FROM Customer c 
RIGHT JOIN Vehicle v ON c.customer_id = v.customer_id;

-- NORMALIZATION--
-- 🔹 1NF: Ensure Atomicity (Already satisfied by schema)

-- Example: No multivalued attributes in Customer table
SELECT * FROM Customer;

-- 🔹 2NF: No partial dependency (already satisfied because there are no composite primary keys)
-- Just an example of dependency from Service_Request to Service_Type cost
SELECT service_type, AVG(cost) AS avg_cost
FROM Service_Request
GROUP BY service_type;

-- 🔹 3NF: Ensure no transitive dependency (each non-key depends only on the key)
-- Verify Specialist expertise depends only on specialist_id
SELECT specialist_id, name, expertise
FROM Specialist;

-- 🔹 Functional Dependency Check using GROUP BY
-- Each registration_number is unique → should return 1 row per registration_number
SELECT registration_number, COUNT(*) AS duplicate_count
FROM Vehicle
GROUP BY registration_number
HAVING COUNT(*) > 1;

-- 🔹 Query showing dependency of vehicle on customer (vehicle belongs to only one customer)
SELECT v.vehicle_id, v.model, c.name AS customer_name
FROM Vehicle v
JOIN Customer c ON v.customer_id = c.customer_id;

-- 🔹 Check: No transitive dependency in Service_Request (e.g., worker_id → specialist_id is not allowed)
-- So, Service_Request has direct specialist_id assigned instead of deriving from worker
SELECT sr.service_id, sr.worker_id, sr.specialist_id, w.assigned_specialist_id
FROM Service_Request sr
JOIN Worker w ON sr.worker_id = w.worker_id
WHERE sr.specialist_id <> w.assigned_specialist_id;


-- VIEWS--

CREATE VIEW View_Customer_Info AS
SELECT customer_id, name, contact, email
FROM Customer;

-- Example usage:
SELECT * FROM View_Customer_Info;

CREATE VIEW View_Vehicle_Owners AS
SELECT v.vehicle_id, v.model, v.registration_number, c.name AS owner_name, c.contact
FROM Vehicle v
JOIN Customer c ON v.customer_id = c.customer_id;

-- Example usage:
SELECT * FROM View_Vehicle_Owners;

CREATE VIEW View_Service_Revenue AS
SELECT status, SUM(cost) AS total_revenue
FROM Service_Request
GROUP BY status;

-- Example usage:
SELECT * FROM View_Service_Revenue;

-- First View: Completed and High-Value Services
CREATE VIEW View_Completed_HighValue_Services AS
SELECT sr.service_id, sr.vehicle_id, sr.cost
FROM Service_Request sr
WHERE sr.status = 'Completed' AND sr.cost > 5000;

-- Nested View: Join with Vehicle and Customer
CREATE VIEW View_HighValue_Service_Customers AS
SELECT chvs.service_id, chvs.cost, c.name AS customer_name, v.model
FROM View_Completed_HighValue_Services chvs
JOIN Vehicle v ON chvs.vehicle_id = v.vehicle_id
JOIN Customer c ON v.customer_id = c.customer_id;

-- Example usage:
SELECT * FROM View_HighValue_Service_Customers;
 

Procedure to Get Service History of a Vehicle by Registration Number
DELIMITER $$
CREATE PROCEDURE GetVehicleServiceHistory(IN reg_no VARCHAR(20))
BEGIN
    SELECT sr.service_id, sr.service_type, sr.cost, sr.status, sr.payment_status, sr.date 
    FROM Service_Request sr 
    JOIN Vehicle v ON sr.vehicle_id = v.vehicle_id 
    WHERE v.registration_number = reg_no;
END $$
DELIMITER ;

-- Example: Call Procedure
CALL GetVehicleServiceHistory('DL3CAP1234');

-- TRIGGERS
--  Trigger: Auto-update last_service_date when a new service is marked 'Completed'
DELIMITER $$

CREATE TRIGGER UpdateLastServiceDate
AFTER UPDATE ON Service_Request
FOR EACH ROW
BEGIN
    IF NEW.status = 'Completed' AND OLD.status <> 'Completed' THEN
        UPDATE Vehicle
        SET last_service_date = NEW.date
        WHERE vehicle_id = NEW.vehicle_id;
    END IF;
END $$

DELIMITER ;
--  Trigger: Log deleted workers into a separate table -- 
-- First, create the log table:
sql
Copy
Edit
CREATE TABLE Deleted_Worker_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    worker_id INT,
    name VARCHAR(100),
    contact VARCHAR(15),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
Then the trigger:

DELIMITER $$

CREATE TRIGGER LogDeletedWorker
BEFORE DELETE ON Worker
FOR EACH ROW
BEGIN
    INSERT INTO Deleted_Worker_Log (worker_id, name, contact)
    VALUES (OLD.worker_id, OLD.name, OLD.contact);
END //

DELIMITER ;
3. ✅ Trigger: Restrict adding a service request if the vehicle is already under "In Progress" service
sql
Copy
Edit
DELIMITER $$

CREATE TRIGGER PreventDuplicateService
BEFORE INSERT ON Service_Request
FOR EACH ROW
BEGIN
    DECLARE ongoing_count INT;

    SELECT COUNT(*) INTO ongoing_count
    FROM Service_Request
    WHERE vehicle_id = NEW.vehicle_id AND status = 'In Progress';

    IF ongoing_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This vehicle already has a service in progress.';
    END IF;
END $$

DELIMITER ;


-- CURSOR Example--
--Cursor: Loop through all vehicles and print the vehicle ID and last service date--
--(for demonstration or debug – can be adapted to insert into a summary table)-- 


DELIMITER $$

CREATE PROCEDURE PrintVehicleServiceDates()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id INT;
    DECLARE v_model VARCHAR(100);
    DECLARE v_service_date DATE;

    DECLARE vehicle_cursor CURSOR FOR
        SELECT vehicle_id, model, last_service_date FROM Vehicle;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN vehicle_cursor;

    read_loop: LOOP
        FETCH vehicle_cursor INTO v_id, v_model, v_service_date;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Just SELECTing in this example (or can insert into another table/log)
        SELECT CONCAT('Vehicle ID: ', v_id, ', Model: ', v_model, ', Last Service: ', v_service_date) AS vehicle_info;
    END LOOP;

    CLOSE vehicle_cursor;
END $$

DELIMITER ;

-- To run the cursor procedure:
CALL PrintVehicleServiceDates();
