//#define DEBUG_EMAIL

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ExpertPdf.HtmlToPdf;
using ScreeningONE.Objects;
using ScreeningONE.DomainModels;
using ScreeningONE.ViewModels;
using StringExtensions;
using System.Web.Security;
using System.Configuration;

namespace ScreeningONE.Controllers
{
    public class InvoicesController : S1BaseController
    {

        public DateTime pubStartDate;
        public DateTime pubEndDate;
        public DateTime pubInvoiceDate;
        public int pubBillingGroup;
        public int pubClientID;
        public bool pubRunInvoicesForBilling;

        //
        // GET: /Invoices/
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public ActionResult Index()
        {
            Invoices_Index viewInvoices_Index = new Invoices_Index();

            //viewInvoices_Index.StartDate = GetFirstInMonth(DateTime.Now).ToShortDateString();
            viewInvoices_Index.StartDate = GetLastInPreviousMonth(DateTime.Now).ToShortDateString();
            viewInvoices_Index.EndDate = GetLastInMonth(DateTime.Now).ToShortDateString();

            viewInvoices_Index.ClientsList = Clients.GetClientsWithInvoicesForDropdownNonAudit(Convert.ToDateTime(viewInvoices_Index.StartDate), Convert.ToDateTime(viewInvoices_Index.EndDate));


            return View(viewInvoices_Index);
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

        private static DateTime GetLastInPreviousMonth(DateTime dt)
        {
            DateTime dtRet = new DateTime(dt.Year, dt.Month, 1, 0, 0, 0).AddDays(-1);
            return dtRet;
        }


        //Return JSON data for the Invoices jqGrid
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult IndexJSON(int ClientID, int BillingContactID, DateTime StartDate, DateTime EndDate, bool BillingContactForAnyClient,
            string InvoiceNumber, int DeliveryMethod, int ReleaseStatus, FormCollection fc, bool AuditClientsOnly) //ClientID (0 = all), BillingContactID (0 = all)
        {
            int ID = Convert.ToInt32(fc["id"]);
            string FieldToSort = fc["sidx"];
            string strSortOrder = fc["sord"];
            //SortDirection SortOrder;
            bool SortOrder;

            if (FieldToSort=="id" || FieldToSort=="Action")
            {
                FieldToSort = "InvoiceDate";
            }

            if (strSortOrder=="desc")
                //SortOrder = SortDirection.Descending;
                SortOrder = true;
            else
                //SortOrder = SortDirection.Ascending;
                SortOrder = false;

            if (StartDate == null)
            {
                StartDate = DateTime.Now.AddDays(-30);
            }

            if (EndDate == null)
            {
                EndDate = DateTime.Now.AddDays(30);
            }

            int RowsPerPage = Convert.ToInt32(fc["rows"]);
            int CurrentPage = Convert.ToInt32(fc["page"]);
            int StartRow = ((CurrentPage - 1) * RowsPerPage) + 1;
            int EndRow = StartRow + RowsPerPage - 1;

            //Add 23 hours, 59 minutes, 59 seconds, and 997 ms (this is the closest you can get to the next day)
            EndDate = EndDate.AddHours(23).AddMinutes(59).AddSeconds(59).AddMilliseconds(997);



            if (String.IsNullOrEmpty(InvoiceNumber))
            {
                InvoiceNumber = null;
            }

            List<Invoice> result = Invoices.GetForDateRange(StartDate, EndDate, ClientID, BillingContactID, BillingContactForAnyClient, DeliveryMethod,
                   ReleaseStatus, InvoiceNumber, CurrentPage, RowsPerPage, FieldToSort, SortOrder, AuditClientsOnly);

            Array rows;
            int totalRows;
            decimal totalOriginalAmount;
            decimal totalInvoiceAmount;

            if (result.Count > 0)
            {
                rows = (from question in result
                        select new
                        {
                            i = question.InvoiceID,
                            cell = new string[] { question.InvoiceID.ToString(),
                                  "",
                                  question.InvoiceDate.ToShortDateString(),  
                                  question.InvoiceNumber,
                                  question.InvoiceTypeDesc,
                                  question.ClientName,
                                  question.ReleasedStatus,
                                  question.OriginalAmount.ToString("F"),
                                  question.InvoiceAmount.ToString("F")}
                        }
                          ).ToArray();

                totalInvoiceAmount = (from question in result
                                      select question.InvoiceAmount
                      ).Sum();

                totalOriginalAmount = (from question in result
                                       select question.OriginalAmount
                              ).Sum();

                totalRows = (from question in result
                             select question.TotalNumberOfRows).First();
            }
            else
            {
                rows = null;

                totalInvoiceAmount = 0;
                totalOriginalAmount = 0;
                totalRows = 0;
            }
            //No Invoice # Filter
            /*if (String.IsNullOrEmpty(InvoiceNumber))
            {
                rows = (from question in result.Order(FieldToSort, SortOrder)
                        select new
                        {
                            i = question.InvoiceID,
                            cell = new string[] { question.InvoiceID.ToString(),
                                  "",
                                  question.InvoiceDate.ToShortDateString(),  
                                  question.InvoiceNumber,
                                  question.InvoiceTypeDesc,
                                  question.ClientName,
                                  question.ReleasedStatus,
                                  question.OriginalAmount.ToString("F"),
                                  question.InvoiceAmount.ToString("F")}
                        }
                          ).Skip(StartRow - 1).Take(RowsPerPage).ToArray();
            }
            else //Has Invoice # Filter
            {
                rows = (from question in result.Order(FieldToSort, SortOrder)
                        where question.InvoiceNumber.Contains(InvoiceNumber)
                        select new
                        {
                            i = question.InvoiceID,
                            cell = new string[] { question.InvoiceID.ToString(),
                                  "",
                                  question.InvoiceDate.ToShortDateString(),  
                                  question.InvoiceNumber,
                                  question.InvoiceTypeDesc,
                                  question.ClientName,
                                  question.ReleasedStatus,
                                  question.OriginalAmount.ToString("F"),
                                  question.InvoiceAmount.ToString("F")}
                        }
                          ).Skip(StartRow - 1).Take(RowsPerPage).ToArray();
            }
            */
            //int totalRows = result2.Count;



            var ret = new JsonResult
            {
                Data = new
                {
                    page = CurrentPage,
                    records = totalRows,
                    rows = rows,
                    userdata = new { BillingContactName = "Total:",
                        OriginalAmount = totalOriginalAmount.ToString("C"),
                        InvoiceAmount = totalInvoiceAmount.ToString("C") },
                    total = Math.Ceiling(Convert.ToDouble((double)totalRows / (double)RowsPerPage))
                }
            };

            return ret;
        }

        //Return JSON data for the verify invoice jqGrid
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult invoiceVerifySetupsForClientJSON(DateTime _StartTransactionDate, DateTime _EndTransactionDate, DateTime _InvoiceDate, int _ClientID) //ClientID (0 = all), BillingContactID (0 = all)
        {
            List<InvoiceVerifySetupsForClient> result = Invoices.GetInvoiceVerifySetupsForClient(_StartTransactionDate, _EndTransactionDate, _InvoiceDate, _ClientID);

            var rows = result.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }

        public JsonResult InvoicesByBillingContactJSON(int BillingContactID, FormCollection fc)
        {

            int ID = Convert.ToInt32(fc["id"]);
            string FieldToSort = fc["sidx"];
            string strSortOrder = fc["sord"];
            SortDirection SortOrder;

            if (FieldToSort == "id" || FieldToSort == "Action")
            {
                FieldToSort = "InvoiceDate";
            }

            if (strSortOrder == "desc")
                SortOrder = SortDirection.Descending;
            else
                SortOrder = SortDirection.Ascending;

            int RowsPerPage = Convert.ToInt32(fc["rows"]);
            int CurrentPage = Convert.ToInt32(fc["page"]);
            int StartRow = ((CurrentPage - 1) * RowsPerPage) + 1;
            int EndRow = StartRow + RowsPerPage - 1;

            var result = Invoices.GetAllForBililngContactID(BillingContactID, m_UserID);
            var result2 = Invoices.GetAllForBililngContactID(BillingContactID, m_UserID);

            Array rows = (from question in result.Order(FieldToSort, SortOrder)
                          select new
                          {
                              i = question.InvoiceID,
                              cell = new string[] { question.InvoiceID.ToString(),
                                  "",
                                  question.InvoiceDate.ToShortDateString(),  
                                  question.InvoiceNumber,
                                  question.InvoiceTypeDesc,
                                  question.ClientName,
                                  question.BillingContactName,
                                  question.OriginalAmount.ToString("F"),
                                  question.InvoiceAmount.ToString("F")}
                          }
                          ).Skip(StartRow - 1).Take(RowsPerPage).ToArray();

            int totalRows = result2.Count;

            decimal totalInvoiceAmount = (from question in result
                                          select question.InvoiceAmount
                          ).Sum();

            decimal totalOriginalAmount = (from question in result
                                           select question.OriginalAmount
                          ).Sum();

            var ret = new JsonResult
            {
                Data = new
                {
                    page = CurrentPage,
                    records = totalRows,
                    rows = rows,
                    userdata = new
                    {
                        BillingContactName = "Total:",
                        OriginalAmount = totalOriginalAmount.ToString("C"),
                        InvoiceAmount = totalInvoiceAmount.ToString("C")
                    },
                    total = Math.Ceiling(Convert.ToDouble((double)totalRows / (double)RowsPerPage))
                }
            };

            return ret;
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin, Client")]
        public ActionResult Details(int id) //id = InvoiceID
        {
            Invoices_Details viewInvoices_Details = new Invoices_Details();

            viewInvoices_Details.toPrint = false;
            viewInvoices_Details.showToClient = false;
            viewInvoices_Details.invoice = Invoices.GetInvoice(id);

            viewInvoices_Details.invoiceLines = Invoices.GetInvoiceLines(id);
            viewInvoices_Details.numberOfColumns = viewInvoices_Details.invoice.NumberOfColumns;

            viewInvoices_Details.InvoiceType = viewInvoices_Details.invoice.InvoiceTypeDesc;

            return View("Details", "View", viewInvoices_Details);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult FinanceCharges()
        {

            return View();
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult FinanceChargesToCreateJSON(DateTime FinanceChargeDate, FormCollection fc)
        {

            int ID = Convert.ToInt32(fc["id"]);
            string FieldToSort = fc["sidx"];
            string strSortOrder = fc["sord"];
            SortDirection SortOrder;

            if (FieldToSort == "id" || FieldToSort == "Action")
            {
                FieldToSort = "ClientName";
            }

            if (strSortOrder == "desc")
                SortOrder = SortDirection.Descending;
            else
                SortOrder = SortDirection.Ascending;

            int RowsPerPage = Convert.ToInt32(fc["rows"]);
            int CurrentPage = Convert.ToInt32(fc["page"]);
            int StartRow = ((CurrentPage - 1) * RowsPerPage) + 1;
            int EndRow = StartRow + RowsPerPage - 1;

            var result = Invoices.GetInvoicesToCreateFinanceChargesFor(FinanceChargeDate);
            var result2 = Invoices.GetInvoicesToCreateFinanceChargesFor(FinanceChargeDate);

            Array rows = (from question in result.Order(FieldToSort, SortOrder)
                          select new
                          {
                              i = question.InvoiceID,
                              cell = new string[] { question.InvoiceID.ToString(),
                                  "",
                                  question.InvoiceDate.ToShortDateString(),
                                  question.InvoiceNumber,
                                  question.ClientName,
                                  question.OriginalInvoiceAmount.ToString("F"),
                                  question.InvoiceAmountDue.ToString("F"),
                                  question.FinanceChargeAmount.ToString("F")
                              }
                          }
                          ).Skip(StartRow - 1).Take(RowsPerPage).ToArray();

            decimal totalInvoiceAmountDue = (from question in result
                                             select question.InvoiceAmountDue
                          ).Sum();

            decimal totalFinanceChargeAmount = (from question in result
                                                select question.FinanceChargeAmount
                          ).Sum();

            int totalRows = result2.Count;

            var ret = new JsonResult
            {
                Data = new
                {
                    page = CurrentPage,
                    records = totalRows,
                    rows = rows,
                    userdata = new
                    {
                        OriginalInvoiceAmount = "Total:",
                        InvoiceAmountDue = totalInvoiceAmountDue.ToString("C"),
                        FinanceChargeAmount = totalFinanceChargeAmount.ToString("C")
                    },
                    total = Math.Ceiling(Convert.ToDouble((double)totalRows / (double)RowsPerPage))
                }
            };

            return ret;
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult CreateFinanceChargesJSON(string InvoiceIDs, DateTime FinanceChargeDate) //id is a comma separated list of ID's
        {
            if (String.IsNullOrEmpty(InvoiceIDs))
            {
                return new JsonResult { Data = new { success = false } };
            }

            //split the ID's into an array
            string[] InvoiceIDsArray = InvoiceIDs.Split(',');

            //if there are any errors while creating the finance charges, return success = false
            try
            {
                foreach (var invoiceIDstring in InvoiceIDsArray)
                {
                    int invoiceID = Int32.Parse(invoiceIDstring);
                    Invoices.CreateFinanceCharge(FinanceChargeDate, invoiceID, 0);
                }
            }
            catch
            {
                return new JsonResult { Data = new { success = false } };
            }

            return new JsonResult { Data = new { success = true } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin, Client")]
        public ActionResult RenderInvoiceToPrint(int id) //id = InvoiceID
        {
            //Mode 4
            Invoices_Details viewInvoices_Details = new Invoices_Details();

            viewInvoices_Details.toPrint = true;
            viewInvoices_Details.showToClient = false;
            viewInvoices_Details.invoice = Invoices.GetInvoice(id);

            viewInvoices_Details.invoiceLines = Invoices.GetInvoiceLines(id);
            viewInvoices_Details.numberOfColumns = viewInvoices_Details.invoice.NumberOfColumns;

            viewInvoices_Details.InvoiceType = viewInvoices_Details.invoice.InvoiceTypeDesc;

            return View("Details", "Print", viewInvoices_Details);
        }

        public ActionResult RenderInvoiceToPrint_Public(int id) //id = InvoiceID
        {
            //Mode 6
            Invoices_Details viewInvoices_Details = new Invoices_Details();

            viewInvoices_Details.toPrint = true;
            viewInvoices_Details.showToClient = false;
            viewInvoices_Details.invoice = Invoices.GetInvoice(id);

            viewInvoices_Details.invoiceLines = Invoices.GetInvoiceLines(id);
            viewInvoices_Details.numberOfColumns = viewInvoices_Details.invoice.NumberOfColumns;

            viewInvoices_Details.InvoiceType = viewInvoices_Details.invoice.InvoiceTypeDesc;

            return View("Details", "Print", viewInvoices_Details);
        }

        [ScreeningONEAuthorize(Portal = "Client", Roles = "Client")]
        public ActionResult ClientRenderInvoice(int id) //id = InvoiceID
        {
            if (!Security.UserCanAccessInvoice(m_UserID, id))
            {
                return RedirectToAction("Index", "Home");
            }

            Invoices_Details viewInvoices_Details = new Invoices_Details();

            viewInvoices_Details.toPrint = false;
            viewInvoices_Details.showToClient = true;
            viewInvoices_Details.invoice = Invoices.GetInvoice(id);

            viewInvoices_Details.invoiceLines = Invoices.GetInvoiceLines(id);
            viewInvoices_Details.numberOfColumns = viewInvoices_Details.invoice.NumberOfColumns;

            viewInvoices_Details.InvoiceType = viewInvoices_Details.invoice.InvoiceTypeDesc;

            return View("Details", "View", viewInvoices_Details);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public FileContentResult PrintInvoiceToPDF(int id) //id = InvoiceID
        {
            Invoice invoiceToExport = Invoices.GetInvoice(id);

            PdfConverter pdf = new PdfConverter();
            //pdf.PdfDocumentOptions.PdfPageSize = PdfPageSize.Letter;
            pdf.PdfDocumentOptions.BottomMargin = 0;
            pdf.PdfDocumentOptions.TopMargin = 15;
            pdf.PdfDocumentOptions.LeftMargin = 10;
            pdf.PdfDocumentOptions.RightMargin = 10;
            pdf.PdfDocumentOptions.PdfPageOrientation = PDFPageOrientation.Portrait;
            pdf.PdfDocumentOptions.ShowFooter = true;
            pdf.PdfFooterOptions.ShowPageNumber = true;
            pdf.LicenseKey = "q4CZi5qai5Oci5KFm4uYmoWamYWSkpKS";

            string AuthName = this.Request.Cookies[".ASPXAUTH"].Name;
            string AuthValue = this.Request.Cookies[".ASPXAUTH"].Value;

            //Clients.LogAction("AuthName", AuthName);
            //Clients.LogAction("AuthValue", AuthValue);

            //pdf.HttpRequestHeaders = "Cookie: name=" + AuthValue;
            pdf.HttpRequestHeaders = String.Format(
                "Cookie : {0}={1}\r\n", AuthName, AuthValue
            );

            string UrlToPDF = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"]  //"http://screeningone.com:8080/" /*"http://localhost:1225"*/ /*"http://s1-tpa-dv1:82/"*/
                + Url.Action("InvoicesDetailsMode4", "PDF", new { id = id });

            if (invoiceToExport.BillingReportGroupID > 0)
            {
                PdfConverter pdf2 = new PdfConverter();
                //pdf2.PdfDocumentOptions.PdfPageSize = PdfPageSize.Letter;
                pdf2.PdfDocumentOptions.BottomMargin = 40;
                pdf2.PdfDocumentOptions.TopMargin = 40;
                pdf2.PdfDocumentOptions.LeftMargin = 50;
                pdf2.PdfDocumentOptions.RightMargin = 50;
                pdf2.PdfDocumentOptions.PdfPageOrientation = PDFPageOrientation.Landscape;
                pdf2.PdfDocumentOptions.ShowFooter = true;
                pdf2.PdfFooterOptions.ShowPageNumber = true;
                pdf.PdfDocumentOptions.AppendPDFStream = new System.IO.MemoryStream();

                pdf2.HttpRequestHeaders = String.Format(
                    "Cookie : {0}={1}\r\n", AuthName, AuthValue
                );
                pdf2.LicenseKey = "q4CZi5qai5Oci5KFm4uYmoWamYWSkpKS";

                string UrlToPDF2 = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"] //"http://screeningone.com:8080/" /*"http://localhost:1225"*/ /*"http://s1-tpa-dv1:82/"*/
                    + Url.Action("InvoiceReportsIndexMode5", "PDF", new { InvoiceID = id, GroupID = invoiceToExport.BillingReportGroupID });

                pdf2.SavePdfFromUrlToStream(UrlToPDF2, pdf.PdfDocumentOptions.AppendPDFStream);

                pdf.PdfFooterOptions.PageNumberingPageCountIncrement = (0 - pdf2.ConversionSummary.PdfPageCount);
            }


            FileContentResult fcr = new FileContentResult(pdf.GetPdfFromUrlBytes(UrlToPDF), "application/PDF");
            fcr.FileDownloadName = invoiceToExport.ClientName + "_" + invoiceToExport.InvoiceNumber + ".pdf";
            return fcr;
        }

        //return a Json list of Billing Contacts for a Client (use to load dropdowns)
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        [HttpPost]
        public JsonResult GetBillingContactsForClient(int id) //id = ClientID
        {
            int ClientID = id;

            List<SelectListItem> billingContacts = Clients.GetBillingContactsForClient(ClientID);

            var rows = billingContacts.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult UpdateInvoiceLineText(int id, int invoiceLineNumber, string col1Text, string col2Text, string col3Text, string col4Text,
            string col5Text, string col6Text, string col7Text, string col8Text) //id = InvoiceID
        {
            Invoices.UpdateInvoiceLineText(id, invoiceLineNumber, col1Text, col2Text, col3Text, col4Text, col5Text, col6Text, col7Text, col8Text);

            return new JsonResult { Data = new { success = true } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult CreateInvoicesJSON(DateTime StartDate, DateTime EndDate, DateTime InvoiceDate, int BillingGroup,int ClientID,bool RunInvoicesForBilling)
        {
            // fire off the separate thread
            pubStartDate = StartDate;
            pubEndDate = EndDate;
            pubInvoiceDate = InvoiceDate;
            pubBillingGroup = BillingGroup;
            pubRunInvoicesForBilling = RunInvoicesForBilling;
            pubClientID = ClientID;

            //OLD Code
            /*
            Thread _thread = new Thread(new ThreadStart(createInvoicesAsync));

            _thread.Start();

            _thread.ThreadState.ToString();
            */

            // NEW Code
            if (pubRunInvoicesForBilling)
            {

                Invoices.SQLJobCreateInvoices(pubStartDate, pubEndDate, pubInvoiceDate, pubBillingGroup, m_UserID);
            }
            else
            {
                Invoices.SQLJobCreateInvoicesForClient(pubStartDate, pubEndDate, pubInvoiceDate, pubClientID, m_UserID);
            }

            return new JsonResult { Data = new { success = true } };
        }

        //OLD Code
        private void createInvoicesAsync()
        {
            if (pubRunInvoicesForBilling)
            {

                Invoices.CreateInvoices(pubStartDate, pubEndDate, pubInvoiceDate, pubBillingGroup);
            }
            else
            {
                Invoices.CreateInvoicesForClient(pubStartDate, pubEndDate, pubInvoiceDate, pubClientID);
            }

            string email = Membership.GetUser().Email;
            var result = Security.GetUserInfoForFPCustomSP(Membership.GetUser().UserName);            

            InvoicesDataContext dc = new InvoicesDataContext();
            var invoices = dc.S1_Invoices_GetLastInvoicesCreated();

            string messagebody = "<p>Your invoices have been created, you can now continue:</p>";

            foreach (var item in invoices)
            {
                messagebody = messagebody + "<br />";
                messagebody = messagebody + item.ClientName + " - " + item.InvoiceNumber;
            }

            MailGun.SendEmailToEmailAddressAsScreeningOne(0, 0, "", "Create Invoices Complete", messagebody, ConfigurationManager.AppSettings["supportemail"], ConfigurationManager.AppSettings["BillingEmail"], ConfigurationManager.AppSettings["BillingEmailName"]);

                /*
            Dictionary <string, string> messagevalues = new Dictionary<string, string>();
            var messageRecord = Messages.GetMessageTemplateRecord(0, "Create Invoices Complete", messagevalues);

            string messagebody = "<p>Your invoices have been created, you can now continue:</p>";

            foreach (var item in invoices)
            {
                messagebody = messagebody + "<br />";
                messagebody = messagebody + item.ClientName + " - " + item.InvoiceNumber;
            }

            int messageActionType = messageRecord.MessageActionTypeID.GetValueOrDefault();
            int? MessageIDOutput = new int?();
            Guid? MessageActionGuidOutput = new Guid?();
            string subject = "Create Invoices Complete";
            Messages.CreateMessageWithAction(messageActionType, subject, messagebody, result.UserId, 1, 0, 3, "", System.DateTime.Now, null, "HTML", ref MessageIDOutput, ref MessageActionGuidOutput);
            Messages.UpdateMessageAndMarkForSending(MessageIDOutput.Value, subject, messagebody);
            */
        }

        //Get XML for the next step in the QuickBooks Import/Export process
        public XmlResult GetNextStepXML(string id, int firstCall)
        {
            /*
             * 1 - Export Invoices
             * 2 - Export Finance Charges
             * 3 - Export Credit Memos
             * 4 - Get Credit Invoice TxnID's
             * 5 - Link Credits to Invoices
             * 6 - Import Payments (Transaction Date)
             * 7 - Import Payments (Modified Date)
             */
            if (id == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "192.168" || this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "127.0.0"
                || this.HttpContext.Request.UserHostAddress == "96.254.199.75"
                || this.HttpContext.Request.UserHostAddress == "70.46.148.242"))
            {
                int lastStep = Invoices.QBExport_GetLastStep();

                switch (lastStep)
                {
                    case 0: //Invoices
                        if (firstCall==1)
                            Invoices.QBExport_AddNextStep(1);
                        return GetInvoicesXML(id);
                    case 1:
                        if (firstCall == 1)
                            Invoices.QBExport_AddNextStep(2);
                        return GetFinanceChargesXML(id);
                    case 2:
                        if (firstCall == 1)
                            Invoices.QBExport_AddNextStep(3);
                        return GetCreditMemosXML(id);
                    case 3:
                        if (firstCall == 1)
                            Invoices.QBExport_AddNextStep(4);
                        return GetInvoicesQueryXML(id);
                    case 4:
                        if (firstCall == 1)
                            Invoices.QBExport_AddNextStep(5);
                        return GetLinkCreditMemosXML(id);
                    case 5:
                        if (firstCall == 1)
                            Invoices.QBExport_AddNextStep(6);
                        return GetImportPaymentsXML_TransactionDate(id);
                    case 6:
                        if (firstCall == 1)
                            Invoices.QBExport_AddNextStep(0);
                        return GetImportPaymentsXML(id);
                    default:
                        if (firstCall == 1)
                            Invoices.QBExport_AddNextStep(1);
                        return GetInvoicesXML(id);
                }
            }
            else
                return new XmlResult("<error>Invalid Request: " + this.HttpContext.Request.UserHostAddress + "</error>");
        }

        //Public method secured by IP and Authentication Token
        public XmlResult GetInvoicesXML(string id) //id = authentication token
        {
            if (id == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "192.168" || this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "127.0.0"
                || this.HttpContext.Request.UserHostAddress == "96.254.199.75"
                || this.HttpContext.Request.UserHostAddress == "70.46.148.242"))
            {
                //Invoice test = Invoices.GetInvoice(4095);
                //string outXML = "<?qbxml version=\"8.0\"?><QBXML><QBXMLMsgsRq onError=\"stopOnError\"><InvoiceAddRq requestID=\"3\"><InvoiceAdd><CustomerRef><FullName>TAMPA METRO YMCA</FullName></CustomerRef><TemplateRef><FullName>Invoice</FullName></TemplateRef><TxnDate>2010-07-01</TxnDate><RefNumber>678910</RefNumber><IsFinanceCharge>0</IsFinanceCharge><IsToBePrinted>0</IsToBePrinted><IsToBeEmailed>0</IsToBeEmailed><InvoiceLineAdd><ItemRef><FullName>Imported Invoice</FullName></ItemRef><Desc>Imported Invoice</Desc><Amount>45678.90</Amount></InvoiceLineAdd></InvoiceAdd><IncludeRetElement>TxnID</IncludeRetElement></InvoiceAddRq></QBXMLMsgsRq></QBXML>";
                string outXML = "<?qbxml version=\"8.0\"?><QBXML><QBXMLMsgsRq onError=\"stopOnError\">";
                int CurRequest = 4;

                List<Invoice> exportInvoices = Invoices.GetExportInvoices();
                foreach (var item in exportInvoices)
                {
                    outXML += "<InvoiceAddRq requestID=\"" + CurRequest.ToString() + "\">";
                    outXML += "<InvoiceAdd><CustomerRef><FullName>" + System.Web.HttpUtility.HtmlEncode(item.ClientName) + "</FullName></CustomerRef><TemplateRef><FullName>Invoice</FullName></TemplateRef>";
                    outXML += "<TxnDate>" + item.InvoiceDate.ToString("yyyy-MM-dd") + "</TxnDate><RefNumber>" + item.InvoiceNumber + "</RefNumber>";
                    outXML += "<IsFinanceCharge>0</IsFinanceCharge>";
                    outXML += "<Memo>" + System.Web.HttpUtility.HtmlEncode(item.BillTo.stripHTML()) + "</Memo>";
                    outXML += "<IsToBePrinted>0</IsToBePrinted><IsToBeEmailed>0</IsToBeEmailed>";
                    //item.BillTo contains the actual client name as opposed to the BillAsClientName that is stored in item.ClientName
                    outXML += "<InvoiceLineAdd><ItemRef><FullName>Imported Invoice</FullName></ItemRef><Desc>Imported Invoice - " + System.Web.HttpUtility.HtmlEncode(item.BillTo.stripHTML()) + "</Desc>";
                    outXML += "<Amount>" + item.InvoiceAmount.ToString("F") + "</Amount></InvoiceLineAdd></InvoiceAdd>";
                    outXML += "<IncludeRetElement>TxnID</IncludeRetElement><IncludeRetElement>RefNumber</IncludeRetElement></InvoiceAddRq>";
                    CurRequest++;
                }

                outXML += "</QBXMLMsgsRq></QBXML>";

                return new XmlResult(outXML);
            }
            else
                return new XmlResult("<error>Invalid Request: " + this.HttpContext.Request.UserHostAddress + "</error>");
        }

        //Public method secured by IP and Authentication Token
        public XmlResult GetFinanceChargesXML(string id) //id = authentication token
        {
            if (id == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "192.168" || this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "127.0.0"
                || this.HttpContext.Request.UserHostAddress == "96.254.199.75"
                || this.HttpContext.Request.UserHostAddress == "70.46.148.242"))
            {
                //Invoice test = Invoices.GetInvoice(4095);
                string outXML = "<?qbxml version=\"8.0\"?><QBXML><QBXMLMsgsRq onError=\"stopOnError\">";
                int CurRequest = 4;

                List<Invoice> exportInvoices = Invoices.GetExportFinanceCharges();
                foreach (var item in exportInvoices)
                {
                    outXML += "<InvoiceAddRq requestID=\"" + CurRequest.ToString() + "\">";
                    outXML += "<InvoiceAdd><CustomerRef><FullName>" + System.Web.HttpUtility.HtmlEncode(item.ClientName) + "</FullName></CustomerRef><TemplateRef><FullName>Invoice</FullName></TemplateRef>";
                    outXML += "<TxnDate>" + item.InvoiceDate.ToString("yyyy-MM-dd") + "</TxnDate><RefNumber>" + item.InvoiceNumber + "</RefNumber>";
                    outXML += "<IsFinanceCharge>1</IsFinanceCharge><IsToBePrinted>0</IsToBePrinted><IsToBeEmailed>0</IsToBeEmailed>";
                    outXML += "<InvoiceLineAdd><ItemRef><FullName>*Fin Chg</FullName></ItemRef><Desc>Imported Finance Charge</Desc>";
                    outXML += "<Amount>" + item.InvoiceAmount.ToString("F") + "</Amount></InvoiceLineAdd></InvoiceAdd>";
                    outXML += "<IncludeRetElement>TxnID</IncludeRetElement><IncludeRetElement>RefNumber</IncludeRetElement></InvoiceAddRq>";
                    CurRequest++;
                }

                outXML += "</QBXMLMsgsRq></QBXML>";

                return new XmlResult(outXML);
            }
            else
                return new XmlResult("<error>Invalid Request: " + this.HttpContext.Request.UserHostAddress + "</error>");
        }

        //Public method secured by IP and Authentication Token
        public XmlResult GetCreditMemosXML(string id) //id = authentication token
        {
            if (id == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "192.168" || this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "127.0.0"
                || this.HttpContext.Request.UserHostAddress == "96.254.199.75"
                || this.HttpContext.Request.UserHostAddress == "70.46.148.242"))
            {
                //Invoice test = Invoices.GetInvoice(4095);
                string outXML = "<?qbxml version=\"8.0\"?><QBXML><QBXMLMsgsRq onError=\"stopOnError\">";
                int CurRequest = 4;

                List<Invoice> exportInvoices = Invoices.GetExportCreditMemos();
                foreach (var item in exportInvoices)
                {
                    outXML += "<CreditMemoAddRq requestID=\"" + CurRequest.ToString() + "\">";
                    outXML += "<CreditMemoAdd><CustomerRef><FullName>" + System.Web.HttpUtility.HtmlEncode(item.ClientName) + "</FullName></CustomerRef><TemplateRef><FullName>Custom Credit Memo</FullName></TemplateRef>";
                    outXML += "<TxnDate>" + item.InvoiceDate.ToString("yyyy-MM-dd") + "</TxnDate><RefNumber>" + item.InvoiceNumber + "</RefNumber>";
                    outXML += "<IsToBePrinted>0</IsToBePrinted><IsToBeEmailed>0</IsToBeEmailed>";
                    outXML += "<CreditMemoLineAdd><ItemRef><FullName>Credit Memo</FullName></ItemRef>";
                    outXML += "<Amount>" + item.InvoiceAmount.ToString("F") + "</Amount></CreditMemoLineAdd></CreditMemoAdd>";
                    outXML += "<IncludeRetElement>TxnID</IncludeRetElement>";
                    outXML += "<IncludeRetElement>RefNumber</IncludeRetElement></CreditMemoAddRq>";
                    CurRequest++;
                }

                outXML += "</QBXMLMsgsRq></QBXML>";

                return new XmlResult(outXML);
            }
            else
                return new XmlResult("<error>Invalid Request: " + this.HttpContext.Request.UserHostAddress + "</error>");
        }


        //Public method secured by IP and Authentication Token
        public XmlResult GetInvoicesQueryXML(string id) //id = authentication token
        {
            if (id == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "192.168" || this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "127.0.0"
                || this.HttpContext.Request.UserHostAddress == "96.254.199.75"
                || this.HttpContext.Request.UserHostAddress == "70.46.148.242"))
            {
                //Invoice test = Invoices.GetInvoice(4095);
                string outXML = "<?qbxml version=\"8.0\"?><QBXML><QBXMLMsgsRq onError=\"stopOnError\">";
                int CurRequest = 4;

                List<Invoice> exportInvoices = Invoices.QBExportLinkCredits_GetCreditsWithMissingRelatedInvoiceTxnIDs();

                foreach (var item in exportInvoices)
                {
                    outXML += "<InvoiceQueryRq requestID=\"" + CurRequest.ToString() + "\">";
                    outXML += "<RefNumber>" + item.InvoiceNumber + "</RefNumber>";
                    outXML += "<IncludeRetElement>TxnID</IncludeRetElement>";
                    outXML += "<IncludeRetElement>RefNumber</IncludeRetElement></InvoiceQueryRq>";
                    CurRequest++;
                }

                outXML += "</QBXMLMsgsRq></QBXML>";

                return new XmlResult(outXML);
            }
            else
                return new XmlResult("<error>Invalid Request: " + this.HttpContext.Request.UserHostAddress + "</error>");
        }


        //Public method secured by IP and Authentication Token
        public XmlResult GetLinkCreditMemosXML(string id) //id = authentication token
        {
            if (id == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "192.168" || this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "127.0.0"
                || this.HttpContext.Request.UserHostAddress == "96.254.199.75"
                || this.HttpContext.Request.UserHostAddress == "70.46.148.242"))
            {
                //Invoice test = Invoices.GetInvoice(4095);
                string outXML = "<?qbxml version=\"8.0\"?><QBXML><QBXMLMsgsRq onError=\"stopOnError\">";
                int CurRequest = 4;

                List<Invoice> exportInvoices = Invoices.QBExportLinkCredits_GetCreditsToLink();

                foreach (var item in exportInvoices)
                {
                    outXML += "<ReceivePaymentAddRq requestID=\"" + CurRequest.ToString() + "\">";
                    outXML += "<ReceivePaymentAdd>";
                    outXML += "<CustomerRef><FullName>" + System.Web.HttpUtility.HtmlEncode(item.ClientName) + "</FullName></CustomerRef>";
                    outXML += "<ARAccountRef><FullName>Accounts Receivable</FullName></ARAccountRef>";
                    outXML += "<AppliedToTxnAdd>";
                    outXML += "<TxnID>" + item.InvoiceTypeDesc + "</TxnID>";
                    outXML += "<SetCredit>";
                    outXML += "<CreditTxnID>" + item.InvoiceNumber + "</CreditTxnID>";
                    outXML += "<AppliedAmount>" + item.InvoiceAmount.ToString("F") + "</AppliedAmount>";
                    outXML += "</SetCredit>";
                    outXML += "</AppliedToTxnAdd>";
                    outXML += "</ReceivePaymentAdd>";
                    outXML += "<IncludeRetElement>TxnID</IncludeRetElement>";
                    outXML += "<IncludeRetElement>RefNumber</IncludeRetElement></ReceivePaymentAddRq>";
                    CurRequest++;
                }

                outXML += "</QBXMLMsgsRq></QBXML>";

                return new XmlResult(outXML);
            }
            else
                return new XmlResult("<error>Invalid Request: " + this.HttpContext.Request.UserHostAddress + "</error>");
        }


        //Public method secured by IP and Authentication Token
        public XmlResult GetImportPaymentsXML(string id) //id = authentication token
        {
            if (id == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "192.168" || this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "127.0.0"
                || this.HttpContext.Request.UserHostAddress == "96.254.199.75"
                || this.HttpContext.Request.UserHostAddress == "70.46.148.242"))
            {
                DateTime lastPaymentUpdateDate = Invoices.QBExport_GetLastPaymentUpdateDate().AddDays(-1); //One day overlap

                //Invoice test = Invoices.GetInvoice(4095);
                string outXML = "<?qbxml version=\"8.0\"?><QBXML><QBXMLMsgsRq onError=\"stopOnError\">";
                int CurRequest = 2;

                outXML += "<ReceivePaymentQueryRq requestID=\"" + CurRequest.ToString() + "\">";
                outXML += "<ModifiedDateRangeFilter>";
                outXML += "<FromModifiedDate>" + lastPaymentUpdateDate.ToString("yyyy-MM-dd") + "T00:00:00</FromModifiedDate>";
                outXML += "<ToModifiedDate>" + System.Configuration.ConfigurationManager.AppSettings["QbModifiedCutoffDate"] + "</ToModifiedDate>";
                outXML += "</ModifiedDateRangeFilter>";
                /*outXML += "<TxnDateRangeFilter>";
                outXML += "<FromTxnDate>2010-09-16</FromTxnDate>";
                outXML += "<ToTxnDate>2010-09-16</ToTxnDate>";
                outXML += "</TxnDateRangeFilter>";*/
                outXML += "<IncludeLineItems>true</IncludeLineItems>";
                outXML += "<IncludeRetElement>TxnID</IncludeRetElement>";
                outXML += "<IncludeRetElement>TotalAmount</IncludeRetElement>";
                outXML += "<IncludeRetElement>AppliedToTxnRet</IncludeRetElement>";
                outXML += "<IncludeRetElement>TxnDate</IncludeRetElement>";
                outXML += "<IncludeRetElement>CustomerRef</IncludeRetElement>";
                outXML += "<IncludeRetElement>PaymentMethodRef</IncludeRetElement>";
                outXML += "<IncludeRetElement>UnusedPayment</IncludeRetElement>";
                outXML += "<IncludeRetElement>UnusedCredits</IncludeRetElement>";
                outXML += "</ReceivePaymentQueryRq>";

                outXML += "</QBXMLMsgsRq></QBXML>";

                return new XmlResult(outXML);
            }
            else
                return new XmlResult("<error>Invalid Request: " + this.HttpContext.Request.UserHostAddress + "</error>");
        }

        //Public method secured by IP and Authentication Token
        public XmlResult GetImportPaymentsXML_TransactionDate(string id) //id = authentication token
        {
            if (id == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "192.168" || this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "127.0.0"
                || this.HttpContext.Request.UserHostAddress == "96.254.199.75"
                || this.HttpContext.Request.UserHostAddress == "70.46.148.242"))
            {
                DateTime lastPaymentUpdateDate = Invoices.QBExport_GetLastPaymentUpdateDate().AddDays(-1); //One day overlap

                //Invoice test = Invoices.GetInvoice(4095);
                string outXML = "<?qbxml version=\"8.0\"?><QBXML><QBXMLMsgsRq onError=\"stopOnError\">";
                int CurRequest = 2;

                outXML += "<ReceivePaymentQueryRq requestID=\"" + CurRequest.ToString() + "\">";
                //outXML += "<ModifiedDateRangeFilter>";
                //outXML += "<FromModifiedDate>" + lastPaymentUpdateDate.ToString("yyyy-MM-dd") + "T00:00:00</FromModifiedDate>";
                //outXML += "<ToModifiedDate>2010-12-31T00:00:00</ToModifiedDate>";
                //outXML += "</ModifiedDateRangeFilter>";
                outXML += "<TxnDateRangeFilter>";
                outXML += "<FromTxnDate>" + lastPaymentUpdateDate.ToString("yyyy-MM-dd") + "</FromTxnDate>";
                outXML += "<ToTxnDate>" + System.Configuration.ConfigurationManager.AppSettings["QbTransactionCutoffDate"] + "</ToTxnDate>";
                outXML += "</TxnDateRangeFilter>";
                outXML += "<IncludeLineItems>true</IncludeLineItems>";
                outXML += "<IncludeRetElement>TxnID</IncludeRetElement>";
                outXML += "<IncludeRetElement>TotalAmount</IncludeRetElement>";
                outXML += "<IncludeRetElement>AppliedToTxnRet</IncludeRetElement>";
                outXML += "<IncludeRetElement>TxnDate</IncludeRetElement>";
                outXML += "<IncludeRetElement>CustomerRef</IncludeRetElement>";
                outXML += "<IncludeRetElement>PaymentMethodRef</IncludeRetElement>";
                outXML += "<IncludeRetElement>UnusedPayment</IncludeRetElement>";
                outXML += "<IncludeRetElement>UnusedCredits</IncludeRetElement>";
                outXML += "</ReceivePaymentQueryRq>";

                outXML += "</QBXMLMsgsRq></QBXML>";

                return new XmlResult(outXML);
            }
            else
                return new XmlResult("<error>Invalid Request: " + this.HttpContext.Request.UserHostAddress + "</error>");
        }


        //Public method secured by IP and Authentication Token
        public XmlResult UpdateInvoicesExportedXML(string id) //id = authentication token
        {
            string inXML;
            using (var reader = new StreamReader(this.Request.InputStream))
            {
                inXML = reader.ReadToEnd();
            }
            if (id == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "192.168" || this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "127.0.0"
                || this.HttpContext.Request.UserHostAddress == "96.254.199.75"
                || this.HttpContext.Request.UserHostAddress == "70.46.148.242"))
            {
                byte[] byteArray = Encoding.ASCII.GetBytes(inXML);
                MemoryStream memStream = new MemoryStream(byteArray);
                System.Data.DataSet ds = new System.Data.DataSet();
                ds.ReadXml(memStream);

                string strQBTransactionID;
                string strInvoiceNumber;
                if (ds.Tables.Contains("InvoiceRet"))
                {
                    for (int CurRow2 = 0; CurRow2 < ds.Tables["InvoiceRet"].Rows.Count; CurRow2++)
                    {
                        strQBTransactionID = (string)ds.Tables["InvoiceRet"].Rows[CurRow2].ItemArray[0];
                        strInvoiceNumber = (string)ds.Tables["InvoiceRet"].Rows[CurRow2].ItemArray[1];
                        Invoices.SetInvoiceAsExported(strInvoiceNumber, strQBTransactionID);
                    }
                }

                string ErrorText="";
                if (ds.Tables.Contains("InvoiceAddRs"))
                {
                    for (int CurRow = 0; CurRow < ds.Tables["InvoiceAddRs"].Rows.Count; CurRow++)
                    {
                        ErrorText = (string)ds.Tables["InvoiceAddRs"].Rows[CurRow].ItemArray[3];
                        Invoices.CreateQuickBooksExportError(ErrorText);
                    }
                }

                return new XmlResult("<postdata>" + ErrorText + "</postdata>");
                //return new XmlResult("<postdata>/postdata>");
            }
            else
                return new XmlResult("<error>Invalid Request: " + this.HttpContext.Request.UserHostAddress + "</error>");
        }


        //Public method secured by IP and Authentication Token
        public XmlResult UpdateInvoicesTxnXML(string id) //id = authentication token
        {
            string inXML;
            using (var reader = new StreamReader(this.Request.InputStream))
            {
                inXML = reader.ReadToEnd();
            }
            if (id == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "192.168" || this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "127.0.0"
                || this.HttpContext.Request.UserHostAddress == "96.254.199.75"
                || this.HttpContext.Request.UserHostAddress == "70.46.148.242"))
            {
                byte[] byteArray = Encoding.ASCII.GetBytes(inXML);
                MemoryStream memStream = new MemoryStream(byteArray);
                System.Data.DataSet ds = new System.Data.DataSet();
                ds.ReadXml(memStream);

                string strQBTransactionID;
                string strInvoiceNumber;
                if (ds.Tables.Contains("InvoiceRet"))
                {
                    for (int CurRow2 = 0; CurRow2 < ds.Tables["InvoiceRet"].Rows.Count; CurRow2++)
                    {
                        strQBTransactionID = (string)ds.Tables["InvoiceRet"].Rows[CurRow2].ItemArray[0];
                        strInvoiceNumber = (string)ds.Tables["InvoiceRet"].Rows[CurRow2].ItemArray[1];
                        Invoices.SetInvoiceTxnID(strInvoiceNumber, strQBTransactionID);
                    }
                }

                string ErrorText="";
                if (ds.Tables.Contains("InvoiceRet"))
                {
                    for (int CurRow = 0; CurRow < ds.Tables["InvoiceRet"].Rows.Count; CurRow++)
                    {
                        ErrorText = (string)ds.Tables["InvoiceRet"].Rows[CurRow].ItemArray[1];
                        Invoices.CreateQuickBooksExportError(ErrorText);
                    }
                }

                return new XmlResult("<postdata>" + ErrorText + "</postdata>");
                //return new XmlResult("<postdata>/postdata>");
            }
            else
                return new XmlResult("<error>Invalid Request: " + this.HttpContext.Request.UserHostAddress + "</error>");
        }


        //Public method secured by IP and Authentication Token
        public XmlResult UpdateCreditMemosExportedXML(string id) //id = authentication token
        {
            string inXML;
            using (var reader = new StreamReader(this.Request.InputStream))
            {
                inXML = reader.ReadToEnd();
            }
            if (id == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "192.168" || this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "127.0.0"
                || this.HttpContext.Request.UserHostAddress == "96.254.199.75"
                || this.HttpContext.Request.UserHostAddress == "70.46.148.242"))
            {
                byte[] byteArray = Encoding.ASCII.GetBytes(inXML);
                MemoryStream memStream = new MemoryStream(byteArray);
                System.Data.DataSet ds = new System.Data.DataSet();
                ds.ReadXml(memStream);

                string strQBTransactionID;
                string strInvoiceNumber;
                string ErrorText = "";
                if (ds.Tables.Contains("CreditMemoRet"))
                {
                    for (int CurRow = 0; CurRow < ds.Tables["CreditMemoRet"].Rows.Count; CurRow++)
                    {
                        ErrorText = (string)ds.Tables["CreditMemoRet"].Rows[CurRow].ItemArray[1];
                        Invoices.CreateQuickBooksExportError(ErrorText);
                    }
                }

                if (ds.Tables.Contains("CreditMemoRet"))
                {
                    for (int CurRow2 = 0; CurRow2 < ds.Tables["CreditMemoRet"].Rows.Count; CurRow2++)
                    {
                        strQBTransactionID = (string)ds.Tables["CreditMemoRet"].Rows[CurRow2].ItemArray[0];
                        strInvoiceNumber = (string)ds.Tables["CreditMemoRet"].Rows[CurRow2].ItemArray[1];
                        Invoices.SetInvoiceAsExported(strInvoiceNumber, strQBTransactionID);
                        Invoices.QBExportLinkCredits_AddCredit(strInvoiceNumber);
                    }
                }

                return new XmlResult("<postdata>" + ErrorText + "</postdata>");
                //return new XmlResult("<postdata>/postdata>");
            }
            else
                return new XmlResult("<error>Invalid Request: " + this.HttpContext.Request.UserHostAddress + "</error>");
        }

        //Public method secured by IP and Authentication Token
        public XmlResult MarkCreditsAsLinkedXML(string id)
        {
            if (id == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "192.168" || this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "127.0.0"
                || this.HttpContext.Request.UserHostAddress == "96.254.199.75"
                || this.HttpContext.Request.UserHostAddress == "70.46.148.242"))
            {
                Invoices.MarkCreditsAsLinked();

                return new XmlResult("<postdata></postdata>");
            }
            else
                return new XmlResult("<error>Invalid Request: " + this.HttpContext.Request.UserHostAddress + "</error>");
        }

        //Public method secured by IP and Authentication Token
        public XmlResult UpdatePaymentsXML(string id) //id = authentication token
        {
            string inXML;

            using (var reader = new StreamReader(this.Request.InputStream))
            {
                inXML = reader.ReadToEnd();
            }

            if (inXML.Contains("<DiscountAmount>"))
            {
                inXML = inXML.Replace("\n","");
                /*
                System.Text.RegularExpressions.Regex test1 = new System.Text.RegularExpressions.Regex("<DiscountAmount>.*?</DiscountAccountRef>");
                foreach (var item in test1.Matches(inXML))
                {
                    string test2 = item.ToString();
                }
                */
                inXML = System.Text.RegularExpressions.Regex.Replace(inXML, "<DiscountAmount>.*?</DiscountAccountRef>", "");
            }

            if (id == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "192.168" || this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "127.0.0"
                || this.HttpContext.Request.UserHostAddress == "96.254.199.75"
                || this.HttpContext.Request.UserHostAddress == "70.46.148.242"))
            {
                byte[] byteArray = Encoding.ASCII.GetBytes(inXML);
                MemoryStream memStream = new MemoryStream(byteArray);
                System.Data.DataSet ds = new System.Data.DataSet();
                ds.ReadXml(memStream);

                string strTransactionID;
                string strTransactionDate;
                string strAmount;
                string strCustomer;
                int AppliedToTxn;
                int PaymentTxn;
                int billingContactID;
                if (ds.Tables.Contains("ReceivePaymentRet"))
                {
                    //Clients.LogAction("INVOICES_UpdatePaymentsXML_StartCreate4", ds.Tables["ReceivePaymentRet"].Rows.Count.ToString());
                    for (int CurRow2 = 0; CurRow2 < ds.Tables["ReceivePaymentRet"].Rows.Count; CurRow2++)
                    {
                        //Clients.LogAction("INVOICES_UpdatePaymentsXML_StartCreate3", ds.Tables["ReceivePaymentRet"].Rows[CurRow2].ItemArray.Length.ToString());

                        strTransactionID = (string)ds.Tables["ReceivePaymentRet"].Rows[CurRow2].ItemArray[0];
                        AppliedToTxn = (int)ds.Tables["ReceivePaymentRet"].Rows[CurRow2].ItemArray[1];
                        strTransactionDate = (string)ds.Tables["ReceivePaymentRet"].Rows[CurRow2].ItemArray[2];
                        strAmount = (string)ds.Tables["ReceivePaymentRet"].Rows[CurRow2].ItemArray[3];
                        PaymentTxn = (int)ds.Tables["ReceivePaymentRet"].Rows[CurRow2].ItemArray[1];

                        strCustomer = (string)ds.Tables["CustomerRef"].Rows[PaymentTxn].ItemArray[1];
                        var resultBillingContactID = Clients.GetFirstBillingContactFromBillAsClientName(strCustomer);
                        DateTime transactionDate = DateTime.Parse(strTransactionDate);
                        DateTime cutOffDate = new DateTime(2010, 1, 1); //Don't import payments with a transaction date prior to 1/1/2010
                        Decimal transactionAmount = decimal.Parse(strAmount);

                        //Make sure there is a valid Billing Contact and that the payment has a transaction date on or after 1/1/2010
                        if (resultBillingContactID.HasValue && transactionDate >= cutOffDate)
                        {
                            billingContactID = resultBillingContactID.Value;

                            var result = Invoices.CreateOrUpdatePayment(transactionDate, transactionAmount, billingContactID,
                                0, "", strTransactionID);

                            if (ds.Tables.Contains("AppliedToTxnRet") && result > 0)
                            {
                                int InvoicePaymentCreated = 0;
                                int PaymentID = Convert.ToInt32(result);

                                Clients.LogAction("INVOICES_UpdatePaymentsXML_StartCreate5", ds.Tables["AppliedToTxnRet"].Rows.Count.ToString());
                                for (int CurRow = 0; CurRow < ds.Tables["AppliedToTxnRet"].Rows.Count; CurRow++)
                                {
                                    //Clients.LogAction("INVOICES_UpdatePaymentsXML_StartCreate1", ds.Tables["AppliedToTxnRet"].Rows[CurRow].ItemArray.Length.ToString());
                                    try {
                                        if (ds.Tables["AppliedToTxnRet"].Rows[CurRow].ItemArray.Length >= 6
                                            && !String.IsNullOrEmpty((string)ds.Tables["AppliedToTxnRet"].Rows[CurRow]["RefNumber"]))
                                        {
                                            //Clients.LogAction("INVOICES_UpdatePaymentsXML_StartCreate2", (string)ds.Tables["AppliedToTxnRet"].Rows[CurRow]["RefNumber"]);

                                            if ((int)ds.Tables["AppliedToTxnRet"].Rows[CurRow].ItemArray[6] == AppliedToTxn)
                                            {
                                                int InvoicePaymentID = Invoices.CreateOrUpdateInvoicePayment(PaymentID,
                                                    (string)ds.Tables["AppliedToTxnRet"].Rows[CurRow]["RefNumber"],
                                                    Decimal.Parse((string)ds.Tables["AppliedToTxnRet"].Rows[CurRow]["Amount"]),
                                                    (string)ds.Tables["AppliedToTxnRet"].Rows[CurRow]["TxnID"],
                                                    billingContactID);

                                                if (InvoicePaymentID > 0)
                                                {
                                                    InvoicePaymentCreated++;
                                                }
                                            }
                                            /*else if ((int)ds.Tables["AppliedToTxnRet"].Rows[CurRow].ItemArray[6] > AppliedToTxn)
                                            {
                                                break;
                                            }*/
                                        }
                                        else
                                        {
                                            Clients.LogAction("INVOICES_UpdatePaymentsXML_MissingRefNumber", "No invoice payments were created for PaymentID: " + PaymentID.ToString());
                                        }

                                    }
                                    catch (Exception ex)
                                    {
                                        Clients.LogAction("INVOICES_UpdatePaymentsXML_UnknownCreateError", ex.Message);
                                    }

                                }



                                if (InvoicePaymentCreated > 0)
                                {
                                    Clients.LogAction("INVOICES_UpdatePaymentsXML_CreatedInvoicePayment", "No invoice payments were created for PaymentID: " + PaymentID.ToString());
                                }
                                else
                                {
                                    Clients.LogAction("INVOICES_UpdatePaymentsXML_NoInvoicePayments", "No invoice payments were created for PaymentID: " + PaymentID.ToString());
                                }


                            }
                        }
                        else //Could not find primar BillingContact from BillAsClientName
                        {
                            Clients.LogAction("INVOICES_UpdatePaymentsXML_CantFindBillingContact", "Cannot find a primary billing contact for BillAsClientName: " + strCustomer);
                        }
                        //ds.Tables["ReceivePaymentRet"].Rows[CurRow2]
                        //Invoices.CreateNewInvoicePayment();
                    }
                }

                /*string ErrorText = "";
                if (ds.Tables.Contains("AppliedToTxnRet"))
                {
                    for (int CurRow = 0; CurRow < ds.Tables["AppliedToTxnRet"].Rows.Count; CurRow++)
                    {
                        ErrorText = (string)ds.Tables["AppliedToTxnRet"].Rows[CurRow].ItemArray[3];
                        Invoices.CreateQuickBooksExportError(ErrorText);
                    }
                }*/
                string ErrorText = "";

                return new XmlResult("<postdata>" + ErrorText + "</postdata>");
                //return new XmlResult("<postdata>/postdata>");
            }
            else
                return new XmlResult("<error>Invalid Request: " + this.HttpContext.Request.UserHostAddress + "</error>");
        }


        //Public method secured by IP and Authentication Token
        public XmlResult UpdateCreditMemosXML(string id) //id = authentication token
        {
            string inXML;
            using (var reader = new StreamReader(this.Request.InputStream))
            {
                inXML = reader.ReadToEnd();
            }
            if (id == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "192.168" || this.HttpContext.Request.UserHostAddress.Substring(0, 7) == "127.0.0"
                || this.HttpContext.Request.UserHostAddress == "96.254.199.75"
                || this.HttpContext.Request.UserHostAddress == "70.46.148.242"))
            {
                byte[] byteArray = Encoding.ASCII.GetBytes(inXML);
                MemoryStream memStream = new MemoryStream(byteArray);
                System.Data.DataSet ds = new System.Data.DataSet();
                ds.ReadXml(memStream);

                string strTransactionID;
                string strTransactionDate;
                string strAmount;
                //string strTotalAmount;
                string strCustomer;
                string strRefNumber;
                int CreditMemoTxn;
                Invoice relatedInvoice;
                if (ds.Tables.Contains("CreditMemoRet"))
                {
                    for (int CurRow2 = 0; CurRow2 < ds.Tables["LinkedTxn"].Rows.Count; CurRow2++)
                    {
                        CreditMemoTxn = (int)ds.Tables["LinkedTxn"].Rows[CurRow2].ItemArray[6];
                        strRefNumber = (string)ds.Tables["LinkedTxn"].Rows[CurRow2].ItemArray[3];
                        strAmount = (string)ds.Tables["LinkedTxn"].Rows[CurRow2].ItemArray[5];

                        strTransactionID = (string)ds.Tables["CreditMemoRet"].Rows[CreditMemoTxn].ItemArray[0];
                        strTransactionDate = (string)ds.Tables["CreditMemoRet"].Rows[CreditMemoTxn].ItemArray[2];
                        //strTotalAmount = (string)ds.Tables["CreditMemoRet"].Rows[CreditMemoTxn].ItemArray[1];

                        strCustomer = (string)ds.Tables["CustomerRef"].Rows[CreditMemoTxn].ItemArray[1];

                        var resultBillingContactID = Clients.GetFirstBillingContactFromBillAsClientName(strCustomer);

                        if (resultBillingContactID.HasValue)
                        {
                            relatedInvoice = Invoices.GetInvoiceFromInvoiceNumber(strRefNumber, resultBillingContactID.Value);

                            if (relatedInvoice != null)
                            {
                                Invoices.CreateNewCredit(DateTime.Parse(strTransactionDate), 0 - Decimal.Parse(strAmount), "", "", resultBillingContactID.Value, relatedInvoice.InvoiceID);
                            }
                            else
                            {
                                Invoices.CreateNewCredit(DateTime.Parse(strTransactionDate), 0 - Decimal.Parse(strAmount), "", "", resultBillingContactID.Value, 0);
                            }
                        }
                        else
                        {
                            Clients.LogAction("INVOICES_UpdateCreditMemosXML_NoBillingContact", "Cannot find a primary billing contact for BillAsClientName: " + strCustomer);
                        }
                        relatedInvoice = null;
                    }
                }

                string ErrorText = "";

                return new XmlResult("<postdata>" + ErrorText + "</postdata>");
            }
            else
                return new XmlResult("<error>Invalid Request: " + this.HttpContext.Request.UserHostAddress + "</error>");
        }


        //Void multiple invoices
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin_CanVoidInvoices")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult VoidInvoicesJSON(string InvoiceIDs)
        {
            int UserID = SecurityExtension.GetCurrentUserID(this);

            if (String.IsNullOrEmpty(InvoiceIDs))
            {
                return new JsonResult { Data = new { success = false } };
            }

            //split the ID's into an array
            string[] InvoiceIDsArray = InvoiceIDs.Split(',');

            //if there are any errors while creating the finance charges, return success = false
            try
            {
                foreach (var invoiceIDstring in InvoiceIDsArray)
                {
                    int invoiceID = Int32.Parse(invoiceIDstring);
                    Invoices.VoidInvoice(invoiceID, UserID);
                }
            }
            catch
            {
                return new JsonResult { Data = new { success = false } };
            }

            return new JsonResult { Data = new { success = true } };
        }


        //Release multiple invoices
        /*[ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult ReleaseInvoicesJSON(string InvoiceIDs)
        {
            if (String.IsNullOrEmpty(InvoiceIDs))
            {
                return new JsonResult { Data = new { success = false } };
            }

            //split the ID's into an array
            string[] InvoiceIDsArray = InvoiceIDs.Split(',');

            //if there are any errors while creating the finance charges, return success = false
            try
            {
                foreach (var invoiceIDstring in InvoiceIDsArray)
                {
                    int invoiceID = Int32.Parse(invoiceIDstring);
                    Invoices.ReleaseInvoice(invoiceID);
                }
            }
            catch
            {
                return new JsonResult { Data = new { success = false } };
            }

            return new JsonResult { Data = new { success = true } };
        }*/

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult ReleaseInvoicesJSON(string InvoiceIDs)
        {
            if (String.IsNullOrEmpty(InvoiceIDs))
            {
                return new JsonResult { Data = new { success = false } };
            }

            Clients.LogAction("INVOICES_ReleaseInvoicesJSON_Started", InvoiceIDs);

            //split the ID's into an array
            string[] InvoiceIDsArray = InvoiceIDs.Split(',');

            //if there are any errors, return success = false
            try
            {
                foreach (var invoiceIDstring in InvoiceIDsArray)
                {
                    int invoiceID = Int32.Parse(invoiceIDstring);
                    int emailresult = Invoices.ReleaseInvoice(invoiceID);
                }
            }
            catch
            {
                return new JsonResult { Data = new { success = false } };
            }

            return new JsonResult { Data = new { success = true } };
        }


        //Get a partial view with the list of related invoices
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult RelatedInvoices(int id) //id = InvoiceID
        {
            Invoices_RelatedInvoices viewInvoices_RelatedInvoices = new Invoices_RelatedInvoices();
            viewInvoices_RelatedInvoices.relatedInvoices = Invoices.GetRelatedInvoices(id);

            return View(viewInvoices_RelatedInvoices);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult CreateNewCredit()
        {
            Invoices_Credit viewInvoiced_Credit = new Invoices_Credit();

            viewInvoiced_Credit.InvoiceID = 0;
            viewInvoiced_Credit.PublicDescription = "";
            viewInvoiced_Credit.PrivateDescription = "";
            viewInvoiced_Credit.ClientID = 0;
            viewInvoiced_Credit.BillingContactID = 0;
            viewInvoiced_Credit.RelatedInvoiceID = 0;
            viewInvoiced_Credit.InvoiceAmount = 0.00M;
            viewInvoiced_Credit.InvoiceDate = DateTime.Now;
            viewInvoiced_Credit.ModifyCreditID = 0;

            return View(viewInvoiced_Credit);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult ModifyCredit(int id) //id = InvoiceID
        {
            Invoices_Credit viewInvoiced_Credit = new Invoices_Credit();

            Invoice creditInvoice = Invoices.GetInvoice(id);

            viewInvoiced_Credit.InvoiceID = id;
            viewInvoiced_Credit.PublicDescription = creditInvoice.ColumnHeaders[0]; //Col1Header contains PublicDescription
            viewInvoiced_Credit.PrivateDescription = creditInvoice.ColumnHeaders[1]; //Col2Header contains PrivateDescription
            viewInvoiced_Credit.ClientID = creditInvoice.ClientID;
            viewInvoiced_Credit.BillingContactID = creditInvoice.BillingContactID;
            viewInvoiced_Credit.RelatedInvoiceID = creditInvoice.RelatedInvoiceID;
            viewInvoiced_Credit.InvoiceAmount = creditInvoice.InvoiceAmount;
            viewInvoiced_Credit.InvoiceDate = creditInvoice.InvoiceDate;
            viewInvoiced_Credit.ModifyCreditID = id;

            return View("CreateNewCredit", viewInvoiced_Credit);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult SaveCreditJSON(DateTime InvoiceDate, decimal InvoiceAmount, string PublicDescription,
            string PrivateDescription, int BillingContactID, int RelatedInvoiceID, int ModifyCreditID)
        {
            if (ModifyCreditID > 0)
            {
                Invoices.ModifyCredit(ModifyCreditID, InvoiceDate, InvoiceAmount, PublicDescription, PrivateDescription, BillingContactID,
                    RelatedInvoiceID);
            }
            else
            {
                Invoices.CreateNewCredit(InvoiceDate, InvoiceAmount, PublicDescription, PrivateDescription, BillingContactID,
                    RelatedInvoiceID);
            }

            return new JsonResult { Data = new { success = true } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [HttpPost]
        public JsonResult GetUnpaidInvoicesForBillingContactForDropdown(int id) //id = BillingContactID
        {
            List<SelectListItem> clients = Invoices.GetUnpaidInvoicesForBillingContactForDropdown(id);

            var rows = clients.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };

        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult VerifyInvoiceSetup(DateTime StartTransactionDate, DateTime EndTransactionDate,
            DateTime InvoiceDate, int BillingGroup)
        {
            Invoices_VerifyInvoiceSetup invoices_VerifyInvoiceSetup = new Invoices_VerifyInvoiceSetup();
            invoices_VerifyInvoiceSetup.invoiceVerifySetups = Invoices.GetInvoiceVerifySetups(StartTransactionDate, EndTransactionDate,
                InvoiceDate, BillingGroup);

            return View(invoices_VerifyInvoiceSetup);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult VerifyInvoiceSetupForClient(DateTime StartTransactionDate, DateTime EndTransactionDate,
            DateTime InvoiceDate, int ClientID)
        {
            Invoices_VerifyInvoiceSetupForClient invoices_VerifyInvoiceSetupsForClient = new  Invoices_VerifyInvoiceSetupForClient();
            invoices_VerifyInvoiceSetupsForClient.invoiceVerifySetupsForClient = Invoices.GetInvoiceVerifySetupsForClient(StartTransactionDate, EndTransactionDate,
                InvoiceDate, ClientID);

            return View(invoices_VerifyInvoiceSetupsForClient);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [HttpPost]
        public JsonResult GetClientListAuditOnlyForDropdownJSON(string StartDate, string EndDate )
        {
            List<SelectListItem> clientListAuditOnly = Clients.GetClientsWithInvoicesForDropdownAuditOnly(Convert.ToDateTime(StartDate), Convert.ToDateTime(EndDate));

            var rows = clientListAuditOnly.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult GetClientListForDropdownJSON()
        {
            List<SelectListItem> clientList = Clients.GetClientListForDropdown();

            var rows = clientList.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult GetClientListNonAuditForDropdownJSON(string StartDate, string EndDate)
        {
            List<SelectListItem> clientList = Clients.GetClientsWithInvoicesForDropdownNonAudit(Convert.ToDateTime(StartDate), Convert.ToDateTime(EndDate));

            var rows = clientList.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult InvoiceAndPaymentBalancer()
        {
            var myModel = new Invoices_InvoiceAndPaymentBalancer();
            var nPlease = DateTime.Now;
            var endDate = nPlease.AddMonths(1);
            endDate = new DateTime(endDate.Year, endDate.Month, 1);
            endDate = endDate.AddDays(-1);
            var startDate = new DateTime(endDate.Year, endDate.Month, 1);
            myModel.ClientsSelectListItemList = Clients.GetClientSelectListItemListForInvoiceBalancer();
            myModel.StartDate = startDate;
            myModel.EndDate = endDate;
            return View(myModel);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult ComposeCurrentInvoiceReminder()
        {
            var myModel = new Invoices_ComposeCurrentInvoiceReminder();

            return View(myModel);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [ValidateInput(false)]
        [HttpPost]
        public ActionResult ComposeCurrentInvoiceReminder(Invoices_ComposeCurrentInvoiceReminder myModel)
        {
            if (!String.IsNullOrEmpty(Request["btnPreviewEmail"]))
            {
                Invoices.PreviewCurrentInvoiceReminder(m_UserID, myModel.Subject, myModel.Message);
                return RedirectToAction("PreviewCurrentInvoiceReminders");
            }

            return View(myModel);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult PreviewCurrentInvoiceReminders()
        {
            var myModel = new Invoices_CurrentInvoiceRemindersToSend();
            return View(myModel);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [ValidateInput(false)]
        [HttpPost]
        public ActionResult PreviewCurrentInvoiceReminders(Invoices_CurrentInvoiceRemindersToSend myModel)
        {
            if (!String.IsNullOrEmpty(Request["btnSendEmail"]))
            {
                Invoices.SendCurrentInvoiceReminder();
                return RedirectToAction("CurrentInvoiceRemindersSent");
            }

            if (!String.IsNullOrEmpty(Request["btnCancel"]))
            {
                Invoices.TruncateCurrentInvoiceReminder();
            }

            myModel = new Invoices_CurrentInvoiceRemindersToSend();

            return View(myModel);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult RemovePreviewMessageForCurrentInvoiceJSON(Guid? messageGuid)
        {
            string message = "";
            try
            {
                Invoices.RemovePreviewMessageForCurrentInvoice(messageGuid.Value);
                return new JsonResult { Data = new { success = true, messageGuid = messageGuid.Value } };
            }
            catch (Exception ex)
            {
                message = ex.Message;
            }

            return new JsonResult { Data = new { success = false, message = message } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult CurrentInvoiceRemindersSent()
        {
            var myModel = new Invoices_CurrentInvoiceRemindersSent();

            return View(myModel);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult ComposeOverdueInvoiceReminder()
        {
            var myModel = new Invoices_ComposeOverdueInvoiceReminder();
            return View(myModel);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [ValidateInput(false)]
        [HttpPost]
        public ActionResult ComposeOverdueInvoiceReminder(Invoices_ComposeOverdueInvoiceReminder myModel)
        {
            if (!String.IsNullOrEmpty(Request["btnPreviewEmail"]))
            {
                Invoices.PreviewOverdueInvoiceReminder(m_UserID, myModel.Subject, myModel.Message, myModel.UserFinanceChargeDate);
                return RedirectToAction("PreviewOverdueInvoiceReminders");
            }
            myModel = new Invoices_ComposeOverdueInvoiceReminder();
            return View(myModel);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult PreviewOverdueInvoiceReminders()
        {
            var myModel = new Invoices_OverdueInvoiceRemindersToSend();

            return View(myModel);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [ValidateInput(false)]
        [HttpPost]
        public ActionResult PreviewOverdueInvoiceReminders(Invoices_OverdueInvoiceRemindersToSend myModel)
        {
            if (!String.IsNullOrEmpty(Request["btnSendEmail"]))
            {
                Invoices.SendOverdueInvoiceReminder();
                return RedirectToAction("OverdueInvoiceRemindersSent");
            }

            if (!String.IsNullOrEmpty(Request["btnCancel"]))
            {
                Invoices.TruncateOverdueInvoiceReminder();
            }

            myModel = new Invoices_OverdueInvoiceRemindersToSend();
            return View(myModel);
        }
        
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult RemovePreviewMessageForOverdueInvoiceJSON(Guid? messageGuid)
        {
            string message = "";
            try
            {
                Invoices.RemovePreviewMessageForOverdueInvoice(messageGuid.Value);
                return new JsonResult { Data = new { success = true, messageGuid = messageGuid.Value } };
            }
            catch (Exception ex)
            {
                message = ex.Message;
            }

            return new JsonResult { Data = new { success = false, message = message } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult OverdueInvoiceRemindersSent()
        {
            var myModel = new Invoices_OverdueInvoiceRemindersSent();

            return View(myModel);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult GetPaymentsForInvoiceBalancerJSON(int clientID, DateTime? startDate, DateTime? endDate)
        {
            try
            {
                var paymentList = Invoices.GetPaymentsForInvoiceBalancer(clientID, startDate, endDate);
                var payList = (from r in paymentList
                               select new
                               {
                                   RootParentClientID = r.RootParentClientID.HasValue ? r.RootParentClientID.Value.ToString() : "",
                                   ParentClientID = r.ParentClientID.HasValue ? r.ParentClientID.Value.ToString() : "",
                                   ParentClientName = !String.IsNullOrEmpty(r.ParentClientName) ? r.ParentClientName : "",
                                   ClientID = r.ClientID.HasValue ? r.ClientID.Value.ToString() : "",
                                   ClientName = !String.IsNullOrEmpty(r.ClientName) ? r.ClientName : "",
                                   IsPaymentContact = r.IsPaymentContact.HasValue ? r.IsPaymentContact.Value.ToString() : "",
                                   ClientContactID = r.ClientContactID.HasValue ? r.ClientContactID.Value.ToString() : "",
                                   ContactLastName = !String.IsNullOrEmpty(r.ContactLastName) ? r.ContactLastName : "",
                                   ContactFirstName = !String.IsNullOrEmpty(r.ContactFirstName) ? r.ContactFirstName : "",
                                   PaymentID = r.PaymentID.HasValue ? r.PaymentID.Value.ToString() : "",
                                   BillingContactID = r.BillingContactID.HasValue ? r.BillingContactID.Value.ToString() : "",
                                   Date = r.Date.HasValue ? r.Date.Value.ToString("MM/dd/yyyy") : "",
                                   TotalAmount = r.TotalAmount.HasValue ? r.TotalAmount.Value.ToString("c2") : "",
                                   PaymentMethodID = r.PaymentMethodID.HasValue ? r.PaymentMethodID.Value.ToString() : "",
                                   CheckNumber = !String.IsNullOrEmpty(r.CheckNumber) ? r.CheckNumber : "",
                                   QBTransactionID = !String.IsNullOrEmpty(r.QBTransactionID) ? r.QBTransactionID : "",
                                   IsPaymentInvoice = r.IsPaymentInvoice.HasValue ? r.IsPaymentInvoice.Value.ToString() : "",
                                   InvoiceID = r.InvoiceID.HasValue ? r.InvoiceID.Value.ToString() : "",
                                   InvoiceNumber = !String.IsNullOrEmpty(r.InvoiceNumber) ? r.InvoiceNumber : "",
                                   InvoiceDate = r.InvoiceDate.HasValue ? r.InvoiceDate.Value.ToString("MM/dd/yyyy") : "",
                                   InvoiceTypeID = r.InvoiceTypeID.HasValue ? r.InvoiceTypeID.Value.ToString() : "",
                                   BillTo = !String.IsNullOrEmpty(r.BillTo) ? r.BillTo : "",
                                   POName = !String.IsNullOrEmpty(r.POName) ? r.POName : "",
                                   PONumber = !String.IsNullOrEmpty(r.PONumber) ? r.PONumber : "",
                                   Amount = r.Amount.HasValue ? r.Amount.Value.ToString("c2") : "",
                                   InvoiceExported = r.InvoiceExported.HasValue ? r.InvoiceExported.Value.ToString() : "",
                                   InvoiceExportedOn = r.InvoiceExportedOn.HasValue ? r.InvoiceExportedOn.Value.ToString("MM/dd/yyyy") : "",
                                   RelatedInvoiceID = r.RelatedInvoiceID.HasValue ? r.RelatedInvoiceID.Value.ToString() : "",
                                   DontShowOnStatement = r.DontShowOnStatement.HasValue ? r.DontShowOnStatement.Value.ToString() : "",
                                   InvoicePaymentID = r.InvoicePaymentID.HasValue ? r.InvoicePaymentID.Value.ToString() : "",
                                   IpQBTransactionID = !String.IsNullOrEmpty(r.IpQBTransactionID) ? r.IpQBTransactionID : "",
                                   IpAmount = r.IpAmount.HasValue ? r.IpAmount.Value.ToString("c2") : ""
                               }).ToList();

                List<PaymentForBalancer> paymentForBalancerList = new List<PaymentForBalancer>();
                Dictionary<string, List<PaymentContactForBalancer>> clientContacts = new Dictionary<string, List<PaymentContactForBalancer>>();
                Dictionary<string, List<InvoiceForBalancer>> clientInvoices = new Dictionary<string, List<InvoiceForBalancer>>();
                if (payList.Count > 0)
                {
                    string lastPayClientID = "";
                    string lastPaymentID = "";
                    PaymentForBalancer currentPayment = null;
                    foreach (var pay in payList)
                    {
                        if (lastPayClientID != pay.ClientID ||
                            lastPaymentID != pay.PaymentID)
                        {
                            var pmy = pay.PaymentID != "" ? paymentForBalancerList.Find(delegate(PaymentForBalancer find) { return find.PaymentID == pay.PaymentID; }) : paymentForBalancerList.Find(delegate(PaymentForBalancer find) { return find.ClientID == pay.ClientID; });

                            if (pmy == null)
                            {
                                currentPayment = new PaymentForBalancer(pay.RootParentClientID,
                                                                        pay.ParentClientID,
                                                                        pay.ParentClientName,
                                                                        pay.ClientID,
                                                                        pay.ClientName,
                                                                        pay.PaymentID,
                                                                        pay.Date,
                                                                        pay.TotalAmount,
                                                                        pay.PaymentMethodID,
                                                                        pay.CheckNumber,
                                                                        pay.QBTransactionID,
                                                                        new List<PaymentContactForBalancer>(),
                                                                        new List<InvoiceForBalancer>());

                                paymentForBalancerList.Add(currentPayment);
                            }
                            else
                            {
                                currentPayment = pmy;
                            }

                            lastPayClientID = pay.ClientID;
                            lastPaymentID = pay.PaymentID;
                        }

                        if (!clientContacts.ContainsKey(pay.ClientID))
                        {
                            clientContacts.Add(pay.ClientID, new List<PaymentContactForBalancer>());
                        }

                        if (!clientInvoices.ContainsKey(pay.ClientID))
                        {
                            clientInvoices.Add(pay.ClientID, new List<InvoiceForBalancer>());
                        }

                        if (pay.ClientContactID != "" && clientContacts[pay.ClientID].Find(delegate(PaymentContactForBalancer paymentContactForBalancer) { return paymentContactForBalancer.ClientContactID == pay.ClientContactID; }) == null)
                        {
                            clientContacts[pay.ClientID].Add(new PaymentContactForBalancer(pay.ClientContactID,
                                                                                           pay.BillingContactID,
                                                                                           pay.ContactLastName,
                                                                                           pay.ContactFirstName,
                                                                                           pay.IsPaymentContact,
                                                                                           pay.PaymentID,
                                                                                           pay.ClientID));
                        }

                        if (pay.ClientContactID != "" && pay.IsPaymentContact.ToLower() == "true")
                        {
                            int indexFound = currentPayment.ClientContacts.FindIndex(delegate(PaymentContactForBalancer paymentContactForBalancer) { return paymentContactForBalancer.ClientContactID == pay.ClientContactID; });
                            if (indexFound < 0)
                            {
                                currentPayment.ClientContacts.Add(new PaymentContactForBalancer(pay.ClientContactID,
                                                                                                pay.BillingContactID,
                                                                                                pay.ContactLastName,
                                                                                                pay.ContactFirstName,
                                                                                                pay.IsPaymentContact,
                                                                                                pay.PaymentID,
                                                                                                pay.ClientID));
                            }
                        }

                        if (pay.InvoiceID != "" && clientInvoices[pay.ClientID].Find(delegate(InvoiceForBalancer invoiceForBalancer) { return invoiceForBalancer.InvoiceID == pay.InvoiceID; }) == null)
                        {
                            clientInvoices[pay.ClientID].Add(new InvoiceForBalancer(pay.InvoiceID,
                                                                                    pay.InvoiceNumber,
                                                                                    pay.InvoiceDate,
                                                                                    pay.InvoiceTypeID,
                                                                                    pay.BillTo,
                                                                                    pay.POName,
                                                                                    pay.PONumber,
                                                                                    pay.Amount,
                                                                                    pay.InvoiceExported,
                                                                                    pay.InvoiceExportedOn,
                                                                                    pay.RelatedInvoiceID,
                                                                                    pay.DontShowOnStatement,
                                                                                    pay.IsPaymentInvoice,
                                                                                    pay.PaymentID,
                                                                                    pay.ClientID,
                                                                                    pay.IpQBTransactionID,
                                                                                    pay.IpAmount));
                        }

                        if (pay.InvoiceID != "" && pay.IsPaymentInvoice.ToLower() == "true")
                        {
                            int indexFound = currentPayment.Invoices.FindIndex(delegate(InvoiceForBalancer invoiceForBalancer) { return invoiceForBalancer.InvoiceID == pay.InvoiceID; });
                            if (indexFound < 0)
                            {
                                currentPayment.Invoices.Add(new InvoiceForBalancer(pay.InvoiceID,
                                                                                   pay.InvoiceNumber,
                                                                                   pay.InvoiceDate,
                                                                                   pay.InvoiceTypeID,
                                                                                   pay.BillTo,
                                                                                   pay.POName,
                                                                                   pay.PONumber,
                                                                                   pay.Amount,
                                                                                   pay.InvoiceExported,
                                                                                   pay.InvoiceExportedOn,
                                                                                   pay.RelatedInvoiceID,
                                                                                   pay.DontShowOnStatement,
                                                                                   pay.IsPaymentInvoice,
                                                                                   pay.PaymentID,
                                                                                   pay.ClientID,
                                                                                   pay.IpQBTransactionID,
                                                                                   pay.IpAmount));
                            }
                        }

                    }

                    foreach (var payment in paymentForBalancerList)
                    {
                        var newClientContactsList = clientContacts[payment.ClientID].ToArray().ToList();

                        foreach (var ccon in newClientContactsList)
                        {
                            ccon.IsPaymentContact = "";
                            ccon.PaymentID = "";
                        }

                        foreach (var ccon in payment.ClientContacts)
                        {
                            int i = newClientContactsList.FindIndex(delegate(PaymentContactForBalancer find)
                            {
                                return find.ClientContactID == ccon.ClientContactID;
                            });

                            if (i >= 0)
                            {
                                newClientContactsList[i] = ccon;
                            }
                        }

                        payment.ClientContacts = newClientContactsList;

                        var newInvoicesList = clientInvoices[payment.ClientID].ToArray().ToList();

                        foreach (var invp in newInvoicesList)
                        {
                            invp.IsPaymentInvoice = "";
                            invp.PaymentID = "";
                            invp.IpQBTransactionID = "";
                            invp.IpAmount = "";
                        }

                        foreach (var invp in payment.Invoices)
                        {
                            int i = newInvoicesList.FindIndex(delegate(InvoiceForBalancer find)
                            {
                                return find.InvoiceID == invp.InvoiceID;
                            });

                            if (i >= 0)
                            {
                                newInvoicesList[i] = invp;
                            }
                        }

                        payment.Invoices = newInvoicesList;
                    }
                }

                var rows = (from r in paymentForBalancerList
                            select new
                            {
                                RootParentClientID = r.RootParentClientID,
                                ParentClientID = r.ParentClientID,
                                ParentClientName = r.ParentClientName,
                                ClientID = r.ClientID,
                                ClientName = r.ClientName,
                                PaymentID = r.PaymentID,
                                Date = r.Date,
                                TotalAmount = r.TotalAmount,
                                PaymentMethodID = r.PaymentMethodID,
                                CheckNumber = r.CheckNumber,
                                QBTransactionID = r.QBTransactionID,
                                ClientContacts = r.ClientContacts.ToArray(),
                                Invoices = r.Invoices.ToArray()
                            }).ToArray();

                var result = new JsonResult { Data = new { success = true, rows = rows } };

                result.MaxJsonLength = Int32.MaxValue;

                return result;
            }
            catch (Exception ex) 
            {
                return new JsonResult { Data = new { success = false, errorMessage = ex.Message } };
            }            
        }

        //NOT CURRENTLY USED
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [HttpPost]
        public JsonResult GetBillingGroupsForDropdownJSON()
        {
            List<SelectListItem> billingGroups = Invoices.GetBillingGroupList();

            var rows = billingGroups.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }

    }
}
