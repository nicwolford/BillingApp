using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScreeningONE.DomainModels
{
    public class Report
    {
        public int ReportId { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        IEnumerable<ReportParameter> Parameters { get; set; }
    }
}
