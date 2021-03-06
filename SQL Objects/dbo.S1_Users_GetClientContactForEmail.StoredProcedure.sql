/****** Object:  StoredProcedure [dbo].[S1_Users_GetClientContactForEmail]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[S1_Users_GetClientContactForEmail]
(
	@userid int
)
AS
	SET NOCOUNT ON;
	
SELECT distinct
u.UserID as UserID,
au.UserName as UserName,
am.LoweredEmail as Email,
max(cc.ContactFirstName) as ContactFirstName,
max(cc.contactlastname) as ContactLastName,
max(C.ClientName) as ClientName,
MAX(CC.ContactZIP) as ContactZipCode,
MAX(cc.ContactStateCode) as ContactState
FROM BillingContacts BC
INNER JOIN ClientContacts CC ON BC.ClientContactID=CC.ClientContactID
INNER JOIN Users u on u.UserID = CC.UserID
INNER JOIN aspnet_Membership am on am.UserId = u.UserGUID
INNER JOIN aspnet_Users au on au.UserId = am.UserID
INNER JOIN Clients C on C.ClientID = CC.ClientID
where u.UserID = @userid
GROUP BY u.UserID, au.username, LoweredEmail, UserFirstName, UserLastName 


GO
