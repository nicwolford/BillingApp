/****** Object:  StoredProcedure [dbo].[S1_Clients_GetClientList]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC S1_Clients_GetClientList 

CREATE PROCEDURE [dbo].[S1_Clients_GetClientList]

AS
	SET NOCOUNT ON;
    DECLARE @StartDate datetime
    DECLARE @EndDate datetime     
     
    SET @StartDate='9/2/2010'
    SET @EndDate='10/1/2010'

	
SELECT C.ClientID,C.ClientName,C.Address1,C.Address2,c.City, c.[State], c.ZipCode, 
c.ParentClientID, ISNULL(C2.ClientName,'') as ParentClientName,
C.BillAsClientName,BG.BillingGroupID,BG.BillingGroupName,C.[Status], case when sum(ClientBalances.TotalAmount) is null then 0 else sum(ClientBalances.TotalAmount) end as CurrentBalance
FROM dbo.Clients C
INNER JOIN BillingGroups BG
	ON C.BillingGroup=BG.BillingGroupID
LEFT JOIN Clients C2
	ON C2.ClientID=C.ParentClientID
LEFT JOIN (
SELECT ClientID, SUM(Amount) as TotalAmount
FROM (
SELECT C.ClientID, BC.BillingContactID, InvoiceDate as [Date], IT.InvoiceTypeDesc as [Type], InvoiceNumber, 
(CASE WHEN I.InvoiceTypeID=3 THEN 0 - Amount ELSE Amount END) as Amount,
(CASE WHEN InvoiceDate>'7/31/2010' THEN 
      (CASE WHEN I.InvoiceTypeID IN (3,5) THEN 0 ELSE I.InvoiceID END)
ELSE 0 END) as LinkID
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
 
UNION ALL
 
SELECT C.ClientID, BC.BillingContactID, I.InvoiceDate as [Date], IT.InvoiceTypeDesc as [Type], ISNULL(I.InvoiceNumber,''), I.Amount,
0 as LinkID
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
 
UNION ALL
 
SELECT C.ClientID, BC.BillingContactID, P.[Date], 'Payment' as [Type], '' as InvoiceNumber, 0 - P.TotalAmount, 0 as LinkID 
FROM Payments P
INNER JOIN BillingContacts BC ON 
      BC.BillingContactID=P.BillingContactID
INNER JOIN ClientContacts CC 
      ON CC.ClientContactID=BC.ClientContactID
INNER JOIN Clients C 
      ON CC.ClientID=C.ClientID
WHERE BC.HideFromClient=0
) A
GROUP BY ClientID

) ClientBalances on ClientBalances.ClientID = C.ClientID
GROUP BY C.ClientID,C.ClientName,C.Address1,C.Address2,c.City, c.[State], c.ZipCode, 
c.ParentClientID, C2.ClientName,C.BillAsClientName,BG.BillingGroupID,BG.BillingGroupName,C.[Status]
ORDER BY C.ClientName


GO
