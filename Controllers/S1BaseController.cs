using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ScreeningONE.Objects;
using ScreeningONE.Models;
using ScreeningONE.DomainModels;

namespace ScreeningONE.Controllers
{
    public class S1BaseController : Controller
    {
        protected int m_UserID;
        protected string m_Portal;
        //protected int m_ClientID;

        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            m_UserID = SecurityExtension.GetCurrentUserID(this);
            m_Portal = ScreeningONEAuthorizeHelper.GetPortal(this, filterContext.ActionDescriptor.ActionName);
            //m_ClientID = Clients.GetParentClientIDFromUser(m_UserID);
            //S1_Clients_GetClientsFromUserResult client = Clients.GetParentClientFromUser(m_UserID);

            ViewData["UserID"] = m_UserID;
            /*if (client != null)
            {
                ViewData["ClientName"] = Clients.GetParentClientFromUser(m_UserID).ClientName;
            }
             */ 

            ViewModels.MainMenu viewMainMenu = new ViewModels.MainMenu();
            viewMainMenu.Portal = m_Portal;
            viewMainMenu.UserID = m_UserID;
            ViewData["MainMenu"] = viewMainMenu;

            ViewModels.LogOn viewLogOn = new ViewModels.LogOn();
            viewLogOn.Portal = m_Portal;
            //viewLogOn.ClientID = m_ClientID;
            ViewData["LogOn"] = viewLogOn;

            if (User.IsInRole("Client_SalesDemo"))
                viewMainMenu.IsSalesDemoClient = true;
            else
                viewMainMenu.IsSalesDemoClient = false;


            base.OnActionExecuting(filterContext);
        }

    }
}
