/****** Object:  StoredProcedure [dbo].[S1_Clients_AttachPaymentToInvoice]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Clients_AttachPaymentToInvoice]
@ClientID int,
@InvoiceID int,
@PaymentID int,
@PaymentDate datetime,
@PaymentQB varchar(50),
@AmountReceived money,
@ManualEntry bit = null,
@ManualUserID int = null
AS
BEGIN

if exists(select i.InvoiceID
            from Invoices i
		    where i.ClientID = @ClientID and
			      i.InvoiceID = @InvoiceID)
begin
;with dataToInsert as (
select distinct
       @InvoiceID as InvoiceID,
       @PaymentID as PaymentID,
       @PaymentQB as QBTransactionID,
       @AmountReceived as Amount,
	   @ManualEntry as ManualEntry,
       @ManualUserID as ManualUserID
  from Payments p
       inner join BillingContacts bc on bc.BillingContactID = p.BillingContactID
  where bc.ClientID = @ClientID and
        p.PaymentID = @PaymentID and
		p.[Date] = @PaymentDate)
insert into InvoicePayments(PaymentID, InvoiceID, QBTransactionID, Amount, ManualEntry, ManualUserID)
select dti.PaymentID,
       dti.InvoiceID,
	   dti.QBTransactionID,
	   dti.Amount,
	   dti.ManualEntry,
	   dti.ManualUserID
  from dataToInsert dti
  where not exists(select ip.InvoicePaymentID
                     from InvoicePayments ip
					 where ip.InvoiceID = dti.InvoiceID and
					       ip.PaymentID = dti.PaymentID)
end

;select ip.*
  from InvoicePayments ip
  where ip.InvoiceID = @InvoiceID and
        ip.PaymentID = @PaymentID 
				 
END


GO
