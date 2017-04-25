using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.Models;

namespace ScreeningONE.DomainModels
{
    public class Products
    {
        //Returns a list of all products
        public static List<Product> GetProducts()
        {
            List<Product> products = new List<Product>();

            ProductsDataContext dc = new ProductsDataContext();
            var result = dc.S1_Products_GetProductList();

            foreach (var item in result)
            {
                Product newItem = new Product(item.ProductID, 0, "", item.ProductName, 0, 0, 0, "", 0);

                products.Add(newItem);
            }

            return products;
        }

        public ViewModels.TazworksImportError getTazworksImportError(int ImportID)
        {
            var dc = new BillingImportDataContext();

            var result = dc.S1_BillingImport_GetImportError(ImportID).SingleOrDefault();

            ViewModels.TazworksImportError err = new ViewModels.TazworksImportError();

            err.ImportID = ImportID;
            err.ItemCode = result.ItemCode;
            err.ProductDesc = result.ProductDesc;
            err.ProductName = result.ProductName;
            err.ProductType = result.ProductType;

            return err;
        }

        public static void fixTazworksImportError(ViewModels.TazworksImportError err)
        {
            var dc = new BillingImportDataContext();

            var result = dc.S1_BillingImport_FixImportError(err.ImportID, err.ProductName, err.ProductType, err.ItemCode, err.ProductDesc);
        }

        public static void AddProductToVendor(ViewModels.VendorProducts vp)
        {
            var dc = new VendorsDataContext();

            dc.S1_Vendors_AddProductToVendor(vp.vendorID, vp.productID);
        }

        public static int CreateProduct(ViewModels.ViewModelProducts p)
        {
            var dc = new ProductsDataContext();

            var result = dc.S1_Products_AddProduct(p.ProductCode, p.ProductName, Convert.ToDecimal(p.BaseCost), Convert.ToDecimal(p.BaseCommission), Convert.ToByte(p.IncludeOnInvoice), Convert.ToDecimal(p.Employment), Convert.ToDecimal(p.Tenant), Convert.ToDecimal(p.Business), Convert.ToDecimal(p.Volunteer), Convert.ToDecimal(p.Other)).SingleOrDefault();

            return Convert.ToInt32(result.productID);
        }

        //Returns a list of all products
        public static List<Product> GetProductsFromClient(int _ClientID)
        {
            List<Product> products = new List<Product>();

            ProductsDataContext dc = new ProductsDataContext();
            var result = dc.S1_Products_GetProductListFromClient(_ClientID);

            foreach (var item in result)
            {
                Product newItem = new Product(0, Convert.ToInt32(item.ClientProductsID), item.ProductCode, item.ProductName, Convert.ToInt32(item.IncludeOnInvoice), Convert.ToDecimal(item.SalesPrice), Convert.ToInt32(item.ImportsAtBaseOrSales), item.VendorName, Convert.ToInt32(item.VendorID));

                products.Add(newItem);
            }

            return products;
        }

        //Returns a list of all products for use in a dropdown
        public static List<SelectListItem> GetProductList()
        {
            List<SelectListItem> productList = new List<SelectListItem>();

            ProductsDataContext dc = new ProductsDataContext();
            var result = dc.S1_Products_GetProductList();

            foreach (var item in result)
            {
                SelectListItem newItem = new SelectListItem();
                newItem.Value = item.ProductID.ToString();
                newItem.Text = item.ProductName;

                productList.Add(newItem);
            }

            return productList;
        }

        //Returns a list of all products for use in a dropdown. Filter by Vendor.
        public static List<SelectListItem> GetProductListFromVendor(int _VendorID)
        {
            List<SelectListItem> productList = new List<SelectListItem>();

            ProductsDataContext dc = new ProductsDataContext();
            var result = dc.S1_Products_GetProductListFromVendor(_VendorID);

            foreach (var item in result)
            {
                SelectListItem newItem = new SelectListItem();
                newItem.Value = item.ProductID.ToString();
                newItem.Text = item.ProductName;

                productList.Add(newItem);
            }

            return productList;
        }

        //Returns a list of all products for use in a dropdown.  Filter by Client and Vendor
        public static List<SelectListItem> GetProductListFromClientAndVendor(int _ClientID, int _VendorID)
        {
            List<SelectListItem> productList = new List<SelectListItem>();

            ProductsDataContext dc = new ProductsDataContext();
            var result = dc.S1_Products_GetProductListFromClientAndVendor(_ClientID, _VendorID);

            foreach (var item in result)
            {
                SelectListItem newItem = new SelectListItem();
                newItem.Value = item.ProductID.ToString();
                newItem.Text = item.ProductName;

                productList.Add(newItem);
            }

            return productList;
        }


        //Update
        public static int UpdateClientProductInfo(int _ClientProductsID, decimal _SalesPrice, string _IncludeOnInvoice, string _ImportsAtBaseOrSales)
        {

            int includeoninvoice;
            bool importsatbaseorsales;

            switch (_IncludeOnInvoice)
            {
                case "Always": includeoninvoice = 0;
                    break;
                case "Non-Zero": includeoninvoice = 1;
                    break;
                case "Never": includeoninvoice = 2;
                    break;
                default: includeoninvoice = 1;
                    break;
            }

            if (_ImportsAtBaseOrSales == "Yes")
            {
                importsatbaseorsales = false;
            }
            else
            {
                importsatbaseorsales = true;
            }

            var dc = new ProductsDataContext();
            int result = dc.S1_Products_UpdateClientProductsInfo(_ClientProductsID, _SalesPrice, includeoninvoice, importsatbaseorsales);

            return result;
        }


        //INSERT
        public static int InsertClientProduct(int _ClientID, int _ProductID, int _VendorID)
        {

            var dc = new ProductsDataContext();
            int result = dc.S1_Products_InsertClientProduct(_ClientID, _ProductID, _VendorID);

            return result;
        }


    }

    public class Product
    {
        public int ProductID;
        public int ClientProductsID;
        public string ProductCode;
        public string ProductName;
        public int IncludeOnInvoice;
        public decimal SalesPrice;
        public int ImportsAtBaseOfSales;
        public string VendorName;
        public int VendorID;

        public Product()
        {
        }

        public Product(int _ProductID, int _ClientProductsID, string _ProductCode, string _ProductName, int _IncludeOnInvoice, decimal _SalesPrice, int _ImportsAtBaseOrSales, string _VendorName, int _VendorID)
        {
            ProductID = _ProductID;
            ClientProductsID = _ClientProductsID;
            ProductCode = _ProductCode;
            ProductName = _ProductName;
            IncludeOnInvoice = _IncludeOnInvoice;
            SalesPrice = _SalesPrice;
            ImportsAtBaseOfSales = _ImportsAtBaseOrSales;
            VendorName = _VendorName;
            VendorID = _VendorID;
        }
    }
}
