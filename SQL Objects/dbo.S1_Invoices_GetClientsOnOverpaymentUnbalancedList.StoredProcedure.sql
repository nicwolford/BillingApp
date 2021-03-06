/****** Object:  StoredProcedure [dbo].[S1_Invoices_GetClientsOnOverpaymentUnbalancedList]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





--EXEC S1_Invoices_GetClientsOnOverpaymentUnbalancedList

CREATE PROCEDURE [dbo].[S1_Invoices_GetClientsOnOverpaymentUnbalancedList]

AS
	SET NOCOUNT ON;



	--Unbalanced report query
	select A.ClientID,'Type' = 'Unbalanced'
	from QBBalanceSummary q
	right join
	(SELECT BillAsClientName, SUM(Amount) as TotalAmount,ClientID,ParentClientID
	FROM (
	SELECT c.BillAsClientName, BC.BillingContactID, InvoiceDate as [Date], IT.InvoiceTypeDesc as [Type], InvoiceNumber,
	(CASE WHEN I.InvoiceTypeID=3 THEN 0 - Amount ELSE Amount END) as Amount,
	(CASE WHEN InvoiceDate>'7/31/2010' THEN
	(CASE WHEN I.InvoiceTypeID IN (3,5) THEN 0 ELSE I.InvoiceID END)
	ELSE 0 END) as LinkID,C.ClientID,C.ParentClientID
	FROM Invoices I INNER JOIN InvoiceTypes IT ON I.InvoiceTypeID=IT.InvoiceTypeID
	INNER JOIN InvoiceBillingContacts IBC
	ON IBC.InvoiceID=I.InvoiceID
	INNER JOIN BillingContacts BC
	ON BC.BillingContactID=IBC.BillingContactID AND IBC.IsPrimaryBillingContact=1
	INNER JOIN ClientContacts CC
	ON CC.ClientContactID=BC.ClientContactID
	INNER JOIN Clients C
	ON I.ClientID=C.ClientID
	WHERE VoidedOn IS NULL AND I.InvoiceTypeID<>2
	AND I.Released>0
	AND BC.HideFromClient=0
	AND C.DoNotInvoice=0

	UNION ALL

	SELECT c.BillAsClientName, BC.BillingContactID, I.InvoiceDate as [Date], IT.InvoiceTypeDesc as [Type], ISNULL(I.InvoiceNumber,''), I.Amount,
	0 as LinkID,C.ClientID,C.ParentClientID
	FROM Invoices I
	INNER JOIN InvoiceTypes IT
	ON I.InvoiceTypeID=IT.InvoiceTypeID
	INNER JOIN InvoiceBillingContacts IBC
	ON IBC.InvoiceID=I.InvoiceID
	INNER JOIN BillingContacts BC
	ON BC.BillingContactID=IBC.BillingContactID AND IBC.IsPrimaryBillingContact=1
	INNER JOIN ClientContacts CC
	ON CC.ClientContactID=BC.ClientContactID
	INNER JOIN Clients C
	ON I.ClientID=C.ClientID
	LEFT JOIN Invoices I2
	ON I2.InvoiceID=I.RelatedInvoiceID
	WHERE I.VoidedOn IS NULL AND I.InvoiceTypeID=2
	AND I.Released>0
	AND BC.HideFromClient=0
	AND C.DoNotInvoice=0

	UNION ALL

	SELECT c.BillAsClientName, BC.BillingContactID, P.[Date], 'Payment' as [Type], '' as InvoiceNumber, 0 - P.TotalAmount, 0 as LinkID,C.ClientID,C.ParentClientID
	FROM Payments P
	INNER JOIN BillingContacts BC ON
	BC.BillingContactID=P.BillingContactID
	INNER JOIN ClientContacts CC
	ON CC.ClientContactID=BC.ClientContactID
	INNER JOIN Clients C
	ON CC.ClientID=C.ClientID
	WHERE BC.HideFromClient=0
	AND C.DoNotInvoice=0
	) A
	GROUP BY BillAsClientName,ClientID,ParentClientID
	) a
	on a.BillAsClientName = q.Client
	Where ISNULL(q.amount,0) - a.TotalAmount <> 0

UNION ALL
	---overpayment report query
	SELECT A.ClientID,'Type'='Overpayment'
	FROM
	(
	--Overpayment Credit
	SELECT CC.ClientContactID, C.BillAsClientName, ISNULL(BC.ContactName,BC.ContactAddress1) as ContactName,
	0 - (TotalAmount - (SELECT ISNULL(SUM(IP.Amount),0) FROM InvoicePayments IP WHERE IP.PaymentID=P.PaymentID)) 
	as [Amount], 
	BC.IsPrimaryBillingContact as PrimaryBillingContact, BC.BillingContactID, BC.ContactEmail, BC.DeliveryMethod,
	2 as CurrentActivity,C.ClientID,C.ParentClientID
	FROM Payments P
	INNER JOIN BillingContacts BC ON BC.BillingContactID=P.BillingContactID
	INNER JOIN ClientContacts CC ON CC.ClientContactID=BC.ClientContactID
	INNER JOIN Clients C ON CC.ClientID=C.ClientID
	WHERE 
	/*BC.HideFromClient=0
	AND*/ C.BillAsClientName IS NOT NULL
	--AND BC.OnlyShowInvoices=0
	--AND C.BillingGroup=1
	--AND C.AuditInvoices=0
	AND TotalAmount - (SELECT ISNULL(SUM(IP.Amount),0) FROM InvoicePayments IP WHERE IP.PaymentID=P.PaymentID) > 0
	AND NOT EXISTS (SELECT 1 FROM Invoices I INNER JOIN InvoiceBillingContacts IBC 
		  ON IBC.InvoiceID=I.InvoiceID
		  WHERE I.InvoiceTypeID=4 AND IBC.BillingContactID=BC.BillingContactID)
	AND (BC.IsPrimaryBillingContact=1 OR BC.BillingContactID IN (SELECT DISTINCT BillingContactID FROM InvoiceSplitBillingContacts WHERE IsPrimaryBillingContact=1))
	 
	UNION ALL
	 
	--Credit Memo not conencted to an Invoice and there is no Beginning Balance
	SELECT CC.ClientContactID, C.BillAsClientName, ISNULL(BC.ContactName,BC.ContactAddress1) as ContactName,
	0 - I.Amount as Amount,
	BC.IsPrimaryBillingContact as PrimaryBillingContact, BC.BillingContactID, BC.ContactEmail, BC.DeliveryMethod,
	2 as CurrentActivity,C.ClientID,C.ParentClientID
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
	--AND C.BillingGroup=1
	--AND C.AuditInvoices=0
	AND I.InvoiceDate < GETDATE()
	AND NOT EXISTS (SELECT 1 FROM Invoices I INNER JOIN InvoiceBillingContacts IBC 
		  ON IBC.InvoiceID=I.InvoiceID
		  WHERE I.InvoiceTypeID=4 AND IBC.BillingContactID=BC.BillingContactID)
	AND (BC.IsPrimaryBillingContact=1 OR BC.BillingContactID IN (SELECT DISTINCT BillingContactID FROM InvoiceSplitBillingContacts WHERE IsPrimaryBillingContact=1))
	 
	UNION ALL
	 
	--Beginning Balance
	SELECT CC.ClientContactID, C.BillAsClientName, ISNULL(BC.ContactName,BC.ContactAddress1) as ContactName,
	MAX(I.Amount) - ISNULL(SUM(ISNULL(IP.Amount,0)),0) - ISNULL(MAX(CreditAmount),0)
	as Amount,
	BC.IsPrimaryBillingContact as PrimaryBillingContact, BC.BillingContactID, BC.ContactEmail, BC.DeliveryMethod,
	(CASE WHEN MAX(I.Amount) < (ISNULL(SUM(ISNULL(IP.Amount,0)),0) - ISNULL(MAX(CreditAmount),0)) THEN 2 ELSE 0 END) as CurrentActivity
	,C.ClientID,C.ParentClientID
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
	--AND C.BillingGroup=1
	--AND C.AuditInvoices=0
	AND I.Released>0
	AND C.BillAsClientName IS NOT NULL
	AND (BC.IsPrimaryBillingContact=1 OR BC.BillingContactID IN (SELECT DISTINCT BillingContactID FROM InvoiceSplitBillingContacts WHERE IsPrimaryBillingContact=1))
	GROUP BY CC.ClientContactID, C.ClientName, BC.ContactName,BC.ContactAddress1, 
	BC.IsPrimaryBillingContact, BC.BillingContactID, C.BillAsClientName, BC.ContactEmail, BC.DeliveryMethod,C.ClientID,C.ParentClientID
	) A
	LEFT JOIN BillingPackagePrinted BPP
		  ON BPP.BillingContactID=A.BillingContactID
		  AND BPP.PackageEndDate=getdate()
	GROUP BY A.ClientContactID, A.BillAsClientName, A.ContactName, A.PrimaryBillingContact, A.BillingContactID, A.ContactEmail, A.DeliveryMethod,A.ClientID,A.ParentClientID
	HAVING MAX(A.CurrentActivity) = 2
	ORDER BY ClientID







GO
