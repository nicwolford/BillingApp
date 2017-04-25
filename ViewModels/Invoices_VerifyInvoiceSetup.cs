using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.DomainModels;

namespace ScreeningONE.ViewModels
{
    public class Invoices_VerifyInvoiceSetup
    {
        public List<InvoiceVerifySetups> invoiceVerifySetups;
        public List<SelectListItem> referenceSplitContacts;
    }
}
