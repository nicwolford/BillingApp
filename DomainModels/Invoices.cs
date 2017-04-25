//#define DEBUG_EMAIL

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using ScreeningONE.Models;
using ScreeningONE.Objects;
using System.Configuration;

namespace ScreeningONE.DomainModels
{
    public class Invoices
    {
        public static List<Invoice> GetForDateRange(DateTime _StartDate, DateTime _EndDate, int _ClientID, int _BillingContactID, bool _BillingContactForAnyClient,
            int _DeliveryMethod, int _ReleaseStatus, string _InvoiceNumber, int _CurrentPage, int _RowsPerPage, string _OrderBy, bool _OrderDir,bool _AuditOnlyClients)
        {
            int? nClientID;
            int? nBillingContactID;
            int? nDeliveryMethod;
            int? nReleaseStatus;

            //Convert 0 to null for the Stored Procedure
            if (_ClientID != 0) { nClientID = _ClientID; } else { nClientID = null; }
            //Convert 0 to null for the Stored Procedure
            if (_BillingContactID != 0) { nBillingContactID = _BillingContactID; } else { nBillingContactID = null; }
            //Convert -1 to null for the Stored Procedure
            if (_DeliveryMethod != -1) { nDeliveryMethod = _DeliveryMethod; } else { nDeliveryMethod = null; }
            //Convert -1 to null for the Stored Procedure
            if (_ReleaseStatus != -1) { nReleaseStatus = _ReleaseStatus; } else { nReleaseStatus = null; }

            List<Invoice> invoicesList = new List<Invoice>();

            InvoicesDataContext dc = new InvoicesDataContext();
            
            if (_AuditOnlyClients)
            {
                var result = dc.S1_Invoices_GetInvoices_DateRange_Paged_AuditOnly(_StartDate, _EndDate, nClientID, nBillingContactID,
                _BillingContactForAnyClient, nDeliveryMethod, nReleaseStatus, _InvoiceNumber, _CurrentPage, _RowsPerPage, _OrderBy, _OrderDir);

                foreach (var item in result)
                {
                    Invoice tempInvoice = new Invoice(item.InvoiceID, item.InvoiceNumber, item.InvoiceDate, item.InvoiceTypeDesc,
                        item.Amount, item.ClientName, item.ContactName, "", "", "", "", "", item.OriginalAmount, "", "", "", "", "", "",
                        "", "", 0, "", "", "", 0, "", item.ReleasedStatusText, item.Number.Value, 0, 0, 0, 0, 0);

                    invoicesList.Add(tempInvoice);
                }

            }
            else
            {
                var result = dc.S1_Invoices_GetInvoices_DateRange_Paged(_StartDate, _EndDate, nClientID, nBillingContactID,
                _BillingContactForAnyClient, nDeliveryMethod, nReleaseStatus, _InvoiceNumber, _CurrentPage, _RowsPerPage, _OrderBy, _OrderDir);

                foreach (var item in result)
                {
                    Invoice tempInvoice = new Invoice(item.InvoiceID, item.InvoiceNumber, item.InvoiceDate, item.InvoiceTypeDesc,
                        item.Amount, item.ClientName, item.ContactName, "", "", "", "", "", item.OriginalAmount, "", "", "", "", "", "",
                        "", "", 0, "", "", "", 0, "", item.ReleasedStatusText, item.Number.Value, 0, 0, 0, 0, 0);

                    invoicesList.Add(tempInvoice);
                }

            }
            

            return invoicesList;
        }

        public static List<SelectListItem> GetReferenceSplitContactsForDropdown(int _ClientID)
        {
            List<SelectListItem> referenceSplitContactsList = new List<SelectListItem>();

            var db = new InvoicesDataContext();
            var result = db.S1_Invoices_GetReferenceSplitContacts(_ClientID);
            foreach (var item in result)
            {
                SelectListItem listitem = new SelectListItem();
                listitem.Value = item.InvoiceSplitID.ToString();
                listitem.Text = item.ContactName;
                referenceSplitContactsList.Add(listitem);
            }

            return referenceSplitContactsList;

        }

        public static List<Invoice> GetAllForBililngContactID(int _BililngContactID, int _UserID)
        {
            List<Invoice> invoicesList = new List<Invoice>();

            InvoicesDataContext dc = new InvoicesDataContext();
            var result = dc.S1_Invoices_GetInvoicesFromBillingContactID(_BililngContactID, _UserID);

            foreach (var item in result)
            {
                Invoice tempInvoice = new Invoice(item.InvoiceID, item.InvoiceNumber, item.InvoiceDate, item.InvoiceTypeDesc,
                    item.Amount, item.ClientName, item.ContactName, "", "", "", "", "", item.OriginalAmount, "", "", "", "", "", "",
                    "", "", 0, "", "", "", 0, "", "", 0, 0, 0, 0, 0, 0);

                invoicesList.Add(tempInvoice);
            }

            return invoicesList;
        }

        //Get one Invoice by InvoiceID
        public static Invoice GetInvoice(int _InvoiceID)
        {
            InvoicesDataContext dc = new InvoicesDataContext();
            var result = dc.S1_Invoices_GetInvoice(_InvoiceID).SingleOrDefault();
            var result2 = dc.S1_Invoices_GetInvoicePaymentsAndCredits(_InvoiceID).SingleOrDefault();

            Invoice invoice = new Invoice(result.InvoiceID, result.InvoiceNumber, result.InvoiceDate, result.InvoiceTypeDesc,
                result.Amount, result.ClientName, result.ContactName, result.ContactAddress1, result.ContactAddress2,
                result.ContactCity, result.ContactStateCode, result.ContactZIP, 0, result.Col1Header, result.Col2Header, 
                result.Col3Header, result.Col4Header, result.Col5Header, result.Col6Header, result.Col7Header, result.Col8Header, 
                result.NumberOfColumns, result.BillTo, result.POName, result.PONumber, result.BillingReportGroupID, result.DueText, 
                "", 0, result.ClientID, result.BillingContactID, result.RelatedInvoiceID, result.BillingGroup.Value, 
                (result2.PaymentsAndCredits.HasValue ? result2.PaymentsAndCredits.Value : 0));

            return invoice;
        }

        public static List<InvoiceLine> GetInvoiceLines(int _InvoiceID)
        {
            List<InvoiceLine> invoiceLines = new List<InvoiceLine>();

            InvoicesDataContext dc = new InvoicesDataContext();
            var result = dc.S1_Invoices_GetInvoicesLines(_InvoiceID);

            int maxInvoiceLineNumber = 0;
            foreach (var item in result)
            {
                InvoiceLine tempInvoiceLine = new InvoiceLine(item.InvoiceLineNumber, item.Col1Text, item.Col2Text, item.Col3Text, 
                    item.Col4Text, item.Col5Text, item.Col6Text, item.Col7Text, item.Col8Text, item.Amount);

                invoiceLines.Add(tempInvoiceLine);
                maxInvoiceLineNumber = item.InvoiceLineNumber;
            }

            int linesPerPage = 24;
            int numberOfPages = (int)Math.Ceiling((decimal)(maxInvoiceLineNumber / linesPerPage));

            //Pad lines
           /* for (int curLine = 0; curLine < linesPerPage - (maxInvoiceLineNumber % linesPerPage); curLine++)
            {
                InvoiceLine tempInvoiceLine = new InvoiceLine(maxInvoiceLineNumber + curLine + 1, "", "", "", "", "", "", "", "", 0);

                invoiceLines.Add(tempInvoiceLine);
            }*/

            return invoiceLines;
        }

        //Update the 8 text fields in an invoice line row
        public static void UpdateInvoiceLineText(int _InvoiceID, int _InvoiceLineNumber, string _Col1Text, string _Col2Text, string _Col3Text, string _Col4Text,
            string _Col5Text, string _Col6Text, string _Col7Text, string _Col8Text)
        {
            InvoicesDataContext dc = new InvoicesDataContext();
            dc.S1_Invoices_UpdateInvoiceLineText(_InvoiceID, _InvoiceLineNumber, _Col1Text, _Col2Text, _Col3Text, _Col4Text, _Col5Text, _Col6Text, _Col7Text, 
                _Col8Text);
        }

        //Auto-generate invoices
        public static void CreateInvoices(DateTime _StartTransactionDate, DateTime _EndTransactionDate, DateTime _InvoiceDate,
            int _BillingGroup)
        {
            InvoicesDataContext dc = new InvoicesDataContext();
            dc.CommandTimeout = 300000;
            dc.S1_Invoices_CreateInvoices(_StartTransactionDate, _EndTransactionDate, _InvoiceDate, _BillingGroup);
        }

        //Auto-generate invoices for client
        public static void CreateInvoicesForClient(DateTime _StartTransactionDate, DateTime _EndTransactionDate, DateTime _InvoiceDate,
            int _ClientID)
        {
            InvoicesDataContext dc = new InvoicesDataContext();
            dc.CommandTimeout = 300000;
            dc.S1_Invoices_CreateInvoicesForClient(_StartTransactionDate, _EndTransactionDate, _InvoiceDate, _ClientID);
        }

        //Auto-generate invoices
        public static void SQLJobCreateInvoices(DateTime _StartTransactionDate, DateTime _EndTransactionDate, DateTime _InvoiceDate,
            int _BillingGroup, int _UserId)
        {
            InvoicesDataContext dc = new InvoicesDataContext();
            dc.S1_Invoices_SQLJobCreateInvoices(_StartTransactionDate, _EndTransactionDate, _InvoiceDate, _BillingGroup, _UserId);
        }

        //Auto-generate invoices for client
        public static void SQLJobCreateInvoicesForClient(DateTime _StartTransactionDate, DateTime _EndTransactionDate, DateTime _InvoiceDate,
            int _ClientID, int _UserId)
        {
            InvoicesDataContext dc = new InvoicesDataContext();
            dc.S1_Invoices_SQLJobCreateInvoicesForClient(_StartTransactionDate, _EndTransactionDate, _InvoiceDate, _ClientID, _UserId);
        }

        //Return the number of invoices to export that have a NULL value in the BillAsClientName field
        public static int GetCountOfExportInvoicesWithNullBillAsClientName()
        {
            InvoicesDataContext dc = new InvoicesDataContext();

            int? tempInt = dc.S1_Invoices_GetCountOfExportInvoicesWithNullBillAsClientName().SingleOrDefault().Column1;
            if (tempInt.HasValue)
                return tempInt.Value;
            else
                return 0;           
        }

        //Get a list of invoice to export to QuickBooks
        public static List<Invoice> GetExportInvoices()
        {
            List<Invoice> exportInvoices = new List<Invoice>();
            InvoicesDataContext dc = new InvoicesDataContext();

            var result = dc.S1_Invoices_GetExportInvoices();
            foreach (var item in result)
            {
                Invoice exportInvoice = new Invoice();

                exportInvoice.ClientName = item.BillAsClientName;
                exportInvoice.BillTo = item.ClientName;
                exportInvoice.InvoiceAmount = item.Amount;
                exportInvoice.InvoiceDate = item.InvoiceDate;
                exportInvoice.InvoiceNumber = item.InvoiceNumber;

                exportInvoices.Add(exportInvoice);
            }

            return exportInvoices;
        }

        //Get a collection of invoices containing Finance Charge
        public static List<Invoice> GetExportFinanceCharges()
        {
            List<Invoice> exportInvoices = new List<Invoice>();
            InvoicesDataContext dc = new InvoicesDataContext();

            var result = dc.S1_Invoices_GetExportFinanceCharges();
            foreach (var item in result)
            {
                Invoice exportInvoice = new Invoice();

                exportInvoice.ClientName = item.BillAsClientName;
                exportInvoice.InvoiceAmount = item.Amount;
                exportInvoice.InvoiceDate = item.InvoiceDate;
                exportInvoice.InvoiceNumber = item.InvoiceNumber;

                exportInvoices.Add(exportInvoice);
            }

            return exportInvoices;
        }

        //Get a collection of invoices containing Credit Memos
        public static List<Invoice> GetExportCreditMemos()
        {
            List<Invoice> exportInvoices = new List<Invoice>();
            InvoicesDataContext dc = new InvoicesDataContext();

            var result = dc.S1_Invoices_GetExportCreditMemos();
            foreach (var item in result)
            {
                Invoice exportInvoice = new Invoice();

                exportInvoice.ClientName = item.BillAsClientName;
                exportInvoice.InvoiceAmount = item.Amount;
                exportInvoice.InvoiceDate = item.InvoiceDate;
                exportInvoice.InvoiceNumber = item.InvoiceNumber;

                exportInvoices.Add(exportInvoice);
            }

            return exportInvoices;
        }

        //Void one invoice, reset ProductTransactions so they can be invoiced again
        public static void VoidInvoice(int id, int _UserID) //id = InvoiceID
        {
            InvoicesDataContext dc = new InvoicesDataContext();
            dc.S1_Invoices_VoidInvoice(id, _UserID);
        }

        //Set an individual invoice as exported
        public static void SetInvoiceAsExported(string _InvoiceNumber, string _QBTransactionID)
        {
            InvoicesDataContext dc = new InvoicesDataContext();
            dc.S1_Invoices_SetInvoiceAsExported(_InvoiceNumber, _QBTransactionID);
        }

        public static void CreateQuickBooksExportError(string _ErrorText)
        {
            InvoicesDataContext dc = new InvoicesDataContext();
            dc.S1_Invoices_CreateQuickBooksExportError(_ErrorText);
        }

        //Get a list of Billing Groups for Dropdown
        public static List<SelectListItem> GetBillingGroupList()
        {
            List<SelectListItem> billingGroupList = new List<SelectListItem>();

            InvoicesDataContext dc = new InvoicesDataContext();
            var result = dc.S1_Invoices_GetBillingGroupsList();

            foreach (var item in result)
            {
                SelectListItem newItem = new SelectListItem();
                newItem.Value = item.BillingGroupID.ToString();
                newItem.Text = item.BillingGroupName;

                billingGroupList.Add(newItem);
            }

            return billingGroupList;
        }
               

        //Get a list of the invoices that require finance charges
        public static List<NewFinanceCharge> GetInvoicesToCreateFinanceChargesFor(DateTime _FinanceChargeDate)
        {
            List<NewFinanceCharge> newFinanceCharges = new List<NewFinanceCharge>();

            InvoicesDataContext dc = new InvoicesDataContext();
            var result = dc.S1_Invoices_GetInvoicesToCreateFinanceChargesFor(_FinanceChargeDate);

            foreach (var item in result)
            {
                NewFinanceCharge newItem = new NewFinanceCharge(item.InvoiceID, item.InvoiceNumber, item.InvoiceDate, item.ClientName, item.ClientID,
                    item.OriginalInvoiceAmount, 
                    (item.InvoiceAmountDue.HasValue ? item.InvoiceAmountDue.Value : 0), 
                    (item.PaymentAmount.HasValue ? item.PaymentAmount.Value : 0),
                    (item.FinanceChargeAmount.HasValue ? item.FinanceChargeAmount.Value : 0));
                
                newFinanceCharges.Add(newItem);
            }

            return newFinanceCharges;
        }

        //Add one finance charge
        public static void CreateFinanceCharge(DateTime _FinanceChargeDate, int _InvoiceID, int _CreateInvoicesBatchID)
        {
            InvoicesDataContext dc = new InvoicesDataContext();
            dc.S1_Invoices_CreateFinanceCharge(_FinanceChargeDate, _InvoiceID, _CreateInvoicesBatchID);
        }

        //Release an invoice
        public static int ReleaseInvoice(int _InvoiceID)
        {
            InvoicesDataContext dc = new InvoicesDataContext();
            var result = dc.S1_Invoices_GetReleaseInvoiceGroup(_InvoiceID).ToList();

            bool hasOpenInvoice = false;
            if (result != null)
            {
                foreach (var item in result)
                {
                    if (item.Released == 0)
                        hasOpenInvoice = true;
                }

                if (hasOpenInvoice)
                {
                    //set invoice to pending
                    dc.S1_Invoices_ReleasePendingInvoice(_InvoiceID);

                    return -1; //do not send invoice release email
                }
                else
                {
                    var ListToEmail = dc.S1_Invoices_GetReleaseInvoiceGroupToEmail(_InvoiceID).ToList();
                    //int loop = 0;
                    int email_primary = 0;
                    List<int> email_cc_list = new List<int>();
                    string email_to = string.Empty;
                    string email_subject = ConfigurationManager.AppSettings["CompanyName"] + " Billing: Your Online Invoice Is Available.";
                    string email_message = string.Empty;
                    int email_cc = 0;

                    foreach (var item in ListToEmail)
                    {

                        // build the primary
                        if (item.IsPrimaryBillingContact.HasValue && item.IsPrimaryBillingContact.Value == true)
                        {
                            // add the primary
                            email_to = item.ContactEmail;
                            email_primary = item.UserID.Value;
                        }
                        else
                        {
                            // add the secondary
                            if (item.UserID.Value > 0)
                            {
                                if (email_cc == 0)
                                {
                                    email_cc = item.UserID.Value;
                                    email_cc_list.Add(item.UserID.Value);
                                }
                                else 
                                {
                                    email_cc = item.UserID.Value;
                                    email_cc_list.Add(item.UserID.Value);
                                }
                            }
                        }

                    }

                    if (email_primary != 0)
                    {
                        Dictionary<string, string> messagevalues = new Dictionary<string, string>();
                        //messagevalues.Add("[[COMPANYNAME]]", item.ClientName);
                        messagevalues.Add("[[InvoiceDate]]", DateTime.Now.ToString("MMMM yyyy"));
                        messagevalues.Add("[[GUIDURL]]", System.Configuration.ConfigurationManager.AppSettings["DefaultPath"]);
                        messagevalues.Add("[[CORPORATENAME]]", System.Configuration.ConfigurationManager.AppSettings["CompanyName"]);
                        messagevalues.Add("[[CORPORATEPHONE]]", System.Configuration.ConfigurationManager.AppSettings["billingphone"]);
                        messagevalues.Add("[[CORPORATEEMAIL]]", System.Configuration.ConfigurationManager.AppSettings["BillingEmail"]);

                        MailGun.SendEmailToUserFromTemplate(0, 0, "Invoice Release", 0, email_primary, 0, email_subject, messagevalues);
                        /*
                        var messageRecord = Messages.GetMessageTemplateRecord(0, "Invoice Release", messagevalues);

                        string messagebody = messageRecord != null ? messageRecord.MessageText : null;

                        if (messagebody != null)
                        {
                            int messageActionType = messageRecord.MessageActionTypeID.GetValueOrDefault();
                            int? MessageIDOutput = new int?();
                            Guid? MessageActionGuidOutput = new Guid?();

                            Messages.CreateMessageWithAction(messageActionType, email_subject, messagebody, email_primary, 1, 0, 3, "", System.DateTime.Now, null, "HTML", ref MessageIDOutput, ref MessageActionGuidOutput);
                            Messages.UpdateMessageAndMarkForSending(MessageIDOutput.Value, email_subject, messagebody);

                            foreach (int ccuserid in email_cc_list)
                            {
                                if (ccuserid != 0)
                                {
                                    messageActionType = messageRecord.MessageActionTypeID.GetValueOrDefault();
                                    MessageIDOutput = new int?();
                                    MessageActionGuidOutput = new Guid?();
                                    Messages.CreateMessageWithAction(messageActionType, email_subject, messagebody, ccuserid, 1, 0, 3, "", System.DateTime.Now, null, "HTML", ref MessageIDOutput, ref MessageActionGuidOutput);
                                    Messages.UpdateMessageAndMarkForSending(MessageIDOutput.Value, email_subject, messagebody);
                                }
                            }
                        }
                        else
                        {
                            //todoo: future error logging
                        }
                        */

                        // send the email


                        //set all invoices in the group and the incoming _InvoiceID to released
                        dc.S1_Invoices_ReleaseInvoice(_InvoiceID); //This releases the original email which is not contained in the result from S1_Invoices_GetReleaseInvoiceGroup
                        foreach (var item in result)
                        {
                            if (_InvoiceID != item.InvoiceID)
                            {
                                dc.S1_Invoices_ReleaseInvoice(item.InvoiceID);
                            }
                        }
                    }
                    else
                    {
                        dc.S1_Invoices_ReleaseInvoice(_InvoiceID); 
                        foreach (var item in result)
                        {
                            if (_InvoiceID != item.InvoiceID)
                            {
                                dc.S1_Invoices_ReleaseInvoice(item.InvoiceID);
                            }
                        }
                        return 0; //send invoice release email
                    }
                    return 1; //send 1 invoice release email for the group
                }
      
            }
            else //there are no associated open invoices
            {
                //release the invoice
                dc.S1_Invoices_ReleaseInvoice(_InvoiceID);
                return 0; //send invoice release email
            }
                        
        }




        //Get a list of related invoices that could hold up the release of the selected invoice
        public static List<Invoice> GetRelatedInvoices(int _InvoiceID)
        {
            List<Invoice> relatedInvoices = new List<Invoice>();

            InvoicesDataContext dc = new InvoicesDataContext();
            var result = dc.S1_Invoices_GetPendingReleaseInvoiceGroup(_InvoiceID);

            foreach (var item in result)
            {
                Invoice invoice = new Invoice();

                invoice.BillingContactName = item.Contact;
                invoice.InvoiceID = item.InvoiceID;
                invoice.InvoiceNumber = item.InvoiceNumber;
                invoice.ReleasedStatus = item.ReleasedStatusText;

                relatedInvoices.Add(invoice);
            }

            return relatedInvoices;
        }

        //Get a list of unpaid invoices for a selected billing contact
        public static List<Invoice> GetUnpaidInvoicesForBillingContact(int _BillingContactID)
        {
            List<Invoice> invoicesList = new List<Invoice>();

            InvoicesDataContext dc = new InvoicesDataContext();
            var result = dc.S1_Invoices_GetUnpaidInvoicesFromBillingContactID(_BillingContactID);

            foreach (var item in result)
            {
                Invoice tempInvoice = new Invoice(item.InvoiceID, item.InvoiceNumber, item.InvoiceDate, item.InvoiceTypeDesc,
                    item.Amount, item.ClientName, item.ContactName, "", "", "", "", "", item.OriginalAmount, "", "", "", "", "", "",
                    "", "", 0, "", "", "", 0, "", "", 0, 0, 0, 0, 0, 0);

                invoicesList.Add(tempInvoice);
            }

            return invoicesList;
        }

        //Use the GetUnpaidInvoicesForBillingContact function to create a Dropdown list for the Create New Credit screen
        public static List<SelectListItem> GetUnpaidInvoicesForBillingContactForDropdown(int _BillingContactID)
        {
            List<SelectListItem> selectItems = new List<SelectListItem>();

            var result = GetUnpaidInvoicesForBillingContact(_BillingContactID);
            foreach (var item in result)
            {
                SelectListItem tempItem = new SelectListItem();
                tempItem.Text = item.InvoiceNumber + " - " + item.InvoiceDate.ToString("MM/dd/yyyy");
                tempItem.Value = item.InvoiceID.ToString();
                selectItems.Add(tempItem);
            }

            return selectItems;
        }

        //Add a new credit
        public static void CreateNewCredit(DateTime _InvoiceDate, decimal _InvoiceAmount, string _PublicDescription,
            string _PrivateDescription, int _BillingContactID, int _RelatedInvoiceID)
        {
            InvoicesDataContext dc = new InvoicesDataContext();

            dc.S1_Invoices_CreateCredit(_InvoiceDate, _InvoiceAmount, _PublicDescription, _PrivateDescription, _BillingContactID, _RelatedInvoiceID);            
        }

        //Modify a new credit
        public static void ModifyCredit(int _InvoiceID, DateTime _InvoiceDate, decimal _InvoiceAmount, string _PublicDescription,
            string _PrivateDescription, int _BillingContactID, int _RelatedInvoiceID)
        {
            InvoicesDataContext dc = new InvoicesDataContext();

            dc.S1_Invoices_ModifyCredit(_InvoiceID, _InvoiceDate, _InvoiceAmount, _PublicDescription, _PrivateDescription, _BillingContactID, _RelatedInvoiceID);
        }

        //Create Payment
        public static int CreateOrUpdatePayment(DateTime _PaymentDate, decimal _PaymentAmount, int _BillingContactID, int _PaymentMethodID,
            string _CheckNumber, string _QBTransactionID)
        {
            InvoicesDataContext dc = new InvoicesDataContext();

            var result = dc.S1_Invoices_CreatePayment(_PaymentDate, _PaymentAmount, _BillingContactID, _PaymentMethodID, _CheckNumber, 
                _QBTransactionID).SingleOrDefault().PaymentID;

            if (result != null && result.HasValue)
            {
                return Convert.ToInt32(result.Value);
            }
            else
            {
                return -1;
            }
        }

        //Create an invoice payment - This will connect an invoice to a payment
        public static int CreateOrUpdateInvoicePayment(int _PaymentID, string _ReferenceNumber, decimal _Amount, string _QBTransactionID, int _BillingContactID)
        {
            InvoicesDataContext dc = new InvoicesDataContext();
            var result = dc.S1_Invoices_CreateInvoicePayment(_PaymentID, _ReferenceNumber, _Amount, _QBTransactionID, _BillingContactID).SingleOrDefault().InvoicePaymentID;

            if (result.HasValue)
                return result.Value;
            else
                return -1;
        }

        public static List<InvoiceEmail> GetInvoiceEmail(int _InvoiceID)
        {
            List<InvoiceEmail> emailInvoices = new List<InvoiceEmail>();
            InvoicesDataContext dc = new InvoicesDataContext();

            var result = dc.S1_Invoices_GetInvoiceEmail(_InvoiceID);
            foreach (var item in result)
            {
                InvoiceEmail emailInvoice = new InvoiceEmail(item.ClientName, item.LoweredEmail, item.InvoiceDate, item.UserID);

                emailInvoices.Add(emailInvoice);
            }

            return emailInvoices;
        }

        //Used for getting the InvoiceID from an InvoiceNumber
        public static Invoice GetInvoiceFromInvoiceNumber(string _InvoiceNumber, int _BillingContactID)
        {
            var dc = new InvoicesDataContext();
            var item = dc.S1_Invoices_GetInvoiceFromInvoiceNumber(_InvoiceNumber, _BillingContactID).SingleOrDefault();
            if (item != null)
            {
                return new Invoice(item.InvoiceID, item.InvoiceNumber, item.InvoiceDate, "",
                        item.Amount, "", "", "", "", "", "", "", item.Amount, "", "", "", "", "", "",
                        "", "", 0, "", "", "", 0, "", "", 0, 0, 0, 0, 0, 0);
            }
            else
            {
                return null;
            }
        }

        public static void MarkCreditsAsLinked()
        {
            InvoicesDataContext db = new InvoicesDataContext();
            db.S1_Invoices_MarkCreditsAsLinked();
        }

        //Get the date of the most recent QB Payments update
        public static DateTime QBExport_GetLastPaymentUpdateDate()
        {
            var dc = new InvoicesDataContext();
            var result = dc.S1_Invoices_GetLastQBPaymentsUpdateDate().SingleOrDefault();

            if (result != null)
            {
                return (result.LastUpdateDate.HasValue ? result.LastUpdateDate.Value : new DateTime(2010, 1, 2));
            }
            else
            {
                return new DateTime(2010, 1, 2);
            }
        }

        //Add a step to the QBExportLog table
        public static void QBExport_AddNextStep(int _StepNumber)
        {
            var dc = new InvoicesDataContext();
            dc.S1_Invoices_QBExportLog_AddNextStep(_StepNumber);
        }

        //Get last step from the QBExportLog table
        public static int QBExport_GetLastStep()
        {
            var dc = new InvoicesDataContext();
            var result = dc.S1_Invoices_QBExportLog_GetLastStep().SingleOrDefault();

            if (result != null)
                return result.ExportStep;
            else return 0;
        }

        //Add a row to the QBExportLinkCredits table
        public static void QBExportLinkCredits_AddCredit(string creditInvoiceNumber)
        {
            var dc = new InvoicesDataContext();
            dc.S1_Invoices_QBExportLinkCredits_AddCredit(creditInvoiceNumber);
        }

        public static void QBExportLog_DeleteExportStep(int ExportLogID)
        {
            var dc = new InvoicesDataContext();
            dc.S1_Invoices_QBExportLog_DeleteExportStep(ExportLogID);
        }

        public static List<Invoice> QBExportLinkCredits_GetCreditsWithMissingRelatedInvoiceTxnIDs()
        {
            List<Invoice> invoicesList = new List<Invoice>();
            var dc = new InvoicesDataContext();
            var result = dc.S1_Invoices_QBExportLinkCredits_GetCreditsWithMissingRelatedInvoiceTxnIDs();

            foreach (var item in result)
            {
                Invoice tempInvoice = new Invoice(item.InvoiceID, item.InvoiceNumber, DateTime.Now, "",
                    0, "", "", "", "", "", "", "", 0, "", "", "", "", "", "",
                    "", "", 0, "", "", "", 0, "", "", 0, 0, 0, 0, 0, 0);

                invoicesList.Add(tempInvoice);
            }

            return invoicesList;            
        }

        public static void SetInvoiceTxnID(string _InvoiceNumber, string _TxnID)
        {
            var dc = new InvoicesDataContext();
            dc.S1_Invoices_SetInvoiceTxnID(_InvoiceNumber, _TxnID);
        }

        public static List<Invoice> QBExportLinkCredits_GetCreditsToLink()
        {
            List<Invoice> invoicesList = new List<Invoice>();
            var dc = new InvoicesDataContext();
            var result = dc.S1_Invoices_QBExportLinkCredits_GetCreditsToLink();

            foreach (var item in result)
            {
                Invoice tempInvoice = new Invoice(0, item.CreditMemoTxnID, DateTime.Now, item.InvoiceTxnID,
                    item.Amount, item.BillAsClientName, "", "", "", "", "", "", 0, "", "", "", "", "", "",
                    "", "", 0, "", "", "", 0, "", "", 0, 0, 0, 0, 0, 0);

                invoicesList.Add(tempInvoice);
            }

            return invoicesList;
        }

        //Get a list of all rows in descending order
        public static List<QBExportLog> QBExportLog_GetAll()
        {
            List<QBExportLog> exportLog = new List<QBExportLog>();
            var dc = new InvoicesDataContext();
            var result = dc.S1_Invoices_QBExportLog_GetAll();

            foreach (var item in result)
            {
                QBExportLog tempItem = new QBExportLog(item.QBExportLogID, item.ExportStep, item.ExportTime, item.ExportTimeString);

                exportLog.Add(tempItem);
            }

            return exportLog; 
        }

        public static List<InvoiceVerifySetups> GetInvoiceVerifySetups(DateTime _StartTransactionDate, DateTime _EndTransactionDate, 
            DateTime _InvoiceDate, int _BillingGroup)
        {
            List<InvoiceVerifySetups> invoiceVerifySetups = new List<InvoiceVerifySetups>();

            var dc = new InvoicesDataContext();
            dc.CommandTimeout = 500;
            var result = dc.S1_Invoices_CreateInvoicesVerify(_StartTransactionDate, _EndTransactionDate, 
                _InvoiceDate, _BillingGroup);

            foreach (var item in result)
            {
                InvoiceVerifySetups tempItem = new InvoiceVerifySetups(item.DataSetName, item.ClientID, item.ClientName, item.ProductID,
                    item.ProductName);
                invoiceVerifySetups.Add(tempItem);
            }

            return invoiceVerifySetups;
        }

        public static List<InvoiceVerifySetupsForClient> GetInvoiceVerifySetupsForClient(DateTime _StartTransactionDate, DateTime _EndTransactionDate,
            DateTime _InvoiceDate, int _ClientID)
        {
            List<InvoiceVerifySetupsForClient> invoiceVerifySetupsForClient = new List<InvoiceVerifySetupsForClient>();

            var dc = new InvoicesDataContext();
            dc.CommandTimeout = 500;
            var result = dc.S1_Invoices_CreateInvoicesVerifyForClient(_StartTransactionDate, _EndTransactionDate,
                _InvoiceDate, _ClientID);

            foreach (var item in result)
            {
                InvoiceVerifySetupsForClient tempItem = new InvoiceVerifySetupsForClient(item.DataSetName, item.ClientID, item.ClientName, item.ProductID,
                    item.ProductName);
                invoiceVerifySetupsForClient.Add(tempItem);
            }

            return invoiceVerifySetupsForClient;
        }

        public static List<S1_Invoices_GetPaymentsForInvoiceBalancerResult> GetPaymentsForInvoiceBalancer(int _ClientID, DateTime? _StartDate, DateTime? _EndDate)
        {
            using (InvoicesDataContext dc = new InvoicesDataContext())
            {
                return dc.S1_Invoices_GetPaymentsForInvoiceBalancer(_ClientID, _StartDate, _EndDate).ToList();
            }
        }

        public static List<S1_Invoices_SendCurrentInvoiceReminderResult> SendCurrentInvoiceReminder()
        {
            using (InvoicesDataContext dc = new InvoicesDataContext())
            {
                return dc.S1_Invoices_SendCurrentInvoiceReminder().ToList();
            }
        }

        public static List<S1_Invoices_PreviewCurrentInvoiceReminderResult> PreviewCurrentInvoiceReminder(int? fromUserId, string messageSubject, string messageText)
        {
            using (InvoicesDataContext dc = new InvoicesDataContext())
            {
                return dc.S1_Invoices_PreviewCurrentInvoiceReminder(fromUserId, messageSubject, messageText).ToList();
            }
        }


        public static List<S1_Invoices_CurrentInvoiceRemindersSentResult> CurrentInvoiceRemindersSent()
        {
            using (InvoicesDataContext dc = new InvoicesDataContext())
            {
                return dc.S1_Invoices_CurrentInvoiceRemindersSent().ToList();
            }
        }

        public static List<S1_Invoices_CurrentInvoiceRemindersToSendResult> CurrentInvoiceRemindersToSend()
        {
            using (InvoicesDataContext dc = new InvoicesDataContext())
            {
                return dc.S1_Invoices_CurrentInvoiceRemindersToSend().ToList();
            }
        }

        public static void RemovePreviewMessageForCurrentInvoice(Guid messageGuid)
        {
            using (InvoicesDataContext dc = new InvoicesDataContext())
            {
                dc.S1_Invoices_RemovePreviewMessageForCurrentInvoice(messageGuid);
            }
        }

        public static void TruncateCurrentInvoiceReminder()
        {
            using (InvoicesDataContext dc = new InvoicesDataContext())
            {
                dc.S1_Invoices_TruncateCurrentInvoiceReminder();
            }
        }

        public static List<S1_Invoices_SendOverdueInvoiceReminderResult> SendOverdueInvoiceReminder()
        {
            using (InvoicesDataContext dc = new InvoicesDataContext())
            {
                return dc.S1_Invoices_SendOverdueInvoiceReminder().ToList();
            }
        }

        public static List<S1_Invoices_PreviewOverdueInvoiceReminderResult> PreviewOverdueInvoiceReminder(int? fromUserId, string messageSubject, string messageText, DateTime? userFinanceChargeDate)
        {
            using (InvoicesDataContext dc = new InvoicesDataContext())
            {
                return dc.S1_Invoices_PreviewOverdueInvoiceReminder(fromUserId, messageSubject, messageText, userFinanceChargeDate).ToList();
            }
        }

        public static List<S1_Invoices_OverdueInvoiceRemindersSentResult> OverdueInvoiceRemindersSent()
        {
            using (InvoicesDataContext dc = new InvoicesDataContext())
            {
                return dc.S1_Invoices_OverdueInvoiceRemindersSent().ToList();
            }
        }

        public static List<S1_Invoices_OverdueInvoiceRemindersToSendResult> OverdueInvoiceRemindersToSend()
        {
            using (InvoicesDataContext dc = new InvoicesDataContext())
            {
                return dc.S1_Invoices_OverdueInvoiceRemindersToSend().ToList();
            }
        }

        public static void RemovePreviewMessageForOverdueInvoice(Guid messageGuid)
        {
            using (InvoicesDataContext dc = new InvoicesDataContext())
            {
                dc.S1_Invoices_RemovePreviewMessageForOverdueInvoice(messageGuid);
            }
        }

        public static void TruncateOverdueInvoiceReminder()
        {
            using (InvoicesDataContext dc = new InvoicesDataContext())
            {
                dc.S1_Invoices_TruncateOverdueInvoiceReminder();
            }
        }

    }

    public class QBExportLog
    {
        public int QBExportLogID { get; set; }
        public int ExportStep { get; set; }
        public DateTime ExportTime { get; set; }
        public string ExportTimeString { get; set; }

        public QBExportLog() 
        {
        
        }

        public QBExportLog(int _QBExportLogID, int _ExportStep, DateTime _ExportTime, string _ExportTimeString)
        {
            QBExportLogID = _QBExportLogID;
            ExportStep = _ExportStep;
            ExportTime = _ExportTime;
            ExportTimeString = _ExportTimeString;
        }
    }

    public class InvoiceVerifySetups
    {
        public string DataSetName { get; set; }
        public int ClientID { get; set; }
        public string ClientName { get; set; }
        public int ProductID { get; set; }
        public string ProductName { get; set; }
        
        public InvoiceVerifySetups() {}

        public InvoiceVerifySetups(string _DataSetName, int _ClientID, string _ClientName, int _ProductID, string _ProductName) 
        {
            DataSetName = _DataSetName;
            ClientID = _ClientID;
            ClientName = _ClientName;
            ProductID = _ProductID;
            ProductName = _ProductName;
        }
        
    }
   

    public class InvoiceVerifySetupsForClient
    {
        public string DataSetName { get; set; }
        public int ClientID { get; set; }
        public string ClientName { get; set; }
        public int ProductID { get; set; }
        public string ProductName { get; set; }

        public InvoiceVerifySetupsForClient() { }

        public InvoiceVerifySetupsForClient(string _DataSetName, int _ClientID, string _ClientName, int _ProductID, string _ProductName)
        {
            DataSetName = _DataSetName;
            ClientID = _ClientID;
            ClientName = _ClientName;
            ProductID = _ProductID;
            ProductName = _ProductName;
        }
    }

    public class Invoice
    {
        public int InvoiceID;
        public string InvoiceNumber;
        public DateTime InvoiceDate;
        public string InvoiceTypeDesc;
        public decimal InvoiceAmount;
        public decimal OriginalAmount;
        public string BillTo;
        public string ClientName;
        public string BillingContactName;
        public string BillingContactAddress1;
        public string BillingContactAddress2;
        public string BillingContactCity;
        public string BillingContactStateCode;
        public string BillingContactZIP;
        public string ServicesDate;
        public string POName;
        public string PONumber;
        public int BillingReportGroupID;
        public string DueText;
        public int NumberOfColumns;
        public string ReleasedStatus;
        public int TotalNumberOfRows;
        public int ClientID;
        public int BillingContactID;
        public int RelatedInvoiceID;
        public int BillingGroup;
        public decimal PaymentsAndCredits;
       public List<string> ColumnHeaders;

       public Invoice()
       {

       }

        public Invoice(int _InvoiceID, string _InvoiceNumber, DateTime _InvoiceDate, string _InvoiceTypeDesc, decimal? _InvoiceAmount,
            string _ClientName, string _BillingContactName, string _BillingContactAddress1, string _BillingContactAddress2,
            string _BillingContactCity, string _BillingContactStateCode, string _BillingContactZIP, decimal _OriginalAmount,
            string _Col1Header, string _Col2Header, string _Col3Header, string _Col4Header, string _Col5Header, string _Col6Header, 
            string _Col7Header, string _Col8Header, int _NumberOfColumns, string _BillTo, string _POName, string _PONumber,
            int _BillingReportGroupID, string _DueText, string _ReleasedStatus, int _TotalNumberOfRows, int _ClientID,
            int _BillingContactID, int _RelatedInvoiceID, int _BillingGroup, decimal _PaymentsAndCredits)
        {
            InvoiceID = _InvoiceID;
            InvoiceNumber = _InvoiceNumber;
            InvoiceDate = _InvoiceDate;
            InvoiceTypeDesc = _InvoiceTypeDesc;
            InvoiceAmount = (_InvoiceAmount.HasValue ? _InvoiceAmount.Value : 0);
            ClientName = _ClientName;
            BillingContactName = _BillingContactName;
            OriginalAmount = _OriginalAmount;
            BillingContactAddress1 = _BillingContactAddress1;
            BillingContactAddress2 = _BillingContactAddress2;
            BillingContactCity = _BillingContactCity;
            BillingContactStateCode = _BillingContactStateCode;
            BillingContactZIP = _BillingContactZIP;
            ServicesDate = InvoiceDate.AddMonths(-1).ToShortDateString() + " - " + InvoiceDate.AddDays(-1).ToShortDateString();
            NumberOfColumns = _NumberOfColumns;
            ColumnHeaders = new List<string>();
            ColumnHeaders.Add(_Col1Header);
            ColumnHeaders.Add(_Col2Header);
            ColumnHeaders.Add(_Col3Header);
            ColumnHeaders.Add(_Col4Header);
            ColumnHeaders.Add(_Col5Header);
            ColumnHeaders.Add(_Col6Header);
            ColumnHeaders.Add(_Col7Header);
            ColumnHeaders.Add(_Col8Header);
            BillTo = _BillTo;
            POName = _POName;
            PONumber = _PONumber;
            BillingReportGroupID = _BillingReportGroupID;
            DueText = _DueText;
            ReleasedStatus = _ReleasedStatus;
            TotalNumberOfRows = _TotalNumberOfRows;
            ClientID = _ClientID;
            BillingContactID = _BillingContactID;
            RelatedInvoiceID = _RelatedInvoiceID;
            BillingGroup = _BillingGroup;
            PaymentsAndCredits = _PaymentsAndCredits;
        }
    }

    public class InvoiceLine
    {
        public int LineNumber;
        public List<string> Columns;
        public decimal Amount;

        public InvoiceLine(int _LineNumber, string _Col1Text, string _Col2Text, string _Col3Text, string _Col4Text,
                    string _Col5Text, string _Col6Text, string _Col7Text, string _Col8Text, decimal? _Amount)
        {
            Columns = new List<string>();

            LineNumber = _LineNumber;
            Columns.Add(_Col1Text);
            Columns.Add(_Col2Text);
            Columns.Add(_Col3Text);
            Columns.Add(_Col4Text);
            Columns.Add(_Col5Text);
            Columns.Add(_Col6Text);
            Columns.Add(_Col7Text);
            Columns.Add(_Col8Text);
            Amount = (_Amount.HasValue ? _Amount.Value : 0);
        }
    }

    public class NewFinanceCharge
    {
        public int InvoiceID;
        public string InvoiceNumber;
        public DateTime InvoiceDate;
        public string ClientName;
        public int ClientID;
        public decimal OriginalInvoiceAmount;
        public decimal InvoiceAmountDue;
        public decimal PaymentAmount;
        public decimal FinanceChargeAmount;

        public NewFinanceCharge() { }

        public NewFinanceCharge(int _InvoiceID, string _InvoiceNumber, DateTime _InvoiceDate, string _ClientName, int _ClientID, decimal _OriginalInvoiceAmount,
            decimal _InvoiceAmountDue, decimal _PaymentAmount, decimal _FinanceChargeAmount)
        {
            InvoiceID = _InvoiceID;
            InvoiceNumber = _InvoiceNumber;
            InvoiceDate = _InvoiceDate;
            ClientName = _ClientName;
            ClientID = _ClientID;
            OriginalInvoiceAmount = _OriginalInvoiceAmount;
            InvoiceAmountDue = _InvoiceAmountDue;
            PaymentAmount = _PaymentAmount;
            FinanceChargeAmount = _FinanceChargeAmount;
        }
    }

    public class InvoiceEmail
    {
        public string ClientName;
        public string ContactEmail;
        public DateTime InvoiceDate;
        public int EmailUserID;

        public InvoiceEmail(string _ClientName, string _ContactEmail, DateTime _InvoiceDate, int _EmailUserID)
        {
            ClientName = _ClientName;
            ContactEmail = _ContactEmail;
            InvoiceDate = _InvoiceDate;
            EmailUserID = _EmailUserID;

        }
    }

    public class PaymentContactForBalancer
    {
        public PaymentContactForBalancer() 
        {
            this.ClientContactID = "";
            this.BillingContactID = "";
            this.ContactLastName = "";
            this.ContactFirstName = "";
            this.IsPaymentContact = "";
            this.PaymentID = "";
            this.ClientID = "";
        }

        public PaymentContactForBalancer(string clientContactID, 
                                         string billingContactID, 
                                         string contactLastName, 
                                         string contactFirstName, 
                                         string isPaymentContact,
                                         string paymentID,
                                         string clientID)
        {
            this.ClientContactID = clientContactID;
            this.BillingContactID = billingContactID;
            this.ContactLastName = contactLastName;
            this.ContactFirstName = contactFirstName;
            this.IsPaymentContact = isPaymentContact;
            this.PaymentID = paymentID;
            this.ClientID = clientID;
        }

        public string ClientContactID { get; set; }
        public string BillingContactID { get; set; }
        public string ContactLastName { get; set; }
        public string ContactFirstName { get; set; }
        public string IsPaymentContact { get; set; }
        public string PaymentID { get; set; }
        public string ClientID { get; set; }

    }

    public class PaymentForBalancer
    {
        public PaymentForBalancer() 
        { 
            this.RootParentClientID = "";
            this.ParentClientID = "";
            this.ParentClientName = "";
            this.ClientID = "";
            this.ClientName = "";
            this.PaymentID = "";
            this.Date = "";
            this.TotalAmount = "";
            this.PaymentMethodID = "";
            this.CheckNumber = "";
            this.QBTransactionID = "";
            this.ClientContacts = new List<PaymentContactForBalancer>();
            this.Invoices = new List<InvoiceForBalancer>();
        }

        public PaymentForBalancer(string rootParentClientID,
                                  string parentClientID,
                                  string parentClientName,
                                  string clientID,
                                  string clientName,
                                  string paymentID,
                                  string date,
                                  string totalAmount,
                                  string paymentMethodID,
                                  string checkNumber,
                                  string qBTransactionID,
                                  List<PaymentContactForBalancer> clientContacts,
                                  List<InvoiceForBalancer> invoices)
        {
            this.RootParentClientID = rootParentClientID;
            this.ParentClientID = parentClientID;
            this.ParentClientName = parentClientName;
            this.ClientID = clientID;
            this.ClientName = clientName;
            this.PaymentID = paymentID;
            this.Date = date;
            this.TotalAmount = totalAmount;
            this.PaymentMethodID = paymentMethodID;
            this.CheckNumber = checkNumber;
            this.QBTransactionID = qBTransactionID;
            this.ClientContacts = clientContacts;
            this.Invoices = invoices;
        }

        public string RootParentClientID { get; set; }
        public string ParentClientID { get; set; }
        public string ParentClientName { get; set; }
        public string ClientID { get; set; }
        public string ClientName { get; set; }
        public string PaymentID { get; set; }
        public string Date { get; set; }
        public string TotalAmount { get; set; }
        public string PaymentMethodID { get; set; }
        public string CheckNumber { get; set; }
        public string QBTransactionID { get; set; }
        public List<PaymentContactForBalancer> ClientContacts { get; set; }
        public List<InvoiceForBalancer> Invoices { get; set; }
    }

    public class InvoiceForBalancer
    {
        public InvoiceForBalancer()
        {
            this.InvoiceID = "";
            this.InvoiceNumber = "";
            this.InvoiceDate = "";
            this.InvoiceTypeID = "";
            this.BillTo = "";
            this.POName = "";
            this.PONumber = "";
            this.Amount = "";
            this.InvoiceExported = "";
            this.InvoiceExportedOn = "";
            this.RelatedInvoiceID = "";
            this.DontShowOnStatement = "";
            this.IsPaymentInvoice = "";
            this.PaymentID = "";
            this.ClientID = "";
            this.IpQBTransactionID = "";
            this.IpAmount = "";
        }

        public InvoiceForBalancer(string invoiceID,
                                  string invoiceNumber,
                                  string invoiceDate,
                                  string invoiceTypeID,
                                  string billTo,
                                  string pOName,
                                  string pONumber,
                                  string amount,
                                  string invoiceExported,
                                  string invoiceExportedOn,
                                  string relatedInvoiceID,
                                  string dontShowOnStatement,
                                  string isPaymentInvoice,
                                  string paymentID,
                                  string clientID,
                                  string ipQBTransactionID,
                                  string ipAmount)
        {
            this.InvoiceID = invoiceID;
            this.InvoiceNumber = invoiceNumber;
            this.InvoiceDate = invoiceDate;
            this.InvoiceTypeID = invoiceTypeID;
            this.BillTo = billTo;
            this.POName = pOName;
            this.PONumber = pONumber;
            this.Amount = amount;
            this.InvoiceExported = invoiceExported;
            this.InvoiceExportedOn = invoiceExportedOn;
            this.RelatedInvoiceID = relatedInvoiceID;
            this.DontShowOnStatement = dontShowOnStatement;
            this.IsPaymentInvoice = isPaymentInvoice;
            this.PaymentID = paymentID;
            this.ClientID = clientID;
            this.IpQBTransactionID = ipQBTransactionID;
            this.IpAmount = ipAmount;
        }

        public string InvoiceID { get; set; }
        public string InvoiceNumber { get; set; }
        public string InvoiceDate { get; set; }
        public string InvoiceTypeID { get; set; }
        public string BillTo { get; set; }
        public string POName { get; set; }
        public string PONumber { get; set; }
        public string Amount { get; set; }
        public string InvoiceExported { get; set; }
        public string InvoiceExportedOn { get; set; }
        public string RelatedInvoiceID { get; set; }
        public string DontShowOnStatement { get; set; }
        public string IsPaymentInvoice { get; set; }
        public string PaymentID { get; set; }
        public string ClientID { get; set; }
        public string IpQBTransactionID { get; set; }
        public string IpAmount { get; set; }
    }

}
