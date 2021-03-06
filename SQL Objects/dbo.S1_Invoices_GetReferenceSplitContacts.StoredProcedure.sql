/****** Object:  StoredProcedure [dbo].[S1_Invoices_GetReferenceSplitContacts]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***********************************************************************
Created By:		Rhonda Carey
Created On:		06/23/2011
Description:	Get a list of billing contacts for the reference split invoices

Modified By:
Modified On:
Descrition:

Test Script
DECLARE @ClientID int

SELECT @ClientID = 779

--EXEC S1_Invoices_GetReferenceSplitContacts @ClientID

**************************************************************************/

CREATE PROCEDURE [dbo].[S1_Invoices_GetReferenceSplitContacts]
	
	@ClientID int
	
AS
	SET NOCOUNT ON;

	SELECT ibc.InvoiceSplitID,bc.BillingContactID,bc.ContactName
	FROM BillingContacts bc
	INNER JOIN InvoiceSplitBillingContacts ibc
		ON bc.BillingContactID = ibc.BillingContactID
	WHERE bc.ClientID = @ClientID
	ORDER BY bc.ContactName


GO
