-- Library Management System Database
-- Create the database
CREATE DATABASE IF NOT EXISTS LibraryManagementSystem;
USE LibraryManagementSystem;

-- 1. Members table (One-to-Many with Loans)
CREATE TABLE IF NOT EXISTS Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    membership_date DATE NOT NULL,
    membership_type ENUM('Student', 'Faculty', 'Staff', 'Public') NOT NULL,
    membership_status ENUM('Active', 'Suspended', 'Expired') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Authors table (Many-to-Many with Books through Book_Authors)
CREATE TABLE IF NOT EXISTS Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_year YEAR,
    death_year YEAR,
    nationality VARCHAR(50),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Publishers table (One-to-Many with Books)
CREATE TABLE IF NOT EXISTS Publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) UNIQUE NOT NULL,
    contact_email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    website VARCHAR(200),
    established_year YEAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Categories table (One-to-Many with Books)
CREATE TABLE IF NOT EXISTS Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES Categories(category_id) ON DELETE SET NULL
);

-- 5. Books table (Central entity with multiple relationships)
CREATE TABLE IF NOT EXISTS Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    edition VARCHAR(20),
    publication_year YEAR,
    publisher_id INT NOT NULL,
    category_id INT NOT NULL,
    language VARCHAR(30) DEFAULT 'English',
    page_count INT,
    description TEXT,
    cover_image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id) ON DELETE RESTRICT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE RESTRICT
);

-- 6. Book_Authors junction table (Many-to-Many relationship)
CREATE TABLE IF NOT EXISTS Book_Authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT NOT NULL DEFAULT 1,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE
);

-- 7. Book_Copies table (One-to-Many with Books, One-to-Many with Loans)
CREATE TABLE IF NOT EXISTS Book_Copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    barcode VARCHAR(50) UNIQUE NOT NULL,
    acquisition_date DATE NOT NULL,
    purchase_price DECIMAL(10,2),
    current_condition ENUM('New', 'Good', 'Fair', 'Poor', 'Damaged') DEFAULT 'Good',
    location VARCHAR(100),
    copy_status ENUM('Available', 'Checked Out', 'Reserved', 'Under Repair', 'Lost') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE
);

-- 8. Loans table (Many-to-One with Members and Book_Copies)
CREATE TABLE IF NOT EXISTS Loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    checkout_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    renewal_count INT DEFAULT 0,
    late_fee DECIMAL(8,2) DEFAULT 0.00,
    loan_status ENUM('Active', 'Returned', 'Overdue', 'Lost') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (copy_id) REFERENCES Book_Copies(copy_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE RESTRICT
);

-- 9. Reservations table (Many-to-One with Members and Books)
CREATE TABLE IF NOT EXISTS Reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    reservation_status ENUM('Active', 'Fulfilled', 'Cancelled', 'Expired') DEFAULT 'Active',
    priority INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE
);

-- 10. Fines table (One-to-One with Loans)
CREATE TABLE IF NOT EXISTS Fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL UNIQUE,
    member_id INT NOT NULL,
    fine_amount DECIMAL(8,2) NOT NULL,
    fine_reason ENUM('Late Return', 'Damaged Item', 'Lost Item') NOT NULL,
    fine_date DATE NOT NULL,
    paid_date DATE NULL,
    fine_status ENUM('Outstanding', 'Paid', 'Waived') DEFAULT 'Outstanding',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES Loans(loan_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE
);

-- 11. Staff table (for library employees)
CREATE TABLE IF NOT EXISTS Staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    staff_status ENUM('Active', 'Inactive', 'On Leave') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 12. Audit_Log table (for tracking important operations)
CREATE TABLE IF NOT EXISTS Audit_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    action_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    old_values JSON,
    new_values JSON,
    changed_by INT NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (changed_by) REFERENCES Staff(staff_id) ON DELETE RESTRICT
);

-- Create indexes for better performance
CREATE INDEX idx_members_email ON Members(email);
CREATE INDEX idx_members_status ON Members(membership_status);
CREATE INDEX idx_books_title ON Books(title);
CREATE INDEX idx_books_isbn ON Books(isbn);
CREATE INDEX idx_books_publisher ON Books(publisher_id);
CREATE INDEX idx_books_category ON Books(category_id);
CREATE INDEX idx_copies_status ON Book_Copies(copy_status);
CREATE INDEX idx_copies_book ON Book_Copies(book_id);
CREATE INDEX idx_loans_member ON Loans(member_id);
CREATE INDEX idx_loans_copy ON Loans(copy_id);
CREATE INDEX idx_loans_due_date ON Loans(due_date);
CREATE INDEX idx_loans_status ON Loans(loan_status);
CREATE INDEX idx_reservations_book ON Reservations(book_id);
CREATE INDEX idx_reservations_member ON Reservations(member_id);
CREATE INDEX idx_fines_member ON Fines(member_id);
CREATE INDEX idx_fines_status ON Fines(fine_status);

-- Display confirmation message
SELECT 'Library Management System database created successfully!' AS Message;