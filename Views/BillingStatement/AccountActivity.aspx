<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.BillingStatement_AccountActivity>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	AccountActivity
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">

    <h2>Account Activity</h2>
    
    <div style='font-size:14px; background-color:White; border:solid 1px black;padding:8px;'>
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
                
                <div style='font-weight:bold;'>ACCOUNT ACTIVITY</div>
                <div style='margin-top:5px;'>
                <%// Html.Encode(Model.invoice.BillTo).Replace("|","<br/>") %>
                </div>
            </div>
        </div>
        
    <div style='float:right;margin-right:3px;width:20%;text-align:center;'>
        <br /><br />
        <div style='font-size:32px; text-decoration:underline;font-weight:bold;'>Account Activity</div>
        <br />
        <div><span style='font-weight:bold;'>Balance As Of</span></div>
        <div style='margin-top:5px;'><%= DateTime.Now.ToString("MM/dd/yyyy") %></div>

    </div>
    <div style='clear:both;'></div>
    
    <br /><br />
    
    <table style='width:100%;'>
    <tr style='font-weight:bold;'>
    <th style='width:150px; text-align:left;'>Invoice #</th>
    <th style='width:150px; text-align:left;'>Date</th>
    <th style='width:500px; text-align:left;'>Type</th>
    <th style='text-align:right;'>Amount</th>
    </tr>
    <% 
        decimal TotalAmount = 0;
        foreach (var item in Model.AccountActivity.accountActivityRows) { 
            TotalAmount += item.Amount; %>
    <tr>
    <td><a href='javascript:void(0)' onclick="openInvoice(<%= item.LinkID.ToString() %>)"><%= Html.Encode(item.InvoiceNumber) %></a></td>
    <td><%= Html.Encode(item.Date.ToString("MM/dd/yyyy")) %></td>    
    <td><%= Html.Encode(item.Type) %></td>
    <td style='text-align:right;'><%= Html.Encode(item.Amount.ToString("F")) %></td>
    </tr>
    
    <% } %>
    <tr>
    <td colspan='3' style='text-align:right; font-weight:bold;'>Current Balance:</td>
    <td style='text-align:right; font-weight:bold;'><%= Html.Encode(TotalAmount.ToString("C")) %></td>
    </tr>
    </table>
    
    </div>
    
    </div>

    
</div>

<script type="text/javascript">
    function openInvoice(id) {
        window.open('../../Invoices/ClientRenderInvoice/' + id);
    }
</script>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
