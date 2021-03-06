/****** Object:  StoredProcedure [dbo].[S1_ClientContacts_UpdateBillingContact]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[S1_ClientContacts_UpdateBillingContact]
@billingcontactid int,
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
@contactemail varchar(max),
@isprimary bit,
@POName varchar(50),
@PONumber varchar(50),
@notes varchar(max),
@OnlyShowInvoices bit,
@BillingContactStatus bit,
@NewPrimaryContactID int
AS
SET NOCOUNT ON;
Begin

DECLARE @error int

select @error = 0


if exists(select InvoiceSplitID from InvoiceSplit where ClientID = @clientid) and
   not exists(select bc.BillingContactID  from BillingContacts bc where bc.ClientID = @clientid and bc.ClientContactID = @clientcontactid)
begin

;INSERT INTO BillingContacts (ClientID, ClientContactID, DeliveryMethod, ContactName, ContactAddress1, ContactAddress2,
				              ContactCity, ContactStateCode, ContactZIP, ContactEmail, OrderBy, ContactPhone, ContactFax, IsPrimaryBillingContact, 
				              POName, PONumber, Notes, OnlyShowInvoices, BillingContactStatus, HideFromClient)
 VALUES (@clientid, @clientcontactid, @deliverymethod, @contactname, @contactaddr1, @contactaddr2, 
		 @contactcity, @contactstate, @contactzip, @contactemail, null, @contactbusinessphone, @contactfax, 
		 0 /*@isprimary*/, @POName, @PONumber, @notes, @OnlyShowInvoices, @BillingContactStatus, 0)

return @error

end

if exists(select InvoiceSplitID from InvoiceSplit where ClientID = @clientid)
BEGIN
select @error = -5
END

if @error = 0
BEGIN
;declare @OldPrimaryContactID int

;select top 1 @OldPrimaryContactID = BillingContactID from BillingContacts where IsPrimaryBillingContact = 1 and ClientID = @clientid order by BillingContactID desc

if @isprimary = 1 and
(@NewPrimaryContactID is null or @NewPrimaryContactID = 0)
begin
select @NewPrimaryContactID = @billingcontactid
end
else if (@NewPrimaryContactID is null or @NewPrimaryContactID = 0)
begin
select @NewPrimaryContactID = @OldPrimaryContactID
end

select @NewPrimaryContactID = coalesce(@NewPrimaryContactID,0),
       @OldPrimaryContactID = coalesce(@OldPrimaryContactID,0)

if ((@NewPrimaryContactID != @OldPrimaryContactID and
     @NewPrimaryContactID != 0 and
	 @OldPrimaryContactID != 0) or
    (@OldPrimaryContactID = 0 and
	 @NewPrimaryContactID != 0))
BEGIN
if (exists(select BillingContactID 
             from BillingContacts 
	  	     WHERE BillingContactID = @NewPrimaryContactID and 
			       ClientID = @clientid and
				   IsPrimaryBillingContact = 1)) or
   /*(exists(select BillingContactID 
             from BillingPackagePrinted 
			 WHERE BillingContactID = @NewPrimaryContactID)) or*/
   (exists(select BillingContactID 
             from InvoiceBillingContacts 
			 WHERE BillingContactID = @NewPrimaryContactID and
			       IsPrimaryBillingContact = 1)) or
   (exists(select BillingContactID 
             from Payments
			 WHERE BillingContactID = @NewPrimaryContactID))
BEGIN
select @error = -4
END
else if (not exists(select BillingContactID from BillingContacts where BillingContactID = @NewPrimaryContactID and ClientID = @clientid))
BEGIN
select @error = -3
END

if @error = 0
BEGIN

if coalesce(@OldPrimaryContactID,0) != 0
begin
UPDATE BillingContacts
SET IsPrimaryBillingContact = 0
WHERE BillingContactID = @OldPrimaryContactID
and ClientID = @clientid
end

UPDATE BillingContacts
SET IsPrimaryBillingContact = 1
WHERE BillingContactID = @NewPrimaryContactID
and ClientID = @clientid

if coalesce(@OldPrimaryContactID,0) != 0
begin
;with dataToInsert as (
select @NewPrimaryContactID as BillingContactID, 
       bpp.PackageEndDate, 
	   bpp.PrintedOn, 
	   bpp.PrintedByUser, 
	   NEWID() as EmailGuid
  from BillingPackagePrinted bpp
  where bpp.BillingContactID = @OldPrimaryContactID)
insert into BillingPackagePrinted(BillingContactID,PackageEndDate,PrintedOn,PrintedByUser,EmailGuid)
select dti.BillingContactID,dti.PackageEndDate,dti.PrintedOn,dti.PrintedByUser,dti.EmailGuid
  from dataToInsert dti
  where not exists(select bpp.BillingPackagePrintedID
                     from BillingPackagePrinted bpp
		 		 	 where bpp.BillingContactID = dti.BillingContactID and
					       bpp.PackageEndDate = dti.PackageEndDate and
					       bpp.PrintedByUser = dti.PrintedByUser and
						   bpp.PrintedOn = dti.PrintedOn)
end

if coalesce(@OldPrimaryContactID,0) != 0
begin
UPDATE InvoiceBillingContacts
SET IsPrimaryBillingContact = 0
WHERE BillingContactID = @OldPrimaryContactID
end

UPDATE InvoiceBillingContacts
SET IsPrimaryBillingContact = 1
WHERE BillingContactID = @NewPrimaryContactID


--UPDATE InvoiceSplitBillingContacts
--SET IsPrimaryBillingContact = 0
--WHERE BillingContactID = @OldPrimaryContactID

--UPDATE InvoiceSplitBillingContacts
--SET IsPrimaryBillingContact = 1
--WHERE BillingContactID = @NewPrimaryContactID

if coalesce(@OldPrimaryContactID,0) != 0
begin
UPDATE Payments
SET BillingContactID = @NewPrimaryContactID
WHERE BillingContactID = @OldPrimaryContactID
end

--write to the log table for tracking
DECLARE @ActionTypeCode varchar(50)
DECLARE @LogDescription varchar(max)
SELECT @ActionTypeCode = 'PrimaryBillingContactID_Reassigned'
SELECT @LogDescription = 'PrimaryBillingContact has been reassigned. Original PrimaryContactID: ' + Cast(@OldPrimaryContactID as varchar(15)) + ' New PrimaryContactID: ' + Cast(@NewPrimaryContactID as varchar(15))
EXEC S1_Log_CreateAction @ActionTypeCode,@LogDescription
END
END

;UPDATE BillingContacts
SET
DeliveryMethod = @deliverymethod,
ContactName = @contactname,
ContactAddress1 = @contactaddr1,
ContactAddress2 = @contactaddr2,
ContactCity = @contactcity,
ContactStateCode = @contactstate,
ContactZIP = @contactzip,
ContactEmail = @contactemail,
ContactPhone = @contactbusinessphone,
ContactFax = @contactfax,
--IsPrimaryBillingContact = @isprimary, --This is handled above
POName = @POName,
PONumber = @PONumber,
Notes = @notes,
OnlyShowInvoices = @OnlyShowInvoices,
BillingContactStatus = @BillingContactStatus
WHERE BillingContactID = @billingcontactid
and ClientContactID = @clientcontactid
and ClientID = @clientid

END

return @error

END
GO
