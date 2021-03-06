/****** Object:  StoredProcedure [dbo].[S1_Products_GetProductFromClientAndProductID]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC S1_Products_GetProductFromClientAndProductID 2, 1

CREATE PROCEDURE [dbo].[S1_Products_GetProductFromClientAndProductID]
(
	@ClientID int,
	@ProductID int
)
AS
	SET NOCOUNT ON;
	
SELECT P.ProductID, ProductCode, ProductName, CP.IncludeOnInvoice, CP.SalesPrice, CP.ImportsAtBaseOrSales
FROM Products P
INNER JOIN ClientProducts CP
	ON P.ProductID=CP.ProductID
WHERE CP.ClientID=@ClientID
AND CP.ProductID=@ProductID
ORDER BY ProductName
GO
