<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.BillingStatement_Index>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Index
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
<% if (!Model.toPrint)
       { %>
       
    <div style='float:left;'><h2>Billing Statement</h2></div>
    <div style='float:right;margin-top:28px;margin-right:5px;'><a href='../../BillingStatement/Home/<%= Model.BillingContactID %>'>Back to Billing</a>
     &nbsp; <a href='javascript:void(0)' id='linkHaveAQuestion'>Have a Question about this Statement?</a>
     &nbsp; <a href='../../BillingStatement/PrintBillingStatementToPDF/<%= Model.BillingContactID %>'>Export to PDF</a></div>
    <div style='clear:both'></div>
    
<div style='font-size:10px; background-color:White; border:solid 1px black;padding:8px;'>
    <% }
       else
       { %>    
       
    <div style='font-size:10px;'>
    
    <% } %>
    
    <div style='font-size:16px;'>
    
        <div style='margin-left:3px;float:left;'>
            <div style='margin-left:40px;'>
                <img src="<%=ConfigurationManager.AppSettings["logourl"] %>" alt='Logo' style='max-width:300px; max-height:83px;' />
                <br />
            
                <div style='font-size:18px;'>
                <%=ConfigurationManager.AppSettings["billingaddress1"] %><br />
                <%=ConfigurationManager.AppSettings["billingcity"] %>, <%=ConfigurationManager.AppSettings["billingstate"] %> <%=ConfigurationManager.AppSettings["billingzipcode"] %><br />
                Phone: <%=ConfigurationManager.AppSettings["billingphone"] %><br />
                Fax: <%=ConfigurationManager.AppSettings["billingfax"] %><br />
                </div>
                
                <br /><br /><br /><br />
                
                <div style='font-weight:bold;'>BILLING STATEMENT</div>
                <div style='margin-top:5px;'>
                <%= Html.Encode(Model.BillingStatement.billingContact.BillAsClientName) %><br />
                <% if (String.IsNullOrEmpty(Html.Encode(Model.BillingStatement.billingContact.BillingContactName)))
                   { %>
                        Attn: Accounts Payable
                    <% }
                   else
                   { %>
                        <%= Html.Encode(Model.BillingStatement.billingContact.BillingContactName)%>
                    <% } %>
                    <br />
                <%= Html.Encode(Model.BillingStatement.billingContact.ClientContactAddress1) %><br />
                
                <% if (!String.IsNullOrEmpty(Model.BillingStatement.billingContact.ClientContactAddress2))
                   { %>
                        <%= Html.Encode(Model.BillingStatement.billingContact.ClientContactAddress2) %><br />
                <% } %>
                
                <%= Html.Encode(Model.BillingStatement.billingContact.ClientContactCity) %>, 
                <%= Html.Encode(Model.BillingStatement.billingContact.ClientContactStateCode) %> 
                <%= Html.Encode(Model.BillingStatement.billingContact.ClientContactZIP) %>
                <br />
                </div>
            </div>
        </div>
        
    <div style='float:right;margin-right:3px;width:20%;text-align:center;'>
        <br /><br />
        <div style='font-size:32px; text-decoration:underline;font-weight:bold;'>Billing Statement</div>
        <br />
        <div><span style='font-weight:bold;'>Statement Date</span></div>
        <div style='margin-top:5px;'><%= Model.StatementDate.ToString("MM/dd/yyyy") %></div>
        <div style='margin-top:15px;'><span style='font-weight:bold;'>Due Date</span></div>
        <div style='margin-top:5px;'><%= Html.Encode(Model.BillingStatement.billingContact.DueText) %></div>
    </div>
    <div style='clear:both;'></div>
    
    <br /><br />
    
    <table border='0' cellpadding='4' cellspacing='0' width='100%' style='border:solid 1px black; margin-bottom:0px;'>
    <thead style='font-weight:bold;'>
    <tr>
    <th style='width:150px; text-align:left; border-bottom:solid 1px black; border-right:solid 1px black;'>Date</th>
    <th style='width:150px; text-align:left; border-bottom:solid 1px black; border-right:solid 1px black;'>Invoice #</th>
    <th style='width:450px; text-align:left; border-bottom:solid 1px black; border-right:solid 1px black;'>Description</th>
    <th style='text-align:right; border-bottom:solid 1px black; border-right:solid 1px black;'>Amount</th>
    <th style='text-align:right; border-bottom:solid 1px black;'>Balance</th>    
    </tr>
    </thead>
    <% 
        decimal TotalAmount = 0;
        foreach (var item in Model.BillingStatement.billingStatementRows) { 
            TotalAmount += item.Amount; %>
    <tr>
    <td style='border-right:solid 1px black;'><%= (item.Date.HasValue ? Html.Encode(item.Date.Value.ToString("MM/dd/yyyy")) : "&nbsp;") %></td>
    
    <% if (item.LinkID != 0)
       { %>
            <td style='border-right:solid 1px black;'><a href='javascript:void(0)' onclick="openInvoice(<%= item.LinkID.ToString() %>)"><%= Html.Encode(item.InvoiceNumber)%></a></td>
    <% }
       else
       {
           if (!String.IsNullOrEmpty(item.InvoiceNumber))
           {
           %>
                <td style='border-right:solid 1px black;'><%= Html.Encode(item.InvoiceNumber)%></td>
            <% 
           } 
           else 
           { %>
                <td style='border-right:solid 1px black;'>&nbsp;</td>
         <% }       
      } %>
    
    
    
    <td style='border-right:solid 1px black;'><%= Html.Encode(item.Type) %></td>
    <td style='text-align:right; border-right:solid 1px black;'><%= Html.Encode(item.Amount.ToString("F")) %></td>
    <td style='text-align:right;'><%= Html.Encode(TotalAmount.ToString("F")) %></td>
    </tr>
    
    <% } %>
    </table>
    
    <table width='100%' cellpadding='4' cellspacing='0' style='margin-top:0px;'>
    <tr>
    <td style='text-align:center; font-weight:bold; border:solid 1px black;'>
    For your convenience we offer payment by phone with check or credit card completely free<br /> of charge. Call 888-327-6511 x206 to pay by phone.  Thank you.
    </td>    
    <td style='text-align:right; font-weight:bold; border:solid 1px black;'>
    <span style='font-size:20px;'>Total Due</span><span style='margin-left:60px;'><%= Html.Encode((TotalAmount < 0 ? 0 : TotalAmount).ToString("C"))%></span>
    </td>
    </tr>
    <tr>
    <td style='text-align:center; font-weight:bold;'>
    All amounts not paid within 30 days from invoice date shall be assessed a finance charge.
    </td>
    <td>&nbsp;</td>
    </tr>
    <tr>
    <td style='text-align:center;'>
    Vist us online at <%=ConfigurationManager.AppSettings["websiteurl"] %>
    </td>
    <td>&nbsp;</td>
    </tr>
    </table>
    
    <table border='0' cellpadding='5' cellspacing='0' style='width:250px; text-align:center; margin-left:213px; margin-top:20px; font-weight:bold; border:double 3px black;'>
    <tr><td>
    PLEASE REMIT TO<br />
    <%=ConfigurationManager.AppSettings["CompanyName"] %><br />
    <%=ConfigurationManager.AppSettings["billingaddress1"] %><br />
    <%=ConfigurationManager.AppSettings["billingcity"] %>, <%=ConfigurationManager.AppSettings["billingstate"] %> <%=ConfigurationManager.AppSettings["billingzipcode"] %>
    </td></tr>
    </table>
    
    </div>
    
    </div>
</div>

<script type="text/javascript">
    $(function() { 
        $('#linkHaveAQuestion').click(function() {
            $("#CntMsgBillingMessagecontent").load('../../Help/BillingMessage?CntMsgMessageCategory=Billing%20Statement&CntMsgMessageSubject=<%= HttpUtility.UrlEncode("Billing Statement - " + Model.StatementDate.ToShortDateString()) %>');
            $("#CntMsgBillingMessagedlg").dialog('open');
        });
    });

    function openInvoice(id) {
        window.open('../../Invoices/ClientRenderInvoice/' + id);
    }
</script>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
