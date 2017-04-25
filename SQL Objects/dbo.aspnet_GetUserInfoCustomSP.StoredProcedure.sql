/****** Object:  StoredProcedure [dbo].[aspnet_GetUserInfoCustomSP]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[aspnet_GetUserInfoCustomSP]
@UserName nvarchar(256)
AS
BEGIN
       select am.IsApproved,
              am.IsLockedOut
        from aspnet_Users u
		     inner join aspnet_Membership am on am.UserId = u.UserId
        where  u.UserName = @UserName
END


GO
