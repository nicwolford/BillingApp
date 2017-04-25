//#define DEBUG_EMAIL

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ScreeningONE.Objects;
using ScreeningONE.ViewModels;
using ScreeningONE.DomainModels;
using System.Configuration;


namespace ScreeningONE.Controllers
{
    public class HelpController : S1BaseController
    {
        //
        // GET: /Help/

        public ActionResult Index()
        {
            return View();
        }

        [ScreeningONEAuthorize(Portal="Client", Roles="Client")]
        public ActionResult ClientHelpHome()
        {
            return View();
        }

        [ScreeningONEAuthorize(Portal = "Client", Roles = "Client")]
        public ActionResult BillingMessage(string CntMsgMessageSubject, string CntMsgMessageCategory)
        {
            if (String.IsNullOrEmpty(CntMsgMessageSubject)) { CntMsgMessageSubject = ""; }
            if (String.IsNullOrEmpty(CntMsgMessageCategory)) { CntMsgMessageCategory = ""; }

            BillingMessage_Details viewBillingMessageDetails = new BillingMessage_Details();

            MembershipUser currentuser = Membership.Provider.GetUser(User.Identity.Name, true);

            var contactresults = ClientContacts.GetClientContactFromUserName(currentuser.UserName);

            if (contactresults.ClientContactID == 0 || contactresults.ClientContactID == null)
            {
                viewBillingMessageDetails.CntMsgClientContactID = 0;
                viewBillingMessageDetails.CntMsgMessageFromName = "unknown";
                viewBillingMessageDetails.CntMsgMessageFromEmail = "unknown";
                viewBillingMessageDetails.CntMsgMessageFromPhone = "unknown";
            }
            else
            {
                viewBillingMessageDetails.CntMsgClientContactID = contactresults.ClientContactID;
                viewBillingMessageDetails.CntMsgMessageFromName = contactresults.ClientContactFirstName + " " + contactresults.ClientContactLastName;
                viewBillingMessageDetails.CntMsgMessageFromEmail = contactresults.ClientContactEmail;
                viewBillingMessageDetails.CntMsgMessageFromPhone = contactresults.ClientContactBusinessPhone;
            }


            if (contactresults.ClientID == 0 || contactresults.ClientID == null)
            {
                viewBillingMessageDetails.CntMsgClientID = 0;
                viewBillingMessageDetails.CntMsgClientName = "unknown";
            }
            else
            {
                viewBillingMessageDetails.CntMsgClientID = contactresults.ClientID;

                var clientresults = Clients.GetClient(contactresults.ClientID);

                if (clientresults.ClientName == null)
                {
                    viewBillingMessageDetails.CntMsgClientName = "unknown";
                }
                else
                {
                    viewBillingMessageDetails.CntMsgClientName = clientresults.ClientName;
                }

            }

            viewBillingMessageDetails.CntMsgMessageToName = ConfigurationManager.AppSettings["CompanyName"] + " Billing Dept.";
            
#if DEBUG_EMAIL
            viewBillingMessageDetails.CntMsgMessageToEmail = "IT@screeningone.com"; 
#else
            viewBillingMessageDetails.CntMsgMessageToEmail = ConfigurationManager.AppSettings["billingemail"]; 
#endif
            viewBillingMessageDetails.CntMsgMessageCategory = CntMsgMessageCategory;
            viewBillingMessageDetails.CntMsgMessageSubject = CntMsgMessageSubject;
            viewBillingMessageDetails.CntMsgMessageBody = "";

            return View(viewBillingMessageDetails);
        }

        [ScreeningONEAuthorize(Portal = "Client", Roles = "Client")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult BillingMessage(int CntMsgClientID, string CntMsgClientName, int CntMsgClientContactID,
                           string CntMsgMessageSubject,string CntMsgMessageFromName, string CntMsgMessageBody, string CntMsgMessageToName,
                            string CntMsgMessageFromEmail, string CntMsgMessageToEmail, string CntMsgMessageCategory, string CntMsgMessageFromPhone)
        {
            BillingMessage_Details viewBillingMessageDetails = new BillingMessage_Details();

            viewBillingMessageDetails.CntMsgClientID = CntMsgClientID;
            viewBillingMessageDetails.CntMsgClientName = CntMsgClientName;
            viewBillingMessageDetails.CntMsgClientContactID = CntMsgClientContactID;
            viewBillingMessageDetails.CntMsgMessageSubject = CntMsgMessageSubject;
            viewBillingMessageDetails.CntMsgMessageFromName = CntMsgMessageFromName;
            viewBillingMessageDetails.CntMsgMessageBody = CntMsgMessageBody;
            viewBillingMessageDetails.CntMsgMessageToName = CntMsgMessageToName;
            viewBillingMessageDetails.CntMsgMessageFromEmail = CntMsgMessageFromEmail;
            viewBillingMessageDetails.CntMsgMessageToEmail = CntMsgMessageToEmail;
            viewBillingMessageDetails.CntMsgMessageCategory = CntMsgMessageCategory;
            viewBillingMessageDetails.CntMsgMessageFromPhone = CntMsgMessageFromPhone;

            ClientContact userresult = ClientContacts.GetClientContactFromClientContactID(CntMsgClientContactID);

            Dictionary<string, string> messagevalues = new Dictionary<string, string>();
            messagevalues.Add("[[COMPANYNAME]]", CntMsgClientName);
            messagevalues.Add("[[USERNAME]]", CntMsgMessageFromName);
            messagevalues.Add("[[USEREMAIL]]", CntMsgMessageFromEmail);
            messagevalues.Add("[[MESSAGECATEGORY]]", CntMsgMessageCategory);
            messagevalues.Add("[[USERPHONE]]", CntMsgMessageFromPhone);
            messagevalues.Add("[[MESSAGEBODY]]", CntMsgMessageBody);
            messagevalues.Add("[[CORPORATENAME]]", System.Configuration.ConfigurationManager.AppSettings["CompanyName"]);

            string subject = "Billing Client Request: " + CntMsgMessageSubject;

            MailGun.SendEmailToEmailAddressFromTemplate(4, 0, "Client Request", 0, ConfigurationManager.AppSettings["supportemail"], subject, "Tech Support", messagevalues);

            return new JsonResult { Data = new { success = true } };

            /*var messageRecord = Messages.GetMessageTemplateRecord(0, "Client Request", messagevalues);

            string messagebody = messageRecord != null ? messageRecord.MessageText : null;

            if (messagebody != null)
            {
                int messageActionType = messageRecord.MessageActionTypeID.GetValueOrDefault();
                int? MessageIDOutput = new int?();
                Guid? MessageActionGuidOutput = new Guid?();
                subject = "Billing Client Request: " + CntMsgMessageSubject;
                Messages.CreateMessageWithAction(messageActionType, subject, messagebody, 2, 1, 0, 3, "", System.DateTime.Now, null, "HTML", ref MessageIDOutput, ref MessageActionGuidOutput);
                Messages.UpdateMessageAndMarkForSending(MessageIDOutput.Value, subject, messagebody);
                return new JsonResult { Data = new { success = true } };
            }
            else
            {
                ModelState.AddModelError("ErrorMessages", "The message body was empty and could not be delivered. Please enter some information in the Message body and try again.");
                return new JsonResult
                {
                    Data = new
                    {
                        success = false,
                        view = RenderToString.RenderViewToString(this, "BillingMessage", viewBillingMessageDetails)
                    }
                };
            }*/

        }

    }
}
