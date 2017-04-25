using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ScreeningONE.ViewModels
{
    public class Account_ConfirmedChangePass
    {
        public bool ShowFieldSet { get; set; }
        public bool ShowNewPassword { get; set; }
        public bool ShowConfirmPassword { get; set; }
        public bool ShowPassResetButton { get; set; }
        public string sUserName { get; set; }

    }
}
