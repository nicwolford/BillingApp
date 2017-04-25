using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Mvc.Ajax;
using System.Security;
using ScreeningONE.ViewModels;
using ScreeningONE.DomainModels;
using System.Text.RegularExpressions;
using System.Text;
using LumenWorks.Framework.IO.Csv;
using ScreeningONE.Objects;
using StringExtensions;
using System.Configuration;

namespace ScreeningONE.Controllers
{
    public class BillingImportController : S1BaseController
    {
        //
        // GET: /FileImport/
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs("GET")]
        public ActionResult ImportBillingFile()
        {
            ViewBag.nofileerror = "";
            return View();
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs("POST")]
        public ActionResult ImportBillingFile(string transactionname)
        {

            ViewBag.nofileerror = "";
            if (Request.Files == null || Request.Files.Count <= 0 || Request.Files[0].FileName == "" || Request.Files[0].ContentLength == 0)
            {               
                ViewBag.nofileerror = "File was not uploaded.";
                return View();
            }
            
            HttpPostedFileBase billingfile = Request.Files[0];

            string subFolder = "";

            switch (transactionname)
            {
                case "tazworks1":
                    subFolder = "Tazworks 1.0 CSV File";
                    break;
                case "tazworks2":
                    subFolder = "Tazworks 2.0 CSV File";
                    break;
                case "edrug":
                    subFolder = "eDrug CSV File";
                    break;
                case "tu":
                    subFolder = "TransUnion CSV File";
                    break;
                case "xp":
                    subFolder = "Experian CSV File";
                    break;
                case "QB":
                    subFolder = "Quickbooks Billing Summary";
                    BillingImport_Upload viewBillingData = new BillingImport_Upload();
                    ContentResult result = new ContentResult();
                    result.ContentType = "text/plain";
                    viewBillingData.importfilename = billingfile.FileName;
                    viewBillingData.username = User.Identity.Name;
                    viewBillingData.VendorID = 7;

                    int importbatchid = BillingImport.CreateImportBatch(viewBillingData);

                    if (importbatchid == -1)
                    {
                        ViewData.ModelState.AddModelError("*", "A new import batch ID could not be created.  Please refresh this screen and try again.");
                        return View(viewBillingData);
                    }

                    if (importbatchid == -2)
                    {
                        ViewData.ModelState.AddModelError("*", "A file from this directory with the same name was previously imported. If it is a new file, please rename the file and try again.");
                        return View(viewBillingData);
                    }

                    viewBillingData.importbatchid = importbatchid;

                    //Skip empty files
                    if (billingfile.ContentLength != 0)
                    {
                        string clearresult = DomainModels.BillingImport.ClearQBBalanceSummaryTable();
                        if (clearresult == "0")
                        {
                            int linecount = 0;

                            try
                            {
                                using (CsvReader csv =
                                            new CsvReader(new StreamReader(billingfile.InputStream), true, CsvReader.DefaultDelimiter, CsvReader.DefaultQuote, CsvReader.DefaultEscape, CsvReader.DefaultComment, ValueTrimmingOptions.None))
                                {
                                    csv.MissingFieldAction = MissingFieldAction.ReplaceByEmpty;
                                    int fieldCount = csv.FieldCount;

                                    while (csv.ReadNextRecord())
                                    {
                                        linecount++;
                                        viewBillingData.VendorID = 7;
                                        viewBillingData.QBBillAsClientName = csv[0].ToString();
                                        viewBillingData.QBAmount = Decimal.Parse(csv[1].ToString());

                                        string returnresults = DomainModels.BillingImport.UploadQBBillingSummaryData(viewBillingData);

                                        if (returnresults != "0")
                                        {

                                            ViewData.ModelState.AddModelError("*", "There was a problem importing the Quickbooks Balance data. Line Number:" + linecount + "; FileNum:" + viewBillingData.FileNum);

                                            return View(viewBillingData);

                                        }

                                    }

                                }

                            }
                            catch (Exception ex)
                            {
                                //ViewData.ModelState.AddModelError("*", ex.Message);                          
                                ViewData.ModelState.AddModelError("*", "The CSV file appears to be corrupt. Line Number:" + (linecount + 1));
                                ViewData.ModelState.AddModelError("*", ex.ToString());
                                return View(viewBillingData);
                            }//end using CSVReader

                            return RedirectToAction("Index", "Reports");
                        } //end if clear table success
                        else
                        {
                            ViewData.ModelState.AddModelError("*", "There was a problem clearing the previous Quickbooks import data. This import failed.");
                            return View(viewBillingData);
                        }
                    }
                    break;
            }

            if (transactionname != "QB")
            {
                string importUploadPath = ConfigurationManager.AppSettings["ImportUploadPath"];

                if (!importUploadPath.EndsWith("\\"))
                {
                    importUploadPath = importUploadPath + "\\";
                }

                if (!subFolder.EndsWith("\\"))
                {
                    subFolder = subFolder + "\\";
                }

                DateTime nPlease = DateTime.Now;

                subFolder = subFolder + "\\" + nPlease.ToString("yyyy") + "\\" + nPlease.ToString("MMM") + "\\" + nPlease.ToString("dd") + "\\" + nPlease.ToString("hhmmsstt") + "\\";

                if (!Directory.Exists(importUploadPath + subFolder))
                {
                    Directory.CreateDirectory(importUploadPath + subFolder);
                }

                //billingfile.SaveAs(importUploadPath + subFolder + billingfile.FileName);
                billingfile.SaveAs(Path.Combine(importUploadPath + subFolder, billingfile.FileName.Split('\\').Last()));
            }

            return View();
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs("POST")]
        public ActionResult ImportBillingFileOld(string transactionname)
        {
            BillingImport_Upload viewBillingData = new BillingImport_Upload();
                        
            HttpPostedFileBase billingfile = Request.Files[0];
            ContentResult result = new ContentResult();
            result.ContentType = "text/plain";

            viewBillingData.importfilename = billingfile.FileName;
            viewBillingData.username = User.Identity.Name;

            switch(transactionname) {
            
                case "tazworks1": 
                    viewBillingData.VendorID = 1;
                    break;
                case "tazworks2": 
                    viewBillingData.VendorID = 2;
                    break;
                case "edrug": 
                    viewBillingData.VendorID = 8;
                    break;
                case "tu": 
                    viewBillingData.VendorID = 4;
                    break;
                case "xp":
                    viewBillingData.VendorID = 5;
                    break;
                case "QB":
                    viewBillingData.VendorID = 7;
                    break;
            }

            int importbatchid = BillingImport.CreateImportBatch(viewBillingData);

            if (importbatchid == -1)
            {
                ViewData.ModelState.AddModelError("*", "A new import batch ID could not be created.  Please refresh this screen and try again.");
                return View(viewBillingData);
            }

            if (importbatchid == -2)
            {
                ViewData.ModelState.AddModelError("*", "A file from this directory with the same name was previously imported. If it is a new file, please rename the file and try again.");
                return View(viewBillingData);
            }

            viewBillingData.importbatchid = importbatchid;

            //Skip empty files
            if (billingfile.ContentLength != 0)
            {
                if (transactionname == "tazworks1" || transactionname == "tazworks2")
                {
                    string clearresult = DomainModels.BillingImport.ClearTazworksImportTable();
                    if (clearresult == "0")
                    {
                        int linecount = 0;

                        try
                        {
                            using (CsvReader csv = 
                                        new CsvReader(new StreamReader(billingfile.InputStream),true, CsvReader.DefaultDelimiter, CsvReader.DefaultQuote, CsvReader.DefaultEscape, CsvReader.DefaultComment, ValueTrimmingOptions.None))
                            {
                                csv.MissingFieldAction = MissingFieldAction.ReplaceByEmpty;
                                int fieldCount = csv.FieldCount;

                                while (csv.ReadNextRecord())
                                {
                                    linecount++;
                                    if (transactionname == "tazworks1")
                                    {
                                        viewBillingData.VendorID = 1;
                                        viewBillingData.FileNum = Int32.Parse(csv[0].ToString());
                                        viewBillingData.ClientNumber = csv[1].ToString();
                                        viewBillingData.ClientName = csv[2].ToString();
                                        viewBillingData.SalesRep = csv[10].ToString();
                                        viewBillingData.LName = csv[11].ToString();
                                        viewBillingData.FName = csv[12].ToString();
                                        viewBillingData.MName = csv[13].ToString();
                                        viewBillingData.SSN = csv[14].ToString();
                                        viewBillingData.CoLName = csv[15].ToString();
                                        viewBillingData.CoFName = csv[16].ToString();
                                        viewBillingData.CoSSN = csv[18].ToString();
                                        viewBillingData.OrderBy = csv[19].ToString();
                                        viewBillingData.Reference = csv[20].ToString();
                                        viewBillingData.DateOrdered = csv[21].ToString();
                                        viewBillingData.ProductName = csv[22].ToString();
                                        viewBillingData.ProductType = csv[23].ToString();
                                        viewBillingData.ProductDesc = csv[24].ToString().stripHTML();
                                        viewBillingData.Price = Decimal.Parse(csv[25].ToString());
                                        viewBillingData.InvoiceNumber = csv[27].ToString();

                                        string returnresults = DomainModels.BillingImport.UploadTazworks1Data(viewBillingData);

                                        if (returnresults != "0")
                                        {

                                            ViewData.ModelState.AddModelError("*", "There was a problem importing the Tazworks 1.0 data. Line Number:" + linecount + "; FileNum:" + viewBillingData.FileNum);

                                            return View(viewBillingData);

                                        }
                                    }
                                    else
                                    {

                                        
                                        viewBillingData.VendorID = 2;
                                        if (csv[0].ToString() == "") {
                                            viewBillingData.FileNum = (Int32.Parse(csv[30].ToString())+linecount)*10;
                                        }
                                        else
                                        {
                                            viewBillingData.FileNum = Int32.Parse(csv[0].ToString());
                                        }
                                        viewBillingData.ClientNumber = csv[1].ToString();
                                        viewBillingData.ClientName = csv[2].ToString();
                                        viewBillingData.SalesRep = csv[10].ToString();
                                        viewBillingData.LName = csv[11].ToString();
                                        viewBillingData.FName = csv[12].ToString();
                                        viewBillingData.MName = csv[13].ToString();
                                        viewBillingData.SSN = csv[14].ToString();
                                        viewBillingData.CoLName = csv[15].ToString();
                                        viewBillingData.CoFName = csv[16].ToString();
                                        viewBillingData.CoSSN = csv[18].ToString();
                                        viewBillingData.ClientNumberOrdered = csv[19].ToString();
                                        viewBillingData.ClientNameOrdered = csv[20].ToString();
                                        viewBillingData.OrderBy = csv[21].ToString();
                                        viewBillingData.Reference = csv[22].ToString();
                                        viewBillingData.DateOrdered = csv[23].ToString();
                                        viewBillingData.ProductName = csv[24].ToString();
                                        viewBillingData.ProductType = csv[25].ToString();
                                        viewBillingData.ItemCode = csv[26].ToString();
                                        viewBillingData.ProductDesc = csv[27].ToString().stripHTML();
                                        viewBillingData.Price = Decimal.Parse(csv[28].ToString());
                                        viewBillingData.InvoiceNumber = csv[30].ToString();

                                        string returnresults = DomainModels.BillingImport.UploadTazworks2Data(viewBillingData);

                                        if (returnresults != "0")
                                        {

                                            ViewData.ModelState.AddModelError("*", "There was a problem importing the Tazworks 2.0 data. Line Number:" + linecount + "; FileNum:" + viewBillingData.FileNum);

                                            return View(viewBillingData);

                                        }
                                    }
                                }
                            }
                        }
			            catch (Exception ex)
			            {
                            //ViewData.ModelState.AddModelError("*", ex.Message);                          
                            ViewData.ModelState.AddModelError("*", "The CSV file appears to be corrupt. Line Number:" + (linecount + 1) + "; FileNum:" + viewBillingData.FileNum);
                            ViewData.ModelState.AddModelError("*", ex.ToString());
                            return View(viewBillingData);
			            }//end using CSVReader

                        return RedirectToAction("VerifyImport", "BillingImport", new { vendorid = viewBillingData.VendorID });
                    } //end if clear table success
                    else
                    {
                        ViewData.ModelState.AddModelError("*", "There was a problem clearing the previous Tazworks import data. This import failed.");
                        return View(viewBillingData);
                    }
                }// end of check for Tazworks format

                if (transactionname == "tu")
                {
                    string clearresult = DomainModels.BillingImport.ClearTUImportTable();
                    if (clearresult == "0")
                    {
                        int linecount = 0;

                        try
                        {

                            string line = null;

                            using (StreamReader billdata = new StreamReader(billingfile.InputStream))
                            {

                                while ((line = billdata.ReadLine()) != null)
                                {
                                    linecount++;

                                    DateTime inquirydate = ConvertFromJulianDate(line.Substring(13, 4) + line.Substring(18, 3));

                                    string strInquiryDate = inquirydate.ToString();

                                    viewBillingData.TUSubscriberID = line.Substring(0, 12);
                                    viewBillingData.TUInquiryDate = strInquiryDate;
                                    viewBillingData.TUInquiryTime = line.Substring(22, 6);
                                    viewBillingData.TUECOA = line.Substring(29, 2);
                                    viewBillingData.TUSurname = line.Substring(32, 32);
                                    viewBillingData.TUFirstName = line.Substring(65, 20);
                                    viewBillingData.TUAddress = line.Substring(86, 40);
                                    viewBillingData.TUCity = line.Substring(127, 10);
                                    viewBillingData.TUState = line.Substring(138, 2);
                                    viewBillingData.TUZip = line.Substring(141, 5);
                                    viewBillingData.TUSSN = line.Substring(148, 4);
                                    viewBillingData.TUSpouseFirstName = line.Substring(153, 20);
                                    viewBillingData.TUNetPrice = Decimal.Round(Convert.ToDecimal(line.Substring(207, 7) + "." + line.Substring(214, 3)),2 );
                                    viewBillingData.TUMMSSTo   = line.Substring(218, 4);
                                    viewBillingData.TUTimeZone = line.Substring(223, 1);
                                    viewBillingData.TUProductType = line.Substring(225, 1);
                                    viewBillingData.TUProductCode  = line.Substring(227, 5);
                                    viewBillingData.TUHit = line.Substring(236, 1);
                                    viewBillingData.TUUserReference = line.Substring(239, 24);
                                        
                                    string returnresults = DomainModels.BillingImport.UploadTransUnionData(viewBillingData);

                                    if (returnresults != "0")
                                    {
                                        ViewData.ModelState.AddModelError("*", "There was a problem importing the TransUnion data. Line Number:" + linecount);
                               
                                        return View(viewBillingData);
                                    }
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            //ViewData.ModelState.AddModelError("*", ex.Message);                          
                            ViewData.ModelState.AddModelError("*", "The CSV file appears to be corrupt. Line Number:" + (linecount + 1));
                            ViewData.ModelState.AddModelError("*", ex.ToString());
                            return View(viewBillingData);
                        }//end using CSVReader

                        return RedirectToAction("VerifyImport", "BillingImport", new { vendorid = viewBillingData.VendorID });
                    } //end if clear table success
                    else
                    {
                        ViewData.ModelState.AddModelError("*", "There was a problem clearing the previous TransUnion import data. This import failed.");
                        return View(viewBillingData);
                    }
                }// end of check for TransUnion format


                if (transactionname == "xp")
                {
                    string clearresult = DomainModels.BillingImport.ClearXPImportTable();
                    if (clearresult == "0")
                    {
                        int linecount = 0;

                        try
                        {

                            string line = null;

                            using (StreamReader billdata = new StreamReader(billingfile.InputStream))
                            {

                                while ((line = billdata.ReadLine()) != null)
                                {
                                    if (line.Substring(9, 1) == "5")
                                    {
                                        int productcount = 1;
                                        int productcodeposition = 378;
                                        int productpriceposition = 677;
 
                                        while (productcount <= 30)
                                        {
                                            if (line.Substring(productcodeposition, 7) != "       ")
                                            {
                                                viewBillingData.XPRequesterNo = line.Substring(1, 5);
                                                viewBillingData.XPRecordType = line.Substring(9, 1);
                                                viewBillingData.XPMktPreamble = line.Substring(13, 4);
                                                viewBillingData.XPAccPreamble = line.Substring(20, 4);
                                                viewBillingData.XPSubcode = line.Substring(27, 7);
                                                viewBillingData.XPInquiryDate = line.Substring(37, 6);
                                                viewBillingData.XPInquiryTime = line.Substring(46, 6);
                                                viewBillingData.XPLastName = line.Substring(55, 32);
                                                viewBillingData.XPSecondLastName = line.Substring(90, 32);
                                                viewBillingData.XPFirstName = line.Substring(125, 32);
                                                viewBillingData.XPMiddleName = line.Substring(160, 32);
                                                viewBillingData.XPGenerationCode = line.Substring(195, 1);
                                                viewBillingData.XPStreetNumber = line.Substring(199, 10);
                                                viewBillingData.XPStreetName = line.Substring(212, 32);
                                                viewBillingData.XPStreetSuffix = line.Substring(247, 4);
                                                viewBillingData.XPCity = line.Substring(254, 32);
                                                viewBillingData.XPUnitID = line.Substring(289, 32);
                                                viewBillingData.XPState = line.Substring(324, 2);
                                                viewBillingData.XPZipCode = line.Substring(329, 9);
                                                viewBillingData.XPHitCode = line.Substring(341, 2);
                                                viewBillingData.XPSSN = line.Substring(346, 9);
                                                viewBillingData.XPOperatorID = line.Substring(358, 2);
                                                viewBillingData.XPDuplicateID = line.Substring(363, 1);
                                                viewBillingData.XPStatementID = line.Substring(367, 2);
                                                viewBillingData.XPInvoiceCodes = line.Substring(372, 3);
                                                viewBillingData.XPProductCode = line.Substring(productcodeposition, 7);
                                                viewBillingData.XPProductPrice = Decimal.Parse(line.Substring(productpriceposition, 10));
                                                viewBillingData.XPMKeyWord = line.Substring(1008, 20);

                                                string returnresults = DomainModels.BillingImport.UploadExperianData(viewBillingData);

                                                if (returnresults != "0")
                                                {

                                                    ViewData.ModelState.AddModelError("*", "There was a problem importing the Experian data. Line Number:" + linecount);

                                                    return View(viewBillingData);
                                                    
                                                }
                                            
                                            }

                                            productcount++; productcodeposition += +10; productpriceposition += +11;

                                        }
                                        
                                    }
                                
                                }

                            }

                        }
                        catch (Exception ex)
                        {
                            //ViewData.ModelState.AddModelError("*", ex.Message);                          
                            ViewData.ModelState.AddModelError("*", "The CSV file appears to be corrupt. Line Number:" + (linecount + 1));
                            ViewData.ModelState.AddModelError("*", ex.ToString());
                            return View(viewBillingData);
                        }//end using CSVReader

                        return RedirectToAction("VerifyImport", "BillingImport", new { vendorid = viewBillingData.VendorID });
                    } //end if clear table success
                    else
                    {
                        ViewData.ModelState.AddModelError("*", "There was a problem clearing the previous Experian import data. This import failed.");
                        return View(viewBillingData);
                    }
                }// end of check for Experian format

                if (transactionname == "edrug")
                {
                    string clearresult = BillingImport.CleareDrugImportTable();
                    if (clearresult == "0")
                    {
                        int linecount = 0;

                        try
                        {
                            using (CsvReader csv =
                                        new CsvReader(new StreamReader(billingfile.InputStream), true, CsvReader.DefaultDelimiter, CsvReader.DefaultQuote, CsvReader.DefaultEscape, CsvReader.DefaultComment, ValueTrimmingOptions.None))
                            {
                                csv.MissingFieldAction = MissingFieldAction.ReplaceByEmpty;
                                int fieldCount = csv.FieldCount;

                                while (csv.ReadNextRecord())
                                {
                                    linecount++;

                                    viewBillingData.VendorID = 8;
                                    viewBillingData.EDCustomerName = csv[5].ToString();
                                    viewBillingData.EDCustomerNumber = csv[4].ToString();
                                    viewBillingData.EDInvoiceNumber = csv[3].ToString();
                                    viewBillingData.EDLocationCode = csv[6].ToString();
                                    viewBillingData.EDServiceDate = csv[7].ToString();
                                    viewBillingData.EDProduct = csv[13].ToString();
                                    viewBillingData.EDFee = Decimal.Parse(csv[8].ToString());
                                    viewBillingData.EDSSN = csv[9].ToString();
                                    viewBillingData.EDEmployeeName = csv[0].ToString();
                                    viewBillingData.EDCOCNumber = csv[10].ToString();
                                    viewBillingData.EDSpecimenID = csv[11].ToString();
                                    viewBillingData.EDReason = csv[14].ToString();
                                    viewBillingData.EDComments = csv[15].ToString();

                                    string returnresults = BillingImport.UploadeDrugData(viewBillingData);

                                    if (returnresults != "0")
                                    {

                                        ViewData.ModelState.AddModelError("*", "There was a problem importing the eDrug data. Line Number:" + linecount + "; FileNum:" + viewBillingData.FileNum);

                                        return View(viewBillingData);

                                    }
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            //ViewData.ModelState.AddModelError("*", ex.Message);                          
                            ViewData.ModelState.AddModelError("*", "The CSV file appears to be corrupt. Line Number:" + (linecount + 1) + "; FileNum:" + viewBillingData.FileNum);
                            ViewData.ModelState.AddModelError("*", ex.ToString());
                            return View(viewBillingData);
                        }//end using CSVReader

                        return RedirectToAction("VerifyImport", "BillingImport", new { vendorid = viewBillingData.VendorID });
                    } //end if clear table success
                    else
                    {
                        ViewData.ModelState.AddModelError("*", "There was a problem clearing the previous eDrug import data. This import failed.");
                        return View(viewBillingData);
                    }
                }// end of check for eDrug format


                if (transactionname == "QB")
                {
                    string clearresult = DomainModels.BillingImport.ClearQBBalanceSummaryTable();
                    if (clearresult == "0")
                    {
                        int linecount = 0;

                        try
                        {
                            using (CsvReader csv =
                                        new CsvReader(new StreamReader(billingfile.InputStream), true, CsvReader.DefaultDelimiter, CsvReader.DefaultQuote, CsvReader.DefaultEscape, CsvReader.DefaultComment, ValueTrimmingOptions.None))
                            {
                                csv.MissingFieldAction = MissingFieldAction.ReplaceByEmpty;
                                int fieldCount = csv.FieldCount;

                                while (csv.ReadNextRecord())
                                {
                                    linecount++;
                                    viewBillingData.VendorID = 7;
                                    viewBillingData.QBBillAsClientName = csv[0].ToString();
                                    viewBillingData.QBAmount = Decimal.Parse(csv[1].ToString());

                                    string returnresults = DomainModels.BillingImport.UploadQBBillingSummaryData(viewBillingData);

                                    if (returnresults != "0")
                                    {

                                        ViewData.ModelState.AddModelError("*", "There was a problem importing the Quickbooks Balance data. Line Number:" + linecount + "; FileNum:" + viewBillingData.FileNum);

                                        return View(viewBillingData);

                                    }

                                }

                            }

                        }
                        catch (Exception ex)
                        {
                            //ViewData.ModelState.AddModelError("*", ex.Message);                          
                            ViewData.ModelState.AddModelError("*", "The CSV file appears to be corrupt. Line Number:" + (linecount + 1));
                            ViewData.ModelState.AddModelError("*", ex.ToString());
                            return View(viewBillingData);
                        }//end using CSVReader

                        return RedirectToAction("Index", "Reports");
                    } //end if clear table success
                    else
                    {
                        ViewData.ModelState.AddModelError("*", "There was a problem clearing the previous Quickbooks import data. This import failed.");
                        return View(viewBillingData);
                    }
                }// end of check for Quickbooks format


            } // end if (billingfile.ContentLength != 0)

            return View(viewBillingData);
        
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs("GET")]
        public ActionResult VerifyImport(int vendorid)
        {
            BillingImport_Upload viewBillingData = new BillingImport_Upload();

            viewBillingData.VendorID = vendorid;
            viewBillingData.importauditlist = BillingImport.GetImportAuditResults(vendorid);
            if (viewBillingData.importauditlist.Count > 0)
            {
                viewBillingData.totalrecords = viewBillingData.importauditlist.SingleOrDefault().TotalRecordCount.Value;
                viewBillingData.totalprice = viewBillingData.importauditlist.SingleOrDefault().TotalPrice.Value;
            }
            else {
                viewBillingData.totalrecords = 0;
                viewBillingData.totalprice = 0;
            }
            
            return View(viewBillingData);
        }


        //Return JSON data for the VerifyImport jqGrid
        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Client, Admin")]
        public JsonResult VerifyImportJSON(FormCollection fc) 
        {
            int ID = Convert.ToInt32(fc["id"]);
            string FieldToSort = fc["sidx"];
            string SortOrder = fc["sord"];
            if (FieldToSort == "id")
            {
                FieldToSort = "";
                SortOrder = "";
            }

            int RowsPerPage = Convert.ToInt32(fc["rows"]);
            int CurrentPage = Convert.ToInt32(fc["page"]);

            var result = BillingImport.GetImportErrors(Convert.ToInt32(fc["vendorid"]));

            Array rows = (from question in result
                          select new
                          {
                              i = question.ImportID,
                              cell = new string[] { question.ImportID.ToString(),
                                  question.ErrorCode.ToString(),  
                                  question.LineNumber.ToString(),
                                  question.ErrorMsg,
                                  question.FileNum.ToString(),
                                  question.ErrorDetail }
                          }
                          ).ToArray();

            int totalRows = rows.Length;

            var ret = new JsonResult
            {
                Data = new
                {
                    page = 1,
                    records = totalRows,
                    rows = rows,
                    total = 1
                }
            };

            return ret;
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs("POST")]
        public ActionResult VerifyImport(BillingImport_Upload viewBillingData, FormCollection fc)
        {

            string returnresults = null;
            string returnupdateresults = null;
            string returnmvraccessfeeresults = null;
            string returnmvrupdateresults = null;

            switch (viewBillingData.VendorID)
            {

                case 1:
                    returnresults = BillingImport.ImportTazworksTransactions(viewBillingData.VendorID);
                    if (returnresults == "0")
                    {
                        returnupdateresults = BillingImport.UpdateTaz1SoftwareFees();

                        if (returnupdateresults == "-1")
                        {
                            ViewData.ModelState.AddModelError("*", "An error was encountered while inserting the PayLease access fees.");
                            return View(viewBillingData);
                        }

                        returnmvrupdateresults = BillingImport.UpdateTaz1StateMVRRecords();

                        if (returnmvrupdateresults == "-1")
                        {
                            ViewData.ModelState.AddModelError("*", "An error was encountered while updating the State MVR Records.");
                            return View(viewBillingData);
                        }

                        returnmvraccessfeeresults = BillingImport.UpdateTaz1StateMVRAccessFees();

                        if (returnmvraccessfeeresults == "-1")
                        {
                            ViewData.ModelState.AddModelError("*", "An error was encountered while updating the State MVR Access Fees.");
                            return View(viewBillingData);
                        }
                    }
                    break;
                case 2:
                    returnresults = BillingImport.ImportTazworksTransactions(viewBillingData.VendorID);
                    if (returnresults == "0")
                    {
                        returnupdateresults = BillingImport.UpdateTaz2SoftwareFees();
                    }
                    break;
                case 8:
                    returnresults = BillingImport.ImporteDrugTransactions(viewBillingData.VendorID);
                    if (returnresults != "0")
                    {
                        ViewData.ModelState.AddModelError("*", "An error was encountered while importing the eDrug file data.");
                        return View(viewBillingData);
                    }
                    break;
                case 4:
                    returnresults = BillingImport.ImportTransUnionTransactions(viewBillingData.VendorID);
                    if (returnresults == "0")
                    {
                        returnupdateresults = BillingImport.UpdateTUSurcharges();
                    }

                    break;
                case 5:
                    returnresults = BillingImport.ImportExperianTransactions(viewBillingData.VendorID);
                    if (returnresults == "0")
                    {
                        returnupdateresults = BillingImport.UpdateXPSurcharges();
                    }
                    break;
                case 7:
                    break;
            }


            if (returnresults == "-2")
            {
                ViewData.ModelState.AddModelError("*", "This is a duplicate import and cannot be completed.");
                return View(viewBillingData);
            }
            
            if (returnresults == "-1")
            {
                ViewData.ModelState.AddModelError("*", "Unable to complete the import!");
                return View(viewBillingData);
            }

            switch (viewBillingData.VendorID)
            {

                case 1:
                    BillingImport.UpdateTemp(null, null, null, false, null);
                    break;
                case 2:
                    BillingImport.UpdateTemp(null, null, null, false, null);
                    break;
                case 8:
                    BillingImport.UpdateTemp(false, null, null, null, null);
                    break;
                case 4:
                    BillingImport.UpdateTemp(null, null, null, null, false);
                    break;
                case 5:
                    BillingImport.UpdateTemp(null, false, null, null, null);
                    break;
                case 7:
                    BillingImport.UpdateTemp(null, null, false, null, null);
                    break;
            }

            return RedirectToAction("Index", "ProductTransactions");
        }

        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [AcceptVerbs("GET")]
        public ActionResult MatchDescToProduct(int id, int VendorID, string errorcode) //id = importid
        {
            BillingImport_Upload viewBillingData = new BillingImport_Upload();

            viewBillingData.ProductDesc = BillingImport.GetImportErrorDescription(id);
            viewBillingData.errorcode = errorcode;
            if (viewBillingData.ProductDesc == null || viewBillingData.ProductDesc == "0")
            {
                ViewData.ModelState.AddModelError("*", "The description could not be loaded.  Please cancel and try again. ");
                return View(viewBillingData);
            }
            viewBillingData.ImportID = id;
            viewBillingData.productlist = BillingImport.GetProducts(VendorID, id);

            return View(viewBillingData);
        }


        [ScreeningONEAuthorize(Portal = "Admin", Roles = "Admin")]
        [ActionName("MatchDescToProduct")]
        [AcceptVerbs("POST")]
        public JsonResult MatchDescToProductPost(BillingImport_Upload viewBillingData, FormCollection fc) //id = vendorid
        {
            string productcode = fc["productlist"];
            string searchtext = fc["productdesc"];
            int importid = Int32.Parse(fc["importid"]);
            string errorcode = fc["errorcodeval"];
            bool permanentsearch = true;

            if (errorcode == "104")
            {
                if (fc["ispermanentsearch"].ToString().Contains("t"))
                {
                    permanentsearch = true;
                }
                else
                {
                    permanentsearch = false;
                }
            }

            if (productcode == "")
            {
                ViewData.ModelState.AddModelError("*", "Please select a product first.");
                HandleMatchProductErrors(viewBillingData, fc);
                return new JsonResult
                {
                    Data = new
                    {
                        success = false,
                        view = RenderToString.RenderViewToString(this, "MatchDescToProduct", viewBillingData)
                    }
                };
            }

            string returnupdateresults = BillingImport.UpdateTazworksImport(importid, searchtext);

            if (returnupdateresults != "0")
            {
                ViewData.ModelState.AddModelError("*", "The description text could not be changed. ");
                HandleMatchProductErrors(viewBillingData, fc);
                return new JsonResult
                {
                    Data = new
                    {
                        success = false,
                        view = RenderToString.RenderViewToString(this, "MatchDescToProduct", viewBillingData)
                    }
                };
            }

            string returnresults = BillingImport.InsertTazworks1SearchText(productcode, searchtext, errorcode, permanentsearch, importid);

            if (returnresults != "0")
            {
                ViewData.ModelState.AddModelError("*", "The desciption could not be matched to the product selected.  Please try again.");
                HandleMatchProductErrors(viewBillingData, fc);
                return new JsonResult
                {
                    Data = new
                    {
                        success = false,
                        view = RenderToString.RenderViewToString(this, "MatchDescToProduct", viewBillingData)
                    }
                };
            }
            else
            {
                return new JsonResult { Data = new { success = true, importid = importid } };
            }
        }


        public JsonResult HandleMatchProductErrors(BillingImport_Upload viewBillingData, FormCollection fc)
        {
            viewBillingData.productlist = BillingImport.GetProducts(viewBillingData.VendorID, viewBillingData.ImportID);
            viewBillingData.productlist.Find(
                    delegate(SelectListItem tempitem)
                    {
                        return tempitem.Value == fc["productlist"];
                    }
                    ).Selected = true;


            return new JsonResult
            {
                Data = new
                {
                    success = false,
                    view = RenderToString.RenderViewToString(this, "MatchDescToProduct", viewBillingData)
                }
            };
        }

        private static DateTime ConvertFromJulianDate(string juliandate)
        {

            int njuliandate = Convert.ToInt32(juliandate);
             
            int Year = Convert.ToInt32(njuliandate.ToString().Substring(0, 4));
            int DoY = Convert.ToInt32(njuliandate.ToString().Substring(4));
            DateTime dtOut = new DateTime(Year, 1, 1);
            return dtOut.AddDays(DoY - 1);


            //string converteddate = Convert.ToString(Month) + "/" + Convert.ToString(Day) + "/" + Convert.ToString(Year);

//            return converteddate;
            
        }


    }
}
