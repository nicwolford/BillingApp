using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ScreeningONE.DomainModels
{
    public class ReportParameter
    {
        public int ReportId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public ReportParameterType ParameterType { get; set; }
        public string DefaultValue { get; set; }
    }
}
