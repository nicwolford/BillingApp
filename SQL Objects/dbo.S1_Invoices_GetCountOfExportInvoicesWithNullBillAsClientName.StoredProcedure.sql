/****** Object:  StoredProcedure [dbo].[S1_Invoices_GetCountOfExportInvoicesWithNullBillAsClientName]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Invoices_GetCountOfExportInvoicesWithNullBillAsClientName]
AS
	SET NOCOUNT ON;
	
	SELECT COUNT(*)
	FROM Invoices I
	INNER JOIN Clients C
		ON I.ClientID=C.ClientID
	WHERE C.BillAsClientName IS NULL AND I.InvoiceExported=0

GO
