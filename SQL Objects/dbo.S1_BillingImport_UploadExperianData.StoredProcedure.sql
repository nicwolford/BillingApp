/****** Object:  StoredProcedure [dbo].[S1_BillingImport_UploadExperianData]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[S1_BillingImport_UploadExperianData]
(
	@ImportBatchID int,
	@XPRequesterNo varchar(5),
	@XPRecordType char(1),
	@XPMktPreamble varchar(4),
	@XPAccPreamble varchar(4),
	@XPSubcode varchar(7),
	@XPInquiryDate datetime,
	@XPInquiryTime varchar(6),
	@XPLastName varchar(255),
	@XPSecondLastName varchar(255),
	@XPFirstName varchar(255),
	@XPMiddleName varchar(255),
	@XPGenerationCode char(1),
	@XPStreetNumber varchar(10),
	@XPStreetName varchar(32),
	@XPStreetSuffix varchar(4),
	@XPCity varchar(32),
	@XPUnitID varchar(32),
	@XPState varchar(2),
	@XPZipCode varchar(9),
	@XPHitCode varchar(2),
	@XPSSN varchar(9),
	@XPOperatorID varchar(2),
	@XPDuplicateID char(1),
	@XPStatementID varchar(2),
	@XPInvoiceCodes varchar(3),
	@XPProductCode varchar(7),
	@XPProductPrice money,
	@XPMKeyWord varchar(20)

)
AS
SET NOCOUNT ON;
Begin

	Declare @errorcode int
			
	Set @errorcode = 0
	

	BEGIN TRANSACTION

	--Group Experian Credit - No Reports with the Experian Credits
	if (@XPProductCode = 'PPC0002')
	BEGIN
		set @XPProductCode = 'PPC0001'
	END
	
	--Group Demographic All - No Reports with the Demographic All
	if (@XPProductCode = '0000JA2')
	BEGIN
		set @XPProductCode = '0000JA1'
	END
	
	--Assign non-tazworks transactions to CheckPast client from the S1master finance code
	if (@XPSubcode = '1974158' and @XPMKeyWord not like 'Taz%' and @XPProductCode <> '136000M')
	BEGIN
		set @XPSubcode = '1974158A'
	END

	if (@XPProductCode <> '136000M' and @XPMKeyWord not like 'Taz%')
	BEGIN
    INSERT INTO ExperianImport 
		(ImportBatchID,XPRequesterNo,XPRecordType,XPMktPreamble,XPAccPreamble,XPSubcode,XPInquiryDate,XPInquiryTime,
XPLastName,XPSecondLastName,XPFirstName,XPMiddleName,XPGenerationCode,XPStreetNumber,
XPStreetName,XPStreetSuffix,XPCity,XPUnitID,XPState,XPZipCode,XPHitCode,XPSSN,XPOperatorID,
XPDuplicateID,XPStatementID,XPInvoiceCodes,XPProductCode,XPProductPrice,XPMKeyWord)
    VALUES (@ImportBatchID, @XPRequesterNo,@XPRecordType,@XPMktPreamble,@XPAccPreamble,@XPSubcode,@XPInquiryDate,@XPInquiryTime,
@XPLastName,@XPSecondLastName,@XPFirstName,@XPMiddleName,@XPGenerationCode,@XPStreetNumber,
@XPStreetName,@XPStreetSuffix,@XPCity,@XPUnitID,@XPState,@XPZipCode,@XPHitCode,@XPSSN,@XPOperatorID,
@XPDuplicateID,@XPStatementID,@XPInvoiceCodes,@XPProductCode,@XPProductPrice,@XPMKeyWord)
	END
	
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
