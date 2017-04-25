using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.DomainModels;

namespace ScreeningONE.ViewModels
{
    public class Invoices_InvoiceAndPaymentBalancer
    {
        public List<SelectListItem> ClientsSelectListItemList { get; set;}
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
    }
}
