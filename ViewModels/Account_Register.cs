using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ScreeningONE.ViewModels
{
    public class Account_Register
    {
        public string Title { get; set; }
        public int PasswordLength { get; set; }
        public string username { get; set; }
        public string email { get; set; }
        public string password { get; set; }
        public string confirmPassword { get; set; }
        public string passwordQuestion { get; set; }
        public string passwordAnswer { get; set; }
        public string RegisterGUID { get; set; }
        public string CAPTCHAAnswer { get; set; }
        public string actionpath { get; set; }
        public string ReturnUrl { get; set; }
        public int ClientID { get; set; }
        public string ClientName { get; set; }
        public string portal { get; set; }
    }
}
