# 🚗 Garage Management System (SQL)

## 📌 Overview
The **Garage Management System** is a relational database project designed to streamline operations in an automobile garage.  
It covers customer management, vehicles, specialists, workers, service requests, billing, and reporting using SQL concepts like **joins, views, triggers, procedures, and cursors**.

This project demonstrates **Database Design, Normalization (1NF, 2NF, 3NF), Advanced SQL Queries, Stored Procedures, Triggers, and Views**.

---

## 🗂️ Features
- **Garage Owner Management** – store owner details.
- **Customer & Vehicle Records** – track customer info, vehicles, and service history.
- **Specialists & Workers** – assign expertise and link workers to specialists.
- **Service Requests** – record vehicle services with cost, type, and status.
- **Billing System** – generate bills with multiple payment methods.
- **Advanced SQL Features**:
  - **Triggers** (auto-update service date, prevent duplicate service, log deleted workers).
  - **Stored Procedures** (fetch vehicle service history, loop through vehicles with cursors).
  - **Views** (customer info, vehicle owners, high-value services, revenue insights).
  - **Subqueries & Joins** (aggregate analysis, dependency checks).
- **Normalization** – schema follows **1NF, 2NF, 3NF**.

---

## 🛠️ Tech Stack
- **Database**: MySQL
- **Concepts**: SQL Joins, Views, Triggers, Procedures, Cursors, Normalization

---

## 📊 Sample Queries
- **Aggregate**: Calculate total revenue, average cost, number of vehicles per customer.
- **Subqueries**: Find customers with high-value services (> ₹5000).
- **Joins**: Inner, Left, Right, and simulated Full Outer Joins.
- **Billing**: Auto-generate bills for completed services.

---

## 📌 Example Procedure
```sql
CALL GetVehicleServiceHistory('DL3CAP1234');
