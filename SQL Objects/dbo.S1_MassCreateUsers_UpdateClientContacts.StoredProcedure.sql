/****** Object:  StoredProcedure [dbo].[S1_MassCreateUsers_UpdateClientContacts]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[S1_MassCreateUsers_UpdateClientContacts]
(
	@ClientContactID int,
	@UserID int
)
AS
	SET NOCOUNT ON;
	
UPDATE ClientContacts
SET UserID = @UserID
WHERE ClientContactID = @ClientContactID

UPDATE ClientContacts
SET ContactEmail = a.Email
FROM
(select am.Email, u.userid
from users u
inner join aspnet_users au on au.userid = u.userguid
inner join aspnet_membership am on am.userid = au.userid
where u.UserID = @UserID) a
WHERE a.UserID = ClientContacts.UserID

GO
