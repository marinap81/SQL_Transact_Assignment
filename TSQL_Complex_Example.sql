--STUDENT NUMBER 103340660
--STUDENT NAME MARINA PAJVANCIC
DROP PROCEDURE IF EXISTS HELP;
USE test123;
SELECT * FROM INFORMATION_SCHEMA.TABLES
select name, modify_date from sys.procedures; /*displays list of stored procedures*/
IF OBJECT_ID('ADD_CUSTOMER') IS NOT NULL

DROP PROCEDURE IF EXISTS ADD_CUSTOMER;
GO
/*procedure 1*/

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
EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude2';
EXEC ADD_CUSTOMER @pcustid = 500, @pcustname = 'testdude3'; /*unable to add- get an error as outside range- not currently in table*/
EXEC ADD_CUSTOMER @pcustid = 200, @pcustname = 'testdude4'; /*added*/


select * from customer;

--DELETE from customer;

GO
/*Procedure 2 */

DROP PROCEDURE IF EXISTS DELETE_ALL_CUSTOMERS;
GO

CREATE PROCEDURE DELETE_ALL_CUSTOMERS AS
BEGIN 

DELETE FROM CUSTOMER;
PRINT (CONCAT('NUMBER OF ROWS AFFECTED ', @@ROWCOUNT));
END;
EXEC DELETE_ALL_CUSTOMERS;

GO

DROP PROCEDURE  IF EXISTS ADD_PRODUCT;
GO
/*Procedure 3*/
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
EXEC ADD_PRODUCT @pprodid = 1001, @pprodname = 'SmartWatch', @pprice = 50.00;
EXEC ADD_PRODUCT @pprodid = 2051, @pprodname = 'MobilePhone', @pprice = 850.00;
select * from product;
GO
/*Procedure 4*/
DROP PROCEDURE IF EXISTS DELETE_ALL_PRODUCTS;
GO

CREATE PROCEDURE DELETE_ALL_PRODUCTS AS
BEGIN 

DELETE FROM PRODUCT;
RETURN @@ROWCOUNT;
END;
EXEC DELETE_ALL_PRODUCTS;
SELECT * FROM PRODUCT;
GO

DROP PROCEDURE IF EXISTS GET_CUSTOMER_STRING;
GO

/*PROCEDURE 5*/
CREATE PROCEDURE GET_CUSTOMER_STRING @PCUSTID INT, @PReturnString NVARCHAR(100) OUTPUT AS /*setting variables*/
BEGIN 

    BEGIN TRY
DECLARE @PCUSTNAME NVARCHAR(100), @STATUS NVARCHAR(7), @YTD MONEY; /*declaring further variables*/

SELECT @PCUSTNAME = CUSTNAME, @STATUS = [STATUS], @YTD = SALES_YTD /*assigning the 3 above variables*/
FROM CUSTOMER
WHERE CUSTID = @PCUSTID

IF @@ROWCOUNT = 0 
    THROW 50060, 'Customer ID not found', 1


    SET @PReturnString = CONCAT ('CustId: ', @PCUSTID, ' Name: ', @PCUSTNAME,' status: ', @STATUS, ' SalesYTD: ',@YTD);
    /*return strin only assigned if data is found, if rowcount = 0 then return string won't be executed*/
    END TRY

        BEGIN CATCH
        IF ERROR_NUMBER() IN (50060) /*can add additional errors inside bracket, saves multiple IF statements*/
            THROW /*takes msg and passes it on*/
        ELSE
    BEGIN
    DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE(); /*ERROR_MESSAGE() is called & set into var @errormessage*/
    THROW 50000, @ERRORMESSAGE, 1                           /*deals with error 50060 and what to output*/
    END;
        END CATCH;
    END;

    /*anonymous block*/

    BEGIN
    DECLARE @OUTPUTVALUE NVARCHAR(100)
  
    EXEC GET_CUSTOMER_STRING @PCUSTID = 1, @PReturnString = @OUTPUTVALUE OUTPUT;
    PRINT(@OUTPUTVALUE)
    END;

  SELECT * FROM CUSTOMER

  GO

/*PROCEDURE 6*/
--CAN UPDATE WITHOUT CHECKING IF CUSTOMER EXISTS
--UPDATE CUSTOMER SET STATUS = 'OK' WHERE CUSTID = 1;
DROP PROCEDURE  IF EXISTS UPD_CUST_SALESYTD;
GO

CREATE PROCEDURE UPD_CUST_SALESYTD @PCUSTID INT, @PAMT MONEY AS 
BEGIN

BEGIN TRY 

    UPDATE CUSTOMER SET SALES_YTD = @PAMT WHERE CUSTID = @PCUSTID;
    IF @@ROWCOUNT = 0
            THROW 50070, 'Customer ID not found',1
    
    ELSE IF @PAMT <-999.99 or @PAMT > 999.99 
           THROW 50080, 'Amount out of range', 1
    
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
EXEC UPD_CUST_SALESYTD  @PCUSTID = 1, @PAMT = 150;
select * from customer;
/*Procedure 7*/

DROP PROCEDURE  IF EXISTS GET_PROD_STRING;
GO

CREATE PROCEDURE GET_PROD_STRING @pprodid INT, @pReturnString NVARCHAR(1000) OUTPUT AS /*RString OUT Parameter*/
BEGIN 

    BEGIN TRY
    DECLARE @Name NVARCHAR(100), @Price MONEY, @Sales MONEY                      /*declaring further variables*/
   

    SELECT @Name = PRODNAME, @Price = SELLING_PRICE, @Sales = SALES_YTD              /*Assigning */
    FROM PRODUCT
    WHERE PRODID = @pprodid

           /* IF @pprodid < 1000 OR @pprodid > 2500
            THROW 50090, 'Product ID not found', 1 */

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

 /*anonymous block*/ /*on further testing it wasn't throwing error 50090. Product ID not found, this has now been corrected*/

    BEGIN
    DECLARE @OUTPUTVALUE NVARCHAR(100)
  
    EXEC GET_PROD_STRING @pprodid = 2000, @pReturnString = @OUTPUTVALUE OUTPUT;
    PRINT(@OUTPUTVALUE)
    END;
    
/*Procedure 8-CORRECTLY SET UP- ONLY SHOWS 1 ERROR MSG AND EXITS IF 2 INVALID PARAMATERS ARE ENTERED*/

DROP PROCEDURE  IF EXISTS UPD_PROD_SALESYTD

GO

CREATE PROCEDURE UPD_PROD_SALESYTD @pprodid INT, @pamt MONEY AS
BEGIN

    BEGIN TRY
           /* IF @pprodid < 1000 OR @pprodid > 2500
            THROW 50100, 'Product ID not found', 1 */

        UPDATE PRODUCT SET SALES_YTD = @pamt WHERE PRODID = @pprodid 

             IF @pamt < -999.99 OR @pamt > 999.99
            THROW 50110, 'Amount out of range', 1

            ELSE IF @@ROWCOUNT = 0                       
            THROW 50100, 'Product ID not found', 1 

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
EXEC ADD_PRODUCT @pprodid = 1001, @pprodname = 'SmartWatch', @pprice = 50.00;
EXEC ADD_PRODUCT @pprodid = 2051, @pprodname = 'MobilePhone', @pprice = 850.00;
EXEC UPD_PROD_SALESYTD  @pprodid = 2000, @PAMT = 1500; /*on testing both parameters being invalid was only outputting 1 error- amount out of range*/
select * from product;



/*Procedure 9-NEED TO GET THIS TO WORK*/

DROP PROCEDURE  IF EXISTS UPD_CUSTOMER_STATUS

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
GO

    EXEC UPD_CUSTOMER_STATUS @pcustid = 1, @pstatus = 'SUSPEND';
SELECT * FROM CUSTOMER;
GO





