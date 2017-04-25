using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ExpertPdf.HtmlToPdf;
using ScreeningONE.DomainModels;
using ScreeningONE.ViewModels;
using StringExtensions;

namespace ScreeningONE.Controllers
{
    public class InvoiceReportsController : S1BaseController
    {
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult Index(int InvoiceID, int GroupID)
        {
            InvoiceReports_Index viewInvoiceReport = new InvoiceReports_Index();

            viewInvoiceReport.invoicerptlist = InvoiceReports.GetInvoiceReport(InvoiceID, GroupID);
            viewInvoiceReport.toPrint = false;
            viewInvoiceReport.GroupID = GroupID;
            viewInvoiceReport.InvoiceID = InvoiceID;
            viewInvoiceReport.ClientView = false;

            return View("Index", "View", viewInvoiceReport);
        }

        [ScreeningONEAuthorize(Portal = "Client", Roles = "Client_Billing")]
        public ActionResult ClientIndex(int InvoiceID, int GroupID)
        {
            if (!Security.UserCanAccessInvoice(m_UserID, InvoiceID))
            {
                return RedirectToAction("Index", "Home");
            }

            InvoiceReports_Index viewInvoiceReport = new InvoiceReports_Index();

            viewInvoiceReport.invoicerptlist = InvoiceReports.GetInvoiceReport(InvoiceID, GroupID);
            viewInvoiceReport.toPrint = false;
            viewInvoiceReport.GroupID = GroupID;
            viewInvoiceReport.InvoiceID = InvoiceID;
            viewInvoiceReport.ClientView = true;

            return View("Index", "View", viewInvoiceReport);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public ActionResult RenderReportToPrint(int InvoiceID, int GroupID)
        {
            //Mode 5
            InvoiceReports_Index viewInvoiceReport = new InvoiceReports_Index();

            viewInvoiceReport.invoicerptlist = InvoiceReports.GetInvoiceReport(InvoiceID, GroupID);
            viewInvoiceReport.toPrint = true;
            viewInvoiceReport.GroupID = GroupID;
            viewInvoiceReport.InvoiceID = InvoiceID;

            return View("Index", "Print", viewInvoiceReport);
        }


        public ActionResult RenderReportToPrint_Public(int InvoiceID, int GroupID)
        {
            //Mode 7
            InvoiceReports_Index viewInvoiceReport = new InvoiceReports_Index();

            viewInvoiceReport.invoicerptlist = InvoiceReports.GetInvoiceReport(InvoiceID, GroupID);
            viewInvoiceReport.toPrint = true;
            viewInvoiceReport.GroupID = GroupID;
            viewInvoiceReport.InvoiceID = InvoiceID;

            return View("Index", "Print", viewInvoiceReport);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public FileContentResult PrintReportToPDF(int InvoiceID, int GroupID)
        {
            PdfConverter pdf = new PdfConverter();
            //pdf.PdfDocumentOptions.PdfPageSize = PdfPageSize.Letter;
            pdf.PdfDocumentOptions.BottomMargin = 0;
            pdf.PdfDocumentOptions.TopMargin = 15;
            pdf.PdfDocumentOptions.LeftMargin = 40;
            pdf.PdfDocumentOptions.RightMargin = 40;
            pdf.PdfDocumentOptions.PdfPageOrientation = PDFPageOrientation.Landscape;
            pdf.PdfDocumentOptions.ShowFooter = true;
            pdf.PdfFooterOptions.ShowPageNumber = true;
            pdf.LicenseKey = "q4CZi5qai5Oci5KFm4uYmoWamYWSkpKS";

            string AuthName = this.Request.Cookies[".ASPXAUTH"].Name;
            string AuthValue = this.Request.Cookies[".ASPXAUTH"].Value;

            //pdf.HttpRequestHeaders = "Cookie: name=" + AuthValue;
            pdf.HttpRequestHeaders = String.Format(
                "Cookie : {0}={1}\r\n", AuthName, AuthValue
            );

            string UrlToPDF = System.Configuration.ConfigurationManager.AppSettings["ExportPDFPath"] //"http://screeningone.com:8080/" /*"http://localhost:1225"*/ /*"http://s1-tpa-dv1:82/"*/
                + Url.Action("InvoiceReportsIndexMode7", "PDF", new { InvoiceID = InvoiceID, GroupID = GroupID });

            /*PdfConverter pdf2 = new PdfConverter();
            pdf2.PdfDocumentOptions.BottomMargin = 20;
            pdf2.PdfDocumentOptions.TopMargin = 20;
            pdf2.PdfDocumentOptions.PdfPageOrientation = PDFPageOrientation.Landscape;
            pdf2.PdfDocumentOptions.PrependPDFStream = new System.IO.MemoryStream();
            pdf2.HttpRequestHeaders = String.Format(
                "Cookie : {0}={1}\r\n", AuthName, AuthValue
            );

            pdf.SavePdfFromUrlToStream(UrlToPDF, pdf2.PdfDocumentOptions.PrependPDFStream);*/

            Invoice invoiceToExport = Invoices.GetInvoice(InvoiceID);

            FileContentResult fcr = new FileContentResult(pdf.GetPdfFromUrlBytes(UrlToPDF), "application/PDF");
            fcr.FileDownloadName = (invoiceToExport.ClientName + "_" + invoiceToExport.InvoiceNumber).cleanFileName() + "_BillingDetail.pdf";
            return fcr;
        }

    }
}
