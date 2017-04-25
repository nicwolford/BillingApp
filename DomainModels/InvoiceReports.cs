using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ScreeningONE.Models;

namespace ScreeningONE.DomainModels
{
    public class InvoiceReports
    {
        public static List<InvoiceReportRow> GetInvoiceReport(int invoiceid, int grouporderid)
        {
            List<InvoiceReportRow> invoicedrptdata = new List<InvoiceReportRow>();

            InvoiceReportsDataContext dc = new InvoiceReportsDataContext();
            dc.CommandTimeout = 3000;
            var result = dc.S1_InvoiceReports_GetInvoiceDetail(invoiceid, grouporderid);

            foreach (var item in result)
            {
                InvoiceReportRow templist = new InvoiceReportRow(item.Detail.Value, item.GroupOrder, Convert.ToInt32(item.RecordCount), item.FileNum, item.ClientName, item.Address1,
                    item.Address2, item.Address3, item.ContactPhone, item.ContactFax, item.ProductType, Convert.ToDateTime(item.DateOrdered),
                    item.Name, item.SSN, item.OrderBy, item.Reference, Convert.ToDecimal(item.ProductPrice), item.ProductDescription, 
                    Convert.ToDateTime(item.InvoiceDate), item.InvoiceNumber, item.LName, item.FName, (int)item.LineNumber.Value,
                    item.PrimaryClientName);

                invoicedrptdata.Add(templist);
            }

            return invoicedrptdata;
        }

    }

    public class InvoiceReportRow
    {

    	public int Detail;
        public string GroupOrder;
        public int RecordCount;
        public string FileNum;
        public string ClientName;
        public string Address1;
        public string Address2;
        public string Address3; 
        public string ContactPhone;
        public string ContactFax;
        public string ProductType;
        public DateTime DateOrdered;
        public string Name;
        public string SSN;
        public string OrderBy;
        public string Reference;
        public decimal ProductPrice;
        public string ProductDescription;
        public DateTime InvoiceDate;
        public string InvoiceNumber;
        public string LName;
        public string FName;
        public int LineNumber;
        public string PrimaryClientName;
        
        public InvoiceReportRow(int _Detail, string _GroupdOrder, int _RecordCount, string _FileNum, string _ClientName, string _Address1, string _Address2,
            string _Address3, string _ContactPhone, string _ContactFax, string _ProductType,
            DateTime _DateOrdered, string _Name, string _SSN, string _OrderBy, string _Reference,
            decimal _ProductPrice, string _ProductDescription, DateTime _InvoiceDate, string _InvoiceNumber, string _LName,
            string _FName, int _LineNumber, string _PrimaryClientName)
        {
            Detail = _Detail;
            GroupOrder = _GroupdOrder;
            RecordCount = _RecordCount;
            FileNum = _FileNum;
            ClientName = _ClientName;
            Address1 = _Address1;
            Address2 = _Address2;
            Address3 = _Address3;
            ContactPhone = _ContactPhone;
            ContactFax = _ContactFax;
            ProductType = _ProductType;
            DateOrdered = _DateOrdered;
            Name = _Name;
            SSN = _SSN;
            OrderBy = _OrderBy;
            Reference = _Reference;
            ProductPrice = _ProductPrice;
            ProductDescription = _ProductDescription;
            InvoiceDate = _InvoiceDate;
            InvoiceNumber = _InvoiceNumber;
            LName = _LName;
            FName = _FName;
            LineNumber = _LineNumber;
            PrimaryClientName = _PrimaryClientName;
        }
    }

}