/****** Object:  StoredProcedure [dbo].[S1_ProductTransactions_AddFinanceChargeProductTransactions]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--EXEC S1_ProductTransactions_AddFinanceChargeProductTransactions '02/29/2012','03/01/2012'

CREATE PROCEDURE [dbo].[S1_ProductTransactions_AddFinanceChargeProductTransactions]
(
	@FinanceChargeDate datetime,
	@RunDate datetime
)
AS
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRY
	BEGIN TRANSACTION -- Start the transaction..
	
		DECLARE @FinanceChargeAssessDate datetime
		
		Set @FinanceChargeAssessDate = 	DATEADD(DD, 30, DATEADD(MONTH, DATEDIFF(MONTH, 0, @RunDate)-1, 0))

		DECLARE @tmp_UnbalancedOverPaymentList TABLE
		(
			ClientID int,
			[Type] varchar(20)
		)
		
		INSERT INTO @tmp_UnbalancedOverPaymentList 
		EXEC S1_Invoices_GetClientsOnOverpaymentUnbalancedList
		
		
		DECLARE @tmp_FinanceChargeInvoices TABLE
		(
			InvoiceID int, 
			InvoiceNumber varchar(50),
			ClientID int,
			ClientName varchar(100),
			InvoiceDate datetime,
			OriginalInvoiceAmount money,
			InvoiceAmountDue money,
			CreditAmount money,
			PaymentAmount money,
			FinanceChargeAmount money
		)
		
		INSERT INTO @tmp_FinanceChargeInvoices
		EXEC S1_Invoices_GetInvoicesToCreateFinanceChargeTransactionsFor @FinanceChargeAssessDate
		
		DECLARE @ProductID int = 372
		DECLARE @VendorID int = 6
		DECLARE @TransactionDate datetime = @FinanceChargeDate
		DECLARE @DateOrdered datetime  = @RunDate
		DECLARE @OrderBy varchar(50) = NULL
		DECLARE @FileNum varchar(50)
		DECLARE @FName varchar(50) = NULL
		DECLARE @LName varchar(50) = NULL
		DECLARE @MName varchar(50) = NULL
		DECLARE @SSN varchar(50) = NULL
		DECLARE @ProductType varchar(50) = NULL
		
	
		DECLARE @ClientID int
		DECLARE @Reference varchar(50) -- id of the invoice that created the FC
		DECLARE @ProductDescription varchar(max)
		DECLARE @ProductPrice money -- the amount of the FC
		
		----User for testing same qry that the cursor uses
		--SELECT FC.ClientID,FC.InvoiceID,
		--'ProductDescription' = 'For Overdue Balance on Invoice: ' + FC.InvoiceNumber + ' - $' + convert(varchar, FC.OriginalInvoiceAmount),
		--FC.FinanceChargeAmount,'FileNum' = FC.InvoiceID
		--FROM @tmp_FinanceChargeInvoices FC
		--LEFT OUTER JOIN @tmp_UnbalancedOverPaymentList UO
		--	ON FC.ClientID = UO.ClientID
		--WHERE UO.ClientID IS NULL
		
		
		--Get all finance charges except for those clients who are on the unbalanced and/or overpayment list
		DECLARE curFinCharges CURSOR for
		SELECT FC.ClientID,'Invoice: ' + FC.InvoiceNumber,
		'ProductDescription' = 'For Overdue Balance on Invoice: ' + FC.InvoiceNumber + ' - $' + convert(varchar, FC.OriginalInvoiceAmount),
		FC.FinanceChargeAmount,'FileNum' = FC.InvoiceNumber
		FROM @tmp_FinanceChargeInvoices FC
		LEFT OUTER JOIN @tmp_UnbalancedOverPaymentList UO
			ON FC.ClientID = UO.ClientID
		WHERE UO.ClientID IS NULL
		and fc.financechargeamount >= 5.00
				

		OPEN curFinCharges
		FETCH curFinCharges into @ClientID,@Reference,@ProductDescription,@ProductPrice,@FileNum

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
						 
			INSERT INTO ProductTransactions (ProductID, ClientID, VendorID, TransactionDate, 
				DateOrdered, OrderBy, Reference, FileNum, FName, LName, MName, SSN, ProductName, ProductDescription, 
				ProductType, ProductPrice)
			VALUES (@ProductID, @ClientID, @VendorID, @TransactionDate, @DateOrdered, @OrderBy, 
				@Reference, @FileNum, @FName, @LName, @MName, @SSN, 'Finance Charge', @ProductDescription, 'FEE',@ProductPrice)
		
			FETCH curFinCharges into @ClientID,@Reference,@ProductDescription,@ProductPrice,@FileNum

		END

	CLOSE curFinCharges
	DEALLOCATE curFinCharges

	COMMIT TRAN -- Transaction Success!

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		--SELECT 
  --      ERROR_NUMBER() AS ErrorNumber
  --      ,ERROR_MESSAGE() AS ErrorMessage;
		ROLLBACK TRAN --RollBack in case of Error
END CATCH


GO
