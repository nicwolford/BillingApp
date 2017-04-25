using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ScreeningONE.Objects;
using System.Web.Mvc;

namespace ScreeningONE.ViewModels
{
    public class Security_Users
    {
        //Client Info
        public int ClientID { get; set; }
        public int ParentClientID { get; set; }
        public int SubClientID { get; set; }
        public int ActiveClient { get; set; }
        public string CompanyName { get; set; }
        public List<SelectListItem> subaccountlist;
        public List<SelectListItem> clientselectlist;



        //Security
        public List<ScreeningONE.Models.Users.S1_Users_GetClientUsersResult> userlist;
        public List<SelectListItem> menuoptionslist;
        public List<SelectListItem> securitycompanieslist;
        public List<SelectListItem> securitycompanieslist2;
        public List<SelectListItem> usertypelist;
        public List<SelectListItem> adduserlist; 
        public string firstname { get; set; }
        public string lastname { get; set; }
        public string username { get; set; }
        public string password { get; set; }
        public string confirmPassword { get; set; }
        public string email { get; set; }
        public string ReturnUrl { get; set; }
        public int newclientuserclientid { get; set; }
        public bool IsApproved { get; set; }
        public int UserID { get; set; }


        public Security_Users()
        {
            subaccountlist = new List<SelectListItem>();
            userlist = new List<ScreeningONE.Models.Users.S1_Users_GetClientUsersResult>();
            adduserlist = new List<SelectListItem>();
            menuoptionslist = new List<SelectListItem>();
            securitycompanieslist = new List<SelectListItem>();
            securitycompanieslist2 = new List<SelectListItem>();
            usertypelist = new List<SelectListItem>();
            clientselectlist = new List<SelectListItem>();
        }
        
    }
}
