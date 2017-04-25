using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ScreeningONE.DomainModels;

namespace ScreeningONE.ViewModels
{
    public class QBExport_Index
    {
        public List<QBExportLog> exportLog { get; set; }
        public List<Invoice> invoicesToExport { get; set; }
        public string SecurityGUID { get; set; }
    }
}
