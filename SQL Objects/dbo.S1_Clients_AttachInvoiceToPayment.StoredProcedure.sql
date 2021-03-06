/****** Object:  StoredProcedure [dbo].[S1_Clients_AttachInvoiceToPayment]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Clients_AttachInvoiceToPayment]
@ClientID int,
@PaymentID int,
@InvoiceID int,
@InvoiceNumber varchar(50),
@InvoiceDate datetime,
@InvoiceQB varchar(50),
@PaymentSpent money,
@ManualEntry bit = null,
@ManualUserID int = null
AS
BEGIN

if exists(select p.PaymentID
            from BillingContacts bc
			     inner join Payments p on p.BillingContactID = bc.BillingContactID
		    where bc.ClientID = @ClientID and
			      p.PaymentID = @PaymentID)
begin
;with dataToInsert as (
select @PaymentID as PaymentID,
       @InvoiceID as InvoiceID,
       @InvoiceQB as QBTransactionID,
       @PaymentSpent as Amount,
	   @ManualEntry as ManualEntry,
       @ManualUserID as ManualUserID
  from Invoices i
  where i.ClientID = @ClientID and
        i.InvoiceID = @InvoiceID and
		i.InvoiceNumber = @InvoiceNumber and
		i.InvoiceDate = @InvoiceDate)
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
