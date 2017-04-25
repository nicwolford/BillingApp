using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ScreeningONE.DomainModels;
using ScreeningONE.ViewModels;

namespace ScreeningONE.Controllers
{
    public class QBExportController : S1BaseController
    {
        //
        // GET: /QBExport/
        
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult Index()
        {
            QBExport_Index qbExport_Index = new QBExport_Index();

            qbExport_Index.exportLog = Invoices.QBExportLog_GetAll();
            qbExport_Index.invoicesToExport = Invoices.GetExportInvoices(); //BillAsClientName is stored in ClientName
            qbExport_Index.SecurityGUID = System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"];

            return View(qbExport_Index);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult DeleteExportStep(int id) //id=QBExportLogID
        {
            Invoices.QBExportLog_DeleteExportStep(id);

            return RedirectToAction("Index");
        }

    }
}
