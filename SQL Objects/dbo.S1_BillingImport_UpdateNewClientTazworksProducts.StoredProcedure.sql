/****** Object:  StoredProcedure [dbo].[S1_BillingImport_UpdateNewClientTazworksProducts]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec S1_BillingImport_UpdateNewClientTazworksProducts

CREATE PROCEDURE [dbo].[S1_BillingImport_UpdateNewClientTazworksProducts]

AS
SET NOCOUNT ON;
		
Begin

DECLARE @clientid int,
		@productid int,
		@vendorid int

DECLARE clientproducts CURSOR 
FOR
SELECT distinct PT.ClientID, PT.ProductID, PT.VendorID
FROM ProductTransactions PT
INNER JOIN Clients C on C.ClientID = PT.ClientID
INNER JOIN Products P on P.ProductID = PT.ProductID
inner join VendorProducts vp on vp.productid = p.productid and vp.vendorid in (1, 2)
WHERE PT.ProductID not in (select CP.ProductID from ClientProducts CP where CP.ClientID = PT.ClientID)
  AND C.DoNotInvoice = 0
  AND PT.VendorID in (1,2)

OPEN clientproducts
Fetch clientproducts into @clientid, @productid, @vendorid

While (@@FETCH_STATUS = 0)
BEGIN

	Exec S1_Products_InsertClientProduct @clientid, @productid, @vendorid

	Fetch clientproducts into @clientid, @productid, @vendorid
END

Close clientproducts
Deallocate clientproducts

End





GO
