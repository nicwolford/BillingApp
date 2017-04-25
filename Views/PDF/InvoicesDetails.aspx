<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.Invoices_Details>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Details
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<script type="text/javascript">
    function editRow(invoice, invoiceLine) {
        //alert(invoice + ' | ' + invoiceLine);

        //alert($('#invoice_rows tr:nth-child(' + invoiceLine + ')').find(':nth-child(3)').html());

        var actionCol = $('#invoice_rows tr:nth-child(' + invoiceLine + ')').find(':nth-child(1) a');
        //actionCol.empty();
        actionCol.replaceWith("<a href='javascript:void(0);' onclick='saveRow(" + invoice + "," + invoiceLine + ")'>Save</a>");

        var numberOfColumns = parseInt($('#hdnNumberOfColumns').val());

        for (var curRow = 2; curRow < numberOfColumns + 2; curRow++)
        {
            var col = $('#invoice_rows tr:nth-child(' + invoiceLine + ')').find(':nth-child(' + curRow + ')');
            var colText = col.html();
            if (colText != null) {
                col.empty();
                col.append("<input type='text' value='" + colText.trim() + "' style='width:90%'/>");
            }
        }
        
        /*
        var col1 = $('#invoice_rows tr:nth-child(' + invoiceLine + ')').find(':nth-child(2)');
        var col1text = col1.html();
        col1.empty();
        col1.append("<input type='text' value='" + col1text.trim() + "' style='width:90%'/>");

        var col2 = $('#invoice_rows tr:nth-child(' + invoiceLine + ')').find(':nth-child(3)');
        var col2text = col2.html();
        col2.empty();
        col2.append("<input type='text' value='" + col2text.trim() + "' style='width:90%'/>");
        */
    }

    function saveRow(invoice, invoiceLine) {
        //alert(invoice + ' | ' + invoiceLine);

        var col1 = $('#invoice_rows tr:nth-child(' + invoiceLine + ')').find(':nth-child(2) input');
        var col1text = col1.val();
        var col2 = $('#invoice_rows tr:nth-child(' + invoiceLine + ')').find(':nth-child(3) input');
        var col2text = col2.val();
        var col3 = $('#invoice_rows tr:nth-child(' + invoiceLine + ')').find(':nth-child(4) input');
        var col3text = col3.val();
        var col4 = $('#invoice_rows tr:nth-child(' + invoiceLine + ')').find(':nth-child(5) input');
        var col4text = col4.val();
        var col5 = $('#invoice_rows tr:nth-child(' + invoiceLine + ')').find(':nth-child(6) input');
        var col5text = col5.val();
        var col6 = $('#invoice_rows tr:nth-child(' + invoiceLine + ')').find(':nth-child(7) input');
        var col6text = col6.val();
        var col7 = $('#invoice_rows tr:nth-child(' + invoiceLine + ')').find(':nth-child(8) input');
        var col7text = col7.val();
        var col8 = $('#invoice_rows tr:nth-child(' + invoiceLine + ')').find(':nth-child(9) input');
        var col8text = col8.val();

        $.post('../../Invoices/UpdateInvoiceLineText/' + invoice, { invoiceLineNumber: invoiceLine, col1Text: col1text, col2Text: col2text, col3Text: col3text, col4Text: col4text, col5Text: col5text, col6Text: col6text,
            col7Text: col7text, col8Text: col8text }, function(data) { 
                    if (data.success)
                    {
                        var actionCol = $('#invoice_rows tr:nth-child(' + invoiceLine + ')').find(':nth-child(1) a');
                        //actionCol.abc123();
                        //actionCol.empty();
                        actionCol.replaceWith("<a href='javascript:void(0);' onclick='editRow(" + invoice + "," + invoiceLine + ")'>Edit Line</a>");

                        if (col1text != null) if (col1text == '') col1.replaceWith("&nbsp;"); else col1.replaceWith(col1text.trim());
                        if (col2text != null) if (col2text == '') col2.replaceWith("&nbsp;"); else col2.replaceWith(col2text.trim());
                        if (col3text != null) if (col3text == '') col3.replaceWith("&nbsp;"); else col3.replaceWith(col3text.trim());
                        if (col4text != null) if (col4text == '') col4.replaceWith("&nbsp;"); else col4.replaceWith(col4text.trim());
                        if (col5text != null) if (col5text == '') col5.replaceWith("&nbsp;"); else col5.replaceWith(col5text.trim());
                        if (col6text != null) if (col6text == '') col6.replaceWith("&nbsp;"); else col6.replaceWith(col6text.trim());
                        if (col7text != null) if (col7text == '') col7.replaceWith("&nbsp;"); else col7.replaceWith(col7text.trim());
                        if (col8text != null) if (col8text == '') col8.replaceWith("&nbsp;"); else col8.replaceWith(col8text.trim());                 
                    }
                }, 'json');
    }
</script>

<div class="art-content-wide">

    

    <% if (!Model.toPrint)
       { %>
    <div style='float:left;'><h2>Invoice Detail</h2></div>
    <div style='float:right;margin-top:28px;margin-right:5px;'><a href='../../Invoices/PrintInvoiceToPDF/<%= Model.invoice.InvoiceID.ToString() %>'>Export to PDF</a></div>
    
    <% if (Model.invoice.BillingReportGroupID > 0) { %>
        <div style='float:right;margin-top:28px;margin-right:5px;'>
        <% if (Model.showToClient)
           { %>
            <a href='../../InvoiceReports/ClientIndex?InvoiceID=<%= Model.invoice.InvoiceID.ToString() %>&GroupID=<%= Model.invoice.BillingReportGroupID.ToString() %>'>Billing Detail Report</a>
        <% }
           else
           { %>
            <a href='../../InvoiceReports/Index?InvoiceID=<%= Model.invoice.InvoiceID.ToString() %>&GroupID=<%= Model.invoice.BillingReportGroupID.ToString() %>'>Billing Detail Report</a>
        <% } %>
        </div>
    <% } %>
    <div style='clear:both;height:0px;line-height:0px;'></div>
    
    <%= Html.Hidden("hdnNumberOfColumns",Model.numberOfColumns) %>
    
    <div style='font-size:14px; background-color:White; border:solid 1px black;padding:8px;'>
    <% }
       else
       { %>    
       
    <div style='font-size:16px;'>
    
    <% } %>
    
   
    
    <%
        int DefaultLinesPerPage = 24;
        int LinesPerPage = 24;
        int LinesAlreadyRendered = 0;
        int LinesRenderedOnPage = 0;
        //int NumberOfPages = (int)Math.Ceiling((decimal)Model.invoiceLines.Count / LinesPerPage);

        //for (int CurPage = 0; CurPage < NumberOfPages; CurPage++)
        //{
        while (true) {
            LinesRenderedOnPage = 0;
            LinesPerPage = DefaultLinesPerPage;
         %>
         
         
     <div style='margin-left:3px;float:left;'>
    
    <div style='margin-left:40px;'>
        <img src="<%=ConfigurationManager.AppSettings["logourl"] %>" style='max-width:300px; max-height:83px;' />
        <br />
    
        <div style='font-size:18px;'>
        <%=ConfigurationManager.AppSettings["billingaddress1"] %><br />
        <%=ConfigurationManager.AppSettings["billingcity"] %>, <%=ConfigurationManager.AppSettings["billingstate"] %> <%=ConfigurationManager.AppSettings["billingzipcode"] %><br />
        Phone: <%=ConfigurationManager.AppSettings["billingphone"] %><br />
        Fax: <%=ConfigurationManager.AppSettings["billingfax"] %><br />
        </div>
        
        <br /><br /><br /><br />
        
        <% if (Model.InvoiceType == "Finance Charge") { %>
            <div style='font-weight:bold;'>FINANCE CHARGE</div>
        <% } else { %>
            <div style='font-weight:bold;'>INVOICE</div>
        <% } %>
        <div style='margin-top:5px;'>
        <%= Html.Encode(Model.invoice.BillTo).Replace("|","<br/>") %>
        </div>
        </div>
    
    </div>
        
    <div style='float:right;margin-right:3px;width:20%;text-align:center;'>
    <br /><br />
    <% if (Model.InvoiceType == "Finance Charge") { %>
        <div style='font-size:32px; text-decoration:underline;font-weight:bold;'>Finance Charge</div>
    <% } else { %>
        <div style='font-size:32px; text-decoration:underline;font-weight:bold;'>Invoice</div>
    <% } %>
    <br />
    <div><span style='font-weight:bold;'>Invoice No.</span></div>
    <div style='margin-top:5px;'><%= Html.Encode(Model.invoice.InvoiceNumber) %></div>
    
    <% if (Model.InvoiceType != "Finance Charge") { %>
        <div style='margin-top:15px;'><span style='font-weight:bold;'>Services Date</span></div>
        <div style='margin-top:5px;'><%= Html.Encode(Model.invoice.ServicesDate) %></div>
        <div style='margin-top:15px;'><span style='font-weight:bold;'>Due Date</span></div>
        <div style='margin-top:5px;'><%= Html.Encode(Model.invoice.DueText) %></div>
    <% } %>
    </div>
    <div style='clear:both;'></div>
    
    <br /><br />
    
    <div style='margin-left:3px;float:left;'>
    <span style='font-weight:bold;'>Invoice Date:</span> <%= Html.Encode(Model.invoice.InvoiceDate.ToShortDateString()) %>
    </div>
    <div style='margin-right:5px;float:right;'>
    <span style='font-weight:bold;'><%= Html.Encode(Model.invoice.POName) %></span> <%= Html.Encode(Model.invoice.PONumber) %>
    </div>
    <div style='clear:both;'></div>
    
    <br />
    
    
    
    <table border='0' cellpadding='4' cellspacing='0' width='100%' style='border:solid 1px black; margin-bottom:0px;'>
    <thead style='font-weight:bold;'>
    <tr>
        <% if (!Model.toPrint && !Model.showToClient)
           { %>
        <th style='text-align:center; border-bottom:solid 1px black; border-right:solid 1px black;'>Action</th>
        <% } %>
        
    <% for (int curCol = 0; curCol < Model.numberOfColumns; curCol++)
       { %>
       <th style='text-align:center; border-bottom:solid 1px black; border-right:solid 1px black;'>
       <%= Html.Encode(Model.invoice.ColumnHeaders[curCol])%>
       </th>
    <% } %>
    
        <th style='text-align:center; border-bottom:solid 1px black;'>Amount</th>
    </tr>
    </thead>    
    <tbody id='invoice_rows'>    
    <% foreach (var item in Model.invoiceLines.Skip(LinesAlreadyRendered))
       {
           //if (item.LineNumber > (CurPage * LinesPerPage) && item.LineNumber <= ((CurPage + 1) * LinesPerPage))
           //{
           %>
    
    <tr>
    
    <% if (!Model.toPrint && !Model.showToClient)
       { %>
    <td style='border-right:solid 1px black;'>
    <a href='javascript:void(0);' onclick='javascript:editRow(<%= Model.invoice.InvoiceID.ToString() %>,<%= item.LineNumber %>);'>Edit Line</a>
    </td>
    <% } %>
    
        <% for (int curCol = 0; curCol < Model.numberOfColumns; curCol++)
           { %>
                <% if (Model.invoice.ColumnHeaders[curCol] == "Item Amount")
                   { %>
                        <td style='border-right:solid 1px black;text-align:right;'>
                <% }
                   else
                   { %>
                        <td style='border-right:solid 1px black;'>
                    <% } %>
                
                <% if (!String.IsNullOrEmpty(item.Columns[curCol]) && !String.IsNullOrEmpty(item.Columns[curCol].Trim()))
                   { %>
                        <% if (item.Columns[curCol] == "SEE ATTACHED DETAIL" && Model.invoice.BillingReportGroupID > 0)
                           { %>

                        <% if (Model.showToClient)
                           { %>
                            <a href='<%= System.Configuration.ConfigurationManager.AppSettings["DefaultPath"] + "/InvoiceReports/ClientIndex?InvoiceID=" + Model.invoice.InvoiceID.ToString() + "&GroupID=" + Model.invoice.BillingReportGroupID.ToString() %>'><%= Html.Encode(item.Columns[curCol])%></a>
                        <% }
                           else
                           { %>
                            <a href='<%= System.Configuration.ConfigurationManager.AppSettings["DefaultPath"] + "/InvoiceReports/Index?InvoiceID=" + Model.invoice.InvoiceID.ToString() + "&GroupID=" + Model.invoice.BillingReportGroupID.ToString() %>'><%= Html.Encode(item.Columns[curCol])%></a>
                        <% } %>

                        <% }
                           else
                           { %>
                                <%= Html.Encode(item.Columns[curCol])%>
                        <% } %>
                <% }
                   else
                   { %>
                    &nbsp;
                <% } %>
                </td>
                
        
        <% } %>
        
        <td style='text-align:right;'>
            <% if (item.Amount != 0)
               { %>
                    <%= Html.Encode(item.Amount.ToString("F"))%>
            <% }
               else
               { %>
                &nbsp;
            <% } %>
        </td>
    
    </tr>
        
    <% //} //end if

        if (Model.invoice.ColumnHeaders[6] == "Description")
        {
            LinesPerPage -= (int)Math.Floor((decimal)item.Columns[6].Length / 34);
        }
        else
        {
            int TotalRowLength = 0;
            if (!String.IsNullOrEmpty(item.Columns[0]))
                TotalRowLength += item.Columns[0].Length;
            if (!String.IsNullOrEmpty(item.Columns[1]))
                TotalRowLength += item.Columns[1].Length;
            if (!String.IsNullOrEmpty(item.Columns[2]))
                TotalRowLength += item.Columns[2].Length;
            if (!String.IsNullOrEmpty(item.Columns[3]))
                TotalRowLength += item.Columns[3].Length;
            if (!String.IsNullOrEmpty(item.Columns[4]))
                TotalRowLength += item.Columns[4].Length;
            if (!String.IsNullOrEmpty(item.Columns[5]))
                TotalRowLength += item.Columns[5].Length;
            if (!String.IsNullOrEmpty(item.Columns[6]))
                TotalRowLength += item.Columns[6].Length;
            if (!String.IsNullOrEmpty(item.Columns[7]))
                TotalRowLength += item.Columns[7].Length;

            if (Model.numberOfColumns < 7 && TotalRowLength > 80)
            {
                LinesPerPage -= (int)Math.Floor((decimal)TotalRowLength / 102);
            }
            else if (Model.numberOfColumns > 6 && TotalRowLength > 75)
            {
                LinesPerPage = 14;
            }
        }
           
        LinesAlreadyRendered++;
        LinesRenderedOnPage++;
        if (LinesRenderedOnPage >= LinesPerPage)
        {
            break; //exit the foreach line
        }

        //End of Invoice
        if (LinesAlreadyRendered == Model.invoiceLines.Count)
        {
            int NumberOfExtraLines=LinesPerPage-LinesRenderedOnPage;
            for (int ExtraLine = 0; ExtraLine < NumberOfExtraLines; ExtraLine++)
            {
                %>
                <tr>
                
                <% if (!Model.toPrint && !Model.showToClient)
                   { %>
                <td style='border-right:solid 1px black;'>
                    &nbsp;
                </td>
                <% } %>                
                
             <% for (int curCol = 0; curCol < Model.numberOfColumns; curCol++)
                { %>
                    <td style='border-right:solid 1px black;'>&nbsp;</td>
             <% } %>
        
                    <td style='text-align:right;'></td>
                </tr>
                <%
            }
        }
       } //end foreach %>
    </tbody>
    </table>
    
    <table width='100%' cellpadding='4' cellspacing='0' style='margin-top:0px;'>
    <tr>
    <td style='text-align:center; font-weight:bold; border:solid 1px black;'>
    For your convenience we offer payment by phone with check or credit card completely free<br /> of charge. Call 888-327-6511 x206 to pay by phone.  Thank you.
    </td>    
    <td style='text-align:right; font-weight:bold; border:solid 1px black;'>
    <span style='font-size:16px;'>Payments / Credits</span><span style='margin-left:60px;'><%= Html.Encode(Model.invoice.PaymentsAndCredits.ToString("C"))%></span>
    </td>
    </tr>
    <% //if (Model.InvoiceType != "Finance Charge")
       //{ %>
        <tr>
        <td style='text-align:center; '>
        <span style='font-weight:bold;'>All amounts not paid within 30 days from invoice date shall be assessed a finance charge.</span><br />
        Vist us online at <%=ConfigurationManager.AppSettings["websiteurl"] %>
        </td>
        <td style='text-align:right; font-weight:bold; border:solid 1px black;'>
        <span style='font-size:20px;'>Invoice Total</span><span style='margin-left:60px;'><%= Html.Encode((Model.invoice.PaymentsAndCredits + Model.invoice.InvoiceAmount).ToString("C"))%></span>
        </td>
        </tr>
    <% //} %>
    </table>
    
    <table border='0' cellpadding='5' cellspacing='0' style='width:250px; text-align:center; margin-left:213px; margin-top:20px; font-weight:bold; border:double 3px black;'>
    <tr><td>
    PLEASE REMIT TO<br />
    <%=ConfigurationManager.AppSettings["CompanyName"] %><br />
    <%=ConfigurationManager.AppSettings["billingaddress1"] %><br />
    <%=ConfigurationManager.AppSettings["billingcity"] %>, <%=ConfigurationManager.AppSettings["billingstate"] %> <%=ConfigurationManager.AppSettings["billingzipcode"] %>
    </td></tr>
    </table>
    
    <% //if (CurPage < NumberOfPages - 1)
       //{ %>
        
    <%//} %>
    
    <%  if (LinesAlreadyRendered >= Model.invoiceLines.Count)
        {
            break; //exit while
        }
        else
        { %>
            <div style='page-break-after:always;'></div>
    <% } %>
        
    
    <% } //End while %>    
    </div>

    
</div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
