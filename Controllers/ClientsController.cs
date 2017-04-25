using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using ScreeningONE.Objects;
using ScreeningONE.ViewModels;
using ScreeningONE.DomainModels;
using StringExtensions;

namespace ScreeningONE.Controllers
{
    public class ClientsController : S1BaseController
    {
        //
        // GET: /Clients/

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult Index()
        {
            Clients_Details viewClients_Details = new Clients_Details();

            viewClients_Details.ClientID = 0;

            return View(viewClients_Details);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public JsonResult IndexJSON(FormCollection fc)
        {
            int ID = Convert.ToInt32(fc["id"]);
            string FieldToSort = fc["sidx"];
            string strSortOrder = fc["sord"];
            bool _search = Convert.ToBoolean(fc["_search"]);
            string searchField = fc["searchField"];
            string searchOper = fc["searchOper"];
            string searchString = fc["searchString"];

            SortDirection SortOrder;

            if (FieldToSort == "id")
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

            List<Client> clientlist = Clients.GetClients();
            List<Client> result;

            if (_search)
                
                switch (searchField)
                {
                    case "ClientName":
                        result = clientlist.Where(x => x.ClientName.ToUpper().Contains(searchString.ToUpper())).ToList();
                        break;
                        
                    case "ParentClientName":
                        result = clientlist.Where(x => x.ParentClientName.ToUpper().Contains(searchString.ToUpper())).ToList();
                        break;

                    case "BillAsClientName":
                        result = clientlist.Where(x => x.BillAsClientName.ToUpper().Contains(searchString.ToUpper())).ToList();
                        break;

                       
                    default:
                        result = clientlist.ToList();
                        break;
                        
                }
                
            else
                result = clientlist.ToList();
            //var result = Clients.GetClients();

            Array rows = (from question in result.Order(FieldToSort, SortOrder)
                          select new
                          {
                              i = question.ClientID,
                              cell = new string[] { question.ClientID.ToString(), 
                                  question.ClientName,
                                  question.ParentClientName,
                                    question.BillAsClientName,
                                    question.Status,
                                    question.CurrentBalance.ToString("#,##0.00") }
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
        public JsonResult ClientContactsJSON(int ClientID, FormCollection fc) 
        {
            int ID = Convert.ToInt32(fc["id"]);
            string FieldToSort = fc["sidx"];
            string strSortOrder = fc["sord"];
            SortDirection SortOrder;

            if (FieldToSort == "id" || FieldToSort == "Action" || FieldToSort == "ClientContactEmail" || FieldToSort == "LastLoginDate" || FieldToSort == "DeliveryMethod" || FieldToSort == "IsPrimaryBillingContact" || FieldToSort == "ClientContactStatus")
            {
                FieldToSort = "ClientContactName";
            }

            if (strSortOrder == "desc")
                SortOrder = SortDirection.Descending;
            else
                SortOrder = SortDirection.Ascending;

            int RowsPerPage = Convert.ToInt32(fc["rows"]);
            int CurrentPage = Convert.ToInt32(fc["page"]);
            int StartRow = ((CurrentPage - 1) * RowsPerPage) + 1;
            int EndRow = StartRow + RowsPerPage - 1;

            var result = ClientContacts.GetClientContactsFromClientID(ClientID);

            Array rows = (from question in result.Order(FieldToSort, SortOrder)
                                                         
                         select new
                          {
                              i = question.ClientContactID,
                              cell = new string[] { question.ClientContactID.ToString(), 
                                  question.ClientContactEmail,
                                  question.ClientContactName,
                                  question.LastLoginDate,
                                  question.DeliveryMethod,
                                    (question.IsPrimaryBillingContact ? "Primary" : (question.IsBillingContact ? "Secondary" : "None") ),
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
        public ActionResult Details(int id) //id = ClientID
        {
            Clients_Details viewClients_Details = new Clients_Details();

            Client clientInfo = Clients.GetClient(id);
            ClientInvoiceSettings clientInvoiceSettings = Clients.GetClientInvoiceSettings(id);
            ClientInvoiceSettings parentInvoiceSettings = Clients.GetClientInvoiceSettings(clientInfo.ParentClientID);
            ClientExpectedRevenueSettings clientExpectedRevenueSettings = Clients.GetClientExpectedRevenueSettings(id);
            ClientVendors clientVendors = Clients.GetClientVendors(id);

            int BillingContactID = Clients.GetPrimaryBillingContactIDFromClient(id).Value;

            if (BillingContactID != 0)
            {
                viewClients_Details.AccountActivity = BillingStatements.GetAccountActivity(BillingContactID, 0);               
            }

            viewClients_Details.BillingContactID = BillingContactID;
            viewClients_Details.ClientName = clientInfo.ClientName;
            viewClients_Details.Address1 = clientInfo.Address1;
            viewClients_Details.Address2 = clientInfo.Address2;
            viewClients_Details.City = clientInfo.City;
            viewClients_Details.State = clientInfo.State;
            viewClients_Details.Zip = clientInfo.Zip;
            viewClients_Details.Status = clientInfo.Status;
            viewClients_Details.DoNotInvoice = clientInfo.DoNotInvoice;
            viewClients_Details.ClientID = id;
            viewClients_Details.ParentClientName = clientInfo.ParentClientName;
            viewClients_Details.Tazworks1ID = clientVendors.Tazworks1ID;
            viewClients_Details.Tazworks2ID = clientVendors.Tazworks2ID;
            viewClients_Details.Debtor1ID = clientVendors.Debtor1ID;
            viewClients_Details.TransUnionID = clientVendors.TransUnionID;
            viewClients_Details.ExperianID = clientVendors.ExperianID;
            viewClients_Details.BilledAsClientName = clientInfo.BillAsClientName;
            viewClients_Details.AuditInvoices = clientInfo.AuditInvoices;
            viewClients_Details.ParentClientID = clientInfo.ParentClientID;
            viewClients_Details.PembrookeID = clientVendors.PembrookeID;
            viewClients_Details.ApplicantONEID = clientVendors.ApplicantONEID;
            viewClients_Details.RentTrackID = clientVendors.RentTrackID;
            viewClients_Details.Notes = clientInfo.Notes;

            if (clientInfo.DoNotInvoice)
            {
                viewClients_Details.BillingGroupID = "0";
            }
            else
            {
                viewClients_Details.BillingGroupID = Convert.ToString(clientInfo.BillingGroupID);
            }

            if (clientInvoiceSettings.InvoiceTemplate == 0)
            {
                if (parentInvoiceSettings.ClientSplitMode == 2)
                {
                    viewClients_Details.HasClientInvoiceSettings = 2; //Parent roll up
                }
                else
                {
                    viewClients_Details.HasClientInvoiceSettings = 0;
                }
            }
            else
            {
                viewClients_Details.HasClientInvoiceSettings = 1;
            }

            if (clientVendors.Tazworks1ID == null && clientVendors.Tazworks2ID == null 
                && clientVendors.Debtor1ID == null && clientVendors.TransUnionID == null && clientVendors.ExperianID == null)
            {
                viewClients_Details.HasVendorSettings = false; 
            }
            else
            {
                viewClients_Details.HasVendorSettings = true;
            }

            viewClients_Details.InvoiceTemplate = clientInvoiceSettings.InvoiceTemplate;
            viewClients_Details.BillingDetailReport = clientInvoiceSettings.BillingDetailReport;
            viewClients_Details.ClientSplitMode = clientInvoiceSettings.ClientSplitMode;
            viewClients_Details.ApplyFinanceCharge = clientInvoiceSettings.ApplyFinanceCharge;
            viewClients_Details.FinanceChargeDays = clientInvoiceSettings.FinanceChargeDays;
            viewClients_Details.FinanceChargePercent = clientInvoiceSettings.FinanceChargePercent;
            viewClients_Details.SentToCollections = clientInvoiceSettings.SentToCollections;
            viewClients_Details.ExcludeFromReminders = clientInvoiceSettings.ExcludeFromReminders;

            viewClients_Details.ExpectedMonthlyRevenue = clientExpectedRevenueSettings.ExpectedMonthlyRevenue.ToString("#.##");
            viewClients_Details.AccountCreateDate = (clientExpectedRevenueSettings.AccountCreateDate == DateTime.MinValue ? "" : clientExpectedRevenueSettings.AccountCreateDate.ToString("MM/dd/yyyy"));
            viewClients_Details.AccountOwner = clientExpectedRevenueSettings.AccountOwner;
            viewClients_Details.AffiliateName = clientExpectedRevenueSettings.AffiliateName;

            return View("Details", "View", viewClients_Details);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult RemovePaymentFromInvoiceJSON(string clientID, string paymentID, string invoiceID, string invoiceNumber)
        {
            int id = 0;
            if (!int.TryParse(clientID, out id))
            {
               id = 0;
            }            
            string message = "";
            AccountActivity accountActivity = null;
            try
            {
                int paymentIDInt = int.Parse(paymentID);
                int invoiceIDInt = int.Parse(invoiceID);
                Clients.RemovePaymentFromInvoice(paymentIDInt, invoiceIDInt);
                int BillingContactID = Clients.GetPrimaryBillingContactIDFromClient(id).Value;
                if (BillingContactID != 0)
                {
                    accountActivity = BillingStatements.GetAccountActivityForAnInvoiceIDAndPaymentID(BillingContactID, 0, invoiceIDInt, paymentIDInt);
                    return new JsonResult { Data = new { success = true, accountActivity = accountActivity, paymentID = paymentID, invoiceID = invoiceID, invoiceNumber = invoiceNumber } };
                }
                else 
                {
                    message = "Request processed. However there is no primary billing contact for the client.";
                }
            }
            catch(Exception ex)
            {
                message = ex.Message;
            }
            return new JsonResult { Data = new { success = false, message = message, paymentID = paymentID, invoiceID = invoiceID, invoiceNumber = invoiceNumber } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult AttachPaymentToInvoiceJSON(string clientID, string invoiceID, string paymentIDs, string paymentDates, string paymentQBs, string amountsReceived)
        {
            int id = 0;
            if (!int.TryParse(clientID, out id))
            {
                id = 0;
            }

            string[] paymentID = paymentIDs.Split(new string[] { "~*~" }, StringSplitOptions.None);
            string[] paymentDate = paymentDates.Split(new string[] { "~*~" }, StringSplitOptions.None);
            string[] paymentQB = paymentQBs.Split(new string[] { "~*~" }, StringSplitOptions.None);
            string[] amountReceived = amountsReceived.Split(new string[] { "~*~" }, StringSplitOptions.None);
            
            string message = "";
            for (int i = 0; i < paymentID.Length; i++)
            {
                try
                {
                    var resultRecord = Clients.AttachPaymentToInvoice(id, int.Parse(invoiceID), int.Parse(paymentID[i]), DateTime.Parse(paymentDate[i]), paymentQB[i], decimal.Parse(amountReceived[i]), true, m_UserID);

                    if (resultRecord == null) 
                    {
                        message = (message == "" ? "" : "\r\n") + message + "Failed to attach record.";
                    }
                }
                catch (Exception ex)
                {
                    message = (message == "" ? "" : "\r\n") + message + ex.Message;
                }
            }

            if (message != "")
            {
                return new JsonResult { Data = new { success = false, message = message, invoiceID = invoiceID, paymentIDs = paymentIDs, paymentDates = paymentDates, paymentQBs = paymentQBs, amountsReceived = amountsReceived } };
            }

            int BillingContactID = Clients.GetPrimaryBillingContactIDFromClient(id).Value;

            AccountActivity accountActivity = null;

            if (BillingContactID != 0)
            {
                accountActivity = BillingStatements.GetAccountActivity(BillingContactID, 0);
                List<BillingStatementRow> billingStatementRowsToKeep = new List<BillingStatementRow>();
                for (int i = 0; i < paymentID.Length; i++)
                {
                    try
                    {
                        var found = accountActivity.accountActivityRows.Find(delegate(BillingStatementRow find)
                        {
                            return paymentID[i] != "" &&
                                   find.PaymentID == paymentID[i];
                        });

                        if (found != null)
                        {
                            billingStatementRowsToKeep.Add(found);
                        }
                    }
                    catch (Exception ex)
                    {
                        message = (message == "" ? "" : "\r\n") + message + ex.Message;
                    }
                }

                try
                {
                    var found = accountActivity.accountActivityRows.Find(delegate(BillingStatementRow find)
                    {
                        return invoiceID != "" &&
                               find.InvoiceID == invoiceID;
                    });

                    if (found != null)
                    {
                        billingStatementRowsToKeep.Add(found);
                    }
                }
                catch (Exception ex)
                {
                    message = (message == "" ? "" : "\r\n") + message + ex.Message;
                }

                accountActivity.accountActivityRows = billingStatementRowsToKeep;
            }

            if (message != "")
            {
                return new JsonResult { Data = new { success = false, message = message, invoiceID = invoiceID, paymentIDs = paymentIDs, paymentDates = paymentDates, paymentQBs = paymentQBs, amountsReceived = amountsReceived } };
            }

            return new JsonResult { Data = new { success = true, accountActivity = accountActivity, invoiceID = invoiceID, paymentIDs = paymentIDs, paymentDates = paymentDates, paymentQBs = paymentQBs, amountsReceived = amountsReceived } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult AttachInvoiceToPaymentJSON(string clientID, string paymentID, string invoiceIDs, string invoiceNumbers, string invoiceDates, string invoiceQBs, string paymentSpents)
        {
            int id = 0;
            if (!int.TryParse(clientID, out id))
            {
                id = 0;
            }

            string[] invoiceID = invoiceIDs.Split(new string[] { "~*~" }, StringSplitOptions.None);
            string[] invoiceNumber = invoiceNumbers.Split(new string[] { "~*~" }, StringSplitOptions.None);
            string[] invoiceDate = invoiceDates.Split(new string[] { "~*~" }, StringSplitOptions.None);
            string[] invoiceQB = invoiceQBs.Split(new string[] { "~*~" }, StringSplitOptions.None);
            string[] paymentSpent = paymentSpents.Split(new string[] { "~*~" }, StringSplitOptions.None);

            string message = "";
            for (int i = 0; i < invoiceID.Length; i++) 
            {
                try
                {
                    var resultRecord = Clients.AttachInvoiceToPayment(id, int.Parse(paymentID), int.Parse(invoiceID[i]), invoiceNumber[i], DateTime.Parse(invoiceDate[i]), invoiceQB[i], decimal.Parse(paymentSpent[i]), true, m_UserID);

                    if (resultRecord == null)
                    {
                        message = (message == "" ? "" : "\r\n") + message + "Failed to attach record.";
                    }
                }
                catch (Exception ex) 
                {
                    message = (message == "" ? "" : "\r\n") + message + ex.Message;
                }
            }
                           
            if (message != "") 
            {
                return new JsonResult { Data = new { success = false, message = message, paymentID = paymentID, invoiceIDs = invoiceIDs, invoiceNumbers = invoiceNumbers, invoiceDates = invoiceDates, invoiceQBs = invoiceQBs, paymentSpents = paymentSpents } };
            }

            int BillingContactID = Clients.GetPrimaryBillingContactIDFromClient(id).Value;
            
            AccountActivity accountActivity = null;
            
            if (BillingContactID != 0)
            {
                accountActivity = BillingStatements.GetAccountActivity(BillingContactID, 0);
                List<BillingStatementRow> billingStatementRowsToKeep = new List<BillingStatementRow>();
                for (int i = 0; i < invoiceID.Length; i++)
                {
                    try
                    {
                        var found = accountActivity.accountActivityRows.Find(delegate(BillingStatementRow find) {
                            return invoiceID[i] != "" && 
                                    find.InvoiceID == invoiceID[i];
                        });

                        if (found != null) 
                        {
                            billingStatementRowsToKeep.Add(found);
                        }
                    }
                    catch (Exception ex)
                    {
                        message = (message == "" ? "" : "\r\n") + message + ex.Message;
                    }
                }

                try
                {
                    var found = accountActivity.accountActivityRows.Find(delegate(BillingStatementRow find)
                    {
                        return paymentID != "" &&
                               find.PaymentID == paymentID;
                    });

                    if (found != null)
                    {
                        billingStatementRowsToKeep.Add(found);
                    }
                }
                catch (Exception ex)
                {
                    message = (message == "" ? "" : "\r\n") + message + ex.Message;
                }

                accountActivity.accountActivityRows = billingStatementRowsToKeep;

            }

            if (message != "")
            {
                return new JsonResult { Data = new { success = false, message = message, paymentID = paymentID, invoiceIDs = invoiceIDs, invoiceNumbers = invoiceNumbers, invoiceDates = invoiceDates, invoiceQBs = invoiceQBs, paymentSpents = paymentSpents } };
            }

            return new JsonResult { Data = new { success = true, accountActivity = accountActivity, paymentID = paymentID, invoiceIDs = invoiceIDs, invoiceNumbers = invoiceNumbers, invoiceDates = invoiceDates, invoiceQBs = invoiceQBs, paymentSpents = paymentSpents } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult RemovePaymentJSON(string clientID, string paymentID)
        {
            int id = 0;
            if (!int.TryParse(clientID, out id))
            {
                id = 0;
            }
            
            string message = "";
                
            try
            {
                bool answer = Clients.RemovePayment(id, int.Parse(paymentID));

                if (!answer) 
                {
                    message = (message == "" ? "" : "\r\n") + message + "Could not delete payment. Make sure payment is not associated with any invoices.";                
                }

            }                
            catch (Exception ex)                
            {
                message = (message == "" ? "" : "\r\n") + message + ex.Message;
            }

            if (message != "")
            {
                return new JsonResult { Data = new { success = false, message = message, paymentID = paymentID } };
            }

            return new JsonResult { Data = new { success = true, paymentID = paymentID } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult PaymentToInvoiceSearchByAmountJSON(string clientID, string searchTerm)
        {
            int id = 0;
            if (!int.TryParse(clientID, out id))
            {
                id = 0;
            }

            var results = Clients.PaymentToInvoiceSearchByAmount(id, searchTerm);

            return new JsonResult { Data = new { success = true, results = results } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult PaymentToInvoiceSearchByDateJSON(string clientID, string searchTerm)
        {
            int id = 0;
            if (!int.TryParse(clientID, out id))
            {
                id = 0;
            }

            var results = Clients.PaymentToInvoiceSearchByDate(id, searchTerm);

            return new JsonResult { Data = new { success = true, results = results } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult PaymentToInvoiceSearchByIDJSON(string clientID, string searchTerm)
        {
            int id = 0;
            if (!int.TryParse(clientID, out id))
            {
                id = 0;
            }

            var results = Clients.PaymentToInvoiceSearchByID(id, searchTerm);

            return new JsonResult { Data = new { success = true, results = results } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult PaymentToInvoiceSearchByQBJSON(string clientID, string searchTerm)
        {
            int id = 0;
            if (!int.TryParse(clientID, out id))
            {
                id = 0;
            }

            var results = Clients.PaymentToInvoiceSearchByQB(id, searchTerm);

            return new JsonResult { Data = new { success = true, results = results } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult InvoiceToPaymentSearchByAmountJSON(string clientID, string searchTerm)
        {
            int id = 0;
            if (!int.TryParse(clientID, out id))
            {
                id = 0;
            }

            var results = Clients.InvoiceToPaymentSearchByAmount(id, searchTerm);

            return new JsonResult { Data = new { success = true, results = results } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult InvoiceToPaymentSearchByDateJSON(string clientID, string searchTerm)
        {
            int id = 0;
            if (!int.TryParse(clientID, out id))
            {
                id = 0;
            }

            var results = Clients.InvoiceToPaymentSearchByDate(id, searchTerm);

            return new JsonResult { Data = new { success = true, results = results } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult InvoiceToPaymentSearchByInvoiceNumberJSON(string clientID, string searchTerm)
        {
            int id = 0;
            if (!int.TryParse(clientID, out id))
            {
                id = 0;
            }

            var results = Clients.InvoiceToPaymentSearchByInvoiceNumber(id, searchTerm);

            return new JsonResult { Data = new { success = true, results = results } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult InvoiceToPaymentSearchByQBJSON(string clientID, string searchTerm)
        {
            int id = 0;
            if (!int.TryParse(clientID, out id))
            {
                id = 0;
            }

            var results = Clients.InvoiceToPaymentSearchByQB(id, searchTerm);

            return new JsonResult { Data = new { success = true, results = results } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public JsonResult SaveClientInfoJSON(int id, string ClientName, string Address1, string Address2, string City, string State, string Zip,
                                            int ParentClientID, string BilledAsClientName, string Status, int BillingGroupID, string notes ) //id = ClientID
        {
            System.Text.RegularExpressions.Regex nonUTF8 = new System.Text.RegularExpressions.Regex("[^\x00-\x7F]+");

            ClientName = ClientName == null ? "" : nonUTF8.Replace(ClientName, " ").SingleSpaceOnly();
            Address1 = Address1 == null ? "" : nonUTF8.Replace(Address1, " ").SingleSpaceOnly();
            Address2 = Address2 == null ? "" : nonUTF8.Replace(Address2, " ").SingleSpaceOnly();
            City = City == null ? "" : nonUTF8.Replace(City, " ").SingleSpaceOnly();
            State = State == null ? "" : nonUTF8.Replace(State, " ").SingleSpaceOnly();
            Zip = Zip == null ? "" : nonUTF8.Replace(Zip, " ").SingleSpaceOnly();
            BilledAsClientName = BilledAsClientName == null ? "" : nonUTF8.Replace(BilledAsClientName, " ").SingleSpaceOnly();

            bool AuditInvoices;
            bool DoNotInvoice;
            
            if (State.Length > 2) { return new JsonResult { Data = new { success = false } }; }

            if (ClientName.Length == 0) { return new JsonResult { Data = new { success = false } }; }

            if (BillingGroupID == 0) { DoNotInvoice = true; } else { DoNotInvoice = false; }

            if (BillingGroupID == 1 || BillingGroupID == 4) { AuditInvoices = true; } else { AuditInvoices = false; }

            int result = Clients.UpdateClientInfo(id, ClientName, Address1, Address2, City, State, Zip, ParentClientID, BilledAsClientName, Status, AuditInvoices, DoNotInvoice, BillingGroupID, notes);

            if (result == -1)
            {
                return new JsonResult { Data = new { success = false } };
            }
            else
            { 
                return new JsonResult { Data = new { success = true } };
            }
           
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public JsonResult CreateClientInvoiceSettingsJSON(int id, int InvoiceTemplate, int BillingDetailReport, int ClientSplitMode, bool ApplyFinanceCharges,
                                                          int FinChargeDays, decimal FinChargePct, bool SentToCollections, bool ExcludeFromReminders) //id = ClientID
        {
            Clients.CreateClientInvoiceSettings(id, InvoiceTemplate, ClientSplitMode, BillingDetailReport, false, ApplyFinanceCharges, FinChargeDays, FinChargePct, SentToCollections, ExcludeFromReminders);

            return new JsonResult { Data = new { success = true } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public JsonResult SaveClientInvoiceSettingsJSON(int id, int InvoiceTemplate, int BillingDetailReport, int ClientSplitMode, bool ApplyFinanceCharges, 
                                                        int FinChargeDays, decimal FinChargePct, bool SentToCollections, bool ExcludeFromReminders) //id = ClientID
        {

            Clients.UpdateClientInvoiceSettings(id, InvoiceTemplate, ClientSplitMode, BillingDetailReport, false, ApplyFinanceCharges, FinChargeDays, FinChargePct / 100, SentToCollections, ExcludeFromReminders);

            return new JsonResult { Data = new { success = true } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public JsonResult SaveExpectedRevenueSettingsJSON(int ClientID, string ExpectedMonthlyRevenue, string AccountCreateDate, string AccountOwner, string AffiliateName) //id = ClientID
        {
            if (String.IsNullOrEmpty(ExpectedMonthlyRevenue))
            {
                ExpectedMonthlyRevenue = "0.00";
            }

            Decimal decimalExpectedMonthlyRevenue = Decimal.Parse(ExpectedMonthlyRevenue);

            if (String.IsNullOrEmpty(AccountCreateDate))
            {
                AccountCreateDate = DateTime.Now.ToString("MM/dd/yyyy");
            }

            DateTime datetimeAccountCreateDate = DateTime.Parse(AccountCreateDate);

            Clients.SaveExpectedRevenueSettings(ClientID, decimalExpectedMonthlyRevenue, datetimeAccountCreateDate, AccountOwner, AffiliateName);

            return new JsonResult { Data = new { success = true } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public JsonResult RemoveClientInvoiceSettingsJSON(int id) //id = ClientID
        {
            Clients.RemoveClientInvoiceSettings(id);

            return new JsonResult { Data = new { success = true } };
        }

        public JsonResult RemoveParentRelationshipJSON(int id) //id= ClientID
        {
            Clients.RemoveParentRelationship(id);

            return new JsonResult { Data = new { success = true } };
        }

       
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        [HttpPost]
        public JsonResult SaveClientVendorSettingsJSON(int id, string tazworks1, string tazworks2, string debtor1, string transunion, string experian, string applicantone, string pembrooke, string RentTrack) //id = ClientID
        {
            int vendorid;
            string vendorclientnumber;

                vendorid = 1;
                vendorclientnumber = tazworks1;
                Clients.UpdateClientVendorSettings(id, vendorid, vendorclientnumber);            


                vendorid = 2;
                vendorclientnumber = tazworks2;
                Clients.UpdateClientVendorSettings(id, vendorid, vendorclientnumber);
 
            
                vendorid = 3;
                vendorclientnumber = debtor1;
                Clients.UpdateClientVendorSettings(id, vendorid, vendorclientnumber);

                vendorid = 4;
                vendorclientnumber = transunion;
                Clients.UpdateClientVendorSettings(id, vendorid, vendorclientnumber);

                vendorid = 5;
                vendorclientnumber = experian;
                Clients.UpdateClientVendorSettings(id, vendorid, vendorclientnumber);

                vendorid = 7;
                vendorclientnumber = applicantone;
                Clients.UpdateClientVendorSettings(id, vendorid, vendorclientnumber);

                vendorid = 8;
                vendorclientnumber = pembrooke;
                Clients.UpdateClientVendorSettings(id, vendorid, vendorclientnumber);

                vendorid = 9;
                vendorclientnumber = RentTrack;
                Clients.UpdateClientVendorSettings(id, vendorid, vendorclientnumber);

            return new JsonResult { Data = new { success = true } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        [HttpPost]
        public JsonResult GetClientsForDropdownJSON()
        {
            List<SelectListItem> clients = Clients.GetClientListForDropdown();

            var rows = clients.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public JsonResult GetClientsWithInvoicesForDropdownJSON()
        {
            List<SelectListItem> clients = Clients.GetClientsWithInvoicesForDropdown();

            var rows = clients.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [HttpPost]
        public JsonResult GetClientsBySplitModeForDropdownJSON(int SplitMode,DateTime StartDate, DateTime EndDate)
        {
            List<SelectListItem> clients = Clients.GetClientListBySplitModeForDropdown(SplitMode,StartDate, EndDate);

            var rows = clients.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };


        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        [HttpPost]
        public JsonResult GetClientsWithBillingContactsForDropdownJSON()
        {
            List<SelectListItem> clients = Clients.GetClientsWithBillingContactsForDropdown();

            var rows = clients.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }

        //Get a list of users for the specified client.  The list is formatted for use in a dropdown.
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public JsonResult GetUsersFromClientForDropdownJSON(int id) //id = ClientID
        {
            List<SelectListItem> users = Clients.GetUsersFromClientForDropdown(id);

            var rows = users.ToArray();

            return new JsonResult { Data = new { success = true, rows = rows } };
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public ActionResult SelectParentClient()
        {
            Clients_Details viewClients_Details = new Clients_Details();
            viewClients_Details.clientlist = Clients.GetClientListForDropdown();

            return View("SelectParentClient", viewClients_Details);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        public ActionResult CreateClient()
        {
            Clients_Details viewClients_Details = new Clients_Details();

            viewClients_Details.ClientName = "";
            viewClients_Details.Address1 = "";
            viewClients_Details.Address2 = "";
            viewClients_Details.City = "";
            viewClients_Details.State = "";
            viewClients_Details.Zip = "";
            viewClients_Details.ClientID = 0;
            viewClients_Details.Tazworks1Client = false;
            viewClients_Details.Tazworks2Client = false;
            viewClients_Details.NonTazworksClient = false;

            return View(viewClients_Details);
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public JsonResult CreateClientJSON(string ClientName, string Address1, string Address2, string City, string State, string Zip, bool Tazworks1Client, bool Tazworks2Client, bool NonTazworksClient) 
        {
            System.Text.RegularExpressions.Regex nonUTF8 = new System.Text.RegularExpressions.Regex("[^\x00-\x7F]+");

            ClientName = ClientName == null ? "" : nonUTF8.Replace(ClientName, " ").SingleSpaceOnly();
            Address1 = Address1 == null ? "" : nonUTF8.Replace(Address1, " ").SingleSpaceOnly();
            Address2 = Address2 == null ? "" : nonUTF8.Replace(Address2, " ").SingleSpaceOnly();
            City = City == null ? "" : nonUTF8.Replace(City, " ").SingleSpaceOnly();
            State = State == null ? "" : nonUTF8.Replace(State, " ").SingleSpaceOnly();
            Zip = Zip == null ? "" : nonUTF8.Replace(Zip, " ").SingleSpaceOnly();

            Clients_Details viewClients_Details = new Clients_Details();

            viewClients_Details.ClientName = ClientName;
            viewClients_Details.Address1 = Address1;
            viewClients_Details.Address2 = Address2;
            viewClients_Details.City = City;
            viewClients_Details.State = State;
            viewClients_Details.Zip = Zip;
            viewClients_Details.ClientID = 0;
            viewClients_Details.Tazworks1Client = Tazworks1Client;
            viewClients_Details.Tazworks2Client = Tazworks2Client;
            viewClients_Details.NonTazworksClient = NonTazworksClient;


            if (String.IsNullOrEmpty(ClientName))
            {
                ViewData.ModelState.AddModelError("ClientName", " ");
                viewClients_Details.ClientName = "";
            }

            if (String.IsNullOrEmpty(Address1))
            {
                ViewData.ModelState.AddModelError("Address1", " ");
                viewClients_Details.Address1 = "";
            }

            if (String.IsNullOrEmpty(Address2))
            {
                viewClients_Details.Address2 = "";
            }

            if (String.IsNullOrEmpty(City))
            {
                ViewData.ModelState.AddModelError("City", " ");
                viewClients_Details.City = "";
            }

            if (String.IsNullOrEmpty(State))
            {
                ViewData.ModelState.AddModelError("State", " ");
                viewClients_Details.State = "";
            }

            if (String.IsNullOrEmpty(Zip))
            {
                ViewData.ModelState.AddModelError("Zip", " ");
                viewClients_Details.Zip = "";
            }

            if (!Tazworks1Client && !Tazworks2Client && !NonTazworksClient)
            {
                ViewData.ModelState.AddModelError("TazworksClient", "You must select at least 1 Tazworks system or select Non-Tazworks Client. ");
            }

            if (ViewData.ModelState.IsValid)
            {

                viewClients_Details.ClientID = Clients.CreateClient(ClientName, Address1, Address2, City, State, Zip, Tazworks1Client, Tazworks2Client, NonTazworksClient);

                if (viewClients_Details.ClientID == 0)
                {
                    return new JsonResult
                    {
                        Data = new
                        {
                            success = false,
                            view = RenderToString.RenderViewToString(this, "CreateClient", viewClients_Details)
                        }
                    };
                }
                else
                {
                    return new JsonResult
                    {
                        Data = new
                        {
                            success = true,
                            clientid = viewClients_Details.ClientID
                        }
                    };
                }
            }
            else
            {
                return new JsonResult
                {
                    Data = new
                    {
                        success = false,
                        view = RenderToString.RenderViewToString(this, "CreateClient", viewClients_Details)
                    }
                };
            }
        }


        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public ActionResult ClientAccountActivity(int id) //id = ClientID
        {
            int BillingContactID = Clients.GetPrimaryBillingContactIDFromClient(id).Value;

            Clients_Details viewBillingStatement_AccountActivity = new Clients_Details();
            viewBillingStatement_AccountActivity.AccountActivity = BillingStatements.GetAccountActivity(BillingContactID, 0);

            return View(viewBillingStatement_AccountActivity);
        }

    }
}
