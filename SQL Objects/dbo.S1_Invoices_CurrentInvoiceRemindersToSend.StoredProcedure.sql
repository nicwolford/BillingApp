/****** Object:  StoredProcedure [dbo].[S1_Invoices_CurrentInvoiceRemindersToSend]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Invoices_CurrentInvoiceRemindersToSend]
AS
BEGIN

--Exec S1_Invoices_CurrentInvoiceRemindersToSend

select recr.[MessageGUID],
       recr.MessageType,
       recr.MessageText,
       recr.MessageTo,
       recr.ToContactType,
       recr.MessageFrom,
       recr.FromContactType,
       recr.SentDate,
       recr.ReceivedDate,
       recr.MessageSubject,
       recr.[Status],
       recr.BodyFormat,
       recr.BadEmailAddress,
       recr.ClientID,
       recr.ClientName,
       fam.LoweredEmail as FromUserEmail,
	   fmu.UserFirstName as FromUserFirstName,
	   fmu.UserLastName as FromUserLastName,
	   fmu.UserMiddleInit as FromMiddleInit,
	   ltrim(rtrim(rtrim(coalesce(fmu.UserFirstName,'') + ' ' + coalesce(fmu.UserMiddleInit,'')) + ' ' + coalesce(fmu.UserLastName,''))) as FromFullName,
	   tam.LoweredEmail as ToUserEmail,
	   tou.UserFirstName as ToUserFirstName,
	   tou.UserLastName as ToUserLastName,
	   tou.UserMiddleInit as ToMiddleInit,
	   ltrim(rtrim(rtrim(coalesce(tou.UserFirstName,'') + ' ' + coalesce(tou.UserMiddleInit,'')) + ' ' + coalesce(tou.UserLastName,''))) as ToFullName
  from ReminderEmailCurrentRun recr
       inner join Users fmu on fmu.UserID = recr.MessageFrom
       inner join Users tou on tou.UserID = recr.MessageTo
	   inner join aspnet_Membership fam on fam.UserId = fmu.UserGUID
	   inner join aspnet_Membership tam on tam.UserId = tou.UserGUID
  order by recr.ClientName

END


GO
