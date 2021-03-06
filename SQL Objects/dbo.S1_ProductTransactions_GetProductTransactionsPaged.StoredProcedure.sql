/****** Object:  StoredProcedure [dbo].[S1_ProductTransactions_GetProductTransactionsPaged]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--S1_ProductTransactions_GetProductTransactionsPaged 0, 2, 1, 103, 'ProductPrice', 0

CREATE PROCEDURE [dbo].[S1_ProductTransactions_GetProductTransactionsPaged]
(
	@Status int,
	@ClientID int,
	@StartDate datetime,
	@EndDate datetime,
	@FileNum varchar(50),
	@CurrentPage int,
	@RowsPerPage int,
	@OrderBy varchar(50),
	@OrderDir bit
)
AS
	SET NOCOUNT ON;
	
DECLARE @FirstRow int, @LastRow int
SELECT @FirstRow=((@CurrentPage-1)*@RowsPerPage)+1
SELECT @LastRow=@FirstRow+(@RowsPerPage-1)

/*
SELECT PT.ProductTransactionID, PT.FileNum, PT.OrderBy, PT.Reference, PT.DateOrdered, 
PT.FName, PT.LName, PT.MName, PT.ProductID, PT.ProductDescription, PT.ProductType, 
P.ProductName, PT.ProductPrice, PT.ExternalInvoiceNumber, PT.SalesRep, PT.ClientID,
C.ClientName,
0 as rownum,
0 as Number
FROM ProductTransactions PT
INNER JOIN Products P
	ON PT.ProductID=P.ProductID
INNER JOIN Clients C
	ON C.ClientID=PT.ClientID
WHERE P.ExcludeFromBill=0
AND (@ClientID=0 OR C.ClientID=@ClientID)	
*/

IF (@OrderDir=0)
BEGIN
	
	IF (@Status=0)
	BEGIN
	--All Transactions
	WITH CTE (ProductTransactionID, FileNum, OrderBy, Reference, TransactionDate, DateOrdered,
	FName, LName, MName, ProductID, ProductDescription, ProductType, ProductName, 
	ProductPrice, ExternalInvoiceNumber, SalesRep, ClientID, ClientName,IncludeOnInvoice, rownum, Number)
	AS (
	SELECT PT.ProductTransactionID, PT.FileNum, PT.OrderBy, PT.Reference, PT.TransactionDate, PT.DateOrdered, 
	PT.FName, PT.LName, PT.MName, PT.ProductID, PT.ProductDescription, PT.ProductType, 
	P.ProductName, 
	(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN ISNULL(CP.SalesPrice,0) ELSE ISNULL(PT.ProductPrice,0) END) 
	AS ProductPrice, PT.ExternalInvoiceNumber, PT.SalesRep, PT.ClientID,
	C.ClientName,CP.IncludeOnInvoice,
	rownum = ROW_NUMBER() OVER (ORDER BY 
	(CASE 
		WHEN @OrderBy='DateOrdered' THEN CONVERT(char(8),PT.DateOrdered,112) 
		WHEN @OrderBy='ProductType' THEN PT.ProductType
		WHEN @OrderBy='ClientName' THEN C.ClientName
		WHEN @OrderBy='ProductDescription' THEN PT.ProductDescription
		WHEN @OrderBy='ProductPrice' THEN right('0000000000'+ltrim(Convert(varchar(10),PT.ProductPrice)),10)
		WHEN @OrderBy='FileNum' THEN PT.FileNum
		ELSE CONVERT(char(8),PT.DateOrdered,112)  
	END
	)
	ASC,C.ClientID),
	COUNT(*) OVER () as Number
	FROM ProductTransactions PT
	INNER JOIN Products P
		ON PT.ProductID=P.ProductID
	INNER JOIN Clients C
		ON C.ClientID=PT.ClientID
	INNER JOIN ClientProducts CP
		ON CP.ClientID=PT.ClientID
		AND CP.ProductID=PT.ProductID
	WHERE (@ClientID=0 OR C.ClientID=@ClientID)
	AND PT.TransactionDate BETWEEN @StartDate AND @EndDate
	AND (PT.FileNum=@FileNum OR @FileNum='')
	)
	SELECT *
	FROM CTE
	WHERE rownum BETWEEN @FirstRow AND @LastRow
	ORDER BY rownum

	END
	ELSE IF (@Status=1)
	BEGIN

	--New Transactions
	WITH CTE (ProductTransactionID, FileNum, OrderBy, Reference, TransactionDate, DateOrdered,
	FName, LName, MName, ProductID, ProductDescription, ProductType, ProductName, 
	ProductPrice, ExternalInvoiceNumber, SalesRep, ClientID, ClientName,IncludeOnInvoice, rownum, Number)
	AS (
	SELECT A.*,
	rownum = ROW_NUMBER() OVER (ORDER BY 
	(CASE 
		WHEN @OrderBy='DateOrdered' THEN CONVERT(char(8),DateOrdered,112) 
		WHEN @OrderBy='ProductType' THEN ProductType
		WHEN @OrderBy='ClientName' THEN ClientName
		WHEN @OrderBy='ProductDescription' THEN ProductDescription
		WHEN @OrderBy='ProductPrice' THEN right('0000000000'+ltrim(Convert(varchar(10),ProductPrice)),10)
		WHEN @OrderBy='FileNum' THEN FileNum
		ELSE CONVERT(char(8),DateOrdered,112)  
	END
	) ASC,ClientID),
	COUNT(*) OVER () as Number
	FROM (
	SELECT PT.ProductTransactionID, PT.FileNum, PT.OrderBy, PT.Reference, PT.TransactionDate, PT.DateOrdered, 
	PT.FName, PT.LName, PT.MName, PT.ProductID, PT.ProductDescription, PT.ProductType, 
	P.ProductName, 
	(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN ISNULL(CP.SalesPrice,0) ELSE ISNULL(PT.ProductPrice,0) END) 
	AS ProductPrice, PT.ExternalInvoiceNumber, PT.SalesRep, PT.ClientID,
	C.ClientName,CP.IncludeOnInvoice
	FROM ProductTransactions PT
	INNER JOIN Products P
		ON PT.ProductID=P.ProductID
	INNER JOIN Clients C
		ON C.ClientID=PT.ClientID
	INNER JOIN ClientProducts CP
		ON CP.ClientID=PT.ClientID
		AND CP.ProductID=PT.ProductID
	WHERE PT.Invoiced=0
	AND (PT.FileNum=@FileNum OR @FileNum='')
	AND (@ClientID=0 OR C.ClientID=@ClientID)
	AND CP.IncludeOnInvoice<>2
	AND (CP.IncludeOnInvoice<>1 OR PT.ProductPrice<>0 OR 
	(CP.ImportsAtBaseOrSales=0 AND CP.SalesPrice<>0))
	AND PT.TransactionDate BETWEEN @StartDate AND @EndDate
	/*UNION ALL
	SELECT PT.ProductTransactionID, PT.FileNum, PT.OrderBy, PT.Reference, PT.TransactionDate, PT.DateOrdered, 
	PT.FName, PT.LName, PT.MName, PT.ProductID, PT.ProductDescription, PT.ProductType, 
	P.ProductName, 
	(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN ISNULL(CP.SalesPrice,0) ELSE ISNULL(PT.ProductPrice,0) END) 
	AS ProductPrice, PT.ExternalInvoiceNumber, PT.SalesRep, PT.ClientID,
	C.ClientName
	FROM ProductTransactions PT
	INNER JOIN Products P
		ON PT.ProductID=P.ProductID
	INNER JOIN Clients C
		ON C.ClientID=PT.ClientID	
	INNER JOIN ClientProducts CP
		ON CP.ClientID=PT.ClientID
		AND CP.ProductID=PT.ProductID	
	WHERE NOT EXISTS (SELECT 1 FROM ProductsOnInvoice POI WHERE POI.ProductTransactionID=PT.ProductTransactionID)
	AND (@ClientID=0 OR C.ClientID=@ClientID)
	AND CP.IncludeOnInvoice<>2
	AND (CP.IncludeOnInvoice<>1 OR PT.ProductPrice<>0)
	AND PT.TransactionDate BETWEEN @StartDate AND @EndDate*/
	) AS A
	)
	SELECT *
	FROM CTE
	WHERE rownum BETWEEN @FirstRow AND @LastRow
	ORDER BY rownum

	END
	ELSE IF (@Status=2)
	BEGIN

	--Invoiced Transactions
	WITH CTE (ProductTransactionID, FileNum, OrderBy, Reference, TransactionDate, DateOrdered,
	FName, LName, MName, ProductID, ProductDescription, ProductType, ProductName, 
	ProductPrice, ExternalInvoiceNumber, SalesRep, ClientID, ClientName,IncludeOnInvoice, rownum, Number)
	AS (

	SELECT PT.ProductTransactionID, PT.FileNum, PT.OrderBy, PT.Reference, PT.TransactionDate, PT.DateOrdered, 
	PT.FName, PT.LName, PT.MName, PT.ProductID, PT.ProductDescription, PT.ProductType, 
	P.ProductName, 
	(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN ISNULL(CP.SalesPrice,0) ELSE ISNULL(PT.ProductPrice,0) END) 
	AS ProductPrice, PT.ExternalInvoiceNumber, PT.SalesRep, PT.ClientID,
	C.ClientName,CP.IncludeOnInvoice,
	rownum = ROW_NUMBER() OVER (ORDER BY 
	(CASE 
		WHEN @OrderBy='DateOrdered' THEN CONVERT(char(8),PT.DateOrdered,112) 
		WHEN @OrderBy='ProductType' THEN PT.ProductType
		WHEN @OrderBy='ClientName' THEN C.ClientName
		WHEN @OrderBy='ProductDescription' THEN PT.ProductDescription
		WHEN @OrderBy='ProductPrice' THEN right('0000000000'+ltrim(Convert(varchar(10),PT.ProductPrice)),10)
		WHEN @OrderBy='FileNum' THEN PT.FileNum
		ELSE CONVERT(char(8),PT.DateOrdered,112)  
	END
	) ASC,C.ClientID),
	COUNT(*) OVER () as Number
	FROM ProductTransactions PT
	INNER JOIN ProductsOnInvoice POI
		ON PT.ProductTransactionID=POI.ProductTransactionID
	INNER JOIN Invoices I
		ON POI.InvoiceID=I.InvoiceID
	INNER JOIN Products P
		ON PT.ProductID=P.ProductID
	INNER JOIN Clients C
		ON C.ClientID=PT.ClientID
	INNER JOIN ClientProducts CP
		ON CP.ClientID=PT.ClientID
		AND CP.ProductID=PT.ProductID	
	WHERE PT.Invoiced=1
	AND (PT.FileNum=@FileNum OR @FileNum='')
	AND (@ClientID=0 OR C.ClientID=@ClientID)
	AND PT.TransactionDate BETWEEN @StartDate AND @EndDate
	)
	SELECT *
	FROM CTE
	WHERE rownum BETWEEN @FirstRow AND @LastRow
	ORDER BY rownum

	END
	
	ELSE IF (@Status=3)
	BEGIN

	--UnInvoiced Transactions
	WITH CTE (ProductTransactionID, FileNum, OrderBy, Reference, TransactionDate, DateOrdered,
	FName, LName, MName, ProductID, ProductDescription, ProductType, ProductName, 
	ProductPrice, ExternalInvoiceNumber, SalesRep, ClientID, ClientName,IncludeOnInvoice, rownum, Number)
	AS (

	SELECT PT.ProductTransactionID, PT.FileNum, PT.OrderBy, PT.Reference, PT.TransactionDate, PT.DateOrdered, 
	PT.FName, PT.LName, PT.MName, PT.ProductID, PT.ProductDescription, PT.ProductType, 
	P.ProductName, 
	(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN ISNULL(CP.SalesPrice,0) ELSE ISNULL(PT.ProductPrice,0) END) 
	AS ProductPrice, PT.ExternalInvoiceNumber, PT.SalesRep, PT.ClientID,
	C.ClientName,CP.IncludeOnInvoice,
	rownum = ROW_NUMBER() OVER (ORDER BY 
	(CASE 
		WHEN @OrderBy='DateOrdered' THEN CONVERT(char(8),PT.DateOrdered,112) 
		WHEN @OrderBy='ProductType' THEN PT.ProductType
		WHEN @OrderBy='ClientName' THEN C.ClientName
		WHEN @OrderBy='ProductDescription' THEN PT.ProductDescription
		WHEN @OrderBy='ProductPrice' THEN right('0000000000'+ltrim(Convert(varchar(10),PT.ProductPrice)),10)
		WHEN @OrderBy='FileNum' THEN PT.FileNum
		ELSE CONVERT(char(8),PT.DateOrdered,112)  
	END
	) ASC,C.ClientID),
	COUNT(*) OVER () as Number
	FROM ProductTransactions PT
	INNER JOIN Products P
		ON PT.ProductID=P.ProductID
	LEFT JOIN ProductsOnInvoice POI
		ON PT.ProductTransactionID=POI.ProductTransactionID
	INNER JOIN Clients C
		ON C.ClientID=PT.ClientID
	INNER JOIN ClientProducts CP
		ON CP.ClientID=PT.ClientID
		AND CP.ProductID=PT.ProductID	
	WHERE PT.Invoiced=0
	AND (PT.FileNum=@FileNum OR @FileNum='')
	AND (@ClientID=0 OR C.ClientID=@ClientID)
	AND PT.TransactionDate BETWEEN @StartDate AND @EndDate
	AND (CASE
	WHEN CP.IncludeOnInvoice = 2 AND ((CP.ImportsAtBaseOrSales=0 AND ISNULL(CP.SalesPrice,0) = 0) OR (CP.ImportsAtBaseOrSales=1 AND ISNULL(PT.ProductPrice,0) = 0)) THEN 0
	WHEN CP.IncludeOnInvoice = 2 AND ((CP.ImportsAtBaseOrSales=0 AND ISNULL(CP.SalesPrice,0) > 0) OR (CP.ImportsAtBaseOrSales=1 AND ISNULL(PT.ProductPrice,0) > 0)) THEN 1
	WHEN CP.IncludeOnInvoice = 0 THEN 1 
	WHEN (CP.IncludeOnInvoice = 1 AND CP.ImportsAtBaseOrSales=0 AND ISNULL(CP.SalesPrice,0) > 0) THEN 1 
    WHEN (CP.IncludeOnInvoice = 1 AND CP.ImportsAtBaseOrSales=1 AND ISNULL(PT.ProductPrice,0) > 0) THEN 1
    ELSE 0 END = 1)

    )
	SELECT *
	FROM CTE
	WHERE rownum BETWEEN @FirstRow AND @LastRow
	ORDER BY rownum

	END

END
ELSE
BEGIN
	
IF (@Status=0)
BEGIN

--All Transactions
WITH CTE (ProductTransactionID, FileNum, OrderBy, Reference, TransactionDate, DateOrdered,
FName, LName, MName, ProductID, ProductDescription, ProductType, ProductName, 
ProductPrice, ExternalInvoiceNumber, SalesRep, ClientID, ClientName,IncludeOnInvoice, rownum, Number)
AS (
SELECT PT.ProductTransactionID, PT.FileNum, PT.OrderBy, PT.Reference, PT.TransactionDate, PT.DateOrdered, 
PT.FName, PT.LName, PT.MName, PT.ProductID, PT.ProductDescription, PT.ProductType, 
P.ProductName, 
(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN ISNULL(CP.SalesPrice,0) ELSE ISNULL(PT.ProductPrice,0) END) 
	AS ProductPrice, PT.ExternalInvoiceNumber, PT.SalesRep, PT.ClientID,
C.ClientName,CP.IncludeOnInvoice,
rownum = ROW_NUMBER() OVER (ORDER BY 
(CASE 
	WHEN @OrderBy='DateOrdered' THEN CONVERT(char(8),PT.DateOrdered,112) 
	WHEN @OrderBy='ProductType' THEN PT.ProductType
	WHEN @OrderBy='ClientName' THEN C.ClientName
	WHEN @OrderBy='ProductDescription' THEN PT.ProductDescription
	WHEN @OrderBy='ProductPrice' THEN right('0000000000'+ltrim(Convert(varchar(10),PT.ProductPrice)),10)
	WHEN @OrderBy='FileNum' THEN PT.FileNum
	ELSE CONVERT(char(8),PT.DateOrdered,112)  
END
)
DESC,C.ClientID),
COUNT(*) OVER () as Number
FROM ProductTransactions PT
INNER JOIN Products P
	ON PT.ProductID=P.ProductID
INNER JOIN Clients C
	ON C.ClientID=PT.ClientID
INNER JOIN ClientProducts CP
		ON CP.ClientID=PT.ClientID
		AND CP.ProductID=PT.ProductID	
WHERE (@ClientID=0 OR C.ClientID=@ClientID)
AND PT.TransactionDate BETWEEN @StartDate AND @EndDate
AND (PT.FileNum=@FileNum OR @FileNum='')
)
SELECT *
FROM CTE
WHERE rownum BETWEEN @FirstRow AND @LastRow
ORDER BY rownum


END
ELSE IF (@Status=1)
BEGIN

--New Transactions
WITH CTE (ProductTransactionID, FileNum, OrderBy, Reference, TransactionDate, DateOrdered,
FName, LName, MName, ProductID, ProductDescription, ProductType, ProductName, 
ProductPrice, ExternalInvoiceNumber, SalesRep, ClientID, ClientName,IncludeOnInvoice, rownum, Number)
AS (
SELECT A.*,
rownum = ROW_NUMBER() OVER (ORDER BY 
(CASE 
	WHEN @OrderBy='DateOrdered' THEN CONVERT(char(8),DateOrdered,112) 
	WHEN @OrderBy='ProductType' THEN ProductType
	WHEN @OrderBy='ClientName' THEN ClientName
	WHEN @OrderBy='ProductDescription' THEN ProductDescription
	WHEN @OrderBy='ProductPrice' THEN right('0000000000'+ltrim(Convert(varchar(10),ProductPrice)),10)
	WHEN @OrderBy='FileNum' THEN FileNum
	ELSE CONVERT(char(8),DateOrdered,112) 
END
) DESC,ClientID),
COUNT(*) OVER () as Number
FROM (
SELECT PT.ProductTransactionID, PT.FileNum, PT.OrderBy, PT.Reference, PT.TransactionDate, PT.DateOrdered, 
PT.FName, PT.LName, PT.MName, PT.ProductID, PT.ProductDescription, PT.ProductType, 
P.ProductName, 
(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN ISNULL(CP.SalesPrice,0) ELSE ISNULL(PT.ProductPrice,0) END) 
	AS ProductPrice, PT.ExternalInvoiceNumber, PT.SalesRep, PT.ClientID,
C.ClientName,CP.IncludeOnInvoice
FROM ProductTransactions PT
INNER JOIN Products P
	ON PT.ProductID=P.ProductID
INNER JOIN Clients C
	ON C.ClientID=PT.ClientID
INNER JOIN ClientProducts CP
		ON CP.ClientID=PT.ClientID
		AND CP.ProductID=PT.ProductID	
WHERE PT.Invoiced=0
	AND (PT.FileNum=@FileNum OR @FileNum='')
	AND (@ClientID=0 OR C.ClientID=@ClientID)
	AND CP.IncludeOnInvoice<>2
	AND (CP.IncludeOnInvoice<>1 OR PT.ProductPrice<>0 OR 
	(CP.ImportsAtBaseOrSales=0 AND CP.SalesPrice<>0))
AND PT.TransactionDate BETWEEN @StartDate AND @EndDate
/*UNION ALL
SELECT PT.ProductTransactionID, PT.FileNum, PT.OrderBy, PT.Reference, PT.TransactionDate, PT.DateOrdered, 
PT.FName, PT.LName, PT.MName, PT.ProductID, PT.ProductDescription, PT.ProductType, 
P.ProductName, 
(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN ISNULL(CP.SalesPrice,0) ELSE ISNULL(PT.ProductPrice,0) END) 
AS ProductPrice, PT.ExternalInvoiceNumber, PT.SalesRep, PT.ClientID,
C.ClientName
FROM ProductTransactions PT
INNER JOIN Products P
	ON PT.ProductID=P.ProductID
INNER JOIN Clients C
	ON C.ClientID=PT.ClientID	
INNER JOIN ClientProducts CP
		ON CP.ClientID=PT.ClientID
		AND CP.ProductID=PT.ProductID	
WHERE NOT EXISTS (SELECT 1 FROM ProductsOnInvoice POI WHERE POI.ProductTransactionID=PT.ProductTransactionID)
AND (@ClientID=0 OR C.ClientID=@ClientID)
AND CP.IncludeOnInvoice<>2
	AND (CP.IncludeOnInvoice<>1 OR PT.ProductPrice<>0)
AND PT.TransactionDate BETWEEN @StartDate AND @EndDate*/
) AS A
)
SELECT *
FROM CTE
WHERE rownum BETWEEN @FirstRow AND @LastRow
ORDER BY rownum

END
ELSE IF (@Status=2)
BEGIN

--Invoiced Transactions
WITH CTE (ProductTransactionID, FileNum, OrderBy, Reference, TransactionDate, DateOrdered,
FName, LName, MName, ProductID, ProductDescription, ProductType, ProductName, 
ProductPrice, ExternalInvoiceNumber, SalesRep, ClientID, ClientName,IncludeOnInvoice, rownum, Number)
AS (

SELECT PT.ProductTransactionID, PT.FileNum, PT.OrderBy, PT.Reference, PT.TransactionDate, PT.DateOrdered, 
PT.FName, PT.LName, PT.MName, PT.ProductID, PT.ProductDescription, PT.ProductType, 
P.ProductName, 
(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN ISNULL(CP.SalesPrice,0) ELSE ISNULL(PT.ProductPrice,0) END) 
	AS ProductPrice, PT.ExternalInvoiceNumber, PT.SalesRep, PT.ClientID,
C.ClientName,CP.IncludeOnInvoice,
rownum = ROW_NUMBER() OVER (ORDER BY 
(CASE 
	WHEN @OrderBy='DateOrdered' THEN CONVERT(char(8),PT.DateOrdered,112)  
	WHEN @OrderBy='ProductType' THEN PT.ProductType
	WHEN @OrderBy='ClientName' THEN C.ClientName
	WHEN @OrderBy='ProductDescription' THEN PT.ProductDescription
	WHEN @OrderBy='ProductPrice' THEN right('0000000000'+ltrim(Convert(varchar(10),PT.ProductPrice)),10)
	WHEN @OrderBy='FileNum' THEN PT.FileNum
	ELSE CONVERT(char(8),PT.DateOrdered,112)  
END
) DESC,C.ClientID),
COUNT(*) OVER () as Number
FROM ProductTransactions PT
INNER JOIN ProductsOnInvoice POI
	ON PT.ProductTransactionID=POI.ProductTransactionID
INNER JOIN Invoices I
	ON POI.InvoiceID=I.InvoiceID
INNER JOIN Products P
	ON PT.ProductID=P.ProductID
INNER JOIN Clients C
	ON C.ClientID=PT.ClientID
INNER JOIN ClientProducts CP
		ON CP.ClientID=PT.ClientID
		AND CP.ProductID=PT.ProductID
WHERE PT.Invoiced=1
AND (PT.FileNum=@FileNum OR @FileNum='')
AND (@ClientID=0 OR C.ClientID=@ClientID)
AND PT.TransactionDate BETWEEN @StartDate AND @EndDate
)
SELECT *
FROM CTE
WHERE rownum BETWEEN @FirstRow AND @LastRow
ORDER BY rownum

END
ELSE IF (@Status=3)
BEGIN

--UnInvoiced Transactions
WITH CTE (ProductTransactionID, FileNum, OrderBy, Reference, TransactionDate, DateOrdered,
FName, LName, MName, ProductID, ProductDescription, ProductType, ProductName, 
ProductPrice, ExternalInvoiceNumber, SalesRep, ClientID, ClientName,IncludeOnInvoice, rownum, Number)
AS (

SELECT PT.ProductTransactionID, PT.FileNum, PT.OrderBy, PT.Reference, PT.TransactionDate, PT.DateOrdered, 
PT.FName, PT.LName, PT.MName, PT.ProductID, PT.ProductDescription, PT.ProductType, 
P.ProductName, 
(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN ISNULL(CP.SalesPrice,0) ELSE ISNULL(PT.ProductPrice,0) END) 
	AS ProductPrice, PT.ExternalInvoiceNumber, PT.SalesRep, PT.ClientID,
C.ClientName,CP.IncludeOnInvoice,
rownum = ROW_NUMBER() OVER (ORDER BY 
(CASE 
	WHEN @OrderBy='DateOrdered' THEN CONVERT(char(8),PT.DateOrdered,112)  
	WHEN @OrderBy='ProductType' THEN PT.ProductType
	WHEN @OrderBy='ClientName' THEN C.ClientName
	WHEN @OrderBy='ProductDescription' THEN PT.ProductDescription
	WHEN @OrderBy='ProductPrice' THEN right('0000000000'+ltrim(Convert(varchar(10),PT.ProductPrice)),10)
	WHEN @OrderBy='FileNum' THEN PT.FileNum
	ELSE CONVERT(char(8),PT.DateOrdered,112)  
END
) DESC,C.ClientID),
COUNT(*) OVER () as Number
FROM ProductTransactions PT
LEFT JOIN ProductsOnInvoice POI
	ON PT.ProductTransactionID=POI.ProductTransactionID
INNER JOIN Products P
	ON PT.ProductID=P.ProductID
INNER JOIN Clients C
	ON C.ClientID=PT.ClientID
INNER JOIN ClientProducts CP
		ON CP.ClientID=PT.ClientID
		AND CP.ProductID=PT.ProductID
WHERE PT.Invoiced=0
AND (PT.FileNum=@FileNum OR @FileNum='')
AND (@ClientID=0 OR C.ClientID=@ClientID)
AND PT.TransactionDate BETWEEN @StartDate AND @EndDate
AND (CASE
	WHEN CP.IncludeOnInvoice = 2 AND ((CP.ImportsAtBaseOrSales=0 AND ISNULL(CP.SalesPrice,0) = 0) OR (CP.ImportsAtBaseOrSales=1 AND ISNULL(PT.ProductPrice,0) = 0)) THEN 0
	WHEN CP.IncludeOnInvoice = 2 AND ((CP.ImportsAtBaseOrSales=0 AND ISNULL(CP.SalesPrice,0) > 0) OR (CP.ImportsAtBaseOrSales=1 AND ISNULL(PT.ProductPrice,0) > 0)) THEN 1
	WHEN CP.IncludeOnInvoice = 0 THEN 1 
	WHEN (CP.IncludeOnInvoice = 1 AND CP.ImportsAtBaseOrSales=0 AND ISNULL(CP.SalesPrice,0) > 0) THEN 1 
    WHEN (CP.IncludeOnInvoice = 1 AND CP.ImportsAtBaseOrSales=1 AND ISNULL(PT.ProductPrice,0) > 0) THEN 1
    ELSE 0 END = 1)

)
SELECT *
FROM CTE
WHERE rownum BETWEEN @FirstRow AND @LastRow
ORDER BY rownum

END
END

GO
