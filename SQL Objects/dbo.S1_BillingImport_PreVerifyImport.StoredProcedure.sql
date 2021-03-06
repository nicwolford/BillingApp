/****** Object:  StoredProcedure [dbo].[S1_BillingImport_PreVerifyImport]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec S1_BillingImport_PreVerifyImport 2

CREATE PROCEDURE [dbo].[S1_BillingImport_PreVerifyImport]
(
	@vendorid int
)
AS
SET NOCOUNT ON;

BEGIN

	--10/1/2012 - EB - Split the if (@vendorid = 1 or @vendorid = 2) into two separate if's
	--The code was taking 2 seconds to run outside the SP, but 53 seconds inside the SP
	--This is due to how the execution plan optomizes for a constant vs. a variable (@vendorid)

	if (@vendorid = 1)
	BEGIN

	SELECT distinct 
	case when COUNT(ClientNumber) > 0 then min(ImportID) else null end as ImportID,
	case when COUNT(ClientNumber) > 0 then 101 else null end as ErrorCode,
	case when COUNT(ClientNumber) > 0 then 'Client not found.' else null end as ErrorMsg,
	0 as LineNumber,
	0 as FileNum,
	case when COUNT(ClientNumber) > 0 then 'Tazworks ClientID: ' + (case when 1 = 1 then ClientNumber else ClientNumberOrdered end) + ',  Client Name: ' + (case when 1 = 1 then ClientName else ClientNameOrdered end) else null end as ErrorDetail
	FROM TazworksImport
	WHERE ClientNumber not in (select distinct vendorclientnumber from ClientVendors where VendorID = 1 
								and ClientID in (select ClientID from Clients))
	GROUP BY ClientNumber, ClientName, ClientNumberOrdered, ClientNameOrdered

	UNION ALL
	
	SELECT 
	case when COUNT(TP.ProductDesc) > 0 then ImportID else null end as ImportID,
	case when COUNT(TP.ProductDesc) > 0 then 103 else null end as ErrorCode,
	case when COUNT(TP.ProductDesc) > 0 then 'Unmatched Product: ' + Convert(varchar, TP.Price) else null end as ErrorMsg,
	case when COUNT(TP.ProductDesc) > 0 then ImportID - (select MIN(ImportID) - 1 from TazworksImport) else null end as LineNumber,
	case when COUNT(TP.ProductDesc) > 0 then FileNum else null end as FileNum,
	case when COUNT(TP.ProductDesc) > 0 then 'Product Description: ' + TP.ProductDesc else null end as ErrorDetail
	FROM TazworksImport TP
	WHERE 0 = (SELECT count(productcode) FROM TazworksSearchList TS 
				WHERE (TP.ProductDesc like TS.SearchText + '%' and TS.MatchPriority<>999998) or (TS.MatchPriority=999998 AND TP.ProductDesc = TS.SearchText ))
	GROUP BY FileNum, TP.ProductDesc, ImportID, TP.Price

	UNION ALL
	
	SELECT 
	case when COUNT(TP.ProductDesc) > 0 then ImportID else null end as ImportID,
	case when COUNT(TP.ProductDesc) > 0 then 104 else null end as ErrorCode,
	case when COUNT(TP.ProductDesc) > 0 then 'Negative: ' + Convert(varchar, TP.Price) else null end as ErrorMsg,
	case when COUNT(TP.ProductDesc) > 0 then ImportID - (select MIN(ImportID) - 1 from TazworksImport) else null end as LineNumber,
	case when COUNT(TP.ProductDesc) > 0 then FileNum else null end as FileNum,
	case when COUNT(TP.ProductDesc) > 0 then 'Product Description: ' + TP.ProductDesc else null end as ErrorDetail
	FROM TazworksImport TP
	WHERE TP.Price < 0
	  AND (TP.ProductDesc not in (select searchtext from TazworksTempSearchList) AND TP.ImportID not in (select ImportID from TazworksTempSearchList) AND TP.ProductDesc not in (select searchtext from TazworksSearchList))
	  AND 0 < (select count(productcode) from TazworksSearchList TS 
							WHERE ((TP.ProductDesc like TS.SearchText + '%' and TS.MatchPriority not in (999999, 999998)) 
									or (TS.MatchPriority in (999999, 999998) AND TP.ProductDesc = TS.SearchText )) AND TS.ProductCode in ('CRD_CSTM','CSTM','DRG_CSTM','INV_CSTM','OTH_CSTM','REP_CSTM','VER_CSTM'))
	GROUP BY FileNum, TP.Price, TP.ProductDesc, ImportID

	UNION ALL	
	
	SELECT 
	case when COUNT(TP.Reference) > 0 then ImportID else null end as ImportID,
	case when COUNT(TP.Reference) > 0 then 105 else null end as ErrorCode,
	case when COUNT(TP.Reference) > 0 then 'Unmatched Reference: ' + TP.ClientName else null end as ErrorMsg,
	case when COUNT(TP.Reference) > 0 then ImportID - (select MIN(ImportID) - 1 from TazworksImport) else null end as LineNumber,
	case when COUNT(TP.Reference) > 0 then FileNum else null end as FileNum,
	case when COUNT(TP.Reference) > 0 then 'Reference: ' + TP.Reference else null end as ErrorDetail
	FROM TazworksImport TP
	WHERE TP.ClientNumber in (select vendorclientnumber from ClientVendors cv inner join Clients c on c.ClientID = cv.ClientID and c.ImportClientSplitMode = 1 and cv.VendorID = 1)
	  AND (TP.ProductDesc not in (select searchtext from TazworksTempSearchList) AND TP.ImportID not in (select ImportID from TazworksTempSearchList) AND TP.ProductDesc not in (select searchtext from TazworksSearchList))
	  AND 0 < (select count(productcode) from TazworksSearchList TS 
							WHERE ((TP.ProductDesc like TS.SearchText + '%' and TS.MatchPriority not in (999999, 999998)) 
									or (TS.MatchPriority in (999999, 999998) AND TP.ProductDesc = TS.SearchText )) AND TS.ProductCode in ('CRD_CSTM','CSTM','DRG_CSTM','INV_CSTM','OTH_CSTM','REP_CSTM','VER_CSTM'))
	  AND TP.Reference not in (select splittext from ImportClientSplit where FromClientID = (select ClientID from ClientVendors where VendorClientNumber = TP.ClientNumber and VendorID = @vendorid))
	GROUP BY FileNum, TP.ClientName, TP.Reference, ImportID

	END
	
	if (@vendorid = 2)
	BEGIN
	
	/*SELECT distinct 
	case when COUNT(ClientNumber) > 0 then min(ImportID) else null end as ImportID,
	case when COUNT(ClientNumber) > 0 then 101 else null end as ErrorCode,
	case when COUNT(ClientNumber) > 0 then 'Client not found.' else null end as ErrorMsg,
	0 as LineNumber,
	0 as FileNum,
	case when COUNT(ClientNumber) > 0 then 'Tazworks ClientID: ' + (case when 2 = 1 then ClientNumber else ClientNumberOrdered end) + ',  Client Name: ' + (case when 2 = 1 then ClientName else ClientNameOrdered end) else null end as ErrorDetail
	FROM TazworksImport
	WHERE ClientNumber not in (select distinct vendorclientnumber from ClientVendors where VendorID = 2 
								and ClientID in (select ClientID from Clients))
	GROUP BY ClientNumber, ClientName, ClientNumberOrdered, ClientNameOrdered
	*/
	declare @tmpClientNumber Table (
	clientnumber [varchar](255) Not Null,
	clientname [varchar](255) null
)

insert into @tmpClientNumber
select distinct clientnumber, ClientName
from TazworksImport
order by ClientNumber

SELECT  
	0 as ImportID,
	case when COUNT(ClientNumber) > 0 then 101 else null end as ErrorCode,
	case when COUNT(ClientNumber) > 0 then 'Client not found.' else null end as ErrorMsg,
	0 as LineNumber,
	0 as FileNum,
	case when COUNT(ClientNumber) > 0 then 'Tazworks ClientID: ' + (case when 2 = 1 then ClientNumber else ClientNumber end) + ',  Client Name: ' + (case when 2 = 1 then ClientName else ClientName end) else null end as ErrorDetail
	FROM @tmpClientNumber
	WHERE ClientNumber not in (select distinct vendorclientnumber from ClientVendors where VendorID = 2
								and ClientID in (select ClientID from Clients))
	GROUP BY ClientNumber, clientname--, ClientName, ClientNumberOrdered, ClientNameOrdered

	UNION ALL

	SELECT 
	case when COUNT(TP.ItemCode) > 0 then TP.ImportID else null end as ImportID,
	case when COUNT(TP.ItemCode) > 0 then 102 else null end as ErrorCode,
	case when COUNT(TP.ItemCode) > 0 then 'Unmatched Product: ' + Convert(varchar, TP.Price) else null end as ErrorMsg,
	case when COUNT(TP.ItemCode) > 0 then TP.ImportID - (select MIN(ImportID) - 1 from TazworksImport) else null end as LineNumber,
	case when COUNT(TP.ItemCode) > 0 then FileNum else null end as FileNum,
	case when COUNT(TP.ItemCode) > 0 then 'ItemCode: ' + TP.ItemCode else null end as ErrorDetail
	FROM TazworksImport TP
	WHERE 0 = (select count(P.ProductCode) from Products P 
				where left(TP.ItemCode, len(P.ProductCode)) = P.ProductCode 
				  AND LEN(P.ProductCode) = (select MAX(len(PL.ProductCode)) from Products PL where TP.ItemCode like PL.ProductCode + '%')
				  AND P.ProductID in (select ProductID from VendorProducts where VendorID = 2))
	GROUP BY TP.FileNum, TP.ItemCode, TP.ImportID, TP.Price
	
	UNION ALL
	
    SELECT 
	case when COUNT(TP.ItemCode) > 0 then TP.ImportID else null end as ImportID,
	case when COUNT(TP.ItemCode) > 0 then 104 else null end as ErrorCode,
	case when COUNT(TP.ItemCode) > 0 then 'Negative: ' + Convert(varchar, TP.Price) else null end as ErrorMsg,
	case when COUNT(TP.ItemCode) > 0 then TP.ImportID - (select MIN(ImportID) - 1 from TazworksImport) else null end as LineNumber,
	case when COUNT(TP.ItemCode) > 0 then FileNum else null end as FileNum,
	case when COUNT(TP.ItemCode) > 0 then 'Product Description: ' + TP.ProductDesc else null end as ErrorDetail
	FROM TazworksImport TP
	WHERE 0 < (select count(P.ProductCode) from Products P 
				where left(TP.ItemCode, len(P.ProductCode)) = P.ProductCode 
				  AND LEN(P.ProductCode) = (select MAX(len(PL.ProductCode)) from Products PL where TP.ItemCode like PL.ProductCode + '%')
				  AND P.ProductID in (select ProductID from VendorProducts where VendorID = 2)
				  AND P.ProductCode in ('CRD_CSTM','CSTM','DRG_CSTM','INV_CSTM','OTH_CSTM','REP_CSTM','VER_CSTM'))
	  AND (TP.ProductDesc not in (select searchtext from TazworksTempSearchList) AND TP.ImportID not in (select ImportID from TazworksTempSearchList) AND TP.ProductDesc not in (select searchtext from TazworksSearchList))
	  AND TP.Price < 0
	GROUP BY TP.FileNum, TP.Price, TP.ProductDesc, TP.ImportID

	END

	if (@vendorid = 4)
	BEGIN
	
	SELECT distinct 
	case when COUNT(TUSubscriberID) > 0 then min(ImportID) else null end as ImportID,
	case when COUNT(TUSubscriberID) > 0 then 101 else null end as ErrorCode,
	case when COUNT(TUSubscriberID) > 0 then 'Client not found.' else null end as ErrorMsg,
	0 as LineNumber,
	0 as FileNum,
	case when COUNT(TUSubscriberID) > 0 then 'TransUnion ClientID: ' + TUSubscriberID else null end as ErrorDetail
	FROM TransUnionImport
	WHERE TUSubscriberID not in (select distinct vendorclientnumber from ClientVendors where VendorID = @vendorid)
	GROUP BY TUSubscriberID  

	UNION ALL

	SELECT 
	case when COUNT(TU.ProductCode) > 0 then TU.ImportID else null end as ImportID,
	case when COUNT(TU.ProductCode) > 0 then 102 else null end as ErrorCode,
	case when COUNT(TU.ProductCode) > 0 then 'Unmatched Product' else null end as ErrorMsg,
	case when COUNT(TU.ProductCode) > 0 then TU.ImportID - (select MIN(ImportID) - 1 from TransUnionImport) else null end as LineNumber,
	0 as FileNum,
	case when COUNT(TU.ProductCode) > 0 then 'ProductCode: ' + TU.ProductCode else null end as ErrorDetail
	FROM TransUnionImport TU
	WHERE 0 = (select count(P.ProductCode) from Products P 
				where TU.ProductCode = P.ProductCode 
				  AND P.ProductID in (select ProductID from VendorProducts where VendorID = @vendorid))
      AND UserReference not like 'Taz%'
	GROUP BY TU.ProductCode, TU.ImportID
	
	END


	if (@vendorid = 5)
	
	BEGIN
	
	--Insert into a temp table
	SELECT distinct
	identity(int, 1, 1) as ImportID,
	case when COUNT(XP.XPProductCode) > 0 then 102 else null end as ErrorCode,
	case when COUNT(XP.XPProductCode) > 0 then 'New Product' else null end as ErrorMsg,
	0 as LineNumber,
	0 as FileNum,
	case when COUNT(XP.XPProductCode) > 0 then 'ProductCode: ' + XP.XPProductCode else null end as ErrorDetail
	INTO #experiannewproducts
	FROM ExperianImport XP
	WHERE 0 = (select count(P.ProductCode) from Products P 
				where XP.XPProductCode = P.ProductCode 
				  AND P.ProductID in (select ProductID from VendorProducts where VendorID = @vendorid))
	GROUP BY XP.XPProductCode
	
	
	SELECT distinct 
	case when COUNT(XPSubCode) > 0 then min(ImportID) else null end as ImportID,
	case when COUNT(XPSubCode) > 0 then 101 else null end as ErrorCode,
	case when COUNT(XPSubCode) > 0 then 'Client not found.' else null end as ErrorMsg,
	0 as LineNumber,
	0 as FileNum,
	case when COUNT(XPSubCode) > 0 then 'Experian ClientID: ' + XPSubCode else null end as ErrorDetail
	FROM ExperianImport
	WHERE XPSubCode not in (select distinct vendorclientnumber from ClientVendors where VendorID = @vendorid or VendorID = 3)
	GROUP BY XPSubCode  

	UNION ALL

	select * from #experiannewproducts
	
	END
		

	if (@vendorid = 8)
	BEGIN
	
	SELECT distinct 
	case when COUNT(CustomerNumber) > 0 then min(ImportID) else null end as ImportID,
	case when COUNT(CustomerNumber) > 0 then 101 else null end as ErrorCode,
	case when COUNT(CustomerNumber) > 0 then 'Client not found.' else null end as ErrorMsg,
	0 as LineNumber,
	0 as FileNum,
	case when COUNT(CustomerNumber) > 0 then 'eDrug ClientID: ' + CustomerNumber + LocationCode else null end as ErrorDetail
	FROM eDrugImport
	WHERE eDrugImport.CustomerNumber + eDrugImport.LocationCode not in (
				select distinct vendorclientnumber from ClientVendors where VendorID = @vendorid)
	  AND eDrugImport.CustomerNumber not in (select distinct vendorclientnumber from ClientVendors where VendorID = @vendorid) 
	  AND Comments like '%EDI%'
	  
	GROUP BY eDrugImport.CustomerNumber, eDrugImport.LocationCode

	UNION ALL

	SELECT 
	case when COUNT(ED.Product) > 0 then ED.ImportID else null end as ImportID,
	case when COUNT(ED.Product) > 0 then 102 else null end as ErrorCode,
	case when COUNT(ED.Product) > 0 then 'Unmatched Product' else null end as ErrorMsg,
	case when COUNT(ED.Product) > 0 then ED.ImportID - (select MIN(ImportID) - 1 from eDrugImport) else null end as LineNumber,
	0 as FileNum,
	case when COUNT(ED.Product) > 0 then 'ProductCode: ' + ED.Product else null end as ErrorDetail
	FROM eDrugImport ED
	WHERE 0 = (select count(P.ProductCode) from Products P 
				where ED.Product = P.ProductCode 
				  AND P.ProductID in (select ProductID from VendorProducts where VendorID = @vendorid))
	AND Comments like '%EDI%'
	GROUP BY ED.Product, ED.ImportID
	
	END

END





GO
