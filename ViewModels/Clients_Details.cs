using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.DomainModels;

namespace ScreeningONE.ViewModels
{
    public class Clients_Details
    {
        public string ClientName { get; set; }
        public string Address1 { get; set; }
        public string Address2 { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string Zip { get; set; }
        public string Status { get; set; }
        public bool DoNotInvoice { get; set; }
        public bool AuditInvoices { get; set; }
        public int ClientID { get; set; }
        public int HasClientInvoiceSettings { get; set; }
        public int InvoiceTemplate { get; set; }
        public int BillingDetailReport { get; set; }
        public int ClientSplitMode { get; set; }
        public int ParentClientID { get; set; }
        public string ParentClientName { get; set; }
        public bool HasVendorSettings { get; set; }
        public string Tazworks1ID { get; set; }
        public string Tazworks2ID { get; set; }
        public string Debtor1ID { get; set; }
        public string TransUnionID { get; set; }
        public string ExperianID { get; set; }
        public string BilledAsClientName { get; set; }
        public bool ApplyFinanceCharge { get; set; }
        public int FinanceChargeDays { get; set; }
        public decimal FinanceChargePercent { get; set; }
        public bool SentToCollections { get; set; }
        public bool Tazworks1Client { get; set; }
        public bool Tazworks2Client { get; set; }
        public bool NonTazworksClient { get; set; }
        public List<SelectListItem> clientlist;
        public AccountActivity AccountActivity;
        public int BillingContactID { get; set; }
        public string BillingGroupID { get; set; }
        public string PembrookeID { get; set; }
        public string ApplicantONEID { get; set; }
        public string RentTrackID { get; set; }
        public string Notes { get; set; }
        public bool ExcludeFromReminders { get; set; }
        public string ExpectedMonthlyRevenue { get; set; }
        public string AccountCreateDate { get; set; }
        public string AccountOwner { get; set; }
        public string AffiliateName { get; set; }

        public Clients_Details()
        {
            clientlist = new List<SelectListItem>();
        }

    }
}
