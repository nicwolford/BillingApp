/****** Object:  StoredProcedure [dbo].[S1_Clients_GetClient]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC S1_Clients_GetClient 2

CREATE PROCEDURE [dbo].[S1_Clients_GetClient]
(
	@ClientID int
)
AS
	SET NOCOUNT ON;
	
SELECT ClientID, ParentClientID, ClientName, Address1, Address2, City, [State], ZipCode, DoNotInvoice, 
Status, BillAsClientName, ImportClientSplitMode, DueText, BillingGroup, (select c.ClientName from Clients c where c.ClientID = Clients.ParentClientID) as ParentClientName,
AuditInvoices, Notes
FROM Clients
WHERE ClientID=@ClientID


GO
