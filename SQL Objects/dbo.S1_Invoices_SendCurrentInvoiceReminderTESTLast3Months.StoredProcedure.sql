/****** Object:  StoredProcedure [dbo].[S1_Invoices_SendCurrentInvoiceReminderTESTLast3Months]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[S1_Invoices_SendCurrentInvoiceReminderTESTLast3Months]
@FromUserId int,
@MessageSubject varchar(255),
@MessageText varchar(max)
AS
BEGIN

--Exec S1_Invoices_SendCurrentInvoiceReminderTESTLast3Months 2, 'Invoice Reminder', 
--'Good afternoon<br />
--<br />
--This is a reminder that the most recent invoice dated 11.01.2014 is available<br />
--for you to review online at <a href="https://www.screeningone.com">https://www.screeningone.com</a>. Your username will<br />
--always be the email address we have on file.<br />
--<br />
--If you require help with your login credentials or have not been set up to<br />
--use our billing website, please contact our billing department at<br />
--<a href="mailto:billing@screeningone.com?subject=ScreeningONE%20Billing%20Department&body=Your%20message%20here.">billing@screeningone.com</a><br />
--<br />
--Thank You<br />
--Sincerely<br />
--ScreeningONE Inc'

;declare @nPlease datetime,
         @nPleaseWOTime datetime,
         @InvoiceDate datetime,
         @InvoiceDateMinusOneMonth datetime,
         @InvoiceDateMinusTwoMonth datetime,
         @InvoiceDateMinusThreeMonth datetime

;declare @ToSendMessages as TABLE(
	[MessageGUID] uniqueidentifier,
	[MessageType] int,
	[MessageText] varchar(5000),
	[MessageTo] int,
	[ToContactType] int,
	[MessageFrom] int,
	[FromContactType] int,
	[SentDate] datetime,
	[ReceivedDate] datetime,
	[MessageSubject] varchar(255),
	[Status] tinyint,
	[BodyFormat] varchar(50),
	BadEmailAddress bit,
	ClientID int,
	ClientName varchar(100))

;select @nPlease = getdate()
;select @nPleaseWOTime = convert(datetime,convert(varchar(255),@nPlease,101),101)
;select @InvoiceDate = convert(datetime,cast(Month(@nPlease) as varchar(255)) + '/01/' + cast(Year(@nPlease) as varchar(255)))
;select @InvoiceDateMinusOneMonth = dateadd(m,-1,convert(datetime,cast(Month(@nPlease) as varchar(255)) + '/01/' + cast(Year(@nPlease) as varchar(255))))
;select @InvoiceDateMinusTwoMonth = dateadd(m,-2,convert(datetime,cast(Month(@nPlease) as varchar(255)) + '/01/' + cast(Year(@nPlease) as varchar(255))))
;select @InvoiceDateMinusThreeMonth = dateadd(m,-3,convert(datetime,cast(Month(@nPlease) as varchar(255)) + '/01/' + cast(Year(@nPlease) as varchar(255))))
			 
;with messagesToSend as (
select distinct 8 as MessageType,
	   @messagetext as MessageText,
	   u.UserID as MessageTo,
	   1 as ToContactType,
	   @FromUserId as MessageFrom,
	   1 as FromContactType,
	   @nPlease as SentDate,
	   null as ReceivedDate,
	   @MessageSubject as MessageSubject,
	   0 as [Status],
	   'HTML' as BodyFormat,
	   case when am.Email not like '%screeningone%' then 0 else 1 end as BadEmailAddress,
	   c.ClientID,
	   c.ClientName
  from Invoices i
       inner join InvoiceBillingContacts ibc on ibc.InvoiceID = i.InvoiceID
       inner join BillingContacts bc on bc.BillingContactID = ibc.BillingContactID /*and
	                                    bc.IsPrimaryBillingContact = 1*/
	   inner join ClientContacts cc on cc.ClientContactID = bc.ClientContactID
	   inner join Users u on u.UserID = cc.UserID
	   inner join aspnet_Membership am on am.UserId = u.UserGUID
	   inner join Clients c on c.ClientID = i.ClientID
  where i.InvoiceTypeID = 1 and
        i.VoidedOn is null and
		i.InvoiceDate in (@InvoiceDate,
		                  @InvoiceDateMinusOneMonth,
						  @InvoiceDateMinusTwoMonth,
						  @InvoiceDateMinusThreeMonth))
insert into @ToSendMessages(MessageGUID,MessageType,MessageText,
                             MessageTo,ToContactType,MessageFrom,
					         FromContactType,SentDate,ReceivedDate,
					         MessageSubject,[Status],BodyFormat,
							 BadEmailAddress,ClientID,ClientName)
select NEWID() as MessageGUID,
       mts.MessageType,
	   mts.MessageText,
	   mts.MessageTo,
	   mts.ToContactType,
	   mts.MessageFrom,
	   mts.FromContactType,
	   mts.SentDate,
	   mts.ReceivedDate,
	   mts.MessageSubject,
	   mts.[Status],
	   mts.BodyFormat,
	   mts.BadEmailAddress,
	   mts.ClientID,
	   mts.ClientName
  from messagesToSend mts

;select @InvoiceDate as IDate,
	    @InvoiceDateMinusOneMonth as IDateM1M,
	    @InvoiceDateMinusTwoMonth as IDateM2M,
	    @InvoiceDateMinusThreeMonth as IDateM3M

;select tsm.MessageGUID,
       tsm.MessageType,
	   tsm.MessageText,
	   tsm.MessageTo,
	   tsm.ToContactType,
	   tsm.MessageFrom,
	   tsm.FromContactType,
	   tsm.SentDate,
	   tsm.ReceivedDate,
	   tsm.MessageSubject,
	   tsm.[Status],
	   tsm.BodyFormat,
	   tsm.BadEmailAddress,
	   tsm.ClientID,
	   tsm.ClientName
  from @ToSendMessages tsm

END



GO
