/****** Object:  StoredProcedure [dbo].[S1_Messages_GetMessageTemplateReservedWordList]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--EXEC GetMessageTemplateReservedWordList 'Change Password'

CREATE PROCEDURE [dbo].[S1_Messages_GetMessageTemplateReservedWordList]
(
	@MessageTemplateName varchar(50)
)
AS
SET NOCOUNT ON;
Begin
	
	SELECT  mr.ReservedWord, mr.ReservedWordDisplay
	FROM MessageReservedWords mr
	INNER JOIN MessageTemplateReservedWords mtr on mr.MessageReservedWordID = mtr.MessageReservedWordID
	INNER JOIN MessageTemplates mt on mtr.MessageTemplateID = mt.MessageTemplateID
	WHERE mt.MessageName = @MessageTemplateName
	  AND mr.ShowInList = 1
	ORDER BY mr.ReservedWordDisplay
	
End





GO
