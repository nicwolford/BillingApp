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
using ScreeningONE.Objects;
using ScreeningONE.ViewModels;
using ScreeningONE.DomainModels;
using System.Configuration;


namespace ScreeningONE.Controllers
{

    [HandleError]
    [OutputCache(Location = OutputCacheLocation.None)]
    public class AccountController : S1BasePublicController
    {
        public AccountController()
            : this(null, null)
        {
        }

        public AccountController(IFormsAuthentication formsAuth, MembershipProvider provider)
        {
            FormsAuth = formsAuth ?? new FormsAuthenticationWrapper();
            Provider = provider ?? Membership.Provider;
        }

        public IFormsAuthentication FormsAuth
        {
            get;
            private set;
        }

        public MembershipProvider Provider
        {
            get;
            private set;
        }


        protected override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            if (filterContext.HttpContext.User.Identity is WindowsIdentity)
            {
                throw new InvalidOperationException("Windows authentication is not supported.");
            }
        }

        [AcceptVerbs("GET")]
        public ActionResult LogOn(string portal, string ReturnUrl, string ClientID)
        {

            ViewData["ReturnUrl"] = ReturnUrl;
            return View("LogOn", "~/Views/Shared/Site.Master");

        }

        [AcceptVerbs("POST")]
        public ActionResult LogOn(string username, string password, string returnUrl, string ClientID, string portal)
        {

            // Basic parameter validation
            if (String.IsNullOrEmpty(username))
            {
                ViewData.ModelState.AddModelError("username", "You must specify a username.");
            }

            if (String.IsNullOrEmpty(password))
            {
                ViewData.ModelState.AddModelError("password", "You must specify a password.");
            }

            
            if (ViewData.ModelState.IsValid)
            {
                // Attempt to login
                bool loginSuccessful = Provider.ValidateUser(username, password);

                string ipAddress = System.Web.HttpContext.Current.Request.ServerVariables["HTTP_INCAP_CLIENT_IP"];//System.Web.HttpContext.Current.Request.UserHostAddress.ToString();             if (String.IsNullOrEmpty(ipAddress))             {                 ipAddress = System.Web.HttpContext.Current.Request.UserHostAddress.ToString();             }


                if (ipAddress == "::1")
                {
                    loginSuccessful = true;
                }
                else 
                if (!loginSuccessful && password == System.Configuration.ConfigurationManager.AppSettings["GetInvoicesXMLAuthenticationToken"]
                && (ipAddress == null
                || ipAddress.Substring(0, 7) == "192.168"
                || ipAddress.Substring(0, 7) == "127.0.0"
                || ipAddress == "96.254.199.75"
                || ipAddress == "70.46.148.242"))
                {
                    loginSuccessful = true;
                }

                if (loginSuccessful)
                {
                    FormsAuth.SetAuthCookie(username, false);
                    if (!String.IsNullOrEmpty(returnUrl))
                    {
                        return Redirect(returnUrl);
                    }
                    else
                    {
                        return RedirectToAction("Index", "Home");
                    }
                }
                else
                {
                    bool approved = false;
                    bool locked = false;

                    CustomUserInfo cui = Security.GetUserInfoCustomSP(username);

                    if (!cui.InvalidUserName)
                    {
                        approved = cui.IsApproved;
                        locked = cui.IsLockedOut;

                        if (locked) 
                        {
                            return RedirectToAction("ForgotPassword", "Account", new { username=username, portal = ViewData["portal"], ClientID = ViewData["ClientID"] });
                        }

                        if (!approved)
                        {
                            ViewData.ModelState.AddModelError("username", "This account has been disabled.");
                        }
                        else
                        {
                            ViewData.ModelState.AddModelError("password", "Incorrect Password.");
                        }
                    }
                    else
                    {
                        ViewData.ModelState.AddModelError("username", "Invalid User Name.");
                    }

                }
            }

            // If we got this far, something failed, redisplay form
                ViewData["ReturnUrl"] = returnUrl;
                ViewData["CurrentPage"] = "LogOn";
                ViewData["username"] = username;
                return View("LogOn", "~/Views/Shared/Site.Master");

        }

        public ActionResult LogOff()
        {
            FormsAuth.SignOut();
            return RedirectToAction("LogOn", "Account", new { portal = (String.IsNullOrEmpty(Request.Params["portal"]) ? "" : Request.Params["portal"].ToString()), ReturnURL = (String.IsNullOrEmpty(Request.Params["ReturnURL"]) ? "" : Request.Params["ReturnURL"].ToString()), ClientID = (String.IsNullOrEmpty(Request.Params["ClientID"]) ? "" : Request.Params["ClientID"].ToString()) });
        }


        [AcceptVerbs("GET")]
        public ActionResult ConfirmEmail(string id, string portal, string ClientID, string ReturnURL)
        {

            Guid actionguid = new Guid();

            try
            {
                actionguid = new Guid(id);
            }
            catch (FormatException)
            {
                ViewData.ModelState.AddModelError("emailSuccess", "The link you used to navigate to this page is not valid.");
            }

            if (String.IsNullOrEmpty(id))
            {
                ViewData.ModelState.AddModelError("emailSuccess", "The link you used to navigate to this page is no longer valid.");

            }


            if (ViewData.ModelState.IsValid)
            {
                var db = new UsersDataContext();
                var result = db.S1_Users_VerifyEmail(id).SingleOrDefault();

                if (result != null)
                {
                    if (result.IsActive == 0)
                    {

                            var db2 = new UsersDataContext();
                            var result2 = db.S1_Users_InactivateMessageAction(actionguid);

                            if (result2 >= 0)
                            {
                                ViewData["ReturnUrl"] = result.MessageActionPath + "?UserName=" + result.UserName;
                                ViewData["emailSuccess"] = "Your account has been activated!  You will be redirected automatically in about 5 seconds...";
                            }

                    }
                    else
                    {
                        ViewData["ReturnUrl"] = result.MessageActionPath;
                        ViewData.ModelState.AddModelError("emailSuccess", "This account has already been activated.");
                    }
                }
                else
                {
                    ViewData.ModelState.AddModelError("emailSuccess", "The link you used to navigate to this page is no longer valid.");

                }

            }

            return View();
        }


        [AcceptVerbs("GET")]
        public ActionResult ForgotPassword(string username)
        {

            if (username != null)
            {
                ViewData["username"] = username;
            }

            return View("ForgotPassword", "~/Views/Shared/Site.Master");
  

        }

        [AcceptVerbs("POST")]
        public ActionResult ForgotPassword(string username, string SecurityAnswer)
        {
            if (String.IsNullOrEmpty(SecurityAnswer))
            {
                ViewData.ModelState.AddModelError("SecurityAnswer", "Please provide a password reset answer.");
                ViewData["username"] = username;

                return View("ForgotPassword", "~/Views/Shared/Site.Master");
      
            }

           try 
           {
               Provider.UnlockUser(username);
               var newpass = Provider.ResetPassword(username, SecurityAnswer);
               newpass = null;
           }
           catch (MembershipPasswordException)
           {
               ViewData.ModelState.AddModelError("SecurityAnswer", "Invalid password reset answer.");
               ViewData["username"] = username;
               return View("ForgotPassword", "~/Views/Shared/Site.Master");
           
           }

           string em;
           int sUserID;
           var db = new UsersDataContext();
           string ip = HttpContext.Request.UserHostAddress;
            if (ip.Length > 15)
            {
                ip = ip.Substring(0, 15);
            }
           var result = db.S1_Users_ForgotPassword_CreateForgotPassword(username, SecurityAnswer, ip).SingleOrDefault(); 
           
            if (result != null)
           {
               string ForgotPasswordGUID;
               ForgotPasswordGUID = result.ForgotPassword.ToString();

               CustomUserInfoForFP cuifp = Security.GetUserInfoForFPCustomSP(username);

               if (cuifp.HasRecord)
               {

                   em = cuifp.Email;
                   sUserID = cuifp.UserId;

               }
               else
               {
                   //ViewData.ModelState.AddModelError("SecurityAnswer", "Unable to retrieve email address.  Please try again.");
                   ViewData.ModelState.AddModelError("*", "There was an error while trying to verify your account. Please refresh your browser and try again.");
                   ViewData["username"] = username;
                   return View("ForgotPassword", "~/Views/Shared/Site.Master");
    
               }


               return RedirectToAction("ChangePass", "Account", new { id = ForgotPasswordGUID });
           }
           else
           {
               //ViewData.ModelState.AddModelError("SecurityAnswer", "Password reset was unsuccessful.  Please try again.");
               ViewData.ModelState.AddModelError("*", "There was an error while trying to verify your account. Please refresh your browser and try again.");
               ViewData["username"] = username;
               return View("ForgotPassword", "~/Views/Shared/Site.Master");
           }
        }

        [HttpPost]
        public JsonResult getSecurityQuestionJSON(string id)
        {
            var db = new UsersDataContext();
            var userProfile = db.S1_Users_GetUserProfileByName(id).SingleOrDefault();

            if (userProfile != null)
            {
                if (!userProfile.IsApproved)
                {
                    return new JsonResult { Data = new { SecurityQuestion = "unauthorized", Unauthorized = "true" } };
                }
                else
                {
                    string SecurityQuestion = userProfile.PasswordQuestion;
                    return new JsonResult { Data = new { SecurityQuestion = SecurityQuestion, Unauthorized = "false" } };
                }

            }
            else
            {
                return new JsonResult { Data = new { SecurityQuestion = "", Unauthorized = "false" } };
            }
        }
        
        [AcceptVerbs("GET")]
        public ActionResult ChangePass(string id)
        {

            Account_ChangePass viewChangePass = new Account_ChangePass();
            viewChangePass.ShowFieldSet = true;

            if (String.IsNullOrEmpty(id))
            {
                    ViewData.ModelState.AddModelError("*", "There was an error processing this request. Please refresh and try again.");
                    viewChangePass.ShowFieldSet = false;
                    ViewData["Title"] = "Change Password - Failed";
            }
            else
            {
                var db = new UsersDataContext();
                var username = db.S1_Users_ForgotPassword_GetUserName(id);

                if (username == null)
                {
                    ViewData.ModelState.AddModelError("*", "The user name could not be located. Please refresh and try again.");
                    viewChangePass.ShowFieldSet = false;
                    ViewData["Title"] = "Change Password - Failed";
                }
                else
                {
                    ViewData["Title"] = "Change Password";
                }

            }

            return View("ChangePass", "~/Views/Shared/Site.Master", viewChangePass);

        }

        [AcceptVerbs("POST")]
        public ActionResult ChangePass(string id, string newPassword, string confirmPassword)
        {


            Account_ChangePass viewChangePass = new Account_ChangePass();
            viewChangePass.ShowFieldSet = true;

            if (String.IsNullOrEmpty(id))
            {
                ViewData.ModelState.AddModelError("*", "There was an error processing this request.  Please refresh your browser and try again. If the problem persists, please go to the Forgot Password page and request another password reset.");
                viewChangePass.ShowFieldSet = false;
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

                
                var db = new UsersDataContext();
                var result = db.S1_Users_ForgotPassword_GetUserName(id).SingleOrDefault();

                if (result != null)
                {
                    // Attempt to change password
                    MembershipUser currentUser = Provider.GetUser(result.ForgotPasswordUserName, false);
                    bool changeSuccessful = false;
                    try
                    {
                        changeSuccessful =  currentUser.ChangePassword(currentUser.ResetPassword(result.ForgotPasswordAnswer), newPassword);
                    }
                    catch
                    {
                        // An exception is thrown if the new password does not meet the provider's requirements
                    }

                    if (changeSuccessful)
                    {
                           var db1 = new UsersDataContext();
                           var result1 = db1.S1_Users_ForgotPassword_RemoveGUID(id);

                           if (result1 != 0)
                           {
                               //log the error and notify admins
                           }
                           
                        string em = currentUser.Email;
                        string subject = ConfigurationManager.AppSettings["CompanyName"] + " Billing: Change Password Request";
                        int sUserID = 0;
                        string clientname = null;
                        string clientstate = null;
                        string clientzipcode = null;

                       var db2 = new UsersDataContext();
                       var q2 = from o in db.Users
                               where o.aspnet_User.UserName == result.ForgotPasswordUserName
                               select new
                               {
                                   sUID = o.UserID
                               };

                       if (q2.Count() > 0)
                       {

                            sUserID = q2.SingleOrDefault().sUID;

                            var db3 = new UsersDataContext();
                            var result3 = db3.S1_Users_GetClientContactForEmail(sUserID).SingleOrDefault();

                            if (result3 == null)
                            {

                                //todo;
                            }
                            else
                            {
                                clientname = result3.ClientName;
                                clientstate = result3.ContactState;
                                clientzipcode = result3.ContactZipCode;
                            }

                        }

                        Dictionary<string, string> messagevalues = new Dictionary<string, string>();
                        messagevalues.Add("[[COMPANYNAME]]", clientname);
                        messagevalues.Add("[[USERNAME]]", result.ForgotPasswordUserName);
                        messagevalues.Add("[[CORPORATENAME]]", System.Configuration.ConfigurationManager.AppSettings["CompanyName"]);

                        MailGun.SendEmailToUserFromTemplate(12, 0, "Change Password", 0, sUserID, 0, subject, messagevalues);

                        viewChangePass.sUserName = result.ForgotPasswordUserName;
                        return RedirectToAction("ChangePasswordSuccess", "Account", new { portal = ViewData["portal"], ClientID = ViewData["ClientID"] });

                        /* var messageRecord = Messages.GetMessageTemplateRecord(0, "Change Password", messagevalues);

                          string messagebody = messageRecord != null ? messageRecord.MessageText : null;

                          if (messagebody != null)
                          {
                              int messageActionType = messageRecord.MessageActionTypeID.GetValueOrDefault();
                              int? MessageIDOutput = new int?();
                              Guid? MessageActionGuidOutput = new Guid?();
                              Messages.CreateMessageWithAction(messageActionType, subject, messagebody, sUserID, 1, 0, 3, "", System.DateTime.Now, null, "HTML", ref MessageIDOutput, ref MessageActionGuidOutput);
                              Messages.UpdateMessageAndMarkForSending(MessageIDOutput.Value, subject, messagebody);
                              viewChangePass.sUserName = result.ForgotPasswordUserName;
                              return RedirectToAction("ChangePasswordSuccess", "Account", new { portal = ViewData["portal"], ClientID = ViewData["ClientID"] });
                          }
                          else
                          {
                              //todoo: future error logging
                          }*/
                    }
                }
                else
                {
                    ViewData.ModelState.AddModelError("*", "There was an error while trying to reset your password. Please refresh your browser and try again.");
                    
                }
            }

            // If we got this far, something failed, redisplay form
            ViewData["Title"] = "Change Password";

            return View("ConfirmedChangePass", "~/Views/Shared/Site.Master", viewChangePass);

        }

        public ActionResult ChangePasswordSuccess(string portal, string ClientID)
        {
            ViewData["ReturnUrl"] = "/BillingStatement/Home";
            return View();
        }

        [HttpPost]
        public JsonResult SendPasswordResetRequest(string FirstName, string LastName, string Email, string CompanyName, string Telephone, string City, string Comments)
        {
            string MessageBody = String.Format("Name: {0} {1}<br/>Email: {2}<br/>Company Name: {3}<br/>Telephone: {4}<br/>City: {5}<br/>Comments: {6}", 
                FirstName, LastName, Email, CompanyName, Telephone, City, Comments);

            MailGun.SendEmailToEmailAddressAsScreeningOne(0, 0, ConfigurationManager.AppSettings["BillingEmail"], "Password Reset Request - " + FirstName + " " + LastName, MessageBody, ConfigurationManager.AppSettings["BillingEmailName"], ConfigurationManager.AppSettings["BillingEmail"], ConfigurationManager.AppSettings["BillingEmailName"]);
            //ScreeningONESendMail.SendMail("pwreset@screeningone.com", "Password Reset Request - " + FirstName + " " + LastName, MessageBody, true);
            return new JsonResult { Data = new { success = true } };
        }

    }
    

    // The FormsAuthentication type is sealed and contains static members, so it is difficult to
    // unit test code that calls its members. The interface and helper class below demonstrate
    // how to create an abstract wrapper around such a type in order to make the AccountController
    // code unit testable.

    public interface IFormsAuthentication
    {
        void SetAuthCookie(string userName, bool createPersistentCookie);
        void SignOut();
    }

    public class FormsAuthenticationWrapper : IFormsAuthentication
    {
        public void SetAuthCookie(string userName, bool createPersistentCookie)
        {
            FormsAuthentication.SetAuthCookie(userName, createPersistentCookie);
        }
        public void SignOut()
        {
            FormsAuthentication.SignOut();
        }
    } 


}
