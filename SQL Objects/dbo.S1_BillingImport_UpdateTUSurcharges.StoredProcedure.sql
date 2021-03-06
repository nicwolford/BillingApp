/****** Object:  StoredProcedure [dbo].[S1_BillingImport_UpdateTUSurcharges]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Exec S1_BillingImport_UpdateTUSurcharges '05/26/2010', '06/30/2010'

CREATE PROCEDURE [dbo].[S1_BillingImport_UpdateTUSurcharges]

AS
SET NOCOUNT ON;
Begin

	Declare @errorcode int	
	
	Set @errorcode = 0

	UPDATE ProductTransactions
	Set FileNum = 'DELETE'
	WHERE ClientID in (select clientid from ClientProducts where ProductID = 178 and SalesPrice <> 0 and ImportsAtBaseOrSales = 0)
	  AND VendorID = 4
	  AND ProductID = 178
	  AND ImportBatchID = (select MAX(importbatchID) from ImportBatch where ImportBatchVendorID = 4 and ImportSuccess = 1)
	  

	BEGIN TRANSACTION

	insert into ProductTransactions (ProductID, ClientID, VendorID, TransactionDate, DateOrdered, OrderBy, Reference, FName, LName, MName, SSN, ProductName, ProductDescription, ProductType, ProductPrice, ExternalInvoiceNumber, SalesRep, CoLName, CoFName, CoMName, CoSSN)
	select PT.ProductID, PT.ClientID, PT.VendorID, PT.TransactionDate, PT.DateOrdered, PT.OrderBy, PT.Reference, PT.FName, 
	PT.LName, PT.MName, PT.SSN, PT.ProductName, PT.ProductDescription, PT.ProductType, 
	PT.ProductPrice/
	(select COUNT(PT2.ProductTransactionID) from ProductTransactions PT2 
	WHERE PT2.ClientID = PT1.ClientID and PT2.VendorID = PT1.Vendorid and PT2.ProductID = PT1.ProductID and PT2.ImportBatchID = PT1.ImportBatchID),
	PT.ExternalInvoiceNumber, PT.SalesRep, PT.CoLName, PT.CoFName, PT.CoMName, PT.CoSSN
	 from ProductTransactions PT
	inner join ProductTransactions PT1 on PT1.ImportBatchID = PT.ImportBatchID AND PT1.ClientID = PT.ClientID and PT1.VendorID = PT.VendorID and PT1.ProductID = 175
	WHERE PT.ClientID in (select clientid from ClientProducts where ProductID = 178 and SalesPrice <> 0 and ImportsAtBaseOrSales = 0)
	  AND PT.VendorID = 4
	  AND PT.ProductID = 178
	  AND PT.ImportBatchID = (select MAX(importbatchID) from ImportBatch where ImportBatchVendorID = 4 and ImportSuccess = 1)
	  order by PT.clientid
	  
	if(@@ERROR <> 0)
	Begin
		set @errorcode = -1
		ROLLBACK TRANSACTION
	End	
	Else
	Begin
	
		COMMIT TRANSACTION

		DELETE FROM ProductTransactions
		WHERE ClientID in (select clientid from ClientProducts where ProductID = 178 and SalesPrice <> 0 and ImportsAtBaseOrSales = 0)
		  AND VendorID = 4
		  AND ProductID = 178
		  AND FileNum = 'DELETE'

	End


	
    return @errorcode

END	







GO
