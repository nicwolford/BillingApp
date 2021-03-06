/****** Object:  StoredProcedure [dbo].[S1_Clients_InvoiceToPaymentSearchByDate]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Clients_InvoiceToPaymentSearchByDate]
@ClientID int,
@Date varchar(4000)
AS
BEGIN

--execute S1_Clients_InvoiceToPaymentSearchByDate 2827, '02/'

;select top 10 i.*, 
		       case
		         when ISDATE(@Date) = 1 and 
				      i.InvoiceDate = convert(datetime, @Date) then 9999
		         when convert(varchar(4000),i.InvoiceDate,101) like @Date + '%' then 9998
		         when convert(varchar(4000),i.InvoiceDate,101) like '%' + @Date then 9997
		         when convert(varchar(4000),i.InvoiceDate,101) like '%' + @Date + '%' then 9996
		         else 1
		       end as RankNumber
  from Invoices i
  where i.ClientID = @ClientID and
        case
		  when ISDATE(@Date) = 1 and 
			   i.InvoiceDate = convert(datetime, @Date) then 9999
		  when convert(varchar(4000),i.InvoiceDate,101) like @Date + '%' then 9998
		  when convert(varchar(4000),i.InvoiceDate,101) like '%' + @Date then 9997
		  when convert(varchar(4000),i.InvoiceDate,101) like '%' + @Date + '%' then 9996
		  else 1
		end >= 1
  order by case
		     when ISDATE(@Date) = 1 and 
				  i.InvoiceDate = convert(datetime, @Date) then 9999
		     when convert(varchar(4000),i.InvoiceDate,101) like @Date + '%' then 9998
		     when convert(varchar(4000),i.InvoiceDate,101) like '%' + @Date then 9997
		     when convert(varchar(4000),i.InvoiceDate,101) like '%' + @Date + '%' then 9996
		     else 1
		   end desc,
		   i.InvoiceDate desc,
		   i.InvoiceID desc
				 
END


GO
