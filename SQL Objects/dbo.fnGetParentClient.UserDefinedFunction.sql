/****** Object:  UserDefinedFunction [dbo].[fnGetParentClient]    Script Date: 11/21/2016 9:44:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--SELECT * FROM fnGetParentClient(159)

CREATE FUNCTION [dbo].[fnGetParentClient](
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

WITH AllSubClients(ClientID,ParentClientID,TreeLevel)
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
where TreeLevel = (select max(treelevel) from AllSubClients)

RETURN

END



GO
