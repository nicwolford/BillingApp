using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ScreeningONE.ViewModels
{
    public class Invoices_Credit
    {
        public int InvoiceID;
        public DateTime InvoiceDate;
        public string PublicDescription;
        public string PrivateDescription;
        public decimal InvoiceAmount;
        public int BillingContactID;
        public int ClientID;
        public int RelatedInvoiceID;
        public int ModifyCreditID;
    }
}
