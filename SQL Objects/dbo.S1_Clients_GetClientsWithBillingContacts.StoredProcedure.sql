/****** Object:  StoredProcedure [dbo].[S1_Clients_GetClientsWithBillingContacts]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC S1_Clients_GetClientsWithBillingContacts 

CREATE PROCEDURE [dbo].[S1_Clients_GetClientsWithBillingContacts]

AS
	SET NOCOUNT ON;
	
SELECT DISTINCT C.ClientID,C.ClientName,C.Address1,C.Address2,c.City, c.[State], c.ZipCode, 
c.ParentClientID, ISNULL(C2.ClientName,'') as ParentClientName,
C.BillAsClientName,BG.BillingGroupID,BG.BillingGroupName,C.[Status]
FROM dbo.Clients C
INNER JOIN BillingGroups BG
	ON C.BillingGroup=BG.BillingGroupID
INNER JOIN ClientContacts CC
	ON C.ClientID=CC.ClientID
INNER JOIN BillingContacts BC
	ON BC.ClientContactID=CC.ClientContactID
LEFT JOIN Clients C2
	ON C2.ClientID=C.ParentClientID
WHERE C.BillAsClientName IS NOT NULL
ORDER BY C.ClientName

GO
