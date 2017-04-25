using ScreeningONE.DomainModels;
using ScreeningONE.Models;
using ScreeningONE.Objects;
using ScreeningONE.ViewModels;
using System;
using System.Web.Mvc;
using System.Web.Routing;
using System.Linq;

namespace ScreeningONE.Controllers
{
    public class PDFController : Controller
    {

        [LimitToLocalIPAddressAttribute]
        public ActionResult BillingStatmentIndexMode1(int id) //id = BillingContactID
        {
            //Mode 1
            DateTime StartDate, EndDate;

            string StatementDate = "";
            {                
                StartDate = new DateTime(DateTime.Now.AddMonths(-1).Year, DateTime.Now.AddMonths(-1).Month, 2);
                EndDate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, 1);

                StatementDate = EndDate.ToString();
            }

            int BillingContactID = id;

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

            return View("BillingStatmentIndex","Print",viewBillingStatement_Index);
        }

        [LimitToLocalIPAddressAttribute]
        public ActionResult BillingStatmentIndexMode2(int id) //id = BillingContactID
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

            return View("BillingStatmentIndex", "Print", viewBillingStatement_Index);
        }


        [LimitToLocalIPAddressAttribute]
        public ActionResult BillingStatmentIndex_PublicMode3(int id, string StatementDate) //id = BillingContactID
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

            return View("BillingStatmentIndex_Public", "Print", viewBillingStatement_Index);
        }

        [LimitToLocalIPAddressAttribute]
        public ActionResult InvoicesDetailsMode4(int id) //id = InvoiceID
        {
            Invoices_Details viewInvoices_Details = new Invoices_Details();

            viewInvoices_Details.toPrint = true;
            viewInvoices_Details.showToClient = false;
            viewInvoices_Details.invoice = Invoices.GetInvoice(id);

            viewInvoices_Details.invoiceLines = Invoices.GetInvoiceLines(id);
            viewInvoices_Details.numberOfColumns = viewInvoices_Details.invoice.NumberOfColumns;

            viewInvoices_Details.InvoiceType = viewInvoices_Details.invoice.InvoiceTypeDesc;

            return View("InvoicesDetails", "Print", viewInvoices_Details);
        }

        [LimitToLocalIPAddressAttribute]
        public ActionResult InvoiceReportsIndexMode5(int InvoiceID, int GroupID)
        {
            InvoiceReports_Index viewInvoiceReport = new InvoiceReports_Index();

            viewInvoiceReport.invoicerptlist = InvoiceReports.GetInvoiceReport(InvoiceID, GroupID);
            viewInvoiceReport.toPrint = true;
            viewInvoiceReport.GroupID = GroupID;
            viewInvoiceReport.InvoiceID = InvoiceID;

            return View("InvoiceReportsIndex", "Print", viewInvoiceReport);
        }

        [LimitToLocalIPAddressAttribute]
        public ActionResult InvoicesDetailsMode6(int id) //id = InvoiceID
        {
            Invoices_Details viewInvoices_Details = new Invoices_Details();

            viewInvoices_Details.toPrint = true;
            viewInvoices_Details.showToClient = false;
            viewInvoices_Details.invoice = Invoices.GetInvoice(id);

            viewInvoices_Details.invoiceLines = Invoices.GetInvoiceLines(id);
            viewInvoices_Details.numberOfColumns = viewInvoices_Details.invoice.NumberOfColumns;

            viewInvoices_Details.InvoiceType = viewInvoices_Details.invoice.InvoiceTypeDesc;

            return View("InvoicesDetails", "Print", viewInvoices_Details);
        }

        [LimitToLocalIPAddressAttribute]
        public ActionResult InvoiceReportsIndexMode7(int InvoiceID, int GroupID)
        {
            InvoiceReports_Index viewInvoiceReport = new InvoiceReports_Index();

            viewInvoiceReport.invoicerptlist = InvoiceReports.GetInvoiceReport(InvoiceID, GroupID);
            viewInvoiceReport.toPrint = true;
            viewInvoiceReport.GroupID = GroupID;
            viewInvoiceReport.InvoiceID = InvoiceID;

            return View("InvoiceReportsIndex", "Print", viewInvoiceReport);
        }

    }
}