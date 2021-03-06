/****** Object:  StoredProcedure [dbo].[S1_Users_ModifyUserName]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Users_ModifyUserName]
(
	@OldUserName nvarchar(256),
	@NewUserName nvarchar(256)
)
AS
SET NOCOUNT ON;

DECLARE @UserID as int
SELECT @UserID=U.UserID FROM aspnet_Users AU INNER JOIN Users U ON AU.UserID=U.UserGUID
WHERE LoweredUserName=@OldUserName

UPDATE ClientContacts SET ContactEmail = @NewUserName WHERE UserID=@UserID

UPDATE BillingContacts SET ContactEmail = @NewUserName WHERE ClientContactID IN 
(SELECT ClientContactID FROM ClientContacts WHERE UserID=@UserID)

UPDATE aspnet_Users SET UserName=@NewUserName, LoweredUserName=@NewUserName
WHERE LoweredUserName=@OldUserName

GO
