/*==========================================================================================
Using ALT+F1 to inspect items
==========================================================================================*/
-- Table
SELECT * 
FROM DimEmployee

-- View
SELECT TOP 10 * 
FROM [dbo].[V_CustomerOrders]

-- Stored procedure
EXEC [dbo].[P_FactSalesQuota]

/*==========================================================================================
Dry run your DELETE / UPDATE queries
==========================================================================================*/
-- UPDATE c SET 
SELECT c.*,
    FirstName = 'Elisabeth' 
FROM DimCustomer c

/*==========================================================================================
Familiarize yourself with execution plans
==========================================================================================*/
--CREATE INDEX IX_SalesOrderNumber ON dbo.FactOnlineSales(
--    SalesOrderNumber
--)
--GO

--CREATE INDEX IX_SalesOrderNumberWithCost ON dbo.FactOnlineSales(
--    SalesOrderNumber
--)
--INCLUDE(
--    TotalCost
--)
--GO


SELECT 
    fos.SalesOrderNumber,
    fos.TotalCost
FROM FactOnlineSales fos WITH (INDEX(PK_FactOnlineSales_SalesKey))
WHERE SalesOrderNumber IN ('20070101311332','20070101711340') 

SELECT 
    fos.SalesOrderNumber,
    fos.TotalCost
FROM FactOnlineSales fos WITH (INDEX(IX_SalesOrderNumber))
WHERE SalesOrderNumber IN ('20070101311332','20070101711340')

SELECT 
    fos.SalesOrderNumber,
    fos.TotalCost
FROM FactOnlineSales fos WITH (INDEX(IX_SalesOrderNumberWithCost))
WHERE SalesOrderNumber IN ('20070101311332','20070101711340')

/*==========================================================================================
Use CONCAT instead of + ''
==========================================================================================*/

-- Part 1
DECLARE @__ResultCount BIGINT
DECLARE @__Seed BIGINT = DATEDIFF(s, '1970-01-01 00:00:00', SYSDATETIME())
DECLARE @__Rand INT = CAST(RIGHT(CAST(RAND(@__Seed) AS VARCHAR(200)), 2) AS INT)

SELECT 
    *, 
    Rownum = ROW_NUMBER() OVER (ORDER BY SalesKey)
FROM FactSales
WHERE SalesKey <= @__Rand


PRINT 'Rows Selected: ' + @__ResultCount
GO

-- Part 2
DECLARE @__ResultCount BIGINT
DECLARE @__Seed BIGINT = DATEDIFF(s, '1970-01-01 00:00:00', SYSDATETIME())
DECLARE @__Rand INT = CAST(RIGHT(CAST(RAND(@__Seed) AS VARCHAR(200)), 2) AS INT)

SELECT 
    *, 
    Rownum = ROW_NUMBER() OVER (ORDER BY SalesKey)
FROM FactSales
WHERE SalesKey <= @__Rand


PRINT 'Rows Selected: ' + CAST(@__ResultCount AS VARCHAR(100))
GO


-- Part 3
DECLARE @__ResultCount BIGINT
DECLARE @__Seed BIGINT = DATEDIFF(s, '1970-01-01 00:00:00', SYSDATETIME())
DECLARE @__Rand INT = CAST(RIGHT(CAST(RAND(@__Seed) AS VARCHAR(200)), 2) AS INT)

SELECT 
    *, 
    Rownum = ROW_NUMBER() OVER (ORDER BY SalesKey)
FROM FactSales
WHERE SalesKey <= @__Rand

PRINT CONCAT('Rows Selected: ', @__ResultCount)

/*==========================================================================================
CAST as XML for large results you want to inspect
==========================================================================================*/

SELECT TOP 10 ProductName, CAST(CONCAT('<![CDATA[', ProductName, ']]>') AS XML) ProductNameAsXML
FROM DimProduct
ORDER BY LEN(ProductName) DESC



/*==========================================================================================
Drag n' Drop Some Things
==========================================================================================*/

SELECT *
FROM DimCustomer

SELECT
    [CustomerKey], [GeographyKey], [CustomerLabel], [Title], [FirstName], [MiddleName], [LastName], [NameStyle], [BirthDate], [MaritalStatus], [Suffix], [Gender], [EmailAddress], [YearlyIncome], [TotalChildren], [NumberChildrenAtHome], [Education], [Occupation], [HouseOwnerFlag], [NumberCarsOwned], [AddressLine1], [AddressLine2], [Phone], [DateFirstPurchase], [CustomerType], [CompanyName], [ETLLoadID], [LoadDate], [UpdateDate]
FROM DimCustomer


/*==========================================================================================
WHERE 1=0 Magic
==========================================================================================*/
DROP TABLE IF EXISTS dbo._DimCustomerCleansing

SELECT 
    IsCleansed = CAST(NULL AS BIT), 
    * 
INTO dbo._DimCustomerCleansing 
FROM DimCustomer
WHERE 1=0



/*==========================================================================================
UNION vs UNION ALL
==========================================================================================*/
-- UNION 
SELECT
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'DimCustomer'

UNION 

SELECT
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = '_DimCustomerCleansing'





-- UNION ALL 

SELECT
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'DimCustomer'

UNION ALL

SELECT
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = '_DimCustomerCleansing'



-- Compared execution plans
SELECT
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM (
    SELECT
        COLUMN_NAME,
        IS_NULLABLE,
        DATA_TYPE,
        CHARACTER_MAXIMUM_LENGTH
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE 
        TABLE_SCHEMA = 'dbo' 
        AND TABLE_NAME = 'DimCustomer'

    UNION ALL

    SELECT
        COLUMN_NAME,
        IS_NULLABLE,
        DATA_TYPE,
        CHARACTER_MAXIMUM_LENGTH
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE 
        TABLE_SCHEMA = 'dbo' 
        AND TABLE_NAME = '_DimCustomerCleansing'
)x
GROUP BY
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH



/*==========================================================================================
INTERSECT
==========================================================================================*/

SELECT
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'DimCustomer'

INTERSECT

SELECT
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = '_DimCustomerCleansing'


-- Naive implementation....AND WRONG
SELECT 
    DimCustomer.COLUMN_NAME,
    DimCustomer.IS_NULLABLE,
    DimCustomer.DATA_TYPE,
    DimCustomer.CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS DimCustomer
    JOIN INFORMATION_SCHEMA.COLUMNS DimCustomerCleansing
        ON DimCustomerCleansing.TABLE_SCHEMA = 'dbo'
        AND DimCustomerCleansing.TABLE_NAME = '_DimCustomerCleansing'
        AND DimCustomerCleansing.COLUMN_NAME = DimCustomer.COLUMN_NAME
        AND DimCustomerCleansing.IS_NULLABLE = DimCustomer.IS_NULLABLE
        AND DimCustomerCleansing.DATA_TYPE = DimCustomer.DATA_TYPE
        AND DimCustomerCleansing.CHARACTER_MAXIMUM_LENGTH = DimCustomer.CHARACTER_MAXIMUM_LENGTH
WHERE 
    DimCustomer.TABLE_SCHEMA = 'dbo' 
    AND DimCustomer.TABLE_NAME = 'DimCustomer'


-- Naive Implementation but at least it's right this time!!!!
SELECT 
    DimCustomer.COLUMN_NAME,
    DimCustomer.IS_NULLABLE,
    DimCustomer.DATA_TYPE,
    DimCustomer.CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS DimCustomer
    JOIN INFORMATION_SCHEMA.COLUMNS DimCustomerCleansing
        ON DimCustomerCleansing.TABLE_SCHEMA = 'dbo'
        AND DimCustomerCleansing.TABLE_NAME = '_DimCustomerCleansing'
        AND ISNULL(DimCustomerCleansing.COLUMN_NAME, '') = ISNULL(DimCustomer.COLUMN_NAME, '')
        AND ISNULL(DimCustomerCleansing.IS_NULLABLE, '') = ISNULL(DimCustomer.IS_NULLABLE, '')
        AND ISNULL(DimCustomerCleansing.DATA_TYPE, '') = ISNULL(DimCustomer.DATA_TYPE, '')
        AND ISNULL(DimCustomerCleansing.CHARACTER_MAXIMUM_LENGTH, '') = ISNULL(DimCustomer.CHARACTER_MAXIMUM_LENGTH, '')
WHERE 
    DimCustomer.TABLE_SCHEMA = 'dbo' 
    AND DimCustomer.TABLE_NAME = 'DimCustomer'



-- Performance comparison - run with one above

SELECT
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'DimCustomer'

INTERSECT

SELECT
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = '_DimCustomerCleansing'



/*==========================================================================================
EXCEPT
==========================================================================================*/
-- Hmmmm.....
SELECT
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'DimCustomer'

EXCEPT

SELECT
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = '_DimCustomerCleansing'



-- That's more like it....
SELECT
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = '_DimCustomerCleansing'

EXCEPT

SELECT
    COLUMN_NAME,
    IS_NULLABLE,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE 
    TABLE_SCHEMA = 'dbo' 
    AND TABLE_NAME = 'DimCustomer'




-- How I've found it useful

SELECT * FROM (
    SELECT
        RESULTSET = 'In DimCustomer_Not_DimCustomerCleansing',
        COLUMN_NAME,
        IS_NULLABLE,
        DATA_TYPE,
        CHARACTER_MAXIMUM_LENGTH
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE 
        TABLE_SCHEMA = 'dbo' 
        AND TABLE_NAME = 'DimCustomer'

    EXCEPT

    SELECT
        RESULTSET = 'In DimCustomer_Not_DimCustomerCleansing',
        COLUMN_NAME,
        IS_NULLABLE,
        DATA_TYPE,
        CHARACTER_MAXIMUM_LENGTH
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE 
        TABLE_SCHEMA = 'dbo' 
        AND TABLE_NAME = '_DimCustomerCleansing'
)x1


    UNION ALL 

SELECT * FROM (
    SELECT
        RESULTSET = 'In DimCustomerCleansing_Not_DimCustomer',
        COLUMN_NAME,
        IS_NULLABLE,
        DATA_TYPE,
        CHARACTER_MAXIMUM_LENGTH
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE 
        TABLE_SCHEMA = 'dbo' 
        AND TABLE_NAME = '_DimCustomerCleansing'

    EXCEPT

    SELECT
        RESULTSET = 'In DimCustomerCleansing_Not_DimCustomer',
        COLUMN_NAME,
        IS_NULLABLE,
        DATA_TYPE,
        CHARACTER_MAXIMUM_LENGTH
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE 
        TABLE_SCHEMA = 'dbo' 
        AND TABLE_NAME = 'DimCustomer'
)x2 



/*==========================================================================================
ORDER BY Randomness
==========================================================================================*/

SELECT TOP 100 *
FROM DimCustomer
ORDER BY NEWID()


/*==========================================================================================
Use the Designer...
==========================================================================================*/

SELECT 
    DimCustomer.COLUMN_NAME,
    DimCustomer.IS_NULLABLE,
    DimCustomer.DATA_TYPE,
    DimCustomer.CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS DimCustomer
    JOIN INFORMATION_SCHEMA.COLUMNS DimCustomerCleansing
        ON DimCustomerCleansing.TABLE_SCHEMA = 'dbo'
        AND DimCustomerCleansing.TABLE_NAME = '_DimCustomerCleansing'
        AND ISNULL(DimCustomerCleansing.COLUMN_NAME, '') = ISNULL(DimCustomer.COLUMN_NAME, '')
        AND ISNULL(DimCustomerCleansing.IS_NULLABLE, '') = ISNULL(DimCustomer.IS_NULLABLE, '')
        AND ISNULL(DimCustomerCleansing.DATA_TYPE, '') = ISNULL(DimCustomer.DATA_TYPE, '')
        AND ISNULL(DimCustomerCleansing.CHARACTER_MAXIMUM_LENGTH, '') = ISNULL(DimCustomer.CHARACTER_MAXIMUM_LENGTH, '')
WHERE 
    DimCustomer.TABLE_SCHEMA = 'dbo' 
    AND DimCustomer.TABLE_NAME = 'DimCustomer'




-- docker run --name dockerdemo --rm -p 1550:1433 -v "D:\Development\SQLMeetup\ContosoRetailDW.bak":/var/opt/mssql/data/ContosoRetailDW.bak -e ACCEPT_EULA=Y -e SA_PASSWORD="c0dingbl0cks!" -e MSSQL_PID="Developer" mcr.microsoft.com/mssql/server:2017-CU14-ubuntu