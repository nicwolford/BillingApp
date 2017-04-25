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
    public class S1BasePublicController : Controller
    {
        protected override void OnActionExecuted(ActionExecutedContext filterContext)
        {
            //int clientidInt;
            //string ClientID = Request["ClientID"];
            string portal = Request["portal"];

            MainMenu viewMainMenu = new MainMenu();
            /*
            if (Int32.TryParse(ClientID, out clientidInt) == true)
            {

                ViewData["ClientName"] = Clients.GetClientNameFromID(clientidInt);
                ViewData["ClientID"] = clientidInt;

            }
            else
            {
                ViewData["ClientName"] = "ScreeningONE";
                ViewData["ClientID"] = 0;
            }
            */
            if (portal == "client")
            {
                viewMainMenu.Portal = "client";
            }
            else
            {
                if (portal == "admin")
                {
                    viewMainMenu.Portal = "admin";
                }
                else
                {
                    viewMainMenu.Portal = "sales";
                }
            }
        }
    }
}
