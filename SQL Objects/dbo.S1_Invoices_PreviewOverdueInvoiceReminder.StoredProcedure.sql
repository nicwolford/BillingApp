/****** Object:  StoredProcedure [dbo].[S1_Invoices_PreviewOverdueInvoiceReminder]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Invoices_PreviewOverdueInvoiceReminder]
@FromUserId int,
@MessageSubject varchar(255),
@MessageText varchar(max),
@UserFinanceChargeDate datetime = null
AS
BEGIN

--Exec S1_Invoices_PreviewOverdueInvoiceReminder 2, 'ScreeningONE Payment Reminder', 
--<p>Dear ScreeningONE Client:<br />
--<br />
--This letter is to notify that you have at least one outstanding invoice and you may be assessed a finance charge. In accordance with your service agreement with ScreeningONE, any invoices not paid in full within [[NetDays]] days of the date of the invoice, will be assessed a finance charge. Below are the outstanding invoice(s) and the amount of finance charge(s) that may be assessed.<br />
--<br />
--<div style="margin-left: 1em;">[[InvoiceList]]</div><br /> 
--</br />
--<br />
--Please submit your payment by [[FinanceChargeDate]] to avoid the assessment of the finance charge(s).<br />
--If you have recently submitted your payment to us, thank you and please discard this notice.<br />
--<br />
--For your convenience we offer payment by phone with check or credit card completely free of charge. Please call 888-327-6511 x 206 if you wish to pay by phone.<br />
--<br />
--Sincerely,<br />
--Screening One, Inc.</p>

	;declare @nPlease datetime,
			 @nPleaseWOTime datetime,
			 @InvoiceDate datetime

	;declare @ToSendMessages as TABLE(
		[MessageGUID] uniqueidentifier,
		[MessageType] int,
		[MessageText] varchar(max),
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

	if not exists(select m.MessageID
					from [Messages] m
					where m.SentDate >= @nPleaseWOTime and
						  m.MessageType = 6 and
						  m.[Status] = 1)
	BEGIN

		;DECLARE @FinanceChargeDate datetime
		;SET @FinanceChargeDate =  DATEADD(MONTH, DATEDIFF(MONTH, 0, @nPlease) + 1, 0)

		if @UserFinanceChargeDate is not null
		begin
		  ;SET @FinanceChargeDate = @UserFinanceChargeDate
		end

		;DECLARE @tmp_UnbalancedOverPaymentList TABLE
		(
		ClientID int,
		[Type] varchar(20)
		)
		
		;INSERT INTO @tmp_UnbalancedOverPaymentList 
		EXEC S1_Invoices_GetClientsOnOverpaymentUnbalancedList

		;DECLARE @tmp_FinanceChargeInvoices TABLE
		(
		InvoiceID int, 
		InvoiceNumber varchar(50),
		ClientID int,
		ClientName varchar(100),
		InvoiceDate datetime,
		OriginalInvoiceAmount money,
		InvoiceAmountDue money,
		CreditAmount money,
		PaymentAmount money,
		FinanceChargeAmount money
		)

		;INSERT INTO @tmp_FinanceChargeInvoices
		EXEC S1_Invoices_GetInvoicesToCreateFinanceChargeTransactionsFor @FinanceChargeDate

		;DECLARE @ProductID int = 372
		;DECLARE @VendorID int = 6
		;DECLARE @TransactionDate datetime = (SELECT DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@FinanceChargeDate),0)))
		;DECLARE @DateOrdered datetime  = @FinanceChargeDate
		;DECLARE @OrderBy varchar(50) = NULL
		;DECLARE @FileNum varchar(50)
		;DECLARE @FName varchar(255) = NULL
		;DECLARE @LName varchar(255) = NULL
		;DECLARE @MName varchar(255) = NULL
		;DECLARE @SSN varchar(50) = NULL
		;DECLARE @ProductType varchar(50) = NULL
		;DECLARE @Reference varchar(50) -- id of the invoice that created the FC
		;DECLARE @ProductDescription varchar(max)
		;DECLARE @ProductPrice money -- the amount of the FC

		;DECLARE @ClientID int
		;DECLARE @ClientName varchar(100)
		;DECLARE @FinanceChargeDays int
		
		;DECLARE @tmpInvoiceList TABLE
		(
		InvoiceID int,
		ProductDescription varchar(max),
		[Status] int
		)
			
		--Get the message template
		;DECLARE @tmp_MessageTemplate TABLE(
		MessageText varchar(max)
		)

		;INSERT INTO @tmp_MessageTemplate 
		select @MessageText
				 
		--Get all finance charges except for those clients who are on the unbalanced and/or overpayment list
		;DECLARE curFinCharges CURSOR for
		SELECT distinct FC.ClientID,CIS.FinanceChargeDays,FC.ClientName
		FROM @tmp_FinanceChargeInvoices FC
		INNER JOIN ClientInvoiceSettings CIS ON FC.ClientID = CIS.ClientID
		LEFT OUTER JOIN @tmp_UnbalancedOverPaymentList UO
		ON FC.ClientID = UO.ClientID
		WHERE UO.ClientID IS NULL
		and FC.ClientID not in (select clientid from clients where clientid in (3155, 3179) or parentclientid = 3155) --Exclude Loundon County per email request from Kim F on 7/26


		OPEN curFinCharges
		FETCH curFinCharges into @ClientID,@FinanceChargeDays,@ClientName

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			
			;DELETE FROM @tmpInvoiceList
			
			;INSERT INTO @tmpInvoiceList	
			SELECT FC.InvoiceID,
			'ProductDescription' = 'Customer Name: ' + FC.ClientName + ', Invoice: ' + FC.InvoiceNumber + ' - $' + convert(varchar, FC.OriginalInvoiceAmount) ,
			'Status' = 0
			FROM @tmp_FinanceChargeInvoices FC
			WHERE FC.ClientID = @ClientID 
			
			;DECLARE @InvoiceList varchar(max) = NULL
			SELECT @InvoiceList = COALESCE(@InvoiceList + '<br />','') + ProductDescription
			FROM @tmpInvoiceList
			
			;DECLARE @msgTxt varchar(max) = NULL
			;SELECT @msgTxt = MessageText From @tmp_MessageTemplate 
			;SET @msgTxt = REPLACE(@msgTxt,'[[NetDays]]',@FinanceChargeDays)
			;SET @msgTxt = REPLACE(@msgTxt,'[[GUIDURL]]','https://www.screeningone.com')
			;SET @msgTxt = REPLACE(@msgTxt,'[[FinanceChargeDate]]',CONVERT(varchar,MONTH(@FinanceChargeDate)) + '/' + CONVERT(varchar,DAY(@FinanceChargeDate)) + '/' + CONVERT(varchar,YEAR(@FinanceChargeDate)))
			;SET @msgTxt = REPLACE(@msgTxt,'[[InvoiceList]]',@InvoiceList)
			
			;DECLARE @messageactiontype int
			;DECLARE @tocontacttype int --1 = User, 2 = Client Contact, 3 = Primary Billing Contact
			;DECLARE @fromcontacttype int --1 = User, 3 = Automated
			;DECLARE @messageactionpath varchar(100)
			;DECLARE @sentdate datetime = null
			;DECLARE @MessageID int
			;DECLARE @MessageActionGUID uniqueidentifier
			;DECLARE @SendToUserID int
			
			;SET @messageactiontype = 6 --Finance Charge					   
			;SET @tocontacttype = 3 
			;SET @fromcontacttype = 3
			;SET @messageactionpath = ''
			;SET @sentdate = @nPlease
			;SET @messageactionpath = ''
			
			;SELECT @SendToUserID = BillingContactID
			FROM BillingContacts
			WHERE ClientID = @ClientID AND IsPrimaryBillingContact = 1


			;insert into @ToSendMessages(MessageGUID,MessageType,MessageText,
										 MessageTo,ToContactType,MessageFrom,
										 FromContactType,SentDate,ReceivedDate,
										 MessageSubject,[Status],BodyFormat,
										 BadEmailAddress,ClientID,ClientName)
			select NEWID() as MessageGUID,
				   @messageactiontype as MessageType,
				   @msgTxt as MessageText,
				   @SendToUserID as MessageTo,
				   @tocontacttype as ToContactType,
				   0 as MessageFrom,
				   @fromcontacttype as FromContactType,
				   @sentdate as SentDate,
				   null as ReceivedDate,
				   @MessageSubject as MessageSubject,
				   1 as [Status],
				   'HTML' as BodyFormat,
				   0 as BadEmailAddress,
				   @ClientID as ClientID,
				   @ClientName as ClientName
			
			--SELECT @msgTxt
			
			--EXEC S1_Messages_CreateMessageWithAction @messageactiontype, 'ScreeningONE Payment Reminder', @msgTxt, @SendToUserID, @tocontacttype, 0, @fromcontacttype,@messageactionpath,@sentdate, null, 'HTML', @MessageID,@MessageActionGUID

			--UPDATE [Messages] 
			--SET [Status]=1
			--WHERE MessageID=@MessageID
			
			FETCH curFinCharges into @ClientID,@FinanceChargeDays,@ClientName

		END

		CLOSE curFinCharges
		DEALLOCATE curFinCharges

	END

	if exists(select * from @ToSendMessages tsm)
	BEGIN
		;truncate table FinanceChargeEmailCurrentRun
		;insert into FinanceChargeEmailCurrentRun(MessageGUID,MessageType,MessageText,
												  MessageTo,ToContactType,MessageFrom,
												  FromContactType,SentDate,ReceivedDate,
												  MessageSubject,[Status],BodyFormat,
												  BadEmailAddress,ClientID,ClientName)
		select tsm.MessageGUID,
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
