/****** Object:  StoredProcedure [dbo].[S1_Clients_RemovePayment]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Clients_RemovePayment]
@ClientID int,
@PaymentID int
AS
BEGIN
--Exec S1_Clients_RemovePayment 99999,3


if exists(select p.PaymentID
            from BillingContacts bc
			     inner join Payments p on p.BillingContactID = bc.BillingContactID
		    where bc.ClientID = @ClientID and
			      p.PaymentID = @PaymentID)
begin

;delete 
   from Payments
   where PaymentID = @PaymentID and
         not exists(select ip.InvoicePaymentID from InvoicePayments ip where ip.PaymentID = @PaymentID)

end


;select cast(case 
               when exists(select p.PaymentID
                             from BillingContacts bc
			                      inner join Payments p on p.BillingContactID = bc.BillingContactID
		                     where bc.ClientID = @ClientID and
			                       p.PaymentID = @PaymentID) then 0
		       else 1
	         end as bit) as success

				 
END


GO
