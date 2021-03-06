/****** Object:  StoredProcedure [dbo].[S1_Clients_PaymentToInvoiceSearchByDate]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Clients_PaymentToInvoiceSearchByDate]
@ClientID int,
@Date varchar(4000)
AS
BEGIN

--execute S1_Clients_PaymentToInvoiceSearchByDate 2827, '02/'

;select distinct
        top 10 p.*, 
		       case
		         when ISDATE(@Date) = 1 and 
				      p.[Date] = convert(datetime, @Date) then 9999
		         when convert(varchar(4000),p.[Date],101) like @Date + '%' then 9998
		         when convert(varchar(4000),p.[Date],101) like '%' + @Date then 9997
		         when convert(varchar(4000),p.[Date],101) like '%' + @Date + '%' then 9996
		         else 1
		       end as RankNumber,
		rtrim(coalesce(cc.ContactFirstName,'') + ' ' + coalesce(cc.ContactLastName,'')) as ContactName
  from Payments p
       inner join BillingContacts bc on bc.BillingContactID = p.BillingContactID
	   left join ClientContacts cc on cc.ClientContactID = bc.ClientContactID
  where bc.ClientID = @ClientID and
        case
		  when ISDATE(@Date) = 1 and 
			   p.[Date] = convert(datetime, @Date) then 9999
		  when convert(varchar(4000),p.[Date],101) like @Date + '%' then 9998
		  when convert(varchar(4000),p.[Date],101) like '%' + @Date then 9997
		  when convert(varchar(4000),p.[Date],101) like '%' + @Date + '%' then 9996
		  else 1
		end >= 1
  order by case
		     when ISDATE(@Date) = 1 and 
				  p.[Date] = convert(datetime, @Date) then 9999
		     when convert(varchar(4000),p.[Date],101) like @Date + '%' then 9998
		     when convert(varchar(4000),p.[Date],101) like '%' + @Date then 9997
		     when convert(varchar(4000),p.[Date],101) like '%' + @Date + '%' then 9996
		     else 1
		   end desc,
		   p.[Date] desc,
		   p.PaymentID desc
				 
END


GO
