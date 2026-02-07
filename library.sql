-- library_system_clean.sql
-- Clean Library Management System

-- Create and use database
DROP DATABASE IF EXISTS library_db;
CREATE DATABASE library_db;
USE library_db;

-- Create students table
CREATE TABLE students (
    student_id VARCHAR(10) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    enrollment_date DATE NOT NULL,
    status VARCHAR(10) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create books table
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    year INT,
    publisher VARCHAR(100),
    copies_available INT DEFAULT 1,
    total_copies INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create borrowings table
CREATE TABLE borrowings (
    borrowing_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id VARCHAR(10) NOT NULL,
    book_id INT NOT NULL,
    borrowed_date DATE NOT NULL,
    due_date DATE NOT NULL,
    returned_date DATE,
    fine DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'BORROWED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Create audit log table
CREATE TABLE audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50),
    action VARCHAR(10),
    record_id VARCHAR(50),
    old_data TEXT,
    new_data TEXT,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes for performance
CREATE INDEX idx_student_status ON students(status);
CREATE INDEX idx_borrow_due_date ON borrowings(due_date);
CREATE INDEX idx_book_title ON books(title);

-- Insert sample students
INSERT INTO students (student_id, first_name, last_name, email, phone, enrollment_date, status) VALUES
('S001', 'Ricard', 'Downham', 'ricardd@university.edu', '(437) 864-1416', '2024-10-20', 'ACTIVE'),
('S002', 'Baird', 'Fetterplace', 'bairdf@university.edu', '(172) 663-5222', '2022-01-01', 'INACTIVE'),
('S003', 'Calli', 'D''Avaux', 'callid@university.edu', '(477) 187-6851', '2022-08-17', 'INACTIVE'),
('S004', 'Valle', 'Malone', 'vallem@university.edu', '(141) 725-6669', '2022-11-04', 'ACTIVE'),
('S005', 'Joly', 'Feaveryear', 'jolyf@university.edu', '(675) 594-8565', '2023-01-17', 'ACTIVE');

-- Insert sample books
INSERT INTO books (isbn, title, author, year, publisher) VALUES
('0195153448', 'Classical Mythology', 'Mark P. O. Morford', 2002, 'Oxford University Press'),
('0002005018', 'Clara Callan', 'Richard Bruce Wright', 2001, 'HarperFlamingo Canada'),
('0060973129', 'Decision in Normandy', 'Carlo D''Este', 1991, 'HarperPerennial'),
('0374157065', 'Flu: The Story of the Great Influenza Pandemic of 1918', 'Gina Bari Kolata', 1999, 'Farrar Straus Giroux'),
('0393045218', 'The Mummies of Urumchi', 'E. J. W. Barber', 1999, 'W. W. Norton & Company');

-- Update total copies
UPDATE books SET total_copies = copies_available;

-- Show data summary
SELECT 'Data Summary:' AS '';
SELECT 'Students:', COUNT(*) FROM students;
SELECT 'Books:', COUNT(*) FROM books;

-- Create borrow procedure
DELIMITER $$
CREATE PROCEDURE borrow_book(
    IN student_id VARCHAR(10),
    IN book_id INT,
    IN days INT
)
BEGIN
    IF (SELECT copies_available FROM books WHERE book_id = book_id) > 0 THEN
        INSERT INTO borrowings (student_id, book_id, borrowed_date, due_date)
        VALUES (student_id, book_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL days DAY));
        
        UPDATE books SET copies_available = copies_available - 1 WHERE book_id = book_id;
        SELECT CONCAT('Book borrowed. ID:', LAST_INSERT_ID()) AS message;
    ELSE
        SELECT 'Book not available' AS message;
    END IF;
END$$

-- Create return procedure
CREATE PROCEDURE return_book(IN borrow_id INT)
BEGIN
    DECLARE book_id INT;
    DECLARE due_date DATE;
    
    SELECT book_id, due_date INTO book_id, due_date 
    FROM borrowings WHERE borrowing_id = borrow_id;
    
    UPDATE borrowings 
    SET returned_date = CURDATE(), 
        status = 'RETURNED',
        fine = GREATEST(0, DATEDIFF(CURDATE(), due_date)) * 5
    WHERE borrowing_id = borrow_id;
    
    UPDATE books SET copies_available = copies_available + 1 WHERE book_id = book_id;
    SELECT 'Book returned' AS message;
END$$

-- Create audit trigger
CREATE TRIGGER audit_students AFTER UPDATE ON students
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO audit_log (table_name, action, record_id, old_data, new_data)
        VALUES ('students', 'UPDATE', OLD.student_id, OLD.status, NEW.status);
    END IF;
END$$

-- Create daily update procedure
CREATE PROCEDURE daily_update()
BEGIN
    UPDATE borrowings 
    SET status = 'OVERDUE'
    WHERE returned_date IS NULL AND due_date < CURDATE() AND status = 'BORROWED';
    
    UPDATE borrowings SET fine = fine + 10 WHERE status = 'OVERDUE' AND returned_date IS NULL;
    SELECT CONCAT('Updated ', ROW_COUNT(), ' records') AS message;
END$$

-- Create check inactive procedure
CREATE PROCEDURE check_inactive()
BEGIN
    UPDATE students s
    LEFT JOIN borrowings b ON s.student_id = b.student_id
    SET s.status = 'INACTIVE'
    WHERE s.status = 'ACTIVE' 
      AND (b.borrowed_date IS NULL OR b.borrowed_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH));
    SELECT CONCAT(ROW_COUNT(), ' students marked inactive') AS message;
END$$
DELIMITER ;

-- Test system
SELECT 'Testing System:' AS '';
CALL borrow_book('S001', 1, 7);
CALL return_book(1);
CALL daily_update();
CALL check_inactive();

-- Generate reports
SELECT 'Reports:' AS '';

SELECT '1. Student Status:' AS '';
SELECT status, COUNT(*) FROM students GROUP BY status;

SELECT '2. Book Availability:' AS '';
SELECT 'Available:', SUM(copies_available) FROM books
UNION
SELECT 'Borrowed:', COUNT(*) FROM borrowings WHERE returned_date IS NULL;

SELECT '3. Borrowing History:' AS '';
SELECT b.borrowing_id, s.first_name, s.last_name, bk.title, b.borrowed_date, b.returned_date, b.fine
FROM borrowings b
JOIN students s ON b.student_id = s.student_id
JOIN books bk ON b.book_id = bk.book_id;

SELECT '4. Overdue Books:' AS '';
SELECT b.borrowing_id, s.first_name, bk.title, b.due_date, b.fine
FROM borrowings b
JOIN students s ON b.student_id = s.student_id
JOIN books bk ON b.book_id = bk.book_id
WHERE b.status = 'OVERDUE' AND b.returned_date IS NULL;

-- Final status
SELECT 'Final Status:' AS '';
SELECT 'Students:', COUNT(*) FROM students;
SELECT 'Books:', COUNT(*) FROM books;
SELECT 'Transactions:', COUNT(*) FROM borrowings;
SELECT 'Library System Ready!' AS '';