/****** Object:  StoredProcedure [dbo].[S1_Invoices_CreateInvoicePayment]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Invoices_CreateInvoicePayment]
(
	@PaymentID int,
	@ReferenceNumber varchar(50),
	@Amount money,
	@QBTransactionID varchar(50),
	@BillingContactID int
)
AS
BEGIN
--EXEC S1_Invoices_CreateInvoicePayment 1, '20100800019', 887.35, '1FABEA-1282742137'

	SET NOCOUNT ON;
	
DECLARE @InvoiceID int
SELECT TOP 1 @InvoiceID=I.InvoiceID 
FROM Invoices I
INNER JOIN InvoiceBillingContacts IBC
	ON I.InvoiceID=IBC.InvoiceID
WHERE I.InvoiceNumber=@ReferenceNumber AND IBC.BillingContactID=@BillingContactID

DECLARE @InvoicePaymentID int

--Temporary fix for community options - 10/25/2010
--		IF (@BillingContactID NOT IN (select billingcontactid from BillingContacts where IsPrimaryBillingContact = 1 and ClientID in
--(select ClientID from Clients where ClientID = 1979 or ParentClientID = 1979)))
--		BEGIN

IF (@InvoiceID IS NOT NULL)
BEGIN 

	SELECT @InvoicePaymentID=InvoicePaymentID
	FROM InvoicePayments WHERE QBTransactionID=@QBTransactionID AND PaymentID=@PaymentID

	IF (@InvoicePaymentID IS NULL)
	BEGIN

	INSERT INTO InvoicePayments (PaymentID, InvoiceID, QBTransactionID, Amount)
	VALUES (@PaymentID, @InvoiceID, @QBTransactionID, @Amount)

	SELECT CONVERT(int,SCOPE_IDENTITY()) as InvoicePaymentID

	END
	ELSE
	BEGIN
	
		

		UPDATE InvoicePayments 
		SET PaymentID=@PaymentID,
		InvoiceID=@InvoiceID,
		Amount = @Amount
		WHERE InvoicePaymentID=@InvoicePaymentID and coalesce(ManualEntry,0) = 0
		
		SELECT @InvoicePaymentID as InvoicePaymentID
		
	END

END
ELSE
BEGIN

SELECT CONVERT(int,-1) as InvoicePaymentID

END

/*END
ELSE
BEGIN

SELECT CONVERT(int,-1) as InvoicePaymentID

END*/

END


GO
