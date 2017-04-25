//#define DEBUG_EMAIL

using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Web;
using System.Threading;
using System.Web.Security;
using System.Web.UI;
using System.Text.RegularExpressions;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ScreeningONE.Objects;
using ScreeningONE.ViewModels;
using ScreeningONE.DomainModels;
using System.Configuration;

namespace ScreeningONE.Controllers
{
    [OutputCache(Location = OutputCacheLocation.None)]
    public class ClientContactsController : S1BaseController
    {
        public ClientContactsController()
            : this(null)
        {
        }

        public ClientContactsController(MembershipProvider provider)
        {
            Provider = provider ?? Membership.Provider;
        }


        public MembershipProvider Provider
        {
            get;
            private set;
        }

        public ActionResult Index()
        {
            return View();
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [HttpPost]
        public JsonResult GetClientContactsForDropdownJSON(int id)
        {
            List<SelectListItem> clientcontacts = ClientContacts.GetBillingContactsFromClientForDropdown(id);

            var rows = clientcontacts.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult AddClientContact(int id, string cmdType) //id = ClientContactID
        {
            ClientContacts_Details viewClientContacts_Details = new ClientContacts_Details();

            viewClientContacts_Details.cmdType = cmdType;

            if (cmdType == "update")
            {
                ClientContact clientContact = ClientContacts.GetClientContactFromClientContactID(id);

                switch (clientContact.DeliveryMethod)
                {
                    case "Online": viewClientContacts_Details.DeliveryMethodVal = "0";
                        break;
                    case "Email-Auto": viewClientContacts_Details.DeliveryMethodVal = "1";
                        break;
                    case "Email-Manual": viewClientContacts_Details.DeliveryMethodVal = "2";
                        break;
                    case "Mail Only": viewClientContacts_Details.DeliveryMethodVal = "3";
                        break;
                    default: viewClientContacts_Details.DeliveryMethodVal = "0";
                        break;                
                }

                viewClientContacts_Details.ClientID = clientContact.ClientID;
                viewClientContacts_Details.ClientContactID = id;
                viewClientContacts_Details.ClientContactFirstName = clientContact.ClientContactFirstName;
                viewClientContacts_Details.ClientContactLastName = clientContact.ClientContactLastName;
                viewClientContacts_Details.ClientContactTitle = clientContact.ClientContactTitle;
                viewClientContacts_Details.ClientContactEmail = clientContact.ClientContactEmail;
                viewClientContacts_Details.ClientContactAddress1 = clientContact.ClientContactAddress1;
                viewClientContacts_Details.ClientContactAddress2 = clientContact.ClientContactAddress2;
                viewClientContacts_Details.ClientContactCity = clientContact.ClientContactCity;
                viewClientContacts_Details.ClientContactStateCode = clientContact.ClientContactStateCode;
                viewClientContacts_Details.ClientContactZIP = clientContact.ClientContactZIP;
                viewClientContacts_Details.ClientContactBusinessPhone = clientContact.ClientContactBusinessPhone;
                viewClientContacts_Details.ClientContactCellPhone = clientContact.ClientContactCellPhone;
                viewClientContacts_Details.ClientContactFax = clientContact.ClientContactFax;
                viewClientContacts_Details.BillingContactName = clientContact.BillingContactName;
                viewClientContacts_Details.BillingContactAddress1 = clientContact.BillingContactAddress1;
                viewClientContacts_Details.BillingContactAddress2 = clientContact.BillingContactAddress2;
                viewClientContacts_Details.BillingContactCity = clientContact.BillingContactCity;
                viewClientContacts_Details.BillingContactStateCode = clientContact.BillingContactStateCode;
                viewClientContacts_Details.BillingContactZIP = clientContact.BillingContactZIP;
                viewClientContacts_Details.BillingContactEmail = clientContact.BillingContactEmail;
                viewClientContacts_Details.BillingContactBusinessPhone = clientContact.BillingContactBusinessPhone;
                viewClientContacts_Details.BillingContactFax = clientContact.BillingContactFax;
                viewClientContacts_Details.BillingContactPOName = clientContact.BillingContactPOName;
                viewClientContacts_Details.BillingContactPONumber = clientContact.BillingContactPONumber;
                viewClientContacts_Details.DeliveryMethod = clientContact.DeliveryMethod;
                viewClientContacts_Details.BillingContactNotes = clientContact.BillingContactNotes;
                viewClientContacts_Details.IsBillingContact = clientContact.IsBillingContact;
                viewClientContacts_Details.IsPrimaryBillingContact = clientContact.IsPrimaryBillingContact;
                viewClientContacts_Details.OnlyShowInvoices = clientContact.OnlyShowInvoices;
                viewClientContacts_Details.ClientContactStatus = clientContact.ClientContactStatus;
                viewClientContacts_Details.BillingContactStatus = clientContact.BillingContactStatus;
                viewClientContacts_Details.ClientID = clientContact.ClientID;
                viewClientContacts_Details.UserID = clientContact.UserID;
                viewClientContacts_Details.BillingContactID = clientContact.BillingContactID;
            }
            else
            {

                viewClientContacts_Details.ClientID = id;
                viewClientContacts_Details.ClientContactFirstName = "";
                viewClientContacts_Details.ClientContactLastName = "";
                viewClientContacts_Details.ClientContactTitle = "";
                viewClientContacts_Details.ClientContactEmail = "";
                viewClientContacts_Details.ClientContactAddress1 = "";
                viewClientContacts_Details.ClientContactAddress2 = "";
                viewClientContacts_Details.ClientContactCity = "";
                viewClientContacts_Details.ClientContactStateCode = "";
                viewClientContacts_Details.ClientContactZIP = "";
                viewClientContacts_Details.ClientContactBusinessPhone = "";
                viewClientContacts_Details.ClientContactCellPhone = "";
                viewClientContacts_Details.ClientContactFax = "";
                viewClientContacts_Details.BillingContactName = "";
                viewClientContacts_Details.BillingContactAddress1 = "";
                viewClientContacts_Details.BillingContactAddress2 = "";
                viewClientContacts_Details.BillingContactCity = "";
                viewClientContacts_Details.BillingContactStateCode = "";
                viewClientContacts_Details.BillingContactZIP = "";
                viewClientContacts_Details.BillingContactEmail = "";
                viewClientContacts_Details.BillingContactBusinessPhone = "";
                viewClientContacts_Details.BillingContactFax = "";
                viewClientContacts_Details.BillingContactPOName = "";
                viewClientContacts_Details.BillingContactPONumber = "";
                viewClientContacts_Details.DeliveryMethod = "";
                viewClientContacts_Details.BillingContactNotes = "";
                viewClientContacts_Details.IsBillingContact = true;
                viewClientContacts_Details.IsPrimaryBillingContact = false;
                viewClientContacts_Details.OnlyShowInvoices = true;
                viewClientContacts_Details.ClientContactStatus = true;
                viewClientContacts_Details.BillingContactStatus = true;
                viewClientContacts_Details.ClientID = 0;
                viewClientContacts_Details.UserID = 0;
                viewClientContacts_Details.BillingContactID = 0;
            }
            
            return View(viewClientContacts_Details);
        }

        [ScreeningONEAuthorize(Portal="Admin", Roles="Admin")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult GetClientContactFromEmail(string Email)
        {
            ClientContact clientContact = ClientContacts.GetClientContactFromEmail(Email);

            if (clientContact.ClientContactID == 0)
                return new JsonResult { Data = new { success = false, clientcontact = clientContact } };
            else
                return new JsonResult { Data = new { success = true, clientcontact = clientContact } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult CreateClientContact(int id,  string ClientContactFirstName, string ClientContactLastName, string ClientContactTitle, string ClientContactEmail,
                         string ClientContactAddress1, string ClientContactAddress2,string ClientContactCity,string ClientContactStateCode, string ClientContactZIP,
                         string ClientContactBusinessPhone, string ClientContactCellPhone, string ClientContactFax,string BillingContactName, string BillingContactAddress1,
                         string BillingContactAddress2, string BillingContactCity, string BillingContactStateCode, string BillingContactZIP, 
                         string BillingContactBusinessPhone, string BillingContactFax, string BillingContactPOName, string BillingContactPONumber, string DeliveryMethod,
                         bool IsPrimaryBillingContact, bool OnlyShowInvoices, string cmdType, bool SendUserEmail) // id=ClientID
        {

            ClientContacts_Details viewClientContacts_Details = new ClientContacts_Details();

            viewClientContacts_Details.cmdType = cmdType;
            viewClientContacts_Details.ClientContactID = id;
            viewClientContacts_Details.ClientContactFirstName = ClientContactFirstName;
            viewClientContacts_Details.ClientContactLastName = ClientContactLastName;
            viewClientContacts_Details.ClientContactTitle = ClientContactTitle;
            viewClientContacts_Details.ClientContactEmail = ClientContactEmail;
            viewClientContacts_Details.ClientContactAddress1 = ClientContactAddress1;
            viewClientContacts_Details.ClientContactAddress2 = ClientContactAddress2;
            viewClientContacts_Details.ClientContactCity = ClientContactCity;
            viewClientContacts_Details.ClientContactStateCode = ClientContactStateCode;
            viewClientContacts_Details.ClientContactZIP = ClientContactZIP;
            viewClientContacts_Details.ClientContactBusinessPhone = ClientContactBusinessPhone;
            viewClientContacts_Details.ClientContactCellPhone = ClientContactCellPhone;
            viewClientContacts_Details.ClientContactFax = ClientContactFax;

            //Billing
            viewClientContacts_Details.BillingContactName = BillingContactName;
            viewClientContacts_Details.BillingContactAddress1 = BillingContactAddress1;
            viewClientContacts_Details.BillingContactAddress2 = BillingContactAddress2;
            viewClientContacts_Details.BillingContactCity = BillingContactCity;
            viewClientContacts_Details.BillingContactStateCode = BillingContactStateCode;
            viewClientContacts_Details.BillingContactZIP = BillingContactZIP;
            viewClientContacts_Details.BillingContactEmail = ClientContactEmail;
            viewClientContacts_Details.BillingContactBusinessPhone = BillingContactBusinessPhone;
            viewClientContacts_Details.ClientContactFax = ClientContactFax;
            viewClientContacts_Details.BillingContactPOName = BillingContactPOName;
            viewClientContacts_Details.BillingContactPONumber = BillingContactPONumber;
            viewClientContacts_Details.DeliveryMethod = DeliveryMethod;
            viewClientContacts_Details.BillingContactNotes = "";
            viewClientContacts_Details.OnlyShowInvoices = OnlyShowInvoices;
            viewClientContacts_Details.IsPrimaryBillingContact = IsPrimaryBillingContact;

            if (String.IsNullOrEmpty(viewClientContacts_Details.ClientContactFirstName))
            {
                ViewData.ModelState.AddModelError("ClientContactFirstName", " ");
                viewClientContacts_Details.ClientContactFirstName = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.ClientContactLastName))
            {
                ViewData.ModelState.AddModelError("ClientContactLastName", " ");
                viewClientContacts_Details.ClientContactLastName = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.ClientContactEmail))
            {
                ViewData.ModelState.AddModelError("ClientContactEmail", " ");
                viewClientContacts_Details.ClientContactEmail = "";
            }
            else
            {

                Regex emailregex = new Regex(@"^[\w-\.]+@([\w-]+\.)+[\w-]{2,7}$");

                Match m = emailregex.Match(viewClientContacts_Details.ClientContactEmail);
                if (m.Success == false)
                {
                    ViewData.ModelState.AddModelError("ClientContactEmail", "Invalid email format.");
                }

            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.ClientContactAddress1))
            {
                ViewData.ModelState.AddModelError("ClientContactAddress1", " ");
                viewClientContacts_Details.ClientContactAddress1 = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.ClientContactCity))
            {
                ViewData.ModelState.AddModelError("ClientContactCity", " ");
                viewClientContacts_Details.ClientContactCity = "";
            }
            
            if (String.IsNullOrEmpty(viewClientContacts_Details.ClientContactStateCode))
            {
                ViewData.ModelState.AddModelError("ClientContactStateCode", " ");
                viewClientContacts_Details.ClientContactStateCode = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.ClientContactZIP))
            {
                ViewData.ModelState.AddModelError("ClientContactZip", " ");
                viewClientContacts_Details.ClientContactZIP = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.BillingContactAddress1))
            {
                ViewData.ModelState.AddModelError("BillingContactAddress1", " ");
                viewClientContacts_Details.BillingContactAddress1 = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.BillingContactCity))
            {
                ViewData.ModelState.AddModelError("BillingContactCity", " ");
                viewClientContacts_Details.BillingContactCity = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.BillingContactStateCode))
            {
                ViewData.ModelState.AddModelError("BillingContactStateCode", " ");
                viewClientContacts_Details.BillingContactStateCode = "";
            }


            if (String.IsNullOrEmpty(viewClientContacts_Details.BillingContactZIP))
            {
                ViewData.ModelState.AddModelError("BillingContactZIP", " ");
                viewClientContacts_Details.BillingContactZIP = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.BillingContactEmail))
            {
                ViewData.ModelState.AddModelError("BillingContactEmail", " ");
                viewClientContacts_Details.BillingContactEmail = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.DeliveryMethod))
            {
                ViewData.ModelState.AddModelError("DeliveryMethod", " ");
                viewClientContacts_Details.DeliveryMethod = "";
            }


            
            if (ViewData.ModelState.IsValid) 
            {

                string ReturnURL = "/Security/ChangePassword";
                int contactuserid = 0;
                int contactclientid = id;
                string clientname = null;
                string clientstate = null;
                string clientzipcode = null;
                string contactpassword = viewClientContacts_Details.ClientContactLastName.Substring(0, 3) + viewClientContacts_Details.ClientContactZIP.Substring(0,3) + viewClientContacts_Details.ClientContactStateCode;


                //CHECK TO SEE IF THE USER ALREADY EXISTS
                var dbu = new UsersDataContext();
                var resultu = dbu.S1_Users_GetUserByEmail(viewClientContacts_Details.ClientContactEmail).SingleOrDefault();

                if (resultu == null)
                {

                    //CREATE THE USER ACCOUNT      
                    // Attempt to register the user
                    MembershipCreateStatus createStatus;
                    MembershipUser newUser = Provider.CreateUser(viewClientContacts_Details.ClientContactEmail, contactpassword, viewClientContacts_Details.ClientContactEmail,
                        "client", "client", true, null, out createStatus);

                    if (newUser != null)
                    {
                        var db = new UsersDataContext();
                        var result = db.S1_Users_CreateUser(viewClientContacts_Details.ClientContactEmail, contactclientid, 1, viewClientContacts_Details.ClientContactFirstName, viewClientContacts_Details.ClientContactLastName).SingleOrDefault();
                        if (result.UserID > 0)
                        {
                            contactuserid = Convert.ToInt32(result.UserID);

                            Roles.AddUserToRole(viewClientContacts_Details.ClientContactEmail, "Client");
                            Roles.AddUserToRole(viewClientContacts_Details.ClientContactEmail, "Client_Billing");

                        if (SendUserEmail)
                        {
                            var db3 = new UsersDataContext();
                            var result3 = db3.S1_Users_GetClientContactForEmail(contactuserid).SingleOrDefault();

                            if (result3 == null)
                            {

                                clientname = "";
                                clientstate = "";
                                clientzipcode = "";
                            }
                            else
                            {
                                clientname = result3.ClientName;
                                clientstate = result3.ContactState;
                                clientzipcode = result3.ContactZipCode;
                            }

                            string subject = ConfigurationManager.AppSettings["CompanyName"] + " Billing: New Account for " + viewClientContacts_Details.ClientContactFirstName + " " + viewClientContacts_Details.ClientContactLastName + " - " + Clients.GetClientNameFromID(viewClientContacts_Details.ClientID);


                            var db1 = new UsersDataContext();

                            //The following line is creating a message with a null status on purpose. Due to the actionGUID being used in the emails following. Note also this is S1_Users instead of S1_Messages
                            var results1 = db.S1_Users_CreateMessageWithAction(1, subject, result.UserID, 1, 0, 3, HttpUtility.UrlDecode(ReturnURL), System.DateTime.Now, null).SingleOrDefault();

                            if (results1.ActionGUID != null)
                            {
                                Provider.ChangePasswordQuestionAndAnswer(viewClientContacts_Details.ClientContactEmail, contactpassword, "What is your Company's zipcode?", viewClientContacts_Details.ClientContactZIP);

                                Dictionary<string, string> messagevalues = new Dictionary<string, string>();
                                messagevalues.Add("[[USER_FIRSTNAME]]", "");
                                messagevalues.Add("[[USER_MI]]", "");
                                messagevalues.Add("[[USER_LASTNAME]]", "");
                                messagevalues.Add("[[USER_TITLE]]", "");
                                messagevalues.Add("[[COMPANY_ADDRESS_STATE]]", clientstate);
                                messagevalues.Add("[[COMPANY_ADDRESS_ZIPCODE]]", clientzipcode);
                                messagevalues.Add("[[USER_EMAIL]]", viewClientContacts_Details.ClientContactEmail);
                                messagevalues.Add("[[USER_PHONE]]", "");
                                messagevalues.Add("[[USERNAME]]", viewClientContacts_Details.ClientContactEmail);
                                messagevalues.Add("[[COMPANYNAME]]", Clients.GetClientNameFromID(viewClientContacts_Details.ClientID));
                                messagevalues.Add("[[PASSWORD]]", contactpassword);
                                messagevalues.Add("[[GUIDURL]]", System.Configuration.ConfigurationManager.AppSettings["DefaultPath"] + "/Account/ConfirmEmail/" + results1.ActionGUID.ToString() + "?portal=client");
                                messagevalues.Add("[[CORPORATENAME]]", ConfigurationManager.AppSettings["CompanyName"]);

                                MailGun.SendEmailToUserFromTemplate(10, 0, "Create Client Account", 0, result.UserID.Value, 0, subject, messagevalues);
                                
                                subject = ConfigurationManager.AppSettings["CompanyName"] + " Billing: " + viewClientContacts_Details.ClientContactFirstName + " " + viewClientContacts_Details.ClientContactLastName + " - " + Clients.GetClientNameFromID(viewClientContacts_Details.ClientID);

                                MailGun.SendEmailToUserFromTemplate(11, 0, "Create Client Password", 0, result.UserID.Value, 0, subject, messagevalues);

                                /* var messageRecord = Messages.GetMessageTemplateRecord(0, "Create Client Account", messagevalues);

                                string messagebody = messageRecord != null ? messageRecord.MessageText : null;

                                if (messagebody != null)
                                {
                                    int messageActionType = messageRecord.MessageActionTypeID.GetValueOrDefault();
                                    int? MessageIDOutput = new int?();
                                    Guid? MessageActionGuidOutput = new Guid?();

                                    //Send email with UserName
                                    Messages.CreateMessageWithAction(messageActionType, subject, messagebody, result.UserID, 1, 0, 3, HttpUtility.UrlDecode(ReturnURL), System.DateTime.Now, null, "HTML", ref MessageIDOutput, ref MessageActionGuidOutput);
                                    Messages.UpdateMessageAndMarkForSending(MessageIDOutput.Value, subject, messagebody);

                                    subject = ConfigurationManager.AppSettings["CompanyName"] + " Billing: " + viewClientContacts_Details.ClientContactFirstName + " " + viewClientContacts_Details.ClientContactLastName + " - " + clientname;

                                    messageRecord = Messages.GetMessageTemplateRecord(0, "Create Client Password", messagevalues);

                                    messagebody = messageRecord != null ? messageRecord.MessageText : null;

                                    if (messagebody != null)
                                    {
                                        messageActionType = messageRecord.MessageActionTypeID.GetValueOrDefault();
                                        MessageIDOutput = new int?();
                                        MessageActionGuidOutput = new Guid?();

                                        //Send email with Password
                                        Messages.CreateMessageWithAction(messageActionType, subject, messagebody, result.UserID, 1, 0, 3, HttpUtility.UrlDecode(ReturnURL), System.DateTime.Now, null, "HTML", ref MessageIDOutput, ref MessageActionGuidOutput);
                                        Messages.UpdateMessageAndMarkForSending(MessageIDOutput.Value, subject, messagebody);
                                    }
                                }
                                else
                                {
                                    ModelState.AddModelError("ErrorMessages", "There was a problem sending the confirmation email.  Please re-create the account. ");
                                    return new JsonResult
                                    {
                                        Data = new
                                        {
                                            success = false,
                                            view = RenderToString.RenderViewToString(this, "AddClientContact", viewClientContacts_Details)
                                        }
                                    };
                                }*/
                            }
                            else
                            {

                                ModelState.AddModelError("ErrorMessages", "There was a problem sending the confirmation email.  Please re-create the account.");
                                return new JsonResult
                                {
                                    Data = new
                                    {
                                        success = false,
                                        view = RenderToString.RenderViewToString(this, "AddClientContact", viewClientContacts_Details)
                                    }
                                };
                            }

                          }
                        }
                        else
                        {
                            ModelState.AddModelError("ErrorMessages", ErrorHandler.ErrorCodeToString(createStatus));
                            return new JsonResult
                            {
                                Data = new
                                {
                                    success = false,
                                    view = RenderToString.RenderViewToString(this, "AddClientContact", viewClientContacts_Details)
                                }
                            };
                        }
                    }
                    else
                    {
                        ViewData.ModelState.AddModelError("ErrorMessages", ErrorHandler.ErrorCodeToString(createStatus));
                        return new JsonResult
                        {
                            Data = new
                            {
                                success = false,
                                view = RenderToString.RenderViewToString(this, "AddClientContact", viewClientContacts_Details)
                            }
                        };

                    }
                } //END IF USER ALREADY EXISTS
                else
                {
                    contactuserid = Convert.ToInt32(resultu.UserID);
                }

                //NOW CREATE THE CLIENT CONTACT
                viewClientContacts_Details.ClientContactID = ClientContacts.CreateClientContact(contactuserid, contactclientid, viewClientContacts_Details.ClientContactFirstName,
                                    viewClientContacts_Details.ClientContactLastName, viewClientContacts_Details.ClientContactTitle, viewClientContacts_Details.ClientContactAddress1,
                                    viewClientContacts_Details.ClientContactAddress2, viewClientContacts_Details.ClientContactCity, viewClientContacts_Details.ClientContactStateCode,
                                    viewClientContacts_Details.ClientContactZIP, viewClientContacts_Details.ClientContactBusinessPhone, viewClientContacts_Details.ClientContactCellPhone,
                                    viewClientContacts_Details.ClientContactFax, viewClientContacts_Details.ClientContactEmail);

                if (viewClientContacts_Details.ClientContactID == 0)
                {
                    ModelState.AddModelError("ErrorMessages", "ERROR: This may be a duplicate contact or another contact on this client has the same email.");
                    return new JsonResult
                    {
                        Data = new
                        {
                            success = false,
                            view = RenderToString.RenderViewToString(this, "AddClientContact", viewClientContacts_Details)
                        }
                    };
                }

                ClientContacts.FixIssuesBillingContact(contactclientid);

                //NOW CREATE THE BILLING CONTACT (if chosen)
                int billingcontactid = ClientContacts.CreateBillingContact(contactclientid, viewClientContacts_Details.ClientContactID, Convert.ToInt32(viewClientContacts_Details.DeliveryMethod),
                                       viewClientContacts_Details.BillingContactName, viewClientContacts_Details.BillingContactAddress1, viewClientContacts_Details.BillingContactAddress2,
                                       viewClientContacts_Details.BillingContactCity, viewClientContacts_Details.BillingContactStateCode, viewClientContacts_Details.BillingContactZIP,
                                       viewClientContacts_Details.BillingContactBusinessPhone, viewClientContacts_Details.BillingContactFax, viewClientContacts_Details.BillingContactEmail,
                                       viewClientContacts_Details.IsPrimaryBillingContact, viewClientContacts_Details.BillingContactPOName, viewClientContacts_Details.BillingContactPONumber,
                                       viewClientContacts_Details.BillingContactNotes, viewClientContacts_Details.OnlyShowInvoices);

                if (billingcontactid == 0)
                {
                    ModelState.AddModelError("ErrorMessages", "ERROR: This may be a duplicate billing contact or SplitInvoice Client.");
                    return new JsonResult
                    {
                        Data = new
                        {
                            success = false,
                            view = RenderToString.RenderViewToString(this, "AddClientContact", viewClientContacts_Details)
                        }
                    };
                }
                else
                {
                    ClientContacts.FixIssuesBillingContact(contactclientid);
                    
                    if (viewClientContacts_Details.IsPrimaryBillingContact)
                    {
                        viewClientContacts_Details.BillingContactStatus = true;

                        int resultbilling = ClientContacts.UpdateBillingContact(billingcontactid, contactclientid, viewClientContacts_Details.ClientContactID, Convert.ToInt32(viewClientContacts_Details.DeliveryMethod),
                                            viewClientContacts_Details.BillingContactName, viewClientContacts_Details.BillingContactAddress1, viewClientContacts_Details.BillingContactAddress2,
                                            viewClientContacts_Details.BillingContactCity, viewClientContacts_Details.BillingContactStateCode, viewClientContacts_Details.BillingContactZIP,
                                            viewClientContacts_Details.BillingContactBusinessPhone, viewClientContacts_Details.BillingContactFax, viewClientContacts_Details.BillingContactEmail,
                                            viewClientContacts_Details.IsPrimaryBillingContact, viewClientContacts_Details.BillingContactPOName, viewClientContacts_Details.BillingContactPONumber,
                                            viewClientContacts_Details.BillingContactNotes, viewClientContacts_Details.OnlyShowInvoices, viewClientContacts_Details.BillingContactStatus, viewClientContacts_Details.NewPrimaryContactID);

                        if (resultbilling != 0)
                        {
                            ModelState.AddModelError("ErrorMessages", "ERROR: This may be a duplicate billing contact or SplitInvoice Client.");
                            return new JsonResult
                            {
                                Data = new
                                {
                                    success = false,
                                    view = RenderToString.RenderViewToString(this, "AddClientContact", viewClientContacts_Details)
                                }
                            };
                        }
                        else
                        {
                            ClientContacts.FixIssuesBillingContact(contactclientid);
                        }
                    }

                    return new JsonResult
                    {
                        Data = new
                        {
                            success = true,
                            billingcontactid = billingcontactid
                        }
                    };

                }

            }
            else
            {
                ModelState.AddModelError("ErrorMessages", "ERROR: Please fill in all required fields. ");
                return new JsonResult
                {
                    Data = new
                    {
                        success = false,
                        view = RenderToString.RenderViewToString(this, "AddClientContact", viewClientContacts_Details)
                    }
                };
            }
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult UpdateClientContact(int ClientContactID, string ClientContactFirstName, string ClientContactLastName, string ClientContactTitle, string ClientContactEmail,
                         string ClientContactAddress1, string ClientContactAddress2,string ClientContactCity,string ClientContactStateCode,string ClientContactZIP,
                         string ClientContactBusinessPhone, string ClientContactCellPhone,string ClientContactFax, string BillingContactName,string BillingContactAddress1,
                         string BillingContactAddress2,string BillingContactCity,string BillingContactStateCode,string BillingContactZIP,
                         string BillingContactBusinessPhone,string BillingContactFax,string BillingContactPOName, string BillingContactPONumber,string DeliveryMethod,
                         bool IsPrimaryBillingContact, bool OnlyShowInvoices, string cmdType, int ClientContactStatus, int BillingContactStatus,
                         int ClientID, int UserID, int BillingContactID, int NewPrimaryContactID) 
            // id=ClientContactID
        {

            ClientContacts_Details viewClientContacts_Details = new ClientContacts_Details();

            viewClientContacts_Details.cmdType = cmdType;
            viewClientContacts_Details.ClientContactFirstName = ClientContactFirstName;
            viewClientContacts_Details.ClientContactLastName = ClientContactLastName;
            viewClientContacts_Details.ClientContactTitle = ClientContactTitle;
            viewClientContacts_Details.ClientContactEmail = ClientContactEmail;
            viewClientContacts_Details.ClientContactAddress1 = ClientContactAddress1;
            viewClientContacts_Details.ClientContactAddress2 = ClientContactAddress2;
            viewClientContacts_Details.ClientContactCity = ClientContactCity;
            viewClientContacts_Details.ClientContactStateCode = ClientContactStateCode;
            viewClientContacts_Details.ClientContactZIP = ClientContactZIP;
            viewClientContacts_Details.ClientContactBusinessPhone = ClientContactBusinessPhone;
            viewClientContacts_Details.ClientContactCellPhone = ClientContactCellPhone;
            viewClientContacts_Details.ClientContactFax = ClientContactFax;
            viewClientContacts_Details.ClientContactStatus = Convert.ToBoolean(ClientContactStatus);

            //Billing
            viewClientContacts_Details.BillingContactName = BillingContactName;
            viewClientContacts_Details.BillingContactAddress1 = BillingContactAddress1;
            viewClientContacts_Details.BillingContactAddress2 = BillingContactAddress2;
            viewClientContacts_Details.BillingContactCity = BillingContactCity;
            viewClientContacts_Details.BillingContactStateCode = BillingContactStateCode;
            viewClientContacts_Details.BillingContactZIP = BillingContactZIP;
            viewClientContacts_Details.BillingContactEmail = ClientContactEmail;
            viewClientContacts_Details.BillingContactBusinessPhone = BillingContactBusinessPhone;
            viewClientContacts_Details.ClientContactFax = ClientContactFax;
            viewClientContacts_Details.BillingContactPOName = BillingContactPOName;
            viewClientContacts_Details.BillingContactPONumber = BillingContactPONumber;
            viewClientContacts_Details.DeliveryMethod = DeliveryMethod;
            viewClientContacts_Details.BillingContactNotes = "";
            viewClientContacts_Details.OnlyShowInvoices = OnlyShowInvoices;
            viewClientContacts_Details.IsPrimaryBillingContact = IsPrimaryBillingContact;
            viewClientContacts_Details.BillingContactStatus = Convert.ToBoolean(BillingContactStatus);
            viewClientContacts_Details.NewPrimaryContactID = Convert.ToInt32(NewPrimaryContactID);


            if (String.IsNullOrEmpty(viewClientContacts_Details.ClientContactFirstName))
            {
                ViewData.ModelState.AddModelError("ClientContactFirstName", " ");
                viewClientContacts_Details.ClientContactFirstName = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.ClientContactLastName))
            {
                ViewData.ModelState.AddModelError("ClientContactLastName", " ");
                viewClientContacts_Details.ClientContactLastName = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.ClientContactEmail))
            {
                ViewData.ModelState.AddModelError("ClientContactEmail", " ");
                viewClientContacts_Details.ClientContactEmail = "";
            }
            else
            {

                Regex emailregex = new Regex(@"^[\w-\.]+@([\w-]+\.)+[\w-]{2,7}$");

                Match m = emailregex.Match(viewClientContacts_Details.ClientContactEmail);
                if (m.Success == false)
                {
                    ViewData.ModelState.AddModelError("ClientContactEmail", "Invalid email format.");
                }

            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.ClientContactAddress1))
            {
                ViewData.ModelState.AddModelError("ClientContactAddress1", " ");
                viewClientContacts_Details.ClientContactAddress1 = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.ClientContactCity))
            {
                ViewData.ModelState.AddModelError("ClientContactCity", " ");
                viewClientContacts_Details.ClientContactCity = "";
            }
            
            if (String.IsNullOrEmpty(viewClientContacts_Details.ClientContactStateCode))
            {
                ViewData.ModelState.AddModelError("ClientContactStateCode", " ");
                viewClientContacts_Details.ClientContactStateCode = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.ClientContactZIP))
            {
                ViewData.ModelState.AddModelError("ClientContactZip", " ");
                viewClientContacts_Details.ClientContactZIP = "";
            }


            if (String.IsNullOrEmpty(viewClientContacts_Details.BillingContactAddress1))
            {
                ViewData.ModelState.AddModelError("BillingContactAddress1", " ");
                viewClientContacts_Details.BillingContactAddress1 = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.BillingContactCity))
            {
                ViewData.ModelState.AddModelError("BillingContactCity", " ");
                viewClientContacts_Details.BillingContactCity = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.BillingContactStateCode))
            {
                ViewData.ModelState.AddModelError("BillingContactStateCode", " ");
                viewClientContacts_Details.BillingContactStateCode = "";
            }


            if (String.IsNullOrEmpty(viewClientContacts_Details.BillingContactZIP))
            {
                ViewData.ModelState.AddModelError("BillingContactZIP", " ");
                viewClientContacts_Details.BillingContactZIP = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.BillingContactEmail))
            {
                ViewData.ModelState.AddModelError("BillingContactEmail", " ");
                viewClientContacts_Details.BillingContactEmail = "";
            }

            if (String.IsNullOrEmpty(viewClientContacts_Details.DeliveryMethod))
            {
                ViewData.ModelState.AddModelError("DeliveryMethod", " ");
                viewClientContacts_Details.DeliveryMethod = "";
            }

            if (viewClientContacts_Details.IsPrimaryBillingContact && (
                    !viewClientContacts_Details.BillingContactStatus || !viewClientContacts_Details.ClientContactStatus))
            {
                ViewData.ModelState.AddModelError("ErrorMessages", "Primary billing contacts cannot be inactive. Please choose a new primary before inactivating or make this contact active.");
            }

            if (viewClientContacts_Details.IsPrimaryBillingContact &&
                           !viewClientContacts_Details.BillingContactStatus)
            {
                ViewData.ModelState.AddModelError("ErrorMessages", "You must first pick a new primary billing contact before inactivating this one.");
            }


            
            if (ViewData.ModelState.IsValid) 
            {
                
                //NOW UPDATE THE CLIENT CONTACT
                int results = ClientContacts.UpdateClientContact(ClientContactID, UserID, ClientID, viewClientContacts_Details.ClientContactFirstName,
                                    viewClientContacts_Details.ClientContactLastName, viewClientContacts_Details.ClientContactTitle, viewClientContacts_Details.ClientContactAddress1,
                                    viewClientContacts_Details.ClientContactAddress2, viewClientContacts_Details.ClientContactCity, viewClientContacts_Details.ClientContactStateCode,
                                    viewClientContacts_Details.ClientContactZIP, viewClientContacts_Details.ClientContactBusinessPhone, viewClientContacts_Details.ClientContactCellPhone,
                                    viewClientContacts_Details.ClientContactFax, viewClientContacts_Details.ClientContactEmail, viewClientContacts_Details.ClientContactStatus);

              if (results != 0)
                {
                    ModelState.AddModelError("ErrorMessages", "ERROR: The Client Contact was not updated. Please try again.");
                    return new JsonResult
                    {
                        Data = new
                        {
                            success = false,
                            view = RenderToString.RenderViewToString(this, "AddClientContact", viewClientContacts_Details)
                        }
                    };
                }

              ClientContacts.FixIssuesBillingContact(ClientID);

              //NOW UPDATE THE Billing CONTACT
              int resultbilling = ClientContacts.UpdateBillingContact(BillingContactID, ClientID, ClientContactID, Convert.ToInt32(viewClientContacts_Details.DeliveryMethod),
                                       viewClientContacts_Details.BillingContactName, viewClientContacts_Details.BillingContactAddress1, viewClientContacts_Details.BillingContactAddress2,
                                       viewClientContacts_Details.BillingContactCity, viewClientContacts_Details.BillingContactStateCode, viewClientContacts_Details.BillingContactZIP,
                                       viewClientContacts_Details.BillingContactBusinessPhone, viewClientContacts_Details.BillingContactFax, viewClientContacts_Details.BillingContactEmail,
                                       viewClientContacts_Details.IsPrimaryBillingContact, viewClientContacts_Details.BillingContactPOName, viewClientContacts_Details.BillingContactPONumber,
                                       viewClientContacts_Details.BillingContactNotes, viewClientContacts_Details.OnlyShowInvoices, viewClientContacts_Details.BillingContactStatus, viewClientContacts_Details.NewPrimaryContactID);

              if (resultbilling != 0)
              {
                  if (resultbilling == -1)
                  {
                      ModelState.AddModelError("ErrorMessages", "Changing Primary Billing contact disallowed [Error Code:" + resultbilling.ToString() + "]. There are too many Primary Contacts. (SP: S1_ClientContacts_UpdateBillingContact)");
                  }

                  if (resultbilling == -2)
                  {
                      ModelState.AddModelError("ErrorMessages", "Another Primary Billing Contact already exists [Error Code:" + resultbilling.ToString() + "]. This contact was defaulted to Secondary. (SP: S1_ClientContacts_UpdateBillingContact)");
                  }

                  if (resultbilling == -5)
                  {
                      ModelState.AddModelError("ErrorMessages", "Client Split detected [Error Code:" + resultbilling.ToString() + "]. Primary Contact data will remain unchanged. Please contact IT to resolve primary contact invoice split if needed. (SP: S1_ClientContacts_UpdateBillingContact)");
                  }

                  if (resultbilling == -4)
                  {
                      ModelState.AddModelError("ErrorMessages", "Billing contact integrity issue detected [Error Code:" + resultbilling.ToString() + "]. Primary Contact data will remain unchanged. Please contact IT to resolve integrity issue. (SP: S1_ClientContacts_UpdateBillingContact)");
                  }

                  if (resultbilling == -3)
                  {
                      ModelState.AddModelError("ErrorMessages", "Billing contact integrity issue detected [Error Code:" + resultbilling.ToString() + "]. Primary Contact data will remain unchanged. Please contact IT to resolve integrity issue. (SP: S1_ClientContacts_UpdateBillingContact)");
                  }

                  if (resultbilling != 0)
                  {
                      ModelState.AddModelError("ErrorMessages", "There was an unknown error [Error Code:" + resultbilling.ToString() + "]. Please contact IT. (SP: S1_ClientContacts_UpdateBillingContact)");

                  }
                  return new JsonResult
                  {
                      Data = new
                      {
                          success = false,
                          view = RenderToString.RenderViewToString(this, "AddClientContact", viewClientContacts_Details)
                      }
                  };
              }                
              
              return new JsonResult
              {
                  Data = new
                  {
                      success = true,
                      view = RenderToString.RenderViewToString(this, "AddClientContact", viewClientContacts_Details)
                  }
              };

            }
            else
            {
                ModelState.AddModelError("ErrorMessages", "ERROR: Please be sure required fields are filled. ");
                return new JsonResult
                {
                    Data = new
                    {
                        success = false,
                        view = RenderToString.RenderViewToString(this, "AddClientContact", viewClientContacts_Details)
                    }
                };
            }
        
        
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult DeleteClientContactJSON(int ClientContactID, int BillingContactID, int ClientID, int UserID)
        {
            int resultdelete = ClientContacts.DeleteClientContact(ClientContactID, BillingContactID, ClientID, UserID);

            if (resultdelete != 0)
            {
                if (resultdelete == -1)
                {
                    ModelState.AddModelError("ErrorMessages", "This is the only client contact so it cannot be deleted.");
                }

                if (resultdelete == -2)
                {
                    ModelState.AddModelError("ErrorMessages", "You cannot delete a contact that is set as the billing primary contact. Contact was not deleted.");
                }

                return new JsonResult { Data = new { success = false } };
            }
            else
            {
                return new JsonResult { Data = new { success = true } };
            }
        }
    
    }
}
