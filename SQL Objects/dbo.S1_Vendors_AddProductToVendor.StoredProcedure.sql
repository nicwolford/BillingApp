/****** Object:  StoredProcedure [dbo].[S1_Vendors_AddProductToVendor]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		overridepro
-- Description:	Add Product to Vendor
-- =============================================
CREATE PROCEDURE [dbo].[S1_Vendors_AddProductToVendor]
	-- Add the parameters for the stored procedure here
	@vendorID int, @productID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if not exists(SELECT * FROM VendorProducts WHERE VendorID=@vendorID AND ProductID=@productID)
	BEGIN
		INSERT INTO VendorProducts(VendorID, ProductID) VALUES(@vendorID, @productID)
	END
END

GO
