/****** Object:  StoredProcedure [dbo].[S1_BillingImport_GetNewClientProducts]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec S1_BillingImport_GetNewClientProducts

CREATE PROCEDURE [dbo].[S1_BillingImport_GetNewClientProducts]

AS
SET NOCOUNT ON;
		
Begin

SELECT distinct PT.ClientID, C.ClientName, PT.ProductID, P.ProductName, P.ProductCode
FROM ProductTransactions PT
INNER JOIN Clients C on C.ClientID = PT.ClientID
INNER JOIN Products P on P.ProductID = PT.ProductID
WHERE PT.ProductID not in (select CP.ProductID from ClientProducts CP where CP.ClientID = PT.ClientID)
  and C.DoNotInvoice = 0



End





GO
