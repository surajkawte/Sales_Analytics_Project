--Script to load all the csv files manually into SQL 
--------------------------------------------------------
-- Customers
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(100),
    ContactName NVARCHAR(100),
    Country NVARCHAR(50)
);

-- Employees
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    emp_FullName NVARCHAR(100),
    DepartmentID INT,
    JobTitle NVARCHAR(50),
    HireDate DATE
);

-- Departments
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName NVARCHAR(50)
);

-- Suppliers
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY,
    SupplierName NVARCHAR(100),
    ContactName NVARCHAR(100),
    Country NVARCHAR(50)
);

-- Products
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    SupplierID INT,
    UnitPrice DECIMAL(10,2)
);

-- Orders
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATE,
    PaymentMethod NVARCHAR(50)
);

-- OrderDetails
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2)
);

-- Payments
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY,
    OrderID INT,
    PaymentDate DATE,
    PaymentAmount DECIMAL(10,2),
    PaymentMethod NVARCHAR(50)
);

-------------------------------------------
--Script to insert the data into created tables
--Note: Please replace the path to your local path where files are stored

-- Load Customers
BULK INSERT Customers
FROM 'C:\Path\To\CSV\Customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- Load Orders
BULK INSERT Orders
FROM 'C:\Path\To\CSV\Orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- Load OrderDetails
BULK INSERT OrderDetails
FROM 'C:\Path\To\CSV\OrderDetails.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- Load Products
BULK INSERT Products
FROM 'C:\Path\To\CSV\Products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- Load Suppliers
BULK INSERT Suppliers
FROM 'C:\Path\To\CSV\Suppliers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- Load Employees
BULK INSERT Employees
FROM 'C:\Path\To\CSV\Employees.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- Load Departments
BULK INSERT Departments
FROM 'C:\Path\To\CSV\Departments.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- Load Payments
BULK INSERT Payments
FROM 'C:\Path\To\CSV\Payments.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);
