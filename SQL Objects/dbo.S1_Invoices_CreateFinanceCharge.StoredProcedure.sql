/****** Object:  StoredProcedure [dbo].[S1_Invoices_CreateFinanceCharge]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC S1_Invoices_CreateFinanceCharge '9/15/2010', 0, 0

CREATE PROCEDURE [dbo].[S1_Invoices_CreateFinanceCharge]
(
	@FinanceChargeDate datetime,
	@InvoiceID int,
	@CreateInvoicesBatchID int
)
AS
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	
	DECLARE @InvoiceNumber varchar(50)
	DECLARE @InvoiceNumberPrefix varchar(9)
	DECLARE @CountOfNextInvoiceNumber int
	DECLARE @BillingContactID int

BEGIN TRY
	BEGIN TRANSACTION -- Start the transaction..
	
	SELECT @InvoiceNumberPrefix = LEFT(I.InvoiceNumber,9),
	@BillingContactID = IBC.BillingContactID
	FROM Invoices I INNER JOIN InvoiceBillingContacts IBC
		ON I.InvoiceID=IBC.InvoiceID
		AND IBC.IsPrimaryBillingContact=1
	WHERE I.InvoiceID=@InvoiceID 

	SELECT @CountOfNextInvoiceNumber = COUNT(*) FROM Invoices 
	WHERE LEFT(InvoiceNumber,10)=@InvoiceNumberPrefix + 'F'
	
	IF (@CountOfNextInvoiceNumber IS NULL)
	BEGIN
		SET @CountOfNextInvoiceNumber = 0
	END
	
	IF (@CountOfNextInvoiceNumber > 8)
	BEGIN
		SELECT @InvoiceNumberPrefix = RIGHT(CONVERT(varchar,YEAR(@FinanceChargeDate)),2) + RIGHT('0' + CONVERT(varchar, MONTH(@FinanceChargeDate)),2)

		SELECT @CountOfNextInvoiceNumber = COUNT(*) FROM NextInvoiceNumber 
		WHERE InvoiceNumberPrefix=@InvoiceNumberPrefix

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

		SELECT @InvoiceNumber = @InvoiceNumberPrefix + RIGHT('0000' + CONVERT(varchar, @NextInvoiceNumber), 5) + 'F'
		
		UPDATE NextInvoiceNumber
		SET NextInvoiceNumber=NextInvoiceNumber+1
		WHERE InvoiceNumberPrefix=@InvoiceNumberPrefix
	END
	ELSE
	BEGIN
		SELECT @CountOfNextInvoiceNumber = @CountOfNextInvoiceNumber + 1
		SELECT @InvoiceNumber = @InvoiceNumberPrefix + 'F' + CONVERT(varchar, @CountOfNextInvoiceNumber)
	END
	
INSERT INTO Invoices (ClientID, InvoiceTypeID, InvoiceNumber, InvoiceDate, Amount, NumberOfColumns, Col1Header, Col2Header,
CreateInvoicesBatchID, BillTo, POName, PONumber, BillingReportGroupID, InvoiceExported, InvoiceExportedOn, DueText, 
RelatedInvoiceID, Released)
SELECT A1.ClientID, 2, @InvoiceNumber, @FinanceChargeDate, 
CASE WHEN ROUND((A1.OriginalInvoiceAmount - A1.CreditAmount - SUM(ISNULL(B1.PaymentsAmount,0))) * A1.FinanceChargePercent,2) < 1 THEN
1
ELSE
ROUND((A1.OriginalInvoiceAmount - A1.CreditAmount - SUM(ISNULL(B1.PaymentsAmount,0))) * A1.FinanceChargePercent,2)
END
, 
2 as NumberOfColumns, 'Type', 'Description', @CreateInvoicesBatchID, A1.BillTo, A1.POName, A1.PONumber,
0 as BillingReportGroupID, 0 as InvoiceExported, NULL as InvoiceExportedOn, A1.DueText, A1.InvoiceID,
	(CASE	WHEN A1.DeliveryMethod = 0 THEN 1
			WHEN A1.DeliveryMethod = 1 THEN 1
			WHEN A1.DeliveryMethod = 2 THEN 2
			WHEN A1.DeliveryMethod = 3 THEN 3
	END) as Released
FROM
(
SELECT I.InvoiceID, I.InvoiceNumber as InvoiceNumber, C.ClientID, C.ClientName, I.InvoiceDate, 
I.Amount as OriginalInvoiceAmount, 
SUM(ISNULL(I2.Amount,0)) as CreditAmount,
CIS.FinanceChargePercent, BC.DeliveryMethod, I.BillTo, I.POName, I.PONumber, I.DueText
FROM Invoices I 
INNER JOIN InvoiceBillingContacts IBC
	ON IBC.InvoiceID=I.InvoiceID
	AND IBC.IsPrimaryBillingContact=1
INNER JOIN BillingContacts BC
	ON BC.BillingContactID=IBC.BillingContactID
INNER JOIN Clients C 
	ON I.ClientID=C.ClientID
INNER JOIN ClientInvoiceSettings CIS
	ON I.ClientID=CIS.ClientID
LEFT JOIN Invoices I2
	ON I2.RelatedInvoiceID=I.InvoiceID
	AND I2.InvoiceTypeID=3
	--AND I2.Amount < I.Amount
WHERE I.InvoiceID=@InvoiceID
AND I.InvoiceTypeID=1 --Only pull invoices
AND I.VoidedOn IS NULL
AND I.Amount>0
AND CIS.ApplyFinanceCharge=1
AND CIS.SentToCollections=0
AND I.InvoiceDate<=DateAdd(day,0 - CIS.FinanceChargeDays,@FinanceChargeDate)
AND I.InvoiceDate>DateAdd(day,(0 - CIS.FinanceChargeDays) - 90,@FinanceChargeDate)
GROUP BY I.InvoiceID, I.InvoiceNumber, C.ClientID, C.ClientName, I.InvoiceDate, 
I.Amount, CIS.FinanceChargePercent, BC.DeliveryMethod, I.BillTo, I.POName, I.PONumber, I.DueText
) A1
LEFT JOIN 
	(SELECT IP2.InvoiceID, IP2.Amount as PaymentsAmount, P2.[Date] 
		FROM InvoicePayments IP2
		INNER JOIN Payments P2 
			ON P2.PaymentID=IP2.PaymentID 
		WHERE [Date] <= @FinanceChargeDate --Only include payments made before or on the Finance Charge date 
	) B1
	ON B1.InvoiceID=A1.InvoiceID
GROUP BY A1.InvoiceID, A1.InvoiceNumber, A1.ClientID, A1.ClientName, A1.InvoiceDate, 
A1.OriginalInvoiceAmount, A1.CreditAmount, A1.FinanceChargePercent,
A1.BillTo, A1.POName, A1.PONumber, A1.DueText, A1.DeliveryMethod
HAVING A1.OriginalInvoiceAmount - A1.CreditAmount - SUM(ISNULL(B1.PaymentsAmount,0))>0

DECLARE @FCInvoiceID int
SELECT @FCInvoiceID=SCOPE_IDENTITY()

INSERT INTO InvoiceBillingContacts (InvoiceID, BillingContactID, IsPrimaryBillingContact) 
VALUES (@FCInvoiceID, @BillingContactID, 1)

INSERT INTO InvoiceLines (InvoiceID, InvoiceLineNumber, Col1Text, Col2Text, Col3Text, Col4Text, Col5Text, Col6Text, Col7Text, 
Col8Text, Amount)
SELECT @FCInvoiceID, 1, 'FINANCE CHARGE', 'For Overdue Balance on Invoice: ' + i2.InvoiceNumber + ' - $' + convert(varchar, i2.amount), 
'', '', '', '', '', '', i.Amount
FROM Invoices i 
INNER JOIN Invoices i2 
	ON i2.invoiceid  = i.RelatedInvoiceID
WHERE i.InvoiceID=@FCInvoiceID

	COMMIT TRAN -- Transaction Success!

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN --RollBack in case of Error
END CATCH

GO
