/****** Object:  StoredProcedure [dbo].[S1_MassCreateUsers_GetClientContactsEmail]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[S1_MassCreateUsers_GetClientContactsEmail]
AS
	SET NOCOUNT ON;
	
SELECT distinct
u.UserID as UserID,
au.UserName as UserName,
am.LoweredEmail as Email,
max(cc.ContactFirstName) as ContactFirstName,
max(cc.contactlastname) as ContactLastName,
max(C.ClientName) as ClientName,
MAX(CC.ContactZIP) as ContactZipCode,
MAX(cc.ContactStateCode) as ContactState
FROM BillingContacts BC
INNER JOIN ClientContacts CC ON BC.ClientContactID=CC.ClientContactID
INNER JOIN Users u on u.UserID = CC.UserID
INNER JOIN aspnet_Membership am on am.UserId = u.UserGUID
INNER JOIN aspnet_Users au on au.UserId = am.UserID
INNER JOIN Clients C on C.ClientID = CC.ClientID --and C.AuditInvoices <> 1
inner join InvoiceBillingContacts i on i.BillingContactID = BC.BillingContactID 
inner join Invoices iv on iv.InvoiceID = i.InvoiceID and iv.InvoiceDate >= '08/01/2010'
where  cc.contactstatus = 1
  and bc.DeliveryMethod in (0)
  and cc.UserID not in (select messageto from Messages)
  and am.LoweredEmail not like '%screeningone.com%'
  and c.DoNotInvoice = 0
  and am.IsApproved = 1
 GROUP BY u.UserID, au.username, LoweredEmail, UserFirstName, UserLastName
order by ClientName

GO
