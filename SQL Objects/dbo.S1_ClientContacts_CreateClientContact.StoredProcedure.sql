/****** Object:  StoredProcedure [dbo].[S1_ClientContacts_CreateClientContact]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[S1_ClientContacts_CreateClientContact]
(
	@userid int,
	@clientid int,
	@contactfirstname varchar(100),
	@contactlastname varchar(100),
	@contacttitle varchar(100),
	@contactaddr1 varchar(100),
	@contactaddr2 varchar(100),
	@contactcity varchar(100),
	@contactstate varchar(2),
	@contactzip varchar(10),
	@contactbusinessphone varchar(50),
	@contactfax varchar(50),
	@contactemail varchar(255)
)
AS
SET NOCOUNT ON;
Begin

	DECLARE @clientcontactid int
			
		
	if not exists(select * from ClientContacts where userid = @userid and clientid = @clientid and ContactEmail = @contactemail)
	BEGIN

		INSERT INTO ClientContacts (ClientID, UserID, ContactPrefix, ContactFirstName, ContactLastName, ContactSuffix,
			ContactTitle, ContactAddr1, ContactAddr2, ContactCity, ContactStateCode, ContactZIP, ContactBusinessPhone, ContactCellPhone,
			ContactHomePhone, ContactFax, ContactEmail, ContactStatus)
		VALUES (@clientid, @userid, null, @contactfirstname, @contactlastname, null, @contacttitle, @contactaddr1, @contactaddr2, 
				@contactcity, @contactstate, @contactzip, @contactbusinessphone, null,null, @contactfax, @contactemail, 1)

		SET @clientcontactid = @@IDENTITY

		if not exists(select * from ClientUsers where UserID = @userid and ClientID = @clientid)
		BEGIN
			INSERT INTO ClientUsers (UserID, ClientID, IsPrimaryClient)
			VALUES (@userid, @clientid, 0)
		END
	
	END
	ELSE
	BEGIN
		SET @clientcontactid = 0 
	END
	
	SELECT @clientcontactid as ClientContactID
	
END

GO
