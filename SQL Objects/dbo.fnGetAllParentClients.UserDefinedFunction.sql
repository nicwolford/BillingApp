/****** Object:  UserDefinedFunction [dbo].[fnGetAllParentClients]    Script Date: 11/21/2016 9:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnGetAllParentClients](
	@ClientID int
)
RETURNS
@ParentClient TABLE (
	ClientID int,
	ParentClientID int,
	TreeLevel int
)

AS
BEGIN

--SELECT * FROM fnGetAllParentClients(188)

;WITH AllSubClients(ClientID,ParentClientID,TreeLevel)
AS
(
	SELECT C.ClientID,C.ParentClientID,0 as TreeLevel 
	FROM dbo.Clients C
	WHERE C.ClientID = @ClientID
	
	UNION ALL
	
	SELECT C.ClientID,C.ParentClientID,TreeLevel+1
	FROM dbo.Clients C
	INNER JOIN AllSubClients A
		ON A.ParentClientID=C.ClientID
)

insert into @ParentClient(ClientID, ParentClientID, TreeLevel)
SELECT ClientID, ParentClientID, TreeLevel
FROM AllSubClients

RETURN

END


GO
