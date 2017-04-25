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
    public class ReportsController : S1BaseController
    {
        //
        // GET: /Reports/

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult Index()
        {
            return View();
        }

    }
}
