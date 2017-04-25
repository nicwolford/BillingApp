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
    public class Invoices_CurrentInvoiceRemindersSent
    {
        public Invoices_CurrentInvoiceRemindersSent() 
        {
            this.Results = Invoices.CurrentInvoiceRemindersSent();
        }
        public List<S1_Invoices_CurrentInvoiceRemindersSentResult> Results { get; set; }
    }
}
