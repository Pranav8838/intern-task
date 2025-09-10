-- Create a new database
CREATE DATABASE LibraryDB;
USE LibraryDB;

-- =========================
-- Step 1: Create Tables
-- =========================

-- Students Table
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Course VARCHAR(30),
    Year INT CHECK (Year BETWEEN 1 AND 4)
);

-- Authors Table
CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY,
    AuthorName VARCHAR(50) NOT NULL
);

-- Books Table
CREATE TABLE Books (
    BookID INT PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    AuthorID INT,
    Genre VARCHAR(30),
    CopiesAvailable INT CHECK (CopiesAvailable >= 0),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)
);

-- Borrow Table
CREATE TABLE Borrow (
    BorrowID INT PRIMARY KEY,
    StudentID INT,
    BookID INT,
    BorrowDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);

-- =========================
-- Step 2: Insert Mock Data
-- =========================

-- Insert Students
INSERT INTO Students VALUES
(1, 'Asha', 'Computer Science', 2),
(2, 'Rahul', 'Mechanical', 3),
(3, 'Meera', 'Electrical', 1),
(4, 'Karan', 'Computer Science', 4),
(5, 'Divya', 'Civil', 2);

-- Insert Authors
INSERT INTO Authors VALUES
(1, 'J.K. Rowling'),
(2, 'Dan Brown'),
(3, 'Chetan Bhagat'),
(4, 'APJ Abdul Kalam'),
(5, 'R.K. Narayan');

-- Insert Books
INSERT INTO Books VALUES
(101, 'Harry Potter', 1, 'Fantasy', 5),
(102, 'Angels and Demons', 2, 'Thriller', 3),
(103, 'Five Point Someone', 3, 'Fiction', 4),
(104, 'Wings of Fire', 4, 'Biography', 2),
(105, 'Malgudi Days', 5, 'Fiction', 6);

-- Insert Borrow Records
INSERT INTO Borrow VALUES
(1, 1, 101, '2025-09-01', NULL),
(2, 2, 103, '2025-09-03', '2025-09-08'),
(3, 3, 102, '2025-09-05', NULL),
(4, 4, 104, '2025-09-06', NULL),
(5, 5, 105, '2025-09-07', '2025-09-10');

-- =========================
-- Step 3: Queries to Test
-- =========================

-- 1. Show all books with their authors
SELECT b.Title, a.AuthorName, b.Genre, b.CopiesAvailable
FROM Books b
JOIN Authors a ON b.AuthorID = a.AuthorID;

-- 2. Find students who borrowed books but haven’t returned yet
SELECT s.Name, b.Title, br.BorrowDate
FROM Borrow br
JOIN Students s ON br.StudentID = s.StudentID
JOIN Books b ON br.BookID = b.BookID
WHERE br.ReturnDate IS NULL;

-- 3. Count total borrowed books by each student
SELECT s.Name, COUNT(br.BorrowID) AS TotalBorrowed
FROM Students s
LEFT JOIN Borrow br ON s.StudentID = br.StudentID
GROUP BY s.Name;

-- 4. Find the most borrowed genre
SELECT b.Genre, COUNT(*) AS BorrowCount
FROM Borrow br
JOIN Books b ON br.BookID = b.BookID
GROUP BY b.Genre
ORDER BY BorrowCount DESC
LIMIT 1;

-- 5. List books with fewer than 3 copies available
SELECT Title, CopiesAvailable
FROM Books
WHERE CopiesAvailable < 3;

