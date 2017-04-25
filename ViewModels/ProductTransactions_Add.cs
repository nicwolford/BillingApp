using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace ScreeningONE.ViewModels
{
    public class ProductTransactions_Add
    {
        public List<SelectListItem> selectListClients;
        public List<SelectListItem> selectListVendors;
        public List<SelectListItem> selectListProducts;
        public DateTime TransactionDate;
    }
}
