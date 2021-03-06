/****** Object:  StoredProcedure [dbo].[S1_BillingStatement_GetBillingActivity]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_BillingStatement_GetBillingActivity]
	@BillingContactID int,
	@UserID int
AS
BEGIN

--EXEC S1_BillingStatement_GetBillingActivity 2528, 0
--EXEC S1_BillingStatement_GetBillingActivity 458, 0
--EXEC S1_BillingStatement_GetBillingActivity 0, 21

SET NOCOUNT ON;
	
DECLARE @tmp_BillingContacts TABLE
(
	BillingContactID int
)
	
IF (@BillingContactID=0)
BEGIN
	INSERT INTO @tmp_BillingContacts (BillingContactID)
	SELECT BC.BillingContactID
	FROM BillingContacts BC
	INNER JOIN ClientContacts CC
		ON BC.ClientContactID=CC.ClientContactID
	WHERE CC.UserID=@UserID
END
ELSE
BEGIN
	INSERT INTO @tmp_BillingContacts (BillingContactID) VALUES (@BillingContactID)
END

--------------------------------------------------------------------------------------------------------------------------------------------
--Start allLineItems Query
--------------------------------------------------------------------------------------------------------------------------------------------
;with generalLineItems as (
SELECT I.InvoiceTypeID, 
       I.InvoiceID, 
	   I.RelatedInvoiceID, 
	   cast(null as int) as PaymentID, 
	   I.InvoiceDate as [Date], 
	   IT.InvoiceTypeDesc as [Type], 
	   I.InvoiceNumber, 
       (CASE 
	      WHEN I.InvoiceTypeID=3 THEN 0 - I.Amount 
		  ELSE I.Amount 
		END) as Amount,
       (CASE 
	      WHEN I.InvoiceDate>'7/31/2010' THEN (CASE 
		                                         WHEN I.InvoiceTypeID IN (3,5) THEN 0 
												 ELSE I.InvoiceID 
											   END)
          ELSE 0 
		END) as LinkID,
       I.Amount as RawAmount,
	   cast(case 
	          when I.RelatedInvoiceID is not null then 1
			  else 0
			end as bit) as HasInvoiceToInvoice
FROM Invoices I INNER JOIN InvoiceTypes IT ON I.InvoiceTypeID=IT.InvoiceTypeID
INNER JOIN InvoiceBillingContacts IBC 
	ON IBC.InvoiceID=I.InvoiceID
INNER JOIN BillingContacts BC 
	ON BC.BillingContactID=IBC.BillingContactID
WHERE BC.BillingContactID IN (SELECT BillingContactID FROM @tmp_BillingContacts) 
AND I.VoidedOn IS NULL AND I.InvoiceTypeID<>2
AND I.Released>0
AND BC.HideFromClient=0

UNION ALL

SELECT I.InvoiceTypeID, 
       I.InvoiceID, 
	   I.RelatedInvoiceID, 
	   cast(null as int) as PaymentID, 
	   I.InvoiceDate as [Date], 
	   IT.InvoiceTypeDesc as [Type], 
	   ISNULL(I.InvoiceNumber,''), 
	   I.Amount,
	   0 as LinkID,
       I.Amount as RawAmount,
	   cast(case 
	          when I.RelatedInvoiceID is not null then 1
			  else 0
			end as bit) as HasInvoiceToInvoice
FROM Invoices I 
INNER JOIN InvoiceTypes IT 
	ON I.InvoiceTypeID=IT.InvoiceTypeID
INNER JOIN InvoiceBillingContacts IBC 
	ON IBC.InvoiceID=I.InvoiceID
INNER JOIN BillingContacts BC 
	ON BC.BillingContactID=IBC.BillingContactID
LEFT JOIN Invoices I2
	ON I2.InvoiceID=I.RelatedInvoiceID
WHERE BC.BillingContactID IN (SELECT BillingContactID FROM @tmp_BillingContacts) 
AND I.VoidedOn IS NULL AND I.InvoiceTypeID=2
AND I.Released>0
AND BC.HideFromClient=0

UNION ALL

SELECT cast(null as int) as InvoiceTypeID, 
       cast(null as int) as InvoiceID, 
	   cast(null as int) as RelatedInvoiceID, 
	   P.PaymentID, 
	   P.[Date], 
	   'Payment' as [Type], 
	   '' as InvoiceNumber, 
	   0 - P.TotalAmount as Amount, 
	   0 as LinkID,
       P.TotalAmount as RawAmount,
	   cast(0 as bit) as HasInvoiceToInvoice
FROM Payments P
INNER JOIN BillingContacts BC ON BC.BillingContactID=P.BillingContactID
WHERE P.BillingContactID IN (SELECT BillingContactID FROM @tmp_BillingContacts) 
AND BC.HideFromClient=0),
allLineItems as (
select gli.InvoiceTypeID,
       gli.InvoiceID,
	   gli.RelatedInvoiceID,
	   gli.PaymentID,
	   gli.[Date],
	   gli.[Type],
	   gli.InvoiceNumber,
	   gli.Amount,
	   gli.LinkID,
	   gli.RawAmount,
	   case 
	     when gli.HasInvoiceToInvoice = 1 then gli.HasInvoiceToInvoice
	     when gli.HasInvoiceToInvoice = 0 then cast(coalesce((select top 1 1
	                                                            from generalLineItems chk
												                where chk.RelatedInvoiceID = gli.InvoiceID),0) as bit)
		 else cast(0 as bit)
	   end as HasInvoiceToInvoice
  from generalLineItems gli),
--------------------------------------------------------------------------------------------------------------------------------------------
--End allLineItems Query
--------------------------------------------------------------------------------------------------------------------------------------------

paymentsOnly as (
select ali.PaymentID,
	   (select left(i.Invoices,Len(i.Invoices)-1) as Invoices
          from (select (select '"' + coalesce(cast(ip.InvoiceID as varchar(8000)),'') + '",' AS [text()]
		                  from InvoicePayments ip
				          where ip.PaymentID = ali.PaymentID
                          order by ip.InvoicePaymentID
                          for xml path ('')) as Invoices) i) as InvoiceList,
	   (select left(id.InvoiceDates,Len(id.InvoiceDates)-1) as InvoiceDates
          from (select (select '"' + coalesce(convert(varchar(8000),i.InvoiceDate,101),'') + '",' AS [text()]
		                  from InvoicePayments ip
						       inner join Invoices i on i.InvoiceID = ip.InvoiceID
				          where ip.PaymentID = ali.PaymentID
                          order by ip.InvoicePaymentID
                          for xml path ('')) as InvoiceDates) id) as InvoiceDateList,
	   (select left(psa.PaymentSpentAmounts,Len(psa.PaymentSpentAmounts)-1) as PaymentSpentAmounts
          from (select (select '"' + coalesce(cast(ip.Amount as varchar(8000)),'') + '",' AS [text()]
		                  from InvoicePayments ip
				          where ip.PaymentID = ali.PaymentID
                          order by ip.InvoicePaymentID
                          for xml path ('')) as PaymentSpentAmounts) psa) as PaymentSpentAmountList,
	   (select left(iqbt.IQBTransactionIDs,Len(iqbt.IQBTransactionIDs)-1) as IQBTransactionIDs
          from (select (select '"' + cast(coalesce(i.QBTransactionID,'') as varchar(8000)) + '",' AS [text()]
		                  from InvoicePayments ip
						       inner join Invoices i on i.InvoiceID = ip.InvoiceID
				          where ip.PaymentID = ali.PaymentID
                          order by ip.InvoicePaymentID
                          for xml path ('')) as IQBTransactionIDs) iqbt) as IQBTransactionIDList,
	   (select left(ipqbt.IpQBTransactionIDs,Len(ipqbt.IpQBTransactionIDs)-1) as IpQBTransactionIDs
          from (select (select '"' + cast(coalesce(ip.QBTransactionID,'') as varchar(8000)) + '",' AS [text()]
		                  from InvoicePayments ip
				          where ip.PaymentID = ali.PaymentID
                          order by ip.InvoicePaymentID
                          for xml path ('')) as IpQBTransactionIDs) ipqbt) as PtiQBTransactionIDList,
	   (select left(ins.InvoiceNumbers,Len(ins.InvoiceNumbers)-1) as InvoiceNumbers
          from (select (select '"' + cast(coalesce(i.InvoiceNumber,'') as varchar(8000)) + '",' AS [text()]
		                  from InvoicePayments ip
						       inner join Invoices i on i.InvoiceID = ip.InvoiceID
				          where ip.PaymentID = ali.PaymentID
                          order by ip.InvoicePaymentID
                          for xml path ('')) as InvoiceNumbers) ins) as InvoiceNumberList
  from allLineItems ali
  where ali.PaymentID is not null
),
paymentsTotalAmountSpent as ( 
select po.PaymentID,
       sum(coalesce(ip.Amount,cast(0 as money))) as TotalAmountSpent
  from paymentsOnly po
       inner join InvoicePayments ip on ip.PaymentID = po.PaymentID
  group by po.PaymentID
),
invoicesOnly as (
select ali.InvoiceID,
	   (select left(p.Payments,Len(p.Payments)-1) as Payments
          from (select (select '"' + coalesce(cast(ip.PaymentID as varchar(8000)),'') + '",' AS [text()]
		                  from InvoicePayments ip
				          where ip.InvoiceID = ali.InvoiceID
                          order by ip.InvoicePaymentID
                          for xml path ('')) as Payments) p) as PaymentList,
	   (select left(pd.PaymentDates,Len(pd.PaymentDates)-1) as PaymentDates
          from (select (select '"' + coalesce(convert(varchar(8000),p.[Date],101),'') + '",' AS [text()]
		                  from InvoicePayments ip
						       inner join Payments p on p.PaymentID = ip.PaymentID
				          where ip.InvoiceID = ali.InvoiceID
                          order by ip.InvoicePaymentID
                          for xml path ('')) as PaymentDates) pd) as PaymentDateList,
	   (select left(paa.AmountsReceived,Len(paa.AmountsReceived)-1) as AmountsReceived
          from (select (select '"' + coalesce(cast(ip.Amount as varchar(8000)),'') + '",' AS [text()]
		                  from InvoicePayments ip
				          where ip.InvoiceID = ali.InvoiceID
                          order by ip.InvoicePaymentID
                          for xml path ('')) as AmountsReceived) paa) as AmountReceivedList,
	   (select left(pqbt.PQBTransactionIDs,Len(pqbt.PQBTransactionIDs)-1) as PQBTransactionIDs
          from (select (select '"' + cast(coalesce(p.QBTransactionID,'') as varchar(8000)) + '",' AS [text()]
		                  from InvoicePayments ip
						       inner join Payments p on p.PaymentID = ip.PaymentID
				          where ip.InvoiceID = ali.InvoiceID
                          order by ip.InvoicePaymentID
                          for xml path ('')) as PQBTransactionIDs) pqbt) as PQBTransactionIDList,
	   (select left(ipqbt.IpQBTransactionIDs,Len(ipqbt.IpQBTransactionIDs)-1) as IpQBTransactionIDs
          from (select (select '"' + cast(coalesce(ip.QBTransactionID,'') as varchar(8000)) + '",' AS [text()]
		                  from InvoicePayments ip
				          where ip.InvoiceID = ali.InvoiceID
                          order by ip.InvoicePaymentID
                          for xml path ('')) as IpQBTransactionIDs) ipqbt) as ItpQBTransactionIDList
  from allLineItems ali
  where ali.InvoiceID is not null
),
invoicesTotalAmountReceived as ( 
select ino.InvoiceID,
       sum(coalesce(ip.Amount,cast(0 as money))) as TotalAmountReceived
  from invoicesOnly ino
       inner join InvoicePayments ip on ip.InvoiceID = ino.InvoiceID
  group by ino.InvoiceID
)
select coalesce(po.InvoiceList,cast('' as text)) as InvoiceList,
       coalesce(po.InvoiceDateList,cast('' as text)) as InvoiceDateList,
	   coalesce(po.PaymentSpentAmountList,cast('' as text)) as PaymentSpentAmountList,
	   coalesce(po.IQBTransactionIDList,cast('' as text)) as IQBTransactionIDList,
	   coalesce(po.PtiQBTransactionIDList,cast('' as text)) as PtiQBTransactionIDList,
	   coalesce(po.InvoiceNumberList,cast('' as text)) as InvoiceNumberList,
       coalesce(ino.PaymentList,cast('' as text)) as PaymentList,
       coalesce(ino.AmountReceivedList,cast('' as text)) as AmountReceivedList,
       coalesce(ino.PaymentDateList,cast('' as text)) as PaymentDateList,
       coalesce(ino.PQBTransactionIDList,cast('' as text)) as PQBTransactionIDList,
       coalesce(ino.ItpQBTransactionIDList,cast('' as text)) as ItpQBTransactionIDList,
       coalesce(ptas.TotalAmountSpent,cast(0 as money)) as TotalAmountSpent,
       coalesce(itar.TotalAmountReceived,cast(0 as money)) as TotalAmountReceived,
       ali.*,
	   case
	     when ali.InvoiceTypeID = 3 and
	          ali.HasInvoiceToInvoice = 1 then ali.RawAmount
		 else cast(0 as money)
	   end as CreditSpent,
	   case
	     when ali.InvoiceTypeID != 3 and
	          ali.HasInvoiceToInvoice = 1 then coalesce((select sum(cr.RawAmount)
			                                               from allLineItems cr 
												           where cr.RelatedInvoiceID = ali.InvoiceID and
												           cr.InvoiceTypeID = 3),cast(0 as money))
		 else cast(0 as money)
	   end as CreditReceived
  from allLineItems ali
       left join paymentsTotalAmountSpent ptas on ptas.PaymentID = ali.PaymentID
	   left join paymentsOnly po on po.PaymentID = ali.PaymentID
       left join invoicesTotalAmountReceived itar on itar.InvoiceID = ali.InvoiceID
	   left join invoicesOnly ino on ino.InvoiceID = ali.InvoiceID
  order by ali.[Date] desc,
           ali.InvoiceNumber desc

END

GO
