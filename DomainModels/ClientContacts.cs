using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.Models;

namespace ScreeningONE.DomainModels
{
    public class ClientContacts
    {
        public static List<ClientContact> GetClientContactsFromClientID(int _ClientID)
        {
            List<ClientContact> clientContacts = new List<ClientContact>();
            ClientContactsDataContext dc = new ClientContactsDataContext();
            var result = dc.S1_ClientContacts_GetClientContactsFromClientID(_ClientID);

            foreach (var item in result)
            {
                ClientContact tempClientContact = new ClientContact(item.ClientContactID, item.ClientContactName, item.ClientContactFirstName, item.ClientContactLastName,
                    item.ClientContactTitle, item.ClientContactAddress1, item.ClientContactAddress2, item.ClientContactCity, item.ClientContactStateCode,
                    item.ClientContactZIP, item.ClientContactBusinessPhone, item.ClientContactCellPhone, item.ClientContactFax, item.ClientContactEmail, 
                    item.BillingContactName, item.IsPrimaryBillingContact, item.OnlyShowInvoices, _ClientID, Convert.ToInt32(item.UserID), 
                    item.BillingDeliveryMethod, Convert.ToBoolean(item.IsBillingContact), item.LastLoginDate, item.BillAsClientName, item.DueText,
                    item.BillingContactAddress1, item.BillingContactAddress2,item.BillingContactCity,item.BillingContactStateCode,item.BillingContactZIP,
                    item.BillingContactEmail,item.BillingContactBusinessPhone, item.BillingContactFax,item.BillingContactPOName,item.BillingContactPONumber,
                    item.BillingContactNotes, Convert.ToBoolean(item.ClientContactStatus), Convert.ToBoolean(item.BillingContactStatus), item.BillingContactID, item.LoginUserName);
                clientContacts.Add(tempClientContact);
            }

            return clientContacts;
        }

        //Return one client contact that matches _Email.  Return an empty ClientContact if the _Email is not found.
        public static ClientContact GetClientContactFromEmail(string _Email)
        {
            if (String.IsNullOrEmpty(_Email))
            {
                return new ClientContact();
            }

            ClientContact clientContacts = new ClientContact();
            ClientContactsDataContext dc = new ClientContactsDataContext();
            var item = dc.S1_ClientContacts_GetClientContactFromEmail(_Email).SingleOrDefault();

            if (item != null)
            {

                clientContacts = new ClientContact(item.ClientContactID, item.ClientContactName, item.ClientContactFirstName, item.ClientContactLastName, 
                    item.ClientContactTitle, item.ClientContactAddress1, item.ClientContactAddress2, item.ClientContactCity, item.ClientContactStateCode,
                    item.ClientContactZIP, item.ClientContactBusinessPhone, item.ClientContactCellPhone, item.ClientContactFax, _Email,
                    item.BillingContactName, item.IsPrimaryBillingContact1, item.OnlyShowInvoices, Convert.ToInt32(item.ClientID),
                    Convert.ToInt32(item.UserID), item.BillingDeliveryMethod, Convert.ToBoolean(item.IsBillingContact), item.LastLoginDate,
                    item.BillAsClientName, item.DueText, item.BillingContactAddress1, item.BillingContactAddress2, item.BillingContactCity, 
                    item.BillingContactStateCode, item.BillingContactZIP, item.BillingContactEmail, item.BillingContactBusinessPhone,
                    item.BillingContactFax, item.BillingContactPOName, item.BillingContactPONumber, item.BillingContactNotes,
                    Convert.ToBoolean(item.ClientContactStatus), Convert.ToBoolean(item.BillingContactStatus), item.BillingContactID, item.LoginUserName);
            }
            else
                clientContacts = new ClientContact();

            return clientContacts;
        }

        //Return one client contact that matches ClientContactID.  Return an empty ClientContact if the not found.
        public static ClientContact GetClientContactFromClientContactID(int ClientContactID)
        {
            if (ClientContactID == 0)
            {
                return new ClientContact();
            }

            ClientContact clientContacts = new ClientContact();
            ClientContactsDataContext dc = new ClientContactsDataContext();
            var item = dc.S1_ClientContacts_GetClientContactFromClientContactID(ClientContactID).SingleOrDefault();

            if (item != null)
            {

                clientContacts = new ClientContact(item.ClientContactID, item.ClientContactName, item.ClientContactFirstName, item.ClientContactLastName,
                    item.ClientContactTitle, item.ClientContactAddress1, item.ClientContactAddress2, item.ClientContactCity, item.ClientContactStateCode,
                    item.ClientContactZIP, item.ClientContactBusinessPhone, item.ClientContactCellPhone, item.ClientContactFax, item.ClientContactEmail,
                    item.BillingContactName, item.IsPrimaryBillingContact1, item.OnlyShowInvoices, Convert.ToInt32(item.ClientID),
                    Convert.ToInt32(item.UserID), item.BillingDeliveryMethod, Convert.ToBoolean(item.IsBillingContact), item.LastLoginDate,
                    item.BillAsClientName, item.DueText, item.BillingContactAddress1, item.BillingContactAddress2, item.BillingContactCity, 
                    item.BillingContactStateCode, item.BillingContactZIP, item.BillingContactEmail, item.BillingContactBusinessPhone, item.BillingContactFax,
                    item.BillingContactPOName, item.BillingContactPONumber, item.BillingContactNotes,
                    Convert.ToBoolean(item.ClientContactStatus), Convert.ToBoolean(item.BillingContactStatus), item.BillingContactID, item.LoginUserName);
            }
            else
                clientContacts = new ClientContact();

            return clientContacts;
        }

        //Return one client contact that matches _UserID.  Return an empty ClientContact if the _UserID is not found.
        public static ClientContact GetClientContactFromUserID(int _UserID)
        {
            ClientContact clientContacts = new ClientContact();
            ClientContactsDataContext dc = new ClientContactsDataContext();
            var item = dc.S1_ClientContacts_GetClientContactFromUserID(_UserID).FirstOrDefault();

            if (item != null)
            {

                clientContacts = new ClientContact(item.ClientContactID, item.ClientContactName, item.ClientContactFirstName, item.ClientContactLastName, 
                    item.ClientContactTitle, item.ClientContactAddress1, item.ClientContactAddress2, item.ClientContactCity, item.ClientContactStateCode,
                    item.ClientContactZIP, item.ClientContactBusinessPhone, item.ClientContactCellPhone, item.ClientContactFax, item.ClientContactEmail,
                    item.BillingContactName, item.IsPrimaryBillingContact1, item.OnlyShowInvoices, Convert.ToInt32(item.ClientID),
                    Convert.ToInt32(item.UserID), item.BillingDeliveryMethod, Convert.ToBoolean(item.IsBillingContact), item.LastLoginDate,
                    item.BillAsClientName, item.DueText, item.BillingContactAddress1, item.BillingContactAddress2, item.BillingContactCity,
                    item.BillingContactStateCode, item.BillingContactZIP, item.BillingContactEmail, item.BillingContactBusinessPhone, item.BillingContactFax,
                    item.BillingContactPOName, item.BillingContactPONumber, item.BillingContactNotes,
                    Convert.ToBoolean(item.ClientContactStatus), Convert.ToBoolean(item.BillingContactStatus), item.BillingContactID, item.LoginUserName);
            }
            else
                clientContacts = new ClientContact();

            return clientContacts;
        }

        //return true if the user has at least one primary contact
        public static bool UserHasPrimaryContact(int _UserID)
        {
            ClientContactsDataContext dc = new ClientContactsDataContext();
            var result = dc.S1_ClientContacts_GetClientContactFromUserID(_UserID);

            if (result != null)
            {
                foreach (var item in result)
                {
                    if (item.IsPrimaryBillingContact1)
                    {
                        return true;
                    }
                }
            }

            return false;
        }

        //Return one client contact that matches _UserID.  Return an empty ClientContact if the _UserID is not found.
        public static ClientContact GetClientContactFromUserName(string _UserName)
        {
            ClientContact clientContacts = new ClientContact();
            ClientContactsDataContext dc = new ClientContactsDataContext();
            var item = dc.S1_ClientContacts_GetClientContactFromUserName(_UserName).SingleOrDefault();

            if (item != null)
            {

                clientContacts = new ClientContact(item.ClientContactID, item.ClientContactName, item.ClientContactFirstName, item.ClientContactLastName,
                    item.ClientContactTitle, item.ClientContactAddress1, item.ClientContactAddress2, item.ClientContactCity, item.ClientContactStateCode,
                    item.ClientContactZIP, item.ClientContactBusinessPhone, item.ClientContactCellPhone, item.ClientContactFax, item.ClientContactEmail,
                    item.BillingContactName, item.IsPrimaryBillingContact1, item.OnlyShowInvoices, Convert.ToInt32(item.ClientID),
                    Convert.ToInt32(item.UserID), item.BillingDeliveryMethod, Convert.ToBoolean(item.IsBillingContact), item.LastLoginDate,
                    item.BillAsClientName, item.DueText, item.BillingContactAddress1, item.BillingContactAddress2, item.BillingContactCity,
                    item.BillingContactStateCode, item.BillingContactZIP, item.BillingContactEmail, item.BillingContactBusinessPhone, item.BillingContactFax,
                    item.BillingContactPOName, item.BillingContactPONumber, item.BillingContactNotes,
                    Convert.ToBoolean(item.ClientContactStatus), Convert.ToBoolean(item.BillingContactStatus), item.BillingContactID,
                    item.LoginUserName);
            }
            else
                clientContacts = new ClientContact();

            return clientContacts;
        }

        //Return one client contact that matches _BillingContactID.  Return an empty ClientContact if the _BillingContactID is not found.
        public static ClientContact GetClientContactFromBillingContactID(int _BillingContactID)
        {
            ClientContact clientContacts = new ClientContact();
            ClientContactsDataContext dc = new ClientContactsDataContext();
            var item = dc.S1_ClientContacts_GetClientContactFromBillingContactID(_BillingContactID).SingleOrDefault();
            
            if (item != null)
            {
                clientContacts = new ClientContact(item.ClientContactID, item.ClientContactName, item.ClientContactFirstName, item.ClientContactLastName, 
                    item.ClientContactTitle, item.ClientContactAddress1, item.ClientContactAddress2, item.ClientContactCity, item.ClientContactStateCode,
                    item.ClientContactZIP, item.ClientContactBusinessPhone, item.ClientContactCellPhone, item.ClientContactFax, item.ClientContactEmail,
                    item.BillingContactName, item.IsPrimaryBillingContact1, item.OnlyShowInvoices, Convert.ToInt32(item.ClientID),
                    Convert.ToInt32(item.UserID), item.BillingDeliveryMethod, true, item.LastLoginDate, item.BillAsClientName, item.DueText, 
                    item.BillingContactAddress1, item.BillingContactAddress2, item.BillingContactCity, item.BillingContactStateCode, item.BillingContactZIP, 
                    item.BillingContactEmail, item.BillingContactBusinessPhone, item.BillingContactFax,item.BillingContactPOName, item.BillingContactPONumber,
                    item.BillingContactNotes, Convert.ToBoolean(item.ClientContactStatus), Convert.ToBoolean(item.BillingContactStatus), item.BillingContactID,
                    item.LoginUserName);
            }
            else
                clientContacts = new ClientContact();

            return clientContacts;
        }

        public static List<SelectListItem> GetBillingContactsForDropdown(int _UserID)
        {
            List<SelectListItem> billingContacts = new List<SelectListItem>();

            ClientContactsDataContext dc = new ClientContactsDataContext();
            var result = dc.S1_ClientContacts_GetAllBillingContactsFromUserID(_UserID);

            SelectListItem firstitem = new SelectListItem();
            firstitem.Value = "0";
            firstitem.Text = "[All Accounts]";
            billingContacts.Add(firstitem);

            foreach (var item in result)
            {
                SelectListItem tempItem = new SelectListItem();
                tempItem.Value = item.BillingContactID.ToString();
                tempItem.Text = item.ClientName + "; "; 
                if (String.IsNullOrEmpty(item.BillingContactName))
                {
                    tempItem.Text += item.BillingContactAddress1;
                }
                else
                {
                    tempItem.Text += item.BillingContactName;
                }
                billingContacts.Add(tempItem);
            }

            return billingContacts;
        }


        //Create Client Contact
        public static int CreateClientContact(int userid, int clientid, string firstname, string lastname, string title, string addr1, string addr2,
                                              string city, string state, string zip, string businessphone, string cellphone, string fax, string email)
        {

            var dc = new ClientContactsDataContext();
            var result = dc.S1_ClientContacts_CreateClientContact(userid, clientid, firstname, lastname, title, addr1, addr2, 
                                                                city, state, zip, businessphone, fax, email).SingleOrDefault();

            if (result.ClientContactID != 0)
            {
                return result.ClientContactID.Value;
            }
            else
            {
                return 0;
            }

        }

        //Update Client Contact
        public static int UpdateClientContact(int clientcontactid, int userid, int clientid, string firstname, string lastname, string title, string addr1, string addr2,
                                              string city, string state, string zip, string businessphone, string cellphone, string fax, string email, bool clientcontactstatus)
        {

            var dc = new ClientContactsDataContext();
            var result = dc.S1_ClientContacts_UpdateClientContact(clientcontactid, userid, clientid, firstname, lastname, title, addr1, addr2,
                                                                city, state, zip, businessphone, fax, email, clientcontactstatus);

            if (result != 0)
            {
                return result - 1;
            }
            else
            {
                return 0;
            }

        }


        //Create Billing Contact
        public static int CreateBillingContact(int clientid, int clientcontactid, int deliverymethod, string contactname, string addr1, string addr2,
                                              string city, string state, string zip, string businessphone, string fax, string email,
                                              bool isprimary, string poname, string ponumber, string notes, bool onlyshowinvoices)
        {

            var dc = new ClientContactsDataContext();
            var result = dc.S1_ClientContacts_CreateBillingContact(clientid, clientcontactid, deliverymethod, contactname, addr1, addr2,
                                                                city, state, zip, businessphone, fax, email, isprimary, poname, 
                                                                ponumber, notes, onlyshowinvoices).SingleOrDefault();

            if (result.BillingContactID != 0)
            {
                return result.BillingContactID.Value;
            }
            else
            {
                return 0;
            }

        }


        //Update Billing Contact
        public static int UpdateBillingContact(int billingcontactid, int clientid, int clientcontactid, int deliverymethod, string contactname, string addr1, string addr2,
                                              string city, string state, string zip, string businessphone, string fax, string email,
                                              bool isprimary, string poname, string ponumber, string notes, bool onlyshowinvoices, bool billingcontactstatus, int newprimarycontactid)
        {

            var dc = new ClientContactsDataContext();
            var result = dc.S1_ClientContacts_UpdateBillingContact(billingcontactid, clientid, clientcontactid, deliverymethod, contactname, addr1, addr2,
                                                                city, state, zip, businessphone, fax, email, isprimary, poname,
                                                                ponumber, notes, onlyshowinvoices, billingcontactstatus, newprimarycontactid);

            return result;

        }

        //Fix Issues Billing Contact
        public static void FixIssuesBillingContact(int clientid)
        {
            var dc = new ClientContactsDataContext();
            dc.S1_ClientContacts_FixIssuesBillingContact(clientid);
        }

        //Delete Client and Billing Contact
        public static int DeleteClientContact(int clientcontactid,int billingcontactid, int clientid,  int userid)
        {

            var dc = new ClientContactsDataContext();
            var result = dc.S1_ClientContacts_DeleteContact(billingcontactid, clientcontactid, userid, clientid).SingleOrDefault().ErrorCode.GetValueOrDefault();
            return result;

        }
        
        //Get a list of billing contacts for the specified client.  The list is formatted for use in a dropdown.
        public static List<SelectListItem> GetBillingContactsFromClientForDropdown(int _ClientID)
        {
            List<SelectListItem> billingcontactlist = new List<SelectListItem>();

            var db = new ClientContactsDataContext();
            var result = db.S1_ClientContacts_GetBillingContactsFromClientID(_ClientID);

            foreach (var item in result)
            {
                if (item.BillingContactID != 0)
                {
                    SelectListItem listitem = new SelectListItem();
                    listitem.Value = item.BillingContactID.ToString();
                    listitem.Text = item.ClientContactName;
                    billingcontactlist.Add(listitem);
                }
            }

            return billingcontactlist;
        }

        public static bool GetBillingContactHideFromClientFromUserID(int _UserID)
        {
            ClientContactsDataContext dc = new ClientContactsDataContext();
            var result = dc.S1_ClientContacts_GetBillingContactHideFromClientFromUserID(_UserID).SingleOrDefault().HideFromClient;

            if (result.HasValue)
            {
                return result.Value;
            }
            else
            {
                return false;
            }
        }
    }

    public class ClientContact
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
        public string LoginUserName;

        public ClientContact() { ClientContactID = 0; }

        public ClientContact(int _ClientContactID, string _ClientContactName, string _ClientContactFirstName, string _ClientContactLastName, string _ClientContactTitle, string _ClientContactAddress1,
            string _ClientContactAddress2, string _ClientContactCity, string _ClientContactStateCode, string _ClientContactZIP,
            string _ClientContactBusinessPhone, string _ClientContactCellPhone, string _ClientContactFax, string _ClientContactEmail,
            string _BillingContactName, bool _IsPrimaryBillingContact, bool _OnlyShowInvoices, int _ClientID, int _UserID, 
            string _DeliveryMethod, bool _IsBillingContact, string _LastLoginDate, string _BillAsClientName, string _DueText,
            string _BillingContactAddress1, string _BillingContactAddress2, string _BillingContactCity, string _BillingContactStateCode,
            string _BillingContactZIP, string _BillingContactEmail, string _BillingContactBusinessPhone, string _BillingContactFax,
            string _BillingContactPOName, string _BillingContactPONumber, string _BillingContactNotes, bool _ClientContactStatus, bool _BillingContactStatus, int _BillingContactID,
            string _LoginUserName) 
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
            LoginUserName = _LoginUserName;
        }
    }
}
