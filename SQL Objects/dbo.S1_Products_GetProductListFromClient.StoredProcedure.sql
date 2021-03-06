/****** Object:  StoredProcedure [dbo].[S1_Products_GetProductListFromClient]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC S1_Products_GetProductListFromClient 1762

CREATE PROCEDURE [dbo].[S1_Products_GetProductListFromClient]
(
	@ClientID int
)
AS
	SET NOCOUNT ON;
	
SELECT CP.ClientProductsID, ProductCode, ProductName, BaseCost, p.BaseCommission, CP.IncludeOnInvoice, 
Employment, Tenant, Business, Volunteer, Other, V.VendorName, case CP.ImportsAtBaseOrSales when 0 then 1 else 0 end as ImportsAtBaseOrSales, CP.SalesPrice, v.VendorID
FROM Products P
INNER JOIN ClientProducts CP
	ON P.ProductID=CP.ProductID
INNER JOIN VendorProducts VP
	ON VP.ProductID=P.ProductID
INNER JOIN ClientVendors cv 
	ON cv.ClientID = CP.ClientID and cv.VendorID = VP.VendorID
INNER JOIN Vendors V 
	ON V.VendorID = cv.VendorID
WHERE CP.ClientID=@ClientID
ORDER BY ProductName
GO
