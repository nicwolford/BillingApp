using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.Models;

namespace ScreeningONE.ViewModels
{
    public class BillingImport_Upload
    {
        //General
        public List<ScreeningONE.Models.S1_BillingImport_PreVerifyImportResult> importerrorlist;
        public List<ScreeningONE.Models.S1_BillingImport_GetImportAuditResultsResult> importauditlist;
        public List<SelectListItem> productlist;
        public int ImportID { get; set; }
        public decimal totalprice { get; set; }
        public int totalrecords { get; set; }
        public string username { get; set; }
        public string importfilename { get; set; }
        public int importbatchid { get; set; }
        public string errorcode { get; set; }

        //Tazworks 1.0 and 2.0 formats
        public int VendorID {get; set;}
        public int FileNum { get; set; }
        public string ClientNumber { get; set; }
        public string ClientName { get; set; }
        public string SalesRep { get; set; }
        public string LName { get; set; }
        public string FName { get; set; }
        public string MName { get; set; }
        public string SSN { get; set; }
        public string ClientNumberOrdered { get; set; }
        public string ClientNameOrdered { get; set; }
        public string OrderBy { get; set; }
        public string Reference { get; set; }
        public string DateOrdered { get; set; }
        public string ProductName { get; set; }
        public string ProductType { get; set; }
        public string ItemCode { get; set; }
        public string ProductDesc { get; set; }
        public decimal Price { get; set; }
        public string Tax { get; set; }
        public string InvoiceNumber { get; set; }
        public string Jurisdiction { get; set; }
        public string ItemDescription { get; set; }
        public string CoLName { get; set; }
        public string CoFName { get; set; }
        public string CoSSN { get; set; }


        //TransUnion format
        public string TUSubscriberID { get; set; }
        public string TUInquiryDate { get; set; }
        public string TUInquiryTime { get; set; } 
	    public string TUECOA { get; set; } 
	    public string TUSurname { get; set; } 
	    public string TUFirstName { get; set; } 
	    public string TUAddress { get; set; } 
	    public string TUCity { get; set; } 
	    public string TUState { get; set; } 
	    public string TUZip { get; set; } 
	    public string TUSSN { get; set; } 
	    public string TUSpouseFirstName { get; set; }  
	    public decimal TUNetPrice  { get; set; } 
	    public string TUMMSSTo  { get; set; }  
	    public string TUTimeZone { get; set; } 
	    public string TUProductCode { get; set; }  
	    public string TUProductType { get; set; }  
	    public string TUHit { get; set; }  
	    public string TUUserReference { get; set; } 
        
        // Experian Format
        public string XPRequesterNo { get; set; } 
        public string XPRecordType { get; set; } 
        public string XPMktPreamble { get; set; } 
        public string XPAccPreamble { get; set; } 
        public string XPSubcode { get; set; } 
        public string XPInquiryDate { get; set; } 
        public string XPInquiryTime { get; set; } 
        public string XPLastName { get; set; } 
        public string XPSecondLastName { get; set; } 
        public string XPFirstName { get; set; } 
        public string XPMiddleName { get; set; } 
        public string XPGenerationCode { get; set; } 
        public string XPStreetNumber { get; set; } 
        public string XPStreetName { get; set; } 
        public string XPStreetSuffix { get; set; } 
        public string XPCity { get; set; } 
        public string XPUnitID { get; set; } 
        public string XPState { get; set; } 
        public string XPZipCode { get; set; } 
        public string XPHitCode { get; set; } 
        public string XPSSN { get; set; } 
        public string XPOperatorID { get; set; } 
        public string XPDuplicateID { get; set; } 
        public string XPStatementID { get; set; } 
        public string XPInvoiceCodes { get; set; } 
        public string XPProductCode { get; set; } 
        public decimal XPProductPrice { get; set; }
        public string XPMKeyWord { get; set; } 


        //eDrug Import
        public string EDCustomerName { get; set; }
        public string EDCustomerNumber { get; set; }
        public string EDInvoiceNumber { get; set; }
        public string EDLocationCode { get; set; }
        public string EDServiceDate { get; set; }
        public string EDProduct { get; set; }
        public decimal EDFee { get; set; }
        public string EDSSN { get; set; }
        public string EDEmployeeName { get; set; }
        public string EDCOCNumber { get; set; }
        public string EDSpecimenID { get; set; }
        public string EDReason { get; set; }
        public string EDComments { get; set; }

        //Quickbooks Balance Summary
        public string QBBillAsClientName { get; set; }
        public decimal QBAmount { get; set; }
        
        public BillingImport_Upload()
        {
            importerrorlist = new List<ScreeningONE.Models.S1_BillingImport_PreVerifyImportResult>();
            importauditlist = new List<ScreeningONE.Models.S1_BillingImport_GetImportAuditResultsResult>();
            productlist = new List<SelectListItem>();
    
        }

    }
}
