/****** Object:  StoredProcedure [dbo].[S1_Commissions_CreatePackageCommissions]    Script Date: 11/21/2016 9:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[S1_Commissions_CreatePackageCommissions]
@ClientID varchar(50) = null,
@ClientName varchar(500),
@PackageName varchar(500),
@PackageProducts varchar(800) = null,
@PackageCommissionRate decimal(4, 2),
@BillingClientID int = null
AS
BEGIN

--Exec S1_Commissions_CreatePackageCommissions 'S1_00803', 'Vineyard', 'Package price for Basic Package', 'credit report with eviction search.', 3.30, 330

;declare @PackageCommissionsInserted table (PackageCommissionID int)

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

;with dataToInsert as
(select @ClientID as ClientID,
        @ClientName as ClientName,
        @PackageName as PackageName,
        @PackageProducts as PackageProducts,
        @PackageCommissionRate as PackageCommissionRate,
        @BillingClientID as BillingClientID)
insert into PackageCommissions (ClientID, ClientName, PackageName, PackageProducts, PackageCommissionRate, BillingClientID)
output inserted.PackageCommissionID into @PackageCommissionsInserted
select dti.ClientID,
	   dti.ClientName,
	   dti.PackageName,
	   dti.PackageProducts,
	   dti.PackageCommissionRate,
	   dti.BillingClientID
  from dataToInsert dti
  where coalesce(@ClientID,'') != '' and
        not exists(select pc.PackageCommissionID
                     from PackageCommissions pc
					 where pc.ClientName = dti.ClientName and
					       pc.PackageName = dti.PackageName)

;select pc.PackageCommissionID
       ,pc.ClientID
       ,pc.ClientName
       ,pc.PackageName
       ,pc.PackageProducts
       ,pc.PackageCommissionRate
       ,pc.BillingClientID
   from PackageCommissions pc
        inner join @PackageCommissionsInserted pci on pci.PackageCommissionID = pc.PackageCommissionID

END

GO
