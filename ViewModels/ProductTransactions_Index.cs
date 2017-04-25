using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace ScreeningONE.ViewModels
{
    public class ProductTransactions_Index
    {
        public string StartDate;
        public string EndDate;
        public List<SelectListItem> ClientsList;
        public List<SelectListItem> BillingGroups;
        public List<SelectListItem> ClientsListBySplitMode;
    }
}
