/****** Object:  StoredProcedure [dbo].[S1_Invoices_ReleasePendingInvoice]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC S1_Invoices_ReleasePendingInvoice 0

CREATE PROCEDURE [dbo].[S1_Invoices_ReleasePendingInvoice]
(
	@InvoiceID int
)
AS
	SET NOCOUNT ON;
	
	UPDATE Invoices
	SET Released=4
	WHERE InvoiceID=@InvoiceID

GO
