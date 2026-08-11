use classicmodels;

#SELECT clause with WHERE, AND, DISTINCT
select distinct
employeeNumber,firstName,lastName
from employees
where jobTitle = "Sales Rep"
and reportsTo = 1102;

#SELECT clause with WHERE,DISTINCT, Wild Card (LIKE)
select distinct productLine
from products
where productLine like "%Cars";

#CASE STATEMENTS for Segmentation
Select 
    customerNumber,
    customerName,
    Case
        When country In ("USA", "Canada") Then  "North America"
        When country In ("UK", "France", "Germany") Then "Europe"
        ELSE "Other"
    End as CustomerSegment
From customers;

#Group By with Aggregation functions and Having clause, Date and Time functions
Select 
    productCode,
    Sum(quantityOrdered) as TotalOrderQuantity
From orderdetails
Group By productCode
Order By TotalOrderQuantity Desc
Limit 10;

Select
    MonthName(paymentDate) as PaymentMonth,
    Count(*) as TotalPayments
From payments
Group By Month(paymentDate), MonthName(paymentDate)
Having Count(*) > 20
Order By TotalPayments Desc;

#CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
-- Create the database
Create Database Customers_Orders;
-- Select the database
Use Customers_Orders;
-- Create Customers table
Create Table Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20));
describe customers;

Use Customers_Orders;

Create Table Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
        FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),
        CHECK (total_amount > 0));
describe orders;

#joins
use classicmodels;
Select
    c.country,
    Count(o.orderNumber) as OrderCount
From customers as c
Join orders as o
    on c.customerNumber = o.customerNumber
Group By c.country
Order By OrderCount Desc
Limit 5;

#self Join
create Table Project(    
EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    Gender VARCHAR(10) CHECK (Gender IN ('Male', 'Female')),
    ManagerID INT);
describe project;
    
Insert into project (EmployeeID, FullName, Gender, ManagerID) Value
(1, 'Pranaya', 'Male', 3),
(2, 'Priyanka', 'Female', 1),
(3, 'Preety', 'Female', NULL),
(4, 'Anurag', 'Male', 1),
(5, 'Sambit', 'Male', 1),
(6, 'Rajesh', 'Male', 3),
(7, 'Hina', 'Female', 3);

Select
    m.FullName AS "Manager Name",
    e.FullName AS "Emp Name"
From project e
Join project m 
    on e.ManagerID = m.EmployeeID;
    
#DDL Commands: Create, Alter, Rename
Create Table Facility (
    Facility_ID INT,
    Name VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100));
    
Alter Table Facility
Modify Facility_ID INT AUTO_INCREMENT,
Add PRIMARY KEY (Facility_ID);

Alter Table Facility 
Add City VARCHAR(100) NOT NULL AFTER Name;
 Describe Facility;
 
#Views in SQL
Use classicmodels;

Create View product_category_sales as
Select
    pl.productLine,
   Round(Sum(od.quantityOrdered * od.priceEach), 2) as total_sales,
    Count(DISTINCT o.orderNumber) as number_of_orders
From productlines as pl
Join products as p
    on pl.productLine = p.productLine
Join orderdetails as od
    on p.productCode = od.productCode
Join orders as o
    on od.orderNumber = o.orderNumber
Group By pl.productLine;

select * from product_category_sales;

#Stored Procedures in SQL with parameters

Use classicmodels;

Delimiter $$

Create Procedure Get_country_payments(
    IN p_year INT,
    IN p_country VARCHAR(50))
Begin
    Select
        Year(p.paymentDate) AS payment_year,
        c.country,
        Concat(
            ROUND(SUM(p.amount) / 1000, 1),
            'K') AS total_amount
    From customers AS c
    Join  payments AS p
        on c.customerNumber = p.customerNumber
    Where Year(p.paymentDate) = p_year
      and c.country = p_country
    Group By Year(p.paymentDate), c.country;
End $$

Delimiter ;

Call Get_country_payments(2003, 'France');

#Window functions - Rank, dense_rank, lead and lag
Use classicmodels;

USE classicmodels;

SELECT
    c.customerNumber,
    c.customerName,
    COUNT(o.orderNumber) AS order_frequency,
    RANK() OVER (
        ORDER BY COUNT(o.orderNumber) DESC
    ) AS customer_rank
FROM customers AS c
JOIN orders AS o
    ON c.customerNumber = o.customerNumber
GROUP BY
    c.customerNumber,
    c.customerName
ORDER BY customer_rank;

Use Classicmodels;

WITH monthly_orders AS (
    SELECT
        YEAR(orderDate) AS order_year,
        MONTH(orderDate) AS month_no,
        MONTHNAME(orderDate) AS month_name,
        COUNT(orderNumber) AS order_count
    FROM orders
    GROUP BY
        YEAR(orderDate),
        MONTH(orderDate),
        MONTHNAME(orderDate)
),
yoy_calculation AS (
    SELECT
        order_year,
        month_no,
        month_name,
        order_count,
        LAG(order_count) OVER (
            PARTITION BY month_no
            ORDER BY order_year
        ) AS previous_year_orders
    FROM monthly_orders
)
SELECT
    order_year,
    month_name,
    order_count,
    CASE
        WHEN previous_year_orders IS NULL THEN '0%'
        WHEN previous_year_orders = 0 THEN NULL
        ELSE CONCAT(
			ROUND(((order_count - previous_year_orders)/ previous_year_orders) * 100),'%')
    END AS YoY_percentage
FROM yoy_calculation
ORDER BY order_year, month_no;

#Subqueries and their applications


Use classicmodels;

Select
    productLine,
    Count(*) as product_count
From products
Where buyPrice > (Select Avg(buyPrice) from products)
Group By productLine
Order By product_count Desc;

USE classicmodels;

Create Table Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100),
    EmailAddress VARCHAR(100));
    Describe Emp_EH;
    
    DELIMITER $$

Create Procedure Insert_Emp_EH(
    IN p_EmpID INT,
    IN p_EmpName VARCHAR(100),
    IN p_EmailAddress VARCHAR(100)
)
Begin

    Declare Exit Handler for SQLException
    Begin
        Select 'Error occurred' as Message;
    End;

    INSERT INTO Emp_EH
        (EmpID, EmpName, EmailAddress)
    VALUES
        (p_EmpID, p_EmpName, p_EmailAddress);

END $$

DELIMITER ;

Call Insert_Emp_EH(101, 'Feroz', 'feroz@gmail.com');

Select * from Emp_EH;

CALL Insert_Emp_EH(101, 'farvez', 'farvez@gmail.com');

#TRIGGERS
Create Table Emp_BIT (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date DATE,
    Working_hours INT);
    describe Emp_BIT;
    
 Insert into Emp_BIT Values
('Robin', 'Scientist', '2020-10-04', 12),
('Warner', 'Engineer', '2020-10-04', 10),
('Peter', 'Actor', '2020-10-04', 13),
('Marco', 'Doctor', '2020-10-04', 14),
('Brayden', 'Teacher', '2020-10-04', 12),
('Antonio', 'Business', '2020-10-04', 11);
select * from Emp_BIT;

DELIMITER $$

Create Trigger before_insert_Emp_BIT
Before insert on Emp_BIT
For Each Row
Begin
    If New.Working_hours < 0 Then
        Set New.Working_hours = ABS(New.Working_hours);
        End If;
End $$

DELIMITER ;

#Test Trigger
Insert into Emp_BIT Values ('Feroz', 'Data Analyst', '2020-10-05', -8);

select * from Emp_BIT;

---------- END ------------




