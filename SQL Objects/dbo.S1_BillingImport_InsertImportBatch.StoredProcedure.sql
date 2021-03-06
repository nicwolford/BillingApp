/****** Object:  StoredProcedure [dbo].[S1_BillingImport_InsertImportBatch]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec S1_BillingImport_InsertImportBatch 1, 'dtonkinadmin', 'testfile'

CREATE PROCEDURE [dbo].[S1_BillingImport_InsertImportBatch]
(
	@VendorID int, 
	@username varchar(50),
	@importfilename varchar(255)

)
AS
SET NOCOUNT ON;
BEGIN

	Declare @errorcode int,
			@importbatchid int
			
	Set @errorcode = 0
	

	BEGIN TRANSACTION

	INSERT INTO ImportBatch (ImportBatchUser, ImportBatchFileName, ImportBatchVendorID)
	VALUES (@username, @importfilename, @VendorID)

	if(@@ERROR <> 0)
	Begin
		set @errorcode = -1
		ROLLBACK TRANSACTION
	End	
	Else
	Begin
	
		COMMIT TRANSACTION
		Set @importbatchid = @@IDENTITY
		
	    if exists(select top 1 * 
				from ProductTransactions 
				where ImportBatchID in (
					select distinct importbatchid 
					from ImportBatch I 
					where I.ImportBatchFileName = 
						(select ImportBatchFileName from ImportBatch where ImportBatchID = @importbatchid))
		)
		BEGIN
			set @errorcode = -2
			Update ImportBatch set ImportSuccess = 0 where ImportBatchID = @importbatchid
		END
	END
		
	SELECT @importbatchid as ImportBatchID, @errorcode as ErrorCode
	
END






GO
