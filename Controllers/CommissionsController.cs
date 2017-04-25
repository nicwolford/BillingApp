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

namespace ScreeningONE.Controllers
{
    public class CommissionsController : S1BaseController
    {
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult Index()
        {
            var myModel = new Commissions_PackageCommissions();
            return View(myModel);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult CreatePackageCommissionsJSON(string clientName, string packageName, string packageCommissionRate)
        {
            clientName = clientName != null ? clientName.Trim() : "";
            packageName = packageName != null ? packageName.Trim() : "";
            packageCommissionRate = packageCommissionRate != null ? packageCommissionRate.Trim() : "";

            string errorMessage = "";
            if (String.IsNullOrWhiteSpace(clientName))
            {
                errorMessage += "Client Name not provided. ";
            }
            if (String.IsNullOrWhiteSpace(packageName))
            {
                errorMessage += "Package Name not provided. ";
            }

            decimal decPackageCommissionRate = 0;
            if (!decimal.TryParse(packageCommissionRate, out decPackageCommissionRate))
            {
                errorMessage += "Commission Rate is invalid. ";
            }

            errorMessage = errorMessage.Trim();

            if (errorMessage != "")
            {
                return new JsonResult { Data = new { success = false, message = errorMessage } };
            }

            try
            {
                var results = Commissions.CreatePackageCommissions(clientName, packageName, decPackageCommissionRate);

                if (results.Count <= 0)
                {
                    errorMessage += "Record already exists, or Client Name is wrong. ";
                }

                errorMessage = errorMessage.Trim();

                return new JsonResult { Data = new { success = results.Count > 0, message = errorMessage, packageCommissionID = (results.Count > 0 ? new int?(results[0].PackageCommissionID) : new int?()), clientID = (results.Count > 0 ? results[0].ClientID : ""), clientName = (results.Count > 0 ? results[0].ClientName : ""), packageCommissionRate = (results.Count > 0 ? results[0].PackageCommissionRate.ToString("f2") : "") } };
            }
            catch (Exception ex)
            {
                errorMessage += "Record already exists, or Client Name is wrong. \n\n[" + ex.Message + "]";
                errorMessage = errorMessage.Trim();
                return new JsonResult { Data = new { success = false, message = errorMessage } };
            }
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult RemovePackageCommissionsJSON(string packageCommissionID)
        {
            packageCommissionID = packageCommissionID != null ? packageCommissionID.Trim() : "";

            string errorMessage = "";

            int intPackageCommissionID = 0;
            if (!int.TryParse(packageCommissionID, out intPackageCommissionID))
            {
                errorMessage += "PackageCommissionID is invalid. ";
            }

            errorMessage = errorMessage.Trim();

            if (errorMessage != "")
            {
                return new JsonResult { Data = new { success = false, message = errorMessage } };
            }

            try
            {
                var results = Commissions.RemovePackageCommissions(intPackageCommissionID);

                if (results.Count <= 0)
                {
                    errorMessage += "Record was already deleted. ";
                }

                errorMessage = errorMessage.Trim();

                return new JsonResult { Data = new { success = results.Count > 0, message = errorMessage, packageCommissionID = (results.Count > 0 ? new int?(results[0].PackageCommissionID) : new int?()), clientID = (results.Count > 0 ? results[0].ClientID : ""), clientName = (results.Count > 0 ? results[0].ClientName : ""), packageCommissionRate = (results.Count > 0 ? results[0].PackageCommissionRate.ToString("f2") : "") } };
            }
            catch (Exception ex)
            {
                errorMessage += ex.Message;
                errorMessage = errorMessage.Trim();
                return new JsonResult { Data = new { success = false, message = errorMessage } };
            }
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult UpdatePackageCommissionsJSON(string packageCommissionID, string clientName,
                                                       string packageName, string packageCommissionRate)
        {
            packageCommissionID = packageCommissionID != null ? packageCommissionID.Trim() : "";
            clientName = clientName != null ? clientName.Trim() : "";
            packageName = packageName != null ? packageName.Trim() : "";
            packageCommissionRate = packageCommissionRate != null ? packageCommissionRate.Trim() : "";

            string errorMessage = "";
            if (String.IsNullOrWhiteSpace(clientName))
            {
                errorMessage += "Client Name not provided. ";
            }
            if (String.IsNullOrWhiteSpace(packageName))
            {
                errorMessage += "Package Name not provided. ";
            }

            int intPackageCommissionID = 0;
            if (!int.TryParse(packageCommissionID, out intPackageCommissionID))
            {
                errorMessage += "PackageCommissionID is invalid. ";
            }

            decimal decPackageCommissionRate = 0;
            if (!decimal.TryParse(packageCommissionRate, out decPackageCommissionRate))
            {
                errorMessage += "Commission Rate is invalid. ";
            }

            errorMessage = errorMessage.Trim();

            if (errorMessage != "")
            {
                return new JsonResult { Data = new { success = false, message = errorMessage } };
            }

            try
            {
                var results = Commissions.UpdatePackageCommissions(intPackageCommissionID, clientName, packageName, decPackageCommissionRate);

                if (results.Count <= 0)
                {
                    errorMessage += "Record does not exists, or Client Name is wrong. ";
                }

                errorMessage = errorMessage.Trim();

                return new JsonResult { Data = new { success = results.Count > 0, message = errorMessage, oldPackageCommissionID = packageCommissionID,  packageCommissionID = (results.Count > 0 ? new int?(results[0].PackageCommissionID) : new int?()), clientID = (results.Count > 0 ? results[0].ClientID : ""), clientName = (results.Count > 0 ? results[0].ClientName : ""), packageCommissionRate = (results.Count > 0 ? results[0].PackageCommissionRate.ToString("f2") : "") } };
            }
            catch (Exception ex)
            {
                errorMessage += "Record does not exists, or Client Name is wrong. \n\n[" + ex.Message + "]";
                errorMessage = errorMessage.Trim();
                return new JsonResult { Data = new { success = false, message = errorMessage } };
            }
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult ClientsSearchByClientNameJSON(string searchTerm)
        {
            var results = Commissions.ClientsSearchByClientName(searchTerm);

            return new JsonResult { Data = new { success = true, results = results } };
        }

    }
}
