/****** Object:  StoredProcedure [dbo].[S1_Invoices_CreateInvoices]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC S1_Invoices_CreateInvoices '09/01/2014','09/30/2014','10/01/2014',3
--EXEC S1_Invoices_CreateInvoices '7/1/2010','7/31/2010','8/1/2010',0

CREATE PROCEDURE [dbo].[S1_Invoices_CreateInvoices]
(
	@StartTransactionDate datetime,
	@EndTransactionDate datetime,
	@InvoiceDate datetime,
	@BillingGroup int
)
AS
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRY
	BEGIN TRANSACTION -- Start the transaction..
	
	
-- overridepro - Redmine ticket 98 - http://redmine.overridepro.com/redmine/issues/98 

DECLARE @EndTransactionTime datetime = '23:59:59'
SET @EndTransactionDate += CAST(@EndTransactionTime as TIME)

-- end Ticket 98
	
DECLARE @StartTransactionDateToPull datetime
SELECT @StartTransactionDateToPull=DATEADD(month,-1,@StartTransactionDate)

DECLARE @StartNewInvoiceNumber int
SELECT @StartNewInvoiceNumber=IDENT_CURRENT('Invoices')

DECLARE @InvoiceNumberPrefix varchar(20)
SELECT @InvoiceNumberPrefix = RIGHT(CONVERT(varchar,YEAR(@InvoiceDate)),2) + RIGHT('0' + CONVERT(varchar, MONTH(@InvoiceDate)),2)

DECLARE @CountOfNextInvoiceNumber int
SELECT @CountOfNextInvoiceNumber = COUNT(*) FROM NextInvoiceNumber WHERE InvoiceNumberPrefix=@InvoiceNumberPrefix

DECLARE @NextInvoiceNumber int

IF (@CountOfNextInvoiceNumber = 0)
BEGIN
	INSERT INTO NextInvoiceNumber(InvoiceNumberPrefix, NextInvoiceNumber)
	VALUES (@InvoiceNumberPrefix, 1)
	SELECT @NextInvoiceNumber = 0 --The starting invoice is this number + 1
	--@InvoiceNumberPrefix + '00001'
END
ELSE
BEGIN
	SELECT TOP 1 @NextInvoiceNumber = NextInvoiceNumber
	FROM NextInvoiceNumber
	WHERE InvoiceNumberPrefix=@InvoiceNumberPrefix
	
	--@InvoiceNumberPrefix + RIGHT('0000' + CONVERT(varchar,NextInvoiceNumber),5)
END

DECLARE @ClientsTemp TABLE (
	[ClientID] [int] NOT NULL,
	[OriginalClientID] [int] NOT NULL
)
/*
DECLARE @ProductTransactions TABLE (
	[ProductTransactionID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ClientID] [int] NOT NULL,
	[VendorID] [int] NOT NULL,
	[TransactionDate] [smalldatetime] NULL,
	[DateOrdered] [smalldatetime] NULL,
	[OrderBy] [varchar](100) NULL,
	[Reference] [varchar](100) NULL,
	[FileNum] [varchar](50) NULL,
	[FName] [varchar](50) NULL,
	[LName] [varchar](50) NULL,
	[MName] [varchar](50) NULL,
	[SSN] [varchar](50) NULL,
	[ProductName] [varchar](100) NULL,
	[ProductDescription] [varchar](max) NULL,
	[ProductType] [varchar](50) NULL,
	[ProductPrice] [money] NOT NULL,
	[SalesRep] [varchar](50) NULL,
	[ExternalInvoiceNumber] [varchar](50) NULL
)
*/
DECLARE @ProductsOnInvoice TABLE (
	[ProductsOnInvoiceID] [int] IDENTITY(1,1) NOT NULL,
	[SplitBy] [int] NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[ClientID] [int] NOT NULL,
	[OriginalClientID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[ProductTransactionID] [int] NULL,
	[TransactionDate] [smalldatetime] NULL,
	[ProductPrice] [money] NOT NULL,
	[OrderBy] [varchar](100) NULL,
	[Reference] [varchar](100) NULL,
	[ProductName] [varchar](100) NULL,
	[ProductDescription] [varchar](max) NULL,
	[ProductType] [varchar](50) NULL,
	[FileNum] [varchar](50) NULL,
	[DateOrdered] [smalldatetime] NULL,
	[FName] [varchar](255) NULL,
	[LName] [varchar](255) NULL,
	[MName] [varchar](255) NULL,
	[SSN] [varchar](50) NULL,
	[CoFName] [varchar](255) NULL,
	[CoLName] [varchar](255) NULL,
	[CoMName] [varchar](255) NULL,
	[CoSSN] [varchar](50) NULL,
	[ExternalInvoiceNumber] [varchar](50) NULL,
	[InvoiceSplitID] [int] NULL,
	[VendorID] [int] NULL
)
/*
INSERT INTO @ProductTransactions
SELECT PT.ProductTransactionID,
PT.ProductID, PT.ClientID, PT.VendorID, PT.TransactionDate, PT.DateOrdered,
PT.OrderBy, PT.Reference, PT.FileNum, PT.FName, PT.LName, PT.MName, PT.SSN,
PT.ProductName, PT.ProductDescription, PT.ProductType,
(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN CP.SalesPrice ELSE PT.ProductPrice END)
AS ProductPrice,
PT.SalesRep,PT.ExternalInvoiceNumber
FROM ProductTransactions PT
INNER JOIN Clients C
	ON PT.ClientID=C.ClientID
INNER JOIN ClientProducts CP
	ON PT.ClientID=CP.ClientID
	AND PT.ProductID=CP.ProductID
WHERE PT.TransactionDate BETWEEN @StartTransactionDate AND @EndTransactionDate  
AND C.DoNotInvoice=0
AND CP.IncludeOnInvoice<>2
AND (CP.IncludeOnInvoice<>1 OR PT.ProductPrice<>0)
AND NOT EXISTS (SELECT 1 FROM ProductsOnInvoice POI
	WHERE POI.ProductTransactionID=PT.ProductTransactionID)
*/
DECLARE @InvoiceID int
SET @InvoiceID=1

/* Split By = 1 - Individual Clients */

INSERT INTO @ClientsTemp (ClientID, OriginalClientID)
SELECT C.ClientID, C.ClientID
FROM Clients C
INNER JOIN ClientInvoiceSettings CIS
	ON C.ClientID=CIS.ClientID
WHERE CIS.SplitByMode=1
--AND C.ClientID<>5605

/* Split By = 2 - Group by Master Client */

INSERT INTO @ClientsTemp (ClientID, OriginalClientID)
SELECT CIS.ClientID, C.ClientID
FROM Clients C
INNER JOIN ClientInvoiceSettings CIS
	ON (C.ClientID=CIS.ClientID OR C.ParentClientID=CIS.ClientID)
WHERE CIS.SplitByMode=2
and C.ClientID not in (select ClientID from ClientInvoiceSettings where SplitByMode = 1)


/* Split By = 3 - Group by Custom Client Splits */

INSERT INTO @ClientsTemp (ClientID, OriginalClientID)
SELECT CS.GroupAsClientID,CSC.ClientID 
FROM Clients C
INNER JOIN ClientInvoiceSettings CIS
	ON C.ClientID=CIS.ClientID
INNER JOIN ClientSplit CS
	ON C.ClientID=CS.ParentClientID
INNER JOIN ClientSplitClient CSC
	ON CS.ClientSplitID=CSC.ClientSplitID
WHERE C.ParentClientID IS NULL AND CIS.SplitByMode=3


--Split By Product
	DECLARE @tmp_ProductSplit TABLE (
		ClientID int,
		BillingContactID int,
		InvoiceSplitID int,
		ProductID int
	)

	INSERT INTO @tmp_ProductSplit (ClientID, BillingContactID, InvoiceSplitID, ProductID)
	SELECT INS.ClientID, ISBC.BillingContactID, INS.InvoiceSplitID, PS.ProductID
	FROM InvoiceSplit INS
	INNER JOIN ProductSplit PS
		ON PS.InvoiceSplitID=INS.InvoiceSplitID
	INNER JOIN InvoiceSplitBillingContacts ISBC
		ON ISBC.InvoiceSplitID=INS.InvoiceSplitID
		AND ISBC.IsPrimaryBillingContact=1
	WHERE PS.ProductID>0

	INSERT INTO @tmp_ProductSplit (ClientID, BillingContactID, InvoiceSplitID, ProductID)
	SELECT INS.ClientID, ISBC.BillingContactID, INS.InvoiceSplitID, P.ProductID
	FROM InvoiceSplit INS
	INNER JOIN ProductSplit PS
		ON PS.InvoiceSplitID=INS.InvoiceSplitID
	INNER JOIN InvoiceSplitBillingContacts ISBC
		ON ISBC.InvoiceSplitID=INS.InvoiceSplitID
		AND ISBC.IsPrimaryBillingContact=1
	CROSS JOIN Products P
	WHERE PS.ProductID=0 AND P.ProductID NOT IN 
	(SELECT ProductID FROM @tmp_ProductSplit PS2 WHERE PS2.ClientID=INS.ClientID
	AND PS2.ProductID=PS2.ProductID)
--End Split By Product



--Insert into Temp Table (Split by Product)
INSERT INTO @ProductsOnInvoice
(SplitBy, InvoiceID, ClientID, OriginalClientID, ProductID, ProductTransactionID, ProductPrice, 
OrderBy, Reference, ProductName, ProductDescription, ProductType, FileNum, DateOrdered, 
FName, LName, MName, SSN, CoFName, CoLName, CoMName, CoSSN, ExternalInvoiceNumber, 
InvoiceSplitID, VendorID)
SELECT 1 as SplitBy, DENSE_RANK() OVER (ORDER BY CT.ClientID, INS.InvoiceSplitID) + @StartNewInvoiceNumber,
CT.ClientID,PT.ClientID,PT.ProductID,PT.ProductTransactionID,PT.ProductPrice,PT.OrderBy,
PT.Reference,PT.ProductName,
PT.ProductDescription,PT.ProductType,PT.FileNum,PT.DateOrdered,PT.FName,
PT.LName,PT.MName,PT.SSN,PT.CoFName,
PT.CoLName,PT.CoMName,PT.CoSSN,PT.ExternalInvoiceNumber,
INS.InvoiceSplitID, PT.VendorID
FROM (
SELECT PT2.ProductTransactionID,
PT2.ProductID, PT2.ClientID, PT2.VendorID, PT2.TransactionDate, PT2.DateOrdered,
PT2.OrderBy, PT2.Reference, PT2.FileNum, PT2.FName, PT2.LName, PT2.MName, PT2.SSN,
PT2.ProductName, PT2.ProductDescription, PT2.ProductType, PT2.CoLName, PT2.CoFName,
PT2.CoMName, PT2.CoSSN,
(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN CP.SalesPrice ELSE PT2.ProductPrice END)
AS ProductPrice,
PT2.SalesRep,PT2.ExternalInvoiceNumber
FROM ProductTransactions PT2
INNER JOIN Clients C
	ON PT2.ClientID=C.ClientID
INNER JOIN ClientProducts CP
	ON PT2.ClientID=CP.ClientID
	AND PT2.ProductID=CP.ProductID
WHERE PT2.TransactionDate BETWEEN @StartTransactionDateToPull AND @EndTransactionDate  
AND PT2.Invoiced=0
AND (C.BillingGroup=@BillingGroup OR @BillingGroup=0)
AND C.DoNotInvoice=0
AND CP.IncludeOnInvoice<>2
AND (CP.IncludeOnInvoice<>1 OR PT2.ProductPrice<>0)
/*AND NOT EXISTS (SELECT 1 FROM ProductsOnInvoice POI
	WHERE POI.ProductTransactionID=PT2.ProductTransactionID)*/
) PT
INNER JOIN @ClientsTemp CT
	ON PT.ClientID=CT.OriginalClientID
INNER JOIN InvoiceSplit INS
	ON CT.ClientID=INS.ClientID
INNER JOIN @tmp_ProductSplit PS
	ON PS.InvoiceSplitID=INS.InvoiceSplitID
	AND PS.ProductID=PT.ProductID
WHERE PT.TransactionDate BETWEEN @StartTransactionDateToPull AND @EndTransactionDate

DECLARE @TempStartNewInvoiceNumber int
SELECT @TempStartNewInvoiceNumber=MAX(InvoiceID) FROM @ProductsOnInvoice
IF (@TempStartNewInvoiceNumber IS NOT NULL)
BEGIN
	SELECT @StartNewInvoiceNumber=@TempStartNewInvoiceNumber
END


--Insert into Temp Table (Split by Reference)
INSERT INTO @ProductsOnInvoice
(SplitBy, InvoiceID, ClientID, OriginalClientID, ProductID, ProductTransactionID, ProductPrice, 
OrderBy, Reference, ProductName, ProductDescription, ProductType, FileNum, DateOrdered, 
FName, LName, MName, SSN, CoFName, CoLName, CoMName, CoSSN, ExternalInvoiceNumber, 
InvoiceSplitID, VendorID)
SELECT 1 as SplitBy, DENSE_RANK() OVER (ORDER BY CT.ClientID, INS.InvoiceSplitID) + @StartNewInvoiceNumber,
CT.ClientID,PT.ClientID,PT.ProductID,PT.ProductTransactionID,PT.ProductPrice,PT.OrderBy,
PT.Reference,PT.ProductName,
PT.ProductDescription,PT.ProductType,PT.FileNum,PT.DateOrdered,PT.FName,
PT.LName,PT.MName,PT.SSN,PT.CoFName,
PT.CoLName,PT.CoMName,PT.CoSSN,PT.ExternalInvoiceNumber,
INS.InvoiceSplitID, PT.VendorID
FROM (
SELECT PT2.ProductTransactionID,
PT2.ProductID, PT2.ClientID, PT2.VendorID, PT2.TransactionDate, PT2.DateOrdered,
PT2.OrderBy, PT2.Reference, PT2.FileNum, PT2.FName, PT2.LName, PT2.MName, PT2.SSN,
PT2.ProductName, PT2.ProductDescription, PT2.ProductType, PT2.CoLName, PT2.CoFName,
PT2.CoMName, PT2.CoSSN,
(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN CP.SalesPrice ELSE PT2.ProductPrice END)
AS ProductPrice,
PT2.SalesRep,PT2.ExternalInvoiceNumber
FROM ProductTransactions PT2
INNER JOIN Clients C
	ON PT2.ClientID=C.ClientID
INNER JOIN ClientProducts CP
	ON PT2.ClientID=CP.ClientID
	AND PT2.ProductID=CP.ProductID
WHERE PT2.TransactionDate BETWEEN @StartTransactionDateToPull AND @EndTransactionDate  
AND PT2.Invoiced=0
AND C.DoNotInvoice=0
AND (C.BillingGroup=@BillingGroup OR @BillingGroup=0)
AND CP.IncludeOnInvoice<>2
AND (CP.IncludeOnInvoice<>1 OR PT2.ProductPrice<>0)
/*AND NOT EXISTS (SELECT 1 FROM ProductsOnInvoice POI
	INNER JOIN Invoices I
		ON POI.InvoiceID=I.InvoiceID
	WHERE POI.ProductTransactionID=PT2.ProductTransactionID AND I.VoidedOn IS NULL)
	*/
	) PT
INNER JOIN @ClientsTemp CT
	ON PT.ClientID=CT.OriginalClientID
INNER JOIN InvoiceSplit INS
	ON CT.ClientID=INS.ClientID
INNER JOIN ReferenceSplit RS
	ON RS.InvoiceSplitID=INS.InvoiceSplitID
	AND RS.ReferenceText=PT.Reference
WHERE PT.TransactionDate BETWEEN @StartTransactionDateToPull AND @EndTransactionDate

SELECT @TempStartNewInvoiceNumber=MAX(InvoiceID) FROM @ProductsOnInvoice
IF (@TempStartNewInvoiceNumber IS NOT NULL)
BEGIN
	SELECT @StartNewInvoiceNumber=@TempStartNewInvoiceNumber
END


--Insert into Temp Table (Split by Ordered By)
INSERT INTO @ProductsOnInvoice
(SplitBy, InvoiceID, ClientID, OriginalClientID, ProductID, ProductTransactionID, ProductPrice, 
OrderBy, Reference, ProductName, ProductDescription, ProductType, FileNum, DateOrdered, 
FName, LName, MName, SSN, CoFName, CoLName, CoMName, CoSSN, ExternalInvoiceNumber, 
InvoiceSplitID, VendorID)
SELECT 1 as SplitBy, DENSE_RANK() OVER (ORDER BY CT.ClientID, INS.InvoiceSplitID) + @StartNewInvoiceNumber,
CT.ClientID,PT.ClientID,PT.ProductID,PT.ProductTransactionID,PT.ProductPrice,PT.OrderBy,
PT.Reference,PT.ProductName,
PT.ProductDescription,PT.ProductType,PT.FileNum,PT.DateOrdered,PT.FName,
PT.LName,PT.MName,PT.SSN,PT.CoFName,
PT.CoLName,PT.CoMName,PT.CoSSN,PT.ExternalInvoiceNumber,
INS.InvoiceSplitID, PT.VendorID
FROM (
SELECT PT2.ProductTransactionID,
PT2.ProductID, PT2.ClientID, PT2.VendorID, PT2.TransactionDate, PT2.DateOrdered,
PT2.OrderBy, PT2.Reference, PT2.FileNum, PT2.FName, PT2.LName, PT2.MName, PT2.SSN,
PT2.ProductName, PT2.ProductDescription, PT2.ProductType, PT2.CoFName, PT2.CoLName,
PT2.CoMName, PT2.CoSSN,
(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN CP.SalesPrice ELSE PT2.ProductPrice END)
AS ProductPrice,
PT2.SalesRep,PT2.ExternalInvoiceNumber
FROM ProductTransactions PT2
INNER JOIN Clients C
	ON PT2.ClientID=C.ClientID
INNER JOIN ClientProducts CP
	ON PT2.ClientID=CP.ClientID
	AND PT2.ProductID=CP.ProductID
WHERE PT2.TransactionDate BETWEEN @StartTransactionDateToPull AND @EndTransactionDate  
AND PT2.Invoiced=0
AND C.DoNotInvoice=0
AND (C.BillingGroup=@BillingGroup OR @BillingGroup=0)
AND CP.IncludeOnInvoice<>2
AND (CP.IncludeOnInvoice<>1 OR PT2.ProductPrice<>0)
/*AND NOT EXISTS (SELECT 1 FROM ProductsOnInvoice POI
	INNER JOIN Invoices I
		ON POI.InvoiceID=I.InvoiceID
	WHERE POI.ProductTransactionID=PT2.ProductTransactionID AND I.VoidedOn IS NULL)*/
	) PT
INNER JOIN @ClientsTemp CT
	ON PT.ClientID=CT.OriginalClientID
INNER JOIN InvoiceSplit INS
	ON CT.ClientID=INS.ClientID
INNER JOIN OrderedBySplit OB
	ON OB.InvoiceSplitID=INS.InvoiceSplitID
	AND OB.OrderedBy=PT.OrderBy
WHERE PT.TransactionDate BETWEEN @StartTransactionDateToPull AND @EndTransactionDate

SELECT @TempStartNewInvoiceNumber=MAX(InvoiceID) FROM @ProductsOnInvoice
IF (@TempStartNewInvoiceNumber IS NOT NULL)
BEGIN
	SELECT @StartNewInvoiceNumber=@TempStartNewInvoiceNumber
END


--Insert into Temp Table (No Split)
INSERT INTO @ProductsOnInvoice
(SplitBy, InvoiceID, ClientID, OriginalClientID, ProductID, ProductTransactionID, 
ProductPrice, OrderBy, Reference, ProductName, ProductDescription, ProductType, FileNum, 
DateOrdered, FName, LName, MName, SSN, CoFName, CoLName, CoMName, CoSSN, ExternalInvoiceNumber, 
InvoiceSplitID,VendorID)
SELECT 1 as SplitBy, DENSE_RANK() OVER (ORDER BY CT.ClientID) + @StartNewInvoiceNumber,
CT.ClientID,PT.ClientID,PT.ProductID,PT.ProductTransactionID,PT.ProductPrice,PT.OrderBy,
PT.Reference,PT.ProductName,
PT.ProductDescription,PT.ProductType,PT.FileNum,PT.DateOrdered,PT.FName,
PT.LName,PT.MName,PT.SSN,PT.CoFName,
PT.CoLName,PT.CoMName,PT.CoSSN,PT.ExternalInvoiceNumber,
NULL AS InvoiceSplitID,PT.VendorID
FROM (
SELECT PT2.ProductTransactionID,
PT2.ProductID, PT2.ClientID, PT2.VendorID, PT2.TransactionDate, PT2.DateOrdered,
PT2.OrderBy, PT2.Reference, PT2.FileNum, PT2.FName, PT2.LName, PT2.MName, PT2.SSN,
PT2.ProductName, PT2.ProductDescription, PT2.ProductType, PT2.CoLName, PT2.CoFName,
PT2.CoMName, PT2.CoSSN,
(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN CP.SalesPrice ELSE PT2.ProductPrice END)
AS ProductPrice,
PT2.SalesRep,PT2.ExternalInvoiceNumber
FROM ProductTransactions PT2
INNER JOIN Clients C
	ON PT2.ClientID=C.ClientID
INNER JOIN ClientProducts CP
	ON PT2.ClientID=CP.ClientID
	AND PT2.ProductID=CP.ProductID
WHERE PT2.TransactionDate BETWEEN @StartTransactionDateToPull AND @EndTransactionDate  
AND PT2.Invoiced=0
AND C.DoNotInvoice=0
AND (C.BillingGroup=@BillingGroup OR @BillingGroup=0)
AND CP.IncludeOnInvoice<>2
AND (CP.IncludeOnInvoice<>1 OR PT2.ProductPrice<>0)
/*AND NOT EXISTS (SELECT 1 FROM ProductsOnInvoice POI
	INNER JOIN Invoices I
		ON POI.InvoiceID=I.InvoiceID
	WHERE POI.ProductTransactionID=PT2.ProductTransactionID AND I.VoidedOn IS NULL)
	*/
	) PT
INNER JOIN @ClientsTemp CT
	ON PT.ClientID=CT.OriginalClientID
WHERE PT.TransactionDate BETWEEN @StartTransactionDateToPull AND @EndTransactionDate
AND PT.ProductTransactionID NOT IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)



--Insert Invoices

INSERT INTO CreateInvoicesBatch (CreatedByUserID, CreatedOn)
VALUES (0,GETDATE())

DECLARE @InvoiceBatchID int
SELECT @InvoiceBatchID=SCOPE_IDENTITY()

DECLARE @NumberOfInvoicesCreated int

SET IDENTITY_INSERT Invoices ON

--custom InvoiceBillingContacts
INSERT INTO Invoices (InvoiceID, ClientID, InvoiceTypeID, InvoiceNumber, InvoiceDate, VoidedOn, 
VoidedByUser, Amount, NumberOfColumns, Col1Header, Col2Header, Col3Header, Col4Header, Col5Header, Col6Header, 
Col7Header, Col8Header, CreateInvoicesBatchID, BillTo, POName, PONumber, 
BillingReportGroupID, DueText)
SELECT InvoiceID,POI.ClientID,1 as InvoiceTypeID,
@InvoiceNumberPrefix + RIGHT('0000' + CONVERT(varchar, 
	DENSE_RANK() OVER (ORDER BY InvoiceID) + @NextInvoiceNumber), 5)
as InvoiceNumber,
@InvoiceDate as InvoiceDate,
null,null,SUM(ProductPrice) as Amount, 0 as NumberOfColumns,'','','','','','','','',@InvoiceBatchID,
ISNULL(C.ClientName, C.BillAsClientName) + '|' + ISNULL(BC.ContactName,'Attn: Accounts Payable') + '|' + BC.ContactAddress1 + '|'
+ (CASE WHEN BC.ContactAddress2 IS NULL THEN '' ELSE BC.ContactAddress2 + '|' END) 
+ BC.ContactCity + ', ' + BC.ContactStateCode + ' ' + BC.ContactZIP,
BC.POName, BC.PONumber, ISNULL(CIS.ReportGroupID,0),
(CASE WHEN C.DueText='[End of Month]' THEN 
CONVERT(char(10),DATEADD(day,-1,DATEADD(month,1,@InvoiceDate)),101) 
ELSE C.DueText END) as DueText
FROM @ProductsOnInvoice POI
INNER JOIN Clients C
	ON C.ClientID=POI.ClientID
INNER JOIN InvoiceSplitBillingContacts ISBC
	ON ISBC.InvoiceSplitID=POI.InvoiceSplitID
	AND ISBC.IsPrimaryBillingContact = 1
INNER JOIN BillingContacts BC
	ON BC.BillingContactID=ISBC.BillingContactID
LEFT JOIN ClientInvoiceSettings CIS
	ON C.ClientID=CIS.ClientID
GROUP BY InvoiceID, POI.ClientID, C.BillAsClientName, C.ClientName, BC.ContactName, BC.ContactAddress1, BC.ContactAddress2,
BC.ContactCity, BC.ContactStateCode, BC.ContactZIP, BC.POName, BC.PONumber, CIS.ReportGroupID, C.DueText

SELECT @NumberOfInvoicesCreated=COUNT(*) FROM Invoices WHERE CreateInvoicesBatchID=@InvoiceBatchID

--custom InvoiceBillingContacts
INSERT INTO Invoices (InvoiceID, ClientID, InvoiceTypeID, InvoiceNumber, InvoiceDate, VoidedOn, 
VoidedByUser, Amount, NumberOfColumns, Col1Header, Col2Header, Col3Header, Col4Header, Col5Header, Col6Header, 
Col7Header, Col8Header, CreateInvoicesBatchID, BillTo, POName, PONumber, 
BillingReportGroupID, DueText)
SELECT InvoiceID,POI.ClientID,1 as InvoiceTypeID,
@InvoiceNumberPrefix + RIGHT('0000' + CONVERT(varchar,
	DENSE_RANK() OVER (ORDER BY InvoiceID) + @NextInvoiceNumber + @NumberOfInvoicesCreated), 5) 
as InvoiceNumber,
@InvoiceDate as InvoiceDate,
null,null,SUM(ProductPrice) as Amount, 0 as NumberOfColumns,'','','','','','','','',@InvoiceBatchID,
ISNULL(C.ClientName,C.BillAsClientName) + '|' + ISNULL(BC.ContactName,'Attn: Accounts Payable') + '|' + BC.ContactAddress1 + '|'
+ (CASE WHEN BC.ContactAddress2 IS NULL THEN '' ELSE BC.ContactAddress2 + '|' END) 
+ BC.ContactCity + ', ' + BC.ContactStateCode + ' ' + BC.ContactZIP,
BC.POName, BC.PONumber, ISNULL(CIS.ReportGroupID,0),
(CASE WHEN C.DueText='[End of Month]' THEN 
CONVERT(char(10),DATEADD(day,-1,DATEADD(month,1,@InvoiceDate)),101) 
ELSE C.DueText END) as DueText
FROM @ProductsOnInvoice POI
INNER JOIN Clients C
	ON C.ClientID=POI.ClientID
INNER JOIN ClientContacts CC
	ON CC.ClientID=POI.ClientID
INNER JOIN BillingContacts BC
	ON BC.ClientContactID=CC.ClientContactID
	AND BC.IsPrimaryBillingContact = 1
LEFT JOIN ClientInvoiceSettings CIS
	ON C.ClientID=CIS.ClientID
WHERE POI.InvoiceSplitID IS NULL
GROUP BY InvoiceID, POI.ClientID, C.BillAsClientName, C.ClientName, BC.ContactName, BC.ContactAddress1, BC.ContactAddress2,
BC.ContactCity, BC.ContactStateCode, BC.ContactZIP, BC.POName, BC.PONumber, CIS.ReportGroupID, C.DueText

SELECT @NumberOfInvoicesCreated=COUNT(*) FROM Invoices WHERE CreateInvoicesBatchID=@InvoiceBatchID

SET IDENTITY_INSERT Invoices OFF

UPDATE NextInvoiceNumber
SET NextInvoiceNumber=NextInvoiceNumber+@NumberOfInvoicesCreated
WHERE InvoiceNumberPrefix=@InvoiceNumberPrefix


--Insert custom InvoiceBillingContacts
INSERT INTO InvoiceBillingContacts (InvoiceID, BillingContactID, IsPrimaryBillingContact)
SELECT InvoiceID, ISBC.BillingContactID, ISBC.IsPrimaryBillingContact
FROM @ProductsOnInvoice POI
INNER JOIN InvoiceSplitBillingContacts ISBC
	ON ISBC.InvoiceSplitID=POI.InvoiceSplitID
GROUP BY InvoiceID, ISBC.BillingContactID, ISBC.IsPrimaryBillingContact

--Insert default InvoiceBillingContacts
INSERT INTO InvoiceBillingContacts (InvoiceID, BillingContactID, IsPrimaryBillingContact)
SELECT InvoiceID, BC.BillingContactID, BC.IsPrimaryBillingContact
FROM @ProductsOnInvoice POI
INNER JOIN ClientContacts CC
	ON CC.ClientID=POI.ClientID
INNER JOIN BillingContacts BC
	ON BC.ClientContactID=CC.ClientContactID
WHERE POI.InvoiceSplitID IS NULL
GROUP BY InvoiceID, BC.BillingContactID, BC.IsPrimaryBillingContact

--Insert ProductsOnInvoice
INSERT INTO ProductsOnInvoice (InvoiceID, ProductID, ProductTransactionID, ProductPrice, 
OrderBy, Reference, ProductName, ProductDescription, ProductType, FileNum, DateOrdered, 
FName, LName, MName, SSN, CoFName, CoLName, CoMName, CoSSN, ExternalInvoiceNumber, 
OriginalClientID, VendorID)
SELECT POI.InvoiceID,ProductID,ProductTransactionID,ProductPrice,OrderBy,Reference,ProductName,
ProductDescription,ProductType,FileNum,DateOrdered,FName,LName,MName,SSN,
CoFName, CoLName, CoMName, CoSSN, ExternalInvoiceNumber, OriginalClientID, VendorID
FROM @ProductsOnInvoice POI
INNER JOIN Invoices I
	ON POI.InvoiceID=I.InvoiceID
ORDER BY InvoiceID,POI.ClientID

--Mark the ProductTransactions as invoiced
UPDATE ProductTransactions
SET Invoiced=1
WHERE ProductTransactionID IN 
(SELECT ProductTransactionID FROM @ProductsOnInvoice POI INNER JOIN Invoices I 
	ON POI.InvoiceID=I.InvoiceID)

/*
SELECT InvoiceID,ClientID
FROM @ProductsOnInvoice
GROUP BY InvoiceID,ClientID
*/


/* Split By = 2 */
/*
SELECT @StartNewInvoiceNumber=IDENT_CURRENT('Invoices')


--Insert into Temp Table (Split by Parent Client and include Sub-Clients)
INSERT INTO @ProductsOnInvoice
(SplitBy, InvoiceID, ClientID, ProductID, ProductTransactionID, ProductPrice, 
OrderBy, Reference, ProductName, ProductDescription, ProductType, FileNum, DateOrdered, 
FName, LName, MName, SSN, ExternalInvoiceNumber)
SELECT 2 as SplitBy, DENSE_RANK() OVER (ORDER BY 
CASE WHEN C.ParentClientID IS NULL THEN C.ClientID ELSE C.ParentClientID END, 
INS.InvoiceSplitID
) + @StartNewInvoiceNumber,
PT.ClientID,PT.ProductID,PT.ProductTransactionID,PT.ProductPrice,PT.OrderBy,
PT.Reference,PT.ProductName,
PT.ProductDescription,PT.ProductType,PT.FileNum,PT.DateOrdered,PT.FName,
PT.LName,PT.MName,PT.SSN,PT.ExternalInvoiceNumber
FROM ProductTransactions PT
INNER JOIN Clients C
	ON PT.ClientID=C.ClientID
INNER JOIN ClientInvoiceSettings CIS
	ON (PT.ClientID=CIS.ClientID OR C.ParentClientID=CIS.ClientID)
LEFT JOIN InvoiceSplit INS
	ON PT.ClientID=INS.ClientID
LEFT JOIN @tmp_ProductSplit PS
	ON PS.InvoiceSplitID=INS.InvoiceSplitID
	AND PT.ProductID=PS.ProductID
WHERE CIS.SplitByMode=2
AND PT.TransactionDate BETWEEN @StartTransactionDate AND @EndTransactionDate

--Insert Invoices
SET IDENTITY_INSERT Invoices ON

INSERT INTO Invoices (InvoiceID, ClientID, InvoiceTypeID, InvoiceNumber, InvoiceDate, BillingContactID, VoidedOn, 
VoidedByUser, Amount, NumberOfColumns, Col1Header, Col2Header, Col3Header, Col4Header, Col5Header, Col6Header, 
Col7Header, Col8Header, CreateInvoicesBatchID)
SELECT InvoiceID,
CASE WHEN MAX(C.ParentClientID) IS NULL THEN MAX(C.ClientID) ELSE MAX(C.ParentClientID) END,
1 as InvoiceTypeID,'' as InvoiceNumber,GETDATE() as InvoiceDate,
1 as BillingContactID,null,null,SUM(ProductPrice) as Amount, 0 as NumberOfColumns,'','','','','','','','',0
FROM @ProductsOnInvoice POI
INNER JOIN Clients C
	ON POI.ClientID=C.ClientID
WHERE SplitBy=2
GROUP BY InvoiceID

SET IDENTITY_INSERT Invoices OFF

--Insert ProductsOnInvoice
INSERT INTO ProductsOnInvoice (InvoiceID, ProductID, ProductTransactionID, ProductPrice, 
OrderBy, Reference, ProductName, ProductDescription, ProductType, FileNum, DateOrdered, 
FName, LName, MName, SSN, ExternalInvoiceNumber, OriginalClientID)
SELECT InvoiceID,ProductID,ProductTransactionID,ProductPrice,OrderBy,Reference,ProductName,
ProductDescription,ProductType,FileNum,DateOrdered,FName,LName,MName,SSN,
ExternalInvoiceNumber, ClientID
FROM @ProductsOnInvoice
ORDER BY InvoiceID,ClientID
*/

DECLARE @tmp_IncludeReports TABLE (
	InvoiceID int,
	IncludeReport bit
)

--Create Standard Invoice 1.0 (InvoiceTemplateID = 1)
INSERT INTO @tmp_IncludeReports (InvoiceID, IncludeReport)
SELECT I.InvoiceID,CASE WHEN COUNT(POI.ProductTransactionID) > 24 THEN 1 ELSE 0 END as IncludeReport
FROM Invoices I 
INNER JOIN ClientInvoiceSettings CIS
	ON I.ClientID=CIS.ClientID
INNER JOIN ProductsOnInvoice POI
	ON I.InvoiceID=POI.InvoiceID
WHERE CIS.InvoiceTemplateID=1
GROUP BY I.InvoiceID, CIS.InvoiceTemplateID

--Normal without report
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Date Ordered / Name / SSN / Ordered By / File # / Reference',
NumberOfColumns=2
WHERE InvoiceID IN (SELECT InvoiceID FROM @tmp_IncludeReports WHERE IncludeReport=0)
/*WHERE ClientID IN 
(SELECT DISTINCT CIS.ClientID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=1)*/

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.LName, A.FName, A.FileNum, A.Detail), Col1Text, 
Col2Text, '' as Col3Text, '' as Col4Text, '' as Col5Text, '' as Col6Text, '' as Col7Text, '' as Col8Text, A.Amount
FROM (
SELECT POI.FileNum,
POI.InvoiceID,
0 as Detail, 
CASE 
	WHEN POI.ProductType = 'EMP' THEN 'EMPLOYMENT'
	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
	ELSE UPPER(POI.ProductType)
END
as Col1Text, 
CONVERT(varchar(10),POI.DateOrdered,101) + ' ' 
+ POI.LName + ', ' + POI.FName + ' ' + (CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) 
+ ' ' + POI.OrderBy + ' ' + POI.FileNum + ' ' + POI.Reference + ' ' 
+ POI.ProductDescription
as Col2Text,
POI.ProductPrice as Amount,
POI.LName, POI.FName
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
INNER JOIN @tmp_IncludeReports IR
	ON I.InvoiceID=IR.InvoiceID	
	AND IR.IncludeReport=0
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND I.CreateInvoicesBatchID=@InvoiceBatchID
AND POI.ProductPrice<>0
--AND CIS.InvoiceTemplateID=1

UNION ALL

SELECT POI.FileNum,
POI.InvoiceID,
0 as Detail, 
CASE 
	WHEN POI.ProductType = 'EMP' THEN 'EMPLOYMENT'
	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
	ELSE UPPER(POI.ProductType)
END
as Col1Text, 
CONVERT(varchar(10),POI.DateOrdered,101) + ' ' 
+ POI.LName + ', ' + POI.FName + ' ' + (CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) 
+ ' ' + POI.OrderBy + ' ' + POI.FileNum + ' ' + POI.Reference + ' ' 
+ POI.ProductDescription
as Col2Text,
POI.ProductPrice as Amount,
POI.LName, POI.FName
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
INNER JOIN @tmp_IncludeReports IR
	ON I.InvoiceID=IR.InvoiceID	
	AND IR.IncludeReport=0
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND POI.CoLName<>''
AND I.CreateInvoicesBatchID=@InvoiceBatchID

) A


--Include Report - Header
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Description',
NumberOfColumns=2,
BillingReportGroupID=4
WHERE InvoiceID IN (SELECT InvoiceID FROM @tmp_IncludeReports WHERE IncludeReport=1)

--Include Report - Invoice Lines
INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.Detail), Col1Text, 
Col2Text, '' as Col3Text, '' as Col4Text, '' as Col5Text, '' as Col6Text, '' as Col7Text, '' as Col8Text, A.Amount
FROM (
SELECT I.InvoiceID,0 as Detail, 
'DETAIL' as Col1Text, 
'SEE ATTACHED DETAIL' as Col2Text, 
SUM(POI.ProductPrice) as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN @tmp_IncludeReports IR
	ON I.InvoiceID=IR.InvoiceID	
	AND IR.IncludeReport=1
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY I.InvoiceID
) A

UPDATE I
SET BillingReportGroupID=4
FROM Invoices I INNER JOIN @tmp_IncludeReports IR ON I.InvoiceID=IR.InvoiceID
WHERE IR.IncludeReport=1
AND I.BillingReportGroupID=0

DELETE FROM @tmp_IncludeReports


--Create Standard Invoice 1.0 [Improved] (InvoiceTemplateID = 2)
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Date Ordered',
Col3Header='Name',
Col4Header='SSN',
Col5Header='Ordered By',
Col6Header='File #',
Col7Header='Reference',
NumberOfColumns=7
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=2)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.Col3Text, A.FileNum, A.Detail), Col1Text, Col2Text, Col3Text, 
Col4Text, Col5Text, Col6Text, Col7Text, '', A.Amount
FROM (
SELECT POI.FileNum,
POI.InvoiceID,
0 as Detail, 
CASE 
	WHEN POI.ProductType = 'EMP' THEN 'EMPLOYMENT'
	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
	ELSE UPPER(POI.ProductType)
END
as Col1Text, 
CONVERT(varchar(10),POI.DateOrdered,101) as Col2Text, 
POI.LName + ', ' + POI.FName as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) as Col4Text,
POI.OrderBy as Col5Text,
POI.FileNum as Col6Text,
POI.Reference as Col7Text,
POI.ProductPrice as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=2
AND I.CreateInvoicesBatchID=@InvoiceBatchID

UNION ALL

SELECT POI.FileNum,
POI.InvoiceID,
1 as Detail, 
'' as Col1Text, 
CONVERT(varchar(10),POI.DateOrdered,101) as Col2Text, 
POI.CoLName + ', ' + ISNULL(POI.CoFName,'') as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.CoSSN END) as Col4Text,
'' as Col5Text,
POI.FileNum as Col6Text,
'' as Col7Text,
0 as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=2
AND POI.CoLName<>''
AND I.CreateInvoicesBatchID=@InvoiceBatchID

) A






--Create Invoice with Quantity and Rate (InvoiceTemplateID = 3)
UPDATE Invoices
SET Col1Header='Description',
Col2Header='Quantity',
Col3Header='Rate',
NumberOfColumns=3
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=3)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.Detail, A.Col1Text, A.ProductsOnInvoiceID), Col1Text,
Col2Text, Col3Text, '' as Col4Text, '' as Col5Text, '' as Col6Text, '' as Col7Text, '' as Col8Text, A.Amount
FROM (
SELECT I.InvoiceID,0 as Detail,
P.ProductName as Col1Text,
COUNT(*) as Col2Text,
POI.ProductPrice as Col3Text,
COUNT(*) * POI.ProductPrice as Amount,
MAX(POI.ProductsOnInvoiceID) ProductsOnInvoiceID
FROM ProductsOnInvoice POI
INNER JOIN Products P
ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice>=0
AND CIS.InvoiceTemplateID=3
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY I.InvoiceID,P.ProductID,P.ProductCode,P.ProductName,POI.ProductPrice

UNION ALL

SELECT I.InvoiceID,1 as Detail,
POI.ProductDescription as Col1Text,
1 as Col2Text,
POI.ProductPrice as Col3Text,
POI.ProductPrice as Amount,
POI.ProductsOnInvoiceID
FROM ProductsOnInvoice POI
INNER JOIN Products P
ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<0
AND CIS.InvoiceTemplateID=3
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY I.InvoiceID,P.ProductID,P.ProductCode,P.ProductName,POI.ProductPrice,
POI.ProductDescription, POI.ProductsOnInvoiceID

) A











--Create Standard Invoice 2.0 (InvoiceTemplateID = 4)
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Date Ordered / Name / SSN / Ordered By / File # / Reference', 
NumberOfColumns=2
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=4)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID 
ORDER BY A.InvoiceID, A.LName, A.FName, A.FileNum, A.ProductTransactionID, A.Detail), Col1Text, 
Col2Text, '' as Col3Text, '' as Col4Text, '' as Col5Text, '' as Col6Text, '' as Col7Text, '' as Col8Text, A.Amount
FROM (
SELECT POI.ProductTransactionID, POI.FileNum,
POI.InvoiceID,
0 as Detail, 
CASE 
	WHEN POI.ProductType = 'EMP' THEN 'EMPLOYMENT'
	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
	ELSE UPPER(POI.ProductType)
END as Col1Text, 
CONVERT(varchar(10),POI.DateOrdered,101) + ' ' 
+ POI.LName + ', ' + POI.FName + ' ' + (CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) 
+ (CASE WHEN POI.CoLName<>'' THEN  
	' / ' + POI.CoLName + ', ' + ISNULL(POI.CoFName,'') + ' ' + 
	(CASE WHEN CIS.HideSSN=1 THEN '' ELSE ISNULL(POI.CoSSN,'') END)
ELSE '' END)
+ ' ' + POI.OrderBy + ' ' + POI.FileNum + ' ' + POI.Reference + ' ' + POI.ProductDescription as Col2Text,
POI.ProductPrice as Amount,
POI.LName, POI.FName
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=4
AND I.CreateInvoicesBatchID=@InvoiceBatchID

UNION ALL

SELECT POI.ProductTransactionID, POI.FileNum,
POI.InvoiceID,
1 as Detail, 
'' as Col1Text, 
POI.ProductDescription as Col2Text,
0 as Amount,
POI.LName, POI.FName
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=4
AND I.CreateInvoicesBatchID=@InvoiceBatchID

) A


--Create Standard Invoice 2.0 [Improved] (InvoiceTemplateID = 5)
INSERT INTO @tmp_IncludeReports (InvoiceID, IncludeReport)
SELECT I.InvoiceID,CASE WHEN COUNT(POI.ProductTransactionID) > 120 THEN 1 ELSE 0 END as IncludeReport
FROM Invoices I 
INNER JOIN ClientInvoiceSettings CIS
	ON I.ClientID=CIS.ClientID
INNER JOIN ProductsOnInvoice POI
	ON I.InvoiceID=POI.InvoiceID
WHERE CIS.InvoiceTemplateID=5
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY I.InvoiceID, CIS.InvoiceTemplateID

--Normal Without Report - Header
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Date Ordered',
Col3Header='Name / SSN',
Col4Header='Ordered By',
Col5Header='File #',
Col6Header='Reference',
Col7Header='Description',
NumberOfColumns=7
WHERE InvoiceID IN (SELECT InvoiceID FROM @tmp_IncludeReports WHERE IncludeReport=0)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.Col3Text, A.FileNum, A.Detail), Col1Text, 
Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, Col7Text, '' as Col8Text, A.Amount
FROM (
SELECT POI.FileNum,
POI.InvoiceID,
0 as Detail, 
CASE 
	WHEN POI.ProductType = 'EMP' THEN 'EMPLOYMENT'
	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
	ELSE UPPER(POI.ProductType)
END as Col1Text, 
CONVERT(varchar(10),POI.DateOrdered,101) as Col2Text,
POI.LName + ', ' + POI.FName + ' ' + (CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END)
 as Col3Text,
POI.OrderBy as Col4Text,
POI.FileNum as Col5Text,
POI.Reference as Col6Text,
POI.ProductDescription as Col7Text,
POI.ProductPrice as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
INNER JOIN @tmp_IncludeReports IR
	ON I.InvoiceID=IR.InvoiceID	
	AND IR.IncludeReport=0
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND I.CreateInvoicesBatchID=@InvoiceBatchID

UNION ALL

SELECT POI.FileNum,
POI.InvoiceID,
1 as Detail, 
'' Col1Text, 
CONVERT(varchar(10),POI.DateOrdered,101) as Col2Text,
POI.CoLName + ', ' + ISNULL(POI.CoFName,'') + ' ' 
+ (CASE WHEN CIS.HideSSN=1 THEN '' ELSE ISNULL(POI.CoSSN,'') END)
 as Col3Text,
'' as Col4Text,
POI.FileNum as Col5Text,
'' as Col6Text,
'' as Col7Text,
0 as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
INNER JOIN @tmp_IncludeReports IR
	ON I.InvoiceID=IR.InvoiceID	
	AND IR.IncludeReport=0
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND POI.CoLName<>''
AND I.CreateInvoicesBatchID=@InvoiceBatchID

) A

--Include Report - Header
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Description',
NumberOfColumns=2,
BillingReportGroupID=4
WHERE InvoiceID IN (SELECT InvoiceID FROM @tmp_IncludeReports WHERE IncludeReport=1)

--Include Report - Invoice Lines
INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.Detail), Col1Text, 
Col2Text, '' as Col3Text, '' as Col4Text, '' as Col5Text, '' as Col6Text, '' as Col7Text, '' as Col8Text, A.Amount
FROM (
SELECT I.InvoiceID,0 as Detail, 
'DETAIL' as Col1Text, 
'SEE ATTACHED DETAIL' as Col2Text, 
SUM(POI.ProductPrice) as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN @tmp_IncludeReports IR
	ON I.InvoiceID=IR.InvoiceID	
	AND IR.IncludeReport=1
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY I.InvoiceID
) A

--SELECT * FROM @tmp_IncludeReports

UPDATE I
SET BillingReportGroupID=4
FROM Invoices I INNER JOIN @tmp_IncludeReports IR ON I.InvoiceID=IR.InvoiceID
WHERE IR.IncludeReport=1
AND I.BillingReportGroupID=0






--Create Invoice with See Attached Detail (InvoiceTemplateID = 6)
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Description',
NumberOfColumns=2
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=6)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.Detail), Col1Text, 
Col2Text, '' as Col3Text, '' as Col4Text, '' as Col5Text, '' as Col6Text, '' as Col7Text, '' as Col8Text, A.Amount
FROM (
SELECT I.InvoiceID,0 as Detail, 
'DETAIL' as Col1Text, 
'SEE ATTACHED DETAIL' as Col2Text, 
SUM(POI.ProductPrice) as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=6
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY I.InvoiceID
) A



--Create Invoice with Subtotal by Sub-client (InvoiceTemplateID = 7)
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Description',
NumberOfColumns=2
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=7)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.Col2Text, A.Detail), Col1Text, 
Col2Text, '' as Col3Text, '' as Col4Text, '' as Col5Text, '' as Col6Text, '' as Col7Text, '' as Col8Text, A.Amount
FROM (
SELECT I.InvoiceID,0 as Detail, 
'DETAIL' as Col1Text, 
OC.ClientName + ' - SEE ATTACHED DETAIL' as Col2Text, 
SUM(POI.ProductPrice) as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
INNER JOIN Clients OC --OriginalClient
	ON OC.ClientID=POI.OriginalClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=7
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY I.InvoiceID, POI.OriginalClientID, OC.ClientName

) A




--Create Summary (Group By FileNum) Invoice 1.0 [Improved] (InvoiceTemplateID = 8)
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Date Ordered',
Col3Header='Name',
Col4Header='SSN',
Col5Header='Ordered By',
Col6Header='File #',
Col7Header='Reference',
NumberOfColumns=7
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=8)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.Col3Text, A.FileNum, A.Detail), Col1Text, Col2Text, Col3Text, 
Col4Text, Col5Text, Col6Text, Col7Text, '', A.Amount
FROM (
SELECT POI.FileNum,
POI.InvoiceID,
0 as Detail, 
CASE 
	WHEN POI.ProductType = 'EMP' THEN 'EMPLOYMENT'
	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
	ELSE UPPER(POI.ProductType)
END
as Col1Text, 
CONVERT(varchar(10),MIN(POI.DateOrdered),101) as Col2Text, 
POI.LName + ', ' + POI.FName as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) as Col4Text,
POI.OrderBy as Col5Text,
POI.FileNum as Col6Text,
POI.Reference as Col7Text,
SUM(POI.ProductPrice) as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=8
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.FileNum, POI.ProductType, POI.LName, POI.FName, POI.SSN, POI.OrderBy,
POI.Reference, POI.CoLName, POI.CoFName, POI.CoMName, POI.CoSSN, CIS.HideSSN

UNION ALL

SELECT POI.FileNum,
POI.InvoiceID,
1 as Detail, 
'' as Col1Text, 
'' as Col2Text, 
POI.CoLName + ', ' + ISNULL(POI.CoFName,'') as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE ISNULL(POI.CoSSN,'') END) as Col4Text,
'' as Col5Text,
POI.FileNum as Col6Text,
'' as Col7Text,
0 as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=8
AND POI.CoLName<>''
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.FileNum, POI.ProductType, POI.LName, POI.FName, POI.SSN, POI.OrderBy,
POI.Reference, POI.CoLName, POI.CoFName, POI.CoMName, POI.CoSSN, CIS.HideSSN

) A






--Create Paylease (InvoiceTemplateID = 9)
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Quantity',
Col3Header='Rate',
NumberOfColumns=3
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=9)

DECLARE @tmp_FileNumGrouping TABLE (
	InvoiceID int,
	FileNum varchar(50),
	Credit tinyint,
	Nat tinyint,
	Eviction tinyint	
)

INSERT INTO @tmp_FileNumGrouping
SELECT I.InvoiceID, FileNum, 
(CASE WHEN (SELECT COUNT(*) FROM ProductTransactions PT1 WHERE PT1.FileNum=POI.FileNum 
AND PT1.ProductID IN (2,48)) > 0 THEN 1 ELSE 0 END) as Credit, 
(CASE WHEN (SELECT COUNT(*) FROM ProductTransactions PT2 WHERE PT2.FileNum=POI.FileNum 
AND PT2.ProductID=80) > 0 THEN 1 ELSE 0 END) as Nat, 
(CASE WHEN (SELECT COUNT(*) FROM ProductTransactions PT3 WHERE PT3.FileNum=POI.FileNum 
AND PT3.ProductID=91) > 0 THEN 1 ELSE 0 END) as Eviction
FROM ProductsOnInvoice POI
INNER JOIN Invoices I
	ON POI.InvoiceID=I.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON I.ClientID=CIS.ClientID
WHERE CIS.InvoiceTemplateID=9
AND POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY I.InvoiceID, FileNum

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, 
Col4Text, Col5Text, Col6Text, Col7Text, Col8Text, Amount)
SELECT InvoiceID, ROW_NUMBER() OVER (PARTITION BY B.InvoiceID ORDER BY B.InvoiceID),
Product as Col1Text, 
COUNT(*) as Col2Text, 
B.Price as Col3Text,
'' as Col4Text,
'' as Col5Text,
'' as Col6Text,
'' as Col7Text,
'' as Col8Text,
COUNT(*) * B.Price as Amount
FROM
(
SELECT I.InvoiceID, 
I.ClientID, POI.FileNum, 'Premier' as Product, 
SUM(POI.ProductPrice) as Price 
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
INNER JOIN
@tmp_FileNumGrouping A
	ON A.FileNum=POI.FileNum
	AND A.InvoiceID=POI.InvoiceID	
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=9
AND A.Credit+A.Eviction+A.Nat=3
AND POI.ProductID IN (2,48,80,91) 
AND POI.ProductDescription NOT LIKE '%2ND%'
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY I.InvoiceID, I.ClientID, POI.FileNum


UNION ALL

SELECT I.InvoiceID, I.ClientID, POI.FileNum, P.ProductName as Product, POI.ProductPrice as Price 
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
INNER JOIN
@tmp_FileNumGrouping A
	ON A.FileNum=POI.FileNum
	AND A.InvoiceID=POI.InvoiceID
WHERE CIS.InvoiceTemplateID=9
AND POI.ProductPrice<>0 
AND (A.Credit+A.Eviction+A.Nat<3 OR POI.ProductID in (251, 94, 83))
AND I.CreateInvoicesBatchID=@InvoiceBatchID

UNION ALL

SELECT I.InvoiceID, I.ClientID, POI.FileNum, '2nd ' + P.ProductName as Product, 
POI.ProductPrice as Price 
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
INNER JOIN
@tmp_FileNumGrouping A
	ON A.FileNum=POI.FileNum
	AND A.InvoiceID=POI.InvoiceID
WHERE CIS.InvoiceTemplateID=9
AND POI.ProductPrice<>0 
AND A.Credit+A.Eviction+A.Nat=3
AND POI.ProductID IN (2,48,80,91) 
AND POI.ProductDescription LIKE '%2ND%'
AND I.CreateInvoicesBatchID=@InvoiceBatchID
) B
GROUP BY B.InvoiceID, B.Product, B.Price
ORDER BY Product






--Create Summary Custom BWPantex $51.25 (Group By FileNum) Invoice 1.0 [Improved] (InvoiceTemplateID = 10)
DECLARE @tmp_BWPantex TABLE (
	FileNum varchar(50)
)

INSERT INTO @tmp_BWPantex (FileNum)
SELECT POI.FileNum
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=10
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.FileNum
HAVING SUM(POI.ProductPrice) > 51.25


UPDATE Invoices
SET Col1Header='Product',
Col2Header='Date Ordered',
Col3Header='Name',
Col4Header='SSN',
Col5Header='Ordered By',
Col6Header='File #',
Col7Header='Reference',
NumberOfColumns=7
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=10)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.Col3Text, A.FileNum, A.Detail), Col1Text, Col2Text, Col3Text, 
Col4Text, Col5Text, Col6Text, Col7Text, '', A.Amount
FROM (
SELECT POI.FileNum,
POI.InvoiceID,
0 as Detail, 
CASE 
	WHEN POI.ProductType = 'EMP' THEN 'EMPLOYMENT'
	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
	ELSE UPPER(POI.ProductType)
END
as Col1Text, 
CONVERT(varchar(10),MIN(POI.DateOrdered),101) as Col2Text, 
POI.LName + ', ' + POI.FName as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) as Col4Text,
POI.OrderBy as Col5Text,
POI.FileNum as Col6Text,
POI.Reference as Col7Text,
SUM(POI.ProductPrice) as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=10
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.FileNum, POI.ProductType, POI.LName, POI.FName, POI.SSN, POI.OrderBy,
POI.Reference, POI.CoLName, POI.CoFName, POI.CoMName, POI.CoSSN, CIS.HideSSN
HAVING SUM(POI.ProductPrice) <= 51.25

UNION ALL

SELECT POI.FileNum,
POI.InvoiceID,
0 as Detail, 
CASE 
	WHEN POI.ProductType = 'EMP' THEN 'EMPLOYMENT'
	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
	ELSE UPPER(POI.ProductType)
END
as Col1Text, 
CONVERT(varchar(10),MIN(POI.DateOrdered),101) as Col2Text, 
POI.LName + ', ' + POI.FName as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) as Col4Text,
POI.OrderBy as Col5Text,
POI.FileNum as Col6Text,
POI.Reference as Col7Text,
SUM(POI.ProductPrice) as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
INNER JOIN @tmp_BWPantex BW
	ON POI.FileNum=BW.FileNum
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=10
AND POI.ProductID NOT IN (172, 373, 374)
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.FileNum, POI.ProductType, POI.LName, POI.FName, POI.SSN, POI.OrderBy,
POI.Reference, POI.CoLName, POI.CoFName, POI.CoMName, POI.CoSSN, CIS.HideSSN

UNION ALL

SELECT POI.FileNum,
POI.InvoiceID,
1 as Detail, 
'ACCESS FEE' as Col1Text, 
CONVERT(varchar(10),MIN(POI.DateOrdered),101) as Col2Text, 
POI.LName + ', ' + POI.FName as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) as Col4Text,
POI.OrderBy as Col5Text,
POI.FileNum as Col6Text,
POI.Reference as Col7Text,
SUM(POI.ProductPrice) as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
INNER JOIN @tmp_BWPantex BW
	ON POI.FileNum=BW.FileNum
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=10
AND POI.ProductID IN (172, 373, 374)
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.FileNum, POI.ProductType, POI.LName, POI.FName, POI.SSN, POI.OrderBy,
POI.Reference, POI.CoLName, POI.CoFName, POI.CoMName, POI.CoSSN, CIS.HideSSN


) A



--Used for CDL School Inc and 
--Create Invoice with Quantity and Rate - Separate Vendor (InvoiceTemplateID = 11)
UPDATE Invoices
SET Col1Header='Description',
Col2Header='Quantity',
Col3Header='Rate',
NumberOfColumns=3
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=11)


INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.Detail), Col1Text, 
Col2Text, Col3Text, '' as Col4Text, '' as Col5Text, '' as Col6Text, '' as Col7Text, '' as Col8Text, A.Amount
FROM (
SELECT I.InvoiceID,0 as Detail, 
'Instascreen System - SEE ATTACHED DETAIL' as Col1Text, 
'1' as Col2Text, 
SUM(POI.ProductPrice) as Col3Text,
SUM(POI.ProductPrice) as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN VendorProducts VP
	ON VP.ProductID=P.ProductID
	AND VP.VendorID=POI.VendorID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND VP.VendorID NOT IN (4,5)
AND CIS.InvoiceTemplateID=11
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY I.InvoiceID

UNION ALL

SELECT I.InvoiceID,2 as Detail, 
P.ProductName as Col1Text, 
COUNT(*) as Col2Text, 
POI.ProductPrice as Col3Text,
COUNT(*) * POI.ProductPrice as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN VendorProducts VP
	ON VP.ProductID=P.ProductID
	AND VP.VendorID=POI.VendorID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND VP.VendorID IN (4,5)
AND POI.ProductID NOT IN (178,232)
AND CIS.InvoiceTemplateID=11
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY I.InvoiceID,P.ProductID,P.ProductCode,P.ProductName,POI.ProductPrice

UNION ALL

SELECT I.InvoiceID,4 as Detail, 
'FACTA SURCHARGE' as Col1Text, 
COUNT(*) as Col2Text, 
POI.ProductPrice as Col3Text,
COUNT(*) * POI.ProductPrice as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN VendorProducts VP
	ON VP.ProductID=P.ProductID
	AND VP.VendorID=POI.VendorID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND VP.VendorID IN (4,5)
AND POI.ProductID IN (178,232)
AND CIS.InvoiceTemplateID=11
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY I.InvoiceID,POI.ProductPrice

) A
ORDER BY InvoiceID, Detail




--Create Summary (Group By FileNum) - Luth Research LLC (InvoiceTemplateID = 12)
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Date Ordered',
Col3Header='Name',
Col4Header='SSN',
Col5Header='Ordered By',
Col6Header='File #',
Col7Header='Reference',
NumberOfColumns=7
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=12)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.Col3Text, A.FileNum, A.Detail), Col1Text, Col2Text, Col3Text, 
Col4Text, Col5Text, Col6Text, Col7Text, '', A.Amount
FROM (
SELECT POI.FileNum,
POI.InvoiceID,
0 as Detail, 
CASE 
	WHEN POI.ProductType = 'EMP' THEN 'EMPLOYMENT'
	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
	ELSE UPPER(POI.ProductType)
END
as Col1Text, 
CONVERT(varchar(10),MIN(POI.DateOrdered),101) as Col2Text, 
LEFT(POI.LName,3) + ', ' + POI.FName as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) as Col4Text,
POI.OrderBy as Col5Text,
POI.FileNum as Col6Text,
POI.Reference as Col7Text,
SUM(POI.ProductPrice) as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=12
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.FileNum, POI.ProductType, POI.LName, POI.FName, POI.SSN, POI.OrderBy,
POI.Reference, POI.CoLName, POI.CoFName, POI.CoMName, POI.CoSSN, CIS.HideSSN

UNION ALL

SELECT POI.FileNum,
POI.InvoiceID,
1 as Detail, 
'' as Col1Text, 
'' as Col2Text, 
LEFT(POI.CoLName,3) + ', ' + ISNULL(POI.CoFName,'') as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE ISNULL(POI.CoSSN,'') END) as Col4Text,
'' as Col5Text,
POI.FileNum as Col6Text,
'' as Col7Text,
0 as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=12
AND POI.CoLName<>''
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.FileNum, POI.ProductType, POI.LName, POI.FName, POI.SSN, POI.OrderBy,
POI.Reference, POI.CoLName, POI.CoFName, POI.CoMName, POI.CoSSN, CIS.HideSSN

) A




--Create Paylease Package (InvoiceTemplateID = 13)
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Quantity',
Col3Header='Rate',
NumberOfColumns=3
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=13)

DECLARE @tmp_FileNumGrouping2 TABLE (
	InvoiceID int,
	FileNum varchar(50),
	Credit tinyint,
	Nat tinyint
)

INSERT INTO @tmp_FileNumGrouping2
SELECT I.InvoiceID,FileNum, 
(CASE WHEN (SELECT COUNT(*) FROM ProductTransactions PT1 WHERE PT1.FileNum=POI.FileNum 
AND PT1.ProductID IN (2,48)) > 0 THEN 1 ELSE 0 END) as Credit, 
(CASE WHEN (SELECT COUNT(*) FROM ProductTransactions PT2 WHERE PT2.FileNum=POI.FileNum 
AND PT2.ProductID=80) > 0 THEN 1 ELSE 0 END) as Nat
FROM ProductsOnInvoice POI
INNER JOIN Invoices I
	ON POI.InvoiceID=I.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON I.ClientID=CIS.ClientID
WHERE CIS.InvoiceTemplateID=13
AND POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY I.InvoiceID, FileNum

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, 
Col4Text, Col5Text, Col6Text, Col7Text, Col8Text, Amount)
SELECT InvoiceID, ROW_NUMBER() OVER (PARTITION BY B.InvoiceID ORDER BY B.InvoiceID),
Product as Col1Text, 
COUNT(*) as Col2Text, 
B.Price as Col3Text,
'' as Col4Text,
'' as Col5Text,
'' as Col6Text,
'' as Col7Text,
'' as Col8Text,
COUNT(*) * B.Price as Amount
FROM
(
SELECT I.InvoiceID, 
I.ClientID, POI.FileNum, 'Package' as Product, 
SUM(POI.ProductPrice) as Price 
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
INNER JOIN
@tmp_FileNumGrouping2 A
	ON A.FileNum=POI.FileNum
	AND A.InvoiceID=POI.InvoiceID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=13
AND A.Credit+A.Nat=2
AND POI.ProductID IN (2,48,80) 
AND POI.ProductDescription NOT LIKE '%2ND%'
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY I.InvoiceID, I.ClientID, POI.FileNum

UNION ALL

SELECT I.InvoiceID, I.ClientID, POI.FileNum, P.ProductName as Product, POI.ProductPrice as Price 
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
INNER JOIN
@tmp_FileNumGrouping2 A
	ON A.FileNum=POI.FileNum
	AND A.InvoiceID=POI.InvoiceID
WHERE CIS.InvoiceTemplateID=13
AND POI.ProductPrice<>0 
AND (A.Credit+A.Nat<2 OR POI.ProductID=251)
AND I.CreateInvoicesBatchID=@InvoiceBatchID

UNION ALL

SELECT I.InvoiceID, I.ClientID, POI.FileNum, '2nd ' + P.ProductName as Product, 
POI.ProductPrice as Price 
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
INNER JOIN
@tmp_FileNumGrouping2 A
	ON A.FileNum=POI.FileNum
	AND A.InvoiceID=POI.InvoiceID
WHERE CIS.InvoiceTemplateID=13
AND POI.ProductPrice<>0 
AND A.Credit+A.Nat=2
AND POI.ProductID IN (2,48,80) 
AND POI.ProductDescription LIKE '%2ND%'
AND I.CreateInvoicesBatchID=@InvoiceBatchID
) B
GROUP BY B.InvoiceID, B.Product, B.Price
ORDER BY Product





--Create Custom - Village Green Management (InvoiceTemplateID = 14)
--UPDATE Invoices
--SET Col1Header='Product',
--Col2Header='Date Ordered / Name / SSN / Ordered By / File # / Reference',
--NumberOfColumns=2
--WHERE InvoiceID IN 
--(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
--INNER JOIN @ProductsOnInvoice POI2 
--	ON CIS.ClientID=POI2.ClientID 
--WHERE CIS.InvoiceTemplateID=14)

--INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
--Col7Text, Col8Text, Amount)
--SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.LName, A.FName, A.FileNum, A.Detail), Col1Text, 
--Col2Text, '' as Col3Text, '' as Col4Text, '' as Col5Text, '' as Col6Text, '' as Col7Text, '' as Col8Text, A.Amount
--FROM (
--SELECT POI.FileNum,
--POI.InvoiceID,
--0 as Detail, 
--CASE 
--	WHEN POI.ProductType = 'EMP' THEN 'EMPLOYMENT'
--	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
--	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
--	ELSE UPPER(POI.ProductType)
--END
--as Col1Text, 
--CONVERT(varchar(10),POI.DateOrdered,101) + ' ' 
--+ POI.LName + ', ' + POI.FName + ' ' + (CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) 
--+ ' ' + POI.OrderBy + ' ' + POI.FileNum + ' ' + POI.Reference + ' ' 
--+ POI.ProductDescription
--as Col2Text,
--POI.ProductPrice as Amount,
--POI.LName, POI.FName
--FROM ProductsOnInvoice POI
--INNER JOIN Products P
--	ON P.ProductID=POI.ProductID
--INNER JOIN Invoices I
--	ON I.InvoiceID=POI.InvoiceID
--INNER JOIN ClientInvoiceSettings CIS
--	ON CIS.ClientID=I.ClientID
--WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
--AND POI.ProductPrice<>0
--AND I.CreateInvoicesBatchID=@InvoiceBatchID
--AND CIS.InvoiceTemplateID=14

--UNION ALL

--SELECT POI.FileNum,
--POI.InvoiceID,
--0 as Detail, 
--CASE 
--	WHEN POI.ProductType = 'EMP' THEN 'EMPLOYMENT'
--	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
--	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
--	ELSE UPPER(POI.ProductType)
--END
--as Col1Text, 
--CONVERT(varchar(10),POI.DateOrdered,101) + ' ' 
--+ POI.LName + ', ' + POI.FName + ' ' + (CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) 
--+ ' ' + POI.OrderBy + ' ' + POI.FileNum + ' ' + POI.Reference + ' ' 
--+ POI.ProductDescription
--as Col2Text,
--POI.ProductPrice as Amount,
--POI.LName, POI.FName
--FROM ProductsOnInvoice POI
--INNER JOIN Products P
--	ON P.ProductID=POI.ProductID
--INNER JOIN Invoices I
--	ON I.InvoiceID=POI.InvoiceID
--INNER JOIN ClientInvoiceSettings CIS
--	ON CIS.ClientID=I.ClientID
--WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
--AND POI.ProductPrice<>0
--AND POI.CoLName<>''
--AND I.CreateInvoicesBatchID=@InvoiceBatchID
--AND CIS.InvoiceTemplateID=14

--) A
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Date Ordered',
Col3Header='Name',
Col4Header='SSN',
Col5Header='Ordered By',
Col6Header='File #',
Col7Header='Reference',
NumberOfColumns=7
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=14)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY Col7Text,Col3Text,A.FileNum, A.InvoiceID ), Col1Text, 
Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, Col7Text,'' as Col8Text, A.Amount
FROM (
SELECT POI.FileNum,
POI.InvoiceID,
0 as Detail, 
CASE 
	WHEN POI.ProductType = 'EMP' THEN 'EMPLOYMENT'
	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
	ELSE UPPER(POI.ProductType)
END
as Col1Text, 
CONVERT(varchar(10),POI.DateOrdered,101) as Col2Text, 
POI.LName + ', ' + POI.FName as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END)  as Col4Text,
POI.OrderBy as Col5Text,
POI.FileNum as Col6Text,
POI.Reference as Col7Text,
POI.ProductDescription,
POI.ProductPrice as Amount,
POI.LName, POI.FName
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND I.CreateInvoicesBatchID=@InvoiceBatchID
AND CIS.InvoiceTemplateID=14

UNION ALL

SELECT POI.FileNum,
POI.InvoiceID,
0 as Detail, 
CASE 
	WHEN POI.ProductType = 'EMP' THEN 'EMPLOYMENT'
	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
	ELSE UPPER(POI.ProductType)
END
as Col1Text, 
CONVERT(varchar(10),POI.DateOrdered,101) as Col2Text,
+ POI.LName + ', ' + POI.FName as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) as Col4Text,
POI.OrderBy as Col5Text,
POI.FileNum as Col6Text,
POI.Reference as Col7Text,
POI.ProductDescription,
POI.ProductPrice as Amount,
POI.LName, POI.FName
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND POI.CoLName<>''
AND I.CreateInvoicesBatchID=@InvoiceBatchID
AND CIS.InvoiceTemplateID=14

) A


--Create Summary Pohanka Automotive Group (InvoiceTemplateID = 15)
UPDATE Invoices
SET 
Col1Header='File #',
Col2Header='Date Ordered',
Col3Header='Name',
Col4Header='SSN',
Col5Header='Ordered By',
Col6Header='Reference',
Col7Header='Item Amount',
NumberOfColumns=7
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=15)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, 
Col5Text, Col6Text, Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, 
ROW_NUMBER() OVER (ORDER BY A.Col6Text, A.GroupDetail, A.Col3Text, A.Detail, A.FileNum, A.InvoiceID), 
Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, Col7Text, '', A.Amount
FROM (
SELECT POI.FileNum as FileNum,
POI.InvoiceID,
0 as Detail, 
0 as GroupDetail,
POI.FileNum as Col1Text,
CONVERT(varchar(10),MIN(POI.DateOrdered),101) as Col2Text, 
POI.LName + ', ' + POI.FName as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) as Col4Text,
POI.OrderBy as Col5Text,
POI.Reference as Col6Text,
CONVERT(varchar(50),CONVERT(decimal(11,2),SUM(POI.ProductPrice))) as Col7Text,
0 as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=15
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.FileNum, POI.ProductType, POI.LName, POI.FName, POI.SSN, POI.OrderBy,
POI.Reference, POI.CoLName, POI.CoFName, POI.CoMName, POI.CoSSN, CIS.HideSSN

UNION ALL

SELECT POI.FileNum,
POI.InvoiceID,
1 as Detail, 
0 as GroupDetail,
POI.FileNum as Col1Text,
'' as Col2Text, 
POI.CoLName + ', ' + ISNULL(POI.CoFName,'') as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE ISNULL(POI.CoSSN,'') END) as Col4Text,
'' as Col5Text,
POI.Reference as Col6Text,
'' as Col7Text,
0 as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=15
AND POI.CoLName<>''
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.FileNum, POI.ProductType, POI.LName, POI.FName, POI.SSN, POI.OrderBy,
POI.Reference, POI.CoLName, POI.CoFName, POI.CoMName, POI.CoSSN, CIS.HideSSN

UNION ALL

SELECT '' as FileNum,
POI.InvoiceID,
0 as Detail,
1 as GroupDetail, 
'' as Col1Text, 
'' as Col2Text, 
'' as Col3Text,
'' as Col4Text,
'' as Col5Text,
POI.Reference as Col6Text,
'' as Col7Text,
SUM(POI.ProductPrice) as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=15
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.Reference

) A

--Create Standard Invoice 1.0 Colorado Christian Univerity - Student (InvoiceTemplateID = 16)
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Date Ordered',
Col3Header='Name',
Col4Header='SSN',
Col5Header='Ordered By',
Col6Header='File #',
Col7Header='Reference',
NumberOfColumns=7
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=16)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.Col3Text, A.FileNum, A.Detail), Col1Text, Col2Text, Col3Text, 
Col4Text, Col5Text, Col6Text, Col7Text, '', A.Amount
FROM (
SELECT POI.FileNum,
POI.InvoiceID,
0 as Detail, 
CASE 
	WHEN POI.ProductType = 'EMP' THEN 'STUDENT'
	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
	ELSE UPPER(POI.ProductType)
END
as Col1Text, 
CONVERT(varchar(10),POI.DateOrdered,101) as Col2Text, 
POI.LName + ', ' + POI.FName as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) as Col4Text,
POI.OrderBy as Col5Text,
POI.FileNum as Col6Text,
POI.Reference as Col7Text,
POI.ProductPrice as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=16
AND I.CreateInvoicesBatchID=@InvoiceBatchID

UNION ALL

SELECT POI.FileNum,
POI.InvoiceID,
1 as Detail, 
'' as Col1Text, 
CONVERT(varchar(10),POI.DateOrdered,101) as Col2Text, 
POI.CoLName + ', ' + ISNULL(POI.CoFName,'') as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.CoSSN END) as Col4Text,
'' as Col5Text,
POI.FileNum as Col6Text,
'' as Col7Text,
0 as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=16
AND POI.CoLName<>''
AND I.CreateInvoicesBatchID=@InvoiceBatchID

) A

--Unknown invoice type....was added, but no client is using it. Will leave alone. 
UPDATE Invoices
SET Col1Header='Product',
Col2Header='Date Ordered',
Col3Header='Name',
Col4Header='SSN',
Col5Header='Ordered By',
Col6Header='File #',
Col7Header='Reference',
NumberOfColumns=7
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=17)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.Col7Text, A.Col3Text, A.Detail), Col1Text, Col2Text, Col3Text, 
Col4Text, Col5Text, Col6Text, Col7Text, '', A.Amount
FROM (
SELECT POI.FileNum,
POI.InvoiceID,
0 as Detail, 
CASE 
	WHEN POI.ProductType = 'EMP' THEN 'EMPLOYMENT'
	WHEN POI.ProductType = 'TNT' THEN 'TENANT'
	WHEN POI.ProductType = 'COLLECT' THEN 'COLLECTION'
	ELSE UPPER(POI.ProductType)
END
as Col1Text, 
CONVERT(varchar(10),MIN(POI.DateOrdered),101) as Col2Text, 
POI.LName + ', ' + POI.FName as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) as Col4Text,
POI.OrderBy as Col5Text,
POI.FileNum as Col6Text,
POI.Reference as Col7Text,
SUM(POI.ProductPrice) as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=17
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.FileNum, POI.ProductType, POI.LName, POI.FName, POI.SSN, POI.OrderBy,
POI.Reference, POI.CoLName, POI.CoFName, POI.CoMName, POI.CoSSN, CIS.HideSSN

UNION ALL

SELECT POI.FileNum,
POI.InvoiceID,
1 as Detail, 
'' as Col1Text, 
'' as Col2Text, 
POI.CoLName + ', ' + ISNULL(POI.CoFName,'') as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE ISNULL(POI.CoSSN,'') END) as Col4Text,
'' as Col5Text,
POI.FileNum as Col6Text,
'' as Col7Text,
0 as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=17
AND POI.CoLName<>''
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.FileNum, POI.ProductType, POI.LName, POI.FName, POI.SSN, POI.OrderBy,
POI.Reference, POI.CoLName, POI.CoFName, POI.CoMName, POI.CoSSN, CIS.HideSSN

) A

--Create Standard Invoice Jani King Franchise (InvoiceTemplateID = 18)
UPDATE Invoices
SET Col1Header='Date Ordered',
Col2Header='Name',
Col3Header='Ordered By',
Col4Header='File #',
Col5Header='Reference',
NumberOfColumns=5
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=18)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, 
Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, ROW_NUMBER() OVER (PARTITION BY A.InvoiceID ORDER BY A.InvoiceID, A.Col3Text, A.FileNum, A.Detail), Col1Text, Col2Text, Col3Text, 
Col4Text, Col5Text, '', '', '', A.Amount
FROM (
SELECT POI.FileNum,
POI.InvoiceID,
0 as Detail, 
CONVERT(varchar(10),POI.DateOrdered,101) as Col1Text, 
POI.LName + ', ' + POI.FName as Col2Text,
POI.OrderBy as Col3Text,
POI.FileNum as Col4Text,
POI.Reference as Col5Text,
POI.ProductPrice as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=18
AND I.CreateInvoicesBatchID=@InvoiceBatchID

UNION ALL

SELECT POI.FileNum,
POI.InvoiceID,
1 as Detail, 
CONVERT(varchar(10),POI.DateOrdered,101) as Col1Text, 
POI.CoLName + ', ' + ISNULL(POI.CoFName,'') as Col2Text,
'' as Col3Text,
POI.FileNum as Col4Text,
'' as Col5Text,
0 as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=18
AND POI.CoLName<>''
AND I.CreateInvoicesBatchID=@InvoiceBatchID

) A

--Create Summary By Reference (InvoiceTemplateID = 19)
UPDATE Invoices
SET 
Col1Header='File #',
Col2Header='Date Ordered',
Col3Header='Name',
Col4Header='SSN',
Col5Header='Ordered By',
Col6Header='Reference',
Col7Header='Item Amount',
NumberOfColumns=7
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=19)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, 
Col5Text, Col6Text, Col7Text, Col8Text, Amount)
SELECT A.InvoiceID, 
ROW_NUMBER() OVER (ORDER BY A.Col6Text, A.GroupDetail, A.Col3Text, A.Detail, A.FileNum, A.InvoiceID), 
Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, Col7Text, '', A.Amount
FROM (
SELECT POI.FileNum as FileNum,
POI.InvoiceID,
0 as Detail, 
0 as GroupDetail,
POI.FileNum as Col1Text,
CONVERT(varchar(10),MIN(POI.DateOrdered),101) as Col2Text, 
POI.LName + ', ' + POI.FName as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE POI.SSN END) as Col4Text,
POI.OrderBy as Col5Text,
POI.Reference as Col6Text,
CONVERT(varchar(50),CONVERT(decimal(11,2),SUM(POI.ProductPrice))) as Col7Text,
0 as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=19
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.FileNum, POI.ProductType, POI.LName, POI.FName, POI.SSN, POI.OrderBy,
POI.Reference, POI.CoLName, POI.CoFName, POI.CoMName, POI.CoSSN, CIS.HideSSN

UNION ALL

SELECT POI.FileNum,
POI.InvoiceID,
1 as Detail, 
0 as GroupDetail,
POI.FileNum as Col1Text,
'' as Col2Text, 
POI.CoLName + ', ' + ISNULL(POI.CoFName,'') as Col3Text,
(CASE WHEN CIS.HideSSN=1 THEN '' ELSE ISNULL(POI.CoSSN,'') END) as Col4Text,
'' as Col5Text,
POI.Reference as Col6Text,
'' as Col7Text,
0 as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=19
AND POI.CoLName<>''
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.FileNum, POI.ProductType, POI.LName, POI.FName, POI.SSN, POI.OrderBy,
POI.Reference, POI.CoLName, POI.CoFName, POI.CoMName, POI.CoSSN, CIS.HideSSN

UNION ALL

SELECT '' as FileNum,
POI.InvoiceID,
0 as Detail,
1 as GroupDetail, 
'' as Col1Text, 
'' as Col2Text, 
'' as Col3Text,
'' as Col4Text,
'' as Col5Text,
POI.Reference as Col6Text,
'' as Col7Text,
SUM(POI.ProductPrice) as Amount
FROM ProductsOnInvoice POI
INNER JOIN Products P
	ON P.ProductID=POI.ProductID
INNER JOIN Invoices I
	ON I.InvoiceID=POI.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE POI.ProductTransactionID IN (SELECT ProductTransactionID FROM @ProductsOnInvoice)
AND POI.ProductPrice<>0
AND CIS.InvoiceTemplateID=19
AND I.CreateInvoicesBatchID=@InvoiceBatchID
GROUP BY POI.InvoiceID, POI.Reference

) A



--SanMar Number of Screenings/DrugTests by Subaccount
--Create Summary By Reference (InvoiceTemplateID = 20)
UPDATE Invoices
SET 
Col1Header='Product',
Col2Header='Description',
Col3Header='Number of Orders',
Col4Header='',
Col5Header='',
Col6Header='',
Col7Header='',
NumberOfColumns=3
WHERE InvoiceID IN 
(SELECT DISTINCT POI2.InvoiceID FROM ClientInvoiceSettings CIS 
INNER JOIN @ProductsOnInvoice POI2 
	ON CIS.ClientID=POI2.ClientID 
WHERE CIS.InvoiceTemplateID=20)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, 
Col5Text, Col6Text, Col7Text, Col8Text, Amount)
SELECT I.InvoiceID, ROW_NUMBER() OVER (PARTITION BY I.InvoiceID ORDER BY A.clientname, A.OrderNum), Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, Col7Text, Col8Text, A.Amount
FROM (
select 0 as OrderNum, c.clientname, 'DETAIL' as Col1Text, c.clientname as Col2Text, 
(select CONVERT(varchar, COUNT(distinct po2.FileNum)) + ' - Screenings'
from @ProductsOnInvoice po2
inner join ProductTransactions pt2 on pt2.ProductTransactionID = po2.ProductTransactionID
INNER JOIN Clients c2 on c2.ClientID = pt2.clientid
where InvoiceID = PO.InvoiceID
and c2.ClientName=c.ClientName
and po2.ProductID not in (167, 168, 367, 368)
group by c2.clientname) as Col3Text,
'' as Col4Text,
'' as Col5Text,
'' as Col6Text,
'' as Col7Text,
'' as Col8Text,
sum(po.ProductPrice) as Amount, PO.InvoiceID
from @ProductsOnInvoice po
inner join ProductTransactions pt on pt.ProductTransactionID = po.ProductTransactionID
inner join clients c on c.clientid = pt.clientid
group by PO.InvoiceID, clientname

UNION ALL

select 1 as OrderNum, c.clientname, 'DETAIL' as Col1Text, '' as Col2Text, 
(select CONVERT(varchar, COUNT(distinct po2.FileNum)) + ' - Drug Tests'
from @ProductsOnInvoice po2
inner join ProductTransactions pt2 on pt2.ProductTransactionID = po2.ProductTransactionID
INNER JOIN Clients c2 on c2.ClientID = pt2.clientid
where InvoiceID = PO.InvoiceID
and c2.ClientName=c.ClientName
and po2.ProductID in (167, 168, 367, 368)
group by c2.clientname) as Col3Text,
'' as Col4Text,
'' as Col5Text,
'' as Col6Text,
'' as Col7Text,
'' as Col8Text,
0 as Amount, PO.InvoiceID
from @ProductsOnInvoice po
inner join ProductTransactions pt on pt.ProductTransactionID = po.ProductTransactionID
inner join clients c on c.clientid = pt.clientid
group by PO.InvoiceID, clientname

UNION ALL

select 3 as OrderNum, c.clientname, 'DETAIL' as Col1Text, '' as Col2Text, 
'' as Col3Text,
'' as Col4Text,
'' as Col5Text,
'' as Col6Text,
'' as Col7Text,
'' as Col8Text,
0 as Amount, PO.InvoiceID
from @ProductsOnInvoice po
inner join ProductTransactions pt on pt.ProductTransactionID = po.ProductTransactionID
inner join clients c on c.clientid = pt.clientid
group by PO.InvoiceID, clientname

) A
INNER JOIN Invoices I
	ON I.InvoiceID=A.InvoiceID
INNER JOIN ClientInvoiceSettings CIS
	ON CIS.ClientID=I.ClientID
WHERE CIS.InvoiceTemplateID=20
AND I.CreateInvoicesBatchID=@InvoiceBatchID






--Set Billing Detail Report to 0 if there are no Tazworks or ScreeningONE Product transactions in the invoice.
Update Invoices
set BillingReportGroupID = 0
where InvoiceDate = @InvoiceDate
and ClientID in (
select clientid 
from Invoices 
WHERE InvoiceDate = @InvoiceDate
  and VoidedOn is null
  and BillingReportGroupID > 0
  and InvoiceID not in (
	select distinct InvoiceID from ProductsOnInvoice 
	where InvoiceID in (select invoiceid from invoices where invoicedate = @InvoiceDate) and VendorID in (1, 2, 6, 7, 8))
  )

--Next 4 queries add mailing fee to any invoice that has at least one billing contact with Mail Only delivery method.
Insert into ProductTransactions (ProductID, ClientID, VendorID, TransactionDate, DateOrdered, OrderBy, Reference, FileNum, FName, LName, MName, SSN, ProductName, ProductDescription, ProductType, ProductPrice, ExternalInvoiceNumber, SalesRep, CoLName, CoFName, CoMName, CoSSN, ImportBatchID, Invoiced)
select distinct 369, i.clientid, 6, @EndTransactionDate, @EndTransactionDate, 'ScreeningOne', '', '', 'Mailing', 'Fee', 'Fee', '', 'Mailing Fee', 'Mailing Fee', 0, 5, i.invoicenumber, '', '', '', '', '', 0, 1
from Invoices i
inner join InvoiceBillingContacts ibc on ibc.InvoiceID = i.invoiceid
inner join BillingContacts bc on bc.ClientID = i.ClientID and ibc.BillingContactID = bc.BillingContactID
where i.InvoiceID in (select distinct InvoiceID from @ProductsOnInvoice)
  and bc.DeliveryMethod = 3 
  and i.InvoiceNumber not in (select externalinvoicenumber from ProductTransactions where ProductID = 369 and TransactionDate = @EndTransactionDate and ClientID = i.clientid)

insert into ProductsOnInvoice (InvoiceID, ProductID, ProductTransactionID, ProductPrice, OrderBy, Reference, ProductName, ProductDescription, ProductType, FileNum, DateOrdered, FName, LName, MName, SSN, ExternalInvoiceNumber, OriginalClientID, CoFName, CoLName, CoMName, CoSSN, VendorID)
select distinct il.InvoiceID, 369, pt.producttransactionid, 5.00, '', '', 'Mailing Fee', 'Mailing Fee', 'Fee', '',  @EndTransactionDate, 'Mailing', 'Fee', '', '', i.invoicenumber, i.ClientID, '', '', '', '', 6
from InvoiceLines il
inner join Invoices i on i.InvoiceID = il.invoiceid
inner join ProductTransactions pt on pt.ClientID = i.ClientID and pt.ExternalInvoiceNumber = i.InvoiceNumber and pt.TransactionDate = @EndTransactionDate
inner join InvoiceBillingContacts ibc on ibc.InvoiceID = i.invoiceid
inner join BillingContacts bc on bc.ClientID = i.ClientID and ibc.BillingContactID = bc.BillingContactID
where i.InvoiceID in (select distinct InvoiceID from @ProductsOnInvoice)
  and bc.DeliveryMethod = 3
  and i.InvoiceID not in (select InvoiceID from ProductsOnInvoice where invoiceid = i.invoiceid and ProductID = 369)
group by il.InvoiceID, pt.ProductTransactionID, i.InvoiceNumber, i.ClientID

update Invoices set Amount = Amount + 5 where InvoiceID in (
select distinct i.invoiceid from Invoices i
inner join InvoiceBillingContacts ibc on ibc.InvoiceID = i.invoiceid
inner join BillingContacts bc on bc.ClientID = i.ClientID and ibc.BillingContactID = bc.BillingContactID
where i.InvoiceID in (select distinct InvoiceID from @ProductsOnInvoice)
  and bc.DeliveryMethod = 3
  and i.VoidedOn is null
  and i.InvoiceID not in (select InvoiceID from InvoiceLines where InvoiceID = i.invoiceID and Col1Text = 'Mailing Fee')
 )

insert into InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, Col7Text, Col8Text, Amount)
select distinct il.InvoiceID, MAX(invoicelinenumber) + 1, 'Mailing Fee', '', '', '', '', '', '', '', 5.00
from InvoiceLines il
inner join Invoices i on i.InvoiceID = il.invoiceid
inner join InvoiceBillingContacts ibc on ibc.InvoiceID = i.invoiceid
inner join BillingContacts bc on bc.ClientID = i.ClientID and ibc.BillingContactID = bc.BillingContactID
where i.InvoiceID in (select distinct InvoiceID from @ProductsOnInvoice)
  and bc.DeliveryMethod = 3
  and il.InvoiceID not in (select InvoiceID from InvoiceLines where InvoiceID = il.InvoiceID and Col1Text = 'Mailing Fee')
group by il.InvoiceID

COMMIT TRAN -- Transaction Success!

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN --RollBack in case of Error
END CATCH



GO
