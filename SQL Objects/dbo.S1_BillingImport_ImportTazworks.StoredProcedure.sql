/****** Object:  StoredProcedure [dbo].[S1_BillingImport_ImportTazworks]    Script Date: 11/21/2016 9:27:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Exec S1_BillingImport_ImportTazworks 2

CREATE PROCEDURE [dbo].[S1_BillingImport_ImportTazworks]
(
	@vendorid int
)
AS
SET NOCOUNT ON;
Begin

	Declare @errorcode int
			
	Set @errorcode = 0

	if exists(select top 1 * 
			from ProductTransactions 
			where ImportBatchID in (
				select distinct importbatchid 
				from ImportBatch I 
				where I.ImportBatchFileName = 
					(select ImportBatchFileName from ImportBatch where ImportBatchID = (select distinct ImportBatchID from TazworksImport)))
	)
	BEGIN
		--Truncate Table TazworksTempSearchList
		set @errorcode = -2
		RETURN @errorcode
	END
	ELSE
	BEGIN
	
	BEGIN TRANSACTION

	if(@vendorid = 1) -- TAZWORKS 1.0 File
	BEGIN

		INSERT INTO ProductTransactions (ProductID, ClientID, VendorID, DateOrdered, TransactionDate, OrderBy, Reference, 
		FileNum, FName, LName, MName, SSN, ProductName, ProductDescription, ProductType, ProductPrice, ExternalInvoiceNumber, 
		SalesRep, CoLName, CoFName, CoSSN, ImportBatchID)
		SELECT ProductID, ClientID, VendorID, DateOrdered, (select top 1 convert(datetime, convert(varchar, month(dateadd(mm, -1, GETDATE()))) + '/01/' + convert(varchar, YEAR(dateadd(mm, -1, GETDATE()))))) as TransactionDate, 
    	case when A.OrderBy in (select shortname from InternalTazworksUsers) and not exists(Select TI.OrderBy from TazworksImport TI where TI.FileNum = A.FileNum and TI.OrderBy not in (select shortname from InternalTazworksUsers)) 
    	then 'ScreeningONE'
    	else (select max(orderby) from tazworksimport where tazworksimport.filenum = A.FileNum and tazworksimport.OrderBy not in (select shortname from InternalTazworksUsers))
        end as OrderBy,
		Reference, FileNum, FName, LName, MName, SSN, ProductName,
		ProductDesc,  ProductType, Price, ExternalInvoiceNumber, SalesRep, CoLName, CoFName, CoSSN, ImportBatchID
		from 
		( 
		select FileNum, FName, LName, TP.VendorID, MName, SSN, OrderBy, Reference, DateOrdered, CoLName, CoFName, CoSSN, ImportBatchID,
		ProductDesc, Price, TS.ProductCode, MatchPriority, 
			CASE WHEN TS.ProductCode = 'USE_PRODUCTTYPE' THEN 
			(SELECT CASE TP.ProductType 
					WHEN 'EMP' THEN (select productid from products where productcode = 'PCKG_EMPLOYMENT')
					WHEN 'employment' THEN (select productid from products where productcode = 'PCKG_EMPLOYMENT')
					WHEN 'TNT' THEN (select productid from products where productcode = 'PCKG_TENANT')
					WHEN 'tenant' THEN (select productid from products where productcode = 'PCKG_TENANT')
					WHEN 'VOL' THEN (select productid from products where productcode = 'PCKG_VOLUNTEER')
					WHEN 'volunteer' THEN (select productid from products where productcode = 'PCKG_VOLUNTEER')
					WHEN 'BUS' THEN (select productid from products where productcode = 'PCKG_BUSINESS')
					WHEN 'business' THEN (select productid from products where productcode = 'PCKG_BUSINESS')
					WHEN 'OTH' THEN (select productid from products where productcode = 'PCKG_OTHER')
					WHEN 'other' THEN (select productid from products where productcode = 'PCKG_OTHER')
					ELSE (select productid from products where productcode = 'PCKG_OTHER')
					END as ProductID) ELSE P.ProductID END as ProductID, 
			TP.ProductName, TP.ProductType, TP.SalesRep,InvoiceNumber as ExternalInvoiceNumber, CV.ClientID, 
			   max(TS.MatchPriority) over (partition by TP.ProductDesc) max_MatchPriority 
		from  TazworksImport TP
		INNER JOIN TazworksSearchList TS
			ON (TP.ProductDesc LIKE TS.SearchText + '%' and TS.MatchPriority not in (999999, 999998)) OR (TS.MatchPriority in (999999, 999998) AND TP.ProductDesc = TS.SearchText)
		LEFT JOIN Products P
			ON P.ProductCode=TS.ProductCode and P.ProductID in (select ProductID from VendorProducts where VendorID = 1)
		INNER JOIN ClientVendors CV
			ON CV.VendorClientNumber = TP.ClientNumber and CV.VendorID = TP.VendorID 
		INNER JOIN Clients C on C.ClientID = CV.ClientID
		WHERE TP.ImportID not in (select ImportID from TazworksTempSearchList)		
		
		UNION ALL
		
		select FileNum, FName, LName, TP.VendorID, MName, SSN, OrderBy, Reference, DateOrdered, CoLName, CoFName, CoSSN, ImportBatchID,
		ProductDesc, Price, TT.ProductCode, MatchPriority, 
			CASE WHEN TT.ProductCode = 'USE_PRODUCTTYPE' THEN 
			(SELECT CASE TP.ProductType 
					WHEN 'EMP' THEN (select productid from products where productcode = 'PCKG_EMPLOYMENT')
					WHEN 'employment' THEN (select productid from products where productcode = 'PCKG_EMPLOYMENT')
					WHEN 'TNT' THEN (select productid from products where productcode = 'PCKG_TENANT')
					WHEN 'tenant' THEN (select productid from products where productcode = 'PCKG_TENANT')
					WHEN 'VOL' THEN (select productid from products where productcode = 'PCKG_VOLUNTEER')
					WHEN 'volunteer' THEN (select productid from products where productcode = 'PCKG_VOLUNTEER')
					WHEN 'BUS' THEN (select productid from products where productcode = 'PCKG_BUSINESS')
					WHEN 'business' THEN (select productid from products where productcode = 'PCKG_BUSINESS')
					WHEN 'OTH' THEN (select productid from products where productcode = 'PCKG_OTHER')
					WHEN 'other' THEN (select productid from products where productcode = 'PCKG_OTHER')
					ELSE (select productid from products where productcode = 'PCKG_OTHER')
					END as ProductID) ELSE PT.ProductID END as ProductID, 
			TP.ProductName, TP.ProductType, TP.SalesRep,InvoiceNumber as ExternalInvoiceNumber, CV.ClientID, 
			   max(TT.MatchPriority) over (partition by TP.ProductDesc) max_MatchPriority 
		from  TazworksImport TP
		INNER JOIN TazworksTempSearchList TT
			ON TP.ImportID = TT.ImportID
		LEFT JOIN Products PT
			ON PT.ProductCode = TT.ProductCode and PT.ProductID in (select ProductID from VendorProducts where VendorID = 1)
		INNER JOIN ClientVendors CV
			ON CV.VendorClientNumber = TP.ClientNumber and CV.VendorID = TP.VendorID
		INNER JOIN Clients C on C.ClientID = CV.ClientID

		) A
		where A.MatchPriority = max_MatchPriority 
		ORDER BY FileNum, FName, LName, SSN, OrderBy, Reference, DateOrdered, 
		ProductDesc
		
	 
	END
	
	if(@vendorid = 2) -- TAZWORKS 2.0 file
	BEGIN
		INSERT INTO ProductTransactions (ProductID, ClientID, VendorID, DateOrdered, TransactionDate, OrderBy, Reference, 
		FileNum, FName, LName, MName, SSN, ProductName, ProductDescription, ProductType, ProductPrice, ExternalInvoiceNumber, 
		SalesRep, CoLName, CoFName, CoSSN, ImportBatchID)
		SELECT ProductID, ClientID, VendorID, DateOrdered, (select top 1 convert(datetime, convert(varchar, month(dateadd(mm, -1, GETDATE()))) + '/01/' + convert(varchar, YEAR(dateadd(mm, -1, GETDATE()))))) as TransactionDate, 
		case when A.OrderBy in (select shortname from InternalTazworksUsers) and not exists(Select TI.OrderBy from TazworksImport TI where TI.FileNum = A.FileNum and TI.OrderBy not in (select shortname from InternalTazworksUsers)) 
    	then 'ScreeningONE'
    	else (select max(orderby) from tazworksimport where tazworksimport.filenum = A.FileNum and tazworksimport.OrderBy not in (select shortname from InternalTazworksUsers))
        end as OrderBy,
		Reference, FileNum, FName, LName, MName, SSN, ProductName,
		/*Case When patindex('% - %', ProductDesc) = 0 Then ProductDesc Else right(ProductDesc, len(ProductDesc) - (patindex('% - %', ProductDesc) + 2)) End as*/ ProductDesc,
		ProductType, Price, ExternalInvoiceNumber, SalesRep, CoLName, CoFName, CoSSN, ImportBatchID
		from 
		( 
		select FileNum, FName, LName, TP.VendorID, MName, SSN, OrderBy, Reference, DateOrdered, CoLName, CoFName, CoSSN, ImportBatchID, 
		ProductDesc, Price, ProductID, TP.ItemCode, TP.ProductName, TP.ProductType, TP.SalesRep,InvoiceNumber as ExternalInvoiceNumber, CV.ClientID
		from  TazworksImport TP
		INNER JOIN Products P
			ON left(TP.ItemCode, len(P.ProductCode)) = P.ProductCode 
		  AND LEN(P.ProductCode) = (select MAX(len(PL.ProductCode)) from Products PL where TP.ItemCode like PL.ProductCode + '%') 
		  AND P.ProductID in (select ProductID from VendorProducts where VendorID = 2)
		INNER JOIN ClientVendors CV
			ON CV.VendorClientNumber = TP.ClientNumberOrdered and CV.VendorID = TP.VendorID
		WHERE TP.ImportID not in (select ImportID from TazworksTempSearchList)
		  --exclude items that are negative and have a description in the TazworksSearchList table 
		  AND (TP.Price >= 0 
				or (left(TP.ItemCode, len(P.ProductCode)) not in (select PP.ProductCode from Products PP 
						where left(TP.ItemCode, len(PP.ProductCode)) = PP.ProductCode 
						  AND LEN(PP.ProductCode) = (select MAX(len(PL.ProductCode)) from Products PL where TP.ItemCode like PL.ProductCode + '%')
						  AND PP.ProductID in (select ProductID from VendorProducts where VendorID = 2)
						  AND PP.ProductCode in ('CRD_CSTM','CSTM','DRG_CSTM','INV_CSTM','OTH_CSTM','REP_CSTM','VER_CSTM'))
				AND TP.ProductDesc not in (select searchtext from TazworksSearchList where MatchPriority = 999999))
				  
				)
		  
		
		UNION ALL --get the negatives that were temporarily mapped to other productcodes.
		
	
		select FileNum, FName, LName, TP.VendorID, MName, SSN, OrderBy, Reference, DateOrdered, CoLName, CoFName, CoSSN, ImportBatchID,
		ProductDesc, Price, ProductID, TP.ItemCode, TP.ProductName, TP.ProductType, TP.SalesRep,InvoiceNumber as ExternalInvoiceNumber, CV.ClientID
		from  TazworksImport TP
		INNER JOIN TazworksTempSearchList TT
			ON TP.ImportID = TT.ImportID
		INNER JOIN Products PP
			ON PP.ProductCode = TT.ProductCode and PP.ProductID in (select ProductID from VendorProducts where VendorID = 2)
		INNER JOIN ClientVendors CV
			ON CV.VendorClientNumber = TP.ClientNumberOrdered and CV.VendorID = TP.VendorID		
	
		UNION ALL --Get the negative transactions that were permanently remapped to other product codes
		
		select FileNum, FName, LName, TP.VendorID, MName, SSN, OrderBy, Reference, DateOrdered, CoLName, CoFName, CoSSN, ImportBatchID, 
		ProductDesc, Price, 
		(select ProductID from Products where ProductCode=TS.ProductCode and ProductID in (select ProductID from VendorProducts where VendorID = 2)) as ProductID, 
		TS.ProductCode, TP.ProductName, TP.ProductType, TP.SalesRep,InvoiceNumber as ExternalInvoiceNumber, CV.ClientID
		from  TazworksImport TP
	    INNER JOIN TazworksSearchList TS
  		    ON (TS.MatchPriority in (999999) AND TP.ProductDesc = TS.SearchText)
		INNER JOIN Products P
			ON left(TP.ItemCode, len(P.ProductCode)) = P.ProductCode 
		  AND LEN(P.ProductCode) = (select MAX(len(PL.ProductCode)) from Products PL where TP.ItemCode like PL.ProductCode + '%') 
		  AND P.ProductID in (select ProductID from VendorProducts where VendorID = 2)
		INNER JOIN ClientVendors CV
			ON CV.VendorClientNumber = TP.ClientNumberOrdered and CV.VendorID = TP.VendorID
		WHERE TP.ImportID not in (select ImportID from TazworksTempSearchList)
		  AND (TP.Price < 0 and left(TP.ItemCode, len(P.ProductCode)) in (select PP.ProductCode from Products PP 
				where left(TP.ItemCode, len(PP.ProductCode)) = PP.ProductCode 
				  AND LEN(PP.ProductCode) = (select MAX(len(PL.ProductCode)) from Products PL where TP.ItemCode like PL.ProductCode + '%')
				  AND PP.ProductID in (select ProductID from VendorProducts where VendorID = 2)
				  AND PP.ProductCode in ('CRD_CSTM','CSTM','DRG_CSTM','INV_CSTM','OTH_CSTM','REP_CSTM','VER_CSTM','SAD_SC'))
				)
	
		) A

		ORDER BY FileNum, FName, LName, SSN, OrderBy, Reference, DateOrdered, 
		ProductDesc
		
	END

	if(@@ERROR <> 0)
	Begin
		set @errorcode = -1
		Goto Cleanup
	End	
	Else
	Begin
	
		COMMIT TRANSACTION
		
		if (@vendorid = 1 or @vendorid = 2)
		BEGIN
			--re-assign any transactions for clients that have the ImportClientSplitMode = 1, Reference
			Update ProductTransactions
			set ClientID = a.Toclientid
			FROM
			(select P.ProductTransactionID, IC.ToClientID
			from
			ProductTransactions P
			INNER JOIN Clients C on P.ClientID = C.ClientID and C.ImportClientSplitMode = 1
			INNER JOIN ImportClientSplit IC on IC.FromClientID = C.ClientID and IC.SplitText = P.Reference
			where P.TransactionDate = (select top 1 convert(datetime, convert(varchar, month(dateadd(mm, -1, GETDATE()))) + '/01/' + convert(varchar, YEAR(dateadd(mm, -1, GETDATE()))))
)
			  and P.VendorID = @vendorid
			) a 
			where a.ProductTransactionID = ProductTransactions.ProductTransactionID
			
			--re-assign any transactions for clients that have the ImportClientSplitMode = 2, OrderBy
			Update ProductTransactions
			set ClientID = a.Toclientid
			FROM
			(select P.ProductTransactionID, IC.ToClientID
			from
			ProductTransactions P
			INNER JOIN Clients C on P.ClientID = C.ClientID and C.ImportClientSplitMode = 2
			INNER JOIN ImportClientSplit IC on IC.FromClientID = C.ClientID and IC.SplitText = P.OrderBy
			where P.TransactionDate = (select top 1 convert(datetime, convert(varchar, month(dateadd(mm, -1, GETDATE()))) + '/01/' + convert(varchar, YEAR(dateadd(mm, -1, GETDATE()))))
)
			  and P.VendorID = @vendorid
			) a 
			where a.ProductTransactionID = ProductTransactions.ProductTransactionID
			
			--Insert RentTrack Application Fee for RentTrack customers
			insert into ProductTransactions (ProductID, ClientID, VendorID, TransactionDate, DateOrdered, OrderBy, Reference, FileNum, FName, LName, MName, SSN, ProductName, ProductDescription, ProductType, ProductPrice, ExternalInvoiceNumber, SalesRep, CoLName, CoFName, CoMName, CoSSN, ImportBatchID, Invoiced)
			select cp.ProductID, ClientID, 9 as VendorID, 
			dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) as TransactionDate,
			dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) as DateOrdered,
			'' as OrderBy, 'RentTrack' as Reference, 'RT' + convert(varchar, GETDATE(), 101) as FileNum, 'Application' as FName, 'Fee' as LName, '' as MName,
			'' as SSN, p.ProductName, p.ProductName + ': $' + 
			CONVERT(varchar, cp.SalesPrice) + ' per applicant X ' +
			convert(varchar, (select count(distinct filenum) from producttransactions 
				where clientid = cp.clientid 
				and vendorid = 2 
				and transactiondate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
				) + 
				(select count(distinct filenum) from producttransactions 
				where clientid = cp.clientid 
				and vendorid = 2 
				and transactiondate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
				and CoLName <> ''
				)
				)  
			as ProductDescription, 'Tenant' as ProductType, 
			((select count(distinct filenum) from producttransactions 
				where clientid = cp.clientid 
				and vendorid = 2 
				and transactiondate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
				) + 
				(select count(distinct filenum) from producttransactions 
				where clientid = cp.clientid 
				and vendorid = 2 
				and transactiondate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
				and CoLName <> ''
				)) * cp.SalesPrice as ProductPrice,
			'' as ExternalInvoiceNumber, 'RentTrack' as SalesRep, '' as CoLName, '' as CoFName, '' as CoMName, '' as CoSSN, 
			(select top 1 importbatchid from TazworksImport) as ImportBatchID, 0 as Invoiced
			from ClientProducts cp
			inner join Products p on p.ProductID = cp.productid
			where cp.ProductID = 392
			and cp.ClientID in (
			select distinct clientid from producttransactions 
				where vendorid = 2 
				and transactiondate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
				and not exists (select ClientID from ProductTransactions where ClientID = cp.ClientID and ProductID = 392 and TransactionDate = dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))))
			)
			
			-- Update Diocese of Richmond...remove County fees from subaccounts and put in parent account
			update ProductTransactions
			set ClientID = 2018
			where ProductTransactionID in (
			select p.ProductTransactionID from ProductTransactions p
			inner join Clients c on c.ClientID = p.clientid
			where transactiondate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			and p.ClientID in (select ClientID from Clients where BillingGroup = 13 and ClientID <> 2018)
			and ProductID in (
			3,
			4,
			56,
			57,
			58
			)
)			

			--Ted Britt
			UPDATE ProductTransactions 
			SET ClientID=4557
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID=3464
			AND Reference IN ('chevy technician|Chevy', 'chevy car sales|Chevy', 'chevy service writer|Chevy', 'chevy internet sales|Chantilly')

			UPDATE ProductTransactions 
			SET ClientID=5480
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID=3464
			AND Reference IN ('quantico shiffler|Harley', 'quantico-bowles|Harley', 'quantico-fischer|Harley', 'quantico|Harley')		

			
			--Tampa YMCA
			UPDATE ProductTransactions 
			SET ClientID=1885
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('Bob Sierra Family YMCA', '14', 'BOB SIERRA', 'BS')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=1886
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('Brandon Family YMCA', 'BRANDON', '10', 'BR')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=1890
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('Camp Cristina YMCA', '15', 'CCR', 'CR')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=1891
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('Campo Family YMCA', 'CA', '23')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=1901
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('CC', '16', 'BGCC')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=1911
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('Child Care Services', 'CCS', 'CS', '18', 'YOUTH DEV', 'YOUTH DEVELPMENT', 'YD')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=1978
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('Community Initiatives Outreach YMCA')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=2009
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('DC', 'DADE CITY')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=2024
			WHERE TransactionDate Between '6/1/2016' and '6/30/2016' 
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('DT')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=2027
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('EP')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=2048
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('First Tee Program YMCA', 'TEE', 'FT', 'F TEE')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=2146
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('12', 'Interbay-Glover Family YMCA')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=2231
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('New Tampa Family YMCA', 'NT', '11')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=2237
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('Northwest Hillsborough County Family YMCA', '24', 'NORTHWEST', 'NW')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=2292
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('PC', 'Plant City Family YMCA')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=2628
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('WP', 'WPV')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=5720
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('South Tampa YMCA', 'ST', 'SOUTH TAMPA')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=6028
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('The Family Y at Big Bend Road')
			AND OrderBy='XML'

			UPDATE ProductTransactions 
			SET ClientID=6029
			WHERE TransactionDate between dateadd(m, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate()))) and dateadd(d, -1, convert(varchar, MONTH(getdate())) + '/01/' + convert(varchar, YEAR(getdate())))
			AND ClientID IN (SELECT ClientID FROM dbo.fnAllSubClients(2595))
			AND Reference IN ('FH', '28')
			AND OrderBy='XML'



			
		END
		
		Update ImportBatch set ImportSuccess = 1 where ImportBatchID = (select distinct ImportBatchID from TazworksImport)
		
		Exec S1_BillingImport_UpdateNewClientTazworksProducts
		
		--Truncate Table TazworksTempSearchList
		if (@vendorid = 2)
		BEGIN 
			Exec S1_BillingImport_UpdateTaz2StateMVRAccessFees		
		END
		
		Return @errorcode
	End	
	
	

	
Cleanup:

    BEGIN
    	ROLLBACK TRANSACTION
		Update ImportBatch set ImportSuccess = 0 where ImportBatchID = (select distinct ImportBatchID from TazworksImport)
		--Truncate Table TazworksTempSearchList
    END

    RETURN @errorcode
	END
End






GO
