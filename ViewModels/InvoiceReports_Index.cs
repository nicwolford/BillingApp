using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ScreeningONE.DomainModels;

namespace ScreeningONE.ViewModels
{
    public class InvoiceReports_Index
    {
        public InvoiceReports invoicereport;
        public List<InvoiceReportRow> invoicerptlist;
        public bool toPrint;
        public int GroupID;
        public int InvoiceID;
        public bool ClientView;

    }
}
