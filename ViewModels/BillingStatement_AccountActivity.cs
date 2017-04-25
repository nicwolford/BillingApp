using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.DomainModels;

namespace ScreeningONE.ViewModels
{
    public class BillingStatement_AccountActivity
    {
        public AccountActivity AccountActivity;
        public BillingStatement BillingStatement;
        public List<SelectListItem> BillingContacts;
        public List<BillingStatement> BillingSatementList;
        public int UserID;
        public int BillingContactID;
        public bool InvoiceOnly;
        public DateTime StatementDate;
        public bool IsPrimaryContact;

        public BillingStatement_AccountActivity()
        {

        }
    }
}
