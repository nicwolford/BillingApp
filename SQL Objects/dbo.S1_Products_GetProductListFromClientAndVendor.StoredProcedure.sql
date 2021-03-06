/****** Object:  StoredProcedure [dbo].[S1_Products_GetProductListFromClientAndVendor]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC S1_Products_GetProductListFromClientAndVendor 2, 1

CREATE PROCEDURE [dbo].[S1_Products_GetProductListFromClientAndVendor]
(
	@ClientID int,
	@VendorID int
)
AS
	SET NOCOUNT ON;
	
SELECT P.ProductID, ProductCode, ProductName, BaseCost, p.BaseCommission, CP.IncludeOnInvoice, 
Employment, Tenant, Business, Volunteer, Other
FROM Products P
INNER JOIN ClientProducts CP
	ON P.ProductID=CP.ProductID
INNER JOIN VendorProducts VP
	ON VP.ProductID=P.ProductID
WHERE CP.ClientID=@ClientID
AND VP.VendorID=@VendorID
ORDER BY ProductName
GO
