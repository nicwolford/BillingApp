/****** Object:  StoredProcedure [dbo].[S1_Clients_UpdateClientVendorSettings]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[S1_Clients_UpdateClientVendorSettings]
(
	@ClientID int,
	@vendorid int,
	@vendorclientnumber varchar(max)
)
AS
	SET NOCOUNT ON;
	
	if exists(select * from ClientVendors where ClientID = @ClientID and VendorID = @vendorid)
	BEGIN
	
		if (@vendorclientnumber is null or @vendorclientnumber = '')
		BEGIN
			DELETE FROM ClientVendors
			WHERE ClientID = @ClientID and VendorID = @vendorid
		END
		ELSE
		BEGIN
			UPDATE ClientVendors
			SET VendorClientNumber = @vendorclientnumber
			WHERE ClientID = @ClientID
			  AND VendorID = @vendorid
		END
	END
	ELSE
	BEGIN
		if (@vendorclientnumber is not null and @vendorclientnumber <> '')
		BEGIN
			INSERT INTO ClientVendors (ClientID, VendorID, VendorClientNumber)
			VALUES (@ClientID, @vendorid, @vendorclientnumber)
		END
	END
	
	--Set the appropriate billing group on the client table based on latest vendors attached to the client
	/*
	if exists(select * from ClientVendors where ClientID = @ClientID and VendorID in (1,2)) and 
		exists(select * from ClientVendors where ClientID = @ClientID and VendorID in (4,5))
	BEGIN
		UPDATE Clients
		SET BillingGroup = 2
		WHERE ClientID = @ClientID	
	END
	ELSE
	BEGIN
		UPDATE Clients
		SET BillingGroup = 1
		WHERE ClientID = @ClientID
	END
	*/

GO
