using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ScreeningONE.Models;
using System.Configuration;

namespace ScreeningONE.DomainModels
{
    public static class Clients
    {
        //return one client
        public static Client GetClient(int _ClientID)
        {
            Client client;
            var dc = new ClientsDataContext();
            var result = dc.S1_Clients_GetClient(_ClientID).SingleOrDefault();
            if (result != null)
            {
                client = new Client(result.ClientID, result.ClientName, Convert.ToInt32(result.ParentClientID), result.ParentClientName, result.BillAsClientName, result.Status, result.Address1, result.Address2,
                    result.City, result.State, result.ZipCode, (result.DoNotInvoice.HasValue ? result.DoNotInvoice.Value : false), (result.AuditInvoices.HasValue ? result.AuditInvoices.Value : false), Convert.ToInt32(result.BillingGroup), result.Notes);
            }
            else
            {
                client = new Client();
            }

            return client;
        }

        //return one ClientInvoiceSettings record
        public static ClientInvoiceSettings GetClientInvoiceSettings(int _ClientID)
        {
            ClientInvoiceSettings clientInvoiceSettings;
            var dc = new ClientsDataContext();
            var result = dc.S1_Clients_GetClientInvoiceSettings(_ClientID).SingleOrDefault();
            if (result != null)
            {
                clientInvoiceSettings = new ClientInvoiceSettings(result.InvoiceTemplateID, result.ReportGroupID.Value, result.SplitByMode.Value,
                                                                (result.ApplyFinanceCharge.HasValue ? result.ApplyFinanceCharge.Value : false), Convert.ToInt32(result.FinanceChargeDays),
                                                                Convert.ToDecimal(result.FinanceChargePercent), (result.SentToCollections.HasValue ? result.SentToCollections.Value : false), result.ExcludeFromReminders.GetValueOrDefault());
            }
            else
            {
                clientInvoiceSettings = new ClientInvoiceSettings();
            }

            return clientInvoiceSettings;
        }


        //return one ClientExpectedRevenue record
        public static ClientExpectedRevenueSettings GetClientExpectedRevenueSettings(int _ClientID)
        {
            ClientExpectedRevenueSettings clientExpectedRevenueSettings;
            var dc = new ClientsDataContext();
            var result = dc.S1_Clients_GetExpectedRevenueSettings(_ClientID).SingleOrDefault();
            if (result != null)
            {
                clientExpectedRevenueSettings = new ClientExpectedRevenueSettings((result.ExpectedMonthlyRevenue.HasValue ? result.ExpectedMonthlyRevenue.Value : 0), 
                    (result.AccountCreateDate.HasValue ? result.AccountCreateDate.Value : new DateTime()), 
                    result.AccountOwner, 
                    result.AffiliateName);
            }
            else
            {
                clientExpectedRevenueSettings = new ClientExpectedRevenueSettings();
            }

            return clientExpectedRevenueSettings;
        }


        //return one ClientVendors record
        public static ClientVendors GetClientVendors(int _ClientID)
        {
            ClientVendors clientVendors;
            var dc = new ClientsDataContext();
            var result = dc.S1_Clients_GetClientVendors(_ClientID).SingleOrDefault();
            if (result != null)
            {
                clientVendors = new ClientVendors(result.Tazworks1ID, result.Tazworks2ID, result.Debtor11ID, result.TransUnionID, result.ExperianID, result.PembrookID, result.ApplicantONEID, result.RentTrackID);
            }
            else
            {
                clientVendors = new ClientVendors();
            }

            return clientVendors;
        }

        // Client Info

        //Create
        public static int CreateClient(string ClientName, string Address1, string Address2, string City, string State, string Zip, bool Tazworks1Client, bool Tazworks2Client, bool NonTazworksClient)
        {

            var dc = new ClientsDataContext();
            var result = dc.S1_Clients_CreateClient(ClientName, Address1, Address2, City, State, Zip, Tazworks1Client, Tazworks2Client, NonTazworksClient).SingleOrDefault();

            if (result.ClientID != 0)
            {
                return result.ClientID.Value;
            }
            else
            {
                return 0;
            }
            
        }

        //Update
        public static int UpdateClientInfo(int _ClientID, string ClientName, string Address1, string Address2, string City, string State, string Zip,
                                                int ParentClientID, string BillAsClientName, string Status, bool AuditInvoices, bool DoNotInvoice, int BillingGroupID, string notes)
        {
            
            var dc = new ClientsDataContext();
            int result = dc.S1_Clients_UpdateClientInfo(_ClientID, ClientName, Address1, Address2, City, State, Zip, ParentClientID, BillAsClientName, Status, AuditInvoices, DoNotInvoice, BillingGroupID, notes);

            return result;
        }

        public static void RemoveParentRelationship(int _ClientID)
        {
            var dc = new ClientsDataContext();
            dc.S1_Clients_RemoveParentRelationship(_ClientID);
        }


        // End Client Info



        // Client Invoice Settings

        //Create
        public static void CreateClientInvoiceSettings(int _ClientID, int _InvoiceTemplate, int _ClientSplitMode, int _BillingDetailReport, bool _HideSSN, bool _ApplyFinanceCharges,
                                                       int _FinChargeDays, decimal _FinChargePct, bool _SentToCollections, bool _ExcludeFromReminders)
        {
            var dc = new ClientsDataContext();
            dc.S1_Clients_CreateClientInvoiceSettings(_ClientID, _InvoiceTemplate, _ClientSplitMode, _BillingDetailReport, _HideSSN,
                                                _ApplyFinanceCharges, _FinChargeDays, _FinChargePct, _SentToCollections, _ExcludeFromReminders);
        }

        //Update
        public static void UpdateClientInvoiceSettings(int _ClientID, int _InvoiceTemplate, int _ClientSplitMode, int _BillingDetailReport, bool _HideSSN,
                                                bool _ApplyFinanceCharges, int _FinChargeDays, decimal _FinChargePct, bool _SentToCollections, bool _ExcludeFromReminders)
        {
            var dc = new ClientsDataContext();
            dc.S1_Clients_UpdateClientInvoiceSettings(_ClientID, _InvoiceTemplate, _ClientSplitMode, _BillingDetailReport, _HideSSN,
                                                _ApplyFinanceCharges, _FinChargeDays, _FinChargePct, _SentToCollections, _ExcludeFromReminders);
        }

        //Remove
        public static void RemoveClientInvoiceSettings(int _ClientID)
        {
            var dc = new ClientsDataContext();
            dc.S1_Clients_RemoveClientInvoiceSettings(_ClientID);
        }

        // End Client Invoice Settings


        // Expected Revenue Settings

        //Save = Add or Update
        public static void SaveExpectedRevenueSettings(int ClientID, decimal ExpectedMonthlyRevenue, DateTime AccountCreateDate, string AccountOwner, string AffiliateName)
        {
            using (ClientsDataContext dc = new ClientsDataContext())
            {
                dc.S1_Clients_SaveExpectedRevenueSettings(ClientID, ExpectedMonthlyRevenue, AccountCreateDate, AccountOwner, AffiliateName);
            }
        }

        // End Expeted Revenue Settings


        // Client Vendor Settings

        //Update
        public static void UpdateClientVendorSettings(int _ClientID, int vendorid, string vendorclientnumber)
        {
            var dc = new ClientsDataContext();
            dc.S1_Clients_UpdateClientVendorSettings(_ClientID, vendorid, vendorclientnumber);
        }

        // End Client Vendor Settings

        public static List<int> GetClientIDsFromUser(int _UserID)
        {
            List<int> outList = new List<int>();

            var dc = new ClientsDataContext();
            var result = dc.S1_Clients_GetClientsFromUser(_UserID);
            foreach (var item in result)
            {
                outList.Add(item.ClientID);
            }

            return outList;
        }

        public static List<SelectListItem> GetSubClientListFromUser(int _UserID)
        {
            List<SelectListItem> clientlist = new List<SelectListItem>();

            var dc = new ClientsDataContext();
            var result = dc.S1_Clients_GetClientsFromUser(_UserID);
            foreach (var item in result)
            {
                if (item.ParentClientID != null)
                {
                    SelectListItem listitem = new SelectListItem();
                    listitem.Value = item.ClientID.ToString();
                    listitem.Text = item.ClientName;
                    clientlist.Add(listitem);
                }
            }

            return clientlist;
        }
        
        
        public static List<SelectListItem> GetClientListFromUser(int _UserID)
        {
            List<SelectListItem> clientlist = new List<SelectListItem>();

            var dc = new ClientsDataContext();
            var result = dc.S1_Clients_GetClientsFromUser(_UserID);
            foreach (var item in result)
            {
                SelectListItem listitem = new SelectListItem();
                listitem.Value = item.ClientID.ToString();
                listitem.Text = item.ClientName;
                clientlist.Add(listitem);
            }

            return clientlist;
        }

        //Get a list of users for the specified client.  The list is formatted for use in a dropdown.
        public static List<SelectListItem> GetUsersFromClientForDropdown(int _ClientID)
        {
            List<SelectListItem> usersList = new List<SelectListItem>();

            var db = new UsersDataContext();
            var result = db.S1_Users_GetClientUsers(_ClientID);
            foreach (var item in result)
            {
                if (!String.IsNullOrEmpty(item.UserName))
                {
                    SelectListItem listitem = new SelectListItem();
                    listitem.Value = item.UserID.ToString();
                    listitem.Text = item.UserName;
                    usersList.Add(listitem);
                }
            }

            return usersList;
        }

        public static int GetParentClientIDFromUser(int _UserID)
        {
            int? clientID = null;
            var dc = new ClientsDataContext();
            var result = dc.S1_Clients_GetClientsFromUser(_UserID);
            foreach (var item in result)
            {
                clientID = item.ClientID;
                if (item.ParentClientID == null)
                {
                    return item.ClientID;
                }
            }

            if (clientID.HasValue)
            {
                int? parentClientID = new int?();
                var result2 = dc.S1_Clients_GetClientParentWithOutput(clientID.Value, ref parentClientID);
                if (parentClientID.HasValue)
                {
                    return parentClientID.Value;
                }
            }
            return 0;
        }

        public static S1_Clients_GetClientsFromUserResult GetParentClientFromUser(int _UserID)
        {
            var dc = new ClientsDataContext();
            var result = dc.S1_Clients_GetClientsFromUser(_UserID);
            foreach (var item in result)
            {
                if (item.ParentClientID == null)
                {
                    return (S1_Clients_GetClientsFromUserResult)item;
                }
            }

            return null;
        }


        public static string GetClientNameFromID(int _ClientID)
        {

                var db = new ClientsDataContext();
                var q = from o in db.Clients
                        where o.ClientID == _ClientID
                        select new
                        {
                            name = o.ClientName
                        };

                if (q.Count() > 0)
                {
                    return q.SingleOrDefault().name;
                }
                else
                {
                    return ConfigurationManager.AppSettings["CompanyName"];
                }
        }

        /*
        public static ATS_ClientSettings_GetClientFromClientIDResult GetClientInfo(int ClientID)
        {
            var db = new ClientsDataContext();
            var result = db.ATS_ClientSettings_GetClientFromClientID(ClientID).SingleOrDefault();
                
            return result;
        }
        */

        public static List<ScreeningONE.Models.Users.S1_Users_GetClientUsersResult> GetClientUsers(int clientid)
        {
            var db = new UsersDataContext();
            var result = db.S1_Users_GetClientUsers(clientid);

            return result.ToList();
        }

        public static List<S1_Users_GetAllClientUsersResult> GetAllClientUsers()
        {
            var db = new ClientsDataContext();
            var result = db.S1_Users_GetAllClientUsers();

            return result.ToList();
        }

        public static List<SelectListItem> GetClientListForDropdown()
        {
            List<SelectListItem> clientlist = new List<SelectListItem>();

            var db = new ClientsDataContext();
            var result = db.S1_Clients_GetClientList();
            foreach (var item in result)
            {
                SelectListItem listitem = new SelectListItem();
                listitem.Value = item.ClientID.ToString();
                listitem.Text = item.ClientName;
                clientlist.Add(listitem);
            }

            return clientlist;
            
        }

        public static List<SelectListItem> GetClientsWithInvoicesForDropdown()
        {
            List<SelectListItem> clientlist = new List<SelectListItem>();

            var db = new ClientsDataContext();
            var result = db.S1_Clients_GetClientsWithInvoices();
            foreach (var item in result)
            {
                SelectListItem listitem = new SelectListItem();
                listitem.Value = item.ClientID.ToString();
                listitem.Text = item.ClientName;
                clientlist.Add(listitem);
            }

            return clientlist;

        }

        public static List<SelectListItem> GetClientsWithInvoicesForDropdownAuditOnly(DateTime StartDate, DateTime Enddate)
        {
            List<SelectListItem> clientlist = new List<SelectListItem>();

            var db = new ClientsDataContext();
            var result = db.S1_Clients_GetClientsWithInvoicesAuditOnly(StartDate, Enddate);
            foreach (var item in result)
            {
                SelectListItem listitem = new SelectListItem();
                listitem.Value = item.ClientID.ToString();
                listitem.Text = item.ClientName;
                clientlist.Add(listitem);
            }

            return clientlist;

        }

        public static List<SelectListItem> GetClientsWithInvoicesForDropdownNonAudit(DateTime StartDate, DateTime EndDate)
        {
            List<SelectListItem> clientlist = new List<SelectListItem>();

            var db = new ClientsDataContext();
            var result = db.S1_Clients_GetClientsWithInvoicesNonAudit(StartDate, EndDate);
            foreach (var item in result)
            {
                SelectListItem listitem = new SelectListItem();
                listitem.Value = item.ClientID.ToString();
                listitem.Text = item.ClientName;
                clientlist.Add(listitem);
            }

            return clientlist;

        }



        public static List<SelectListItem> GetClientsWithUnInvoicedProductTransactionsForDropdown(DateTime StartDate, DateTime EndDate)
        {
            List<SelectListItem> clientlist = new List<SelectListItem>();

            var db = new ClientsDataContext();
            var result = db.S1_Clients_GetClientsWithUnInvoicedProductTransactions(StartDate, EndDate);
            foreach (var item in result)
            {
                SelectListItem listitem = new SelectListItem();
                listitem.Value = item.ClientID.ToString();
                listitem.Text = item.ClientName;
                clientlist.Add(listitem);
            }

            return clientlist;

        }

        public static List<SelectListItem> GetClientListBySplitModeForDropdown(int SplitMode, DateTime StartDate, DateTime EndDate)
        {
            List<SelectListItem> clientlist = new List<SelectListItem>();

            var db = new ClientsDataContext();
            var result = db.S1_Clients_GetClientListBySplitMode(SplitMode, StartDate, EndDate);
            foreach (var item in result)
            {
                SelectListItem listitem = new SelectListItem();
                listitem.Value = item.ClientID.ToString();
                listitem.Text = item.ClientName;
                clientlist.Add(listitem);
            }

            return clientlist;

        }


        public static List<SelectListItem> GetClientsWithBillingContactsForDropdown()
        {
            List<SelectListItem> clientlist = new List<SelectListItem>();

            var db = new ClientsDataContext();
            var result = db.S1_Clients_GetClientsWithBillingContacts();
            foreach (var item in result)
            {
                SelectListItem listitem = new SelectListItem();
                listitem.Value = item.ClientID.ToString();
                listitem.Text = item.ClientName;
                clientlist.Add(listitem);
            }

            return clientlist;

        }

        public static List<Client> GetClients()
        {
            List<Client> clientsList = new List<Client>();

            var db = new ClientsDataContext();
            var result = db.S1_Clients_GetClientList();
            foreach (var item in result)
            {
                Client listitem = new Client(item.ClientID, item.ClientName, Convert.ToInt32(item.ParentClientID), item.ParentClientName, item.BillAsClientName, item.Status, Convert.ToDecimal(item.CurrentBalance));
                clientsList.Add(listitem);
            }

            return clientsList;
        }

        //Return a list of Billing Contacts for a client as SelectListItem's (for use in dropdowns)
        public static List<SelectListItem> GetBillingContactsForClient(int _ClientID)
        {
            List<SelectListItem> billingContactList = new List<SelectListItem>();

            var dc = new ClientsDataContext();
            var result = dc.S1_Clients_GetBillingContactsForClient(_ClientID);
            foreach (var item in result)
            {
                SelectListItem listitem = new SelectListItem();
                listitem.Value = item.Value.ToString();
                listitem.Text = item.Text;
                billingContactList.Add(listitem);
            }

            return billingContactList;
        }

        //Gets the first primary BillingContactID for a BillAsClientName (QuickBooks Customer Name)
        public static int? GetFirstBillingContactFromBillAsClientName(string _BillAsClientName)
        {
            ClientsDataContext dc = new ClientsDataContext();
            var result = dc.S1_Clients_GetFirstBillingContactFromBillAsClientName(_BillAsClientName).SingleOrDefault();
            if (result != null)
            {
                return result.BillingContactID;
            }
            else
            {
                return null;
            }
        }


        //Gets the first primary BillingContactID for a ClientID
        public static int? GetPrimaryBillingContactIDFromClient(int _ClientID)
        {
            ClientsDataContext dc = new ClientsDataContext();
            var result = dc.S1_Clients_GetPrimaryBillingContactIDForClient(_ClientID).SingleOrDefault();
            if (result != null)
            {
                return result.BillingContactID;
            }
            else
            {
                return 0;
            }
        }

        //Logs an action in the ActionLog table
        public static void LogAction(string _ActionTypeCode, string _LogDescription)
        {
            ClientsDataContext dc = new ClientsDataContext();
            dc.S1_Log_CreateAction(_ActionTypeCode, _LogDescription);
        }


        public static List<SelectListItem> GetClientVendorsList(int _ClientID)
        {
            List<SelectListItem> clientvendorslist = new List<SelectListItem>();

            var dc = new ClientsDataContext();
            var result = dc.S1_Clients_GetClientVendorsList(_ClientID);
            foreach (var item in result)
            {
                if (item.VendorID != null)
                {
                    SelectListItem listitem = new SelectListItem();
                    listitem.Value = item.VendorID.ToString();
                    listitem.Text = item.VendorName;
                    clientvendorslist.Add(listitem);
                }
            }

            return clientvendorslist;
        }

        public static List<S1_Clients_GetClientListForInvoiceBalancerResult> GetClientListForInvoiceBalancer()
        {
            using (ClientsDataContext dc = new ClientsDataContext())
            {
                return dc.S1_Clients_GetClientListForInvoiceBalancer().ToList();
            }
        }

        public static List<SelectListItem> GetClientSelectListItemListForInvoiceBalancer()
        {
            List<SelectListItem> clientlist = new List<SelectListItem>();

            foreach (var item in GetClientListForInvoiceBalancer())
            {
                    SelectListItem listitem = new SelectListItem();
                    listitem.Value = item.ClientID.ToString();
                    listitem.Text = item.ClientName.ToString();
                    clientlist.Add(listitem);
            }

            return clientlist;
        }

        public static void RemovePaymentFromInvoice(int paymentID, int invoiceID) 
        {
            using (ClientsDataContext dc = new ClientsDataContext())
            {
                dc.S1_Clients_RemovePaymentFromInvoice(paymentID, invoiceID);
            }        
        }

        public static S1_Clients_AttachInvoiceToPaymentResult AttachInvoiceToPayment(int clientID, int paymentID, int invoiceID, string invoiceNumber, DateTime invoiceDate, string invoiceQB, decimal paymentSpent, bool manualEntry, int manualUserID)
        {
            using (ClientsDataContext dc = new ClientsDataContext())
            {
                return dc.S1_Clients_AttachInvoiceToPayment(clientID, paymentID, invoiceID, invoiceNumber, invoiceDate, invoiceQB, paymentSpent, manualEntry, manualUserID).FirstOrDefault();
            }
        }

        public static S1_Clients_AttachPaymentToInvoiceResult AttachPaymentToInvoice(int clientID, int invoiceID, int paymentID, DateTime paymentDate, string paymentQB, decimal amountReceived, bool manualEntry, int manualUserID)
        {
            using (ClientsDataContext dc = new ClientsDataContext())
            {
                return dc.S1_Clients_AttachPaymentToInvoice(clientID, invoiceID, paymentID, paymentDate, paymentQB, amountReceived, manualEntry, manualUserID).FirstOrDefault();
            }
        }

        public static bool RemovePayment(int clientID, int paymentID)
        {
            bool success = false;
            using (ClientsDataContext dc = new ClientsDataContext())
            {
                var result = dc.S1_Clients_RemovePayment(clientID, paymentID).FirstOrDefault();
                
                if (result != null &&
                    result.success.GetValueOrDefault()) 
                {
                    success = true;
                }
            }
            return success;
        }

        public static List<S1_Clients_PaymentToInvoiceSearchByAmountResult> PaymentToInvoiceSearchByAmount(int clientID, string totalAmount)
        {
            using (ClientsDataContext dc = new ClientsDataContext())
            {
                return dc.S1_Clients_PaymentToInvoiceSearchByAmount(clientID, totalAmount).ToList();
            }
        }

        public static List<S1_Clients_PaymentToInvoiceSearchByDateResult> PaymentToInvoiceSearchByDate(int clientID, string Date)
        {
            using (ClientsDataContext dc = new ClientsDataContext())
            {
                return dc.S1_Clients_PaymentToInvoiceSearchByDate(clientID, Date).ToList();
            }
        }

        public static List<S1_Clients_PaymentToInvoiceSearchByIDResult> PaymentToInvoiceSearchByID(int clientID, string paymentID)
        {
            using (ClientsDataContext dc = new ClientsDataContext())
            {
                return dc.S1_Clients_PaymentToInvoiceSearchByID(clientID, paymentID).ToList();
            }
        }

        public static List<S1_Clients_PaymentToInvoiceSearchByQBResult> PaymentToInvoiceSearchByQB(int clientID, string QBTransactionID)
        {
            using (ClientsDataContext dc = new ClientsDataContext())
            {
                return dc.S1_Clients_PaymentToInvoiceSearchByQB(clientID, QBTransactionID).ToList();
            }
        }

        public static List<S1_Clients_InvoiceToPaymentSearchByAmountResult> InvoiceToPaymentSearchByAmount(int clientID, string totalAmount)
        {
            using (ClientsDataContext dc = new ClientsDataContext())
            {
                return dc.S1_Clients_InvoiceToPaymentSearchByAmount(clientID, totalAmount).ToList();
            }
        }

        public static List<S1_Clients_InvoiceToPaymentSearchByDateResult> InvoiceToPaymentSearchByDate(int clientID, string Date)
        {
            using (ClientsDataContext dc = new ClientsDataContext())
            {
                return dc.S1_Clients_InvoiceToPaymentSearchByDate(clientID, Date).ToList();
            }
        }

        public static List<S1_Clients_InvoiceToPaymentSearchByInvoiceNumberResult> InvoiceToPaymentSearchByInvoiceNumber(int clientID, string paymentID)
        {
            using (ClientsDataContext dc = new ClientsDataContext())
            {
                return dc.S1_Clients_InvoiceToPaymentSearchByInvoiceNumber(clientID, paymentID).ToList();
            }
        }

        public static List<S1_Clients_InvoiceToPaymentSearchByQBResult> InvoiceToPaymentSearchByQB(int clientID, string QBTransactionID)
        {
            using (ClientsDataContext dc = new ClientsDataContext())
            {
                return dc.S1_Clients_InvoiceToPaymentSearchByQB(clientID, QBTransactionID).ToList();
            }
        }

    }

    public class Client
    {
        public int ClientID;
        public string ClientName;
        public int ParentClientID;
        public string ParentClientName;
        public string BillAsClientName;
        public string Status;
        public string Address1;
        public string Address2;
        public string City;
        public string State;
        public string Zip;
        public bool DoNotInvoice;
        public bool AuditInvoices;
        public decimal CurrentBalance;
        public int BillingGroupID;
        public string Notes;

        public Client() { }

        public Client(int _ClientID, string _ClientName, int _ParentClientID, string _ParentClientName, string _BillAsClientName, string _Status, decimal _CurrentBalance)
        {
            ClientID = _ClientID;
            ClientName = _ClientName;
            ParentClientID = _ParentClientID;
            ParentClientName = _ParentClientName;
            BillAsClientName = _BillAsClientName;
            Status = _Status;
            CurrentBalance = _CurrentBalance;
        }

        public Client(int _ClientID, string _ClientName, int _ParentClientID, string _ParentClientName, string _BillAsClientName, string _Status, string _Address1, string _Address2,
            string _City, string _State, string _Zip, bool _DoNotInvoice, bool _AuditInvoices, int _BillingGroupID, string _notes)
        {
            ClientID = _ClientID;
            ClientName = _ClientName;
            ParentClientID = _ParentClientID;
            ParentClientName = _ParentClientName;
            BillAsClientName = _BillAsClientName;
            Status = _Status;
            Address1 = _Address1;
            Address2 = _Address2;
            City = _City;
            State = _State;
            Zip = _Zip;
            DoNotInvoice = _DoNotInvoice;
            AuditInvoices = _AuditInvoices;
            BillingGroupID = _BillingGroupID;
            Notes = _notes;
        }
    }

    public class ClientInvoiceSettings
    {
        public int InvoiceTemplate;
        public int BillingDetailReport;
        public int ClientSplitMode;
        public bool ApplyFinanceCharge;
        public int FinanceChargeDays;
        public decimal FinanceChargePercent;
        public bool SentToCollections;
        public bool ExcludeFromReminders;

        public ClientInvoiceSettings() { InvoiceTemplate = 0; BillingDetailReport = 0; ClientSplitMode = 0; }

        public ClientInvoiceSettings(int _InvoiceTemplate, int _BillingDetailReport, int _ClientSplitMode, bool _ApplyFinanceCharge,
                                     int _FinanceChargeDays, decimal _FinanceChargePercent, bool _SentToCollections, bool _ExcludeFromReminders)
        {
            InvoiceTemplate = _InvoiceTemplate;
            BillingDetailReport = _BillingDetailReport;
            ClientSplitMode = _ClientSplitMode;
            ApplyFinanceCharge = _ApplyFinanceCharge;
            FinanceChargeDays = _FinanceChargeDays;
            FinanceChargePercent = _FinanceChargePercent;
            SentToCollections = _SentToCollections;
            ExcludeFromReminders = _ExcludeFromReminders;
        }
    }

    public class ClientExpectedRevenueSettings
    {
        public decimal ExpectedMonthlyRevenue { get; set; }
        public DateTime AccountCreateDate { get; set; }
        public string AccountOwner { get; set; }
        public string AffiliateName { get; set; }

        public ClientExpectedRevenueSettings() { ExpectedMonthlyRevenue = 0; AccountCreateDate = new DateTime(); AccountOwner = ""; AffiliateName = ""; }

        public ClientExpectedRevenueSettings(decimal _ExpectedMonthlyRevenue, DateTime _AccountCreateDate, string _AccountOwner, string _AffiliateName)
        {
            ExpectedMonthlyRevenue = _ExpectedMonthlyRevenue;
            AccountCreateDate = _AccountCreateDate;
            AccountOwner = _AccountOwner;
            AffiliateName = _AffiliateName;
        }
    }

    public class ClientVendors
    {
        public string Tazworks1ID;
        public string Tazworks2ID;
        public string Debtor1ID;
        public string TransUnionID;
        public string ExperianID;
        public string PembrookeID;
        public string ApplicantONEID;
        public string RentTrackID;

        public ClientVendors() { Tazworks1ID = ""; Tazworks2ID = ""; Debtor1ID = ""; TransUnionID = ""; ExperianID = ""; PembrookeID = ""; ApplicantONEID = ""; RentTrackID = ""; }

        public ClientVendors(string _Tazworks1ID, string _Tazworks2ID, string _Debtor1ID, string _TransUnionID, string _ExperianID, string _PembrookeID, string _ApplicantONEID, string _RentTrackID)
        {
            Tazworks1ID = _Tazworks1ID;
            Tazworks2ID = _Tazworks2ID;
            Debtor1ID = _Debtor1ID;
            TransUnionID = _TransUnionID;
            ExperianID = _ExperianID;
            PembrookeID = _PembrookeID;
            ApplicantONEID = _ApplicantONEID;
            RentTrackID = _RentTrackID;
        }
    }
}
