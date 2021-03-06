/****** Object:  StoredProcedure [dbo].[S1_Products_GetProductListFromVendor]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec S1_Products_GetProductListFromVendor 1

CREATE PROCEDURE [dbo].[S1_Products_GetProductListFromVendor]
(
	@VendorID int
)
AS
	SET NOCOUNT ON;
	
SELECT P.ProductID, ProductName + '-' + ProductCode as ProductName
FROM Products P
INNER JOIN VendorProducts VP
	ON VP.ProductID=P.ProductID
WHERE VP.VendorID=@VendorID
ORDER BY ProductName
GO
