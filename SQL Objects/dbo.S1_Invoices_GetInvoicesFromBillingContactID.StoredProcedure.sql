/****** Object:  StoredProcedure [dbo].[S1_Invoices_GetInvoicesFromBillingContactID]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC S1_Invoices_GetInvoicesFromBillingContactID 142

CREATE PROCEDURE [dbo].[S1_Invoices_GetInvoicesFromBillingContactID]
(
	@BillingContactID int,
	@UserID int
)
AS
	SET NOCOUNT ON;	
	

DECLARE @tmp_BillingContacts TABLE
(
	BillingContactID int
)
	
IF (@BillingContactID=0)
BEGIN
	INSERT INTO @tmp_BillingContacts (BillingContactID)
	SELECT BC.BillingContactID
	FROM BillingContacts BC
	INNER JOIN ClientContacts CC
		ON BC.ClientContactID=CC.ClientContactID
	WHERE CC.UserID=@UserID
END
ELSE
BEGIN
	INSERT INTO @tmp_BillingContacts (BillingContactID) VALUES (@BillingContactID)
END


SELECT A.InvoiceID, A.InvoiceNumber, A.InvoiceDate, A.InvoiceTypeID, A.InvoiceTypeDesc,
A.Amount - A.PaymentsAmount - SUM(ISNULL(CR.Amount,0)) as Amount, 
A.Amount as OriginalAmount, A.BillingContactID, A.ClientContactID, A.ContactName,
A.ClientName
FROM
(
SELECT I.InvoiceID, I.InvoiceNumber, I.InvoiceDate, I.InvoiceTypeID, IT.InvoiceTypeDesc,
I.Amount, I.Amount as OriginalAmount, BC.BillingContactID, BC.ClientContactID, BC.ContactName,
C.ClientName, I.VoidedOn, I.Released, SUM(ISNULL(P.Amount,0)) as PaymentsAmount
FROM Invoices I
INNER JOIN InvoiceTypes IT
	ON IT.InvoiceTypeID=I.InvoiceTypeID
INNER JOIN Clients C
	ON I.ClientID=C.ClientID
INNER JOIN InvoiceBillingContacts IBC
	ON IBC.InvoiceID=I.InvoiceID
INNER JOIN BillingContacts BC
	ON BC.BillingContactID=IBC.BillingContactID
LEFT JOIN InvoicePayments P
	ON I.InvoiceID=P.InvoiceID
GROUP BY I.InvoiceID, I.InvoiceNumber, I.InvoiceDate, I.InvoiceTypeID, IT.InvoiceTypeDesc,
I.Amount, BC.BillingContactID, BC.ClientContactID, BC.ContactName, C.ClientName,
I.VoidedOn, I.Released
) A
LEFT JOIN Invoices CR
	ON A.InvoiceID=CR.RelatedInvoiceID
	AND CR.InvoiceTypeID=3
	AND CR.VoidedOn is null
WHERE A.VoidedOn IS NULL
AND A.BillingContactID IN (SELECT BillingContactID FROM @tmp_BillingContacts)
AND A.InvoiceTypeID=1
AND A.Released>0
AND A.InvoiceDate>'7/31/2010'
GROUP BY A.InvoiceID, A.InvoiceNumber, A.InvoiceDate, A.InvoiceTypeID, A.InvoiceTypeDesc,
A.Amount, A.BillingContactID, A.ClientContactID, A.ContactName, A.ClientName, A.PaymentsAmount
GO
