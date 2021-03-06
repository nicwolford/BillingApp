/****** Object:  StoredProcedure [dbo].[S1_ProductTransactions_UpdateProductTransaction]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--S1_ProductTransactions_UpdateProductTransaction

CREATE PROCEDURE [dbo].[S1_ProductTransactions_UpdateProductTransaction]
(
	@ProductTransactionID int,
	@ProductID int, 
	@ClientID int, 
	@VendorID int, 
	@TransactionDate datetime,
	@DateOrdered datetime, 
	@OrderBy varchar(50), 
	@Reference varchar(50), 
	@FileNum varchar(50), 
	@FName varchar(50), 
	@LName varchar(50), 
	@MName varchar(50), 
	@SSN varchar(50), 
	@ProductDescription varchar(max), 
	@ProductType varchar(50), 
	@ProductPrice money
)
AS
	SET NOCOUNT ON;
	
	UPDATE ProductTransactions
	SET ProductID=@ProductID, 
	ClientID=@ClientID, 
	VendorID=@VendorID, 
	TransactionDate=@TransactionDate,
	DateOrdered=@DateOrdered, 
	OrderBy=@OrderBy, 
	Reference=@Reference, 
	FileNum=@FileNum, 
	FName=@FName, 
	LName=@LName, 
	MName=@MName, 
	SSN=@SSN, 
	ProductDescription=@ProductDescription, 
	ProductType=@ProductType, 
	ProductPrice=@ProductPrice
	WHERE ProductTransactionID=@ProductTransactionID
GO
