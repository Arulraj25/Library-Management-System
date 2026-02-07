Library Management System
A complete Library Management System built with MySQL, Python, and CSV data processing. The system manages students, books, borrowing transactions, fines, and generates reports.

📁 Project Structure
text
LMSM/
├── clean_data.py           # Python script to clean CSV data
├── library_system_clean.sql # Main SQL file with database schema and procedures
├── students_cleaned.csv    # Cleaned student data
├── books_cleaned.csv       # Cleaned book data
├── students.csv           # Original student data
├── books.csv             # Original book data
└── README.md             # This file
🚀 Quick Start
1. Setup MySQL Database
bash
# Run the complete SQL setup
mysql -u root -p < library_system_clean.sql
Or run it step by step in MySQL:

sql
-- Login to MySQL
mysql -u root -p

-- Run the SQL file
SOURCE library_system_clean.sql;
2. Clean Your Data (If needed)
bash
# Run the Python data cleaner
python3 clean_data.py
This will create:

students_cleaned.csv (from students.csv)

books_cleaned.csv (from books.csv)

🗄️ Database Schema
Tables Created:
students - Stores student information

student_id (VARCHAR, Primary Key): Unique student ID (e.g., S001)

first_name, last_name, email, phone

enrollment_date, status (ACTIVE/INACTIVE)

created_at (auto-timestamp)

books - Stores book information

book_id (INT, Auto Increment, Primary Key)

isbn (VARCHAR, Unique): Book ISBN

title, author, year, publisher

copies_available, total_copies

created_at (auto-timestamp)

borrowings - Tracks book borrowing transactions

borrowing_id (INT, Auto Increment, Primary Key)

student_id, book_id (Foreign Keys)

borrowed_date, due_date, returned_date

fine (decimal), status (BORROWED/RETURNED/OVERDUE)

created_at (auto-timestamp)

audit_log - Logs all system changes

log_id (INT, Auto Increment, Primary Key)

table_name, action, record_id

old_data, new_data

changed_at (auto-timestamp)

⚙️ System Features
Core Functions:
📚 Borrow Books

sql
CALL borrow_book('S001', 1, 14);  -- Student S001 borrows book_id 1 for 14 days
📖 Return Books

sql
CALL return_book(1);  -- Return borrowing_id 1
💰 Automatic Fines

₹5 per day for late returns

Automatic overdue status updates

📊 Daily Updates

sql
CALL daily_update();  -- Mark overdue books and update fines
👥 Student Management

sql
CALL check_inactive();  -- Mark students inactive after 6 months of no activity
Reports Generated:
Student Status Report - Count of ACTIVE/INACTIVE students

Book Availability Report - Available vs borrowed books

Borrowing History - Complete transaction history

Overdue Books - List of overdue books with fines

📋 Sample Data
Students (10 records):
S001: Ricard Downham (ACTIVE)

S002: Baird Fetterplace (INACTIVE)

S003: Calli D'Avaux (INACTIVE)

... and 7 more

Books (10 records):
Classical Mythology by Mark P. O. Morford (2002)

Clara Callan by Richard Bruce Wright (2001)

Decision in Normandy by Carlo D'Este (1991)

... and 7 more

🔧 Technical Details
Indexes Created for Performance:
idx_student_status - Fast student status queries

idx_borrow_due_date - Fast overdue book detection

idx_book_title - Fast book search by title

Triggers:
audit_students - Automatically logs student status changes

Procedures:
borrow_book() - Handles book borrowing

return_book() - Handles book returns

daily_update() - Daily maintenance tasks

check_inactive() - Student activity check

🧪 Testing the System
sql
-- Test 1: Borrow a book
CALL borrow_book('S001', 1, 7);

-- Test 2: Return the book
CALL return_book(1);

-- Test 3: Run daily updates
CALL daily_update();

-- Test 4: Check inactive students
CALL check_inactive();

-- View reports
SELECT * FROM students;
SELECT * FROM books;
SELECT * FROM borrowings;
📊 Example Queries
sql
-- Find all active students
SELECT * FROM students WHERE status = 'ACTIVE';

-- Find available books
SELECT * FROM books WHERE copies_available > 0;

-- Check borrowing history for a student
SELECT b.borrowing_id, bk.title, b.borrowed_date, b.returned_date, b.fine
FROM borrowings b
JOIN books bk ON b.book_id = bk.book_id
WHERE b.student_id = 'S001';

-- Find overdue books
SELECT s.first_name, s.last_name, bk.title, b.due_date, b.fine
FROM borrowings b
JOIN students s ON b.student_id = s.student_id
JOIN books bk ON b.book_id = bk.book_id
WHERE b.status = 'OVERDUE' AND b.returned_date IS NULL;
🛠️ Troubleshooting
Common Issues:
MySQL Connection Issues:

bash
# Start MySQL service
sudo service mysql start

# Login
mysql -u root -p
Permission Issues:

bash
# Check file permissions
ls -la *.csv

# Fix permissions if needed
chmod 644 *.csv
Data Loading Issues:

Use the Python cleaner script instead of LOAD DATA

Ensure CSV files are in the same directory

Error Solutions:
"LOAD DATA LOCAL INFILE blocked": Use the Python script to load data

"Table already exists": Drop database and recreate

"Foreign key constraint fails": Insert students before books, books before borrowings

📈 System Requirements
MySQL: 8.0 or higher

Python: 3.6 or higher (for data cleaning)

Storage: Minimal (database < 10MB for sample data)

Memory: 256MB RAM minimum

🔄 Maintenance
Regular Tasks:
Run CALL daily_update(); daily (can be automated with cron)

Run CALL check_inactive(); monthly

Backup database regularly

Backup Database:
bash
# Backup
mysqldump -u root -p library_db > library_backup.sql

# Restore
mysql -u root -p library_db < library_backup.sql
📝 License
This project is for educational purposes. Feel free to modify and use as needed.

🤝 Contributing
Fork the repository

Create a feature branch

Commit your changes

Push to the branch

Create a Pull Request

📧 Support
For issues or questions:

Check the troubleshooting section

Review MySQL error logs

Contact the project maintainer

🎯 Status: System Ready | ✅ Last Tested: Successfully executed all procedures | 📊 Data: 10 students, 10 books loaded