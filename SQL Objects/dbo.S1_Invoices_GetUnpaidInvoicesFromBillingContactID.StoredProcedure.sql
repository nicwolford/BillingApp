/****** Object:  StoredProcedure [dbo].[S1_Invoices_GetUnpaidInvoicesFromBillingContactID]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC S1_Invoices_GetUnpaidInvoicesFromBillingContactID 142

CREATE PROCEDURE [dbo].[S1_Invoices_GetUnpaidInvoicesFromBillingContactID]
(
	@BillingContactID int
)
AS
	SET NOCOUNT ON;	
	


SELECT I.InvoiceID, I.InvoiceNumber, I.InvoiceDate, I.InvoiceTypeID, IT.InvoiceTypeDesc,
I.Amount - ISNULL(P.Amount,0) as Amount, I.Amount as OriginalAmount, BC.BillingContactID, BC.ClientContactID, BC.ContactName,
C.ClientName
FROM Invoices I
INNER JOIN InvoiceTypes IT
	ON IT.InvoiceTypeID=I.InvoiceTypeID
INNER JOIN Clients C
	ON I.ClientID=C.ClientID
INNER JOIN InvoiceBillingContacts IBC
	ON IBC.InvoiceID=I.InvoiceID
	AND IBC.IsPrimaryBillingContact=1
INNER JOIN BillingContacts BC
	ON BC.BillingContactID=IBC.BillingContactID
LEFT JOIN InvoicePayments P
	ON I.InvoiceID=P.InvoiceID
WHERE I.VoidedOn IS NULL
AND BC.BillingContactID=@BillingContactID
AND I.InvoiceTypeID IN (1,2)
AND I.Amount - ISNULL(P.Amount,0) <> 0

GO
