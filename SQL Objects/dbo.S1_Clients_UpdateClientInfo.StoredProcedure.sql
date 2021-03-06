/****** Object:  StoredProcedure [dbo].[S1_Clients_UpdateClientInfo]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[S1_Clients_UpdateClientInfo]
(
	@ClientID int,
	@ClientName varchar(max),
	@Address1 varchar(max),
	@Address2 varchar(max),
	@City varchar(max),
	@State varchar(2),
	@Zip varchar(max),
	@ParentClientID int,
	@BillAsClientName varchar(max),
	@Status varchar(50),
	@AuditInvoices bit, 
	@DoNotInvoice bit,
	@BillingGroupID int,
	@notes varchar(max)
)
AS
	SET NOCOUNT ON;
BEGIN
	DECLARE @error int
		
	set @error = 0
	
	if (@ParentClientID = 0)
	BEGIN
		SET @ParentClientID = null
	END
	
	--Remove any Client Invoice settings if the client's parent has been changed to a 
	--parent that has a SplitByMode = 2 (rolled up invoice)
	if exists (select * from ClientInvoiceSettings where ClientID = @ClientID and @ParentClientID is not null)
	BEGIN
		if exists (select * from ClientInvoiceSettings where ClientID = @ParentClientID and SplitByMode = 2)
			BEGIN
				DELETE FROM ClientInvoiceSettings WHERE ClientID = @ClientID
			END
	END
	
	UPDATE Clients SET
	ParentClientID = @ParentClientID, ClientName = @ClientName, 
	Address1 = @Address1, Address2 = @Address2, City = @City, State = @State, 
	ZipCode = @Zip, DoNotInvoice = @DoNotInvoice, AuditInvoices = @AuditInvoices,
	BillAsClientName = @BillAsClientName, BillingGroup = @BillingGroupID,
	Notes=@notes, Status = @Status
	WHERE ClientID = @ClientID
	
	If (@@ERROR <> 0)
	BEGIN
		set @error = -1
	END
	
	return @error	
END





GO
