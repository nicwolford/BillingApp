using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ScreeningONE.DomainModels;

namespace ScreeningONE.ViewModels
{
    public class Invoices_Details
    {
        public int numberOfColumns;
        public Invoice invoice;
        public List<InvoiceLine> invoiceLines;
        public bool toPrint;
        public bool showToClient;
        public string InvoiceType { get; set; }
    }
}
