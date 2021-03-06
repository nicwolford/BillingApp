/****** Object:  StoredProcedure [dbo].[S1_Clients_GetClientsFromUser]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC S1_Clients_GetClientsFromUser 63

CREATE PROCEDURE [dbo].[S1_Clients_GetClientsFromUser]
(
	@UserID int
)
AS
	SET NOCOUNT ON;
	
SELECT C.ClientID,C.ClientName,C.Address1,C.Address2,c.City, c.State, c.ZipCode, c.ParentClientID, CU.IsPrimaryClient
FROM dbo.ClientUsers CU
INNER JOIN dbo.Clients C
	ON CU.ClientID=C.ClientID
WHERE CU.UserID=@UserID
ORDER BY CU.IsPrimaryClient DESC, C.ClientName
GO
