using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.DomainModels;

namespace ScreeningONE.ViewModels
{
    public class Invoices_Index
    {
        public List<SelectListItem> ClientsList;
        public string StartDate;
        public string EndDate;
    }
}
