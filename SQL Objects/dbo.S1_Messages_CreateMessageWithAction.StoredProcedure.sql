/****** Object:  StoredProcedure [dbo].[S1_Messages_CreateMessageWithAction]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
DECLARE @outMessageID int
DECLARE @outMessageActionGUID uniqueidentifier
EXEC S1_Messages_CreateMessageWithAction 6, 'Test1', '', 2743, 1, 0, 3, null, GETDATE(), null, 'HTML', @outMessageID OUTPUT, @outMessageActionGUID OUTPUT
SELECT @outMessageID
SELECT @outMessageActionGUID
*/

CREATE PROCEDURE [dbo].[S1_Messages_CreateMessageWithAction]
(
	@messageactiontype int,
	@messagesubject varchar(255),
	@messagetext varchar(max),
	@messageto int,  
	@tocontacttype int, --1 = User, 2 = Client Contact
	@messagefrom int,
	@fromcontacttype int, --1 = User, 3 = Automated
	@messageactionpath varchar(100),
	@sentdate datetime = null,
	@receiveddate datetime = null,
	@bodyformat varchar(50) = null,
	@MessageID int OUTPUT,
	@MessageActionGUID uniqueidentifier OUTPUT
)
AS
SET NOCOUNT ON;
Begin

	Declare @errorcode int
			
	Set @messageactionguid = null
	Set @errorcode = 0

	Select @MessageActionGUID = NEWID()
	
	
	BEGIN TRANSACTION
	
	insert into dbo.Messages (MessageType, MessageSubject, MessageText, MessageTo, ToContactType, MessageFrom, FromContactType, SentDate, ReceivedDate, [Status], BodyFormat) 
	values (@messageactiontype, @messagesubject, @messagetext, @messageto, @tocontacttype, @messagefrom, @fromcontacttype, @sentdate, @receiveddate, 0, @bodyformat)
	
	select @MessageID = @@IDENTITY

	if(@@ERROR <> 0)
	Begin
		Set @errorcode = -1
		Goto Cleanup
	End
	Else
	Begin

		insert into dbo.MessageAction (MessageID, MessageActionGUID, MessageActionType, MessageActionPath) 
		values (@MessageID, @MessageActionGUID, @messageactiontype, @messageactionpath)
		
		if(@@ERROR <> 0)
		Begin
			set @errorcode = -1
			Goto Cleanup
		End	
		Else
		Begin
		
			COMMIT TRANSACTION
			
			Return @errorcode
		End
	End
	
Cleanup:

    BEGIN
    	ROLLBACK TRANSACTION
    END

    RETURN @errorcode
	
End







GO
