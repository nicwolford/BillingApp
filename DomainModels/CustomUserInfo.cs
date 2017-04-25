using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ScreeningONE.DomainModels
{
    public class CustomUserInfo
    {
        public bool InvalidUserName { get; set; }
        public bool IsApproved { get; set; }
        public bool IsLockedOut { get; set; }

        public CustomUserInfo()
        {
            this.IsApproved = false;
            this.IsLockedOut = true;
            this.InvalidUserName = true;
        }

        public CustomUserInfo(bool isApproved, bool isLockedOut, bool invalidUserName)
        {
            this.IsApproved = isApproved;
            this.IsLockedOut = isLockedOut;
            this.InvalidUserName = invalidUserName;
        }
    }

}