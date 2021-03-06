/****** Object:  StoredProcedure [dbo].[S1_Clients_GetClientsWithUnInvoicedProductTransactions]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC S1_Clients_GetClientsWithUnInvoicedProductTransactions  '03/01/2012', '03/31/2012'

CREATE PROCEDURE [dbo].[S1_Clients_GetClientsWithUnInvoicedProductTransactions]

	@StartDate datetime,
	@EndDate datetime
	
AS
	SET NOCOUNT ON;
	
DECLARE @tmp_Clients TABLE
(
	ClientID int
)

INSERT INTO @tmp_Clients
SELECT distinct C.ClientID
	FROM ProductTransactions PT
	INNER JOIN Products P
		ON PT.ProductID=P.ProductID
	INNER JOIN Clients C
		ON C.ClientID=PT.ClientID
	INNER JOIN ClientProducts CP
			ON CP.ClientID=PT.ClientID
			AND CP.ProductID=PT.ProductID
	WHERE PT.Invoiced=0
	AND C.ClientID not in (select ClientID from InvoiceSplit)
	AND (C.ParentClientID is null or C.ParentClientID not in (select ClientID from ClientInvoiceSettings where SplitByMode = 2))
	AND PT.TransactionDate BETWEEN @StartDate AND @EndDate
	AND (CASE
		WHEN CP.IncludeOnInvoice = 2 AND ((CP.ImportsAtBaseOrSales=0 AND ISNULL(CP.SalesPrice,0) = 0) OR (CP.ImportsAtBaseOrSales=1 AND ISNULL(PT.ProductPrice,0) = 0)) THEN 0
		WHEN CP.IncludeOnInvoice = 2 AND ((CP.ImportsAtBaseOrSales=0 AND ISNULL(CP.SalesPrice,0) > 0) OR (CP.ImportsAtBaseOrSales=1 AND ISNULL(PT.ProductPrice,0) > 0)) THEN 0
		WHEN CP.IncludeOnInvoice = 0 THEN 1 
		WHEN (CP.IncludeOnInvoice = 1 AND CP.ImportsAtBaseOrSales=0 AND ISNULL(CP.SalesPrice,0) > 0) THEN 1 
		WHEN (CP.IncludeOnInvoice = 1 AND CP.ImportsAtBaseOrSales=1 AND ISNULL(PT.ProductPrice,0) > 0) THEN 1
		ELSE 0 END = 1)
	AND C.DoNotInvoice = 0

	
SELECT C.ClientID,
CASE c.DoNotInvoice when 1 
	then C.ClientName + ' *' 
	else C.ClientName 
end as ClientName
FROM dbo.Clients C
INNER JOIN BillingGroups BG
	ON C.BillingGroup=BG.BillingGroupID
INNER JOIN ProductTransactions PT 
	ON PT.ClientID=C.ClientID
WHERE PT.Invoiced = 0
AND C.ClientID in (select ClientID from @tmp_Clients)
GROUP BY c.clientname, C.ClientID, C.DoNotInvoice
ORDER BY ClientName

GO
