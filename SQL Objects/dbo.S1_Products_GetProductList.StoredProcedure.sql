/****** Object:  StoredProcedure [dbo].[S1_Products_GetProductList]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC S1_Products_GetProductList

CREATE PROCEDURE [dbo].[S1_Products_GetProductList]
AS
	SET NOCOUNT ON;
	
SELECT ProductID, ProductCode, ProductName, BaseCost, BaseCommission, IncludeOnInvoice, 
Employment, Tenant, Business, Volunteer, Other
FROM Products
ORDER BY ProductName
GO
