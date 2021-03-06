/****** Object:  StoredProcedure [dbo].[S1_BillingImport_UploadeDrugData]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[S1_BillingImport_UploadeDrugData]
(
	@ImportBatchID int, 
	@CustomerName varchar(max),
	@CustomerNumber varchar(max),
	@InvoiceNumber varchar(max),
	@LocationCode varchar(max),
	@ServiceDate datetime, 
	@Product varchar(max),
	@Fee money,
	@SSN varchar(max),
	@EmployeeName varchar(max),
	@COCNumber varchar(max),
	@SpecimenID varchar(max),
	@Reason varchar(max),
	@Comments varchar(max)

)
AS
SET NOCOUNT ON;
Begin

	Declare @errorcode int
			
	Set @errorcode = 0
	
	
	BEGIN TRANSACTION

    INSERT INTO eDrugImport 
		(ImportBatchID, CustomerNumber, CustomerName, InvoiceNumber, LocationCode, ServiceDate, Product, Fee,
		SSN, EmployeeName, COCNumber, SpecimenID, Reason, Comments)
    VALUES (@ImportBatchID, @CustomerNumber, @CustomerName, @InvoiceNumber, @LocationCode, @ServiceDate, @Product, @Fee,
		@SSN, @EmployeeName, @COCNumber, @SpecimenID, @Reason, @Comments)

	
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
