/****** Object:  StoredProcedure [dbo].[S1_Users_VerifyEmail]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





--EXEC S1_User_VerifyEmail '1B7240DC-27EB-47BB-8D23-FFF1D96C6B17'

CREATE PROCEDURE [dbo].[S1_Users_VerifyEmail]
(
	@confirmEmailGuid nvarchar(MAX)
)
AS
	SET NOCOUNT ON;
	
	
SELECT	a.UserName as UserName, ma.IsActive, ma.MessageActionPath
FROM MessageAction ma
inner join Messages m on ma.MessageID = m.MessageID
inner join Users u on m.MessageTo = u.UserID
inner join aspnet_Users a on u.UserGUID = a.UserId
WHERE ma.MessageActionGUID=@confirmEmailGuid
  and ma.MessageActionType = 1








GO
