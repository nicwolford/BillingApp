/****** Object:  StoredProcedure [dbo].[S1_BillingImport_ClearTazworksImportTable]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[S1_BillingImport_ClearTazworksImportTable]
AS
SET NOCOUNT ON;
Begin

	Declare @errorcode int
			
	Set @errorcode = 0

	BEGIN TRANSACTION
	
	DELETE FROM TazworksImport
	DBCC CHECKIDENT('TazworksImport', RESEED, 0)
	
	DELETE FROM TazworksTempSearchList

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

	
Cleanup:

    BEGIN
    	ROLLBACK TRANSACTION
    END

    RETURN @errorcode
	
End







GO
