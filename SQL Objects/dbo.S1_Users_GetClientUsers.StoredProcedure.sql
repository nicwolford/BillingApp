/****** Object:  StoredProcedure [dbo].[S1_Users_GetClientUsers]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--EXEC S1_Users_GetClientUsers 1

CREATE PROCEDURE [dbo].[S1_Users_GetClientUsers]
(
	@ClientID int
)
AS
	SET NOCOUNT ON;
	

SELECT u.UserID, 
		u.UserName, 
		rtrim(u.UserLastName) + ', ' + u.UserFirstName as ShortName,
		u.IsApproved,
		c.ClientID, 
		c.ClientName,
		u.Status
FROM vw_S1_Users u
INNER JOIN ClientUsers cu on u.UserID = cu.UserID
INNER JOIN Clients c on cu.ClientID = c.ClientID
WHERE c.ClientID = @ClientID
GROUP BY u.UserID, 
		u.UserName, 
		u.UserFirstName, 
		u.UserLastName, 
		u.IsApproved,
		c.ClientID, 
		c.ClientName, cu.IsPrimaryClient,
		u.status
ORDER BY u.UserLastName, u.UserFirstName


GO
