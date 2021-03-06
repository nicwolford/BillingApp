/****** Object:  StoredProcedure [dbo].[S1_ClientContacts_FixIssuesBillingContact]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_ClientContacts_FixIssuesBillingContact]
@ClientID int
AS
BEGIN
    
	SET NOCOUNT ON;

	if not exists(select InvoiceSplitID from InvoiceSplit where ClientID = @clientid)
    BEGIN

	;insert into InvoiceBillingContacts (InvoiceID, BillingContactID, IsPrimaryBillingContact)		
	SELECT i.InvoiceID, bc.BillingContactID, bc.IsPrimaryBillingContact
	  FROM Invoices i
	       inner join BillingContacts bc on bc.ClientID = i.ClientID
  	  WHERE i.ClientID = @ClientID and
	        not exists(select ibc.InvoiceBillingContactID
			             from InvoiceBillingContacts ibc
						 where ibc.InvoiceID = i.InvoiceID and
						       ibc.BillingContactID = bc.BillingContactID)
	
	END

END

GO
