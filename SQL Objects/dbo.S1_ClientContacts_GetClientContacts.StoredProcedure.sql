/****** Object:  StoredProcedure [dbo].[S1_ClientContacts_GetClientContacts]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC S1_ClientContacts_GetClientContacts

CREATE PROCEDURE [dbo].[S1_ClientContacts_GetClientContacts]
AS
	SET NOCOUNT ON;
	
SELECT ISNULL(CC.ContactFirstName + ' ' + CC.ContactLastName,'[Accounts Payable]') as ClientContactName,
CC.ContactAddr1 as ClientContactAddress1,
CC.ContactAddr2 as ClientContactAddress2,
CC.ContactCity as ClientContactCity,
CC.ContactStateCode as ClientContactState,
CC.ContactZIP as ClientContactZIP,
CC.ContactBusinessPhone as ClientContactBusinessPhone,
CC.ContactCellPhone as ClientContactCellPhone,
CC.ContactFax as ClientContactFax,
CC.ContactEmail as ClientContactEmail,
ISNULL(BC.IsPrimaryBillingContact,0) as IsPrimaryBillingContact
FROM BillingContacts BC
LEFT JOIN ClientContacts CC
	ON BC.ClientContactID=CC.ClientContactID

GO
