<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.Invoices_VerifyInvoiceSetup>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Verify Invoice Setup
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
    <h2>Verify Invoice Setup</h2>
    
    <table border='1' cellpadding='3' cellspacing='0' style='width:100%'>
    <tr>
    <th>Error</th>
    <th>Client ID</th>
    <th>Client Name</th>
    <th>Product ID</th>
    <th>Product Name</th>
    </tr>
    <% foreach (var item in Model.invoiceVerifySetups) { %>
    
    <tr>
    <td><%= Html.Encode(item.DataSetName) %></td>
    <td><%= Html.Encode(item.ClientID.ToString()) %></td>
    <td><%= Html.Encode(item.ClientName) %></td>
    <td><%= Html.Encode(item.ProductID.ToString()) %></td>
    <td><%= Html.Encode(item.ProductName) %></td>
    </tr>
    
    <% } %>
    </table>
</div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
