<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.TazworksImportError>" %>

<div>
<fieldset>

<%= Html.Hidden("ImportID", Model.ImportID) %>
    
<h5 id="product_info_header">Import Line Product Info</h5>

<table>
<tr>
<td align='right'>Product Type:</td>
<td><%= Html.TextBox("ProductType", Model.ProductType, new { @style = "width:250px;" }) %> 
    <%= Html.ValidationMessage("ProductType")%></td>
</tr>
<tr>
<td align='right'>Product Name:</td>
<td><%= Html.TextBox("ProductName", Model.ProductName, new { @style = "width:250px;" })%> 
    <%= Html.ValidationMessage("ProductName")%></td>
</tr>
<tr>
<td align='right'>Item Code:</td>
<td><%= Html.TextBox("ItemCode", Model.ItemCode, new { @style = "width:250px;" })%></td>
</tr>
<tr>
<td align='right'>Product Description:</td>
<td><%= Html.TextArea("ProductDesc", Model.ProductDesc, new { @style = "width:250px;height:200px;" })%>
    <%= Html.ValidationMessage("ProductDesc")%></td>
</tr>

</table>

</fieldset>
</div>