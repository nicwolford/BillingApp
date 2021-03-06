/****** Object:  StoredProcedure [dbo].[S1_MassCreateUsers_GetClientContacts]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[S1_MassCreateUsers_GetClientContacts]
AS
	SET NOCOUNT ON;
	
SELECT 
CC.ClientContactID as ClientContactID,
CC.ContactStatus as ClientContactStatus,
ISNULL(CC.ContactFirstName, '') as ClientContactFirstName,
ISNULL(CC.ContactLastName,C.ClientName) as ClientContactLastName,
CC.ContactAddr1 as ClientContactAddress1,
CC.ContactAddr2 as ClientContactAddress2,
CC.ContactCity as ClientContactCity,
CC.ContactStateCode as ClientContactState,
CC.ContactZIP as ClientContactZIP,
CC.ContactBusinessPhone as ClientContactBusinessPhone,
CC.ContactCellPhone as ClientContactCellPhone,
CC.ContactFax as ClientContactFax,
CC.ContactEmail as ClientContactEmail,
ISNULL(BC.IsPrimaryBillingContact,0) as IsPrimaryBillingContact,
BC.DeliveryMethod,
CC.ClientID,
C.ClientName
FROM BillingContacts BC
INNER JOIN ClientContacts CC
	ON BC.ClientContactID=CC.ClientContactID
INNER JOIN Clients C on C.ClientID = CC.ClientID
where (CC.UserID is null
  or CC.UserID = 0
  or UserID not in (
  select Users.UserID from Users inner join aspnet_Users a on a.UserId = Users.UserGUID))
  --and CC.ContactStatus = 1

GO
