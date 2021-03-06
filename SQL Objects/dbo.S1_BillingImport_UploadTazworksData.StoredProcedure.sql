/****** Object:  StoredProcedure [dbo].[S1_BillingImport_UploadTazworksData]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[S1_BillingImport_UploadTazworksData]
(
	@VendorID int, 
	@FileNum int, 
	@ClientNumber varchar(50), 
	@ClientName varchar(max), 
	@SalesRep varchar(max), 
	@LName varchar(max), 
	@FName varchar(max), 
	@MName varchar(max), 
	@SSN varchar(max), 
	@ClientNumberOrdered varchar(max), 
	@ClientNameOrdered varchar(max), 
	@OrderBy varchar(max), 
	@Reference varchar(max),
	@DateOrdered varchar(max), 
	@ProductName varchar(max), 
	@ProductType varchar(max), 
	@ItemCode varchar(max), 
	@ProductDesc varchar(max), 
	@Price money,
	@InvoiceNumber varchar(max),
	@Jurisdiction varchar(max), 
	@ItemDescription varchar(max),
	@importbatchid int,
	@CoLName varchar(max),
	@CoFName varchar(max),
	@CoSSN varchar(max)

)
AS
SET NOCOUNT ON;
Begin

	Declare @errorcode int
			
	Set @errorcode = 0
	
	
	BEGIN TRANSACTION

    INSERT INTO TazworksImport 
		(ImportBatchID, VendorID, FileNum, ClientNumber, ClientName, SalesRep, LName, FName, MName, SSN, 
		 ClientNumberOrdered, ClientNameOrdered, OrderBy, Reference, DateOrdered, ProductName, 
		  ProductType, ItemCode, ProductDesc, Price, InvoiceNumber, Jurisdiction, ItemDescription, CoLName, CoFName, CoSSN)
    VALUES (@importbatchid, @VendorID, @FileNum, @ClientNumber, @ClientName, @SalesRep, @LName, @FName, @MName, @SSN, 
		 @ClientNumberOrdered, @ClientNameOrdered, @OrderBy, @Reference, @DateOrdered, @ProductName, 
		  @ProductType, @ItemCode, @ProductDesc, @Price, @InvoiceNumber, @Jurisdiction, @ItemDescription, @CoLName, @CoFName, @CoSSN)

	
	if(@@ERROR <> 0)
	Begin
		set @errorcode = -1
		Goto Cleanup
	End	
	Else
	Begin
	
		COMMIT TRANSACTION
		Return @errorcode
	End

	
Cleanup:

    BEGIN
    	ROLLBACK TRANSACTION
    END

    RETURN @errorcode

End






GO
