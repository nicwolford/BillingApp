using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.DomainModels;
using ScreeningONE.Models;
using ScreeningONE.Objects;

namespace ScreeningONE.ViewModels
{
    public class Invoices_OverdueInvoiceRemindersSent
    {
        public Invoices_OverdueInvoiceRemindersSent() 
        {
            this.Results = Invoices.OverdueInvoiceRemindersSent();
        }
        public List<S1_Invoices_OverdueInvoiceRemindersSentResult> Results { get; set; }
    }
}
