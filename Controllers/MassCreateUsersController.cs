//#define DEBUG_EMAIL

using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Text.RegularExpressions;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ScreeningONE.Objects;
using ScreeningONE.ViewModels;
using ScreeningONE.DomainModels;
using ScreeningONE.Models;
using System.Threading;
using System.Configuration;

namespace ScreeningONE.Controllers
{
    [HandleError]
    [OutputCache(Location = OutputCacheLocation.None)]
    public class MassCreateUsersController : S1BaseController
    {
        //
        // GET: /MassCreateUsers/
        public MassCreateUsersController()
            : this(null)
        {
        }
        
        public MassCreateUsersController(MembershipProvider provider)
        {
            Provider = provider ?? Membership.Provider;
        }

        public MembershipProvider Provider
        {
            get;
            private set;
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs("GET")]
        public ActionResult CreateUsers()
        {
            
            return View();

        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs("POST")]
        public ActionResult CreateUsers(string myname)
        {

            var dbc = new ClientContactsDataContext();
            var resultc = dbc.S1_MassCreateUsers_GetClientContacts().ToList();

            bool CreateEmail;
            string username;
            string useremail;
            int newuserid = 0;

            foreach (var item in resultc)
            {
                
                if (String.IsNullOrEmpty(item.ClientContactEmail))
                {
                    username = System.Guid.NewGuid().ToString() + "@" + ConfigurationManager.AppSettings["companyname"] + ".com";
                    useremail = username;
                    CreateEmail = false;
                }
                else
                {

                    Regex emailregex = new Regex(@"^[\w-\.]+@([\w-]+\.)+[\w-]{2,7}$");

                    Match m = emailregex.Match(item.ClientContactEmail);
                    if (m.Success == false)
                    {
                        ViewData.ModelState.AddModelError("ErrorMessages", "Invalid email format. ClientContactID - " + item.ClientContactID);
                        CreateEmail = false;
                    }

                    username = item.ClientContactEmail;
                    useremail = item.ClientContactEmail;

                    if (item.ClientContactStatus == true)
                    {
                        CreateEmail = true;
                    }
                    else
                    {
                        CreateEmail = false;
                    }
                    

                }

                CreateEmail = false;

                if (ViewData.ModelState.IsValid)
                {

                    string ReturnURL = "/Security/ChangePassword";
                    string clientname = null;
                    string clientaddr1 = null;
                    string clientaddr2 = null;
                    string clientcity = null;
                    string clientstate = null;
                    string clientzipcode = null;
                    string contactpassword = item.ClientContactLastName.Substring(0, 3) + item.ClientContactZIP.Substring(0, 3) + item.ClientContactState;


                    //CHECK TO SEE IF THE USER ALREADY EXISTS
                    var dbu = new UsersDataContext();
                    var resultu = dbu.S1_Users_GetUserByEmail(item.ClientContactEmail).SingleOrDefault();

                    if (resultu == null)
                    {

                        //CREATE THE USER ACCOUNT      
                        // Attempt to register the user
                        MembershipCreateStatus createStatus;
                        MembershipUser newUser;

                        if (Convert.ToBoolean(item.ClientContactStatus)) //create a user for an active clientcontact record
                        {
                            newUser = Provider.CreateUser(username, contactpassword, useremail,
                            "client", "client", true, null, out createStatus);
                        }
                        else //create the user, but set IsActive to false on ASPNet security 
                        {
                            newUser = Provider.CreateUser(username, contactpassword, useremail,
                            "client", "client", false, null, out createStatus);
                        }

                        if (newUser != null)
                        {
                            var db = new UsersDataContext();
                            var result = db.S1_Users_CreateUser(username, item.ClientID, 1, item.ClientContactFirstName, item.ClientContactLastName).SingleOrDefault();
                            if (result.UserID > 0)
                            {
                                newuserid = Convert.ToInt32(result.UserID);

                                Roles.AddUserToRole(username, "Client");
                                Roles.AddUserToRole(username, "Client_Billing");

                                Provider.ChangePasswordQuestionAndAnswer(username, contactpassword, "What is your Company's zipcode?", item.ClientContactZIP);


                                if (CreateEmail)
                                {

                                    var db3 = new ClientsDataContext();
                                    var result3 = db3.S1_Clients_GetClientsFromUser(result.UserID).SingleOrDefault();

                                    if (result3 == null)
                                    {

                                        clientname = "";
                                        clientaddr1 = "";
                                        clientaddr2 = "";
                                        clientcity = "";
                                        clientstate = "";
                                        clientzipcode = "";
                                    }
                                    else
                                    {
                                        clientname = result3.ClientName;
                                        clientaddr1 = result3.Address1;
                                        clientaddr2 = result3.Address2;
                                        clientcity = result3.City;
                                        clientstate = result3.State;
                                        clientzipcode = result3.ZipCode;
                                    }

                                    string subject = ConfigurationManager.AppSettings["CompanyName"] + " Billing: New Account for " + item.ClientContactFirstName + " " + item.ClientContactLastName + " - " + clientname;


                                    var db1 = new UsersDataContext();
                                    //The following line is creating a message with a null status on purpose. Due to the actionGUID being used in the emails following. Note also this is S1_Users instead of S1_Messages
                                    var results1 = db.S1_Users_CreateMessageWithAction(1, subject, result.UserID, 1, 0, 3, HttpUtility.UrlDecode(ReturnURL), System.DateTime.Now, null).SingleOrDefault();

                                    if (results1.ActionGUID != null)
                                    {

                                        Dictionary<string, string> messagevalues = new Dictionary<string, string>();
                                        messagevalues.Add("[[USER_FIRSTNAME]]", "");
                                        messagevalues.Add("[[USER_MI]]", "");
                                        messagevalues.Add("[[USER_LASTNAME]]", "");
                                        messagevalues.Add("[[USER_TITLE]]", "");
                                        messagevalues.Add("[[COMPANY_ADDRESS_LINE1]]", clientaddr1);
                                        messagevalues.Add("[[COMPANY_ADDRESS_LINE2]]", clientaddr2);
                                        messagevalues.Add("[[COMPANY_ADDRESS_CITY]]", clientcity);
                                        messagevalues.Add("[[COMPANY_ADDRESS_STATE]]", clientstate);
                                        messagevalues.Add("[[COMPANY_ADDRESS_ZIPCODE]]", clientzipcode);
                                        messagevalues.Add("[[USER_EMAIL]]", item.ClientContactEmail);
                                        messagevalues.Add("[[USER_PHONE]]", "");
                                        messagevalues.Add("[[USERNAME]]", username);
                                        messagevalues.Add("[[COMPANYNAME]]", clientname);
                                        messagevalues.Add("[[PASSWORD]]", contactpassword);
                                        messagevalues.Add("[[GUIDURL]]", System.Configuration.ConfigurationManager.AppSettings["DefaultPath"] + "/Account/ConfirmEmail/" + results1.ActionGUID.ToString() + "?portal=client");

                                        var messageRecord = Messages.GetMessageTemplateRecord(0, "Create Client Account", messagevalues);

                                        string messagebody = messageRecord != null ? messageRecord.MessageText : null;

                                        if (messagebody != null)
                                        {
                                            int messageActionType = messageRecord.MessageActionTypeID.GetValueOrDefault();
                                            int? MessageIDOutput = new int?();
                                            Guid? MessageActionGuidOutput = new Guid?();

                                            //Send email with UserName
                                            Messages.CreateMessageWithAction(messageActionType, subject, messagebody, result.UserID, 1, 0, 3, HttpUtility.UrlDecode(ReturnURL), System.DateTime.Now, null, "HTML", ref MessageIDOutput, ref MessageActionGuidOutput);
                                            Messages.UpdateMessageAndMarkForSending(MessageIDOutput.Value, subject, messagebody);

                                            subject = ConfigurationManager.AppSettings["CompanyName"] + " Billing: " + item.ClientContactFirstName + " " + item.ClientContactLastName + " - " + clientname;
                                            
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
                                            //return View(viewClientContacts_Details);
                                        }
                                        else
                                        {
                                            ModelState.AddModelError("ErrorMessages", "There was a problem sending the confirmation email.  Please re-create the account. ");
                                            return View();
                                        }
                                    }
                                    else
                                    {

                                        ModelState.AddModelError("ErrorMessages", "There was a problem sending the confirmation email.  Please re-create the account.");
                                        return View();
                                    }
                                }
                            }
                            else
                            {
                                ModelState.AddModelError("ErrorMessages", ErrorHandler.ErrorCodeToString(createStatus));
                                return View();

                            }
                        }
                        else
                        {
                            ViewData.ModelState.AddModelError("ErrorMessages", ErrorHandler.ErrorCodeToString(createStatus));
                            return View();

                        }
                    } //END IF USER ALREADY EXISTS
                    else
                    {
                        newuserid = Convert.ToInt32(resultu.UserID);
                    }

                    //NOW UPDATE THE CLIENT CONTACT
                    var db6 = new ClientContactsDataContext();
                    var result6 = db6.S1_MassCreateUsers_UpdateClientContacts(item.ClientContactID, newuserid);

                    if (result6 != 0)
                    {
                        ModelState.AddModelError("ErrorMessages", "Error attaching the UserID to the ClientContact");
                        return View();

                    }

                }

            }
            ModelState.AddModelError("ErrorMessages", "UPDATE IS COMPLETE!!!");
            return View();

        }


        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs("GET")]
        public ActionResult CreateEmails()
        {

            return View();

        }



        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs("POST")]
        public ActionResult CreateEmails(string myname)
        {

            var dbc = new ClientContactsDataContext();
            var resultc = dbc.S1_MassCreateUsers_GetClientContactsEmail().ToList();

            string username;
            string useremail;

            foreach (var item in resultc)
            {

                Regex emailregex = new Regex(@"^[\w-\.]+@([\w-]+\.)+[\w-]{2,7}$");

                Match m = emailregex.Match(item.Email);
                if (m.Success == false)
                {
                    ViewData.ModelState.AddModelError("ErrorMessages", "Invalid email format. ClientContactID - " + item.Email);
                }

                username = item.UserName;
                useremail = item.Email;


                if (ViewData.ModelState.IsValid)
                {

                    string ReturnURL = "/Security/ChangePassword";
                    string contactpassword = item.ContactLastName.Substring(0, 3) + item.ContactZipCode.Substring(0, 3) + item.ContactState;

                    MembershipUser mu = Provider.GetUser(item.UserName, false);
                    Provider.ChangePasswordQuestionAndAnswer(item.UserName, contactpassword, "What is your Company's zipcode?", item.ContactZipCode);
                    Provider.UpdateUser(mu);

                        
                    string oldpassword = mu.ResetPassword();
                    Provider.ChangePassword(item.UserName, oldpassword, contactpassword);
                    Provider.UpdateUser(mu);

                    string subject = ConfigurationManager.AppSettings["CompanyName"] + " Billing: New Account for " + item.ContactFirstName + " " + item.ContactLastName + " - " + item.ClientName;


                    var db1 = new UsersDataContext();
                    //The following line is creating a message with a null status on purpose. Due to the actionGUID being used in the emails following. Note also this is S1_Users instead of S1_Messages
                    var results1 = db1.S1_Users_CreateMessageWithAction(1, subject, item.UserID, 1, 0, 3, HttpUtility.UrlDecode(ReturnURL), System.DateTime.Now, null).SingleOrDefault();

                    if (results1.ActionGUID != null)
                    {


                        Dictionary<string, string> messagevalues = new Dictionary<string, string>();
                        messagevalues.Add("[[USER_EMAIL]]", item.Email);
                        messagevalues.Add("[[USERNAME]]", item.UserName);
                        messagevalues.Add("[[COMPANYNAME]]", item.ClientName);
                        messagevalues.Add("[[PASSWORD]]", contactpassword);
                        messagevalues.Add("[[GUIDURL]]", System.Configuration.ConfigurationManager.AppSettings["DefaultPath"] + "/Account/ConfirmEmail/" + results1.ActionGUID.ToString() + "?portal=client");

                        var messageRecord = Messages.GetMessageTemplateRecord(0, "Create Client Account", messagevalues);

                        string messagebody = messageRecord != null ? messageRecord.MessageText : null;

                        if (messagebody != null)
                        {
                            int messageActionType = messageRecord.MessageActionTypeID.GetValueOrDefault();
                            int? MessageIDOutput = new int?();
                            Guid? MessageActionGuidOutput = new Guid?();

                            //Send email with UserName
                            Messages.CreateMessageWithAction(messageActionType, subject, messagebody, item.UserID, 1, 0, 3, HttpUtility.UrlDecode(ReturnURL), System.DateTime.Now, null, "HTML", ref MessageIDOutput, ref MessageActionGuidOutput);
                            Messages.UpdateMessageAndMarkForSending(MessageIDOutput.Value, subject, messagebody);

                            subject = ConfigurationManager.AppSettings["CompanyName"] + " Billing: " + item.ContactFirstName + " " + item.ContactLastName + " - " + item.ClientName;

                            db1.S1_Users_CreateMessageWithAction(2, subject, item.UserID, 1, 0, 3, "", System.DateTime.Now, null);

                            messageRecord = Messages.GetMessageTemplateRecord(0, "Create Client Password", messagevalues);

                            messagebody = messageRecord != null ? messageRecord.MessageText : null;

                            if (messagebody != null)
                            {
                                messageActionType = messageRecord.MessageActionTypeID.GetValueOrDefault();
                                MessageIDOutput = new int?();
                                MessageActionGuidOutput = new Guid?();

                                //Send email with Password
                                Messages.CreateMessageWithAction(messageActionType, subject, messagebody, item.UserID, 1, 0, 3, HttpUtility.UrlDecode(ReturnURL), System.DateTime.Now, null, "HTML", ref MessageIDOutput, ref MessageActionGuidOutput);
                                Messages.UpdateMessageAndMarkForSending(MessageIDOutput.Value, subject, messagebody);
                            }
                            
                        }
                        else
                        {
                            ModelState.AddModelError("ErrorMessages", "There was a problem sending the confirmation email for UserID - " + item.UserID);
                            return View();
                        }
                    }
                    else
                    {

                        ModelState.AddModelError("ErrorMessages", "There was a problem sending the confirmation email for UserID - " + item.UserID);
                        return View();
                    }
                }


                }

            ModelState.AddModelError("ErrorMessages", "EMAILS SENT!!!");
            return View();
        }

    }
    }


