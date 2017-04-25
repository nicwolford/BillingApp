using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Caching;
using System.Web.Mvc;

namespace ScreeningONE.Controllers
{
    [HandleError]
    public class HomeController : S1BaseController
    {

        [ScreeningONEAuthorize(Portal="Admin", Roles = "Client, Admin, Sales")]
        public ActionResult Index()
        {
            //Redirect to temporary client home page for billing
            if (User.IsInRole("Client"))
            {
                return RedirectToAction("Home", "BillingStatement");
            }

            ViewData["Message"] = "Billing System Home Page";

            return View();
        }

        public ActionResult About()
        {
            return View();
        }

        [CustomContentType(ContentType = "text/css", Order = 2)]
        [OutputCache(CacheProfile = "TemplateCSS")]
        public ContentResult GetCSS(int TemplateID)
        {
            string CSSText = (string)this.ControllerContext.HttpContext.Cache.Get("GetCSS_" + TemplateID.ToString());

            ContentResult fcr = new ContentResult();
            if (CSSText == null)
            {
                
                string fileLocation = Request.PhysicalApplicationPath + System.Configuration.ConfigurationManager.AppSettings["systemCss"];

                fcr.Content = System.IO.File.ReadAllText(fileLocation);
                this.ControllerContext.HttpContext.Cache.Add("GetCSS_" + TemplateID.ToString(), fcr.Content, null, Cache.NoAbsoluteExpiration, new TimeSpan(0, 1, 0), CacheItemPriority.Default, null);

                //Code to remove the CSS template from the cache
                //this.ControllerContext.HttpContext.Cache.Remove("GetCSS_" + TemplateID.ToString());
            }
            else
            {
                fcr.Content = CSSText;
            }

            fcr.ContentType = @"text/css";
            return fcr;

        }

        [AllowAnonymous]
        public ActionResult Unauthorized(string mstr = "Site", string source = "")
        {
            try
            {
                if (source == null) source = "";
                if (source.Length > 0) source = Server.UrlEncode(source);
            }
            catch { }

            try
            {
                return View("Unauthorized", mstr);
            }
            catch
            {
                return View();
            }
        }

    }
}
