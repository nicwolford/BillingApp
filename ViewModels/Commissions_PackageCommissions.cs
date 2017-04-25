using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.DomainModels;
using ScreeningONE.Models;
using ScreeningONE.Objects;

namespace ScreeningONE.ViewModels
{
    public class Commissions_PackageCommissions
    {
        public Commissions_PackageCommissions() 
        {
            this.Results = Commissions.PackageCommissions();
        }
        public List<S1_Commissions_PackageCommissionsResult> Results { get; set; }
    }
}
