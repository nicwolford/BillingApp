/****** Object:  StoredProcedure [dbo].[S1_Clients_RemovePaymentFromInvoice]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Clients_RemovePaymentFromInvoice]
@PaymentID int,
@InvoiceID int
AS
BEGIN

;delete from InvoicePayments
   where InvoiceID = @InvoiceID and
         PaymentID = @PaymentID
				 
END


GO
