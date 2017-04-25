using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ScreeningONE.DomainModels;
using ScreeningONE.ViewModels;
using System.IO;
using RKLib.ExportData;

namespace ScreeningONE.Controllers
{
    public class ProductTransactionsController : S1BaseController
    {
        //
        // GET: /ProductTransactions/

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult Index()
        {
            ProductTransactions_Index viewProductTransactions_Index = new ProductTransactions_Index();

            viewProductTransactions_Index.StartDate = GetFirstInMonth(DateTime.Now.AddMonths(-1)).ToShortDateString();
            viewProductTransactions_Index.EndDate = GetLastInMonth(DateTime.Now.AddMonths(-1)).ToShortDateString();

            viewProductTransactions_Index.ClientsList = Clients.GetClientListForDropdown();
            viewProductTransactions_Index.BillingGroups = Invoices.GetBillingGroupList();
            int SplitMode = 1;
           
            //viewProductTransactions_Index.ClientsListBySplitMode = Clients.GetClientListBySplitModeForDropdown(SplitMode,Convert.ToDateTime(viewProductTransactions_Index.StartDate),Convert.ToDateTime(viewProductTransactions_Index.EndDate));

            return View(viewProductTransactions_Index);
        }

        private static DateTime GetFirstInMonth(DateTime dt)
        {
            DateTime dtRet = new DateTime(dt.Year, dt.Month, 1, 0, 0, 0);
            return dtRet;
        }

        private static DateTime GetLastInMonth(DateTime dt)
        {
            DateTime dtRet = new DateTime(dt.Year, dt.Month, 1, 0, 0, 0).AddMonths(1).AddDays(-1);
            return dtRet;
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [HttpPost]
        public JsonResult GetUninvoicedClientsJSON(DateTime StartDate, DateTime EndDate)
        {
            List<SelectListItem> clientcontacts = Clients.GetClientsWithUnInvoicedProductTransactionsForDropdown(StartDate, EndDate);

            var rows = clientcontacts.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };

            
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult GetAllClientsJSON()
        {
            List<SelectListItem> clientcontacts = Clients.GetClientListForDropdown();

            var rows = clientcontacts.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };


        }

        /// <summary>
        /// Exports to Excel
        /// </summary>
        /// <param name="Status">The status.</param>
        /// <param name="ClientID">The client ID.</param>
        /// <param name="StartDate">The start date.</param>
        /// <param name="EndDate">The end date.</param>
        /// <param name="FileNum">The file num.</param>
        /// <param name="fc">The fc.</param>
        /// <returns></returns>
        [ScreeningONEAuthorize(Portal="Admin", Roles="Admin")]
        public JsonResult ExcelJSON(int Status, int ClientID, DateTime StartDate, DateTime EndDate, string FileNum, FormCollection fc)
        {
            int ID = Convert.ToInt32(fc["id"]);
            string FieldToSort = fc["sidx"];
            string strSortOrder = "asc";
            SortDirection SortOrder;

            if (FieldToSort == "id")
            {
                FieldToSort = "DateOrdered";
            }

            if (strSortOrder == "desc")
                SortOrder = SortDirection.Descending;
            else
                SortOrder = SortDirection.Ascending;

            int RowsPerPage = 100000;
            int CurrentPage = 1;

            EndDate = EndDate.AddHours(23).AddMinutes(59).AddSeconds(59).AddMilliseconds(997);

            List<ProductTransaction> result = ProductTransactions.GetProductTransactions(Status, ClientID, StartDate, EndDate,
                FileNum, CurrentPage, RowsPerPage, FieldToSort, SortOrder);

            // build excel file here - JCT

            string exportPath = System.Configuration.ConfigurationManager.AppSettings["excelExportPath"];

            string filename = Guid.NewGuid().ToString() + ".csv";

            Export _export = new Export();

            // create a string writer
            using (StringWriter sw = new StringWriter())
            {
                using (System.Web.UI.HtmlTextWriter htw = new System.Web.UI.HtmlTextWriter(sw))
                {
                    // instantiate a datagrid
                    System.Web.UI.WebControls.DataGrid dg = new System.Web.UI.WebControls.DataGrid();
                    

                    System.Data.DataTable dt = new System.Data.DataTable();

                    dt.Columns.Add("ID");
                    dt.Columns.Add("Transaction_Date");
                    dt.Columns.Add("Date_Ordered");
                    dt.Columns.Add("Client_Name");
                    dt.Columns.Add("Product_Type");
                    dt.Columns.Add("Product_Description");
                    dt.Columns.Add("File_Number");
                    dt.Columns.Add("Reference");
                    dt.Columns.Add("Ordered_By");
                    dt.Columns.Add("Product_Price");
                    dt.Columns.Add("Include_On_Invoice");

                    foreach (ProductTransaction p in result)
                    {
                        System.Data.DataRow dr;

                        dr = dt.NewRow();

                        dr["ID"] = p.ProductTransactionID;
                        dr["Transaction_Date"] = p.TransactionDate.ToShortDateString();
                        dr["Date_Ordered"] = p.DateOrdered.ToShortDateString();
                        dr["Client_Name"] = p.ClientName;
                        dr["Product_Type"] = p.ProductType;
                        dr["Product_Description"] = p.ProductDescription;
                        dr["File_Number"] = p.FileNum;
                        dr["Reference"] = p.Reference;
                        dr["Ordered_By"] = p.OrderedBy;
                        dr["Product_Price"] = string.Format("{0:C}", p.ProductPrice);
                        dr["Include_On_Invoice"] = p.IncludeOnInvoice.ToString();

                        dt.Rows.Add(dr);
                    }

                    //dg.DataSource = dt;
                    //dg.AutoGenerateColumns = true;
                    //dg.DataBind();
                    //dg.RenderControl(htw);

                    //FileStream fs = new FileStream(exportPath + filename, FileMode.Create);
                    //BinaryWriter bw = new BinaryWriter(fs, System.Text.Encoding.GetEncoding("UTF-8"));

                    //bw.Write(sw.ToString().Trim());
                    //bw.Close();
                    //fs.Close();

                    int[] iColumns = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 };

                    _export.ExportDetails(dt, iColumns, Export.ExportFormat.Excel, exportPath + filename);
                    
                }
            }

            

            var ret = new JsonResult
            {
                Data = new
                {
                    excelFile = filename
                }
            };

            return ret;

        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult IndexJSON(int Status, int ClientID, DateTime StartDate, DateTime EndDate, string FileNum,
            FormCollection fc) //ClientID (0 = all), BillingContactID (0 = all)
        {
                       
            int ID = Convert.ToInt32(fc["id"]);
            string FieldToSort = fc["sidx"];
            string strSortOrder = fc["sord"];
            SortDirection SortOrder;

            if (FieldToSort=="id")
            {
                FieldToSort = "DateOrdered";
            }

            if (strSortOrder=="desc")
                SortOrder = SortDirection.Descending;
            else
                SortOrder = SortDirection.Ascending;

            int RowsPerPage = Convert.ToInt32(fc["rows"]);
            int CurrentPage = Convert.ToInt32(fc["page"]);

            EndDate = EndDate.AddHours(23).AddMinutes(59).AddSeconds(59).AddMilliseconds(997);

            List<ProductTransaction> result = ProductTransactions.GetProductTransactions(Status, ClientID, StartDate, EndDate, 
                FileNum, CurrentPage, RowsPerPage, FieldToSort, SortOrder);

            Array rows = (from question in result
                          select new
                          {
                              i = question.ProductTransactionID,
                              cell = new string[] { question.ProductTransactionID.ToString(),
                                  "", //Action
                                  question.TransactionDate.ToShortDateString(),
                                  question.DateOrdered.ToShortDateString(),
                                  question.ClientName,
                                  question.ProductType,  
                                  question.ProductName,
                                  question.ProductDescription,
                                  question.FileNum,
                                  question.Reference,
                                  question.OrderedBy,
                                  question.ProductPrice.ToString("F"),
                                  question.IncludeOnInvoice.ToString()}
                          }
                          ).ToArray();

            int totalRows;
            if (result.Count > 0)
                totalRows = result.First().NumberOfRows;
            else
                totalRows = 0;

            var ret = new JsonResult
            {
                Data = new
                {
                    page = CurrentPage,
                    records = totalRows,
                    rows = rows,
                    userdata = new {  },
                    total = Math.Ceiling(Convert.ToDouble((double)totalRows / (double)RowsPerPage))
                }
            };

            return ret;
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult Edit(int id) //id = ProductTransactionID
        {
            int ProductTransactionID = id;

            ProductTransactions_Edit viewProductTransactions_Edit = new ProductTransactions_Edit();

            ProductTransaction productTransaction = ProductTransactions.GetProductTransaction(ProductTransactionID);

            viewProductTransactions_Edit.productTransaction = productTransaction;

            return View("EditPartial", viewProductTransactions_Edit);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult Add()
        {
            ProductTransactions_Add viewProductTransactions_Add = new ProductTransactions_Add();

            viewProductTransactions_Add.TransactionDate = DateTime.Now;
            viewProductTransactions_Add.selectListClients = Clients.GetClientListForDropdown();
            //viewProductTransactions_Add.selectListProducts = Products.GetProductList();
            viewProductTransactions_Add.selectListVendors = Vendors.GetVendorList();

            return View("AddPartial", viewProductTransactions_Add);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult UpdateProductTransaction(int _ProductTransactionID, int _ClientID, DateTime _TransactionDate,
                DateTime _DateOrdered,int _ProductID, string _ProductType, string _ProductDescription, decimal _ProductPrice,
                string _FName, string _MName, string _LName, string _Reference, string _OrderedBy, string _FileNum,
                int _VendorID, string _SSN, decimal _BasePrice, bool _ImportsAtBaseOrSales)
        {
            ProductTransaction productTransaction = new ProductTransaction(_ProductTransactionID,_ClientID,"",_TransactionDate,
                _DateOrdered,_ProductID,_ProductType,"",_ProductDescription,_ProductPrice,0,0,_FName,_MName,_LName,_Reference,
                _OrderedBy, _FileNum, _VendorID, "", _SSN, _BasePrice, _ImportsAtBaseOrSales,0);

            ProductTransactions.UpdateProductTransaction(productTransaction);

            return new JsonResult { Data = new { success = true } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult CreateProductTransaction(int _ClientID, DateTime _TransactionDate,
                        DateTime _DateOrdered, int _ProductID, string _ProductType, string _ProductDescription, decimal _ProductPrice,
                        string _FName, string _MName, string _LName, string _Reference, string _OrderedBy, string _FileNum, 
                        int _VendorID, string _SSN, decimal _BasePrice)
        {
            ProductTransaction productTransaction = new ProductTransaction(0, _ClientID, "", _TransactionDate,
                _DateOrdered, _ProductID, _ProductType, "", _ProductDescription, _ProductPrice, 0, 0, _FName, _MName, _LName, _Reference,
                _OrderedBy, _FileNum, _VendorID, "", _SSN, _BasePrice, true,0);

            ProductTransactions.CreateProductTransaction(productTransaction);

            return new JsonResult { Data = new { success = true } };
        }

        public JsonResult RemoveProductTransaction(int _ProductTransactionID)
        {
            ProductTransactions.RemoveProductTransaction(_ProductTransactionID);

            return new JsonResult { Data = new { success = true } };
        }
    }
}
