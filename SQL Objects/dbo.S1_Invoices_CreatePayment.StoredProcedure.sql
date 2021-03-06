/****** Object:  StoredProcedure [dbo].[S1_Invoices_CreatePayment]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Invoices_CreatePayment]
(
	@InvoiceDate datetime,
	@InvoiceAmount money,
	@BillingContactID int,
	@PaymentMethodID int,
	@CheckNumber varchar(50),
	@QBTransactionID varchar(50)
)
AS
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;


	
DECLARE @PaymentID int
SELECT @PaymentID=PaymentID FROM Payments WHERE QBTransactionID=@QBTransactionID

--Temporary fix for community options - 10/25/2010
--	IF (@BillingContactID NOT IN (select billingcontactid from BillingContacts where IsPrimaryBillingContact = 1 and ClientID in
--(select ClientID from Clients where ClientID = 1979 or ParentClientID = 1979)))
--	BEGIN

IF (@PaymentID IS NULL)
BEGIN

INSERT INTO Payments (BillingContactID, [Date], TotalAmount, PaymentMethodID, CheckNumber, 
QBTransactionID)
VALUES (@BillingContactID,@InvoiceDate,@InvoiceAmount,@PaymentMethodID,@CheckNumber,
@QBTransactionID)

SELECT CONVERT(int,SCOPE_IDENTITY()) as PaymentID

END
ELSE
BEGIN

BEGIN TRY
	
	
	BEGIN TRANSACTION -- Start the transaction..

	UPDATE Payments 
	SET BillingContactID=@BillingContactID,
	[Date]=@InvoiceDate, 
	TotalAmount=@InvoiceAmount,
	PaymentMethodID=@PaymentMethodID,
	CheckNumber=@CheckNumber
	WHERE PaymentID=@PaymentID

	DELETE FROM InvoicePayments WHERE PaymentID=@PaymentID and coalesce(ManualEntry,0) = 0

	COMMIT TRAN -- Transaction Success!
	
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN --RollBack in case of Error
END CATCH

SELECT @PaymentID as PaymentID

END

--END
--BEGIN

--SELECT 0 as PaymentID

--END


GO
