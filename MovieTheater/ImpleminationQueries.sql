/*This project consists of completing  a different group of tasks using a database created by you. The minimum requirements for the database design are:
Insert at least three tables into your database.
Create at least three columns per table, be creative when it comes to the data types of your variables.
In addition, insert 7 records per table.
Define a primary key for each table and  make use of the foreign key concept in a query. 
Once you have finished with the database design, please follow the instructions listed below:
1- Add a constraint to a column in any of the tables. (Example: add constraint minimum_date check(Transaction_date >='01.01.2019')...)
1.1- Test the constraint by inserting a new record that violates it.
2- Run at least three queries: 
2.1- One query should involve at least three different tables. 
2.2- In at least one of them, Join operators must be used. 
2.3- In at least one of the queries you should use the HAVING clause.
3- Update a column based on a condition that needs to be met using the where clause.
4- Retrieve data with a query directly into a variable. The variables must be initially declared. The final query must return the minimum and maximum values 
through the variables previously declared. Find out more information in Chapter 6 of the book and assignments related to it.
5- You must create a procedure that returns full details of one of the tables of your choosing based on a given condition using the WHERE clause. 
Check chapter 17 and Video uploaded in Blackboard.

Example:
Create procedure procedure_name
AS
SELECT Columns
FROM table name
WHERE condition
EXEC procedure_name
The Final Project grade is divided in the following way:
1-Sql file along with comments in order to complete the previous taks. (70% of the grade)
2-Presentation. Each team's presentation should not last more/less than 10 minutes. (20% of the grade)
3-Q&A section (10% of the grade). Each student should elaborate at least one question to other team's presentation. */

USE movie_theater_chain;

-- 1 & 1.1
-- THE MOVIE THEATER CHAIN BEGAN AT THE BEGINING OF THE YEAR
-- LETS ADD A CONSTRAINT THAT LIMITS THE DATE BEING USED TO PREVENT ACCIDENTS

ALTER TABLE sales
ADD CONSTRAINT CHK_sale_date 
CHECK (sale_date > '2022-01-01');

INSERT INTO sales
VALUES (107, 1001, 13, '2010-01-01');
-- WORKING AS INTENDED

-- 2.1, 2.2, & 2.3
-- LETS FIND EMPLOYEES THAT HAVE SOLD MORE THAN 3 TICKETS

SELECT e.employee_id, 
	CONCAT(first_name, ' ', last_name) AS full_name,
	COUNT(item_id) AS tickets_sold
FROM employee e
	JOIN sales s
		ON e.employee_id = s.employee_id
	JOIN sale_details sd
		ON s.sale_id = sd.sale_id
WHERE item_id BETWEEN 3000 AND 3002
GROUP BY e.employee_id, CONCAT(first_name, ' ', last_name)
HAVING COUNT(item_id) > 3
ORDER BY e.employee_id;

-- LETS FIND OUT WHAT LOCATIONS CONTRIBUTE MOST TO TOTAL SALES

SELECT location_id AS locations,
	COUNT(sale_id) AS total_sales, 
	SUM(quantity * price) AS total_sale_amt
FROM sale_details 
	JOIN item
		ON sale_details.item_id = item.item_id
	JOIN theater
		ON sale_details.theater_id = theater.theater_id
GROUP BY location_id
ORDER BY total_sale_amt DESC;

-- LETS FIND OUT THE PERCENT OF CUSTOMERS THAT ORDERED CONCESSIONS

SELECT ROUND((
	SELECT COUNT(DISTINCT sale_id) FROM sale_details WHERE NOT item_id BETWEEN 3000 AND 3004
    )
    / CAST(COUNT(DISTINCT sale_id) AS FLOAT), 2) AS concessions_per_customer
FROM sale_details;

-- 3
-- OUR CHAIN WILL BE DISCOUNTING POPCORN IN THE HOPES THAT AN INCREASE IN POPCORN SALES
-- INCREASES DRINK SALES

UPDATE item
SET discounted_price = price * .85
WHERE item_id IN(5000,5001,5002);

SELECT item_id, name, price, discounted_price
FROM item
WHERE item_id IN(5000,5001,5002);

--4
-- This will show the highest and lowest pay rates associated  with the job title 

 Declare @Highestpayrate FLOAT,
		 @Lowestpayrate FLOAT;

Select @Highestpayrate = Max(Rate),
	   @Lowestpayrate= Min(Rate)
FROM position;

Select  @Highestpayrate As HighestRate,
		@Lowestpayrate As LowestRate;

--5
--You want to return values to the code calling the procedure. Specify some parameters as OUTPUT parameters. The following example creates a stored procedure that returns the list of departments for a speciﬁc group. In addition to
-- returning the entire list for the particular Name

CREATE OR ALTER PROCEDURE dbo.pricelist
   	@Name VARCHAR(60)								
	
AS   	
	SELECT   *
	FROM 	item
	WHERE	name = @Name 	
	ORDER BY Price;   	
GO
EXEC dbo.pricelist 'Large ICEE (51oz)';
