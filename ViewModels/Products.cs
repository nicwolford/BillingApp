using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.DomainModels;

namespace ScreeningONE.ViewModels
{
    public class ViewModelProducts
    {
        public int ProductID { get; set; }
        public string ProductCode { get; set; }
        public string ProductName { get; set; }
        public Decimal BaseCost { get; set; }
        public Decimal BaseCommission { get; set; }
        public Int16 IncludeOnInvoice { get; set; }
        public Decimal Employment { get; set; }
        public Decimal Tenant { get; set; }
        public Decimal Business { get; set; }
        public Decimal Volunteer { get; set; }
        public Decimal Other { get; set; }
    }

    public class TazworksImportError
    {
        public int ImportID { get; set; }
        public string ProductName { get; set; }
        public string ProductType { get; set; }
        public string ItemCode { get; set; }
        public string ProductDesc { get; set; }
    }

    public class VendorProducts
    {
        public int productID { get; set; }
        public int vendorID { get; set; }
    }
}