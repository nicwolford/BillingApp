//#define DEBUG_EMAIL

using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Security.Principal;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using System.Web.UI;
using System.Text.RegularExpressions;
using ScreeningONE.Objects;
using ScreeningONE.ViewModels;
using ScreeningONE.DomainModels;
using System.Configuration;

namespace ScreeningONE.Controllers
{
    [HandleError]
    [OutputCache(Location = OutputCacheLocation.None)]
    public class SecurityController : S1BaseController
    {

        public SecurityController()
            : this(null)
        {
        }

        public SecurityController(MembershipProvider provider)
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
        public ActionResult Security()
        {
            Security_Users viewSecuritySetup = new Security_Users();
            List<SelectListItem> clientselectlist = Clients.GetClientListForDropdown();

            viewSecuritySetup.ClientID = Int32.Parse(clientselectlist.ElementAt(0).Value);
            viewSecuritySetup.userlist = Clients.GetClientUsers(viewSecuritySetup.ClientID);

            return View(viewSecuritySetup);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs("GET")]
        public ActionResult SecurityUserSettings(int id)
        {
            Security_Users viewSecuritySetup = new Security_Users();

            viewSecuritySetup.userlist = Clients.GetClientUsers(viewSecuritySetup.ClientID);

            if (id != 0)
            {
                ClientContact clientContact = ClientContacts.GetClientContactFromUserID(id);
                viewSecuritySetup.username = clientContact.LoginUserName;
                viewSecuritySetup.UserID = clientContact.UserID;
                if (viewSecuritySetup.username != null)
                {
                    MembershipUser mu = Provider.GetUser(viewSecuritySetup.username, false);
                    if (mu != null)
                    {
                        viewSecuritySetup.IsApproved = mu.IsApproved;
                    }
                    else
                    {
                        viewSecuritySetup.IsApproved = true;
                    }
                }
                else
                {
                    viewSecuritySetup.username = "";
                    viewSecuritySetup.IsApproved = true;
                }
            }
            else
            {
                viewSecuritySetup.username = "";
                viewSecuritySetup.IsApproved = true;
            }

            return View(viewSecuritySetup);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult GetSecurityUsersJSON(FormCollection fc)
        {
            int ID = Convert.ToInt32(fc["id"]);
            string FieldToSort = fc["sidx"];
            string strSortOrder = fc["sord"];
            bool _search = Convert.ToBoolean(fc["_search"]);
            string searchField = fc["searchField"];
            string searchOper = fc["searchOper"];
            string searchString = fc["searchString"];


            SortDirection SortOrder;

            if (FieldToSort == "id" || FieldToSort == "UserID" || FieldToSort == "UserName" || FieldToSort == "IsApproved")
            {
                FieldToSort = "UserName";
            }

            if (FieldToSort == "ClientName")
            {
                FieldToSort = "ClientName";
            }

            if (strSortOrder == "desc")
                SortOrder = SortDirection.Descending;
            else
                SortOrder = SortDirection.Ascending;

            int RowsPerPage = Convert.ToInt32(fc["rows"]);
            int CurrentPage = Convert.ToInt32(fc["page"]);
            int StartRow = ((CurrentPage - 1) * RowsPerPage) + 1;
            int EndRow = StartRow + RowsPerPage - 1;

            List<ScreeningONE.Models.S1_Users_GetAllClientUsersResult> Users = Clients.GetAllClientUsers();
            List<ScreeningONE.Models.S1_Users_GetAllClientUsersResult> result;

            if (_search)

                switch (searchField)
                {
                    case "UserName":
                        result = Users.Where(x => x.UserName.ToUpper().Contains(searchString.ToUpper())).ToList();
                        break;

                    case "ClientName":
                        result = Users.Where(x => x.ClientName.ToUpper().Contains(searchString.ToUpper())).ToList();
                        break;

                    default:
                        result = Users.ToList();
                        break;

                }

            else
                result = Users.ToList();


            //var Users = Clients.GetClientUsers(ClientID);
            Array rows = (from question in result.Order(FieldToSort, SortOrder)
                    select new
                    {
                        i = question.ClientUsersID,
                        cell = new string[] { question.ClientUsersID.ToString(),
                                  question.UserID.ToString(),
                                  question.UserName,
                                  question.ClientName,
                                  (question.IsApproved ? "Active" : "Inactive")
                        }
                    }
                          ).Skip(StartRow - 1).Take(RowsPerPage).ToArray();

            int totalRows = result.Count;

            var ret = new JsonResult
            {
                Data = new
                {
                    page = CurrentPage,
                    records = totalRows,
                    rows = rows,
                    total = Math.Ceiling(Convert.ToDouble((double)totalRows / (double)RowsPerPage))
                }
            };

            return ret;
          
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult UserClientContactsJSON(int UserID, FormCollection fc)
        {
            int ID = Convert.ToInt32(fc["id"]);
            string FieldToSort = fc["sidx"];
            string strSortOrder = fc["sord"];
            SortDirection SortOrder;

            if (FieldToSort == "id" || FieldToSort == "Action" || FieldToSort == "ClientContactEmail" || FieldToSort == "ClientContactStatus")
            {
                FieldToSort = "ClientContactName";
            }

            if (FieldToSort == "ClientName")
            {
                FieldToSort = "ClientName";
            }

            if (strSortOrder == "desc")
                SortOrder = SortDirection.Descending;
            else
                SortOrder = SortDirection.Ascending;

            int RowsPerPage = Convert.ToInt32(fc["rows"]);
            int CurrentPage = Convert.ToInt32(fc["page"]);
            int StartRow = ((CurrentPage - 1) * RowsPerPage) + 1;
            int EndRow = StartRow + RowsPerPage - 1;


            List<ScreeningONE.DomainModels.Security.UserClientContact> UserContacts = ScreeningONE.DomainModels.Security.GetUserClientContacts(UserID);
            List<ScreeningONE.DomainModels.Security.UserClientContact> result;

            result = UserContacts.ToList();

            Array rows = (from question in result.Order(FieldToSort, SortOrder)

                          select new
                          {
                              i = question.ClientContactID,
                              cell = new string[] { question.ClientContactID.ToString(), 
                                  question.ClientContactEmail,
                                  question.ClientContactName,
                                  question.ClientName,
                                  (question.ClientContactStatus ? "Active" : "Inactive")}
                          }
                          ).Skip(StartRow - 1).Take(RowsPerPage).ToArray();

            int totalRows = result.Count;

            var ret = new JsonResult
            {
                Data = new
                {
                    page = CurrentPage,
                    records = totalRows,
                    rows = rows,
                    total = Math.Ceiling(Convert.ToDouble((double)totalRows / (double)RowsPerPage))
                }
            };

            return ret;
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult SaveUserProfileJSON(string OldUserName, string UserNameEmail, bool Inactive)
        {
            MembershipUser mu = Provider.GetUser(OldUserName, false);

            //Check to see if the old and new names are the same
            if (OldUserName != UserNameEmail)
            {
                if (Membership.GetUser(UserNameEmail) != null)
                {
                    return new JsonResult { Data = new { success = false, error = "New User Name / Email already exists!" } };
                }

                mu.Email = UserNameEmail;
                mu.IsApproved = !Inactive;
                Membership.UpdateUser(mu);

                UsersDataContext dc= new UsersDataContext();
                dc.S1_Users_ModifyUserName(OldUserName, UserNameEmail);

                return new JsonResult { Data = new { success = true, error = "User Name / Email changed!" } };
            }

            mu.IsApproved = !Inactive;
            Membership.UpdateUser(mu);

            //The names are the same, no change required
            return new JsonResult { Data = new { success = true, error = "Changes Saved!" } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs(HttpVerbs.Post)]
        public JsonResult ResetUserPasswordJSON(string OldUserName, int UserID, string UserNameEmail, bool Inactive)
        {
            //Check to see if the old and new names are the same
            if (OldUserName != UserNameEmail)
            {
                return new JsonResult { Data = new { success = false, error = "You must first save the changed username before sending email." } };
            }

            if (Inactive)
            {
                return new JsonResult { Data = new { success = false, error = "Please activate the user and save the change before attempting to reset the password." } };

            }

            Regex emailregex = new Regex(@"^[\w-\.]+@([\w-]+\.)+[\w-]{2,7}$");

            Match m = emailregex.Match(UserNameEmail);
            if (m.Success == false)
            {
                return new JsonResult { Data = new { success = false, error = "Invalid Email Format." } };
            }


            if (ViewData.ModelState.IsValid)
            {

                var db3 = new UsersDataContext();
                var result3 = db3.S1_Users_GetClientContactForEmail(UserID).SingleOrDefault();

                string ReturnURL = "/Security/ChangePassword";
                string contactpassword = result3.ContactLastName.Substring(0, 3) + result3.ContactZipCode.Substring(0, 3) + result3.ContactState;

                MembershipUser mu = Provider.GetUser(result3.UserName, false);
                Provider.ChangePasswordQuestionAndAnswer(result3.UserName, contactpassword, "What is your Company's zipcode?", result3.ContactZipCode);
                Provider.UpdateUser(mu);


                string oldpassword = mu.ResetPassword();
                Provider.ChangePassword(result3.UserName, oldpassword, contactpassword);
                Provider.UpdateUser(mu);

                string subject = ConfigurationManager.AppSettings["CompanyName"] + " Billing: Account for " + result3.ContactFirstName + " " + result3.ContactLastName + " - " + result3.ClientName;


                var db1 = new UsersDataContext();
                //The following line is creating a message with a null status on purpose. Due to the actionGUID being used in the emails following. Note also this is S1_Users instead of S1_Messages
                var results1 = db1.S1_Users_CreateMessageWithAction(1, subject, result3.UserID, 1, 0, 3, HttpUtility.UrlDecode(ReturnURL), System.DateTime.Now, null).SingleOrDefault();

                if (results1.ActionGUID != null)
                {


                    Dictionary<string, string> messagevalues = new Dictionary<string, string>();
                    messagevalues.Add("[[USER_EMAIL]]", result3.Email);
                    messagevalues.Add("[[USERNAME]]", result3.UserName);
                    messagevalues.Add("[[COMPANYNAME]]", result3.ClientName);
                    messagevalues.Add("[[PASSWORD]]", contactpassword);
                    messagevalues.Add("[[GUIDURL]]", System.Configuration.ConfigurationManager.AppSettings["DefaultPath"] + "/Account/ConfirmEmail/" + results1.ActionGUID.ToString() + "?portal=client");
                    messagevalues.Add("[[CORPORATENAME]]", System.Configuration.ConfigurationManager.AppSettings["CompanyName"]);

                    MailGun.SendEmailToUserFromTemplate(10, 0, "Create Client Account", 0, result3.UserID, 0, subject, messagevalues);

                    subject = ConfigurationManager.AppSettings["CompanyName"] + " Billing: " + result3.ContactFirstName + " " + result3.ContactLastName + " - " + result3.ClientName;

                    MailGun.SendEmailToUserFromTemplate(11, 0, "Create Client Password", 0, result3.UserID, 0, subject, messagevalues);

                    return new JsonResult { Data = new { success = true, error = "Password has been resent and emailed to the user." } };

                    /* var messageRecord = Messages.GetMessageTemplateRecord(0, "Create Client Account", messagevalues);

                     string messagebody = messageRecord != null ? messageRecord.MessageText : null;

                     if (messagebody != null)
                     {
                         int messageActionType = messageRecord.MessageActionTypeID.GetValueOrDefault();
                         int? MessageIDOutput = new int?();
                         Guid? MessageActionGuidOutput = new Guid?();

                         //Send email with UserName
                         Messages.CreateMessageWithAction(messageActionType, subject, messagebody, result3.UserID, 1, 0, 3, HttpUtility.UrlDecode(ReturnURL), System.DateTime.Now, null, "HTML", ref MessageIDOutput, ref MessageActionGuidOutput);
                         Messages.UpdateMessageAndMarkForSending(MessageIDOutput.Value, subject, messagebody);

                         subject = ConfigurationManager.AppSettings["CompanyName"] + " Billing: " + result3.ContactFirstName + " " + result3.ContactLastName + " - " + result3.ClientName;

                         messageRecord = Messages.GetMessageTemplateRecord(0, "Create Client Password", messagevalues);

                         messagebody = messageRecord != null ? messageRecord.MessageText : null;

                         if (messagebody != null)
                         {
                             messageActionType = messageRecord.MessageActionTypeID.GetValueOrDefault();
                             MessageIDOutput = new int?();
                             MessageActionGuidOutput = new Guid?();

                             //Send email with Password
                             Messages.CreateMessageWithAction(messageActionType, subject, messagebody, result3.UserID, 1, 0, 3, HttpUtility.UrlDecode(ReturnURL), System.DateTime.Now, null, "HTML", ref MessageIDOutput, ref MessageActionGuidOutput);
                             Messages.UpdateMessageAndMarkForSending(MessageIDOutput.Value, subject, messagebody);
                         }

                         return new JsonResult { Data = new { success = true, error = "Password has been resent and emailed to the user." } };

                     }
                     else
                     {
                         return new JsonResult { Data = new { success = false, error = "Unable to reset the password at this time. Please retry." } };

                     }*/
                }
                else
                {

                    return new JsonResult { Data = new { success = false, error = "Unable to reset the password at this time. Please retry." } };
                }
            }
            return new JsonResult { Data = new { success = false, error = "Unable to reset the password at this time. Please retry." } };
        }
              
                

        // Main View load Fill Client Dropdown at top of page
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult GetClientSelectList(int id) //id = Current UserID
        {

            Security_Users viewSecuritySetup = new Security_Users();

            List<SelectListItem> clientselectlist = Clients.GetClientListForDropdown();

            var rows = clientselectlist.ToArray();

            return new JsonResult { Data = new { rows = rows } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs("GET")]
        public ActionResult CreateClientUser(Security_Users viewSecuritySetup)
        {
            viewSecuritySetup.securitycompanieslist2 = Clients.GetClientListForDropdown();

            SelectListItem item1 = new SelectListItem();
            item1.Text = "Client User";
            item1.Value = "Client";
            viewSecuritySetup.usertypelist.Add(item1);

            return View("CreateClientUser", viewSecuritySetup);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [ActionName("CreateClientUser")]
        [AcceptVerbs("POST")]
        public JsonResult CreateClientUserPost(Security_Users viewSecuritySetup, FormCollection fc)
        {

            int newuserclientid = Convert.ToInt32(fc["primarycompany"]);
            string newuserrole = fc["usertypelist"];

            // Basic parameter validation
            if (String.IsNullOrEmpty(viewSecuritySetup.firstname))
            {
                ViewData.ModelState.AddModelError("firstname", " ");
                ViewData.ModelState.AddModelError("*", "Please enter a firstname.");
            }

            if (String.IsNullOrEmpty(viewSecuritySetup.lastname))
            {
                ViewData.ModelState.AddModelError("lastname", " ");
                ViewData.ModelState.AddModelError("*", "Please enter a lastname.");
            }

            if (String.IsNullOrEmpty(viewSecuritySetup.username))
            {
                ViewData.ModelState.AddModelError("username", " ");
                ViewData.ModelState.AddModelError("*", "Please enter a username.");
            }

            if (String.IsNullOrEmpty(viewSecuritySetup.email))
            {
                ViewData.ModelState.AddModelError("email", " ");
                ViewData.ModelState.AddModelError("*", "Please enter an email address.");
            }
            else
            {

                Regex emailregex = new Regex(@"^[\w-\.]+@([\w-]+\.)+[\w-]{2,7}$");

                Match m = emailregex.Match(viewSecuritySetup.email);
                if (m.Success == false)
                {
                    ViewData.ModelState.AddModelError("email", " ");
                    ViewData.ModelState.AddModelError("*", "Invalid email format.");
                }

            }

            if (viewSecuritySetup.password == null || viewSecuritySetup.password.Length < Provider.MinRequiredPasswordLength)
            {
                ViewData.ModelState.AddModelError("password", " ");
                ViewData.ModelState.AddModelError("*", String.Format(CultureInfo.InvariantCulture,
                         "A password of {0} or more characters is required.",
                          Provider.MinRequiredPasswordLength));
            }

            if (!String.Equals(viewSecuritySetup.password, viewSecuritySetup.confirmPassword, StringComparison.Ordinal))
            {
                ViewData.ModelState.AddModelError("confirmPassword", " ");
                ViewData.ModelState.AddModelError("*", "The password and confirmation do not match.");
            }

            if (ViewData.ModelState.IsValid)
            {

                string subject = ConfigurationManager.AppSettings["CompanyName"] + " Billing: New Account";
                string clientname = null;
                string clientaddr1 = null;
                string clientaddr2 = null;
                string clientcity = null;
                string clientstate = null;
                string clientzipcode = null;

                // Attempt to register the user
                MembershipCreateStatus createStatus;
                MembershipUser newUser = Provider.CreateUser(viewSecuritySetup.username, viewSecuritySetup.password, viewSecuritySetup.email,
                    "client", "client", true, null, out createStatus);

                if (newUser != null)
                {
                    var db = new UsersDataContext();
                    var result = db.S1_Users_CreateUser(viewSecuritySetup.username, newuserclientid, 1, viewSecuritySetup.firstname, viewSecuritySetup.lastname).SingleOrDefault();
                    if (result.UserID > 0)
                    {
                        Roles.AddUserToRole(viewSecuritySetup.username, newuserrole);

                        if (String.IsNullOrEmpty(HttpUtility.UrlDecode(viewSecuritySetup.ReturnUrl)))
                        {
                            viewSecuritySetup.ReturnUrl = "/Account/Logon?portal=admin";
                        }

                        var db1 = new UsersDataContext();
                        //The following line is creating a message with a null status on purpose. Due to the actionGUID being used in the emails following. Note also this is S1_Users instead of S1_Messages
                        var results1 = db.S1_Users_CreateMessageWithAction(1, subject, result.UserID, 1, 0, 3, HttpUtility.UrlDecode(viewSecuritySetup.ReturnUrl), System.DateTime.Now, null).SingleOrDefault();

                        if (results1.ActionGUID != null)
                        {
                            string ReturnURL = "/Account/ConfirmEmail";

                            var db3 = new ClientsDataContext();
                            var result3 = db3.S1_Clients_GetClientsFromUser(result.UserID).SingleOrDefault();

                            if (result3 == null)
                            {

                                //todo;
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

                            Provider.ChangePasswordQuestionAndAnswer(viewSecuritySetup.username, viewSecuritySetup.password, "What is your Company's zipcode?", clientzipcode);

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
                            messagevalues.Add("[[USER_EMAIL]]", viewSecuritySetup.email);
                            messagevalues.Add("[[USER_PHONE]]", "");
                            messagevalues.Add("[[USERNAME]]", viewSecuritySetup.username);
                            messagevalues.Add("[[COMPANYNAME]]", clientname);
                            messagevalues.Add("[[GUIDURL]]", System.Configuration.ConfigurationManager.AppSettings["DefaultPath"] + ReturnURL + "/" + results1.ActionGUID.ToString() + "?portal=client");
                            messagevalues.Add("[[CORPORATENAME]]", System.Configuration.ConfigurationManager.AppSettings["CompanyName"]);

                            MailGun.SendEmailToUserFromTemplate(10, 0, "Create Client Account", 0, result.UserID.Value, 0, subject, messagevalues);

                            return new JsonResult { Data = new { success = true } };

                            /*var messageRecord = Messages.GetMessageTemplateRecord(0, "Create Client Account", messagevalues);

                            string messagebody = messageRecord != null ? messageRecord.MessageText : null;

                            if (messagebody != null)
                            {
                                int messageActionType = messageRecord.MessageActionTypeID.GetValueOrDefault();
                                int? MessageIDOutput = new int?();
                                Guid? MessageActionGuidOutput = new Guid?();

                                Messages.CreateMessageWithAction(messageActionType, subject, messagebody, result.UserID, 1, 0, 3, HttpUtility.UrlDecode(ReturnURL), System.DateTime.Now, null, "HTML", ref MessageIDOutput, ref MessageActionGuidOutput);
                                Messages.UpdateMessageAndMarkForSending(MessageIDOutput.Value, subject, messagebody);
                                
                                return new JsonResult { Data = new { success = true } };
                            }
                            else
                            {
                                ModelState.AddModelError("*", "There was a problem sending the confirmation email.  Please re-create a new account.  We apologize for the inconvenience.");
                                HandleCreateClientUserErrors(viewSecuritySetup, fc);
                                return new JsonResult
                                {
                                    Data = new
                                    {
                                        success = false,
                                        view = RenderToString.RenderViewToString(this, "CreateClientUser", viewSecuritySetup)
                                    }
                                };
                            }*/
                        }

                        ModelState.AddModelError("*", "There was a problem sending the confirmation email.  Please re-create a new account.  We apologize for the inconvenience.");
                        HandleCreateClientUserErrors(viewSecuritySetup, fc);
                        return new JsonResult
                        {
                            Data = new
                            {
                                success = false,
                                view = RenderToString.RenderViewToString(this, "CreateClientUser", viewSecuritySetup)
                            }
                        };
                    }
                    else
                    {
                        ModelState.AddModelError("*", ErrorHandler.ErrorCodeToString(createStatus));
                        HandleCreateClientUserErrors(viewSecuritySetup, fc);
                        return new JsonResult
                        {
                            Data = new
                            {
                                success = false,
                                view = RenderToString.RenderViewToString(this, "CreateClientUser", viewSecuritySetup)
                            }
                        };
                    }
                }
                else
                {
                    ViewData.ModelState.AddModelError("*", ErrorHandler.ErrorCodeToString(createStatus));
                    HandleCreateClientUserErrors(viewSecuritySetup, fc);
                    return new JsonResult
                    {
                        Data = new
                        {
                            success = false,
                            view = RenderToString.RenderViewToString(this, "CreateClientUser", viewSecuritySetup)
                        }
                    };

                }
            }
            return new JsonResult
            {
                Data = new
                {
                    success = false,
                    view = RenderToString.RenderViewToString(this, "CreateClientUser", viewSecuritySetup)
                }
            };
            //return new JsonResult { Data = new { success = true } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs("GET")]
        public ActionResult AddUserToClient(Security_Users viewSecuritySetup)
        {
            viewSecuritySetup.securitycompanieslist = Clients.GetClientListForDropdown();
            viewSecuritySetup.adduserlist = DomainModels.Security.GetAllUsers("Active");

            return View("AddUserToClient", viewSecuritySetup);
        }


        [ScreeningONEAuthorize(Portal = "Client", Roles = "Client_Billing, Client")]
        [AcceptVerbs("GET")]
        public ActionResult ChangePassword()
        {
            Security_Users viewSecurity_Users = new Security_Users();

            var user = Provider.GetUser(HttpContext.User.Identity.Name, HttpContext.User.Identity.IsAuthenticated);

            viewSecurity_Users.username = user.UserName;

            return View(viewSecurity_Users);
        }

        [ScreeningONEAuthorize(Portal = "Client", Roles = "Client_Billing, Client")]
        [AcceptVerbs("POST")]
        public ActionResult ChangePassword(string UserName, string currentPassword, string newPassword, string confirmPassword, string newSecurityQuestion, string newSecurityAnswer)
        {

            Security_Users viewSecurity_Users = new Security_Users();

            viewSecurity_Users.username = UserName;

            // Basic parameter validation
            if (String.IsNullOrEmpty(currentPassword))
            {
                ViewData.ModelState.AddModelError("currentPassword", "You must specify a current password.");
            }
            if (newPassword == null || newPassword.Length < Provider.MinRequiredPasswordLength)
            {
                ViewData.ModelState.AddModelError("newPassword", String.Format(CultureInfo.InvariantCulture,
                         "You must specify a new password of {0} or more characters.",
                         Provider.MinRequiredPasswordLength));
            }
            if (!String.Equals(newPassword, confirmPassword, StringComparison.Ordinal))
            {
                ViewData.ModelState.AddModelError("newPassword", "The new password and confirmation password do not match.");
            }

            if (ViewData.ModelState.IsValid)
            {
                // Attempt to change password
                MembershipUser currentUser = Provider.GetUser(User.Identity.Name, true /* userIsOnline */);
                bool changeSuccessful = false;
                bool changeQuestionSuccessful = false;
                try
                {
                    changeSuccessful = currentUser.ChangePassword(currentPassword, newPassword);
                    changeQuestionSuccessful = currentUser.ChangePasswordQuestionAndAnswer(newPassword, newSecurityQuestion, newSecurityAnswer);
                }
                catch
                {
                    // An exception is thrown if the new password does not meet the provider's requirements
                }

                if (changeSuccessful)
                {
                    if (changeQuestionSuccessful)
                    {
                        return RedirectToAction("ChangePasswordSuccess", "Security");

                    }
                    else
                    {
                        ViewData.ModelState.AddModelError("newSecurityQuestion", "The new security question/answer combination was not accepted. Please try again.");
                    }
                }
                else
                {
                    ViewData.ModelState.AddModelError("password", "The current password is incorrect or the new password is invalid.");
                }
            }

            // If we got this far, something failed, redisplay form

            return View(viewSecurity_Users);
        }

        [ScreeningONEAuthorize(Portal = "Client", Roles = "Client_Billing, Client")]
        public ActionResult ChangePasswordSuccess(string portal, string ClientID)
        {
            ViewData["ReturnUrl"] = "/BillingStatement/Home";
            return View();
        }



        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult HandleCreateClientUserErrors(Security_Users viewSecuritySetup, FormCollection fc)
        {
            viewSecuritySetup.securitycompanieslist2 = Clients.GetClientListFromUser(SecurityExtension.GetCurrentUserID(this));
            viewSecuritySetup.securitycompanieslist2.Find(
                    delegate(SelectListItem tempitem)
                    {
                        return tempitem.Value == fc["primarycompany"];
                    }
                    ).Selected = true;


            SelectListItem item1 = new SelectListItem();
            item1.Text = "Client User";
            item1.Value = "Client";
            viewSecuritySetup.usertypelist.Add(item1);

            SelectListItem item2 = new SelectListItem();
            item2.Text = "Sales User";
            item2.Value = "Sales";
            viewSecuritySetup.usertypelist.Add(item2);


            viewSecuritySetup.usertypelist.Find(
                delegate(SelectListItem tempitem)
                {
                    return tempitem.Value == fc["usertypelist"];
                }
                ).Selected = true;

            return new JsonResult
            {
                Data = new
                {
                    success = false,
                    view = RenderToString.RenderViewToString(this, "CreateClientUser", viewSecuritySetup)
                }
            };
        }


    }
}
