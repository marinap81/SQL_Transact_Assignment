--STUDENT NUMBER 103340660
--STUDENT NAME MARINA PAJVANCIC XX
--USE test123;
--SELECT * FROM INFORMATION_SCHEMA.TABLES /*table catalog*/
--select name, modify_date from sys.procedures; /*displays list of stored procedures*/
GO
DROP PROCEDURE IF EXISTS ADD_CUSTOMER;
DROP PROCEDURE IF EXISTS DELETE_ALL_CUSTOMERS;
DROP PROCEDURE  IF EXISTS ADD_PRODUCT;
DROP PROCEDURE IF EXISTS DELETE_ALL_PRODUCTS;
DROP PROCEDURE IF EXISTS GET_CUSTOMER_STRING;
DROP PROCEDURE  IF EXISTS UPD_CUST_SALESYTD;
DROP PROCEDURE  IF EXISTS GET_PROD_STRING;
DROP PROCEDURE  IF EXISTS UPD_PROD_SALESYTD;
DROP PROCEDURE IF EXISTS UPD_CUSTOMER_STATUS;
DROP PROCEDURE IF EXISTS ADD_SIMPLE_SALE;
DROP PROCEDURE IF EXISTS SUM_CUSTOMER_SALESYTD;
DROP PROCEDURE IF EXISTS SUM_PRODUCT_SALESYTD;
DROP PROCEDURE IF EXISTS GET_ALL_CUSTOMERS;
DROP PROCEDURE IF EXISTS GET_ALL_PRODUCTS;
DROP PROCEDURE IF EXISTS ADD_LOCATION;
DROP PROCEDURE IF EXISTS ADD_COMPLEX_SALE;
DROP PROCEDURE IF EXISTS GET_ALLSALES;
DROP PROCEDURE IF EXISTS COUNT_PRODUCT_SALES;
DROP PROCEDURE IF EXISTS DELETE_SALE;
DROP PROCEDURE IF EXISTS DELETE_ALL_SALES;
DROP PROCEDURE IF EXISTS DELETE_CUSTOMER;
DROP PROCEDURE IF EXISTS DELETE_PRODUCT;
GO

CREATE PROCEDURE ADD_CUSTOMER @PCUSTID INT, @PCUSTNAME NVARCHAR(100) AS

BEGIN
    BEGIN TRY

        IF @PCUSTID < 1 OR @PCUSTID > 499
            THROW 50020, 'Customer ID out of range', 1 /*if out of range it'll throw error linked to error num in catch*/
                                                    /*Otherwise if inside range it'll insert values*/
        INSERT INTO CUSTOMER (CUSTID, CUSTNAME, SALES_YTD, STATUS) 
        VALUES (@PCUSTID, @PCUSTNAME, 0, 'OK'); /*parameters are variables, executed when procedure called*/
    END TRY

    BEGIN CATCH /*catches error & provides feedback, within this block checks what error it is and updates user*/
        if ERROR_NUMBER() = 2627 /*customer error not system error, unrelated to try block*/
            THROW 50010, 'Duplicate customer ID', 1
        ELSE IF ERROR_NUMBER() = 50020 /*system error*/
            THROW /*this will pass the error msg and description in try block*/
        ELSE /*any other error that may occur*/
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE(); /*useful for more than one line of code*/
                THROW 50000, @ERRORMESSAGE, 1 /*this customises the error msg from system noted above so its readable=ERROR_MESSAGE();*/
            END; 
    END CATCH;
END;
GO

CREATE PROCEDURE DELETE_ALL_CUSTOMERS AS
BEGIN 
DELETE FROM CUSTOMER;
PRINT (CONCAT('NUMBER OF ROWS AFFECTED ', @@ROWCOUNT));
END;
GO

CREATE PROCEDURE ADD_PRODUCT @pprodid INT, @pprodname nvarchar(100), @pprice money AS
BEGIN
    BEGIN TRY

        IF @pprodid < 1000 OR @pprodid > 2500
            THROW 50040, 'Product ID out of range', 1 

        ELSE IF @pprice < 0 OR @pprice > 999.99
            THROW 50050, 'Price out of range', 1

        ELSE 

            INSERT INTO PRODUCT (PRODID, PRODNAME,SELLING_PRICE, SALES_YTD) 
            VALUES (@pprodid, @pprodname, @pprice, 0);
    END TRY

BEGIN CATCH

     IF ERROR_NUMBER() = 2627 
      THROW 50030, 'Duplicate product ID', 1
        ELSE
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END; 
    END CATCH;
    END;
GO

CREATE PROCEDURE DELETE_ALL_PRODUCTS AS
BEGIN 
DELETE FROM PRODUCT;
RETURN @@ROWCOUNT;
END;

GO

CREATE PROCEDURE GET_CUSTOMER_STRING @PCUSTID INT, @PReturnString NVARCHAR(100) OUTPUT AS 
BEGIN 

    BEGIN TRY
DECLARE @PCUSTNAME NVARCHAR(100), @STATUS NVARCHAR(7), @YTD MONEY; /*declaring further variables*/
SELECT @PCUSTNAME = CUSTNAME, @STATUS = [STATUS], @YTD = SALES_YTD /*assigning the 3 above variables*/
FROM CUSTOMER
WHERE CUSTID = @PCUSTID

   IF @@ROWCOUNT = 0 
    THROW 50060, 'Customer ID not found', 1

    SET @PReturnString = CONCAT ('CustId: ', @PCUSTID, ' Name: ', @PCUSTNAME,' status: ', @STATUS, ' SalesYTD: ',@YTD);
    /*return string only assigned if data is found, if rowcount = 0 then not executed*/
    END TRY

        BEGIN CATCH
        IF ERROR_NUMBER() IN (50060) 
            THROW /*takes msg and passes it on*/
        ELSE
    BEGIN
    DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE(); /*ERROR_MESSAGE() is called & set into var @errormessage*/
    THROW 50000, @ERRORMESSAGE, 1   /*deals with error 50060 and what to output*/
    END;
        END CATCH;
    END;
    GO

CREATE PROCEDURE UPD_CUST_SALESYTD @PCUSTID INT, @PAMT MONEY AS 
BEGIN

BEGIN TRY 

    DECLARE @CUST_CNT INT;
    SELECT @CUST_CNT = COUNT(*) FROM CUSTOMER WHERE CUSTID = @PCUSTID
        IF (@CUST_CNT = 0) 
            THROW 50070, 'Customer ID not found',1
    
        ELSE IF @PAMT <-999.99 or @PAMT > 999.99 
           THROW 50080, 'Amount out of range', 1

    UPDATE CUSTOMER SET SALES_YTD += @PAMT WHERE CUSTID = @PCUSTID; -- changed order so testing occurs first
    END TRY

BEGIN CATCH
   
    IF ERROR_NUMBER() IN (50070,50080)
       THROW --pass error msg and description in try block*/
    
    ELSE 
        BEGIN
         DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
         THROW 50000, @ERRORMESSAGE, 1
         END;
   END CATCH;
    END; 
GO
CREATE PROCEDURE GET_PROD_STRING @pprodid INT, @pReturnString NVARCHAR(1000) OUTPUT AS /*RString OUT Parameter*/
BEGIN 

    BEGIN TRY
    DECLARE @Name NVARCHAR(100), @Price MONEY, @Sales MONEY      /*declaring further variables*/
   

    SELECT @Name = PRODNAME, @Price = SELLING_PRICE, @Sales = SALES_YTD   /*Assigning */
    FROM PRODUCT
    WHERE PRODID = @pprodid

            IF @@ROWCOUNT = 0
            THROW 50090, 'Product ID not found', 1

    SET @PReturnString = CONCAT('Prodid:  ', @pprodid, ' Name: ', @Name,' Price: ', @Price, ' Sales: ',@Sales);
    END TRY

    BEGIN CATCH
        IF ERROR_NUMBER() IN (50090)
            THROW
        ELSE
            BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE(); /*ERROR_MESSAGE() called & set into var @errormessage*/
            THROW 50000, @ERRORMESSAGE, 1  /*deals with error 50090*/
            END;                         
    END CATCH;
END;
GO
CREATE PROCEDURE UPD_PROD_SALESYTD @pprodid INT, @pamt MONEY AS
BEGIN
    BEGIN TRY
        
            DECLARE @PROD_CNT INT;
            SELECT @PROD_CNT = COUNT(*) FROM PRODUCT WHERE PRODID = @pprodid;
            IF (@PROD_CNT = 0)                
            THROW 50100, 'Product ID not found', 1 

             IF @pamt < -999.99 OR @pamt > 999.99 
            THROW 50110, 'Amount out of range', 1

            UPDATE PRODUCT SET SALES_YTD += @pamt WHERE PRODID = @pprodid   

    END TRY

        BEGIN CATCH
         IF ERROR_NUMBER() IN (50110,50100)
            THROW
        ELSE
            BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE(); 
            THROW 50000, @ERRORMESSAGE, 1  
     
            END;                         
    END CATCH;
END;
GO

CREATE PROCEDURE UPD_CUSTOMER_STATUS @pcustid INT, @pstatus NVARCHAR(7) AS 
BEGIN 
    BEGIN TRY

            IF (@pstatus NOT IN ('OK','SUSPEND'))
        THROW 50130, 'Invalid Status value', 1
    
        UPDATE CUSTOMER SET STATUS = @pstatus WHERE CUSTID = @pcustid 
            
            IF @@ROWCOUNT = 0
            THROW 50120, 'Customer ID not found', 1
    END TRY

    BEGIN CATCH
        IF ERROR_NUMBER() IN (50130, 50120)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE(); 
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;
/*Procedure 10*/
--Check if customer status is 'OK'. If not raise an exception.
--Check if quantity value is valid. If not raise an exception.
--Update both the Customer (customer table) and Product SalesYTD (product table) values 
--Note: 
--The YTD values must be increased by pqty * the product price
--@pqty = sales quantity 
--@prodprice = product price
--Calls UPD_CUST_SALESYTD  and UPD_PROD_SALES_YTD

GO
CREATE PROCEDURE ADD_SIMPLE_SALE @pcustid INT, @pprodid  INT, @pqty INT AS 
BEGIN

    BEGIN TRY
    DECLARE @prodprice MONEY, @NEWYTDVALUE MONEY /*@prodprice = selling price in product table*/
            
    SELECT @prodprice = SELLING_PRICE, @NEWYTDVALUE = SALES_YTD 
    FROM PRODUCT
    WHERE PRODID = @pprodid

    SET @NEWYTDVALUE  = @pqty*@prodprice


    IF ((SELECT STATUS FROM CUSTOMER WHERE CUSTID = @pcustid) NOT IN ('OK'))
        THROW 50150, 'Customer status is not OK', 1

    DECLARE @CUST_CNT INT;
    SELECT @CUST_CNT = COUNT(*) FROM CUSTOMER WHERE CUSTID = @pcustid ;

        IF (@CUST_CNT  = 0)
        THROW 50160, 'Customer ID not found', 1            

        IF @pqty < 1 OR @pqty > 999
        THROW 50140, 'Sale Quantity outside valid range', 1

        EXEC UPD_CUST_SALESYTD @pcustid = @pcustid, @PAMT = @NEWYTDVALUE /*@pmt used from called procedure to set current parameter*/
        EXEC UPD_PROD_SALESYTD @pprodid = @pprodid, @PAMT = @NEWYTDVALUE /*@pmt used from called procedure to set current parameter*/

         END TRY

    BEGIN CATCH
        if ERROR_NUMBER() IN (50150, 50160, 50140, 50170)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;
GO

CREATE PROCEDURE SUM_CUSTOMER_SALESYTD AS 
BEGIN 
BEGIN TRY

SELECT CAST (SUM(SALES_YTD) AS INT) FROM CUSTOMER AS total
END TRY

    BEGIN CATCH
        IF ERROR_NUMBER() IN (50070,50080) /*ADDED SAMER ERROR NUMBERS AS UPDATE CUST SALES*/
       THROW --pass error msg and description in try block*/
    
    ELSE 
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;

GO

CREATE PROCEDURE SUM_PRODUCT_SALESYTD AS 
BEGIN 
BEGIN TRY

SELECT CAST (SUM(SALES_YTD) AS INT) FROM PRODUCT AS total
END TRY
  BEGIN CATCH
         IF ERROR_NUMBER() IN (50110,50100) /*ADDED SAMER ERROR NUMBERS AS UPDATE PRODUCT SALES*/
            THROW
        ELSE
            BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE(); 
            THROW 50000, @ERRORMESSAGE, 1  
     
            END;                         
    END CATCH;
END;


/*Procedure 13*/
--***Get all customer details and return as a SYS_REFCURSOR 

--https://www.sqlservertutorial.net/sql-server-stored-procedures/sql-server-cursor/

GO

CREATE PROCEDURE GET_ALL_CUSTOMERS @pOutCur CURSOR VARYING OUTPUT AS
BEGIN 
    BEGIN TRY
    SET @pOutCur = CURSOR 
    FORWARD_ONLY STATIC FOR
    SELECT * FROM CUSTOMER;
    OPEN @pOutCur;
    END TRY  

    BEGIN CATCH
    DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;
GO
/*https://docs.microsoft.com/en-us/sql/relational-databases/stored-procedures/return-data-from-a-stored-procedure?view=sql-server-ver15*/
CREATE PROCEDURE GET_ALL_PRODUCTS @pOutCur CURSOR VARYING OUTPUT AS

BEGIN 
BEGIN TRY
   
    SET @pOutCur = CURSOR 
    FORWARD_ONLY STATIC FOR
    SELECT * FROM PRODUCT;      /*enter statement which @pOutCur will get info from*/     
    OPEN @pOutCur;
    END TRY
       BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
        THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
END;
GO
/*Procedure 15*/
--Add a new row to the location table
CREATE PROCEDURE ADD_LOCATION @ploccode NVARCHAR(5), @pminqty INT, @pmaxqty INT AS
BEGIN
BEGIN TRY
        SELECT @ploccode = LOCID, @pminqty = MINQTY, @pmaxqty = MAXQTY /*assigning variables, set on exec*/
        FROM [LOCATION]
        WHERE LOCID = @ploccode

        IF LEN(@ploccode) <> 5
        THROW 50190, 'Location Code length invalid', 1

        IF @pminqty < 0 or @pminqty > 999
        THROW 50200, 'Minimum Qty out of range', 1

        IF @pmaxqty < 0 or @pmaxqty > 999
        THROW 50210, 'Maximum Qty out of range', 1

        IF  @pminqty >= @pmaxqty /*Throws error if minqty is larger*/
        THROW 50220, 'Minimum Qty larger than Maximum Qty', 1 

        INSERT INTO [LOCATION](LOCID,MINQTY,MAXQTY)
        VALUES (@ploccode, @pminqty, @pmaxqty)

        END TRY
            BEGIN CATCH
 
                IF ERROR_NUMBER() = 2627 
            THROW 50180, 'Duplicate location ID', 1

            IF ERROR_NUMBER() in (50190, 50200, 50210, 50220)
            THROW

    DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
    END CATCH;
    END;
    GO

    CREATE PROCEDURE ADD_COMPLEX_SALE @pcustid INT, @pprodid INT, @pqty INT, @pdate NVARCHAR(100) AS
    BEGIN
    BEGIN TRY
             DECLARE @prodprice MONEY, @NEWYTDAMOUNT MONEY /*@prodprice = selling price in product table*/
                 
            SELECT @prodprice = SELLING_PRICE, @NEWYTDAMOUNT = SALES_YTD 
            FROM PRODUCT
            WHERE PRODID = @pprodid

            SET @NEWYTDAMOUNT  = @pqty * @prodprice /*@NEWYTDAMOUNT = SALE TABLE*/

                DECLARE @PROD_CNT INT;
                SELECT @PROD_CNT = COUNT(*) FROM PRODUCT WHERE PRODID = @pprodid;

                 IF ( @PROD_CNT = 0 )
                THROW 50270, 'Product ID not found', 1

                IF ((SELECT STATUS FROM CUSTOMER WHERE CUSTID = @pcustid) NOT IN ('OK'))
                THROW 50240, 'Customer status is not OK', 1

                DECLARE @IS_DATE_VALID INT;
                SELECT @IS_DATE_VALID = ISDATE(@pdate);
                IF ( @IS_DATE_VALID = 0 )
                THROW 50250, 'Date not valid', 1

                DECLARE @CUST_CNT INT;
                SELECT @CUST_CNT = COUNT(*) FROM CUSTOMER WHERE CUSTID = @pcustid;

                IF (@CUST_CNT = 0 )
                THROW 50260, 'Customer ID not found', 1

                IF @pqty < 1 OR @pqty > 999
                THROW 50230, 'Sale Quantity outside valid range', 1

        EXEC UPD_CUST_SALESYTD @pcustid = @pcustid, @PAMT = @NEWYTDAMOUNT /*@pmt from referenced procedure to set current parameter*/
        EXEC UPD_PROD_SALESYTD @pprodid = @pprodid, @PAMT = @NEWYTDAMOUNT /*@pmt from referenced procedure to set current parameter*/

        DECLARE @MY_NEXT_SALEID BIGINT; 
        SELECT @MY_NEXT_SALEID = NEXT VALUE FOR SALE_SEQ;

        INSERT INTO SALE
        (SALEID,  CUSTID, PRODID, QTY, PRICE, SALEDATE)
         VALUES
        (@MY_NEXT_SALEID, @pcustid, @pprodid, @pqty, @prodprice,
         CAST(@pdate as DATE) )

        END TRY

        BEGIN CATCH
        if ERROR_NUMBER() IN (50230, 50240, 50250, 50260, 50270)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;
END;
GO
/*Procedure 17*/
--Get all sales details and assign to pOutCur
CREATE PROCEDURE GET_ALLSALES @pOutCur CURSOR VARYING OUTPUT AS
BEGIN 
    BEGIN TRY
    SET @pOutCur = CURSOR 
    FORWARD_ONLY STATIC FOR
    SELECT * FROM SALE;
    OPEN @pOutCur;
    END TRY  

    BEGIN CATCH
    DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1

    END CATCH;
END;
GO

CREATE PROCEDURE COUNT_PRODUCT_SALES @pdays INT, @returnCount INT OUTPUT AS /*@returnCount is assigned in anon block*/
BEGIN 
            BEGIN TRY
            SELECT COUNT(SALEID) FROM SALE
            WHERE SALEDATE >= (GETDATE()-@pdays)
            END TRY

        BEGIN CATCH
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
        END CATCH;
END;

GO
/*This function must return the SaleID value of the Sale row that was deleted.*/

CREATE PROCEDURE DELETE_SALE @psaleID BIGINT OUTPUT AS
BEGIN
    BEGIN TRY

            DECLARE @PPRICE MONEY, @PQTY INT, @UpdatesSalesYTD MONEY 
            DECLARE @CustID INT, @ProdID INT;
    
            SELECT @psaleID = MIN(SALEID) FROM SALE

            IF ( @psaleID IS NULL )
                THROW 50280, 'No Sale Rows Found',1

            SELECT @UpdatesSalesYTD = PRICE*QTY*-1, @CustID=CUSTID, @ProdID=PRODID
            FROM SALE
            WHERE SALEID = @psaleID

            IF @@ROWCOUNT = 0
                THROW 50999, 'Sale ID Not Found',1

            DELETE FROM SALE WHERE SALEID = @psaleID

            EXEC UPD_CUST_SALESYTD @pcustid = @CustID, @PAMT = @UpdatesSalesYTD
            EXEC UPD_PROD_SALESYTD @pprodid = @prodID, @PAMT = @UpdatesSalesYTD 
 
    END TRY
        BEGIN CATCH
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
        END CATCH;
END;

GO

CREATE PROCEDURE DELETE_ALL_SALES AS BEGIN
BEGIN TRY

update customer set sales_ytd = 0; 
update product set sales_ytd = 0;

DELETE FROM SALE;
RETURN @@ROWCOUNT;

END TRY
        BEGIN CATCH
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
        END CATCH;

END;

/*Procedure 21*/
---Delete a row from the Customer table
--Delete a customer with a matching customer id. If ComplexSales exist for the customer, 
--replace the default error code with a custom made exception to handle this error & raise the exception below
-- No matching customer id found50290. 
-- Customer ID not found
-- Customer has child complexsales  150300. 
-- SELECT Customer cannot be deleted as sales exist


GO
CREATE PROCEDURE DELETE_CUSTOMER @pCustid INT AS
BEGIN
    BEGIN TRY

        DECLARE @IS_CUSTFOUND INT
        DECLARE @SALES_RECORDS INT

        SELECT @IS_CUSTFOUND=CUSTID
        FROM CUSTOMER WHERE CUSTID = @pCustid


        IF( @IS_CUSTFOUND IS NULL)
            THROW 50290, 'Customer ID not found', 1

        SELECT @SALES_RECORDS=COUNT(CUSTID) FROM SALE WHERE CUSTID = @pCustid

        IF(@SALES_RECORDS>0 )
           THROW 50300, 'Customer cannot be deleted as sales exist', 1 

        DELETE FROM CUSTOMER WHERE CUSTID=@pCustid;
        
    END TRY

    BEGIN CATCH
    IF ERROR_NUMBER() IN (50290,50300)
        THROW
    ELSE
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END; 
    END CATCH;
END;

/*Procedure 22*/
--Delete a product with a matching Product id
--If ComplexSales exist for the customer, Oracle would normally generate a 'Child Recorddc b Found' error (error code -2292).
--Instead,Create a custom made exception to handle this error
--50000.  Use value of error_message()
-- 50310. Product ID not found
-- 50320. Product cannot be deleted as sales exist

GO
CREATE PROCEDURE DELETE_PRODUCT @pprodid INT AS
BEGIN
    BEGIN TRY

        DECLARE @IS_PRODFOUND INT
        DECLARE @SALES_RECORDS INT

        SELECT @IS_PRODFOUND=PRODID 
        FROM PRODUCT WHERE PRODID = @pprodid

        IF( @IS_PRODFOUND IS NULL)
            THROW 50310, 'Product ID not found', 1

        SELECT @SALES_RECORDS=COUNT(PRODID) FROM SALE WHERE PRODID = @pprodid

        IF(@SALES_RECORDS>0 )
           THROW 50320, 'Product cannot be deleted as sales exist', 1 

        DELETE FROM PRODUCT WHERE PRODID=@pprodid;
        END TRY

    BEGIN CATCH
    IF ERROR_NUMBER() IN (50310,50320)
        THROW
    ELSE
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END; 
    END CATCH;
END;
GO
--************************************END

--***EXECUTION OF PROCEDURES****
--select * from sale;
EXEC DELETE_ALL_SALES;
EXEC DELETE_ALL_PRODUCTS; /*Unable to delete if sales exist*/
EXEC DELETE_ALL_CUSTOMERS; /*Unable to delete if sales exist*/

GO
--EXEC ADD_CUSTOMER @pcustid = 450, @pcustname = 'testdude0';
EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude2';
EXEC ADD_CUSTOMER @pcustid = 200, @pcustname = 'testdude4'; /*added*/
EXEC ADD_CUSTOMER @pcustid = 400, @pcustname = 'testdude0'; /*added*/
EXEC ADD_CUSTOMER @pcustid = 250, @pcustname = 'testdude1'; /*added*/

EXEC ADD_CUSTOMER @pcustid = 5, @pcustname = 'Karen';
EXEC ADD_CUSTOMER @PCUSTID = 300, @PCUSTNAME = 'Marina';

GO
EXEC ADD_PRODUCT @pprodid = 1001, @pprodname = 'SmartWatch', @pprice = 50.00;
EXEC ADD_PRODUCT @pprodid = 2051, @pprodname = 'MobilePhone', @pprice = 850.00;
EXEC ADD_PRODUCT @pprodid = 1500, @pprodname = 'Laptop', @pprice = 650.00;

EXEC ADD_PRODUCT @pprodid = 1400, @pprodname = 'Remote Control', @pprice = 100.00;

    /*anonymous block for Get_Customer_String
    BEGIN
    DECLARE @OUTPUTVALUE NVARCHAR(100)
  
    EXEC GET_CUSTOMER_STRING @PCUSTID = 1, @PReturnString = @OUTPUTVALUE OUTPUT;
    PRINT(@OUTPUTVALUE)
    END;
 */

--EXEC UPD_CUST_SALESYTD  @PCUSTID = 55551, @PAMT = 150;
--EXEC UPD_CUST_SALESYTD  @PCUSTID = 400, @PAMT = 0; 
--EXEC UPD_CUST_SALESYTD @pcustid = 1, @PAMT = 100;

/*anonymous block for GET_PROD_STRING
GO
    BEGIN
    DECLARE @OUTPUTVALUE NVARCHAR(100)
  
    EXEC GET_PROD_STRING @pprodid = 1500, @pReturnString = @OUTPUTVALUE OUTPUT;
    PRINT(@OUTPUTVALUE)
    END; */ 

EXEC UPD_PROD_SALESYTD  @pprodid = 1500, @PAMT = 2;
EXEC UPD_PROD_SALESYTD  @pprodid = 1400, @PAMT = 2;


--EXEC UPD_CUSTOMER_STATUS @pcustid = 300, @pstatus = 'SUSPEND';
--EXEC UPD_CUSTOMER_STATUS @pcustid = 5, @pstatus = 'PENDING';

--EXEC ADD_SIMPLE_SALE @pcustid=200, @pprodid = 1500,  @pqty = 1;
--EXEC ADD_SIMPLE_SALE @pcustid=300, @pprodid = 1500,  @pqty = 1;
--EXEC ADD_SIMPLE_SALE @pcustid=1, @pprodid = 1500,  @pqty = 1;
--EXEC ADD_SIMPLE_SALE @pcustid=300, @pprodid = 1500,  @pqty = 1;
--select * from product;
--select * from customer;
--select * from sale;
--SELECT * FROM LOCATION;
--update customer set sales_ytd = 0;
--update product set sales_ytd = 0;

/*Procedure 8-CORRECTLY SET UP- ONLY SHOWS 1 ERROR MSG AND EXITS IF 2 INVALID PARAMATERS ARE ENTERED*/

--Update one product's sales_ytd value in the product table
--Change one product's SALES_YTD value by the pamt value. 
--SALESytd cannot go above 999.99
--FYI=error 'amount out of range' shows up but it still adds the out of range total to the sales ytd

EXEC SUM_CUSTOMER_SALESYTD;

EXEC SUM_PRODUCT_SALESYTD;
GO
/*anonymous block for Get_all_customers*/
BEGIN
DECLARE @CustOUT as CURSOR 
DECLARE @PID INT, @PPCUSTNAME NVARCHAR(100),@PPSALES MONEY, @PPSTATUS NVARCHAR(7)
EXEC GET_ALL_CUSTOMERS @pOutCur = @CustOUT OUTPUT;
FETCH NEXT FROM @CustOUT INTO @PID, @PPCUSTNAME, @PPSALES, @PPSTATUS; /*LIST ALL VARIABLES REPRESENTED IN COLUMNS*/
WHILE @@FETCH_STATUS = 0 
BEGIN 
PRINT CONCAT ('ID is ',@PID, 'name of customer ', @PPCUSTNAME, 'sales ', @PPSALES, 'status ', @PPSTATUS);
FETCH NEXT FROM @CustOUT INTO @PID, @PPCUSTNAME, @PPSALES, @PPSTATUS;
END

CLOSE @CustOUT;
DEALLOCATE @CustOUT;
END; 
GO
/*anonymous block for Get_all_products*/
/*https://stackoverflow.com/questions/54590125/sql-server-2014-create-procedure-with-cursor-output-parameter*/

BEGIN
       DECLARE @ProdOUT AS CURSOR
       DECLARE @prodid INT, @pprodname NVARCHAR(100), @SELLPRICE MONEY, @PSALES MONEY;
    EXEC GET_ALL_PRODUCTS @pOutCur = @ProdOUT OUTPUT;
FETCH NEXT FROM @ProdOUT INTO @prodid, @pprodname, @SELLPRICE, @PSALES;
WHILE @@FETCH_STATUS = 0 /*LOOP which goes through to get each row of data*/
BEGIN 
PRINT CONCAT (' ID is ',@prodid, ' name of product ', @pprodname, ' selling price ', @SELLPRICE, ' YTD_Sales ', @PSALES);
FETCH NEXT FROM @ProdOUT INTO @prodid, @pprodname, @SELLPRICE, @PSALES;
END

CLOSE @ProdOUT;
DEALLOCATE @ProdOUT;
END;

GO
--EXEC ADD_LOCATION @ploccode = loc20, @pminqty = 0, @pmaxqty = 15;
--EXEC ADD_LOCATION @ploccode = loc30, @pminqty = 0, @pmaxqty = 15;
--select * FROM location;
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2051, @pqty = 1, @pdate = '01/20/2021';

--EXEC ADD_COMPLEX_SALE @pcustid = 5, @pprodid = 1500, @pqty = 1, @pdate = '05/30/2021'; 

--EXEC ADD_COMPLEX_SALE @pcustid = 5, @pprodid = 1400, @pqty = 3, @pdate = '09/27/2021'; 
--EXEC ADD_COMPLEX_SALE @pcustid = 200, @pprodid = 1500, @pqty = 1, @pdate = '01/20/2021';

--select * from customer;
/*errors from UPD_PROD_SALESYTD will show up if params not met, max sales ytd for product update is > 999.99*/

--SELECT * FROM SALE;
--Select * from customer;
--Select * from product;
--select * from location;

--update product set sales_ytd = 0;
--delete from sale;
--update customer set sales_ytd = 0;

/*anon block for Get_allsales*/
GO
BEGIN
DECLARE @SalesOUT as CURSOR 

DECLARE @ID BIGINT, @CUSTID INT,@PRODID INT, @QTY INT, @PRICE MONEY, @SALEDATE DATE /*declare variables for each of the data fields in table*/
EXEC GET_ALLSALES @pOutCur = @SalesOUT OUTPUT;

FETCH NEXT FROM @SalesOUT INTO @ID, @CUSTID, @PRODID, @QTY, @PRICE, @SALEDATE;
WHILE @@FETCH_STATUS = 0 /*LOOP which goes through to get each row of data*/
BEGIN 
PRINT CONCAT (' ID: ',@ID, ' Customer ID: ', @CUSTID, ' Product ID ', @PRODID,
 ' Sales QTY: ',@QTY,' Selling Price: ', @PRICE,'Date of Sale: ',@SALEDATE);

FETCH NEXT FROM @SalesOUT INTO @ID, @CUSTID,@PRODID, @QTY, @PRICE, @SALEDATE;
END

CLOSE @SalesOUT;
DEALLOCATE @SalesOUT;
END;

GO
/*anon block for count_product_sales
BEGIN 
DECLARE @pdays INT, @qtySalesMade INT;
EXEC COUNT_PRODUCT_SALES @pdays = 300, @returnCount = @qtySalesMade OUTPUT;
PRINT (CONCAT ('The number of sales made in th last', @pdays,' days is : ', @qtySalesMade));
END; 
*/


/*Procedure 19 */
--Delete a row from the SALE table

--Determine the smallest saleid value in the SALE table, If value is NULL raise a No Sale Rows Found exception
--Otherwise delete a row from the SALE table with the matching sale id- PARTLY DONE NEEDS TO BE COMPLETED
--Calls UPD_CUST_SALES_YTD  and UPD_PROD_SALES_YTD so that the correct amount is subtracted from SALES_YTD
--You must calculate the amount using the PRICE in the SALE table multiplied by the QTY

--This function must return the SaleID value of the Sale row that was deleted
--@PRICE- (Price in sale table) * @qty (Quantity Sale Table.)
--@UpdatesSalesYTD MONEY /*(Customer&Product Tables) */
/*Anon block for delete_sale
BEGIN
    DECLARE @psaleID BIGINT, @OUTPUTVALUE BIGINT
        EXEC DELETE_SALE @psaleID =  @OUTPUTVALUE OUTPUT;
    PRINT CONCAT('The deleted salesID is: ', @OUTPUTVALUE)
END;
*/

/*Procedure 20*/
--DELETE_ALL_SALES
--Delete all rows in the SALE table 
--Set the Sales_YTD value to zero for all rows in the Customer and Product tables
-- this procedure only deleted sales, 
--it didn't update sales_ytd in either the customer or product table

----EXEC DELETE_PRODUCT @pProdid = 1400;

select * from sale;
select * from product;
select * from customer;