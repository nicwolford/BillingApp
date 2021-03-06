/****** Object:  StoredProcedure [dbo].[S1_Commissions_ClientsSearchByClientName]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Commissions_ClientsSearchByClientName]
@ClientName varchar(max)
AS
BEGIN

--execute S1_Commissions_ClientsSearchByClientName 'D'

;select top 10 c.ParentClientID as ParentBillingClientID,
               c.ClientID as BillingClientID,
               c.ClientName,
               c.Address1,
               c.Address2,
               c.City,
               c.[State],
               c.ZipCode,
               c.DoNotInvoice,
               c.GetsInvoiceDetail,
               c.[Status],
               c.BillAsClientName,
               c.ImportClientSplitMode,
               c.DueText,
               c.BillingGroup,
               c.BillingNotes,
               c.AuditInvoices,
               c.Notes,
			   cast(null as varchar(max)) as PackageName,
			   cast(null as decimal(19,2)) as PackageCommissionRate,
               (select cv.VendorClientNumber
                  from ClientVendors cv
                  where cv.VendorID = 2 and 
                        cv.ClientID = c.ClientID) as ClientID, 
		       case
		         when c.ClientName = @ClientName then 9999
		         when c.ClientName like @ClientName + '%' then 9998
		         when c.ClientName like '%' + @ClientName then 9997
		         when c.ClientName like '%' + @ClientName + '%' then 9996
		         else 1
		       end as RankNumber
  from Clients c
  where case
		  when c.ClientName = @ClientName then 9999
		  when c.ClientName like @ClientName + '%' then 9998
		  when c.ClientName like '%' + @ClientName then 9997
		  when c.ClientName like '%' + @ClientName + '%' then 9996
		  else 1
		end >= 1
  order by case
		     when c.ClientName = @ClientName then 9999
		     when c.ClientName like @ClientName + '%' then 9998
		     when c.ClientName like '%' + @ClientName then 9997
		     when c.ClientName like '%' + @ClientName + '%' then 9996
		     else 1
		   end desc,
		   c.ClientName asc,
		   c.ClientID desc
				 
END

GO
