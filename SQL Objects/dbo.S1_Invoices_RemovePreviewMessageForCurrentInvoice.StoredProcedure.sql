/****** Object:  StoredProcedure [dbo].[S1_Invoices_RemovePreviewMessageForCurrentInvoice]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Invoices_RemovePreviewMessageForCurrentInvoice]
@MessageGuid uniqueidentifier
AS
BEGIN

;delete from ReminderEmailCurrentRun where MessageGUID = @MessageGuid

END


GO
