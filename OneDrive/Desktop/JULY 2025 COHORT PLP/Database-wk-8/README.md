# Library Management System (MySQL Schema)

## Overview
This project implements a **relational database schema** for a Library Management System using **MySQL**.  
It models real-world entities such as **Books, Authors, Publishers, Members, and Loans**, with appropriate relationships and constraints.

This submission is for **Week 8 Final Project – Question 1: Build a Complete Database Management System**.


## Features of the Schema
- **Entities & Tables:**
  - `authors` – stores author details
  - `publishers` – stores publisher info
  - `categories` – book genres/classifications
  - `books` – library books
  - `book_authors` – many-to-many relationship (books ↔ authors)
  - `book_categories` – many-to-many relationship (books ↔ categories)
  - `members` – registered library users
  - `loans` – borrowing records
  - `staff` – library administrators

- **Constraints & Integrity Rules:**
  - `PRIMARY KEY` for unique identifiers
  - `FOREIGN KEY` relationships with cascading rules
  - `UNIQUE` constraints for fields like ISBN and emails
  - `NOT NULL` enforced where required
  - `CHECK` constraints (e.g., loan due date ≥ loan date)

- **Relationships:**
  - One-to-Many: `publishers → books`, `members → loans`
  - Many-to-Many: `books ↔ authors`, `books ↔ categories`
  - One-to-One/Optional: each loan corresponds to one member and one book

- **Triggers:**
  - Auto-update `copies_available` when books are borrowed or returned


## Deliverables
- `library_schema.sql` – contains:
  - `CREATE DATABASE` statement
  - `CREATE TABLE` statements
  - Relationships & constraints
  - Optional triggers
  - Sample data inserts


## Setup Instructions

### 1. Clone the repository
```bash
git clone <your-repo-link>
cd <repo-folder>
2. Open MySQL and run the schema
bash
Copy code
mysql -u root -p < library_schema.sql
3. Verify database creation
sql
Copy code
SHOW DATABASES;
USE library_db;
SHOW TABLES;

Example Queries
Get all books with authors:

sql
Copy code
SELECT b.title, CONCAT(a.first_name, ' ', a.last_name) AS author
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id;
Get overdue loans:

sql
Copy code
SELECT l.loan_id, m.first_name, m.last_name, b.title, l.due_date
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
WHERE l.status = 'overdue';

🧑‍💻 Author
The-Williams
Week 8 Final Project – PLP Cohort (July 2025)