/****** Object:  StoredProcedure [dbo].[GetMessageTemplate]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--EXEC GetMessageTemplate 21, 'Forgot Password'

CREATE PROCEDURE [dbo].[GetMessageTemplate]
(
	@ClientID int,
	@MessageName varchar(50)
)
AS
SET NOCOUNT ON;
Begin

	
	SELECT MessageText 
	FROM MessageTemplates
	WHERE ClientID = @ClientID
	  AND MessageName = @MessageName

	
End







GO
