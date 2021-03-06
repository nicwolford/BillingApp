/****** Object:  StoredProcedure [dbo].[S1_BillingImport_FixImportError]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		overridepro
-- Description:	Get Import Error
-- =============================================
CREATE PROCEDURE [dbo].[S1_BillingImport_FixImportError]
	-- Add the parameters for the stored procedure here
	@ImportID int, @ProductName varchar(max), @ProductType varchar(max), @ItemCode varchar(max), 
	@productDesc varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    UPDATE TOP(1) TazworksImport SET ProductName=@ProductName, ProductType=@ProductType, ItemCode=@ItemCode, 
    ProductDesc=@productDesc WHERE ImportID=@ImportID
END

GO
