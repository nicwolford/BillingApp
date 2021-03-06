/****** Object:  StoredProcedure [dbo].[S1_BillingImport_InsertTazworks1SearchText]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Exec S1_BillingImport_InsertTazworks1SearchText 'PRODUCTCODE', 'SOME TEXT', '103'

CREATE PROCEDURE [dbo].[S1_BillingImport_InsertTazworks1SearchText]
(
	@productcode varchar(255),
	@searchtext varchar(max),
	@matcherrorcode varchar(10),
	@permanentsearchflag bit,
	@importid int
)
AS
SET NOCOUNT ON;
Begin

	Declare @errorcode int,
			@clientid int,
			@vendorid int,
			@productid int
			
	Set @errorcode = 0
	
	select @vendorid = vendorid from TazworksImport where ImportID = @importid
	
	select @clientid= (
	select clientid from ClientVendors
	where VendorID = @vendorid 
	  and VendorClientNumber = (select ClientNumber from TazworksImport where ImportID = @importid))

	
	if not exists(select * from ClientProducts where ClientID = @clientid 
						and ProductID in (
						select p.ProductID from Products p
						inner join vendorproducts vp on vp.ProductID = p.ProductID and vp.VendorID = @vendorid
						where p.ProductCode = @productcode))
	BEGIN							
	
		Insert into ClientProducts (ClientID, ProductID, IncludeOnInvoice, SalesPrice, ImportsAtBaseOrSales)
		select @clientid, p.ProductID, 1, 0, 1
		from Products p
		inner join vendorproducts vp on vp.ProductID = p.ProductID and vp.VendorID = @vendorid
		where p.ProductCode = @productcode
	
	END



	if (@matcherrorcode = '103') --Handle products that don't match
	BEGIN
	
		if not exists(select * from TazworksSearchList where SearchText = @searchtext and MatchPriority = 999998)
		BEGIN
		
		BEGIN TRANSACTION

		INSERT INTO TazworksSearchList (SearchText, ProductCode, MatchPriority)
		VALUES (@searchtext, @productcode, 999998)
	    
		if(@@ERROR <> 0)
		Begin
			set @errorcode = -1
    		ROLLBACK TRANSACTION
			RETURN @errorcode

		End	
		Else
		Begin
		
			COMMIT TRANSACTION
			Return @errorcode
		End

		END
		ELSE
		BEGIN
			Return @errorcode
		END
	END
	
	if (@matcherrorcode = '104' and @permanentsearchflag = 1) --Handle negative amount transactions
	BEGIN
		if not exists(select * from TazworksSearchList where SearchText = @searchtext and MatchPriority = 999999)
		BEGIN
		
		BEGIN TRANSACTION

		INSERT INTO TazworksSearchList (SearchText, ProductCode, MatchPriority)
		VALUES (@searchtext, @productcode, 999999)
		
				if(@@ERROR <> 0)
		Begin
			set @errorcode = -1
    		ROLLBACK TRANSACTION
			RETURN @errorcode
		End	
		Else
		Begin
		
			COMMIT TRANSACTION
			Return @errorcode
		End

		END
		ELSE
		BEGIN
			Return @errorcode
		END
	END
	
	if (@matcherrorcode = '104' and @permanentsearchflag = 0) --Match negative amount to a product temporarilty (for this import only)
	BEGIN
		if not exists(select * from TazworksSearchList where SearchText = @searchtext and MatchPriority = 999999)
		BEGIN
		
		BEGIN TRANSACTION

		INSERT INTO TazworksTempSearchList (SearchText, ProductCode, MatchPriority, ImportID)
		VALUES (@searchtext, @productcode, 999999, @importid)
		
				if(@@ERROR <> 0)
		Begin
			set @errorcode = -1
    		ROLLBACK TRANSACTION
			RETURN @errorcode
		End	
		Else
		Begin
		
			COMMIT TRANSACTION
			Return @errorcode
		End

		END
		ELSE
		BEGIN
			Return @errorcode
		END
		


			
	
	END
	


End






GO
