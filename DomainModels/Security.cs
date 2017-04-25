using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ScreeningONE.Models;
using ScreeningONE.Models.Users;

namespace ScreeningONE.DomainModels
{
    public class Security
    {

        public static CustomUserInfo GetUserInfoCustomSP(string username)
        {
            CustomUserInfo result = new CustomUserInfo();
            using (UsersDataContext dc = new UsersDataContext())
            {
                var dbresult = dc.aspnet_GetUserInfoCustomSP(username);
                if (dbresult.Count() > 0)
                {
                    dbresult = dc.aspnet_GetUserInfoCustomSP(username);
                    var record = dbresult.SingleOrDefault();
                    result.IsApproved = record.IsApproved;
                    result.IsLockedOut = record.IsLockedOut;
                    result.InvalidUserName = false;
                }
                else {
                    result.InvalidUserName = true;
                }
            }
            return result;
        }

        public static CustomUserInfoForFP GetUserInfoForFPCustomSP(string username)
        {
            CustomUserInfoForFP result = new CustomUserInfoForFP();
            using (UsersDataContext dc = new UsersDataContext())
            {
                var dbresult = dc.aspnet_GetUserInfoForFPCustomSP(username).FirstOrDefault();
                if (dbresult != null)
                {
                    result.Email = dbresult.Email;
                    result.UserId = dbresult.UserId;
                    result.HasRecord = true;
                }
                else
                {
                    result.HasRecord = false;
                }
            }
            return result;
        }

        public static S1_Users_GetUserFromUserIDResult GetUserFromUserID(int userid)
        {
            using (UsersDataContext dc = new UsersDataContext())
            {
                return dc.S1_Users_GetUserFromUserID(userid).FirstOrDefault();
               
            }
        }

        public static List<SelectListItem> GetAllUsers(string userstatus) //valid values are Active, Inactive and All
        {
            List<SelectListItem> userlist = new List<SelectListItem>();

            var dc = new UsersDataContext();
            var result = dc.S1_Users_GetAllUsers(userstatus);
            foreach (var item in result)
            {
                if (item.UserID != null)
                {
                    SelectListItem listitem = new SelectListItem();
                    listitem.Value = item.UserID.ToString();
                    listitem.Text = item.ShortName;
                    userlist.Add(listitem);
                }
            }

            return userlist;
        }

        public static List<UserClientContact> GetUserClientContacts(int _UserID)
        {
            List<UserClientContact> clientContacts = new List<UserClientContact>();
            UsersDataContext dc = new UsersDataContext();
            var result = dc.S1_Users_ClientContactsFromUserID(_UserID);

            foreach (var item in result)
            {
                UserClientContact tempClientContact = new UserClientContact(item.ClientContactID, item.ClientContactName, item.ClientContactFirstName, item.ClientContactLastName,
                    item.ClientContactTitle, item.ClientContactAddress1, item.ClientContactAddress2, item.ClientContactCity, item.ClientContactStateCode,
                    item.ClientContactZIP, item.ClientContactBusinessPhone, item.ClientContactCellPhone, item.ClientContactFax, item.ClientContactEmail,
                    item.BillingContactName, item.IsPrimaryBillingContact1, item.OnlyShowInvoices, Convert.ToInt32(item.ClientID), Convert.ToInt32(item.UserID),
                    item.BillingDeliveryMethod, Convert.ToBoolean(item.IsBillingContact), item.LastLoginDate, item.BillAsClientName, item.DueText,
                    item.BillingContactAddress1, item.BillingContactAddress2, item.BillingContactCity, item.BillingContactStateCode, item.BillingContactZIP,
                    item.BillingContactEmail, item.BillingContactBusinessPhone, item.BillingContactFax, item.BillingContactPOName, item.BillingContactPONumber,
                    item.BillingContactNotes, Convert.ToBoolean(item.ClientContactStatus), Convert.ToBoolean(item.BillingContactStatus), item.BillingContactID, item.ClientName);
                clientContacts.Add(tempClientContact);
            }

            return clientContacts;
        }

        //Returns true if the user can access the selected invoice
        public static bool UserCanAccessInvoice(int _UserID, int _InvoiceID)
        {
            UsersDataContext dc = new UsersDataContext();
            var result = dc.S1_Users_Security_CanAccessInvoice(_UserID, _InvoiceID);

            if (result != null && result.Count() > 0)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        //Returns true if the user can access the selected billing contact
        public static bool UserCanAccessBillingContact(int _UserID, int _BillingContactID)
        {
            UsersDataContext dc = new UsersDataContext();
            var result = dc.S1_Users_Security_CanAccessBillingContact(_UserID, _BillingContactID);

            if (result != null && result.Count() > 0)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public class UserClientContact
        {
            public int ClientContactID;
            public string ClientContactName;
            public string ClientContactFirstName;
            public string ClientContactLastName;
            public string ClientContactTitle;
            public string ClientContactAddress1;
            public string ClientContactAddress2;
            public string ClientContactCity;
            public string ClientContactStateCode;
            public string ClientContactZIP;
            public string ClientContactBusinessPhone;
            public string ClientContactCellPhone;
            public string ClientContactFax;
            public string ClientContactEmail;
            public string BillingContactName;
            public bool IsPrimaryBillingContact;
            public bool OnlyShowInvoices;
            public int ClientID;
            public int UserID;
            public string DeliveryMethod;
            public bool IsBillingContact;
            public string LastLoginDate;
            public string BillAsClientName;
            public string DueText;
            public string BillingContactAddress1;
            public string BillingContactAddress2;
            public string BillingContactCity;
            public string BillingContactStateCode;
            public string BillingContactZIP;
            public string BillingContactEmail;
            public string BillingContactBusinessPhone;
            public string BillingContactFax;
            public string BillingContactPOName;
            public string BillingContactPONumber;
            public string BillingContactNotes;
            public bool ClientContactStatus;
            public bool BillingContactStatus;
            public int BillingContactID;
            public string ClientName; 

            public UserClientContact() { ClientContactID = 0; }

            public UserClientContact(int _ClientContactID, string _ClientContactName, string _ClientContactFirstName, string _ClientContactLastName, string _ClientContactTitle, string _ClientContactAddress1,
                string _ClientContactAddress2, string _ClientContactCity, string _ClientContactStateCode, string _ClientContactZIP,
                string _ClientContactBusinessPhone, string _ClientContactCellPhone, string _ClientContactFax, string _ClientContactEmail,
                string _BillingContactName, bool _IsPrimaryBillingContact, bool _OnlyShowInvoices, int _ClientID, int _UserID,
                string _DeliveryMethod, bool _IsBillingContact, string _LastLoginDate, string _BillAsClientName, string _DueText,
                string _BillingContactAddress1, string _BillingContactAddress2, string _BillingContactCity, string _BillingContactStateCode,
                string _BillingContactZIP, string _BillingContactEmail, string _BillingContactBusinessPhone, string _BillingContactFax,
                string _BillingContactPOName, string _BillingContactPONumber, string _BillingContactNotes, bool _ClientContactStatus, bool _BillingContactStatus, int _BillingContactID, string _ClientName)
            {
                ClientContactID = _ClientContactID;
                ClientContactName = (String.IsNullOrEmpty(_ClientContactName) ? "" : _ClientContactName);
                ClientContactFirstName = (String.IsNullOrEmpty(_ClientContactFirstName) ? "" : _ClientContactFirstName);
                ClientContactLastName = (String.IsNullOrEmpty(_ClientContactLastName) ? "" : _ClientContactLastName);
                ClientContactTitle = (String.IsNullOrEmpty(_ClientContactTitle) ? "" : _ClientContactTitle);
                ClientContactAddress1 = (String.IsNullOrEmpty(_ClientContactAddress1) ? "" : _ClientContactAddress1);
                ClientContactAddress2 = (String.IsNullOrEmpty(_ClientContactAddress2) ? "" : _ClientContactAddress2);
                ClientContactCity = (String.IsNullOrEmpty(_ClientContactCity) ? "" : _ClientContactCity);
                ClientContactStateCode = (String.IsNullOrEmpty(_ClientContactStateCode) ? "" : _ClientContactStateCode);
                ClientContactZIP = (String.IsNullOrEmpty(_ClientContactZIP) ? "" : _ClientContactZIP);
                ClientContactBusinessPhone = (String.IsNullOrEmpty(_ClientContactBusinessPhone) ? "" : _ClientContactBusinessPhone);
                ClientContactCellPhone = (String.IsNullOrEmpty(_ClientContactCellPhone) ? "" : _ClientContactCellPhone);
                ClientContactFax = (String.IsNullOrEmpty(_ClientContactFax) ? "" : _ClientContactFax);
                ClientContactEmail = (String.IsNullOrEmpty(_ClientContactEmail) ? "" : _ClientContactEmail);
                BillingContactName = (String.IsNullOrEmpty(_BillingContactName) ? "" : _BillingContactName);
                IsPrimaryBillingContact = _IsPrimaryBillingContact;
                OnlyShowInvoices = _OnlyShowInvoices;
                ClientID = _ClientID;
                UserID = _UserID;
                DeliveryMethod = (String.IsNullOrEmpty(_DeliveryMethod) ? "" : _DeliveryMethod);
                IsBillingContact = _IsBillingContact;
                LastLoginDate = (String.IsNullOrEmpty(_LastLoginDate) ? "" : _LastLoginDate);
                BillAsClientName = (String.IsNullOrEmpty(_BillAsClientName) ? "" : _BillAsClientName);
                DueText = (String.IsNullOrEmpty(_DueText) ? "" : _DueText);
                BillingContactAddress1 = (String.IsNullOrEmpty(_BillingContactAddress1) ? "" : _BillingContactAddress1);
                BillingContactAddress2 = (String.IsNullOrEmpty(_BillingContactAddress2) ? "" : _BillingContactAddress2);
                BillingContactCity = (String.IsNullOrEmpty(_BillingContactCity) ? "" : _BillingContactCity);
                BillingContactStateCode = (String.IsNullOrEmpty(_BillingContactStateCode) ? "" : _BillingContactStateCode);
                BillingContactZIP = (String.IsNullOrEmpty(_BillingContactZIP) ? "" : _BillingContactZIP);
                BillingContactEmail = (String.IsNullOrEmpty(_BillingContactEmail) ? "" : _BillingContactEmail);
                BillingContactBusinessPhone = (String.IsNullOrEmpty(_BillingContactBusinessPhone) ? "" : _BillingContactBusinessPhone);
                BillingContactFax = (String.IsNullOrEmpty(_BillingContactFax) ? "" : _BillingContactFax);
                BillingContactPOName = (String.IsNullOrEmpty(_BillingContactPOName) ? "" : _BillingContactPOName);
                BillingContactPONumber = (String.IsNullOrEmpty(_BillingContactPONumber) ? "" : _BillingContactPONumber);
                BillingContactNotes = (String.IsNullOrEmpty(_BillingContactNotes) ? "" : _BillingContactNotes);
                ClientContactStatus = _ClientContactStatus;
                BillingContactStatus = _BillingContactStatus;
                BillingContactID = _BillingContactID;
                ClientName = _ClientName;
            }
        }

    }
}
