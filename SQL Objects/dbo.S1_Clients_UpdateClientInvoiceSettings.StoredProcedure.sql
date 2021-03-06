/****** Object:  StoredProcedure [dbo].[S1_Clients_UpdateClientInvoiceSettings]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Clients_UpdateClientInvoiceSettings]
	@ClientID int,
	@InvoiceTemplateID int,
	@SplitByMode int,
	@ReportGroupID int,
	@HideSSN bit,
	@ApplyFinanceCharges bit,
	@FinChargeDays int,
	@FinChargePct decimal(4,3),
	@SentToCollections bit,
	@ExcludeFromReminders bit
AS
BEGIN

	SET NOCOUNT ON;
	
	UPDATE ClientInvoiceSettings
	SET InvoiceTemplateID=@InvoiceTemplateID,
	SplitByMode=@SplitByMode,
	ReportGroupID=@ReportGroupID,
	HideSSN=@HideSSN,
	ApplyFinanceCharge = @ApplyFinanceCharges,
	FinanceChargeDays = @FinChargeDays,
	FinanceChargePercent = @FinChargePct,
	SentToCollections = @SentToCollections,
	ExcludeFromReminders = @ExcludeFromReminders
	WHERE ClientID=@ClientID

END


GO
