/****** Object:  StoredProcedure [dbo].[S1_ProductTransactions_GetProductTransaction]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--S1_ProductTransactions_GetProductTransaction 54854

CREATE PROCEDURE [dbo].[S1_ProductTransactions_GetProductTransaction]
(
	@ProductTransactionID int
)
AS
	SET NOCOUNT ON;

SELECT ProductTransactionID,
PT.ProductID, 
PT.ClientID, 
C.ClientName,
PT.VendorID, 
V.VendorName,
TransactionDate,
DateOrdered, 
OrderBy, 
Reference, 
FileNum, 
FName,
CP.IncludeOnInvoice, 
LName, 
MName, 
SSN, 
P.ProductName, 
ProductDescription, 
ProductType, 
(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN ISNULL(CP.SalesPrice,0) ELSE ISNULL(PT.ProductPrice,0) END)
AS ProductPrice, 
ExternalInvoiceNumber, 
SalesRep, 
CoLName, 
CoFName, 
CoMName, 
CoSSN,
(CASE WHEN CP.ImportsAtBaseOrSales=0 THEN ISNULL(PT.ProductPrice,0) ELSE ISNULL(P.BaseCost,0) END)
AS BasePrice,
CP.ImportsAtBaseOrSales
FROM ProductTransactions PT
INNER JOIN Vendors V
	ON PT.VendorID=V.VendorID
INNER JOIN Clients C
	ON PT.ClientID=C.ClientID
INNER JOIN Products P
	ON PT.ProductID=P.ProductID
INNER JOIN ClientProducts CP
	ON PT.ClientID=CP.ClientID
	AND PT.ProductID=CP.ProductID
WHERE ProductTransactionID=@ProductTransactionID


GO
