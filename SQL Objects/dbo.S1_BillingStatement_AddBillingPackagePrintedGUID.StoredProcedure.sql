/****** Object:  StoredProcedure [dbo].[S1_BillingStatement_AddBillingPackagePrintedGUID]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC S1_BillingStatement_AddBillingPackagePrintedGUID 

CREATE PROCEDURE [dbo].[S1_BillingStatement_AddBillingPackagePrintedGUID]
(
	@BillingContactID int,
	@PackageEndDate datetime,
	@PrintedByUser int,
	@ActionGUID varchar(255)
)
AS
	SET NOCOUNT ON;
	
	INSERT INTO BillingPackagePrinted VALUES (@BillingContactID, @PackageEndDate, GETDATE(), @PrintedByUser, @ActionGUID)
GO
