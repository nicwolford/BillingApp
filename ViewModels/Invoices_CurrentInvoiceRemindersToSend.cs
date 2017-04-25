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
    public class Invoices_CurrentInvoiceRemindersToSend
    {
        public Invoices_CurrentInvoiceRemindersToSend() 
        {
            this.Results = Invoices.CurrentInvoiceRemindersToSend();
        }
        public List<S1_Invoices_CurrentInvoiceRemindersToSendResult> Results { get; set; }
    }
}
