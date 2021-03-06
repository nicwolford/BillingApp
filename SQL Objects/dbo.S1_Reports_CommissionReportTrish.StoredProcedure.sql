/****** Object:  StoredProcedure [dbo].[S1_Reports_CommissionReportTrish]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC S1_Reports_CommissionReportTrish '09/01/2016'

CREATE PROCEDURE [dbo].[S1_Reports_CommissionReportTrish]
(
	@InvoiceDate datetime
)
AS
	SET NOCOUNT ON;

;with commdetails as (
select 
PO.FILENUM as FILENUM, (select top 1 Vendorclientnumber from ClientVendors where ClientID = c.ClientID and VendorID in (1,2,8) order by VendorID desc) as Client,
c.clientname, 
case when c.ClientID in (select ClientID from Clients where ClientID = 1874 or ParentClientID = 1874) then 'tbyrd' else pt.salesrep end as salesrep, 
pt.DateOrdered, po.productdescription, p.productname, po.ProductType, 
case 
	when c.ClientID in (select ClientID from Clients where ParentClientID = 3395 or ClientID = 3395) then po.ProductPrice - (po.ProductPrice * .10)
	when c.clientid = 3319 and po.ProductDescription like '%Package C%' then 33.42
	else po.ProductPrice end as ProductPrice, 
CASE p.ProductName
	
	WHEN 'Tenant Product Package'
	THEN (select packagecommissionrate from packagecommissions where (packageproducts = po.productdescription or PackageName = po.ProductDescription) and clientid in (select vendorclientnumber from clientvendors where clientid = c.clientid))

	WHEN 'Employment Product Package'
	THEN (select packagecommissionrate from packagecommissions where (packageproducts = po.productdescription or PackageName = po.ProductDescription) and clientid in (select vendorclientnumber from clientvendors where clientid = c.clientid))

	WHEN 'Business Product Package'
	THEN (select packagecommissionrate from packagecommissions where (packageproducts = po.productdescription or PackageName = po.ProductDescription) and clientid in (select vendorclientnumber from clientvendors where clientid = c.clientid))

	WHEN 'Vounteer Product Package'
	THEN (select packagecommissionrate from packagecommissions where (packageproducts = po.productdescription or PackageName = po.ProductDescription) and clientid in (select vendorclientnumber from clientvendors where clientid = c.clientid))

	WHEN 'Package- Other'
	THEN (select packagecommissionrate from packagecommissions where (packageproducts = po.productdescription or PackageName = po.ProductDescription) and clientid in (select vendorclientnumber from clientvendors where clientid = c.clientid))

	
	WHEN 'Custom Investigative Search'
	THEN 
		CASE WHEN po.ProductDescription like '%Statewide Criminal Search%' then 4.00 
		     WHEN po.ProductDescription like '%County Criminal Search%' and po.ProductDescription not like '%Fairfax%' then 6.00
		     WHEN po.ProductDescription like '%National Wants and Warrants%' then 4.50
		     WHEN po.ProductDescription like '%Fairfax County Criminal Search%' then 3.00
		     WHEN po.ProductDescription like '%I-9 Verification%' then .31
		     WHEN po.ProductDescription like '%Denver Citywide Criminal Search%' then 1.00 
		     WHEN po.ProductDescription like '%Adult and Elderly Abuse Registry Check%' then 1.00 
		     WHEN po.ProductDescription like '%Alias National Criminal Search%' then 2.4
		     WHEN po.ProductDescription like '%Bad Check Report%' then 1.12
		     WHEN po.ProductDescription like '%OFAC Plus%' then .12
		     WHEN po.ProductDescription like '%OFAC-Global Homeland Security Search%' then .12
		     WHEN po.ProductDescription like '%TN Abuse Registry%' then .5
		     WHEN po.ProductDescription like '%CUSTOM INVESTIGATIVE: NORTH CAROLINA STATEWIDE CRIMINAL%' then 4.00
		     WHEN po.ProductDescription like '%NORTH CAROLINA STATEWIDE CRIMINAL%' then 4.00
		     WHEN po.ProductDescription like '%CUSTOM INVESTIGATIVE: NC STATEWIDE CRIMINAL%' then 4.00
		     WHEN po.ProductDescription like '%CUSTOM INVESTIGATIVE: ARIZONA STATEWIDE SEARCH%' then 4.00
		     WHEN po.ProductDescription like '%CUSTOM INVESTIGATIVE: FAIRFAX COUNTY CRIMINAL%' then 3.00
		     WHEN po.ProductDescription like '%OFAC%' then .12
		     WHEN po.ProductDescription like '%Bankruptcy, Tax Liens and Judgment Search%' then 1.20
		     WHEN po.ProductDescription like '%FDA Disbarment Search%' then .25
		     WHEN po.ProductDescription like '%Crimwatch%' then 4.80

		ELSE null
		END
	WHEN 'Custom Verification'
	THEN
		CASE WHEN po.ProductDescription like '%I-9 Verification%' then .31 
		ELSE null
		END
	WHEN 'County Criminal Records Search'
	THEN
		CASE 
		     WHEN c.clientname like 'MGA%' then 5.00 
			 WHEN c.clientname like 'Galpin%' then 5.00 
		     WHEN po.ProductDescription like '%each over%7 year%' and po.ProductPrice >= 20 then 15.00 
			 WHEN po.ProductDescription like '%each over%10 year%' and po.ProductPrice >= 20 then 21.00 
			 WHEN po.ProductDescription like '%7 year%' then 6.00 
			 WHEN po.ProductDescription like '%10 year%' then 7.50 
			 WHEN (cp.BaseCommission is not null and cp.BaseCommission <> 0)  then cp.BaseCommission
		ELSE 
			6.00 
		END
	WHEN 'County Criminal Additional Search Discount'
	THEN
		CASE 
		     WHEN c.clientname like 'MGA%' then 5.00 
			 WHEN c.clientname like 'Galpin%' then 5.00 
		     WHEN po.ProductDescription like '%each over%7 year%' and po.ProductPrice <= -20 then 15.00 
			 WHEN po.ProductDescription like '%each over%10 year%' and po.ProductPrice <= -20 then 21.00 
			 WHEN po.ProductDescription like '%7 year%' then 6.00 
			 WHEN po.ProductDescription like '%10 year%' then 7.50
			 WHEN (cp.BaseCommission is not null and cp.BaseCommission <> 0)  then cp.BaseCommission 
		ELSE
			6.00 
		END
	WHEN 'County Criminal Combined Search Price'
	THEN
		CASE 
		     WHEN c.clientname like 'MGA%' then 5.00 
			 WHEN c.clientname like 'Galpin%' then 5.00 
		     WHEN po.ProductDescription like '%each over%7 year%' and po.ProductPrice >= 40 then 30.00 
			 WHEN po.ProductDescription like '%each over%10 year%' and po.ProductPrice >= 40 then 42.00 
			 WHEN po.ProductDescription like '%7 year%' then 12.00 
			 WHEN po.ProductDescription like '%10 year%' then 15.00 
		ELSE
			12.00 
		END
	WHEN 'County Criminal Search Alias Discount'
	THEN
		CASE 
		     WHEN c.clientname like 'MGA%' then 5.00 
			 WHEN c.clientname like 'Galpin%' then 5.00 
		     WHEN po.ProductDescription like '%each over%7 year%' and po.ProductPrice <= -20 then 15.00 
			 WHEN po.ProductDescription like '%each over%10 year%' and po.ProductPrice <= -20 then 21.00 
			 WHEN po.ProductDescription like '%7 year%' then 6.00 
			 WHEN po.ProductDescription like '%10 year%' then 7.50
			 WHEN (cp.BaseCommission is not null and cp.BaseCommission <> 0)  then cp.BaseCommission 
		ELSE
			6.00 
		END
	WHEN 'Experian Credit'
	THEN
		CASE 
		     WHEN po.ProductType in ('Employment', 'EMP', 'EXPERIAN', 'volunteer') then 2.40 
			 WHEN po.ProductType in ('tenant', 'TNT') then 1.39
			 WHEN po.ProductType in ('other') then 1.32
		ELSE null
		END
	WHEN 'EXPERIAN CREDIT - NO RECORD'
	THEN
		CASE 
		     WHEN po.ProductType in ('Employment', 'EMP', 'EXPERIAN', 'volunteer') then 2.40 
			 WHEN po.ProductType in ('tenant', 'TNT') then 1.39
			 WHEN po.ProductType in ('other') then 1.32
		ELSE null
		END
	WHEN 'EXPERIAN CREDIT REPORT'
	THEN
		CASE 
		     WHEN po.ProductType in ('Employment', 'EMP', 'EXPERIAN', 'volunteer') then 2.40 
			 WHEN po.ProductType in ('tenant', 'TNT') then 1.39
			 WHEN po.ProductType in ('other') then 1.32
		ELSE null
		END
	WHEN 'TransUnion Credit'
	THEN
		CASE 
		     WHEN po.ProductType in ('Employment', 'EMP', 'EXPERIAN', 'volunteer') then 6.00 
			 WHEN po.ProductType in ('tenant', 'TNT') then 1.39
			 WHEN po.ProductType in ('other') then 1.32
		ELSE null
		END
	WHEN 'OIG/GSA Excluded Parties Search'
	THEN
		CASE 
		     WHEN po.ProductDescription like '%Level 3%' then 6.00 
			 WHEN po.ProductDescription like '%Comprehensive%' then 2.50 
			 WHEN po.ProductDescription like '%OIG Medicare/Medicaid Sanction%' and po.productprice > 4 then 6.00
			 WHEN po.ProductDescription like '%OIG Medicare/Medicaid Sanction%' then 1.50
			 WHEN po.ProductDescription like '%Healthcare Sanctions%' then 1.5
		ELSE null
		END	
	WHEN 'OIG/GSA Excluded Parties Search Alias Discount'
	THEN
		CASE 
		     WHEN po.ProductDescription like '%Level 3%' then 6.00 
			 WHEN po.ProductDescription like '%Comprehensive%' then 2.50 
			 WHEN po.ProductDescription like '%OIG Medicare/Medicaid Sanction%' and po.productprice > 4 then 6.00
			 WHEN po.ProductDescription like '%OIG Medicare/Medicaid Sanction%' then 1.50
			 WHEN po.ProductDescription like '%Healthcare Sanctions Search%' then 1.5
		ELSE null
		END	
	WHEN 'OIG/GSA Excluded Parties Search Combined Search Price'
	THEN
		CASE 
		     WHEN po.ProductDescription like '%Level 3%' then 6.00 
			 WHEN po.ProductDescription like '%Comprehensive%' then 2.50 
			 WHEN po.ProductDescription like '%OIG Medicare/Medicaid Sanction%' and po.productprice > 4 then 6.00
			 WHEN po.ProductDescription like '%OIG Medicare/Medicaid Sanction%' then 1.50
			 WHEN po.ProductDescription like '%Healthcare Sanctions Search%' then 1.5
		ELSE null
		END	
	WHEN 'OIG/GSA Excluded Parties Search Fee'
	THEN
		CASE 
		     WHEN po.ProductDescription like '%Level 3%' then 6.00 
			 WHEN po.ProductDescription like '%Comprehensive%' then 2.50 
			 WHEN po.ProductDescription like '%OIG Medicare/Medicaid Sanction%' and po.productprice > 4 then 6.00
			 WHEN po.ProductDescription like '%OIG Medicare/Medicaid Sanction%' then 1.50
			 WHEN po.ProductDescription like '%Healthcare Sanctions Search%' then 1.5
		ELSE null
		END	
	WHEN 'Custom Drug Test'
	THEN
		CASE 
		     WHEN po.ProductDescription like '%eScreen%non-dot%5 panel%' then 26.40
		     WHEN po.ProductDescription like '%eScreen%%5 panel%non-dot%' then 26.40
		     WHEN po.ProductDescription like '%CONCENTRA%12 panel%' then 50.00
		     WHEN po.ProductDescription like '%9 panel%' then 26.40
		     WHEN po.ProductDescription like '%10 panel%' then 26.40
		     WHEN po.ProductDescription like '%5 panel%' then 26.40
		     WHEN po.ProductDescription like '%12 panel%' then 39.00
		     WHEN po.ProductDescription like '%Breath Alcohol Testing%' then 29.50
		ELSE null
		END	
	WHEN 'Drug Test'
	THEN
		CASE 
			 WHEN po.ProductDescription like '%eScreen%non-dot%5 panel%' then 26.40
		     WHEN po.ProductDescription like '%eScreen%%5 panel%non-dot%' then 26.40
		     WHEN po.ProductDescription like '%CONCENTRA%12 panel%' then 50.00
		     WHEN po.ProductDescription like '%9 panel%' then 26.40
		     WHEN po.ProductDescription like '%10 panel%' then 26.40
		     WHEN po.ProductDescription like '%5 panel%' then 26.40
		     WHEN po.ProductDescription like '%12 panel%' then 39.00
		     WHEN po.ProductDescription like '%Hair%' then 60.00
		ELSE null
		END	
	WHEN 'Substance Abuse Detection'
	THEN
		CASE 
			 WHEN po.ProductDescription like '%eScreen%non-dot%5 panel%' then 26.40
		     WHEN po.ProductDescription like '%eScreen%%5 panel%non-dot%' then 26.40
		     WHEN po.ProductDescription like '%CONCENTRA%12 panel%' then 50.00
		     WHEN po.ProductDescription like '%9panel%' then 26.40
		     WHEN po.ProductDescription like '%10panel%' then 26.40
		     WHEN po.ProductDescription like '%5panel%' then 26.40
		     WHEN po.ProductDescription like '%12panel%' then 39.00
		     WHEN po.ProductDescription like '%Hair%' then 60.00
		ELSE null
		END	
	WHEN 'Employment Product Package'
	THEN
		CASE 
			 WHEN c.clientname like 'Compassion%' and po.productdescription like '%Package A%' then 33.78
			 WHEN c.clientname like 'Compassion%' and po.productdescription like '%Package B%' then 32.34
			 WHEN c.clientname like 'Compassion%' and po.productdescription like '%Package C%' then 21.44

		ELSE null
		END	
	WHEN 'Other Charges'
	THEN
		CASE 
	         WHEN po.ProductDescription like '%9 panel drug%' then 26.40
		ELSE null
		END	
	WHEN 'Colorado Boxed Beef Company DOT Emp Verification Package'
	THEN
		CASE 
	         WHEN po.ProductDescription like '%PSP Crash%' then 12.00
		ELSE null
		END			
		

	

ELSE
p.BaseCommission
END as BaseCost,
case when Row_number() over (partition by po.filenum order by po.filenum, po.productdescription) <= 3 then .45 else 0 end as TransactionFee,
0 as TotalCost,
0 as Margin
from ProductsOnInvoice po
inner join Products p on p.ProductID = po.ProductID
inner join Invoices i on i.InvoiceID = po.InvoiceID
inner join ProductTransactions pt on pt.ProductTransactionID = po.ProductTransactionID
inner join clients c on c.clientid = pt.clientid
left join clientproducts cp on cp.clientid = c.clientid and cp.productid = p.productid
where i.VoidedOn is null
and po.FileNum in (select VendorOrderID from ApplicantOne_Train.dbo.VendS1Orders)
and po.ProductID <> 367
and po.VendorID = 2
and i.InvoiceDate = @InvoiceDate
and (salesrep is not null and SalesRep not in (
'bbyrd',
'BP/HOTL',
'bpenk',
'HOTLINK',
'HOUSE',
'JKOHO',
'JKOHO/EG',
'lhirs',
'ML/AP',
'MLIMB',
'PAYL',
'PAYLEASE',
'REYN',
'VAOA',
'sgonz'
)/*or salesrep is not null*/) -- need to make sure you backfill blank salesreps from the pembrooke file to make sure you pick up those drug tests. 

)

select SUM(isnull(margin, 0))
from 
(
select FileNum, Client, ClientName, SalesRep, convert(varchar, DateOrdered, 101) as DateOrdered,ProductDescription, ProductName, ProductType, ProductPrice, 
Case when ProductPrice < 0 then 0-BaseCost else BaseCost end as BaseCost, TransactionFee, 
(Case when ProductPrice < 0 then 0-BaseCost else BaseCost end) + TransactionFee as TotalCost,
ProductPrice - ((Case when ProductPrice < 0 then 0-BaseCost else BaseCost end) + TransactionFee) as Margin,
(ProductPrice - ((Case when ProductPrice < 0 then 0-BaseCost else BaseCost end) + TransactionFee)) * .25 as Commission
from commdetails
where (BaseCost > 0 or BaseCost is null)
and ProductDescription not like '%The work number%'
and ProductDescription not like '%charged%credit%card%'
and ProductDescription not like '%National Student Clearing%'
and ProductDescription not like '%pre%adverse%'
and ProductDescription not like '%Access Fee%'
and ClientName not like 'Sheehy%'
and (salesrep is null or salesrep <> 'RentTrack')
--order by BaseCost, ProductName
) ab



GO
