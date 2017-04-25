using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Security.Principal;
using System.Reflection;
using ScreeningONE.Objects;

namespace ScreeningONE
{
    public static class ScreeningONEAuthorizeHelper
    {
        public static string GetPortal(object obj, string methodName)
        {
            string outString = "";
            foreach (var method in obj.GetType().GetMethods())
            {
                if (method.Name == methodName)
                {
                    foreach (var attr in method.GetCustomAttributes(typeof(ScreeningONEAuthorize), false))
                    {
                        outString = ((ScreeningONEAuthorize)attr).Portal;
                    }
                }
            }

            return outString;
        }
    }

    public class LimitToLocalIPAddressAttribute : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            //Get users IP Address             
            string ipAddress = HttpContext.Current.Request.UserHostAddress;
            if (ipAddress.Trim() != "127.0.0.1" && ipAddress.Trim() != "::1")
            {
                //Send back a HTTP Status code of 403 Forbidden                  
                filterContext.Result = new HttpStatusCodeResult(403);
            }
            base.OnActionExecuting(filterContext);
        }
    }

    public class ScreeningONEAuthorize : AuthorizeAttribute
    {
        public string Portal { get; set; }

        public override void OnAuthorization(AuthorizationContext filterContext)
        {
            IPrincipal user = filterContext.HttpContext.User;

            if (user != null)
            {
                if (!user.Identity.IsAuthenticated)
                {
                    string returnURL;
                    string ClientID = "";

                    returnURL = filterContext.Controller.ControllerContext.HttpContext.Request.Url.PathAndQuery;

                    //Parse ClientID
                    if (returnURL.Contains("ClientID="))
                    {
                        int ClientIDStart = returnURL.IndexOf("ClientID=") + 9;
                        if (ClientIDStart < returnURL.Length)
                        {
                            ClientID = returnURL.Substring(ClientIDStart);
                            returnURL = returnURL.Substring(0, ClientIDStart - 10);
                        }
                    }

                    if (Portal == "Client")
                    {
                        filterContext.HttpContext.Response.Redirect("~/Account/LogOn?portal=client&ReturnURL=" + System.Web.HttpUtility.UrlEncode(returnURL) + "&ClientID=" + ClientID);
                    }
                    else if (Portal == "Admin")
                    {
                        filterContext.HttpContext.Response.Redirect("~/Account/LogOn?portal=admin&ReturnURL=" + System.Web.HttpUtility.UrlEncode(returnURL) + "&ClientID=" + ClientID);
                    }
                    else if (Portal == "Sales")
                    {
                        filterContext.HttpContext.Response.Redirect("~/Account/LogOn?portal=sales&ReturnURL=" + System.Web.HttpUtility.UrlEncode(returnURL) + "&ClientID=" + ClientID);
                    }


                }
            }

            base.OnAuthorization(filterContext);
        }

    }
}

