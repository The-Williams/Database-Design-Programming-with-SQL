-- library_schema.sql
-- Library Management System schema
-- Run on MySQL 8.x

DROP DATABASE IF EXISTS library_db;
CREATE DATABASE library_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE library_db;

-- Table: authors
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_authors_lastname ON authors(last_name);

-- Table: publishers
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    website VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: categories
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Table: books
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE,
    title VARCHAR(255) NOT NULL,
    publisher_id INT,
    year_published YEAR,
    pages INT,
    copies_total INT NOT NULL DEFAULT 1,
    copies_available INT NOT NULL DEFAULT 1,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_books_publisher FOREIGN KEY (publisher_id)
      REFERENCES publishers(publisher_id) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE INDEX idx_books_title ON books(title);

-- Many-to-Many: books <-> authors
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    role VARCHAR(100) DEFAULT 'Author',
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_ba_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_ba_author FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Many-to-Many: books <-> categories
CREATE TABLE book_categories (
    book_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (book_id, category_id),
    CONSTRAINT fk_bc_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_bc_category FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

-- Table: members (library users)
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    address TEXT,
    joined_date DATE DEFAULT (CURRENT_DATE),
    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_members_email ON members(email);

-- Table: loans (borrowing records)
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    returned_date DATE,
    status ENUM('on_loan','overdue','returned') NOT NULL DEFAULT 'on_loan',
    fine_amount DECIMAL(8,2) DEFAULT 0.00,
    CONSTRAINT fk_loans_book FOREIGN KEY (book_id) REFERENCES books(book_id),
    CONSTRAINT fk_loans_member FOREIGN KEY (member_id) REFERENCES members(member_id),
    CONSTRAINT chk_due_after_loan CHECK (due_date >= loan_date)
);

CREATE INDEX idx_loans_book ON loans(book_id);
CREATE INDEX idx_loans_member ON loans(member_id);
CREATE INDEX idx_loans_status ON loans(status);

-- Table: staff (admin users)
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('librarian','admin') DEFAULT 'librarian',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Example triggers to maintain copies_available
DROP TRIGGER IF EXISTS trg_after_loan_insert;
DELIMITER $$
CREATE TRIGGER trg_after_loan_insert
AFTER INSERT ON loans
FOR EACH ROW
BEGIN
  UPDATE books SET copies_available = copies_available - 1 WHERE book_id = NEW.book_id;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS trg_after_loan_return;
DELIMITER $$
CREATE TRIGGER trg_after_loan_return
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN
  IF NEW.status = 'returned' AND OLD.status <> 'returned' THEN
    UPDATE books SET copies_available = copies_available + 1 WHERE book_id = NEW.book_id;
  END IF;
END$$
DELIMITER ;

-- Sample data
INSERT INTO publishers (name, website) VALUES
('O\'Reilly Media','https://www.oreilly.com'),
('Penguin Random House','https://www.penguinrandomhouse.com');

INSERT INTO authors (first_name, last_name) VALUES
('Jane','Austen'),
('George','Orwell');

INSERT INTO categories (name) VALUES ('Fiction'), ('Classic'), ('Science');

INSERT INTO books (isbn, title, publisher_id, year_published, pages, copies_total, copies_available)
VALUES ('9780141439518','Pride and Prejudice',2,1813,279,3,3),
       ('9780451524935','1984',2,1949,328,2,2);

INSERT INTO book_authors (book_id, author_id) VALUES (1,1),(2,2);
INSERT INTO book_categories (book_id, category_id) VALUES (1,2),(1,1),(2,1);

INSERT INTO members (first_name, last_name, email) VALUES ('Alice','Mwangi','alice@example.com'),('Bob','Kamau','bob@example.com');

-- End of schema
