create database Library_management
create table Writers (
    WID INT PRIMARY KEY,
    WName VARCHAR(50) NOT NULL);

create table Books (
    BookID INT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    WID INT,
    PublishedYear INT,
    CONSTRAINT FK_WID FOREIGN KEY (WID) REFERENCES Writers(WID)
);

CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    UserName VARCHAR(100) NOT NULL
);

CREATE TABLE Return_Book (
    RID INT PRIMARY KEY,
    UserID INT,
    BookID INT,
    RDate DATE,
    ReturnDate DATE,
    CONSTRAINT FK_UserID FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_BookID FOREIGN KEY (BookID) REFERENCES Books(BookID)
);


-- Insert Writers of the Books which is present in the library
INSERT INTO Writers(WID, WName) VALUES
(1, 'Jane Doe'),
(2, 'John Smith'),
(3, 'Winget'),
(4, 'Jennifer'),
(5, 'Professer'),
(7, 'Raman'),
(6, 'Alicia');

-- Insert Books into books table
INSERT INTO Books (BookID, Title, WID, PublishedYear) VALUES
(101, 'Sample Book 1', 1, 2000),
(102, 'Sample Book 2', 2, 2014),
(103, 'Sample Book 3', 3, 2000),
(104, 'Sample', 4, 2016),
(105, 'Book 2', 5, 1996),
(106, 'Book1', 6, 1879),
(107, 'BookXYZ', 7, 1994);

-- Insert Users
INSERT INTO Users (UserID, UserName) VALUES
(1001, 'User1'),
(1002, 'User2'),
(1003, 'User3'),
(1004, 'User4'),
(1005, 'User5'),
(1006, 'User6'),
(1007, 'User7');
select * from Users

-- Insert Loans
INSERT INTO Return_Book(RID, UserID, BookID, RDate, ReturnDate) VALUES
(10001, 1001, 101, '2023-01-01', '2023-01-15'),
(10002, 1002, 102, '2023-02-01', '2023-02-15'),
(10003, 1003, 103, '2023-03-01', null),
(10004, 1006, 101, '2023-01-01', '2023-01-15'),
(10005, 1004, 102, null, '2023-02-15'),
(10006, 1005, 103, '2023-03-01', null),
(10007, 1001, 103, '2023-03-01', null);

CREATE TABLE LateFees (
    FeeID INT PRIMARY KEY,
    FeeName VARCHAR(100) NOT NULL,
    FeeAmount DECIMAL(10, 2) NOT NULL
);

-- Insert a LateFeePerDay record
INSERT INTO LateFees (FeeID, FeeName, FeeAmount) VALUES (1, 'LateFeePerDay', 2.50);




--========================================Queries===========================================

--Query: Find the titles of books and their respective authors./Provide a list of books along with their authors?

SELECT Books.Title, Writers.WName
FROM Books
INNER JOIN Writers ON Books.WID = Writers.WID;


-- Find books that have been currently returned
SELECT Books.Title, Users.UserName, Return_Book.ReturnDate
FROM Books
INNER JOIN Return_Book ON Books.BookID = Return_Book.BookID
INNER JOIN Users ON Return_Book.UserID = Users.UserID
WHERE Return_Book.ReturnDate IS NOT NULL;

--which booked is currently borrowed
SELECT Books.Title, Users.UserName
FROM Books
INNER JOIN Return_Book ON Books.BookID = Return_Book.BookID
INNER JOIN Users ON Return_Book.UserID = Users.UserID
WHERE Return_Book.ReturnDate IS NULL;

-- name of those student who do not return book on time
SELECT Users.UserName, Books.Title, Return_Book.RDate, Return_Book.ReturnDate
FROM Users
INNER JOIN Return_Book ON Users.UserID = Return_Book.UserID
INNER JOIN Books ON Return_Book.BookID = Books.BookID
WHERE Return_Book.ReturnDate IS NULL OR Return_Book.ReturnDate < GETDATE();


-- Most borrowed book from the library

SELECT TOP 1 Books.Title, COUNT(Return_Book.RID) AS BorrowedCount
FROM Books
LEFT JOIN Return_Book ON Books.BookID = Return_Book.BookID
GROUP BY Books.Title
ORDER BY BorrowedCount DESC;

-- Calculate Late Fees for Overdue Books/can calculate without creating table as well
DECLARE @LateFeePerDay DECIMAL(10, 2);
SET @LateFeePerDay = 2.50;  -- late fees charge/day

SELECT
    Users.UserName,
    Books.Title,
    DATEDIFF(DAY, Return_Book.ReturnDate, GETDATE()) AS DaysLate,
    DATEDIFF(DAY, Return_Book.ReturnDate, GETDATE()) * @LateFeePerDay AS LateFee
FROM
    Users
INNER JOIN Return_Book ON Users.UserID = Return_Book.UserID
INNER JOIN Books ON Return_Book.BookID = Books.BookID
WHERE
    Return_Book.ReturnDate IS NOT NULL
    AND Return_Book.ReturnDate < GETDATE();


--calculate late fees

SELECT
    Users.UserName,
    Books.Title,
    DATEDIFF(DAY, Return_Book.ReturnDate, GETDATE()) AS DaysLate,
    DATEDIFF(DAY, Return_Book.ReturnDate, GETDATE()) * LF.FeeAmount AS LateFee
FROM
    Users
INNER JOIN Return_Book ON Users.UserID = Return_Book.UserID
INNER JOIN Books ON Return_Book.BookID = Books.BookID
INNER JOIN LateFees LF ON LF.FeeName = 'LateFeePerDay'
WHERE
    Return_Book.ReturnDate IS NOT NULL
    AND Return_Book.ReturnDate < GETDATE();

--those books which is borrowed by specific student

SELECT Users.UserName, Books.Title
FROM Users
INNER JOIN Return_Book ON Users.UserID = Return_Book.UserID
INNER JOIN Books ON Return_Book.BookID = Books.BookID
WHERE Users.UserName = 'User1';

-- List all users who have borrowed a specific book
SELECT Users.UserName, Books.Title
FROM Users
INNER JOIN Return_Book ON Users.UserID = Return_Book.UserID
INNER JOIN Books ON Return_Book.BookID = Books.BookID
WHERE Books.Title = 'Sample Book 1';

-- Find the most popular writer based on the number of borrowed books
SELECT TOP 1 Writers.WName, COUNT(Return_Book.RID) AS BorrowedCount
FROM Writers
INNER JOIN Books ON Writers.WID = Books.WID
INNER JOIN Return_Book ON Books.BookID = Return_Book.BookID
GROUP BY Writers.WName
ORDER BY BorrowedCount DESC;


-- Find the most popular writer based on the number of borrowed books
SELECT TOP 1 Writers.WName, COUNT(Return_Book.RID) AS BorrowedCount
FROM Writers
INNER JOIN Books ON Writers.WID = Books.WID
INNER JOIN Return_Book ON Books.BookID = Return_Book.BookID
GROUP BY Writers.WName
ORDER BY BorrowedCount DESC;


DECLARE @LateFeesPerDay DECIMAL(10, 2);
SET @LateFeesPerDay = 2.50; -- declare a var for fees 
-- Find the user with the highest late fee
SELECT TOP 1 Users.UserName, SUM(DATEDIFF(DAY, Return_Book.ReturnDate, GETDATE()) * @LateFeesPerDay) AS TotalLateFee
FROM Users
INNER JOIN Return_Book ON Users.UserID = Return_Book.UserID
WHERE Return_Book.ReturnDate IS NOT NULL AND Return_Book.ReturnDate < GETDATE()
GROUP BY Users.UserName
ORDER BY TotalLateFee DESC;

-- Find books that are not currently borrowed
SELECT Books.Title
FROM Books
LEFT JOIN Return_Book ON Books.BookID = Return_Book.BookID
WHERE Return_Book.RID IS NULL;


-- select the user with the highest late fees
SELECT TOP 1 Users.UserName, SUM(DATEDIFF(DAY, Return_Book.ReturnDate, GETDATE()) * 2.50) AS TotalLateFee
FROM Users
INNER JOIN Return_Book ON Users.UserID = Return_Book.UserID
WHERE Return_Book.ReturnDate IS NOT NULL AND Return_Book.ReturnDate < GETDATE()
GROUP BY Users.UserName
ORDER BY TotalLateFee DESC;

-- extract those books which published in the last year
SELECT Title, PublishedYear
FROM Books
WHERE PublishedYear >= YEAR(GETDATE()) - 1;


-- List popular genres (based on the writers)
SELECT Writers.WName AS Author, COUNT(Books.BookID) AS BookCount
FROM Writers
LEFT JOIN Books ON Writers.WID = Books.WID
GROUP BY Writers.WName
ORDER BY BookCount DESC;

-- Calculate the average duration of book loans
SELECT AVG(DATEDIFF(DAY, RDate, ReturnDate)) AS AverageLoanDuration
FROM Return_Book
WHERE ReturnDate IS NOT NULL;

-- Identify users with frequent late returns
SELECT Users.UserName, COUNT(*) AS LateReturns
FROM Users
INNER JOIN Return_Book ON Users.UserID = Return_Book.UserID
WHERE Return_Book.ReturnDate IS NOT NULL AND Return_Book.ReturnDate > Return_Book.RDate
GROUP BY Users.UserName
ORDER BY LateReturns DESC;

--those books, written by particular writer
SELECT Title FROM Books WHERE WID = (SELECT WID FROM Writers WHERE WName = 'Alicia');

--books borrowed by a student 1004
SELECT Title FROM Books WHERE BookID IN (SELECT BookID FROM Return_Book WHERE UserID = 1004);

--currentl overdue books

SELECT Title FROM Books
WHERE BookID IN (SELECT BookID FROM Return_Book WHERE ReturnDate IS NULL AND RDate < GETDATE());

--available books
SELECT Title FROM Books WHERE BookID NOT IN (SELECT BookID FROM Return_Book WHERE ReturnDate IS NULL);

--late fees pwr day/Calculate the late fees for books that a user has returned late.
DECLARE @LatefPerDay DECIMAL(10, 2);
SELECT SUM(DATEDIFF(DAY, RDate, ReturnDate) * @LatefPerDay) AS TotalLateFees
FROM Return_Book
WHERE UserID = 1004 AND ReturnDate IS NOT NULL;

	

-- Check for overdue books
SELECT Books.Title, Users.UserName, Return_Book.RDate AS DueDate
FROM Return_Book
INNER JOIN Users ON Return_Book.UserID = Users.UserID
INNER JOIN Books ON Return_Book.BookID = Books.BookID
WHERE Return_Book.ReturnDate IS NULL AND Return_Book.RDate < GETDATE();






