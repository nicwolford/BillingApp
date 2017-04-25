using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ScreeningONE.DomainModels
{
    public class CustomUserInfoForFP
    {
        public bool HasRecord { get; set; }
        public string Email { get; set; }
        public int UserId { get; set; }

        public CustomUserInfoForFP()
        {
            this.HasRecord = false;
            this.Email = "";
            this.UserId = 0;
        }

        public CustomUserInfoForFP(bool hasRecord, string email, int userId)
        {
            this.HasRecord = hasRecord;
            this.Email = email;
            this.UserId = userId;
        }
    }
}