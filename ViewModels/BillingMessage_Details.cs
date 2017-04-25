using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ScreeningONE.Objects;
using System.Web.Mvc;

namespace ScreeningONE.ViewModels
{
    public class BillingMessage_Details
    {
        public int CntMsgClientID { get; set; }
        public string CntMsgClientName { get; set; }
        public int CntMsgClientContactID { get; set; }
        public string CntMsgMessageSubject { get; set; }
        public string CntMsgMessageFromName { get; set; }
        public string CntMsgMessageBody { get; set; }
        public string CntMsgMessageToName { get; set; }
        public string CntMsgMessageFromEmail { get; set; }
        public string CntMsgMessageToEmail { get; set; }
        public string CntMsgMessageCategory { get; set; }
        public string CntMsgMessageFromPhone { get; set; }


        public BillingMessage_Details()
        { 
        
        }

    }
}
