<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.ViewModelProducts>" %>

<style type="text/css">
    
    #vendor-list {display:inline;}
    
</style>

<div>
<fieldset>
<h5 id="product_info_header">Add Product</h5>

<table>
<tr>
<td align='right'>Product Code:</td>
<td><%= Html.TextBox("ProductCode", Model.ProductCode, new { @style = "width:200px;" }) %> *
    <%= Html.ValidationMessage("ClientName")%></td>
</tr>
<tr>
<td align='right'>Product Name:</td>
<td><%= Html.TextBox("ProductName", Model.ProductName, new { @style = "width:200px;" })%> *
    <%= Html.ValidationMessage("ProductName")%></td>
</tr>
<tr>
<td align='right'>Base Cost:</td>
<td><%= Html.TextBox("Base Cost", Model.BaseCost, new { @style = "width:100px;" })%></td>
</tr>
<tr>
<td align='right'>Base Commission:</td>
<td><%= Html.TextBox("BaseCommission", Model.BaseCommission, new { @style = "width:100px;" })%> 
    <%= Html.ValidationMessage("BaseCommission")%></td>
</tr>
<tr>
<td align='right'>Include On Invoice:</td>
<td>
    <select id="IncludeOnInvoice">
        <option value="">Select One</option>
        <option value="0">Always Show</option>
        <option value="1">Show only if Non-Zero</option>
        <option value="2">Never Show</option>
    </select> *
</td>
</tr>
<tr>
<td align='right'>Employment:</td>
<td><%= Html.TextBox("Employment", Model.Employment, new { @style = "width:100px;" })%> 
    <%= Html.ValidationMessage("Zip")%></td>
</tr>
<tr>
<td align='right'>Tenant:</td>
<td><%= Html.TextBox("Tenant", Model.Tenant, new { @style = "width:100px;" })%> 
    <%= Html.ValidationMessage("Tenant")%></td>
</tr>
<tr>
<td align='right'>Business:</td>
<td><%= Html.TextBox("Business", Model.Business, new { @style = "width:100px;" })%> 
    <%= Html.ValidationMessage("Business")%></td>
</tr>

<tr>
<td align='right'>Volunteer:</td>
<td><%= Html.TextBox("Volunteer", Model.Volunteer, new { @style = "width:100px;" })%> 
    <%= Html.ValidationMessage("Volunteer")%></td>
</tr>

<tr>
<td align='right'>Other:</td>
<td><%= Html.TextBox("Other", Model.Other, new { @style = "width:100px;" })%> 
    <%= Html.ValidationMessage("Other")%></td>
</tr>

<tr>
    <td align="right" valign="top">Vendors:</td>
    <td align="left" valign="top">
        <ul id="vendor-list">
            <li>&nbsp;</li>
            <li><input type="checkbox" id="vendor2" name="vendor2" /><label class="inline" for="vendor2"> Tazworks 2.0</label></li>
            <li><input type="checkbox" id="vendor4" name="vendor4" /><label class="inline" for="vendor4"> TransUnion</label></li>
            <li><input type="checkbox" id="vendor5" name="vendor5" /><label class="inline" for="vendor5"> Experian</label></li>
            <li><input type="checkbox" id="vendor6" name="vendor6" /><label class="inline" for="vendor6"> ScreeningOne</label></li>
            <li><input type="checkbox" id="vendor7" name="vendor7" /><label class="inline" for="vendor7"> ApplicantOne</label></li>
            <li><input type="checkbox" id="vendor8" name="vendor8" /><label class="inline" for="vendor8"> eDrug</label></li>
        </ul>
    </td>
</tr>

</table>

</fieldset>
</div>