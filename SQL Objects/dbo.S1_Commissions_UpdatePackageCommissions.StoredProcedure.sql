/****** Object:  StoredProcedure [dbo].[S1_Commissions_UpdatePackageCommissions]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[S1_Commissions_UpdatePackageCommissions]
@PackageCommissionID int,
@ClientID varchar(50) = null,
@ClientName varchar(500),
@PackageName varchar(500),
@PackageProducts varchar(800) = null,
@PackageCommissionRate decimal(4, 2),
@BillingClientID int = null
AS
BEGIN
--Exec S1_Commissions_UpdatePackageCommissions -1, '1633', 'Cooley Boston Staff Recruiting', 'Package price for Staff', 'Social Security Trace, County Criminal, County Civil, Motor Vehicle Record, and Employment Verification - Package price for Staff', 29.30, 1982

;declare @PackageCommissionsUpdated table (PackageCommissionID int)

;select @ClientID = case 
                     when coalesce(@ClientID, '') = '' then cv.VendorClientNumber 
					 else @ClientID 
				   end,
	   @PackageProducts = case 
                            when coalesce(@PackageProducts, '') = '' then @PackageName
					        else @PackageProducts
				          end,
	   @BillingClientID = case 
                            when coalesce(@BillingClientID,0) = 0 then cv.ClientID
					        else @BillingClientID
				          end
  from (select c.ClientID
          from Clients c
		  where c.ClientName = @ClientName) c
       inner join ClientVendors cv on cv.ClientID = c.ClientID
  where cv.VendorID = 2		              

;update PackageCommissions
  set PackageCommissions.ClientID = @ClientID,
      PackageCommissions.ClientName = @ClientName,
	  PackageCommissions.PackageName = @PackageName,
	  PackageCommissions.PackageProducts = @PackageProducts,
	  PackageCommissions.PackageCommissionRate = @PackageCommissionRate,
	  PackageCommissions.BillingClientID = @BillingClientID
  output inserted.PackageCommissionID into @PackageCommissionsUpdated
  where PackageCommissions.PackageCommissionID = @PackageCommissionID and
        coalesce(@ClientID,'') <> ''


;select pc.PackageCommissionID
       ,pc.ClientID
       ,pc.ClientName
       ,pc.PackageName
       ,pc.PackageProducts
       ,pc.PackageCommissionRate
       ,pc.BillingClientID
   from PackageCommissions pc
        inner join @PackageCommissionsUpdated pcu on pcu.PackageCommissionID = pc.PackageCommissionID

END

GO
