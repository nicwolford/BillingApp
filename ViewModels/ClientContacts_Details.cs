using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.DomainModels;

namespace ScreeningONE.ViewModels
{
    public class ClientContacts_Details
    {
        //Client Contact
        public int ClientContactID { get; set; }
        public string ClientContactFirstName { get; set; } 
        public string ClientContactLastName {get; set; }
        public string ClientContactTitle { get; set; }
        public string ClientContactAddress1 { get; set; }
        public string ClientContactAddress2 { get; set; }
        public string ClientContactCity { get; set; }
        public string ClientContactStateCode { get; set; }
        public string ClientContactZIP { get; set; }
        public string ClientContactBusinessPhone { get; set; }
        public string ClientContactCellPhone { get; set; }
        public string ClientContactFax { get; set; }
        public string ClientContactEmail { get; set; }
        public bool ClientContactStatus { get; set; }
        
        
        //Billing Contact
        public string DeliveryMethod { get; set; }
        public string DeliveryMethodVal { get; set; }
        public string BillingContactName { get; set; }
        public string BillingContactAddress1 {get; set; }
        public string BillingContactAddress2 { get; set; }
        public string BillingContactCity { get; set; }
        public string BillingContactStateCode { get; set; }
        public string BillingContactZIP { get; set; }
        public string BillingContactBusinessPhone { get; set; }
        public string BillingContactFax { get; set; }
        public string BillingContactEmail { get; set; }
        public string BillingContactPOName { get; set; }
        public string BillingContactPONumber { get; set; }
        public string BillingContactNotes { get; set; }
        public bool IsPrimaryBillingContact { get; set; }
        public bool OnlyShowInvoices { get; set; }
        public bool BillingContactStatus { get; set; }
        public int BillingContactID { get; set; }
        public int NewPrimaryContactID { get; set; }
        public string NewPrimaryContactName { get; set; }
        
        //Other fields
        public int ClientID { get; set; }
        public int UserID { get; set; }
        public bool IsBillingContact { get; set; }
        public string LastLoginDate { get; set; }
        public string cmdType { get; set; }


    }
}
