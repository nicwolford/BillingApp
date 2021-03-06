/****** Object:  StoredProcedure [dbo].[S1_Clients_GetClientVendors]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec S1_Clients_GetClientVendors 2700

CREATE PROCEDURE [dbo].[S1_Clients_GetClientVendors]
(
	@ClientID int
)
AS
BEGIN
	SET NOCOUNT ON;
	
SELECT 
(select top 1 vendorclientnumber from ClientVendors where ClientID = @clientid and vendorid =1) as Tazworks1ID,
(select top 1 vendorclientnumber from ClientVendors where ClientID = @clientid and vendorid =2) as Tazworks2ID,
(select top 1 vendorclientnumber from ClientVendors where ClientID = @clientid and vendorid =3) as Debtor11ID,
(select top 1 vendorclientnumber from ClientVendors where ClientID = @clientid and vendorid =4) as TransUnionID,
(select top 1 vendorclientnumber from ClientVendors where ClientID = @clientid and vendorid =5) as ExperianID,
(select top 1 vendorclientnumber from ClientVendors where ClientID = @ClientID and VendorID =8) as PembrookID,
(select top 1 vendorclientnumber from ClientVendors where ClientID = @ClientID and VendorID =7) as ApplicantONEID,
(select top 1 vendorclientnumber from ClientVendors where ClientID = @ClientID and VendorID =9) as RentTrackID

END

GO
