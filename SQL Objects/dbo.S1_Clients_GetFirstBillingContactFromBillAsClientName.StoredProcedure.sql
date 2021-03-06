/****** Object:  StoredProcedure [dbo].[S1_Clients_GetFirstBillingContactFromBillAsClientName]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC S1_Clients_GetFirstBillingContactFromBillAsClientName 'AUTOHAUS OF EDENS LLC'

CREATE PROCEDURE [dbo].[S1_Clients_GetFirstBillingContactFromBillAsClientName]
(
	@BillAsClientName varchar(100)
)
AS
	SET NOCOUNT ON;
	
SELECT TOP 1 * FROM BillingContacts BC 
INNER JOIN ClientContacts CC 
	ON BC.ClientContactID=CC.ClientContactID
INNER JOIN Clients C
	ON C.ClientID=CC.ClientID
WHERE C.BillAsClientName=@BillAsClientName
AND BC.IsPrimaryBillingContact=1
GO
