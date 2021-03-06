/****** Object:  StoredProcedure [dbo].[S1_ClientContacts_CreateBillingContact]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_ClientContacts_CreateBillingContact]
	@clientid int,
	@clientcontactid int,
	@deliverymethod int,
	@contactname varchar(255),
	@contactaddr1 varchar(100),
	@contactaddr2 varchar(100),
	@contactcity varchar(100),
	@contactstate varchar(2),
	@contactzip varchar(10),
	@contactbusinessphone varchar(50),
	@contactfax varchar(50),
	@contactemail varchar(255),
	@isprimary bit,
	@POName varchar(50),
	@PONumber varchar(50),
	@notes varchar(max),
	@OnlyShowInvoices bit
AS
BEGIN
    
	SET NOCOUNT ON;

	DECLARE @billingcontactid int
	
	if not exists(select InvoiceSplitID from InvoiceSplit where ClientID = @clientid)
    BEGIN
		SET @isprimary = 0
		SET @OnlyShowInvoices = 1
		
		if not exists(select * from BillingContacts where clientcontactid = @clientcontactid and clientid = @clientid and ContactEmail = @contactemail)
		BEGIN

			INSERT INTO BillingContacts (ClientID, ClientContactID, DeliveryMethod, ContactName, ContactAddress1, ContactAddress2,
				ContactCity, ContactStateCode, ContactZIP, ContactEmail, OrderBy, ContactPhone, ContactFax, IsPrimaryBillingContact, 
				POName, PONumber, Notes, OnlyShowInvoices, BillingContactStatus, HideFromClient)
			VALUES (@clientid, @clientcontactid, @deliverymethod, @contactname, @contactaddr1, @contactaddr2, 
					@contactcity, @contactstate, @contactzip, @contactemail, null, @contactbusinessphone, @contactfax, 
					@isprimary, @POName, @PONumber, @notes, @OnlyShowInvoices, 1, 0)

			SET @billingcontactid = @@IDENTITY
		
			IF (@billingcontactid is not null and 
			    @billingcontactid != 0 and 
				@isprimary = 0)
			BEGIN			
				INSERT INTO InvoiceBillingContacts (InvoiceID, BillingContactID, IsPrimaryBillingContact)
				SELECT InvoiceID, @billingcontactid, @isprimary
				FROM Invoices 
				WHERE ClientID = @clientid		
			END

		END
		ELSE
		BEGIN
			SET @billingcontactid = 0 
		END
    END
    else if not exists(select bc.BillingContactID  from BillingContacts bc where bc.ClientID = @clientid and bc.ClientContactID = @clientcontactid)
	BEGIN

	;INSERT INTO BillingContacts (ClientID, ClientContactID, DeliveryMethod, ContactName, ContactAddress1, ContactAddress2,
				              ContactCity, ContactStateCode, ContactZIP, ContactEmail, OrderBy, ContactPhone, ContactFax, IsPrimaryBillingContact, 
				              POName, PONumber, Notes, OnlyShowInvoices, BillingContactStatus, HideFromClient)
     VALUES (@clientid, @clientcontactid, @deliverymethod, @contactname, @contactaddr1, @contactaddr2, 
		 @contactcity, @contactstate, @contactzip, @contactemail, null, @contactbusinessphone, @contactfax, 
		 0 /*@isprimary*/, @POName, @PONumber, @notes, @OnlyShowInvoices, 1, 0)

    SET @billingcontactid = @@IDENTITY

	END
	else
	BEGIN
	    SET @billingcontactid = 0 
	END
	
	SELECT @billingcontactid as BillingContactID
	
END

GO
