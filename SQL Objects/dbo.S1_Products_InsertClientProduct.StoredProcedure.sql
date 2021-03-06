/****** Object:  StoredProcedure [dbo].[S1_Products_InsertClientProduct]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[S1_Products_InsertClientProduct]
(
	@clientid int,
	@productid int,
	@vendorid int
)
AS
	SET NOCOUNT ON;
	
	DECLARE @errormsg int,
			@includeoninvoice int,
			@ImportsAtBaseOrSales bit,
			@SalesPrice money,
			@rollupclientid int
			

	DECLARE @ClientsTemp TABLE (
		[ClientID] [int] NOT NULL,
		[OriginalClientID] [int] NOT NULL
	)
			
	SET @errormsg = 0
	
	
	IF (@productid <> 0)
	BEGIN

		IF not exists(select * from ClientProducts where ClientID = @clientid and ProductID = @productid)
		BEGIN

			BEGIN TRANSACTION
		
			SET @includeoninvoice = (
				select includeoninvoice 
				from Products p 
				INNER JOIN VendorProducts vp ON vp.ProductID = p.ProductID AND vp.VendorID = @vendorid
				WHERE P.ProductID = @productid
				)
			
			SET @ImportsAtBaseOrSales = 1
			SET @SalesPrice = 0.00	

			INSERT INTO ClientProducts (ClientID, ProductID, IncludeOnInvoice, SalesPrice, ImportsAtBaseOrSales)
			VALUES (@clientid, @productid, @includeoninvoice, @SalesPrice, @ImportsAtBaseOrSales)
			
			if (@productid = 367 or @productid = 368) --if applicantONE eDrug product, move client to billing group 7
			BEGIN
				Update Clients set BillingGroup = 7 where ClientID = @clientid
			END
			
			IF (@@ERROR <> 0)
			BEGIN
				SET @errormsg = -1
				ROLLBACK TRANSACTION
			END		
			ELSE
			BEGIN				
				COMMIT TRANSACTION
			END
			
			--NOW CHECK FOR ROLLUP RELATED CLIENTS TO ADD THE PRODUCT TO
			INSERT INTO @ClientsTemp (ClientID, OriginalClientID)
			SELECT C.ClientID, C.ClientID
			FROM Clients C
			INNER JOIN ClientInvoiceSettings CIS
				ON C.ClientID=CIS.ClientID
			WHERE CIS.SplitByMode=1

			/* Split By = 2 - Group by Master Client */

			INSERT INTO @ClientsTemp (ClientID, OriginalClientID)
			SELECT CIS.ClientID, C.ClientID
			FROM Clients C
			INNER JOIN ClientInvoiceSettings CIS
				ON (C.ClientID=CIS.ClientID OR C.ParentClientID=CIS.ClientID)
			WHERE CIS.SplitByMode=2

			/* Split By = 3 - Group by Custom Client Splits */

			INSERT INTO @ClientsTemp (ClientID, OriginalClientID)
			SELECT CS.GroupAsClientID,CSC.ClientID 
			FROM Clients C
			INNER JOIN ClientInvoiceSettings CIS
				ON C.ClientID=CIS.ClientID
			INNER JOIN ClientSplit CS
				ON C.ClientID=CS.ParentClientID
			INNER JOIN ClientSplitClient CSC
				ON CS.ClientSplitID=CSC.ClientSplitID
			WHERE C.ParentClientID IS NULL AND CIS.SplitByMode=3
			
			
			IF EXISTS(select * from @ClientsTemp where ClientID <> OriginalClientID	and OriginalClientID = @clientid 
						and ClientID not in (select ClientID from ClientProducts where ProductID = @productid))
			BEGIN
			
				SELECT @rollupclientid = ClientID from @ClientsTemp where OriginalClientID = @clientid
								
				INSERT INTO ClientProducts (ClientID, ProductID, IncludeOnInvoice, SalesPrice, ImportsAtBaseOrSales)
				VALUES (@rollupclientid, @productid, @includeoninvoice, @SalesPrice, @ImportsAtBaseOrSales)
				
				if (@productid = 367 or @productid = 368) --if applicantONE eDrug product, move rollup client to billing group 7
				BEGIN
					Update Clients set BillingGroup = 7 where ClientID = @rollupclientid
				END
				
				Set @errormsg = 2
					
			END
	
		END
		
	END
	
    RETURN @errormsg
GO
