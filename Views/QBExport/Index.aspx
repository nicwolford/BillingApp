<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.QBExport_Index>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	QuickBooks Export
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
    <h2>QuickBooks Export</h2>
    
    <%= Html.ActionLink("Refresh Page","Index") %><br /><br />
    
    
    <div id="accordion">
    
        <h3><a href="#">Export Log</a></h3>
        <div>
        
            <table cellpadding='2' cellspacing='1'>
            <tr>
            <th>Export Step</th>
            <th>&nbsp; </th>
            <th>Date/Time</th>
            <th>&nbsp; </th>
            </tr>
            <% foreach (var item in Model.exportLog)
               { %>
            <tr>
            
            <% switch (item.ExportStep) 
               { 
                   case 0:%>
                        <td>Payments Imported 2 - Done!</td>
                    <% break; %>
                    <% case 1:%>
                        <td>Invoices Exported</td>
                    <% break; %>
                    <% case 2:%>
                        <td>Finance Charges Exported</td>
                    <% break; %>
                    <% case 3:%>
                        <td>Credits Exported - Step 1 of 3</td>
                    <% break; %>
                    <% case 4:%>
                        <td>Credits Exported - Step 2 of 3</td>
                    <% break; %>
                    <% case 5:%>
                        <td>Credits Exported - Step 3 of 3</td>
                    <% break; %>
                    <% case 6:%>
                        <td>Payments Imported 1</td>
                    <% break; %>

            
            <% } %>
                <td>&nbsp;</td>
                <td><%= Html.Encode(item.ExportTimeString)%></td>
                <td align="right"><%= Html.ActionLink("Remove", "DeleteExportStep", new { id=item.QBExportLogID })%></td>
            </tr>
            <% } %>
            </table>
            
        </div>
        
        <h3><a href="#">Invoices To Export</a></h3>
        <div>
        
            <% if (Model.invoicesToExport.Count == 0)
               { %>
                    <b>No Invoices To Export</b><br /><br />
            <% }
               else
               { %>
        
                    <table cellpadding='2' cellspacing='1'>
                    <tr>
                    <th>Invoice #</th>
                    <th>&nbsp;</th>
                    <th>Invoice Date</th>
                    <th>QuickBooks Client Name</th>
                    </tr>
                    <% foreach (var invoice in Model.invoicesToExport)
                       { %>
                    
                        <tr>
                        <td><%= Html.Encode(invoice.InvoiceNumber)%></td>
                        <td>&nbsp;</td>
                        <td><%= Html.Encode(invoice.InvoiceDate.ToShortDateString())%></td>
                        <td><%= Html.Encode(invoice.ClientName)%></td>
                        </tr>
                    
                    <% } %>
                    </table>
            
            <% } %>
        
        </div>
    
    </div>
    
    <br />
    
    <a href='../../Invoices/GetInvoicesXML/<%= Model.SecurityGUID %>' target='_blank'>Get Invoices XML</a> - 
    <a href='../../Invoices/GetFinanceChargesXML/<%= Model.SecurityGUID %>' target='_blank'>Get FinanceCharges XML</a> - 
    <a href='../../Invoices/GetCreditMemosXML/<%= Model.SecurityGUID %>' target='_blank'>Get Credits XML</a>
</div>

    <script type="text/javascript">
        $(function() {
            $("#accordion").accordion({ collapsible: true, autoHeight: false });
        });
	</script>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
