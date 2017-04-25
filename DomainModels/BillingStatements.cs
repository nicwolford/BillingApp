using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ScreeningONE.Models;

namespace ScreeningONE.DomainModels
{
    public class BillingStatements
    {
        public static BillingStatement GetCurrentBillingStatement(int _BillingContactID, DateTime _StartDate, DateTime _EndDate)
        {
            BillingStatement billingStatement = new BillingStatement(_BillingContactID, _StartDate, _EndDate);

            return billingStatement;
        }

        public static AccountActivity GetAccountActivity(int _BillingContactID, int _UserID)
        {
            AccountActivity accountActivity = new AccountActivity(_BillingContactID, _UserID);

            return accountActivity;
        }


        public static AccountActivity GetAccountActivityForAnInvoiceIDAndPaymentID(int _BillingContactID, int _UserID, int _InvoiceID, int _PaymentID)
        {
            AccountActivity accountActivity = new AccountActivity(_BillingContactID, _UserID, _InvoiceID, _PaymentID);

            return accountActivity;
        }

        //Get primary and secondary contacts
        public static List<BillingStatement> GetBillingStatementList(DateTime _StartDate, DateTime _EndDate, int _BillingGroup)
        {
            List<BillingStatement> listOfBillingStatements = new List<BillingStatement>();

            BillingStatementDataContext dc = new BillingStatementDataContext();
            var result = dc.S1_BillingStatement_GetBillingStatementList(_StartDate, _EndDate, _BillingGroup);

            foreach (var item in result)
            {
                BillingStatement tempBillingStatement = new BillingStatement();

                tempBillingStatement.billingContact.ClientContactID = item.ClientContactID;
                tempBillingStatement.billingContact.ClientContactName = item.ContactName;
                tempBillingStatement.billingContact.BillingContactID = item.BillingContactID;
                tempBillingStatement.BillingContactName = item.ContactName;
                tempBillingStatement.ContactEmail = item.ContactEmail;
                tempBillingStatement.DeliveryMethod = item.DeliveryMethod;
                tempBillingStatement.ClientName = item.BillAsClientName;
                tempBillingStatement.LastPrinted = item.LastPrintedOn;
                tempBillingStatement.Amount = (item.Amount.HasValue ? item.Amount.Value : 0);
                tempBillingStatement.billingContact.ClientContactAddress1 = item.Amount.Value.ToString("F");
                tempBillingStatement.CurrentActivity = (item.CurrentActivity == 1 ? "Yes" : (item.CurrentActivity == 2 ? "Audit" : (item.CurrentActivity == 3 ? "Secondary" : "No")));

                //Only get primary contacts
                //if (item.PrimaryBillingContact.HasValue && item.PrimaryBillingContact.Value)
                listOfBillingStatements.Add(tempBillingStatement);
            }

            return listOfBillingStatements;
        }

        //Gets a list of InvoiceID's for the current invoices in the Billing Statement
        public static List<CurrentInvoice> GetBillingStatementListCurrentInvoices(int _BillingContactID, DateTime _StartDate, DateTime _EndDate)
        {
            List<CurrentInvoice> invoicesList = new List<CurrentInvoice>();
            BillingStatementDataContext dc = new BillingStatementDataContext();
            var result = dc.S1_BillingStatement_GetBillingStatementListCurrentInvoices(_BillingContactID, _StartDate, _EndDate);

            foreach (var item in result)
            {
                CurrentInvoice tempInvoice = new CurrentInvoice();
                tempInvoice.InvoiceID = item.InvoiceID;
                tempInvoice.IsPrimaryBillingContact = (item.PrimaryBillingContact.HasValue ? item.PrimaryBillingContact.Value : true);

                invoicesList.Add(tempInvoice);
            }

            return invoicesList;
        }

        //Same as GetBillingStatementList, except that it is filtered by UserID
        public static List<BillingStatement> GetBillingStatementListFromUser(int _UserID, DateTime _StartDate, DateTime _EndDate)
        {
            List<BillingStatement> listOfBillingStatements = new List<BillingStatement>();

            BillingStatementDataContext dc = new BillingStatementDataContext();
            var result = dc.S1_BillingStatement_GetBillingStatementListFromUser(_UserID, _StartDate, _EndDate);

            foreach (var item in result)
            {
                BillingStatement tempBillingStatement = new BillingStatement();

                tempBillingStatement.billingContact.ClientContactID = item.ClientContactID;
                tempBillingStatement.billingContact.BillingContactID = item.BillingContactID;
                tempBillingStatement.billingContact.DueText = item.StatementDate.Value.ToString("MM/dd/yyyy");
                tempBillingStatement.billingContact.ClientContactName = item.ContactName;
                tempBillingStatement.billingContact.BillingContactName = item.ClientName;
                tempBillingStatement.billingContact.ClientContactAddress1 = item.Amount.Value.ToString("F");

                listOfBillingStatements.Add(tempBillingStatement);
            }

            return listOfBillingStatements;
        }

        //Add a row to the BillingPackagePrinted table
        public static void AddBillingPackagePrinted(int _BillingContactID, DateTime _PacakgeEndDate, int _PrintedByUser)
        {
            BillingStatementDataContext dc = new BillingStatementDataContext();
            dc.S1_BillingStatement_AddBillingPackagePrinted(_BillingContactID, _PacakgeEndDate, _PrintedByUser);
        }

        //Add a row to the BillingPackagePrinted table with GUID
        public static void AddBillingPackagePrintedGUID(int _BillingContactID, DateTime _PacakgeEndDate, int _PrintedByUser, string _ActionGUID)
        {
            BillingStatementDataContext dc = new BillingStatementDataContext();
            dc.S1_BillingStatement_AddBillingPackagePrintedGUID(_BillingContactID, _PacakgeEndDate, _PrintedByUser, _ActionGUID);
        }

        //Lookup one BillingPackagePrinted record by GUID
        public static BillingPackagePrinted GetBilingPackagePrintedFromGUID(Guid _EmailGuid)
        {
            BillingStatementDataContext dc = new BillingStatementDataContext();
            var result = dc.S1_BillingStatement_GetBillingPackagePrintedFromGUID(_EmailGuid).SingleOrDefault();

            if (result != null)
            {
                return new BillingPackagePrinted(result.BillingPackagePrintedID, result.BillingContactID, result.PackageEndDate, result.PrintedOn, 
                    result.PrintedByUser, result.EmailGuid.Value);
            }
            else
            {
                return new BillingPackagePrinted();
            }
        }

        //Check to see if the billing contact provided is in the special split group of billing contacts as a primary.
        public static int GetSpecialPrimaryBillingContact(int _BillingContactID)
        {
            BillingStatementDataContext dc = new BillingStatementDataContext();
            var result = dc.S1_BillingStatement_GetSpecialPrimaryBillingContact(_BillingContactID).SingleOrDefault();

            if (result != null)
            {
                return 1;
            }
            else
            {
                return 0;
            }
        }

        public static List<StatementEmail> GetStatementEmail(int _BillingContactID)
        {
            string ReturnURL = System.Configuration.ConfigurationManager.AppSettings["DefaultPath"] + "/BillingStatement/PrintPackageToPDF_Public/";

            List<StatementEmail> emailStatements = new List<StatementEmail>();
            BillingStatementDataContext dc = new BillingStatementDataContext();

            var result = dc.S1_BillingStatement_GetStatementEmail(_BillingContactID);
            foreach (var item in result)
            {
                var db1 = new UsersDataContext();
                var results1 = db1.S1_Users_CreateMessageWithAction(5, "Statement AutoEmail", item.UserID, 1, 0, 3, HttpUtility.UrlDecode(ReturnURL), System.DateTime.Now, null).SingleOrDefault();

                if (results1.ActionGUID != null)
                {

                    StatementEmail emailStatement = new StatementEmail(item.ClientName, item.LoweredEmail, item.UserID, results1.ActionGUID.ToString());

                    emailStatements.Add(emailStatement);
                }
            }

            return emailStatements;
        }
    }

    public class BillingPackagePrinted
    {
        public int BillingPackagePrintedID { get; set; }
        public int BillingContactID {get; set;}
        public DateTime PackageEndDate { get; set; }
        public DateTime PrintedOn { get; set; }
        public int PrintedByUser {get; set;}
        public Guid EmailGuid {get; set;}

        public BillingPackagePrinted()
        {
            BillingContactID = 0;
        }

        public BillingPackagePrinted(int _BillingPackagePrintedID, int _BillingContactID, DateTime _PackageEndDate, DateTime _PrintedOn, int _PrintedByUser, 
            Guid _EmailGuid)
        {
            BillingPackagePrintedID = _BillingPackagePrintedID;
            BillingContactID = _BillingContactID;
            PackageEndDate = _PackageEndDate;
            PrintedOn = _PrintedOn;
            PrintedByUser = _PrintedByUser;
            EmailGuid = _EmailGuid;
        }
    }

    public class AccountActivity
    {
        public List<BillingStatementRow> accountActivityRows;

        public AccountActivity()
        {
            accountActivityRows = new List<BillingStatementRow>();
        }

        public AccountActivity(int _BillingContactID, int _UserID)
        {
            accountActivityRows = new List<BillingStatementRow>();

            BillingStatementDataContext dc = new BillingStatementDataContext();
            var result = dc.S1_BillingStatement_GetBillingActivity(_BillingContactID, _UserID);

            foreach (var item in result)
            {
                decimal Balance = (Math.Abs(item.Amount.GetValueOrDefault()) - item.TotalAmountSpent.GetValueOrDefault() - item.TotalAmountReceived.GetValueOrDefault()) - (item.CreditSpent.GetValueOrDefault() + item.CreditReceived.GetValueOrDefault());

                BillingStatementRow accountActivityRow = new BillingStatementRow(item.Date, item.InvoiceNumber, item.Type, item.Amount.Value, item.LinkID, item.InvoiceList,
                                                                                 item.InvoiceDateList, item.PaymentSpentAmountList, item.IQBTransactionIDList, item.PtiQBTransactionIDList, 
                                                                                 item.PaymentList, item.PaymentDateList, item.AmountReceivedList, item.PQBTransactionIDList, item.ItpQBTransactionIDList, 
                                                                                 (item.InvoiceID.HasValue ? item.InvoiceID.Value.ToString() : ""), (item.PaymentID.HasValue ? item.PaymentID.Value.ToString() : ""), 
                                                                                 item.InvoiceNumberList, (item.TotalAmountSpent.HasValue ? item.TotalAmountSpent.Value.ToString("f2") : ""),
                                                                                 (item.TotalAmountReceived.HasValue ? item.TotalAmountReceived.Value.ToString("f2") : ""), Balance, item.CreditReceived.GetValueOrDefault(), item.CreditSpent.GetValueOrDefault());

                accountActivityRows.Add(accountActivityRow);
            }
        }

        public AccountActivity(int _BillingContactID, int _UserID, int _InvoiceID, int _PaymentID)
        {
            accountActivityRows = new List<BillingStatementRow>();

            BillingStatementDataContext dc = new BillingStatementDataContext();
            var result = dc.S1_BillingStatement_GetBillingActivityForAnInvoiceIDAndPaymentID(_BillingContactID, _UserID, _InvoiceID, _PaymentID);

            foreach (var item in result)
            {
                decimal Balance = (Math.Abs(item.Amount.GetValueOrDefault()) - item.TotalAmountSpent.GetValueOrDefault() - item.TotalAmountReceived.GetValueOrDefault()) - (item.CreditSpent.GetValueOrDefault() + item.CreditReceived.GetValueOrDefault());

                BillingStatementRow accountActivityRow = new BillingStatementRow(item.Date, item.InvoiceNumber, item.Type, item.Amount.Value, item.LinkID, item.InvoiceList,
                                                                                 item.InvoiceDateList, item.PaymentSpentAmountList, item.IQBTransactionIDList, item.PtiQBTransactionIDList,
                                                                                 item.PaymentList, item.PaymentDateList, item.AmountReceivedList, item.PQBTransactionIDList, item.ItpQBTransactionIDList,
                                                                                 (item.InvoiceID.HasValue ? item.InvoiceID.Value.ToString() : ""), (item.PaymentID.HasValue ? item.PaymentID.Value.ToString() : ""),
                                                                                 item.InvoiceNumberList, (item.TotalAmountSpent.HasValue ? item.TotalAmountSpent.Value.ToString("f2") : ""),
                                                                                 (item.TotalAmountReceived.HasValue ? item.TotalAmountReceived.Value.ToString("f2") : ""), Balance, item.CreditReceived.GetValueOrDefault(), item.CreditSpent.GetValueOrDefault());

                accountActivityRows.Add(accountActivityRow);
            }
        }

    }

    public class BillingStatement
    {
        public List<BillingStatementRow> billingStatementRows;
        public ClientContact billingContact;
        public string ClientName;
        public DateTime? LastPrinted;
        public decimal Amount;
        public string CurrentActivity;
        public string BillingContactName;
        public string ContactEmail;
        public string DeliveryMethod;

        public BillingStatement()
        {
            billingStatementRows = new List<BillingStatementRow>();
            billingContact = new ClientContact();
        }

        public BillingStatement(int _BillingContactID, DateTime _StartDate, DateTime _EndDate)
        {
            billingStatementRows = new List<BillingStatementRow>();

            BillingStatementDataContext dc = new BillingStatementDataContext();
            var result = dc.S1_BillingStatement_GetCurrentStatement(_BillingContactID, _StartDate, _EndDate);

            foreach (var item in result)
            {
                BillingStatementRow billingStatementRow = new BillingStatementRow(item.Date, item.InvoiceNumber, 
                    item.Type, item.Amount.Value, item.LinkID);

                billingStatementRows.Add(billingStatementRow);
            }

            ClientContactsDataContext ccdc = new ClientContactsDataContext();
            billingContact = ClientContacts.GetClientContactFromBillingContactID(_BillingContactID);
        }
    }

    public class BillingStatementRow
    {
        public DateTime? Date;
        public string InvoiceNumber;
        public string Type;
        public decimal Amount;
        public int LinkID;
        public string InvoiceList;
        public string InvoiceDateList;
        public string PaymentSpentAmountList;
        public string IQBTransactionIDList;
        public string PtiQBTransactionIDList;
        public string PaymentList;
        public string PaymentDateList;
        public string AmountReceivedList;
        public string PQBTransactionIDList;
        public string ItpQBTransactionIDList;
        public string InvoiceID;
        public string PaymentID;
        public string InvoiceNumberList;
        public string TotalAmountSpent;
        public string TotalAmountReceived;
        public decimal Balance;
        public decimal CreditReceived;
        public decimal CreditSpent;

        public BillingStatementRow(DateTime? _Date, string _InvoiceNumber, string _Type, decimal _Amount, int _LinkID)
        {
            Date = _Date;
            InvoiceNumber = _InvoiceNumber;
            Type = _Type;
            Amount = _Amount;
            LinkID = _LinkID;
        }

        public BillingStatementRow(DateTime? _Date, string _InvoiceNumber, string _Type, decimal _Amount, int _LinkID, string _InvoiceList, string _InvoiceDateList, 
                                   string _PaymentSpentAmountList, string _IQBTransactionIDList, string _PtiQBTransactionIDList, string _PaymentList, string _PaymentDateList, 
                                   string _AmountReceivedList, string _PQBTransactionIDList, string _ItpQBTransactionIDList, string _InvoiceID, string _PaymentID,
                                    string _InvoiceNumberList, string _TotalAmountSpent, string _TotalAmountReceived, decimal _Balance, decimal _CreditReceived, decimal _CreditSpent)
        {
            Date = _Date;
            InvoiceNumber = _InvoiceNumber;
            Type = _Type;
            Amount = _Amount;
            LinkID = _LinkID;
            InvoiceList = _InvoiceList;
            InvoiceDateList = _InvoiceDateList;
            PaymentSpentAmountList = _PaymentSpentAmountList;
            IQBTransactionIDList = _IQBTransactionIDList;
            PtiQBTransactionIDList = _PtiQBTransactionIDList;
            PaymentList = _PaymentList;
            PaymentDateList = _PaymentDateList;
            AmountReceivedList = _AmountReceivedList;
            PQBTransactionIDList = _PQBTransactionIDList;
            ItpQBTransactionIDList = _ItpQBTransactionIDList;
            InvoiceID = _InvoiceID;
            PaymentID = _PaymentID;
            InvoiceNumberList = _InvoiceNumberList;
            TotalAmountSpent = _TotalAmountSpent;
            TotalAmountReceived = _TotalAmountReceived;
            Balance = _Balance;
            CreditReceived = _CreditReceived;
            CreditSpent = _CreditSpent;
        }

    }

    public class StatementEmail
    {
        public string ClientName;
        public string ContactEmail;
        public int EmailUserID;
        public string ActionGUID;

        public StatementEmail(string _ClientName, string _ContactEmail, int _EmailUserID, string _ActionGUID)
        {
            ClientName = _ClientName;
            ContactEmail = _ContactEmail;
            EmailUserID = _EmailUserID;
            ActionGUID = _ActionGUID;

        }
    }

    public class CurrentInvoice
    {
        public int InvoiceID { get; set; }
        public bool IsPrimaryBillingContact { get; set; }
    }
}
