/****** Object:  StoredProcedure [dbo].[S1_BillingImport_GetImportAuditResults]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_BillingImport_GetImportAuditResults]
(
	@vendorid int
)
AS
SET NOCOUNT ON;
		
Begin

if (@vendorid = 1 or @vendorid = 2)
	BEGIN
	SELECT COUNT(importid) as TotalRecordCount, SUM(Price) as TotalPrice
	FROM TazworksImport
	END

if (@vendorid = 8)
	BEGIN
		SELECT COUNT(importid) as TotalRecordCount, SUM(Fee) as TotalPrice
		FROM eDrugImport
	END

if (@vendorid = 4)
	BEGIN
		SELECT COUNT(importid) as TotalRecordCount, SUM(NetPrice) as TotalPrice
		FROM TransUnionImport
	END
	
	
if (@vendorid = 5)
	BEGIN
		SELECT COUNT(importid) as TotalRecordCount, SUM(XPProductPrice) as TotalPrice
		FROM ExperianImport
	END
	
--if (@vendorid = 7)
--	BEGIN

--	END


End


GO
