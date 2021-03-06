/****** Object:  StoredProcedure [dbo].[S1_Maintenance_UpdateBillingProductTransactions_Part2]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Wellbridge (run after doing the Maintenance SP for Background in ApplicantOne first, then do again after eDrug in ApplicantOne
--EXEC S1_Maintenance_UpdateBillingProductTransactions_Part2 1

--Ted Britt
--EXEC S1_Maintenance_UpdateBillingProductTransactions_Part2 2

CREATE PROCEDURE [dbo].[S1_Maintenance_UpdateBillingProductTransactions_Part2]
(
	@UpdateProductDescriptionOrReference int --1 = Product Description, 2 = Reference
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @tmpProductTransactions TABLE (
		ProductTransactionID int,
		ProductDescription varchar(max),
		Reference varchar(max)
	)

	INSERT INTO @tmpProductTransactions
	SELECT ProductTransactionID, ProductDescription, Reference
	FROM [504050-DB1].ApplicantONE.dbo.Maintenance_Billing_ProductTransactionsTemp

	
	IF (@UpdateProductDescriptionOrReference = 1)
	BEGIN

		UPDATE PT
		SET PT.ProductDescription = TPT.ProductDescription
		FROM Producttransactions PT
		INNER JOIN @tmpProductTransactions TPT
		ON PT.ProductTransactionID=TPT.ProductTransactionID
	
	END
	ELSE IF (@UpdateProductDescriptionOrReference = 2)
	BEGIN
		
		UPDATE PT
		SET PT.Reference = TPT.Reference
		FROM Producttransactions PT
		INNER JOIN @tmpProductTransactions TPT
		ON PT.ProductTransactionID=TPT.ProductTransactionID
	
	END	

END

GO
