/****** Object:  StoredProcedure [dbo].[S1_BillingImport_ImportTransUnion]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Exec S1_BillingImport_ImportTransUnion 4

CREATE PROCEDURE [dbo].[S1_BillingImport_ImportTransUnion]
(
	@vendorid int
)
AS
SET NOCOUNT ON;
Begin

	Declare @errorcode int
			
	Set @errorcode = 0
	
	if exists(select top 1 * 
			from ProductTransactions 
			where ImportBatchID in (
				select distinct importbatchid 
				from ImportBatch I 
				where I.ImportBatchFileName = 
					(select ImportBatchFileName from ImportBatch where ImportBatchID = (select distinct ImportBatchID from TransUnionImport)))
	)
	BEGIN
		set @errorcode = -2
		RETURN @errorcode
	END
	ELSE
	BEGIN
	
	BEGIN TRANSACTION

		INSERT INTO ProductTransactions (ProductID, ClientID, VendorID, DateOrdered, TransactionDate, Reference, 
		FName, LName, SSN, ProductName, ProductDescription, ProductPrice, ImportBatchID, ProductType)
		SELECT ProductID, ClientID, VendorID, InquiryDate, InquiryDate as TransactionDate, UserReference, FirstName, Surname, SSN, 
		ProductName, ProductDesc, NetPrice, ImportBatchID, 'TRANSUNION'
		from 
		( 
		select FirstName, Surname, @vendorid as VendorID, SSN, InquiryDate, P.ProductName as ProductDesc, NetPrice, 
		ProductID, P.ProductName, CV.ClientID, UserReference, ImportBatchID
		from  TransUnionImport TU
		INNER JOIN Products P
			ON TU.ProductCode = P.ProductCode 
		  AND P.ProductID in (select ProductID from VendorProducts where VendorID = @vendorid)
		INNER JOIN ClientVendors CV
			ON CV.VendorClientNumber = TU.TUSubscriberID and CV.VendorID = @vendorid
		WHERE TU.UserReference not like 'TAZ%'
		) a
		

		ORDER BY FirstName, Surname, SSN, InquiryDate
	
	if(@@ERROR <> 0)
	Begin
		set @errorcode = -1
		Goto Cleanup
	End	
	Else
	Begin
	
		COMMIT TRANSACTION
		Update ImportBatch set ImportSuccess = 1 where ImportBatchID = (select distinct ImportBatchID from TransUnionImport)
		Return @errorcode
	End
	
	

	
Cleanup:

    BEGIN
    	ROLLBACK TRANSACTION
    	Update ImportBatch set ImportSuccess = 0 where ImportBatchID = (select distinct ImportBatchID from TransUnionImport)
    END

    RETURN @errorcode
	END
End






GO
