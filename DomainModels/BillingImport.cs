using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ScreeningONE.Models;
using ScreeningONE.ViewModels;

namespace ScreeningONE.DomainModels
{
    public static class BillingImport
    {

        public static int CreateImportBatch(BillingImport_Upload bd)
        {
            if (bd.VendorID > 0)
            {
                var db = new BillingImportDataContext();
                var result = db.S1_BillingImport_InsertImportBatch(bd.VendorID, bd.username, bd.importfilename).SingleOrDefault();

                if (result.ErrorCode == 0)
                {

                    return result.ImportBatchID.Value;
                }
                else
                {
                    return result.ErrorCode.Value;
                }
            }
            else
            {
                return -1;
            }

        }

        public static string UploadTazworks1Data(BillingImport_Upload bd)
        {
            if (bd.FileNum > 0)
            {
                var db = new BillingImportDataContext();
                var result = db.S1_BillingImport_UploadTazworksData(1, bd.FileNum, bd.ClientNumber, bd.ClientName, bd.SalesRep, bd.LName,
                                                        bd.FName, bd.MName, bd.SSN, null, null,
                                                        bd.OrderBy, bd.Reference, bd.DateOrdered, bd.ProductName, bd.ProductType,
                                                        null, bd.ProductDesc, bd.Price, bd.InvoiceNumber, null, null,bd.importbatchid, bd.CoLName, bd.CoFName, bd.CoSSN);

                return result.ToString();
            }
            else
            {
                return "-1";
            }

        }

        public static string UploadTazworks2Data(BillingImport_Upload bd)
        {
            if (bd.FileNum > 0)
            {
                var db = new BillingImportDataContext();
                var result = db.S1_BillingImport_UploadTazworksData(2, bd.FileNum, bd.ClientNumber, bd.ClientName, bd.SalesRep, bd.LName,
                                                        bd.FName, bd.MName, bd.SSN, bd.ClientNumberOrdered, bd.ClientNameOrdered,
                                                        bd.OrderBy, bd.Reference, bd.DateOrdered, bd.ProductName, bd.ProductType,
                                                        bd.ItemCode, bd.ProductDesc, bd.Price, bd.InvoiceNumber, null, null, bd.importbatchid, bd.CoLName, bd.CoFName, bd.CoSSN);

                return result.ToString();
            }
            else
            {
                return "-1";
            }

        }

        public static string ClearTazworksImportTable()
        {
            var db = new BillingImportDataContext();
            var result = db.S1_BillingImport_ClearTazworksImportTable();

            return result.ToString();

        }


        public static string UploadeDrugData(BillingImport_Upload bd)
        {
            if (bd.EDCustomerNumber != null)
            {
                var db = new BillingImportDataContext();
                var result = db.S1_BillingImport_UploadeDrugData(bd.importbatchid, bd.EDCustomerName, bd.EDCustomerNumber, bd.EDInvoiceNumber, bd.EDLocationCode,  
                                                            Convert.ToDateTime(bd.EDServiceDate), bd.EDProduct, bd.EDFee, bd.EDSSN, bd.EDEmployeeName, bd.EDCOCNumber, bd.EDSpecimenID,
                                                            bd.EDReason, bd.EDComments);

                return result.ToString();
            }
            else
            {
                return "-1";
            }

        }

        public static string CleareDrugImportTable()
        {
            var db = new BillingImportDataContext();
            var result = db.S1_BillingImport_CleareDrugImportTable();

            return result.ToString();

        }

        public static string UploadTransUnionData(BillingImport_Upload bd)
        {
            if (bd.TUSubscriberID != null)
            {
                var db = new BillingImportDataContext();
                var result = db.S1_BillingImport_UploadTransUnionData(bd.importbatchid, bd.TUSubscriberID, 
                                        Convert.ToDateTime(bd.TUInquiryDate), bd.TUInquiryTime, bd.TUECOA,
                                        bd.TUSurname, bd.TUFirstName, bd.TUAddress, bd.TUCity, bd.TUState, bd.TUZip, bd.TUSSN, bd.TUSpouseFirstName,
                                        bd.TUNetPrice, bd.TUMMSSTo, bd.TUTimeZone, bd.TUProductCode,
                                        Convert.ToChar(bd.TUProductType), Convert.ToChar(bd.TUHit), bd.TUUserReference);

                return result.ToString();
            }
            else
            {
                return "-1";
            }

        }

        public static string UploadExperianData(BillingImport_Upload bd)
        {
            if (bd.XPRequesterNo != null)
            {


                var db = new BillingImportDataContext();
                var result = db.S1_BillingImport_UploadExperianData(bd.importbatchid, bd.XPRequesterNo,
                                    Convert.ToChar(bd.XPRecordType), bd.XPMktPreamble, bd.XPAccPreamble, bd.XPSubcode, DateTime.ParseExact(bd.XPInquiryDate, "MMddyy", System.Globalization.CultureInfo.InvariantCulture), bd.XPInquiryTime,
                                    bd.XPLastName, bd.XPSecondLastName, bd.XPFirstName, bd.XPMiddleName, Convert.ToChar(bd.XPGenerationCode), bd.XPStreetNumber,
                                    bd.XPStreetName, bd.XPStreetSuffix, bd.XPCity, bd.XPUnitID, bd.XPState, bd.XPZipCode, bd.XPHitCode, bd.XPSSN, bd.XPOperatorID,
                                    Convert.ToChar(bd.XPDuplicateID), bd.XPStatementID, bd.XPInvoiceCodes, bd.XPProductCode, bd.XPProductPrice, bd.XPMKeyWord);

                return result.ToString();
            }
            else
            {
                return "-1";
            }

        }


        public static string UploadQBBillingSummaryData(BillingImport_Upload bd)
        {

            var db = new BillingImportDataContext();
            var result = db.S1_BillingImport_UploadQBBalanceSummaryData(bd.QBBillAsClientName, Convert.ToDecimal(bd.QBAmount));

            return result.ToString();


        }

        public static string ClearTUImportTable()
        {
            var db = new BillingImportDataContext();
            var result = db.S1_BillingImport_ClearTUImportTable();

            return result.ToString();

        }

        public static string ClearXPImportTable()
        {
            var db = new BillingImportDataContext();
            var result = db.S1_BillingImport_ClearXPImportTable();

            return result.ToString();

        }

        public static string ClearQBBalanceSummaryTable()
        {
            var db = new BillingImportDataContext();
            var result = db.S1_BillingImport_ClearQBBalanceSummaryTable();

            return result.ToString();

        }

        public static List<ScreeningONE.Models.S1_BillingImport_PreVerifyImportResult> GetImportErrors(int vendorid)
        {
            var db = new BillingImportDataContext();
            var result = db.S1_BillingImport_PreVerifyImport(vendorid);

            return result.ToList();
           
            
        }

        public static List<SelectListItem> GetProducts(int vendorid, int importid)
        {
            List<SelectListItem> productlist = new List<SelectListItem>();

            var dc = new BillingImportDataContext();
            var result = dc.S1_BillingImport_GetVendorProducts(vendorid, importid);
            foreach (var item in result)
            {
                if (item.ProductCode != null)
                {
                    SelectListItem listitem = new SelectListItem();
                    listitem.Value = item.ProductCode;
                    listitem.Text = item.ProductName;
                    productlist.Add(listitem);
                }
            }

            return productlist;
        }


        public static string InsertTazworks1SearchText(string productcode, string searchtext, string errorcode, bool ispermanentsearch, int importid)
        {
            if (productcode != null)
            {
                var db = new BillingImportDataContext();
                var result = db.S1_BillingImport_InsertTazworks1SearchText(productcode, searchtext, errorcode, ispermanentsearch, importid);

                return result.ToString();
            }
            else
            {
                return "-1";
            }

        }


        public static string UpdateTazworksImport(int importid, string productdesc)
        {
            if (importid != null)
            {
                var db = new BillingImportDataContext();
                var result = db.S1_BillingImport_UpdateTazworksImport(importid, productdesc);

                return result.ToString();
            }
            else
            {
                return "-1";
            }

        }

        public static string GetImportErrorDescription(int importid)
        {
            var db = new BillingImportDataContext();
            var result = db.S1_BillingImport_GetImportErrorDescription(importid).SingleOrDefault();

            if (result != null)
            {
                return result.ProductDesc;
            }
            else
            {
                return "-1";
            }            

        }

        public static List<ScreeningONE.Models.S1_BillingImport_GetImportAuditResultsResult> GetImportAuditResults(int vendorid)
        {
            var db = new BillingImportDataContext();
            var result = db.S1_BillingImport_GetImportAuditResults(vendorid);

            return result.ToList();
        }


        public static string ImportTazworksTransactions(int vendorid)
        {
            if (vendorid != 0)
            {
                var db = new BillingImportDataContext();
                db.CommandTimeout = 3000000;
                var result = db.S1_BillingImport_ImportTazworks(vendorid);

                return result.ToString();
            }
            else
            {
                return "-1";
            }

        }

        public static string ImporteDrugTransactions(int vendorid)
        {
            if (vendorid != 0)
            {
                var db = new BillingImportDataContext();
                db.CommandTimeout = 3000000;
                var result = db.S1_BillingImport_ImporteDrug(vendorid);

                return result.ToString();
            }
            else
            {
                return "-1";
            }

        }

        public static string ImportTransUnionTransactions(int vendorid)
        {
            if (vendorid != 0)
            {
                var db = new BillingImportDataContext();
                db.CommandTimeout = 3000000;
                var result = db.S1_BillingImport_ImportTransUnion(vendorid);

                return result.ToString();
            }
            else
            {
                return "-1";
            }

        }

        public static string UpdateTUSurcharges()
        {
            var db = new BillingImportDataContext();
            db.CommandTimeout = 3000000;
            var result = db.S1_BillingImport_UpdateTUSurcharges();

            return result.ToString();

        }


        public static string ImportExperianTransactions(int vendorid)
        {
            if (vendorid != 0)
            {
                var db = new BillingImportDataContext();
                db.CommandTimeout = 3000000;
                var result = db.S1_BillingImport_ImportExperian(vendorid);

                return result.ToString();
            }
            else
            {
                return "-1";
            }

        }

        public static string UpdateXPSurcharges()
        {
            var db = new BillingImportDataContext();
            db.CommandTimeout = 3000000;
            var result = db.S1_BillingImport_UpdateXPSurcharges();

            return result.ToString();

        }

        public static string UpdateTaz1SoftwareFees()
        {
            var db = new BillingImportDataContext();
            db.CommandTimeout = 3000000;
            var result = db.S1_BillingImport_UpdateTaz1SoftwareFee();

            return result.ToString();

        }

        public static string UpdateTaz2SoftwareFees()
        {
            var db = new BillingImportDataContext();
            db.CommandTimeout = 3000000;
            var result = db.S1_BillingImport_UpdateTaz2SoftwareFee();

            return result.ToString();

        }

        public static string UpdateTaz1StateMVRRecords()
        {
            var db = new BillingImportDataContext();
            db.CommandTimeout = 3000000;
            var result = db.S1_BillingImport_UpdateTaz1StateMVRRecords();

            return result.ToString();

        }

        public static string UpdateTaz1StateMVRAccessFees()
        {
            var db = new BillingImportDataContext();
            db.CommandTimeout = 3000000;
            var result = db.S1_BillingImport_UpdateTaz1StateMVRAccessFees();

            return result.ToString();

        }

        public static void UpdateTemp(bool? eDrugTempLoaded, bool? experianTempLoaded, bool? quickbooksTempLoaded, bool? tazWorksTempLoaded, bool? transUnionTempLoaded)
        {
            using (BillingImportDataContext dc = new BillingImportDataContext())
            {
                dc.S1_BillingImport_UpdateTemp(eDrugTempLoaded, experianTempLoaded, quickbooksTempLoaded, tazWorksTempLoaded, transUnionTempLoaded);
            }
        }

    }
}
