/****** Object:  StoredProcedure [dbo].[S1_Invoices_CreateCredit]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Invoices_CreateCredit]
(
	@InvoiceDate datetime,
	@InvoiceAmount money,
	@PublicDescription varchar(100),
	@PrivateDescription varchar(100),
	@BillingContactID int,
	@RelatedInvoiceID int
)
AS
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

DECLARE @ClientID int
SELECT @ClientID=ClientID FROM BillingContacts WHERE BillingContactID=@BillingContactID

DECLARE @InvoiceNumber varchar(50)
DECLARE @CountOfNextInvoiceNumber int
DECLARE @InvoiceNumberPrefix varchar(20)

BEGIN TRY
	BEGIN TRANSACTION -- Start the transaction..

IF (@RelatedInvoiceID=0)
BEGIN

	SELECT @InvoiceNumberPrefix = RIGHT(CONVERT(varchar,YEAR(@InvoiceDate)),2) + RIGHT('0' + CONVERT(varchar, MONTH(@InvoiceDate)),2)

	SELECT @CountOfNextInvoiceNumber = COUNT(*) FROM NextInvoiceNumber WHERE InvoiceNumberPrefix=@InvoiceNumberPrefix

	DECLARE @NextInvoiceNumber int

	IF (@CountOfNextInvoiceNumber = 0)
	BEGIN
		INSERT INTO NextInvoiceNumber(InvoiceNumberPrefix, NextInvoiceNumber)
		VALUES (@InvoiceNumberPrefix, 1)
		SELECT @NextInvoiceNumber = 0 --The starting invoice is this number + 1
		--@InvoiceNumberPrefix + '00001'
	END
	ELSE
	BEGIN
		SELECT TOP 1 @NextInvoiceNumber = NextInvoiceNumber
		FROM NextInvoiceNumber
		WHERE InvoiceNumberPrefix=@InvoiceNumberPrefix
		
		--@InvoiceNumberPrefix + RIGHT('0000' + CONVERT(varchar,NextInvoiceNumber),5)
	END

	SELECT @InvoiceNumber = @InvoiceNumberPrefix + RIGHT('0000' + CONVERT(varchar, @NextInvoiceNumber), 5) + 'C'

	INSERT INTO Invoices (ClientID, InvoiceTypeID, InvoiceNumber, InvoiceDate, VoidedOn, VoidedByUser, 
	Amount, NumberOfColumns, Col1Header, Col2Header, Col3Header, Col4Header, Col5Header, Col6Header, 
	Col7Header, Col8Header, CreateInvoicesBatchID, BillTo, POName, PONumber, BillingReportGroupID, 
	InvoiceExported, InvoiceExportedOn, DueText, RelatedInvoiceID, Released) 
	VALUES (@ClientID,3,@InvoiceNumber, @InvoiceDate, NULL, NULL,
	@InvoiceAmount, 0, @PublicDescription, @PrivateDescription, '', '', '', '',
	'', '', 0, '', '', '', 0,
	0, NULL, '', NULL, 1)

	UPDATE NextInvoiceNumber
	SET NextInvoiceNumber=NextInvoiceNumber+1
	WHERE InvoiceNumberPrefix=@InvoiceNumberPrefix

END
ELSE
BEGIN

	SELECT @InvoiceNumberPrefix = LEFT(InvoiceNumber,9) FROM Invoices
	WHERE InvoiceID=@RelatedInvoiceID 

	SELECT @CountOfNextInvoiceNumber = COUNT(*) FROM Invoices 
	WHERE RelatedInvoiceID=@RelatedInvoiceID
	AND InvoiceTypeID=3 --Credits Only
	
	SELECT @CountOfNextInvoiceNumber = @CountOfNextInvoiceNumber + 1

	SELECT @InvoiceNumber = @InvoiceNumberPrefix + 'C' + CONVERT(varchar, @CountOfNextInvoiceNumber)

	INSERT INTO Invoices (ClientID, InvoiceTypeID, InvoiceNumber, InvoiceDate, VoidedOn, VoidedByUser, 
	Amount, NumberOfColumns, Col1Header, Col2Header, Col3Header, Col4Header, Col5Header, Col6Header, 
	Col7Header, Col8Header, CreateInvoicesBatchID, BillTo, POName, PONumber, BillingReportGroupID, 
	InvoiceExported, InvoiceExportedOn, DueText, RelatedInvoiceID, Released) 
	VALUES (@ClientID,3,@InvoiceNumber, @InvoiceDate, NULL, NULL,
	@InvoiceAmount, 0, @PublicDescription, @PrivateDescription, '', '', '', '',
	'', '', 0, '', '', '', 0,
	0, NULL, '', @RelatedInvoiceID, 1)

END

DECLARE @CreditInvoiceID int
SELECT @CreditInvoiceID=SCOPE_IDENTITY()

INSERT INTO InvoiceBillingContacts (InvoiceID, BillingContactID, IsPrimaryBillingContact) 
VALUES (@CreditInvoiceID, @BillingContactID, 1)

	COMMIT TRAN -- Transaction Success!

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN --RollBack in case of Error
END CATCH

GO
