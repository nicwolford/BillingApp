/****** Object:  StoredProcedure [dbo].[S1_Users_GetAllUsers]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--EXEC S1_Users_GetAllUsers 'Active' --'Active' 'Inactive' or 'All'

CREATE PROCEDURE [dbo].[S1_Users_GetAllUsers]
(
	@UserStatus varchar(20)
)
AS
	SET NOCOUNT ON;
	

SELECT u.UserID, 
		u.UserName, 
		rtrim(u.UserLastName) + ', ' + u.UserFirstName as ShortName,
		u.Status
FROM vw_S1_Users u
INNER JOIN ClientUsers cu on u.UserID = cu.UserID
WHERE u.Status = @UserStatus or @UserStatus = 'All'
GROUP BY u.UserID, 
		u.UserName, 
		u.UserFirstName, 
		u.UserLastName, 
		u.status
ORDER BY u.UserLastName, u.UserFirstName


GO
