/****** Object:  StoredProcedure [dbo].[S1_BillingStatement_GetBillingStatementListCurrentInvoices]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC S1_BillingStatement_GetBillingStatementListCurrentInvoices 458, '8/2/2010','9/1/2010'

CREATE PROCEDURE [dbo].[S1_BillingStatement_GetBillingStatementListCurrentInvoices]
(
	@BillingContactID int,
	@StartDate datetime,
	@EndDate datetime
)
AS
	SET NOCOUNT ON;
	
	
--Invoices, Finance Charges, and Credits - Current Period
SELECT I.InvoiceID, CC.ClientContactID, C.BillAsClientName, ISNULL(BC.ContactName,BC.ContactAddress1) as ContactName,
Amount, IBC.IsPrimaryBillingContact as PrimaryBillingContact, BC.BillingContactID, BC.ContactEmail, BC.DeliveryMethod, 
1 as CurrentActivity
FROM Invoices I INNER JOIN InvoiceTypes IT ON I.InvoiceTypeID=IT.InvoiceTypeID
INNER JOIN InvoiceBillingContacts IBC ON IBC.InvoiceID=I.InvoiceID
INNER JOIN BillingContacts BC ON BC.BillingContactID=IBC.BillingContactID 
	--AND IBC.IsPrimaryBillingContact=1
INNER JOIN ClientContacts CC ON CC.ClientContactID=BC.ClientContactID
INNER JOIN Clients C ON I.ClientID=C.ClientID
WHERE VoidedOn IS NULL AND I.InvoiceTypeID=1
AND InvoiceDate BETWEEN @StartDate AND @EndDate
AND I.Released>0
AND C.BillAsClientName IS NOT NULL
AND BC.BillingContactID=@BillingContactID
ORDER BY IBC.IsPrimaryBillingContact DESC


GO
