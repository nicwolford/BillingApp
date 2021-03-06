/****** Object:  StoredProcedure [dbo].[S1_Invoices_ReleaseInvoice]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC S1_Invoices_ReleaseInvoice 0

CREATE PROCEDURE [dbo].[S1_Invoices_ReleaseInvoice]
(
	@InvoiceID int
)
AS
	SET NOCOUNT ON;
	
	UPDATE I
	SET Released=(CASE WHEN BC.DeliveryMethod IN (0,1) THEN 1
						WHEN BC.DeliveryMethod=2 THEN 2
						WHEN BC.DeliveryMethod=3 THEN 3
					END)
	FROM Invoices I
	INNER JOIN InvoiceBillingContacts IBC
		ON I.InvoiceID=IBC.InvoiceID
	INNER JOIN BillingContacts BC
		ON BC.BillingContactID=IBC.BillingContactID
	WHERE I.InvoiceID=@InvoiceID
	AND BC.DeliveryMethod BETWEEN 0 AND 3
	AND I.Released IN (0,4)

GO
