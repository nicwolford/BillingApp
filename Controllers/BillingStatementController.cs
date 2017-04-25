//#define DEBUG_EMAIL

using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Security.Principal;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using System.Web.Security;
using ExpertPdf.HtmlToPdf;
using ScreeningONE.Objects;
using ScreeningONE.DomainModels;
using ScreeningONE.ViewModels;
using System.Threading;
using Ionic.Zip;
using System.Text;
using System.Text.RegularExpressions;
using StringExtensions;
using System.Configuration;

namespace ScreeningONE.Controllers
{

    public class BillingStatementController : S1BaseController
    {
        //
        // GET: /BillingStatement/
        public BillingStatementController()
            : this(null, null)
        {
        }

        public BillingStatementController(IFormsAuthentication formsAuth, MembershipProvider provider)
        {
            FormsAuth = formsAuth ?? new FormsAuthenticationWrapper();
            Provider = provider ?? Membership.Provider;
        }

        public IFormsAuthentication FormsAuth
        {
            get;
            private set;
        }

        public MembershipProvider Provider
        {
            get;
            private set;
        }

        [ScreeningONEAuthorize(Portal = "Client", Roles = "Client_Billing")]
        public ActionResult Index(int id) //id = BillingContactID
        {
            if (!Security.UserCanAccessBillingContact(m_UserID, id))
            {
                return RedirectToAction("Index", "Home");
            }

            int BillingContactID = id;

            DateTime StartDate, EndDate;
            StartDate = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 2);
            EndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            //StartDate = new DateTime(2010,8,2);
            //EndDate = new DateTime(2010,9,1);

            BillingStatement_Index viewBillingStatement_Index = new BillingStatement_Index();
            viewBillingStatement_Index.BillingContactID = BillingContactID;
            viewBillingStatement_Index.ClientView = true;
            viewBillingStatement_Index.BillingStatement =
                BillingStatements.GetCurrentBillingStatement(BillingContactID, StartDate, EndDate);

            viewBillingStatement_Index.StatementDate = EndDate;
            viewBillingStatement_Index.toPrint = false;
            return View(viewBillingStatement_Index);
        }


        public ActionResult Index_Public(int id) //id = BillingContactID
        {

            int BillingContactID = id;

            DateTime StartDate, EndDate;
            StartDate = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 2);
            EndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            //StartDate = new DateTime(2010,8,2);
            //EndDate = new DateTime(2010,9,1);

            BillingStatement_Index viewBillingStatement_Index = new BillingStatement_Index();
            viewBillingStatement_Index.BillingContactID = BillingContactID;
            viewBillingStatement_Index.ClientView = true;
            viewBillingStatement_Index.BillingStatement =
                BillingStatements.GetCurrentBillingStatement(BillingContactID, StartDate, EndDate);

            viewBillingStatement_Index.StatementDate = EndDate;
            viewBillingStatement_Index.toPrint = false;

            return View(viewBillingStatement_Index);
        }

        [ScreeningONEAuthorize(Portal = "Client", Roles = "Client_Billing")]
        public ActionResult RenderBillingStatementToPrint(int id) //id = BillingContactID
        {
            DateTime StartDate, EndDate;
            StartDate = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 2);
            EndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);

            return RenderBillingStatementToPrintAction(id, EndDate.ToString());
        }

        [ScreeningONEAuthorize(Portal = "Client", Roles = "Client_Billing")]
        public ActionResult RenderBillingStatementToPrintWithDate(int id, string StatementDate) //id = BillingContactID
        {
            return RenderBillingStatementToPrintAction(id, StatementDate);
        }

        public ActionResult RenderBillingStatementToPrintWithDate_Public(int id, string StatementDate) //id = BillingContactID
        {
            return RenderBillingStatementToPrintAction_Public(id, StatementDate);
        }

        [ScreeningONEAuthorize(Portal = "Client", Roles = "Client_Billing")]
        public ActionResult RenderBillingStatementToPrintAction(int id, string StatementDate) //id = BillingContactID
        {
            //Mode 1
            if (!Security.UserCanAccessBillingContact(m_UserID, id))
            {
                return RedirectToAction("Index", "Home");
            }

            int BillingContactID = id;

            DateTime StartDate, EndDate;
            EndDate = Convert.ToDateTime(StatementDate);
            StartDate = new DateTime(EndDate.AddMonths(-1).Year, EndDate.AddMonths(-1).Month, 2);

            //StartDate = new DateTime(2010,8,2);
            //EndDate = new DateTime(2010,9,1);

            BillingStatement_Index viewBillingStatement_Index = new BillingStatement_Index();
            viewBillingStatement_Index.BillingContactID = BillingContactID;
            viewBillingStatement_Index.ClientView = true;
            viewBillingStatement_Index.BillingStatement =
                BillingStatements.GetCurrentBillingStatement(BillingContactID, StartDate, EndDate);

            viewBillingStatement_Index.StatementDate = EndDate;
            viewBillingStatement_Index.toPrint = true;

            return View("Index", "Print", viewBillingStatement_Index);
        }

        public ActionResult RenderBillingStatementToPrintAction_Public(int id, string StatementDate) //id = BillingContactID
        {
            //Mode3

            // if (!Security.UserCanAccessBillingContact(m_UserID, id))
            // {
            //     return RedirectToAction("Index", "Home");
            // }

            int BillingContactID = id;

            DateTime StartDate, EndDate;
            EndDate = Convert.ToDateTime(StatementDate);
            StartDate = new DateTime(EndDate.AddMonths(-1).Year, EndDate.AddMonths(-1).Month, 2);

            //StartDate = new DateTime(2010,8,2);
            //EndDate = new DateTime(2010,9,1);

            BillingStatement_Index viewBillingStatement_Index = new BillingStatement_Index();
            viewBillingStatement_Index.BillingContactID = BillingContactID;
            viewBillingStatement_Index.ClientView = true;
            viewBillingStatement_Index.BillingStatement =
                BillingStatements.GetCurrentBillingStatement(BillingContactID, StartDate, EndDate);

            viewBillingStatement_Index.StatementDate = EndDate;
            viewBillingStatement_Index.toPrint = true;

            return View("Index_Public", "Print", viewBillingStatement_Index);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult RenderBillingStatementToPrintAdmin(int id) //id = BillingContactID
        {
            //Mode 2
            int BillingContactID = id;

            DateTime StartDate, EndDate;
            StartDate = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 2);
            EndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            //StartDate = new DateTime(2010,10,2);
            //EndDate = new DateTime(2010,11,1);

            BillingStatement_Index viewBillingStatement_Index = new BillingStatement_Index();
            viewBillingStatement_Index.BillingContactID = BillingContactID;
            viewBillingStatement_Index.ClientView = true;
            viewBillingStatement_Index.BillingStatement =
                BillingStatements.GetCurrentBillingStatement(BillingContactID, StartDate, EndDate);

            viewBillingStatement_Index.StatementDate = EndDate;
            viewBillingStatement_Index.toPrint = true;

            return View("Index", "Print", viewBillingStatement_Index);
        }

        [ScreeningONEAuthorize(Portal = "Client", Roles = "Client_Billing")]
        public FileContentResult PrintBillingStatementToPDF(int id) //id = BillingContactID
        {
            PdfConverter pdf = new PdfConverter();
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

            //pdf.HttpRequestHeaders = "Cookie: name=" + AuthValue;
            pdf.HttpRequestHeaders = String.Format(
                "Cookie : {0}={1}\r\n", AuthName, AuthValue
            );

            string UrlToPDF = "";

            if (!Security.UserCanAccessBillingContact(m_UserID, id))
            {
                UrlToPDF = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"] //"http://screeningone.com:8080/" /*"http://localhost:1225"*/ /*"http://s1-tpa-dv1:82/"*/
                    + Url.Action("Unauthorized", "Home", new { mstr = "Print" });
            }
            else
            {
                UrlToPDF = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"] //"http://screeningone.com:8080/" /*"http://localhost:1225"*/ /*"http://s1-tpa-dv1:82/"*/
                    + Url.Action("BillingStatmentIndexMode1", "PDF", new { id = id });
            }

            DateTime StartDate, EndDate;
            StartDate = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 2);
            EndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);

            BillingStatement billingStatement = BillingStatements.GetCurrentBillingStatement(id, StartDate, EndDate);

            FileContentResult fcr = new FileContentResult(pdf.GetPdfFromUrlBytes(UrlToPDF), "application/PDF");
            fcr.FileDownloadName = billingStatement.billingContact.BillAsClientName + "_" + EndDate.Year.ToString()
                + EndDate.Month.ToString() + "_BillingStatement.pdf";
            return fcr;
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public FileContentResult PrintPackageToPDF(int id) //id = BillingContactID
        {
            DateTime StartDate, EndDate;
            StartDate = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 2);
            EndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            //StartDate = new DateTime(2010, 8, 2);
            //EndDate = new DateTime(2010, 9, 1);

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

            //pdf.HttpRequestHeaders = "Cookie: name=" + AuthValue;
            pdf.HttpRequestHeaders = String.Format(
                "Cookie : {0}={1}\r\n", AuthName, AuthValue
            );

            List<CurrentInvoice> invoicesToAppend = BillingStatements.GetBillingStatementListCurrentInvoices(id, StartDate, EndDate);
            int invoicesCount = 0;

            //Count the number of PDF's to append
            foreach (CurrentInvoice invoice in invoicesToAppend)
            {
                invoicesCount++;
                Invoice invoiceToExport = Invoices.GetInvoice(invoice.InvoiceID);
                if (invoiceToExport.BillingReportGroupID > 0)
                {
                    invoicesCount++;
                }
            }

            string UrlToPDF = "";
            //If this is a secondary contact
            if ((!ClientContacts.GetClientContactFromBillingContactID(id).IsPrimaryBillingContact && BillingStatements.GetSpecialPrimaryBillingContact(id).ToString() == "0") || ClientContacts.GetClientContactFromBillingContactID(id).OnlyShowInvoices)
            {

                //If the billing statement is hidden for the primary and there are no invoices, show an error message in the PDF
                if (ClientContacts.GetClientContactFromBillingContactID(id).IsPrimaryBillingContact && invoicesCount == 0)
                {
                    
                    UrlToPDF = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"] //"http://screeningone.com:8080/" /*"http://localhost:1225"*/ /*"http://s1-tpa-dv1:82/"*/                            
                    + Url.Action("BillingStatmentIndexMode2", "PDF", new { id = id });

                    BillingStatement billingStatement1 = BillingStatements.GetCurrentBillingStatement(id, StartDate, EndDate);

                    FileContentResult fcr1 = new FileContentResult(pdf.GetPdfFromUrlBytes(UrlToPDF), "application/PDF");
                    fcr1.FileDownloadName = (billingStatement1.billingContact.BillAsClientName + "_" + EndDate.Year.ToString()
                        + EndDate.Month.ToString()).cleanFileName() + "_Billing.pdf";
                    return fcr1;
                    // System.Text.ASCIIEncoding encoding = new System.Text.ASCIIEncoding();
                    // FileContentResult fcr1 = new FileContentResult(encoding.GetBytes("This customer contains no invoices and the billing statement is hidden."), "text/html");
                    // return fcr1;
                }

                if (invoicesToAppend.Count > 0)
                {
                    CurrentInvoice FirstInvoice = invoicesToAppend.First();

                    UrlToPDF = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"] //"http://screeningone.com:8080/" /*"http://localhost:1225"*/ /*"http://s1-tpa-dv1:82/"*/                            
                        + Url.Action("InvoicesDetailsMode4", "PDF", new { id = FirstInvoice.InvoiceID });

                    Invoice invoiceToExportSecondary = Invoices.GetInvoice(FirstInvoice.InvoiceID);

                    invoicesToAppend.RemoveAt(0);

                    if (invoiceToExportSecondary.BillingReportGroupID > 0)
                    {
                        //Billing Detail Report
                        PdfConverter pdf2 = new PdfConverter();
                        //pdf2.PdfDocumentOptions.PdfPageSize = PdfPageSize.Letter;
                        pdf2.PdfDocumentOptions.BottomMargin = 40;
                        pdf2.PdfDocumentOptions.TopMargin = 40;
                        pdf2.PdfDocumentOptions.LeftMargin = 50;
                        pdf2.PdfDocumentOptions.RightMargin = 50;
                        pdf2.PdfDocumentOptions.PdfPageOrientation = PDFPageOrientation.Landscape;
                        pdf2.PdfDocumentOptions.ShowFooter = true;
                        pdf2.PdfFooterOptions.ShowPageNumber = true;

                        pdf2.HttpRequestHeaders = String.Format(
                            "Cookie : {0}={1}\r\n", AuthName, AuthValue
                        );
                        pdf2.LicenseKey = "q4CZi5qai5Oci5KFm4uYmoWamYWSkpKS";

                        string UrlToPDF2 = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"]
                            + Url.Action("InvoiceReportsIndexMode5", "PDF", new { InvoiceID = FirstInvoice.InvoiceID, GroupID = invoiceToExportSecondary.BillingReportGroupID });

                        pdf.PdfDocumentOptions.AppendPDFStream = new System.IO.MemoryStream();
                        pdf2.SavePdfFromUrlToStream(UrlToPDF2, pdf.PdfDocumentOptions.AppendPDFStream);
                        pdf.PdfFooterOptions.PageNumberingPageCountIncrement = (0 - pdf2.ConversionSummary.PdfPageCount);
                    }
                }
                else
                {
                    return null;
                }
            }
            else
            {
                UrlToPDF = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"] //"http://screeningone.com:8080/" /*"http://localhost:1225"*/ /*"http://s1-tpa-dv1:82/"*/                            
                    + Url.Action("BillingStatmentIndexMode2", "PDF", new { id = id });

                PdfConverter[] pdfs = new PdfConverter[invoicesCount];
                if (invoicesToAppend.Count > 0)
                {
                    pdf.PdfDocumentOptions.AppendPDFStreamArray = new System.IO.MemoryStream[invoicesCount];

                    int CurStream = 0;
                    foreach (CurrentInvoice invoice in invoicesToAppend)
                    {
                        Invoice invoiceToExport = Invoices.GetInvoice(invoice.InvoiceID);

                        //Invoice
                        pdfs[CurStream] = new PdfConverter();
                        //pdfs[CurStream].PdfDocumentOptions.PdfPageSize = PdfPageSize.Letter;
                        pdfs[CurStream].PdfDocumentOptions.BottomMargin = 0;
                        pdfs[CurStream].PdfDocumentOptions.TopMargin = 15;
                        pdfs[CurStream].PdfDocumentOptions.LeftMargin = 10;
                        pdfs[CurStream].PdfDocumentOptions.RightMargin = 10;
                        pdfs[CurStream].PdfDocumentOptions.PdfPageOrientation = PDFPageOrientation.Portrait;
                        pdfs[CurStream].PdfDocumentOptions.ShowFooter = true;
                        pdfs[CurStream].PdfFooterOptions.ShowPageNumber = true;

                        pdfs[CurStream].HttpRequestHeaders = String.Format(
                            "Cookie : {0}={1}\r\n", AuthName, AuthValue
                        );
                        pdfs[CurStream].LicenseKey = "q4CZi5qai5Oci5KFm4uYmoWamYWSkpKS";

                        string UrlToPDF3 = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"]
                            + Url.Action("InvoicesDetailsMode4", "PDF", new { id = invoice.InvoiceID });

                        pdf.PdfDocumentOptions.AppendPDFStreamArray[CurStream] = new System.IO.MemoryStream();
                        pdfs[CurStream].SavePdfFromUrlToStream(UrlToPDF3, pdf.PdfDocumentOptions.AppendPDFStreamArray[CurStream]);
                        pdf.PdfFooterOptions.PageNumberingPageCountIncrement = (0 - pdfs[CurStream].ConversionSummary.PdfPageCount);
                        CurStream++;


                        if (invoiceToExport.BillingReportGroupID > 0)
                        {
                            //Billing Detail Report
                            pdfs[CurStream] = new PdfConverter();
                            //pdfs[CurStream].PdfDocumentOptions.PdfPageSize = PdfPageSize.Letter;
                            pdfs[CurStream].PdfDocumentOptions.BottomMargin = 40;
                            pdfs[CurStream].PdfDocumentOptions.TopMargin = 40;
                            pdfs[CurStream].PdfDocumentOptions.LeftMargin = 50;
                            pdfs[CurStream].PdfDocumentOptions.RightMargin = 50;
                            pdfs[CurStream].PdfDocumentOptions.PdfPageOrientation = PDFPageOrientation.Landscape;
                            pdfs[CurStream].PdfDocumentOptions.ShowFooter = true;
                            pdfs[CurStream].PdfFooterOptions.ShowPageNumber = true;

                            pdfs[CurStream].HttpRequestHeaders = String.Format(
                                "Cookie : {0}={1}\r\n", AuthName, AuthValue
                            );
                            pdfs[CurStream].LicenseKey = "q4CZi5qai5Oci5KFm4uYmoWamYWSkpKS";

                            string UrlToPDF2 = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"]
                                + Url.Action("InvoiceReportsIndexMode5", "PDF", new { InvoiceID = invoice.InvoiceID, GroupID = invoiceToExport.BillingReportGroupID });

                            pdf.PdfDocumentOptions.AppendPDFStreamArray[CurStream] = new System.IO.MemoryStream();
                            pdfs[CurStream].SavePdfFromUrlToStream(UrlToPDF2, pdf.PdfDocumentOptions.AppendPDFStreamArray[CurStream]);
                            pdf.PdfFooterOptions.PageNumberingPageCountIncrement = (0 - pdfs[CurStream].ConversionSummary.PdfPageCount);
                            CurStream++;
                        }
                    }
                }
            }

            /*if (invoicesToAppend.Count > 0)
                pdf.PdfDocumentOptions.AppendPDFStreamArray = pdfStreams.ToArray();            
             */

            BillingStatement billingStatement = BillingStatements.GetCurrentBillingStatement(id, StartDate, EndDate);

            FileContentResult fcr = new FileContentResult(pdf.GetPdfFromUrlBytes(UrlToPDF), "application/PDF");
            fcr.FileDownloadName = (billingStatement.billingContact.BillAsClientName + "_" + EndDate.Year.ToString()
                + EndDate.Month.ToString()).cleanFileName() + "_Billing.pdf";
            return fcr;
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public FileContentResult ZipInvoices(string BillingContactIDs) //comma seperated invoiceids
        {

            if (String.IsNullOrEmpty(BillingContactIDs))
            {
                byte[] nodata = Encoding.UTF8.GetBytes("nodata");
                FileContentResult fcr = new FileContentResult(nodata, "application/text");
                fcr.FileDownloadName = "nodata.txt";
                return fcr;
            }

            //split the ID's into an array
            string[] BillingContactIDsArray = BillingContactIDs.Split(',');
            bool hasData = false;
            using (ZipFile zip = new ZipFile())
            {
                foreach (var BillingContactIDstring in BillingContactIDsArray)
                {
                    FileContentResult pdfFile = null;
                    pdfFile = PrintPackageToPDF(int.Parse(BillingContactIDstring));
                    if (pdfFile != null && pdfFile.FileContents.LongLength > 0)
                    {
                        int suffixi = 1;

                        while (zip[pdfFile.FileDownloadName] != null && zip[pdfFile.FileDownloadName.Replace(".pdf", suffixi.ToString() + ".pdf")] != null)
                        {
                            suffixi ++;


                        }
                        if (zip[pdfFile.FileDownloadName] == null)
                        {
                            zip.AddEntry(pdfFile.FileDownloadName, pdfFile.FileContents);
                            hasData = true;
                        }
                        else if (zip[pdfFile.FileDownloadName.Replace(".pdf", suffixi.ToString() + ".pdf")] == null)
                        {
                            zip.AddEntry(pdfFile.FileDownloadName.Replace(".pdf", suffixi.ToString() + ".pdf"), pdfFile.FileContents);
                            hasData = true;
                        }
                    }
                }
                if (hasData)
                {
                    string fileName = ("Invoices" + DateTime.Now.ToString()).cleanFileName() + ".zip";
                    fileName = "attachment;filename=" + fileName;
                    Response.Clear();
                    Response.ContentType = "application/zip";
                    Response.AddHeader("Content-Disposition", fileName);
                    zip.Save(Response.OutputStream);
                }
                else
                {
                    byte[] nodata = Encoding.UTF8.GetBytes("nodata");
                    FileContentResult fcr = new FileContentResult(nodata, "application/text");
                    fcr.FileDownloadName = "nodata.txt";
                    return fcr;
                }
            }
            return null;
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public FileContentResult MakeAnEmlFile(string BillingContactID) //comma seperated invoiceids
        {
            DateTime nowPlease = DateTime.Now;

            if (String.IsNullOrEmpty(BillingContactID))
            {
                byte[] nodata = Encoding.UTF8.GetBytes("nodata");
                FileContentResult fcr = new FileContentResult(nodata, "application/text");
                fcr.FileDownloadName = "nodata.txt";
                return fcr;
            }

            //split the ID's into an array
            bool hasData = false;
            FileContentResult pdfFile = null;
            pdfFile = PrintPackageToPDF(int.Parse(BillingContactID));
            if (pdfFile != null && pdfFile.FileContents.LongLength > 0)
            {
                hasData = true;
            }
            
            if (hasData)
            {
                var clientContact = ClientContacts.GetClientContactFromBillingContactID(int.Parse(BillingContactID));

                string attachedFile = Convert.ToBase64String(pdfFile.FileContents, 0, pdfFile.FileContents.Length);

                StringBuilder sbfileFixRowLength = new StringBuilder();

                for (int i = 0; i < attachedFile.Length; i = i + 76)
                {
                    if (i + 76 < attachedFile.Length)
                    {
                        sbfileFixRowLength.Append(attachedFile.Substring(i, 76) + "\r\n");
                    }
                    else 
                    {
                        sbfileFixRowLength.Append(attachedFile.Substring(i) + "\r\n");                    
                    }
                }

                string attachedFileSSX = sbfileFixRowLength.ToString();

                string emlContents = "Reply-To: \"\" <" + ConfigurationManager.AppSettings["billingemail"] + ">" + "\r\n" +
                                     "From: \"\" <" + ConfigurationManager.AppSettings["billingemail"] + ">" + "\r\n" +
                                     "To: \"" + clientContact.BillingContactName + "\" <" + clientContact.BillingContactEmail.ToLower() + ">" + "\r\n" +
                                     "Subject: Invoice from " + ConfigurationManager.AppSettings["CompanyName"] + "\r\n" +
                                     "Date: " + nowPlease.ToString("ddd") + ", " + nowPlease.ToString("dd") + " " + nowPlease.ToString("MMM") + " " + nowPlease.ToString("yyyy") + " " + nowPlease.ToString("HH:mm:ss") + " -0400" + "\r\n" +
                                     "Organization: " + ConfigurationManager.AppSettings["CompanyName"] + "\r\n" +
                                     "MIME-Version: 1.0" + "\r\n" +
                                     "Content-Type: multipart/mixed;" + "\r\n" +
                                     "	boundary=\"----=_NextPart_000_006E_01CF9135.CDEE8990\"" + "\r\n" +
                                     "X-Priority: 3" + "\r\n" +
                                     "X-MSMail-Priority: Normal" + "\r\n" +
                                     "Importance: Normal" + "\r\n" +
                                     "X-Unsent: 1" + "\r\n" +
                                     "X-MimeOLE: Produced By Microsoft MimeOLE V16.4.3528.331" + "\r\n\r\n" +
                                     "This is a multi-part message in MIME format." + "\r\n\r\n" +
                                     "------=_NextPart_000_006E_01CF9135.CDEE8990" + "\r\n" +
                                     "Content-Type: multipart/alternative;" + "\r\n" +
                                     "	boundary=\"----=_NextPart_001_006F_01CF9135.CDEE8990\"" + "\r\n\r\n\r\n" +
                                     "------=_NextPart_001_006F_01CF9135.CDEE8990" + "\r\n" +
                                     "Content-Type: text/plain;" + "\r\n" +
                                     "	charset=\"iso-8859-1\"" + "\r\n" +
                                     "Content-Transfer-Encoding: quoted-printable" + "\r\n\r\n" +
                                     "Dear Customer:" + "\r\n\r\n" +
                                     "Your invoice is attached. Please remit payment at your earliest =" + "\r\n" +
                                     "convenience. To make a phone payment by check or credit card free of =" + "\r\n" +
                                     "charge please contact Accounts Receivable at " + ConfigurationManager.AppSettings["billingphone"] + " or =" + "\r\n" +
                                     ConfigurationManager.AppSettings["billingemail"] + "\r\n\r\n" +
                                     "Thank you for your business." + "\r\n\r\n" +
                                     "Sincerely," + "\r\n\r\n" +
                                     ConfigurationManager.AppSettings["CompanyName"] +  "\r\n" +
                                     "------=_NextPart_001_006F_01CF9135.CDEE8990" + "\r\n" +
                                     "Content-Type: text/html;" + "\r\n" +
                                     "	charset=\"iso-8859-1\"" + "\r\n" +
                                     "Content-Transfer-Encoding: quoted-printable" + "\r\n\r\n" +
                                     "<HTML><HEAD></HEAD>" + "\r\n" +
                                     "<BODY>Dear Customer:<br>" + "\r\n" +
                                     "<br>" + "\r\n" +
                                     "Your invoice is attached.  Please remit payment at your earliest " + "\r\n" +
                                     "convenience. To make a phone payment by check or credit card free of charge " + "\r\n" +
                                     "please contact Accounts Receivable at " + ConfigurationManager.AppSettings["billingphone"] + " or " + "\r\n" +
                                     ConfigurationManager.AppSettings["billingemail"] + "\r\n" +                                     
                                     "<br>" + "\r\n" +
                                     "Thank you for your business.<br>" + "\r\n" +
                                     "<br>" + "\r\n" +
                                     "Sincerely,<br>" + "\r\n" +
                                     "<br>" + "\r\n" +
                                     ConfigurationManager.AppSettings["CompanyName"] + "\r\n" +
                                     "</BODY></HTML>" + "\r\n\r\n" +
                                     "------=_NextPart_001_006F_01CF9135.CDEE8990--" + "\r\n" +
                                     "\r\n" +
                                     "------=_NextPart_000_006E_01CF9135.CDEE8990" + "\r\n" +
                                     "Content-Type: application/pdf;" + "\r\n" +
                                     "	name=\"" + pdfFile.FileDownloadName + "\"" + "\r\n" +
                                     "Content-Transfer-Encoding: base64" + "\r\n" +
                                     "Content-Disposition: attachment;" + "\r\n" +
                                     "	filename=\"" + pdfFile.FileDownloadName + "\"" + "\r\n" +
                                     "\r\n" +
                                     attachedFileSSX +
                                     "\r\n" +
                                     "------=_NextPart_000_006E_01CF9135.CDEE8990--" + "\r\n";

                string fileName = (clientContact.BillAsClientName + " " + nowPlease.ToString()).cleanFileName() + ".eml";
                fileName = "attachment;filename=" + fileName;
                Response.Clear();
                Response.ContentType = "application/octet-stream";
                Response.AddHeader("Content-Disposition", fileName);
                Response.Write(emlContents);
                Response.End();
            }
            else
            {
                byte[] nodata = Encoding.UTF8.GetBytes("nodata");
                FileContentResult fcr = new FileContentResult(nodata, "application/text");
                fcr.FileDownloadName = "nodata.txt";
                return fcr;
            }

            return null;
        }


        /*
        public ActionResult PrintPackageToPDF_Public(Guid id) //id = Guid
        {
            return RedirectToAction("LogOn", "Account", new
            {
                username = "Courtney.Eidel@comop.org",
                password = System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"],
                returnUrl = "/BillingStatement/PrintPackageToPDF_Client/" + id.ToString(),
                ClientID = "1979",
                portal = "client"
            } 
            );
        }
        */
        public FileContentResult PrintPackageToPDF_Public(Guid id) //id = Guid
        {
            BillingPackagePrinted billingPackagePrinted = BillingStatements.GetBilingPackagePrintedFromGUID(id);

            if (billingPackagePrinted.BillingContactID == 0)
            {

            }

            var result2 = ClientContacts.GetClientContactFromBillingContactID(billingPackagePrinted.BillingContactID);

            //FormsAuth.SetAuthCookie("evega@naropa.edu", false);
            //FormsAuth.SetAuthCookie(result2.BillingContactEmail, false);            

            DateTime StartDate, EndDate;
            EndDate = billingPackagePrinted.PackageEndDate;
            StartDate = new DateTime(EndDate.AddMonths(-1).Year, EndDate.AddMonths(-1).Month, 2);

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

            //string AuthName = this.Request.Cookies[".ASPXAUTH"].Name;
            //string AuthValue = this.Request.Cookies[".ASPXAUTH"].Value;

            string AuthName = "expertPDF";
            string AuthValue = id.ToString();

            // pdf.HttpRequestHeaders = "Cookie: name=" + AuthValue;
            pdf.HttpRequestHeaders = String.Format(
                "Cookie : {0}={1}\r\n", AuthName, AuthValue
            );

            List<CurrentInvoice> invoicesToAppend = BillingStatements.GetBillingStatementListCurrentInvoices(billingPackagePrinted.BillingContactID, StartDate, EndDate);
            int invoicesCount = 0;

            //Count the number of PDF's to append
            foreach (CurrentInvoice invoice in invoicesToAppend)
            {
                invoicesCount++;
                Invoice invoiceToExport = Invoices.GetInvoice(invoice.InvoiceID);
                if (invoiceToExport.BillingReportGroupID > 0)
                {
                    invoicesCount++;
                }
            }

            string UrlToPDF = "";
            //If this is a secondary contact
            if ((!ClientContacts.GetClientContactFromBillingContactID(billingPackagePrinted.BillingContactID).IsPrimaryBillingContact
                && invoicesCount > 0 && !invoicesToAppend.First().IsPrimaryBillingContact) || ClientContacts.GetClientContactFromBillingContactID(billingPackagePrinted.BillingContactID).OnlyShowInvoices && invoicesCount > 0)
            {
                CurrentInvoice FirstInvoice = invoicesToAppend.First();

                UrlToPDF = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"] //"http://screeningone.com:8080/" /*"http://localhost:1225"*/ /*"http://s1-tpa-dv1:82/"*/
                    + Url.Action("InvoicesDetailsMode6", "PDF", new { id = FirstInvoice.InvoiceID });

                Invoice invoiceToExportSecondary = Invoices.GetInvoice(FirstInvoice.InvoiceID);

                invoicesToAppend.RemoveAt(0);

                if (invoiceToExportSecondary.BillingReportGroupID > 0)
                {
                    //Billing Detail Report
                    PdfConverter pdf2 = new PdfConverter();
                    //pdf2.PdfDocumentOptions.PdfPageSize = PdfPageSize.Letter;
                    pdf2.PdfDocumentOptions.BottomMargin = 40;
                    pdf2.PdfDocumentOptions.TopMargin = 40;
                    pdf2.PdfDocumentOptions.LeftMargin = 50;
                    pdf2.PdfDocumentOptions.RightMargin = 50;
                    pdf2.PdfDocumentOptions.PdfPageOrientation = PDFPageOrientation.Landscape;
                    pdf2.PdfDocumentOptions.ShowFooter = true;
                    pdf2.PdfFooterOptions.ShowPageNumber = true;

                    pdf2.HttpRequestHeaders = String.Format(
                        "Cookie : {0}={1}\r\n", AuthName, AuthValue
                    );
                    pdf2.LicenseKey = "q4CZi5qai5Oci5KFm4uYmoWamYWSkpKS";

                    string UrlToPDF2 = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"]
                        + Url.Action("InvoiceReportsIndexMode7", "PDF", new { InvoiceID = FirstInvoice.InvoiceID, GroupID = invoiceToExportSecondary.BillingReportGroupID });

                    pdf.PdfDocumentOptions.AppendPDFStream = new System.IO.MemoryStream();
                    pdf2.SavePdfFromUrlToStream(UrlToPDF2, pdf.PdfDocumentOptions.AppendPDFStream);
                    pdf.PdfFooterOptions.PageNumberingPageCountIncrement = (0 - pdf2.ConversionSummary.PdfPageCount);
                }
            }
            else
            {
                UrlToPDF = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"] //"http://screeningone.com:8080/" /*"http://localhost:1225"*/ /*"http://s1-tpa-dv1:82/"*/                            
                    + Url.Action("BillingStatmentIndex_PublicMode3", "PDF", new { id = billingPackagePrinted.BillingContactID, StatementDate = EndDate.ToString() });

                PdfConverter[] pdfs = new PdfConverter[invoicesCount];
                if (invoicesToAppend.Count > 0)
                {
                    pdf.PdfDocumentOptions.AppendPDFStreamArray = new System.IO.MemoryStream[invoicesCount];
                    int CurStream = 0;
                    foreach (CurrentInvoice invoice in invoicesToAppend)
                    {
                        Invoice invoiceToExport = Invoices.GetInvoice(invoice.InvoiceID);

                        //Invoice
                        pdfs[CurStream] = new PdfConverter();
                        //pdfs[CurStream].PdfDocumentOptions.PdfPageSize = PdfPageSize.Letter;
                        pdfs[CurStream].PdfDocumentOptions.BottomMargin = 0;
                        pdfs[CurStream].PdfDocumentOptions.TopMargin = 15;
                        pdfs[CurStream].PdfDocumentOptions.LeftMargin = 10;
                        pdfs[CurStream].PdfDocumentOptions.RightMargin = 10;
                        pdfs[CurStream].PdfDocumentOptions.PdfPageOrientation = PDFPageOrientation.Portrait;
                        pdfs[CurStream].PdfDocumentOptions.ShowFooter = true;
                        pdfs[CurStream].PdfFooterOptions.ShowPageNumber = true;

                        pdfs[CurStream].HttpRequestHeaders = String.Format(
                            "Cookie : {0}={1}\r\n", AuthName, AuthValue
                        );
                        pdfs[CurStream].LicenseKey = "q4CZi5qai5Oci5KFm4uYmoWamYWSkpKS";

                        string UrlToPDF3 = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"]
                            + Url.Action("InvoicesDetailsMode6", "PDF", new { id = invoice.InvoiceID });

                        pdf.PdfDocumentOptions.AppendPDFStreamArray[CurStream] = new System.IO.MemoryStream();
                        pdfs[CurStream].SavePdfFromUrlToStream(UrlToPDF3, pdf.PdfDocumentOptions.AppendPDFStreamArray[CurStream]);
                        pdf.PdfFooterOptions.PageNumberingPageCountIncrement = (0 - pdfs[CurStream].ConversionSummary.PdfPageCount);
                        CurStream++;


                        if (invoiceToExport.BillingReportGroupID > 0)
                        {
                            //Billing Detail Report
                            pdfs[CurStream] = new PdfConverter();
                            //pdfs[CurStream].PdfDocumentOptions.PdfPageSize = PdfPageSize.Letter;
                            pdfs[CurStream].PdfDocumentOptions.BottomMargin = 40;
                            pdfs[CurStream].PdfDocumentOptions.TopMargin = 40;
                            pdfs[CurStream].PdfDocumentOptions.LeftMargin = 50;
                            pdfs[CurStream].PdfDocumentOptions.RightMargin = 50;
                            pdfs[CurStream].PdfDocumentOptions.PdfPageOrientation = PDFPageOrientation.Landscape;
                            pdfs[CurStream].PdfDocumentOptions.ShowFooter = true;
                            pdfs[CurStream].PdfFooterOptions.ShowPageNumber = true;

                            pdfs[CurStream].HttpRequestHeaders = String.Format(
                                "Cookie : {0}={1}\r\n", AuthName, AuthValue
                            );
                            pdfs[CurStream].LicenseKey = "q4CZi5qai5Oci5KFm4uYmoWamYWSkpKS";

                            string UrlToPDF2 = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"]
                                + Url.Action("InvoiceReportsIndexMode7", "PDF", new { InvoiceID = invoice.InvoiceID, GroupID = invoiceToExport.BillingReportGroupID });

                            pdf.PdfDocumentOptions.AppendPDFStreamArray[CurStream] = new System.IO.MemoryStream();
                            pdfs[CurStream].SavePdfFromUrlToStream(UrlToPDF2, pdf.PdfDocumentOptions.AppendPDFStreamArray[CurStream]);
                            pdf.PdfFooterOptions.PageNumberingPageCountIncrement = (0 - pdfs[CurStream].ConversionSummary.PdfPageCount);
                            CurStream++;
                        }
                    }
                }
            }

            /*if (invoicesToAppend.Count > 0)
                pdf.PdfDocumentOptions.AppendPDFStreamArray = pdfStreams.ToArray();            
             */

            BillingStatement billingStatement = BillingStatements.GetCurrentBillingStatement(billingPackagePrinted.BillingContactID, StartDate, EndDate);

            FileContentResult fcr = new FileContentResult(pdf.GetPdfFromUrlBytes(UrlToPDF), "application/PDF");
            fcr.FileDownloadName = billingStatement.billingContact.BillAsClientName + "_" + EndDate.Year.ToString()
                + EndDate.Month.ToString() + "_Billing.pdf";
            return fcr;
        }


        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult AdminIndex(int id) //id = BillingContactID
        {
            int BillingContactID = id;

            DateTime StartDate, EndDate;
            StartDate = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 2);
            EndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            //StartDate = new DateTime(2010, 8, 2);
            //EndDate = new DateTime(2010, 9, 1);

            BillingStatement_Index viewBillingStatement_Index = new BillingStatement_Index();
            viewBillingStatement_Index.BillingContactID = BillingContactID;
            viewBillingStatement_Index.ClientView = false;
            viewBillingStatement_Index.BillingStatement =
                BillingStatements.GetCurrentBillingStatement(BillingContactID, StartDate, EndDate);

            viewBillingStatement_Index.StatementDate = EndDate;

            return View(viewBillingStatement_Index);
        }

        [ScreeningONEAuthorize(Portal = "Client", Roles = "Client_Billing")]
        public ActionResult AccountActivity(int id) //id = BillingContactID
        {
            if (!Security.UserCanAccessBillingContact(m_UserID, id))
            {
                return RedirectToAction("Index", "Home");
            }

            int BillingContactID = id;

            BillingStatement_AccountActivity viewBillingStatement_AccountActivity = new BillingStatement_AccountActivity();
            viewBillingStatement_AccountActivity.AccountActivity = BillingStatements.GetAccountActivity(BillingContactID, m_UserID);

            return View(viewBillingStatement_AccountActivity);
        }

        [ScreeningONEAuthorize(Portal = "Client", Roles = "Client_Billing")]
        public ActionResult Home(int? id) //id is optional.  It sets the billing contact. If you don't supply an ID it will use the first Billing Contact for the User
        {
            if (id.HasValue && !Security.UserCanAccessBillingContact(m_UserID, id.Value))
            {
                return RedirectToAction("Index", "Home");
            }

            int BillingContactID;

            DateTime StartDate, EndDate;
            StartDate = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 2);
            EndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            //StartDate = new DateTime(2010, 8, 2);
            //EndDate = new DateTime(2010, 9, 1);

            BillingStatement_AccountActivity viewBillingStatement_AccountActivity = new BillingStatement_AccountActivity();

            viewBillingStatement_AccountActivity.BillingContacts = ClientContacts.GetBillingContactsForDropdown(m_UserID);

            bool HideFromClient = ClientContacts.GetBillingContactHideFromClientFromUserID(m_UserID);
            viewBillingStatement_AccountActivity.IsPrimaryContact = ClientContacts.UserHasPrimaryContact(m_UserID);

            if (HideFromClient)
            {
                return View("Home_Disabled");
            }

            if (id.HasValue)
            {
                BillingContactID = id.Value;
                viewBillingStatement_AccountActivity.BillingContactID = BillingContactID;

            }
            else
            {
                //if there is one or more billing contacts associated with this user/client contact
                if (viewBillingStatement_AccountActivity.BillingContacts.Count > 2)
                {
                    //pick the first one in the list
                    BillingContactID = Int32.Parse(viewBillingStatement_AccountActivity.BillingContacts.Where(x => x.Value != "0").First().Value);

                    if (viewBillingStatement_AccountActivity.IsPrimaryContact)
                    {
                        viewBillingStatement_AccountActivity.BillingContactID = 0;//multiple statement view
                    }
                    else
                    {
                        viewBillingStatement_AccountActivity.BillingContactID = BillingContactID;
                    }
                }
                else if (viewBillingStatement_AccountActivity.BillingContacts.Count > 0)
                {
                    BillingContactID = Int32.Parse(viewBillingStatement_AccountActivity.BillingContacts.Where(x => x.Value != "0").First().Value);
                    viewBillingStatement_AccountActivity.BillingContactID = BillingContactID;
                }
                else //If there are no billing contacts associated with this user/client contact
                {
                    return RedirectToAction("LogOn", "Account");
                }
            }

            viewBillingStatement_AccountActivity.UserID = m_UserID;
            viewBillingStatement_AccountActivity.AccountActivity = BillingStatements.GetAccountActivity(BillingContactID, m_UserID);
            viewBillingStatement_AccountActivity.BillingSatementList = BillingStatements.GetBillingStatementListFromUser(m_UserID, StartDate, EndDate);

            viewBillingStatement_AccountActivity.BillingStatement =
                BillingStatements.GetCurrentBillingStatement(BillingContactID, StartDate, EndDate);

            //Set the statement date to the End Date of the period (the first of the month)
            viewBillingStatement_AccountActivity.StatementDate = EndDate;

            ClientContact clientContact = ClientContacts.GetClientContactFromBillingContactID(BillingContactID);

            if (viewBillingStatement_AccountActivity.BillingContactID != 0 && clientContact.OnlyShowInvoices)
            {
                if (!viewBillingStatement_AccountActivity.IsPrimaryContact)
                {
                    viewBillingStatement_AccountActivity.BillingContacts.RemoveAt(0); //Remove the [All Clients] item
                }
                return View("Home_InvoicesOnly", viewBillingStatement_AccountActivity);
            }
            else
            {
                return View("Home", viewBillingStatement_AccountActivity);
            }
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult AdminStatements()
        {


            return View();
        }


        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult GetStatementsListJSON(int ExcludePrinted, int ExcludeZero, int BillingGroup, FormCollection fc)
        {
            int ID = Convert.ToInt32(fc["id"]);
            string FieldToSort = fc["sidx"];
            string strSortOrder = fc["sord"];
            SortDirection SortOrder;

            if (FieldToSort == "id" || FieldToSort == "Action" || FieldToSort == null)
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

            DateTime StartDate, EndDate;
            //StartDate = new DateTime(DateTime.Now.Year, DateTime.Now.AddMonths(-1).Month, 2);
            StartDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            EndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);
            //StartDate = new DateTime(2010,8,2);
            //EndDate = new DateTime(2010,9,1);

            string delivery = null;

            switch (ExcludePrinted)
            {
                case 1: delivery = "Email-Auto";
                    break;
                case 2: delivery = "Email";
                    break;
                case 3: delivery = "Mail";
                    break;
                default: delivery = "0";
                    break;
            }

            var result = BillingStatements.GetBillingStatementList(StartDate, EndDate, BillingGroup);
            var result2 = BillingStatements.GetBillingStatementList(StartDate, EndDate, BillingGroup);

            Array rows = (from question in result.Order(FieldToSort, SortOrder)
                          where (question.Amount != 0 || question.CurrentActivity == "Yes" || question.CurrentActivity == "Secondary")
                            && ((question.LastPrinted == null && question.DeliveryMethod == delivery) || ExcludePrinted == 0)
                          select new
                          {
                              i = question.billingContact.BillingContactID,
                              cell = new string[] { question.billingContact.BillingContactID.ToString(),
                                  "",
                                  question.ClientName,  
                                  question.BillingContactName, 
                                  question.DeliveryMethod,
                                  (question.LastPrinted.HasValue ? question.LastPrinted.Value.ToString("MM/dd/yyyy") : "Not Printed"),
                                  question.CurrentActivity,
                                  question.Amount.ToString("C"),
                                  question.ContactEmail
                              }
                          }
                          ).Skip(StartRow - 1).Take(RowsPerPage).ToArray();

            Array rows2 = (from question in result.Order(FieldToSort, SortOrder)
                           where (question.Amount != 0 || question.CurrentActivity == "Yes" || question.CurrentActivity == "Secondary")
                            && ((question.LastPrinted == null && question.DeliveryMethod == delivery) || ExcludePrinted == 0)
                           select new
                           {
                               i = question.billingContact.BillingContactID,
                               cell = new string[] { question.billingContact.BillingContactID.ToString() }
                           }
                          ).ToArray();

            int totalRows = rows2.GetLength(0);

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
        public ActionResult PrintPackages()
        {
            BillingStatement_PrintPackages viewModel = new BillingStatement_PrintPackages();

            viewModel.BillingGroups = Invoices.GetBillingGroupList();

            return View(viewModel);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult MarkAsPrintedJSON(string BillingContactIDs)
        {
            if (String.IsNullOrEmpty(BillingContactIDs))
            {
                return new JsonResult { Data = new { success = false } };
            }

            DateTime StartDate, EndDate;
            StartDate = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 2);
            EndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);

            //split the ID's into an array
            string[] BillingContactIDsArray = BillingContactIDs.Split(',');

            //if there are any errors while creating the finance charges, return success = false
            try
            {
                foreach (var BillingContactIDstring in BillingContactIDsArray)
                {
                    int BillingContactID = Int32.Parse(BillingContactIDstring);

                    BillingStatements.AddBillingPackagePrinted(BillingContactID, EndDate, 0);
                }
            }
            catch
            {
                return new JsonResult { Data = new { success = false } };
            }

            return new JsonResult { Data = new { success = true } };
        }


        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult AutomaticallyEmailJSON(string BillingContactIDs)
        {
            if (String.IsNullOrEmpty(BillingContactIDs))
            {
                return new JsonResult { Data = new { success = false } };
            }

            Clients.LogAction("INVOICES_AutomaticallyEmailJSON_Started", BillingContactIDs);

            DateTime StartDate, EndDate;
            StartDate = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 2);
            EndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);

            //split the ID's into an array
            string[] BillingContactIDsArray = BillingContactIDs.Split(',');
            string ActionGUID = "";

            //if there are any errors while creating the finance charges, return success = false
            try
            {
                foreach (var BillingContactIDstring in BillingContactIDsArray)
                {
                    int BillingContactID = Int32.Parse(BillingContactIDstring);

                    var result3 = BillingStatements.GetStatementEmail(BillingContactID);

                    string ReturnURL = "/BillingStatement/PrintPackageToPDF_Public";

                    foreach (var item in result3)
                    {
                        ActionGUID = item.ActionGUID.ToString();

                        string subject = ConfigurationManager.AppSettings["CompanyName"] + " Billing: Your Statement Is Available - " + item.ClientName;

                        Dictionary<string, string> messagevalues = new Dictionary<string, string>();
                        messagevalues.Add("[[COMPANYNAME]]", item.ClientName);
                        messagevalues.Add("[[STATEMENTDATE]]", EndDate.ToString("MMMM yyyy"));
                        messagevalues.Add("[[GUIDURL]]", System.Configuration.ConfigurationManager.AppSettings["DefaultPath"] + ReturnURL + "/" + item.ActionGUID.ToString());
                        messagevalues.Add("[[CORPORATENAME]]", System.Configuration.ConfigurationManager.AppSettings["CompanyName"]);
                        messagevalues.Add("[[CORPORATEPHONE]]", System.Configuration.ConfigurationManager.AppSettings["billingphone"]);
                        messagevalues.Add("[[CORPORATEEMAIL]]", System.Configuration.ConfigurationManager.AppSettings["BillingEmail"]);



                        MailGun.SendEmailToUserFromTemplate(5, 0, "AutoEmail Release", 0, item.EmailUserID, 0, subject, messagevalues);

                        /* var messageRecord = Messages.GetMessageTemplateRecord(0, "AutoEmail Release", messagevalues);

                         string messagebody = messageRecord != null ? messageRecord.MessageText : null;

                         if (messagebody != null)
                         {
                             int messageActionType = messageRecord.MessageActionTypeID.GetValueOrDefault();
                             int? MessageIDOutput = new int?();
                             Guid? MessageActionGuidOutput = new Guid?();
                             Messages.CreateMessageWithAction(messageActionType, subject, messagebody, item.EmailUserID, 1, 0, 3, HttpUtility.UrlDecode(ReturnURL), System.DateTime.Now, null, "HTML", ref MessageIDOutput, ref MessageActionGuidOutput);
                             Messages.UpdateMessageAndMarkForSending(MessageIDOutput.Value, subject, messagebody);
                         }
                         else
                         {
                             //todoo: future error logging
                         }*/
                    }


                    BillingStatements.AddBillingPackagePrintedGUID(BillingContactID, EndDate, 0, ActionGUID);
                }
            }
            catch
            {
                return new JsonResult { Data = new { success = false } };
            }

            return new JsonResult { Data = new { success = true } };
        }
    }
}
