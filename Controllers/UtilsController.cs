using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace ScreeningONE.Controllers
{
    public class UtilsController : S1BaseController
    {
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult Index()
        {
            return View();
        }

    }
}
