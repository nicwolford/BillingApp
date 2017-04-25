using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ScreeningONE.DomainModels;

namespace ScreeningONE.Controllers
{
    public class VendorsController : S1BaseController
    {
        //
        // GET: /Vendors/

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult Index()
        {
            return View();
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [HttpPost]
        public JsonResult GetVendorsForDropdownJSON()
        {
            List<SelectListItem> vendors = Vendors.GetVendorList();

            var rows = vendors.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }
    }
}
