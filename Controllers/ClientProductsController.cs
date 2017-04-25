using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ScreeningONE.Objects;
using ScreeningONE.ViewModels;
using ScreeningONE.DomainModels;

namespace ScreeningONE.Controllers
{
    public class ClientProductsController : S1BaseController
    {

        public ActionResult Index()
        {
            return View();
        }


        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult ProductsFromClientJSON(int ClientID, FormCollection fc)
        {
            int ID = Convert.ToInt32(fc["id"]);
            string FieldToSort = fc["sidx"];
            string strSortOrder = fc["sord"];
            SortDirection SortOrder;

            if (FieldToSort == "id" || FieldToSort == "Action")
            {
                FieldToSort = "ProductName";
            }

            if (strSortOrder == "desc")
                SortOrder = SortDirection.Descending;
            else
                SortOrder = SortDirection.Ascending;

            int RowsPerPage = Convert.ToInt32(fc["rows"]);
            int CurrentPage = Convert.ToInt32(fc["page"]);
            int StartRow = ((CurrentPage - 1) * RowsPerPage) + 1;
            int EndRow = StartRow + RowsPerPage - 1;

            var result = Products.GetProductsFromClient(ClientID);

            Array rows = (from question in result.Order(FieldToSort, SortOrder)
                          select new
                          {
                              i = question.ProductID,
                              cell = new string[] { question.ClientProductsID.ToString(), 
                                    question.ProductCode,
                                    question.ProductName,
                                    question.SalesPrice.ToString("#,##0.00"),
                                    (question.IncludeOnInvoice.ToString() == "0" ? "Always" : (question.IncludeOnInvoice.ToString() == "1" ? "Non-Zero" : "Never") ),
                                    (Convert.ToBoolean(question.ImportsAtBaseOfSales) ? "Yes" : "No"),
                                    question.VendorName,
                                    question.VendorID.ToString()}
                          }
                          ).Skip(StartRow - 1).Take(RowsPerPage).ToArray();

            int totalRows = result.Count;

            var ret = new JsonResult
            {
                Data = new
                {
                    page = CurrentPage,
                    records = totalRows,
                    rows = rows,
                    total = Math.Ceiling(Convert.ToDouble((double)totalRows / (double)RowsPerPage))
                }
            };

            return ret;
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs("GET")]  
        public ActionResult SelectClientProducts(int id) //id = ClientID
        {
            ClientProducts_Modify viewClientProducts_Modify = new ClientProducts_Modify();

            viewClientProducts_Modify.ClientID = id;
            viewClientProducts_Modify.ClientVendorsList = Clients.GetClientVendorsList(id);


            return PartialView("SelectClientProducts", viewClientProducts_Modify);

        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult GetClientProductsListJSON (int id, int VendorID) //id = ClientID
        {
            ClientProducts_Modify viewClientProducts_Modify = new ClientProducts_Modify();

            viewClientProducts_Modify.ClientProductsList = Products.GetProductListFromVendor(VendorID);
            var result = Products.GetProductListFromClientAndVendor(id, VendorID);

            foreach (var item in result)
            {

                viewClientProducts_Modify.ClientProductsList.Find(
                    delegate(SelectListItem tempitem)
                    {
                        return tempitem.Value == item.Value.ToString();

                    }).Selected = true;
            }

            var rows = viewClientProducts_Modify.ClientProductsList.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }


        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult SaveClientProductsListJSON(int id, string selectedClientProductIDs, int VendorID) //id = ClientID
        {
            string[] strclientproductids = selectedClientProductIDs.Split(',');
            int clientproductid = 0;
            int result = 0;
            bool rollupexists = false;

            foreach (string item in strclientproductids)
            {
                clientproductid = Convert.ToInt32(item);

                result = Products.InsertClientProduct(id, clientproductid, VendorID);
               
                if (result != 0)
                {
                    if (result == 2)
                    {
                        rollupexists = true;

                    }
                    else
                    {
                        return new JsonResult { Data = new { success = false, productid = clientproductid } };
                    }
                    
                }
                
            }

            return new JsonResult { Data = new { success = true, rollupexists = rollupexists } };
        }


        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs(HttpVerbs.Post)]
        public ActionResult EditClientProduct(FormCollection fc) 
        {

            int clientproductsid = Convert.ToInt32(fc["id"].ToString());

            var result = Products.UpdateClientProductInfo(clientproductsid, Convert.ToDecimal(fc["SalesPrice"].ToString()), fc["IncludeOnInvoice"].ToString(), fc["ImportsAtBaseOrSales"].ToString());

            if (result == 0)
            {
                return new JsonResult { Data = new { success = true } };
            }
            else
            {
                return new JsonResult { Data = new { success = false } };
            }
        }


    }
}
