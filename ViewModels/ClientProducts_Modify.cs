using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.DomainModels;

namespace ScreeningONE.ViewModels
{
    public class ClientProducts_Modify
    {
        public int ProductID { get; set; }
        public string ProductName { get; set; }
        public int IncludeOnInvoice { get; set; }
        public decimal SalesPrice { get; set; }
        public int ImportsAtBaseOrSales { get; set; }
        public int ClientID { get; set; }
        public List<SelectListItem> ClientProductsList;
        public List<SelectListItem> ClientVendorsList;


        public ClientProducts_Modify()
        {

            ClientProductsList = new List<SelectListItem>();
            ClientVendorsList = new List<SelectListItem>();
        }

    }
}
