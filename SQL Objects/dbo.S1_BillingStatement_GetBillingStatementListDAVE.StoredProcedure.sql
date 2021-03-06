/****** Object:  StoredProcedure [dbo].[S1_BillingStatement_GetBillingStatementListDAVE]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--EXEC S1_BillingStatement_GetBillingStatementListDAVE '07/1/2014','07/1/2014',0

CREATE PROCEDURE [dbo].[S1_BillingStatement_GetBillingStatementListDAVE] (
	@StartDate datetime,
	@EndDate datetime,
	@BillingGroup int
)
AS
	SET NOCOUNT ON;
	
	
SELECT A.ClientContactID, A.BillAsClientName, A.ContactName, SUM(Amount) as Amount, 1 as PrimaryBillingContact,
@EndDate as StatementDate, A.BillingContactID, A.ContactEmail, 
CASE 
	WHEN A.DeliveryMethod = 0 THEN 'Online'
	WHEN A.DeliveryMethod = 1 THEN 'Email-Auto'
	WHEN A.DeliveryMethod = 2 THEN 'Email'
	WHEN A.DeliveryMethod = 3 THEN 'Mail'
END as DeliveryMethod,  
MAX(BPP.PrintedOn) as LastPrintedOn, MAX(A.CurrentActivity)/*, Case when MAX(A.CurrentActivity) = 2 and a.BillingContactID in (select BillingContactID from BillingContacts where OnlyShowInvoices = 1) then 1 else MAX(A.CurrentActivity) end*/ as CurrentActivity
FROM
(

	--Invoices, Finance Charges, and Credits - Current Period
	SELECT CC.ClientContactID, C.BillAsClientName, ISNULL(BC.ContactName,BC.ContactAddress1) as ContactName,
	Amount, 1 as PrimaryBillingContact, BC.BillingContactID, BC.ContactEmail, BC.DeliveryMethod, 
	1 as CurrentActivity, C.BillingGroup
	FROM Invoices I INNER JOIN InvoiceTypes IT ON I.InvoiceTypeID=IT.InvoiceTypeID
	INNER JOIN InvoiceBillingContacts IBC ON IBC.InvoiceID=I.InvoiceID
	INNER JOIN BillingContacts BC ON BC.BillingContactID=IBC.BillingContactID AND IBC.IsPrimaryBillingContact=1
	INNER JOIN ClientContacts CC ON CC.ClientContactID=BC.ClientContactID
	INNER JOIN Clients C ON I.ClientID=C.ClientID
	WHERE VoidedOn IS NULL AND I.InvoiceTypeID IN (1, 2)
	AND InvoiceDate BETWEEN @StartDate AND @EndDate
	--AND BC.HideFromClient=0
	--AND BC.OnlyShowInvoices=0
	AND I.Released>0
	AND C.BillAsClientName IS NOT NULL
	AND (BC.IsPrimaryBillingContact=1 OR BC.BillingContactID IN (SELECT DISTINCT BillingContactID FROM InvoiceSplitBillingContacts WHERE IsPrimaryBillingContact=1))

UNION ALL

	--Payments - Current Period
	SELECT CC.ClientContactID, C.BillAsClientName, ISNULL(BC.ContactName,BC.ContactAddress1) as ContactName,
	0 - IP.Amount as Amount ,1 as PrimaryBillingContact, BC.BillingContactID, BC.ContactEmail, 
	BC.DeliveryMethod, 0 as CurrentActivity, C.BillingGroup
	FROM Payments P INNER JOIN InvoicePayments IP ON P.PaymentID=IP.PaymentID
	INNER JOIN Invoices I ON IP.InvoiceID=I.InvoiceID
	INNER JOIN InvoiceBillingContacts IBC ON IBC.InvoiceID=I.InvoiceID AND IBC.IsPrimaryBillingContact=1
	INNER JOIN BillingContacts BC ON BC.BillingContactID=IBC.BillingContactID
	INNER JOIN ClientContacts CC ON CC.ClientContactID=BC.ClientContactID
	INNER JOIN Clients C ON I.ClientID=C.ClientID
	WHERE VoidedOn IS NULL
	AND P.[Date] BETWEEN @StartDate AND @EndDate
	--AND BC.HideFromClient=0
	--AND BC.OnlyShowInvoices=0
	AND I.Released>0
	AND I.InvoiceTypeID<4
	AND C.BillAsClientName IS NOT NULL
	AND (BC.IsPrimaryBillingContact=1 OR BC.BillingContactID IN (SELECT DISTINCT BillingContactID FROM InvoiceSplitBillingContacts WHERE IsPrimaryBillingContact=1))

UNION ALL
/*
	--Credits - Unrelated - Current Period
	SELECT CC.ClientContactID, C.BillAsClientName, ISNULL(BC.ContactName,BC.ContactAddress1) as ContactName,  
	0 - I.Amount as Amount, 1 as PrimaryBillingContact, 
	BC.BillingContactID, BC.ContactEmail, BC.DeliveryMethod, 0 as CurrentActivity, C.BillingGroup
	FROM Invoices I 
	INNER JOIN InvoiceTypes IT 
		ON I.InvoiceTypeID=IT.InvoiceTypeID
	INNER JOIN InvoiceBillingContacts IBC 
		ON IBC.InvoiceID=I.InvoiceID
		 AND IBC.IsPrimaryBillingContact=1
	INNER JOIN BillingContacts BC ON BC.BillingContactID=IBC.BillingContactID
	INNER JOIN ClientContacts CC ON CC.ClientContactID=BC.ClientContactID
	INNER JOIN Clients C ON I.ClientID=C.ClientID
	WHERE I.VoidedOn IS NULL AND I.InvoiceTypeID=3
	AND I.InvoiceDate BETWEEN @StartDate AND @EndDate
	AND I.Released>0 
	AND I.DontShowOnStatement=0
	AND (I.RelatedInvoiceID=0 OR I.RelatedInvoiceID IS NULL)
	AND C.BillAsClientName IS NOT NULL
	AND (BC.IsPrimaryBillingContact=1 OR BC.BillingContactID IN (SELECT DISTINCT BillingContactID FROM InvoiceSplitBillingContacts WHERE IsPrimaryBillingContact=1))

UNION ALL
*/
	--Credits - Related - Current Period
	SELECT CC.ClientContactID, C.BillAsClientName, ISNULL(BC.ContactName,BC.ContactAddress1) as ContactName,  
	0 - I.Amount as Amount, 1 as PrimaryBillingContact, 
	BC.BillingContactID, BC.ContactEmail, BC.DeliveryMethod, 0 as CurrentActivity, C.BillingGroup
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
	INNER JOIN ClientContacts CC ON CC.ClientContactID=BC.ClientContactID
	INNER JOIN Clients C ON I.ClientID=C.ClientID
	WHERE I.VoidedOn IS NULL AND I.InvoiceTypeID=3
	AND (I2.InvoiceDate BETWEEN @StartDate AND @EndDate
	OR I.InvoiceDate BETWEEN @StartDate AND @EndDate)
	AND I.Released>0 
	AND I.DontShowOnStatement=0
	AND C.BillAsClientName IS NOT NULL
	AND (BC.IsPrimaryBillingContact=1 OR BC.BillingContactID IN (SELECT DISTINCT BillingContactID FROM InvoiceSplitBillingContacts WHERE IsPrimaryBillingContact=1))
/*
UNION ALL


	SELECT CC.ClientContactID, C.BillAsClientName, ISNULL(A.ContactName,A.ContactAddress1) as ContactName,
	A.Amount - A.CreditsAmount - SUM(ISNULL(B.PaymentsAmount,0)) as Amount, 
	1 as PrimaryBillingContact, 
	A.BillingContactID, A.ContactEmail, A.DeliveryMethod, 0 as CurrentActivity, C.BillingGroup
	FROM 
	(
	SELECT I.InvoiceID, I.InvoiceNumber, IT.InvoiceTypeDesc, I.Amount, SUM(ISNULL(CR.Amount,0)) as CreditsAmount, I.InvoiceTypeID,
	I.InvoiceDate, BC.IsPrimaryBillingContact, BC.BillingContactID, BC.ContactName, BC.ContactAddress1,
	BC.ClientContactID, BC.ClientID, BC.ContactEmail, BC.DeliveryMethod
	FROM Invoices I 
	INNER JOIN InvoiceTypes IT 
		ON I.InvoiceTypeID=IT.InvoiceTypeID
	INNER JOIN InvoiceBillingContacts IBC 
		ON IBC.InvoiceID=I.InvoiceID
	INNER JOIN BillingContacts BC 
		ON BC.BillingContactID=IBC.BillingContactID
		 AND IBC.IsPrimaryBillingContact=1
	LEFT JOIN 
		(SELECT I2.InvoiceID, I2.RelatedInvoiceID, I2.Amount, I2.InvoiceDate
			FROM Invoices I2
			WHERE I2.InvoiceDate < @StartDate --Only include payments in the previous period to lower the amount due
			AND I2.InvoiceTypeID=3
			) CR
			ON CR.RelatedInvoiceID=I.InvoiceID
	WHERE I.VoidedOn IS NULL
	AND I.InvoiceDate < @StartDate
	AND I.Released>0
	AND I.InvoiceTypeID<3 --Don't include Credits as postive amounts
	AND I.DontShowOnStatement=0
	AND (BC.IsPrimaryBillingContact=1 OR BC.BillingContactID IN (SELECT DISTINCT BillingContactID FROM InvoiceSplitBillingContacts WHERE IsPrimaryBillingContact=1))
	GROUP BY I.InvoiceID, I.InvoiceNumber, I.InvoiceDate, I.InvoiceTypeID, IT.InvoiceTypeDesc, I.Amount,
	BC.IsPrimaryBillingContact, BC.BillingContactID, BC.ContactName, BC.ContactAddress1,
	BC.ClientContactID, BC.ClientID, BC.ContactEmail, BC.DeliveryMethod
	) A
	LEFT JOIN 
		(SELECT IP2.InvoiceID, IP2.Amount as PaymentsAmount, P2.[Date] 
			FROM InvoicePayments IP2
			INNER JOIN Payments P2 
				ON P2.PaymentID=IP2.PaymentID 
			WHERE [Date] < @StartDate --Only include payments in the previous period to lower the amount due
		) B
		ON B.InvoiceID=A.InvoiceID
	INNER JOIN ClientContacts CC ON CC.ClientContactID=A.ClientContactID
	INNER JOIN Clients C ON A.ClientID=C.ClientID
	WHERE C.BillAsClientName IS NOT NULL
	GROUP BY A.InvoiceID, A.InvoiceNumber, A.InvoiceDate, A.InvoiceTypeID, A.InvoiceTypeDesc, A.Amount, 
	A.CreditsAmount, CC.ClientContactID, A.ContactName, A.ContactAddress1, 
	A.IsPrimaryBillingContact, A.BillingContactID, C.BillAsClientName, A.ContactEmail, A.DeliveryMethod,
	C.BillingGroup

UNION ALL 

	--Overpayment Credit
	SELECT CC.ClientContactID, C.BillAsClientName, ISNULL(BC.ContactName,BC.ContactAddress1) as ContactName,
	0 - (TotalAmount - (SELECT ISNULL(SUM(IP.Amount),0) FROM InvoicePayments IP WHERE IP.PaymentID=P.PaymentID)) 
	as [Amount], 
	1 as PrimaryBillingContact, BC.BillingContactID, BC.ContactEmail, BC.DeliveryMethod,
	2 as CurrentActivity, C.BillingGroup
	FROM Payments P
	INNER JOIN BillingContacts BC ON BC.BillingContactID=P.BillingContactID
	INNER JOIN ClientContacts CC ON CC.ClientContactID=BC.ClientContactID
	INNER JOIN Clients C ON CC.ClientID=C.ClientID
	WHERE 
	/*BC.HideFromClient=0
	AND*/ C.BillAsClientName IS NOT NULL
	--AND BC.OnlyShowInvoices=0
	AND TotalAmount - (SELECT ISNULL(SUM(IP.Amount),0) FROM InvoicePayments IP WHERE IP.PaymentID=P.PaymentID) > 0
	AND NOT EXISTS (SELECT 1 FROM Invoices I INNER JOIN InvoiceBillingContacts IBC 
		ON IBC.InvoiceID=I.InvoiceID
		WHERE I.InvoiceTypeID=4 AND IBC.BillingContactID=BC.BillingContactID)
	AND (BC.IsPrimaryBillingContact=1 OR BC.BillingContactID IN (SELECT DISTINCT BillingContactID FROM InvoiceSplitBillingContacts WHERE IsPrimaryBillingContact=1))

UNION ALL

	--Credit Memo not conencted to an Invoice and there is no Beginning Balance
	SELECT CC.ClientContactID, C.BillAsClientName, ISNULL(BC.ContactName,BC.ContactAddress1) as ContactName,
	0 - I.Amount as Amount,
	1 as PrimaryBillingContact, BC.BillingContactID, BC.ContactEmail, BC.DeliveryMethod,
	2 as CurrentActivity, C.BillingGroup
	FROM Invoices I 
	INNER JOIN InvoiceTypes IT 
		ON I.InvoiceTypeID=IT.InvoiceTypeID
	INNER JOIN InvoiceBillingContacts IBC 
		ON IBC.InvoiceID=I.InvoiceID
	INNER JOIN BillingContacts BC 
		ON BC.BillingContactID=IBC.BillingContactID
		 AND IBC.IsPrimaryBillingContact=1
	INNER JOIN ClientContacts CC 
		ON CC.ClientContactID=BC.ClientContactID
	INNER JOIN Clients C 
		ON CC.ClientID=C.ClientID
	WHERE I.InvoiceTypeID=3 AND I.RelatedInvoiceID IS NULL
	AND I.InvoiceDate < @StartDate
	AND NOT EXISTS (SELECT 1 FROM Invoices I INNER JOIN InvoiceBillingContacts IBC 
		ON IBC.InvoiceID=I.InvoiceID
		WHERE I.InvoiceTypeID=4 AND IBC.BillingContactID=BC.BillingContactID)
	AND (BC.IsPrimaryBillingContact=1 OR BC.BillingContactID IN (SELECT DISTINCT BillingContactID FROM InvoiceSplitBillingContacts WHERE IsPrimaryBillingContact=1))

UNION ALL

	--Beginning Balance
	SELECT CC.ClientContactID, C.BillAsClientName, ISNULL(BC.ContactName,BC.ContactAddress1) as ContactName,
	MAX(I.Amount) - ISNULL(SUM(ISNULL(IP.Amount,0)),0) - ISNULL(MAX(CreditAmount),0)
	as Amount,
	1 as PrimaryBillingContact, BC.BillingContactID, BC.ContactEmail, BC.DeliveryMethod,
	(CASE WHEN MAX(I.Amount) < (ISNULL(SUM(ISNULL(IP.Amount,0)),0) - ISNULL(MAX(CreditAmount),0)) THEN 2 ELSE 0 END) as CurrentActivity,
	C.BillingGroup
	FROM Invoices I INNER JOIN InvoiceTypes IT ON I.InvoiceTypeID=IT.InvoiceTypeID
	INNER JOIN InvoiceBillingContacts IBC ON IBC.InvoiceID=I.InvoiceID
	INNER JOIN BillingContacts BC ON BC.BillingContactID=IBC.BillingContactID AND IBC.IsPrimaryBillingContact=1
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
	WHERE VoidedOn IS NULL 
	--AND BC.HideFromClient=0
	--AND BC.OnlyShowInvoices=0
	AND I.InvoiceTypeID=4
	AND I.Released>0
	AND C.BillAsClientName IS NOT NULL
	AND (BC.IsPrimaryBillingContact=1 OR BC.BillingContactID IN (SELECT DISTINCT BillingContactID FROM InvoiceSplitBillingContacts WHERE IsPrimaryBillingContact=1))
	GROUP BY CC.ClientContactID, C.ClientName, BC.ContactName,BC.ContactAddress1, 
	BC.IsPrimaryBillingContact, BC.BillingContactID, C.BillAsClientName, BC.ContactEmail, 
	BC.DeliveryMethod, C.BillingGroup
*/

) A
LEFT JOIN BillingPackagePrinted BPP
	ON BPP.BillingContactID=A.BillingContactID
	AND BPP.PackageEndDate=@EndDate
WHERE A.BillingContactID NOT IN (SELECT DISTINCT IBC.BillingContactID FROM Invoices I INNER JOIN InvoiceBillingContacts IBC ON I.InvoiceID=IBC.InvoiceID WHERE Released=0 AND VoidedOn IS NULL and I.InvoiceDate between @StartDate and @EndDate)
AND (A.BillingGroup=@BillingGroup OR @BillingGroup=0)
GROUP BY A.ClientContactID, A.BillAsClientName, A.ContactName, A.PrimaryBillingContact, A.BillingContactID, A.ContactEmail, A.DeliveryMethod
HAVING A.DeliveryMethod > 0
UNION ALL

SELECT CC.ClientContactID, BillAsClientName, ISNULL(BC.ContactName,BC.ContactAddress1) as ContactName, 
0 as Amount, 0 as PrimaryBillingContact,
@EndDate as StatementDate, BC.BillingContactID, BC.ContactEmail, 
CASE 
	WHEN BC.DeliveryMethod = 0 THEN 'Online'
	WHEN BC.DeliveryMethod = 1 THEN 'Email-Auto'
	WHEN BC.DeliveryMethod = 2 THEN 'Email'
	WHEN BC.DeliveryMethod = 3 THEN 'Mail'
END as DeliveryMethod,  
MAX(BPP.PrintedOn) as LastPrintedOn, 
3 as CurrentActivity
FROM
Invoices I
INNER JOIN InvoiceBillingContacts IBC
	ON I.InvoiceID=IBC.InvoiceID
INNER JOIN BillingContacts BC
	ON IBC.BillingContactID=BC.BillingContactID
INNER JOIN ClientContacts CC 
	ON CC.ClientContactID=BC.ClientContactID
INNER JOIN Clients C
	ON C.ClientID=I.ClientID
LEFT JOIN BillingPackagePrinted BPP
	ON BPP.BillingContactID=IBC.BillingContactID
	AND BPP.PackageEndDate=@EndDate
WHERE VoidedOn IS NULL AND I.InvoiceTypeID=1
AND InvoiceDate BETWEEN @StartDate AND @EndDate
--AND BC.HideFromClient=0
--AND BC.OnlyShowInvoices=0
AND I.Released>0
AND C.BillAsClientName IS NOT NULL
AND (C.BillingGroup=@BillingGroup OR @BillingGroup=0)
AND BC.DeliveryMethod > 0
AND BC.IsPrimaryBillingContact = 0
AND BC.BillingContactID NOT IN (SELECT DISTINCT IBC.BillingContactID FROM Invoices I INNER JOIN InvoiceBillingContacts IBC ON I.InvoiceID=IBC.InvoiceID WHERE Released=0 AND VoidedOn IS NULL and I.InvoiceDate between @StartDate and @EndDate)
AND BC.BillingContactID NOT IN (SELECT DISTINCT BillingContactID FROM InvoiceSplitBillingContacts WHERE IsPrimaryBillingContact=1)

GROUP BY CC.ClientContactID, C.BillAsClientName, BC.ContactName, BC.ContactAddress1, BC.BillingContactID, BC.ContactEmail,
BC.DeliveryMethod
ORDER BY BillAsClientName, ContactName

GO
