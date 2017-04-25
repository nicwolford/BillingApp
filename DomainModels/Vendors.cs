using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.Models;

namespace ScreeningONE.DomainModels
{
    public class Vendors
    {
        //Returns a list of all products for use in a dropdown
        public static List<SelectListItem> GetVendorList()
        {
            List<SelectListItem> vendorList = new List<SelectListItem>();

            VendorsDataContext dc = new VendorsDataContext();
            var result = dc.S1_Vendors_GetVendorList();

            foreach (var item in result)
            {
                SelectListItem newItem = new SelectListItem();
                newItem.Value = item.VendorID.ToString();
                newItem.Text = item.VendorName;

                vendorList.Add(newItem);
            }

            return vendorList;
        }
    }
}
