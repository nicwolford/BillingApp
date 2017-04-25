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
    public class Invoices_OverdueInvoiceRemindersToSend
    {
        public Invoices_OverdueInvoiceRemindersToSend() 
        {
            this.Results = Invoices.OverdueInvoiceRemindersToSend();
        }
        public List<S1_Invoices_OverdueInvoiceRemindersToSendResult> Results { get; set; }
    }
}
