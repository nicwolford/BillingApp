/****** Object:  StoredProcedure [dbo].[S1_BillingStatement_GetCurrentStatement]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC S1_BillingStatement_GetCurrentStatement 221, '10/2/2012', '11/1/2012'
--EXEC S1_BillingStatement_GetCurrentStatement 1165, '8/2/2010', '9/1/2010'

CREATE PROCEDURE [dbo].[S1_BillingStatement_GetCurrentStatement]
(
	@BillingContactID int,
	@StartDate datetime,
	@EndDate datetime
)
AS
	SET NOCOUNT ON;
	
--Invoices - Current Period
SELECT InvoiceNumber, [Date], [Type], Amount, LinkID, LineOrder
FROM
(
SELECT InvoiceNumber, InvoiceDate as [Date], IT.InvoiceTypeDesc as [Type], Amount, I.InvoiceID as LinkID, 0 as LineOrder
FROM Invoices I INNER JOIN InvoiceTypes IT ON I.InvoiceTypeID=IT.InvoiceTypeID
INNER JOIN InvoiceBillingContacts IBC ON IBC.InvoiceID=I.InvoiceID AND IBC.IsPrimaryBillingContact=1
INNER JOIN BillingContacts BC ON BC.BillingContactID=IBC.BillingContactID
WHERE BC.BillingContactID=@BillingContactID AND VoidedOn IS NULL AND I.InvoiceTypeID=1
AND InvoiceDate BETWEEN @StartDate AND @EndDate
AND I.Released>0
AND I.DontShowOnStatement=0

UNION ALL

--Refunds - Current Period
SELECT InvoiceNumber, InvoiceDate as [Date], IT.InvoiceTypeDesc as [Type], Amount, 0 as LinkID, 2 as LineOrder
FROM Invoices I INNER JOIN InvoiceTypes IT ON I.InvoiceTypeID=IT.InvoiceTypeID
INNER JOIN InvoiceBillingContacts IBC ON IBC.InvoiceID=I.InvoiceID AND IBC.IsPrimaryBillingContact=1
INNER JOIN BillingContacts BC ON BC.BillingContactID=IBC.BillingContactID
WHERE BC.BillingContactID=@BillingContactID AND VoidedOn IS NULL AND I.InvoiceTypeID=5
AND InvoiceDate BETWEEN @StartDate AND @EndDate
AND I.Released>0
AND I.DontShowOnStatement=0

UNION ALL

--Payments - Current Period
SELECT InvoiceNumber, [Date], 'Payment' as [Type], 0 - IP.Amount, 0 as LinkID,
1 as LineOrder 
FROM Payments P INNER JOIN InvoicePayments IP ON P.PaymentID=IP.PaymentID
INNER JOIN Invoices I ON IP.InvoiceID=I.InvoiceID
INNER JOIN InvoiceBillingContacts IBC ON IBC.InvoiceID=I.InvoiceID AND IBC.IsPrimaryBillingContact=1
INNER JOIN BillingContacts BC ON BC.BillingContactID=IBC.BillingContactID
WHERE BC.BillingContactID=@BillingContactID AND VoidedOn IS NULL
AND P.[Date] BETWEEN @StartDate AND @EndDate
AND I.Released>0
AND I.InvoiceTypeID<>4
AND I.DontShowOnStatement=0

UNION ALL

--Finance Charges - Current Period
SELECT I.InvoiceNumber, I.InvoiceDate as [Date], 
CASE WHEN I2.InvoiceID IS NOT NULL THEN IT.InvoiceTypeDesc + ' on Invoice # ' + I2.InvoiceNumber
ELSE IT.InvoiceTypeDesc END as [Type], 
I.Amount as Amount, 0 as LinkID, 0 as LineOrder
FROM Invoices I 
INNER JOIN InvoiceTypes IT 
	ON I.InvoiceTypeID=IT.InvoiceTypeID
INNER JOIN InvoiceBillingContacts IBC 
	ON IBC.InvoiceID=I.InvoiceID
	AND IBC.IsPrimaryBillingContact=1
LEFT JOIN Invoices I2
	ON I2.InvoiceID=I.RelatedInvoiceID
INNER JOIN BillingContacts BC ON BC.BillingContactID=IBC.BillingContactID
WHERE BC.BillingContactID=@BillingContactID AND I.VoidedOn IS NULL AND I.InvoiceTypeID=2
AND I.InvoiceDate BETWEEN @StartDate AND @EndDate
AND I.Released>0 
AND I.DontShowOnStatement=0

UNION ALL

--Credits - Unrelated - Current Period
SELECT I.InvoiceNumber, I.InvoiceDate as [Date], 
IT.InvoiceTypeDesc + ' - ' + I.Col1Header as [Type],  
0 - I.Amount as Amount, 0 as LinkID, 0 as LineOrder
FROM Invoices I 
INNER JOIN InvoiceTypes IT 
	ON I.InvoiceTypeID=IT.InvoiceTypeID
INNER JOIN InvoiceBillingContacts IBC 
	ON IBC.InvoiceID=I.InvoiceID
	AND IBC.IsPrimaryBillingContact=1
INNER JOIN BillingContacts BC ON BC.BillingContactID=IBC.BillingContactID
WHERE BC.BillingContactID=@BillingContactID AND I.VoidedOn IS NULL AND I.InvoiceTypeID=3
AND I.InvoiceDate BETWEEN @StartDate AND @EndDate
AND I.Released>0 
AND I.DontShowOnStatement=0
AND (I.RelatedInvoiceID=0 OR I.RelatedInvoiceID IS NULL)

UNION ALL

--Credits - Related - Current Period
SELECT I.InvoiceNumber, I.InvoiceDate as [Date], 
IT.InvoiceTypeDesc + ' - ' + I.Col1Header as [Type],  
0 - I.Amount as Amount, 0 as LinkID, 0 as LineOrder
FROM Invoices I 
INNER JOIN InvoiceTypes IT 
	ON I.InvoiceTypeID=IT.InvoiceTypeID
INNER JOIN InvoiceBillingContacts IBC 
	ON IBC.InvoiceID=I.InvoiceID
	AND IBC.IsPrimaryBillingContact=1
INNER JOIN BillingContacts BC 
	ON BC.BillingContactID=IBC.BillingContactID
INNER JOIN Invoices I2
	ON I2.InvoiceID=I.RelatedInvoiceID
WHERE BC.BillingContactID=@BillingContactID AND I.VoidedOn IS NULL AND I.InvoiceTypeID=3
AND (I2.InvoiceDate BETWEEN @StartDate AND @EndDate
OR I.InvoiceDate BETWEEN @StartDate AND @EndDate)
AND I.Released>0 
AND I.DontShowOnStatement=0

UNION ALL

--Invoices, Credits, and Finance Charges - Only show ones that aren't fully paid - Previous Period
SELECT A.InvoiceNumber, A.InvoiceDate as [Date], A.InvoiceTypeDesc as [Type], 
A.Amount - A.CreditsAmount - SUM(ISNULL(B.PaymentsAmount,0)) as Amount, 
(CASE WHEN A.InvoiceTypeID=1 AND A.InvoiceDate>'7/31/2010' 
THEN A.InvoiceID ELSE 0 END) as LinkID, 0 as LineOrder
FROM 
(
SELECT I.InvoiceID, I.InvoiceNumber, IT.InvoiceTypeDesc, I.Amount, SUM(ISNULL(CR.Amount,0)) as CreditsAmount, I.InvoiceTypeID,
I.InvoiceDate
FROM Invoices I 
INNER JOIN InvoiceTypes IT 
	ON I.InvoiceTypeID=IT.InvoiceTypeID
INNER JOIN InvoiceBillingContacts IBC 
	ON IBC.InvoiceID=I.InvoiceID
	AND IBC.IsPrimaryBillingContact=1
INNER JOIN BillingContacts BC 
	ON BC.BillingContactID=IBC.BillingContactID
LEFT JOIN 
	(SELECT I2.InvoiceID, I2.RelatedInvoiceID, I2.Amount, I2.InvoiceDate
		FROM Invoices I2
		WHERE I2.InvoiceDate < @StartDate --Only include payments in the previous period to lower the amount due
		AND I2.InvoiceTypeID=3
		AND I2.VoidedOn is null
		) CR
		ON CR.RelatedInvoiceID=I.InvoiceID
		WHERE BC.BillingContactID=@BillingContactID AND I.VoidedOn IS NULL
--AND (I.Amount - SUM(ISNULL(IP.Amount,0)) <> 0 OR P.[Date] >= @StartDate )
AND I.InvoiceDate < @StartDate
AND I.Released>0
AND I.InvoiceTypeID IN (1,2,5) --Don't include Credits as postive amounts
AND I.DontShowOnStatement=0
GROUP BY I.InvoiceID, I.InvoiceNumber, I.InvoiceDate, I.InvoiceTypeID, IT.InvoiceTypeDesc, I.Amount
) A
LEFT JOIN 
	(SELECT IP2.InvoiceID, IP2.Amount as PaymentsAmount, P2.[Date] 
		FROM InvoicePayments IP2
		INNER JOIN Payments P2 
			ON P2.PaymentID=IP2.PaymentID 
		WHERE [Date] < @StartDate --Only include payments in the previous period to lower the amount due
	) B
	ON B.InvoiceID=A.InvoiceID
GROUP BY A.InvoiceID, A.InvoiceNumber, A.InvoiceDate, A.InvoiceTypeID, A.InvoiceTypeDesc, A.Amount, A.CreditsAmount

UNION ALL 

--Overpayment Credit
SELECT '' as InvoiceNumber, P.[Date], 'Overpayment Credit' as [Type],
0 - (TotalAmount - (SELECT ISNULL(SUM(IP.Amount),0) FROM InvoicePayments IP WHERE IP.PaymentID=P.PaymentID)) 
as [Amount], 
0 as LinkID, 1 as LineOrder
FROM Payments P
WHERE P.BillingContactID=@BillingContactID 
AND TotalAmount - (SELECT ISNULL(SUM(IP.Amount),0) FROM InvoicePayments IP WHERE IP.PaymentID=P.PaymentID) > 0
AND NOT EXISTS (SELECT 1 FROM Invoices I INNER JOIN InvoiceBillingContacts IBC 
	ON IBC.InvoiceID=I.InvoiceID
	AND IBC.IsPrimaryBillingContact=1
WHERE I.InvoiceTypeID=4 AND IBC.BillingContactID=@BillingContactID)

UNION ALL

--Credits - Unrelated - Previous Period - No Beginning Balance
SELECT I.InvoiceNumber, I.InvoiceDate as [Date], 
IT.InvoiceTypeDesc as [Type],  
0 - I.Amount as Amount, 0 as LinkID, 0 as LineOrder
FROM Invoices I 
INNER JOIN InvoiceTypes IT 
	ON I.InvoiceTypeID=IT.InvoiceTypeID
INNER JOIN InvoiceBillingContacts IBC 
	ON IBC.InvoiceID=I.InvoiceID
	AND IBC.IsPrimaryBillingContact=1
INNER JOIN BillingContacts BC ON BC.BillingContactID=IBC.BillingContactID
WHERE BC.BillingContactID=@BillingContactID AND I.VoidedOn IS NULL AND I.InvoiceTypeID=3
AND I.InvoiceDate < @StartDate
AND I.Released>0 
AND I.DontShowOnStatement=0
AND (I.RelatedInvoiceID=0 OR I.RelatedInvoiceID IS NULL)
AND NOT EXISTS (SELECT 1 FROM Invoices I INNER JOIN InvoiceBillingContacts IBC 
	ON IBC.InvoiceID=I.InvoiceID
WHERE I.InvoiceTypeID=4 AND IBC.BillingContactID=@BillingContactID)

UNION ALL

--Beginning Balance
SELECT '' as InvoiceNumber, NULL as [Date], 
(CASE WHEN 
--SUM(I.Amount) >= ISNULL(SUM(IP.Amount),0) 
MAX(I.Amount) >= SUM(ISNULL(IP.Amount,0)) - ISNULL(MAX(CreditAmount),0) THEN IT.InvoiceTypeDesc 
ELSE 'Overpayment Credit' END) as [Type], 
--SUM(I.Amount) - ISNULL(SUM(IP.Amount),0)
MAX(I.Amount) - ISNULL(SUM(ISNULL(IP.Amount,0)),0) - ISNULL(MAX(CreditAmount),0) as Amount, 0 as LinkID, 0 as LineOrder
FROM Invoices I INNER JOIN InvoiceTypes IT ON I.InvoiceTypeID=IT.InvoiceTypeID
INNER JOIN InvoiceBillingContacts IBC ON IBC.InvoiceID=I.InvoiceID AND IBC.IsPrimaryBillingContact=1
INNER JOIN BillingContacts BC ON BC.BillingContactID=IBC.BillingContactID
INNER JOIN ClientContacts CC ON CC.ClientContactID=BC.ClientContactID
INNER JOIN Clients C ON CC.ClientID=C.ClientID
LEFT JOIN (SELECT ISNULL(
	(TotalAmount - ISNULL((SELECT SUM(IP2.Amount) FROM InvoicePayments IP2 WHERE IP2.PaymentID=P2.PaymentID),0)) 
	,0) as Amount, P2.BillingContactID
	FROM Payments P2
	) IP
	ON IP.BillingContactID=BC.BillingContactID
LEFT JOIN (SELECT CRIBC.BillingContactID, SUM(ISNULL(CR1.Amount,0)) as CreditAmount FROM Invoices CR1 INNER JOIN InvoiceBillingContacts CRIBC 
		ON CRIBC.InvoiceID=CR1.InvoiceID
		WHERE CR1.InvoiceTypeID=3 AND CR1.RelatedInvoiceID IS NULL
		GROUP BY CRIBC.BillingContactID
		) CR
	ON CR.BillingContactID=BC.BillingContactID	
WHERE BC.BillingContactID=@BillingContactID AND VoidedOn IS NULL 
AND I.InvoiceTypeID=4
AND I.Released>0
AND I.DontShowOnStatement=0
GROUP BY InvoiceDate, IT.InvoiceTypeDesc
HAVING MAX(I.Amount) <> SUM(ISNULL(IP.Amount,0))

)
A
WHERE Amount<>0
ORDER BY [Date], InvoiceNumber, LineOrder


GO
