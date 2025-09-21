--Real world basic to advanced Questions practice Set

-- Find the 2nd highest salary from the Employees table.

SELECT max(salary) as second_highest_slary FROM employees
where Salary < (select max(Salary) from employees)


-- Show customers who placed more than 5 orders.

select c.CustomerID, c.FirstName, count(o.OrderID) as total_orders,
rank() OVER(order by count(o.OrderID) desc) as rnk,
dense_rank() OVER(order by count(o.OrderID) desc) as dense_rnk,
ROW_NUMBER() OVER(order by count(o.OrderID) desc) from customers c
JOIN orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName
having count(o.orderID) >5
ORDER BY total_orders desc


-- Retrieve products that were never ordered.

select p.ProductID, p.ProductName from Products p
LEFT JOIN order_details o
ON p.ProductID = o.ProductID
WHERE o.ProductID IS NULL;

-- Find the monthly sales trend for 2024.


SELECT YEAR(CAST(o.OrderDate AS date)) AS order_year, 
       LEFT(DATENAME(MONTH, CAST(o.OrderDate AS date)), 3) AS order_month,
       ROUND(SUM(od.Quantity * od.UnitPrice), 2) AS total_sales
FROM Orders o
JOIN Order_Details od ON o.OrderID = od.OrderID
WHERE YEAR(CAST(o.OrderDate AS date)) = 2024
GROUP BY YEAR(CAST(o.OrderDate AS date)), DATENAME(MONTH, CAST(o.OrderDate AS date)), MONTH(CAST(o.OrderDate AS date))
ORDER BY MONTH(CAST(o.OrderDate AS date));

-- Rank employees by salary within each department.

select 
	EmployeeID, emp_FullName,Salary,
	ROW_NUMBER() OVER(partition by DepartmentID order by salary desc) as rnk
	from employees;

-- Find top 3 best-selling products (by revenue)

SELECT TOP 3
	p.ProductName, SUM(od.Unitprice * od.Quantity) as revenue
	FROM products p
	JOIN order_details od
	ON p.ProductID = od.ProductID
	GROUP BY p.ProductName
	ORDER BY revenue DESC;

-- Show customers who ordered in January 2024 but not in February 2024

SELECT DISTINCT c.CustomerID, c.FirstName, o.OrderDate
	FROM customers c
	JOIN orders o
	ON c.CustomerID = o.CustomerID
	where o.OrderDate BETWEEN '2025-01-01' AND '2025-01-31'
	AND c.CustomerID NOT IN(
	SELECT o2.customerID
	from orders o2
	WHERE o2.OrderDate BETWEEN '2024-02-01' AND '2024-02-29'
	);

-- List the top 10 most expensive products (by UnitPrice).

SELECT TOP 10
	ProductID, ProductName,Category, UnitPrice
	FROM Products
	ORDER BY UnitPrice DESC

--Get the total revenue per product category.

SELECT p.Category, ROUND(SUM(od.Quantity * od.UnitPrice),2) AS revenue
	FROM Products p
	JOIN order_details od
	ON p.ProductID = od.ProductID
	GROUP BY p.Category
	ORDER BY revenue DESC;

-- Find suppliers who supply more than 30 different products.

SELECT s.SupplierID, s.SupplierName, COUNT(p.ProductID) AS ProductCount
	FROM Suppliers s
	JOIN Products p ON s.SupplierID = p.SupplierID
	GROUP BY s.SupplierID, s.SupplierName
	HAVING COUNT(p.ProductID) > 30;

-- Show the 3 most recent orders for each customer.

SELECT * FROM(
		SELECT o.orderID, o.customerID, o.orderDate,
	   ROW_NUMBER() OVER(PARTITION BY o.CustomerID ORDER BY o.Orderdate) as rn
	   FROM orders o
	) t
	WHERE rn <= 3
	ORDER BY CustomerID, orderDate DESC;

--Which products are out of stock but have been ordered at least once

SELECT p.ProductID, p.ProductName
	FROM Products p JOIN order_details od
	ON p.ProductID = od.ProductID
	WHERE p.UnitsInStock = 0;

--Calculate each customer’s lifetime spend

SELECT c.CustomerID, c.FirstName,
	SUM(od.Quantity * od.UnitPrice) as lifetime_spend FROM customers c
	JOIN orders o ON c.CustomerID = o.CustomerID
	JOIN order_details od ON o.OrderID = od.OrderID
	GROUP BY c.CustomerID, c.FirstName
	Order BY lifetime_spend DESC;

--Find the product that has been ordered the most (by total quantity)

SELECT TOP 1 p.ProductID, p.ProductName, SUM(od.Quantity) AS Totalqty FROM Products p
	JOIN order_details od
	ON p.ProductID = od.ProductID
	GROUP BY p.ProductID, p.ProductName
	ORDER BY Totalqty DESC;

--Compare average order value between 2023 and 2024

SELECT YEAR(OrderDate) AS OrderYear,
	ROUND(AVG(od.Quantity * od.UnitPrice),2) AS Avg_Price
	FROM orders o JOIN order_details od
	ON o.OrderID = od.OrderID
	WHERE YEAR(OrderDate) IN (2023, 2024)
	GROUP BY YEAR(OrderDate)
	ORDER BY Avg_Price;

--Get customers who ordered from at least 5 different categories


select c.CustomerID, c.FirstName, 
	COUNT(DISTINCT p.Category) AS CategoryCount from customers c
	JOIN orders o ON c.CustomerID = o.CustomerID
	JOIN order_details od ON o.OrderID = od.OrderID
	JOIN Products p ON od.ProductID = p.ProductID
	GROUP BY c.CustomerID, c.FirstName
	HAVING COUNT(DISTINCT p.Category) >=5
	ORDER BY CategoryCount DESC;

--Advanced Questions

--Find the top 3 best-selling products in each category (by revenue)

WITH categorySales AS(
	SELECT p.ProductID, p.Category, p.ProductName,
	SUM(od.Quantity * od.UnitPrice) as Revenue,
	ROW_NUMBER() OVER (PARTITION BY p.Category ORDER BY SUM(od.Quantity * od.UnitPrice) DESC) AS rn
	FROM order_details od JOIN Products p ON p.ProductID = od.ProductID
	GROUP BY p.ProductID, p.Category, p.ProductName

	) 
SELECT ProductID, Category, ProductName
FROM categorySales
WHERE rn<=3
ORDER BY Category, Revenue DESC;

--Find the top 5 customers by spending within each year
WITH CTE AS(
	SELECT c.CustomerID, c.FirstName, YEAR(o.OrderDate) AS OrderYear,
	SUM(od.Quantity * od.UnitPrice) AS Spending,
	RANK() OVER (PARTITION BY YEAR(o.OrderDate) ORDER BY SUM(od.Quantity * od.UnitPrice) DESC) AS rn
	FROM customers c	
	JOIN orders o ON c.CustomerID = o.CustomerID
	JOIN order_details od ON o.OrderID = od.OrderID
	GROUP BY c.CustomerID, c.FirstName,YEAR(o.OrderDate)
	)
SELECT * FROM CTE
WHERE rn<=5
ORDER BY OrderYear, Spending DESC;

--Calculate the running total of revenue per month

WITH monthlyrevenue AS(
	SELECT YEAR(o.OrderDate) AS Order_year, 
	MONTH(o.OrderDate) AS Order_month,
	ROUND(SUM(od.Quantity * od.UnitPrice),2) AS monthlyrevenue from orders o
	JOIN order_details od ON o.OrderID = od.OrderID
	GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
	)

SELECT Order_year,
	   Order_month,
	   monthlyrevenue,
	   SUM(monthlyrevenue) OVER(
	   PARTITION BY Order_year
	   ORDER BY Order_month
	   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) AS running_total_revenue
	FROM monthlyrevenue
	ORDER BY Order_year, Order_month

--Calculate running total revenue per customer (cumulative spend over time)

SELECT c.CustomerID, c.FirstName, o.Orderdate,
	SUM(od.Quantity * od.UnitPrice) OVER(
	PARTITION BY c.customerID
	ORDER BY o.OrderDate 
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	) AS running_total_revenue
	FROM customers c
	JOIN orders o ON c.customerID = o.customerID
	JOIN order_details od ON o.orderID = od.orderID
	ORDER BY c.CustomerID, o.OrderDate

--Find the month-over-month revenue growth %

WITH monthlyrevenue AS (
	SELECT YEAR(o.orderDate) AS order_year,
	MONTH(o.orderDate) AS order_month,
	SUM(od.Quantity * od.UnitPrice) AS revenue FROM orders o
	JOIN order_details od ON o.orderID = od.orderID
	GROUP BY YEAR(o.orderdate), MONTH(o.orderDate) 
	)
SELECT order_year,
	   order_month,
	   LAG(revenue) OVER (ORDER BY order_year, order_month) AS pre_month_revenue,
	   ROUND(
			(revenue - LAG(revenue) OVER (ORDER BY order_year, order_month)) * 100.0/
			NULLIF(LAG(revenue) OVER (ORDER BY order_year, order_month),0),2
	   ) AS growth_percent
FROM monthlyrevenue
ORDER BY order_year, order_month;

--Find the average time (in days) between order date and payment date per customer
	
SELECT c.CustomerID, c.FirstName,
	AVG(DATEDIFF(DAY, o.orderDate, p.PaymentDate)) AS avg_payment_delay
	FROM customers c
	JOIN orders o ON c.CustomerID = o.CustomerID
	JOIN payments p ON o.OrderID = p.OrderID
	GROUP BY c.CustomerID, c.FirstName;

--Find the top 5 products that generated the highest revenue after

SELECT TOP 5
	p.productID,
	p.ProductName,
	SUM(od.Quantity * od.UnitPrice) as revenue
	FROM Products p	
	JOIN order_details od ON p.ProductID = od.ProductID	
	GROUP By p.productID, p.ProductName
	order by revenue DESC;

--Find suppliers who supply more than 5 unique products

SELECT s.SupplierID,
	s.SupplierName,
	COUNT(DISTINCT p.ProductID) AS unique_products
	FROM suppliers s
	JOIN Products p
	ON s.SupplierID = p.SupplierID
	GROUP BY s.SupplierID, s.SupplierName
	HAVING COUNT(DISTINCT p.ProductID) > 5;

--Find the most frequently ordered product combination (basket analysis)

SELECT 
	od1.productID AS ProductA,
	od2.productID AS ProductB,
	COUNT(*) AS Bought_together
	FROM order_details od1
	JOIN order_details od2
	ON od1.orderId = od2.orderID
	WHERE od1.ProductID < od2.ProductID
	GROUP BY od1.productID, od2.productID
	ORDER BY Bought_together DESC;

--Find customers who returned after 90+ days gap between two orders

WITH orders_gap AS(
	SELECT o.CustomerID,
	o.OrderDate,
	LAG(o.orderDate) OVER(PARTITION BY o.CustomerID ORDER BY o.OrderDate) as Prev_order_date
	FROM orders o
	) 
SELECT DISTINCT
	c.CustomerID,
	c.FirstName,
	o.OrderDate,
	o.Prev_order_date,
	DATEDIFF(DAY, o.Prev_order_date, o.OrderDate) AS days_gap
	FROM orders_gap o
	JOIN customers c
	ON o.CustomerID = c.CustomerID
	WHERE o.Prev_order_date IS NOT NULL
	AND DATEDIFF(DAY, o.Prev_order_date, o.OrderDate) >90;

--Find suppliers whose products have never been ordered

SELECT DISTINCT s.SupplierID,s.SupplierName
	FROM suppliers s
	WHERE NOT EXISTS(
	SELECT p.ProductID
	FROM Products p
	JOIN order_details od ON p.ProductID = od.ProductID
	WHERE p.SupplierID = s.SupplierID
	);

--Identify the most profitable supplier based on total revenue of their products

SELECT s.supplierID, s.supplierName,
	SUM(od.Quantity * od.UnitPrice) AS revenue
	FROM suppliers s
	JOIN Products p ON s.SupplierID = p.SupplierID
	JOIN order_details od ON p.ProductID = od.ProductID
	GROUP BY s.supplierID, s.supplierName
	ORDER BY revenue DESC;

--Find the top 3 employees (sales reps) who generated the highest total revenue in each year

WITH RankedEmployee AS(
	SELECT e.EmployeeID, e.emp_FullName,
	YEAR(o.orderDate) as order_year,
	ROUND(SUM(od.Quantity * od.UnitPrice),2) AS revenue
	FROM employees e
	JOIN orders o ON e.EmployeeID = o.EmployeeID
	JOIN order_details od ON od.OrderID = o.OrderID
	GROUP BY e.EmployeeID, e.emp_FullName,YEAR(o.orderDate) 
	)

SELECT * 
	FROM(
	SELECT employeeID,
	emp_FullName,
	order_year,
	revenue,
	RANK () OVER(PARTITION BY order_year ORDER BY revenue DESC) AS rank_in_year
	FROM RankedEmployee
	) ranked
	WHERE rank_in_year <=3
	ORDER BY order_year, rank_in_year;

--customers who ordered last year but not this year

WITH last_year AS(
	SELECT DISTINCT customerID
	FROM orders
	WHERE YEAR(Orderdate) = YEAR(GETDATE()) - 1
),
	this_year AS(
	SELECT DISTINCT customerID
	FROM orders
	WHERE YEAR(OrderDate) = YEAR(GETDATE())
)
SELECT c.customerID, c.FirstName
	FROM customers c
	JOIN last_year l ON c.customerID = l.customerID
	LEFt JOIN this_year t ON c.customerId = t.customerID
	WHERE t.CustomerID IS NULL;


--Find the average order value per customer and their rank within their city

WITH Customers_avg AS(
	SELECT c.customerID,
	c.firstName,
	c.city,
	AVG(od.quantity * od.UnitPrice) as Avg_order_value
	FROM customers c
	JOIN orders o ON c.customerID = o.CustomerID
	JOIN order_details od ON o.OrderID = od.OrderID
	GROUP BY c.CustomerID, c.FirstName, c.City
	)

SELECT customerID,
	   firstName,
	   city,
	   RANK() OVER(PARTITION BY city ORDER BY Avg_order_value) as rnk
	   FROM Customers_avg
	   ORDER BY CustomerID, rnk;

--Find the most profitable product category per year

WITH category_revenue AS(
	SELECT P.Category, YEAR(o.OrderDate) as Order_year,
	SUM(od.Quantity * od.UnitPrice) as Revenue
	FROM Products p
	JOIN order_details od ON p.ProductID = od.ProductID
	JOIN  orders o ON od.OrderID = o.OrderID
	GROUP BY P.Category, YEAR(o.OrderDate)
	)
SELECT * FROM(
	SELECT Category,
	   Order_year,
	   revenue,
	   RANK() OVER (PARTITION BY Order_year ORDER BY Revenue DESC) AS Rank_in_year
	   FROM category_revenue
	) ranked
	WHERE Rank_in_year = 1
	ORDER BY Order_year;

--Find customers who upgraded their spending behavior 
--(Consider	average order value this year > 150% of last year’s average order value)

WITH yearly_customer_spend AS(
	SELECT c.CustomerID, 
	YEAR(o.OrderDate) AS order_year,
	ROUND(AVG(od.Quantity * od.UnitPrice),2) AS avg_order_value
	FROM customers c
	JOIN orders o on c.CustomerID = o.CustomerID
	JOIN order_details od on o.OrderID = od.OrderID
	GROUP BY c.CustomerID, YEAR(o.OrderDate)
	)
SELECT DISTINCT y1.CustomerID,
	   c.FirstName,
	   y1.avg_order_value AS Last_yeat_AOV,
	   y2.avg_order_value AS This_year_AOV
	   FROM yearly_customer_spend y1
	   JOIN yearly_customer_spend y2
	   ON y1.CustomerID = y2.CustomerId
	   AND y2.order_year = y1.order_year +1
	   JOIN customers c ON y1.CustomerID = c.CustomerID
	   WHERE y2.avg_order_value > 1.5 * y1.avg_order_value;

-- Sales performance tiers to employees (top 10% = Platinum, next 20% = Gold, rest = Silver)

WITH emp_revenue AS(
	SELECT e.employeeID,
	e.FirstName,
	SUM(od.Quantity * od.UnitPrice) AS total_revenue
	FROM employees e
	JOIN orders o ON e.EmployeeID= o.EmployeeID
	JOIN order_details od ON o.OrderID = od.OrderID
	GROUP BY e.employeeID, e.FirstName
),
Ranked AS(
	SELECT employeeID,
	Firstname,
	total_revenue,
	PERCENT_RANK() OVER (ORDER BY total_revenue DESC) AS rank_percent
	FROM emp_revenue
)
SELECT 
	employeeID,
	Firstname,
	total_revenue,
	CASE 
		WHEN rank_percent <= 0.1 THEN 'Platinum'
		WHEN rank_percent <= 0.3 THEN 'gold'

	ELSE 'Silver'
	END AS performence_tier
FROM Ranked
ORDER BY total_revenue DESC;