using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ScreeningONE.DomainModels;
using StringExtensions;

namespace ScreeningONE.Controllers
{
    public class ProductsController : S1BaseController
    {
        //
        // GET: /Products/

        public ActionResult Index()
        {
            return View();
        }
        
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [HttpPost]
        public JsonResult GetProductsForDropdownJSON()
        {
            List<SelectListItem> products = Products.GetProductList();

            var rows = products.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [HttpPost]
        public JsonResult GetProductsFromClientAndVendorForDropdownJSON(int ClientID, int VendorID)
        {
            List<SelectListItem> products = Products.GetProductListFromClientAndVendor(ClientID, VendorID);

            var rows = products.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult AddProduct()
        {

            ViewModels.ViewModelProducts products = new ViewModels.ViewModelProducts();

            products.BaseCommission = 0.00m;
            products.BaseCost = 0.00m;
            products.Business = 0.00m;
            products.Employment = 0.00m;
            products.IncludeOnInvoice = 0;
            products.Other = 0.00m;
            products.ProductCode = string.Empty;
            products.ProductID = 0;
            products.ProductName = string.Empty;
            products.Tenant = 0.00m;
            products.Volunteer = 0.00m;

            return View(products);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult TazworksErrorFix(int id)
        {
            Products _products = new Products();

            ViewModels.TazworksImportError err = _products.getTazworksImportError(id);

            return View(err);
        }

        [ScreeningONEAuthorize(Portal="Admin", Roles="Admin")]
        public JsonResult FixImportError(int ImportID, string ProductName, string ProductType, string ItemCode, string ProductDesc)
        {
            ViewModels.TazworksImportError err = new ViewModels.TazworksImportError();

            err.ImportID = ImportID;
            err.ItemCode = ItemCode;
            err.ProductDesc = ProductDesc;
            err.ProductName = ProductName;
            err.ProductType = ProductType;

            Products.fixTazworksImportError(err);

            return new JsonResult
            {
                Data = new
                {
                    success = true
                }
            };
        }

        [ScreeningONEAuthorize(Portal="Admin", Roles="Admin")]
        public JsonResult AddVendorToProduct(int productID, int vendorID)
        {
            ViewModels.VendorProducts vp = new ViewModels.VendorProducts();

            vp.productID = productID;
            vp.vendorID = vendorID;

            Products.AddProductToVendor(vp);

            return new JsonResult
            {
                Data = new
                {
                    success = true,
                }
            };
        }

        /// <summary>
        /// Adds the product JSON.
        /// </summary>
        /// <param name="ProductCode">The product code.</param>
        /// <param name="ProductName">Name of the product.</param>
        /// <param name="BaseCost">The base cost.</param>
        /// <param name="BaseCommission">The base commission.</param>
        /// <param name="IncludeOnInvoice">The include on invoice.</param>
        /// <param name="Employment">The employment.</param>
        /// <param name="Tenant">The tenant.</param>
        /// <param name="Business">The business.</param>
        /// <param name="Volunteer">The volunteer.</param>
        /// <param name="Other">The other.</param>
        /// <returns></returns>
        [ScreeningONEAuthorize(Portal="Admin", Roles="Admin")]
        public JsonResult AddProductJSON(string ProductCode, string ProductName, Decimal BaseCost, Decimal BaseCommission, Int16 IncludeOnInvoice, Decimal Employment, Decimal Tenant, Decimal Business, Decimal Volunteer, Decimal Other)
        {
            ViewModels.ViewModelProducts p = new ViewModels.ViewModelProducts();

            p.BaseCommission = BaseCommission;
            p.BaseCost = BaseCost;
            p.Business = Business;
            p.Employment = Employment;
            p.IncludeOnInvoice = IncludeOnInvoice;
            p.Other = Other;
            p.ProductCode = ProductCode;
            p.ProductName = ProductName;
            p.Tenant = Tenant;
            p.Volunteer = Volunteer;

            if (string.IsNullOrEmpty(ProductCode))
            {
                ViewData.ModelState.AddModelError("ProductCode", " ");
                p.ProductCode = string.Empty;
            }

            if (string.IsNullOrEmpty(ProductName))
            {
                ViewData.ModelState.AddModelError("ProductName", " ");
                p.ProductName = string.Empty;
            }

            if (ViewData.ModelState.IsValid)
            {
                // enter the data
                p.ProductID = Products.CreateProduct(p);

                return new JsonResult
                {
                    Data = new
                    {
                        success = true,
                        productid = p.ProductID
                    }
                };
            }
            else
            {
                return new JsonResult
                {
                    Data = new
                    {
                        success = false,
                        productid = 0
                    }
                };
            }
        }

    }
}
