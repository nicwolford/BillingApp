/****** Object:  StoredProcedure [dbo].[S1_Invoices_QBExportLinkCredits_GetCreditsToLink]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Invoices_QBExportLinkCredits_GetCreditsToLink]
AS
SET NOCOUNT ON;

SELECT C.BillAsClientName, I.QBTransactionID as CreditMemoTxnID, I2.QBTransactionID as InvoiceTxnID, I.Amount
FROM Invoices I INNER JOIN Invoices I2 ON I.RelatedInvoiceID=I2.InvoiceID
INNER JOIN Clients C ON C.ClientID=I.ClientID
WHERE i.invoicetypeid = 3
and I.InvoiceID IN (SELECT CreditInvoiceID FROM QBExportLinkCredits WHERE Linked=0)
and I.InvoiceDate >= '03/01/2015'

/*
UPDATE QBLC 
SET Linked=1 
FROM QBExportLinkCredits QBLC INNER JOIN Invoices I ON I.InvoiceID=QBLC.CreditInvoiceID
WHERE Linked=0 AND I.RelatedInvoiceID IS NOT NULL
*/
GO
