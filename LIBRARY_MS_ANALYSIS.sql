--SOLVING BUSINESS PROBLEMS 
SELECT* FROM BOOKS;
SELECT* FROM BRANCH;
SELECT* FROM EMPLOYEES;
SELECT* FROM ISSUED_STATUS;
SELECT* FROM MEMBERS;
SELECT* FROM RETURN_STATUS;

--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO BOOKS
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT* FROM BOOKS;


--Task 2: Update an Existing Member's Address
 UPDATE MEMBERS
 SET MEMBER_ADDRESS = '125 Oak St'
 WHERE MEMBER_ID =  'C103';
 SELECT* FROM MEMBERS;
--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM ISSUED_STATUS
WHERE issued_id = 'IS121';
SELECT* FROM ISSUED_STATUS;

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.


SELECT * FROM ISSUED_STATUS
WHERE ISSUED_EMP_ID = 'E101';


--Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT ISSUED_MEMBER_ID ,COUNT(*)
FROM ISSUED_STATUS
GROUP BY 1
HAVING COUNT(*)>1;


--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE TOTAL_BOOK_ISSUED AS
SELECT  B.ISBN,BOOK_TITLE ,COUNT(IST.ISSUED_BOOK_ISBN) AS book_issued_cnt
FROM ISSUED_STATUS IST
JOIN BOOKS B
ON B.ISBN = IST.ISSUED_BOOK_ISBN
GROUP BY B.ISBN;

SELECT * FROM TOTAL_BOOK_ISSUED;
--DATA ANALYSIS AND FINDINGD QUESTIONS
--Task 7. Retrieve All Books in a Specific Category:
SELECT * FROM BOOKS 
WHERE CATEGORY ='Classic';
--Task 8: Find Total Rental Income by Category:
SELECT CATEGORY ,SUM(B.RENTAL_PRICE) AS TOTAL_RENTAL_INCOME
FROM BOOKS AS B
JOIN ISSUED_STATUS IST
ON B.ISBN = IST.ISSUED_BOOK_ISBN

GROUP BY CATEGORY;

--List Members Who Registered in the Last 700 Days:
SELECT* FROM MEMBERS 
WHERE REG_DATE > CURRENT_DATE - INTERVAL '700 DAYS';

--List Employees with Their Branch Manager's Name and their branch details:
SELECT E.*,B.BRANCH_ID,E1.EMP_NAME AS MANAGER_NAME 
FROM EMPLOYEES E
JOIN BRANCH B 
ON B.BRANCH_ID  = E.BRANCH_ID
JOIN EMPLOYEES E1
ON E1.EMP_ID  = B.MANAGER_ID;


--. Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE EXPENSIVE_BOOKS AS
SELECT * FROM BOOKS 
WHERE RENTAL_PRICE >7;
SELECT* FROM EXPENSIVE_BOOKS;
--Task 12: Retrieve the List of Books Not Yet Returned
SELECT ISSUED_BOOK_NAME,RS.ISSUED_ID 
FROM RETURN_STATUS RS
RIGHT JOIN ISSUED_STATUS IST 
ON RS.ISSUED_ID = IST.ISSUED_ID
WHERE RETURN_BOOK_ISBN IS NULL;

/*Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books
(assume a 300-day return period). Display the member's_id,
member's name, book title, 
issue date, and days overdue.*/

SELECT M.MEMBER_ID,
M.MEMBER_NAME,
B.BOOK_TITLE, 
CURRENT_DATE-IST.ISSUED_DATE AS OVER_DUE
FROM ISSUED_STATUS IST
  JOIN MEMBERS M 
ON M.MEMBER_ID  = IST.ISSUED_MEMBER_ID
  JOIN BOOKS B
ON B.ISBN = IST.ISSUED_BOOK_ISBN
  LEFT JOIN RETURN_STATUS RS
ON RS.ISSUED_ID = IST.ISSUED_ID 
   WHERE RS.RETURN_DATE IS NULL 
   AND( CURRENT_DATE-ISSUED_DATE )>300
;
--Task 14: Update Book Status on Return
--Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
CREATE OR REPLACE PROCEDURE RETURN_BOOKS_STATUS(P_RETURN_ID VARCHAR(15),P_ISSUED_ID VARCHAR(15),P_BOOK_QUALITY VARCHAR(15))
LANGUAGE PLPGSQL
AS $$
DECLARE 
V_ISSUED_ISBN VARCHAR(25);
V_BOOK_NAME VARCHAR(75);
BEGIN
SELECT ISSUED_BOOK_ISBN,ISSUED_BOOK_NAME
INTO V_ISSUED_ISBN,V_BOOK_NAME
FROM ISSUED_STATUS
WHERE ISSUED_ID=P_ISSUED_ID ;

INSERT 
  INTO RETURN_STATUS(RETURN_ID,ISSUED_ID,RETURN_DATE,BOOK_QUALITY)
  VALUES(P_RETURN_ID,P_ISSUED_ID,CURRENT_DATE,P_BOOK_QUALITY);

UPDATE BOOKS
SET STATUS ='YES'
WHERE ISBN = V_ISSUED_ISBN;

RAISE NOTICE 'THANKS FOR RETURNING THE BOOK %',V_BOOK_NAME;
  
END;
$$
CALL RETURN_BOOKS_STATUS('RS138', 'IS135', 'Good');

/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.*/

CREATE TABLE BRANCH_REPORT AS
SELECT
E.EMP_ID,
BC.MANAGER_ID ,
  COUNT(RS.RETURN_ID) AS TOTAL_RETURN_BOOKS,
  COUNT(IST.ISSUED_ID ) AS TOTAL_ISSUED_BOOKS
  FROM ISSUED_STATUS IST
  JOIN EMPLOYEES E 
ON E.EMP_ID =IST.ISSUED_EMP_ID
  JOIN BOOKS B
ON B.ISBN =IST.ISSUED_BOOK_ISBN
  JOIN BRANCH BC
ON BC.BRANCH_ID =E.BRANCH_ID
  LEFT JOIN RETURN_STATUS RS
ON RS.ISSUED_ID =IST.ISSUED_ID
  GROUP BY 1,2;
SELECT* FROM BRANCH_REPORT;

/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table 
active_members containing members who have issued at least one book in the last 20 months.*/
CREATE TABLE LAST_20MONTH_CHECK AS 
  SELECT * FROM MEMBERS WHERE MEMBER_ID IN(
  SELECT DISTINCT ISSUED_MEMBER_ID FROM 
ISSUED_STATUS
WHERE ISSUED_DATE >= CURRENT_DATE - INTERVAL'20 MONTHS');
SELECT* FROM LAST_20MONTH_CHECK;




/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues.
Display the employee name, number of books processed, and their branch.*/

SELECT EMP_NAME,B.*,COUNT(IST.ISSUED_ID) AS NUM_BOOK_ISSUED
FROM ISSUED_STATUS IST
   JOIN
   EMPLOYEES E
ON E.EMP_ID=IST.ISSUED_EMP_ID
  JOIN BRANCH B
ON B.BRANCH_ID = E.BRANCH_ID
  GROUP BY 1,2
ORDER BY COUNT(IST.ISSUED_ID)
   LIMIT 3;
/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books 
more than twice with the status "damaged" in the books table. 
Display the member name, book title,
and the number of times they've issued damaged books.*/

SELECT M.MEMBER_NAME, 
  B.BOOK_TITLE ,
COUNT(IST.ISSUED_BOOK_ISBN) AS HIGH_RISK_BOOKS
FROM ISSUED_STATUS IST
   LEFT JOIN RETURN_STATUS RS
ON IST.ISSUED_ID =RS.ISSUED_ID 
   JOIN MEMBERS M
ON M.MEMBER_ID=ISSUED_MEMBER_ID
   JOIN BOOKS B 
ON B.ISBN = IST.ISSUED_BOOK_ISBN 
   WHERE RS.BOOK_QUALITY ='Damaged'
GROUP BY 1,2
   HAVING count(RS.BOOK_QUALITY)>2;


/*Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued,
and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'),
the procedure should return an error message indicating that the book is currently not available.*/



CREATE OR REPLACE PROCEDURE STATUS_BOOK(p_issued_id VARCHAR(15), p_issued_member_id VARCHAR(10), p_issued_book_isbn VARCHAR(25), p_issued_emp_id VARCHAR(15))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$
CALL STATUS_BOOK('IS155', 'C108', '978-0-553-29698-2', 'E104');
/*Task 20: Create Table As Select (CTAS) Objective: 
Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.*/

 SELECT  M.member_id, 
	M.member_name, 
	COUNT(member_id) AS books_overdue,
	SUM((CURRENT_DATE - (iST.issued_date + INTERVAL '30 Days')::DATE) * 0.50) AS total_fines	--::DATE MAKES SURE IT RETURNS DATE TYPE
FROM members AS M
JOIN issued_status AS iST
	ON iST.issued_member_id = M.member_id
LEFT JOIN return_status AS RS
	ON RS.issued_id = IST.issued_id
JOIN books AS b
	ON b.isbn = iST.issued_book_isbn
WHERE return_date IS NULL 
	AND CURRENT_DATE - (iST.issued_date + INTERVAL '30 Days')::DATE > 0
GROUP BY 1,2;
