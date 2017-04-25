using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.Models.Users;

namespace ScreeningONE.Objects
{
    public class SecurityExtension
    {
        //returns 0 if the user cannot be found
        public static int GetCurrentUserID(Controller c)
        {
            return GetCurrentUserIDFromName(c.User.Identity.Name);
        }

        public static int GetCurrentUserID(HttpContextBase h)
        {
            return GetCurrentUserIDFromName(h.User.Identity.Name);
        }

        public static int GetCurrentUserIDFromName(string UserName)
        {
            var db = new UsersDataContext();
            var q = from o in db.Users
                    where o.aspnet_User.UserName == UserName
                    select new
                    {
                        UserID = o.UserID
                    };

            if (q.Count() > 0)
            {
                return q.SingleOrDefault().UserID;
            }

            return 0;
        }

        //returns 0 if admin or client not found
        public static int GetCurrentClientID(Controller c)
        {
            var db = new ClientsDataContext();
            var results = db.S1_Clients_GetClientsFromUser(GetCurrentUserIDFromName(c.User.Identity.Name)).SingleOrDefault();

            return results.ClientID;
        }

        public static bool CurrentUserHasRole(Controller c, string role)
        {
            return c.User.IsInRole(role);
        }

        public static bool CurrentUserHasRole(System.Web.HttpContextBase h, string role)
        {
            return h.User.IsInRole(role);
        }
    }
}
