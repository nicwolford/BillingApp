/****** Object:  StoredProcedure [dbo].[S1_BillingStatement_GetBillingPackagePrintedFromGUID]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC S1_BillingStatement_GetBillingPackagePrintedFromGUID 

CREATE PROCEDURE [dbo].[S1_BillingStatement_GetBillingPackagePrintedFromGUID]
(
	@EmailGuid uniqueidentifier
)
AS
	SET NOCOUNT ON;

SELECT BillingPackagePrintedID, BillingContactID, PackageEndDate, PrintedOn, PrintedByUser, EmailGuid
FROM BillingPackagePrinted WHERE EmailGuid=@EmailGuid
GO
