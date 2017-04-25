<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.Invoices_RelatedInvoices>" %>

<table id='tableRelatedInvoices'>
<thead>
<tr>
<th>Invoice #</th><th>Client / Contact</th><th>Status</th>
</tr>
</thead>
<tbody>
<% 
    if (Model.relatedInvoices == null || Model.relatedInvoices.Count == 0)
    {
%>
        <tr><td colspan='3'>There are no related invoices.</td></tr>
<%
    }
    else
    {
        foreach (var item in Model.relatedInvoices)
        { 
%>
        <tr>
        <td><%= Html.Encode(item.InvoiceNumber)%></td>
        <td><%= Html.Encode(item.BillingContactName)%></td>
        <td><%= Html.Encode(item.ReleasedStatus)%></td>
        </tr>    
<%      }

    }%>
</tbody>
</table>

<script type="text/javascript">
    $(function() {
        tableToGrid('#tableRelatedInvoices');
    });
</script>