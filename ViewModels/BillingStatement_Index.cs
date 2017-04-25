using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ScreeningONE.DomainModels;

namespace ScreeningONE.ViewModels
{
    public class BillingStatement_Index
    {
        public BillingStatement BillingStatement;
        public DateTime StatementDate;
        public int BillingContactID;
        public bool ClientView;
        public bool toPrint;

        public BillingStatement_Index()
        {

        }
    }
}
