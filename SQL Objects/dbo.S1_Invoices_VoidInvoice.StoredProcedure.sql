/****** Object:  StoredProcedure [dbo].[S1_Invoices_VoidInvoice]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[S1_Invoices_VoidInvoice]
(
	@InvoiceID int,
	@UserID int
)
AS
	SET NOCOUNT ON;
	
	UPDATE Invoices SET VoidedOn=GETDATE(), VoidedByUser=@UserID WHERE InvoiceID=@InvoiceID
	
	UPDATE ProductTransactions SET Invoiced=0 WHERE ProductTransactionID IN 
		(SELECT ProductTransactionID FROM ProductsOnInvoice WHERE InvoiceID=@InvoiceID)

GO
