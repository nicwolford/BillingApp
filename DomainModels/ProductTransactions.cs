using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ScreeningONE.Models;

namespace ScreeningONE.DomainModels
{
    public class ProductTransactions
    {

        //Return product transactions (Status = 0 is all, status = 1 is new, status = 2 is invoiced)
        public static List<ProductTransaction> GetProductTransactions(int _Status, int _ClientID)
        {
            List<ProductTransaction> productTransactions = new List<ProductTransaction>();

            ProductTransactionsDataContext dc = new ProductTransactionsDataContext();
            var result = dc.S1_ProductTransactions_GetProductTransactions(_Status, _ClientID);

            foreach (var item in result)
            {
                ProductTransaction tempProductTransaction = new ProductTransaction(item.ProductTransactionID, item.ClientID,
                    item.ClientName, item.TransactionDate, item.DateOrdered, item.ProductID, item.ProductType, item.ProductName, item.ProductDescription,
                    item.ProductPrice, 0, item.ProductTransactionID, item.FName, item.MName, item.LName, item.Reference, item.OrderBy,
                    item.FileNum, 0, "", "", 0, true,item.IncludeOnInvoice);

                productTransactions.Add(tempProductTransaction);
            }

            return productTransactions;
        }

        //Return product transactions (Status = 0 is all, status = 1 is new, status = 2 is invoiced, status = 3 is un-invoiced)
        public static List<ProductTransaction> GetProductTransactions(int _Status, int _ClientID, DateTime _StartDate,
            DateTime _EndDate, string FileNum, int _CurrentPage, 
            int _RowsPerPage, 
            string _SortField, SortDirection _SortDirection)
        {
            List<ProductTransaction> productTransactions = new List<ProductTransaction>();

            ProductTransactionsDataContext dc = new ProductTransactionsDataContext();
            
            //IEnumerable<S1_ProductTransactions_GetProductTransactionsPagedResult> result;
            bool boolSortDirection;
            if (_SortDirection == SortDirection.Ascending)
                boolSortDirection = false;
            else
                boolSortDirection = true;

            var result = dc.S1_ProductTransactions_GetProductTransactionsPaged(_Status, _ClientID, _StartDate, _EndDate,
                FileNum.Trim(), _CurrentPage, _RowsPerPage, _SortField, boolSortDirection);

            /*
            int FirstRow = ((_CurrentPage - 1) * _RowsPerPage) + 1;
            int LastRow = FirstRow + _RowsPerPage - 1;
                
            if (!String.IsNullOrEmpty(_SortField))
            {
                result = result_temp.Order(_SortField, _SortDirection).Skip(FirstRow).Take(LastRow);
            }
            else
            {
                result = result_temp.Skip(FirstRow).Take(LastRow);
            }
            */

            foreach (var item in result)
            {
                ProductTransaction tempProductTransaction = new ProductTransaction(item.ProductTransactionID, item.ClientID,
                    item.ClientName, item.TransactionDate, item.DateOrdered, item.ProductID, item.ProductType, item.ProductName, item.ProductDescription,
                    item.ProductPrice, (item.Number.HasValue ? item.Number.Value : 0),
                    (int)(item.rownum.HasValue ? item.rownum.Value : 0), item.FName, item.MName, item.LName, item.Reference,
                    item.OrderBy, item.FileNum, 0, "", "", 0, true,item.IncludeOnInvoice);

                productTransactions.Add(tempProductTransaction);
            }

            return productTransactions;
        }

        //Return one product transaction
        public static ProductTransaction GetProductTransaction(int _ProductTransactionID)
        {
            ProductTransactionsDataContext dc = new ProductTransactionsDataContext();
            var item = dc.S1_ProductTransactions_GetProductTransaction(_ProductTransactionID).SingleOrDefault();

            return new ProductTransaction(item.ProductTransactionID, item.ClientID,
                    item.ClientName, item.TransactionDate, item.DateOrdered, item.ProductID, item.ProductType, item.ProductName, item.ProductDescription,
                    item.ProductPrice, 0, 0, item.FName, item.MName, item.LName, item.Reference, item.OrderBy, item.FileNum,
                    item.VendorID, item.VendorName, item.SSN, item.BasePrice, item.ImportsAtBaseOrSales.Value,item.IncludeOnInvoice);
        }

        public static void CreateProductTransaction(ProductTransaction _ProductTransaction)
        {
            ProductTransactionsDataContext dc = new ProductTransactionsDataContext();

            dc.S1_ProductTransactions_CreateProductTransaction(_ProductTransaction.ProductID, _ProductTransaction.ClientID,
                _ProductTransaction.VendorID, _ProductTransaction.TransactionDate, _ProductTransaction.DateOrdered,
                _ProductTransaction.OrderedBy, _ProductTransaction.Reference, _ProductTransaction.FileNum,
                _ProductTransaction.FName, _ProductTransaction.LName, _ProductTransaction.MName, _ProductTransaction.SSN,
                _ProductTransaction.ProductDescription, _ProductTransaction.ProductType, _ProductTransaction.ProductPrice);
        }

        public static void RemoveProductTransaction(int _ProductTransactionsID)
        {
            ProductTransactionsDataContext dc = new ProductTransactionsDataContext();

            dc.S1_ProductTransactions_RemoveProductTransaction(_ProductTransactionsID);
        }

        public static void UpdateProductTransaction(ProductTransaction _ProductTransaction)
        {
            ProductTransactionsDataContext dc = new ProductTransactionsDataContext();

            if (_ProductTransaction.ImportsAtBaseOrSales) //Update ProductTransaction using ProductPrice
            {
                dc.S1_ProductTransactions_UpdateProductTransaction(_ProductTransaction.ProductTransactionID,
                    _ProductTransaction.ProductID, _ProductTransaction.ClientID, _ProductTransaction.VendorID,
                    _ProductTransaction.TransactionDate, _ProductTransaction.DateOrdered, _ProductTransaction.OrderedBy,
                    _ProductTransaction.Reference, _ProductTransaction.FileNum, _ProductTransaction.FName,
                    _ProductTransaction.LName, _ProductTransaction.MName, _ProductTransaction.SSN, _ProductTransaction.ProductDescription,
                    _ProductTransaction.ProductType, _ProductTransaction.ProductPrice);
            }
            else //Update ProductTransaction using BasePrice
            {
                dc.S1_ProductTransactions_UpdateProductTransaction(_ProductTransaction.ProductTransactionID,
                    _ProductTransaction.ProductID, _ProductTransaction.ClientID, _ProductTransaction.VendorID,
                    _ProductTransaction.TransactionDate, _ProductTransaction.DateOrdered, _ProductTransaction.OrderedBy,
                    _ProductTransaction.Reference, _ProductTransaction.FileNum, _ProductTransaction.FName,
                    _ProductTransaction.LName, _ProductTransaction.MName, _ProductTransaction.SSN, _ProductTransaction.ProductDescription,
                    _ProductTransaction.ProductType, _ProductTransaction.BasePrice);
            }
        }
    }

    public class ProductTransaction
    {
        public int ProductTransactionID;
        public string FName;
        public string MName;
        public string LName;
        public string SSN;
        public string Reference;
        public string OrderedBy;
        public string FileNum;
        public DateTime TransactionDate;
        public int ClientID;
        public int VendorID;
        public string ClientName;
        public string VendorName;
        public DateTime DateOrdered;
        public int ProductID;
        public string ProductType;
        public string ProductName;
        public string ProductDescription;
        public bool ImportsAtBaseOrSales;
        public byte IncludeOnInvoice;
        public decimal ProductPrice;
        public decimal BasePrice;
        public int NumberOfRows;
        public int RowNumber;
        

        public ProductTransaction(int _ProductTransactionID, int _ClientID, string _ClientName, DateTime? _TransactionDate, DateTime ?_DateOrdered, int _ProductID, 
            string _ProductType, string _ProductName, string _ProductDescription, decimal? _ProductPrice, int _NumberOfRows,
            int _RowNumber, string _FName, string _MName, string _LName, string _Reference, string _OrderedBy, string _FileNum,
            int _VendorID, string _VendorName, string _SSN, decimal _BasePrice, bool _ImportsAtBaseOrSales,byte _IncludeOnInvoice)
        {
            ProductTransactionID = _ProductTransactionID;
            ClientID = _ClientID;
            ClientName = _ClientName;
            TransactionDate = (_TransactionDate.HasValue ? _TransactionDate.Value : new DateTime(1753, 1, 1));
            DateOrdered = (_DateOrdered.HasValue ? _DateOrdered.Value : new DateTime(1753, 1, 1));
            ProductID = _ProductID;
            ProductType = _ProductType;
            ProductName = _ProductName;
            ProductDescription = _ProductDescription;
            ProductPrice = Convert.ToDecimal(_ProductPrice);
            NumberOfRows = _NumberOfRows;
            RowNumber = _RowNumber;
            FName = _FName;
            MName = _MName;
            LName = _LName;
            Reference = _Reference;
            OrderedBy = _OrderedBy;
            FileNum = _FileNum;
            VendorID = _VendorID;
            VendorName = _VendorName;
            SSN = _SSN;
            BasePrice = _BasePrice;
            ImportsAtBaseOrSales = _ImportsAtBaseOrSales;
            IncludeOnInvoice = _IncludeOnInvoice;
        }
    }
}
