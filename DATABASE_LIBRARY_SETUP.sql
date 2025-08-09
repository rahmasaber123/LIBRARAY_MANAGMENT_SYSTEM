-- library mangment system project
--CREATING BRANCH TABLE
 DROP TABLE IF EXISTS BRANCH ;
 CREATE TABLE BRANCH (
    branch_id varchar(20) primary key,
    manager_id	varchar(20),
    branch_address varchar(55),
    contact_no varchar(25)
 );
 --CREATING EMPLOYEE TABLE
  DROP TABLE IF EXISTS EMPLOYEES ;
 CREATE TABLE EMPLOYEES (
     emp_id varchar(15) primary key,
     emp_name varchar(20),
     position	text,
     salary int,
     branch_id varchar(10)--foreign key
 );

 
--CREATING BOOKS TABLE
 DROP TABLE IF EXISTS BOOKS ;
 CREATE TABLE BOOKS (
   isbn varchar(25) primary key,
   book_title varchar(75),
   category varchar(15),	
   rental_price float,
   status	varchar(10),
   author varchar(35),
   publisher varchar(55)
);

 ALTER TABLE BOOKS
 ALTER COLUMN  category TYPE VARCHAR (40);

--creating table members
 DROP TABLE IF EXISTS  MEMBERS ;
 CREATE TABLE MEMBERS (
    member_id varchar(10) primary key,
    member_name varchar(25),
    member_address varchar(75),
    reg_date Date
);
 
--creating issued_status table
 DROP TABLE IF EXISTS  issued_status;
 create table issued_status (
    issued_id varchar(15) primary key,
    issued_member_id varchar(10),--fk members
    issued_book_name varchar(75),
    issued_date	Date,
    issued_book_isbn	varchar(25),--fk books
    issued_emp_id varchar(15)--fk employees
) ;
--creating return status table
 DROP TABLE IF EXISTS  return_status;
 create table return_status 
 (
    return_id varchar(15)  primary key,
    issued_id	varchar(15) ,--fk issued_status
    return_book_name	varchar(75),
    return_date Date,
    return_book_isbn varchar(25) --fk books 
);



--add foreign keys constraints
ALTER TABLE issued_status 
ADD CONSTRAINT FK_MEMEBERS
FOREIGN KEY (issued_member_id)
REFERENCES MEMBERS(member_id);

--!!

ALTER TABLE issued_status 
ADD CONSTRAINT FK_BOOKS
FOREIGN KEY (issued_book_isbn)
REFERENCES BOOKS(isbn);

--!!
ALTER TABLE issued_status 
ADD CONSTRAINT FK_EMPOLYEES
FOREIGN KEY (issued_emp_id) 
REFERENCES EMPLOYEES(emp_id);


--!!


ALTER TABLE return_status 
ADD CONSTRAINT FK_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status( issued_id);


--!!
ALTER TABLE return_status 
ADD CONSTRAINT FK_BOOKS
FOREIGN KEY (return_book_isbn)
REFERENCES BOOKS(isbn);
--!!

ALTER TABLE return_status 
ADD CONSTRAINT FK_BOOKS
FOREIGN KEY (return_book_isbn) 
REFERENCES BOOKS(isbn);


--!!

 ALTER TABLE EMPLOYEES
ADD CONSTRAINT FK_BRANCH
FOREIGN KEY (branch_id) 
REFERENCES BRANCH(branch_id);
