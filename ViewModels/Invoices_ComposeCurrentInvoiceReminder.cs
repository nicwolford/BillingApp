using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.DomainModels;
using ScreeningONE.Objects;

namespace ScreeningONE.ViewModels
{
    public class Invoices_ComposeCurrentInvoiceReminder
    {
        public Invoices_ComposeCurrentInvoiceReminder() 
        {
            DateTime nPlease = DateTime.Now;
            var invoiceDate = new DateTime(nPlease.Year, nPlease.Month, 1);

            Dictionary<string, string> messagevalues = new Dictionary<string, string>();
            messagevalues.Add("[[CORPORATENAME]]", System.Configuration.ConfigurationManager.AppSettings["CompanyName"]);
            messagevalues.Add("[[CORPORATEPHONE]]", System.Configuration.ConfigurationManager.AppSettings["billingphone"]);
            messagevalues.Add("[[CORPORATEEMAIL]]", System.Configuration.ConfigurationManager.AppSettings["BillingEmail"]);

            messagevalues.Add("[[INVOICEDATE]]", HttpUtility.HtmlEncode(invoiceDate.ToString("MM.dd.yyyy")));
            this.Message = ScreeningONESendMail.GetMessageTemplate(0, "Invoice Email Reminder", messagevalues);
            this.Subject = "Invoice Reminder";
        }
        public string Subject { get; set; }
        public string Message { get; set; }
    }
}
