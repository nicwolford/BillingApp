using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.DomainModels;
using ScreeningONE.Objects;
using System.Configuration;

namespace ScreeningONE.ViewModels
{
    public class Invoices_ComposeOverdueInvoiceReminder
    {
        public Invoices_ComposeOverdueInvoiceReminder() 
        {
            Dictionary<string, string> messagevalues = new Dictionary<string, string>();
            messagevalues.Add("[[CORPORATENAME]]", System.Configuration.ConfigurationManager.AppSettings["CompanyName"]);
            messagevalues.Add("[[CORPORATEPHONE]]", System.Configuration.ConfigurationManager.AppSettings["billingphone"]);
            this.Message = ScreeningONESendMail.GetMessageTemplate(0, "Finance Charge Assessment", messagevalues);
            this.Subject = ConfigurationManager.AppSettings["CompanyName"] + " Payment Reminder";
            DateTime nPlease = DateTime.Now;
            this.UserFinanceChargeDate = new DateTime?(new DateTime(nPlease.Year, nPlease.Month, 1));
            this.UserFinanceChargeDate = new DateTime?(this.UserFinanceChargeDate.Value.AddMonths(1));
            this.UserFinanceChargeDate = new DateTime?(new DateTime(this.UserFinanceChargeDate.Value.Year, this.UserFinanceChargeDate.Value.Month, 1));
        }

        public string Subject { get; set; }
        public string Message { get; set; }
        public DateTime? UserFinanceChargeDate { get; set; }
    }
}
