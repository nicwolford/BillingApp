<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.ProductTransactions_Add>" %>

<fieldset>

<p>
<label for="addClient">Client:</label>
<%= Html.DropDownList("addClient", Model.selectListClients, new { @style = "width:500px;" })%>
</p>

<p>
<label for="addVendor">Vendor:</label>
<%= Html.DropDownList("addVendor", Model.selectListVendors, new { @style = "width:500px;" })%>
</p>

<p>
<label for="addProduct">Product:</label>
<select id='addProduct' style='width:500px;'></select>
<%// Html.DropDownList("Product", Model.selectListProducts, new { @style = "width:500px;" })%>
</p>


<p style='float:left;margin-bottom:3px;'>
<label for="addTransactionDate">Transaction Date:</label>
<%= Html.TextBox("addTransactionDate", Model.TransactionDate.ToShortDateString(), new { @style = "width:120px;" })%>
</p>

<p style='float:left;margin-bottom:3px;'>
<label for="addDateOrdered">Date Ordered:</label>
<%= Html.TextBox("addDateOrdered", Model.TransactionDate.ToShortDateString(), new { @style = "width:120px;" })%>
</p>

<script type="text/javascript">
    $(function() {
        $('#addTransactionDate').datepicker({ showOn: 'both', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true, changeMonth: true, changeYear: true });
        $('#addDateOrdered').datepicker({ showOn: 'both', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true, changeMonth: true, changeYear: true });
        $('#addClient').change(onClientChange);
        $('#addVendor').change(onVendorChange);
    });

    function onClientChange() {
        UpdateProductsDropdownItems();
    }

    function onVendorChange() {
        UpdateProductsDropdownItems();
    }

    function UpdateProductsDropdownItems() {
        $('#addProduct').empty();
        $('#addProduct').append(
                              $('<option></option>').val(0).html('Loading...')
                        );

        $.post("../../Products/GetProductsFromClientAndVendorForDropdownJSON?ClientID=" + $('#addClient').val() + "&VendorID=" + $('#addVendor').val(), function(data) {
            $('#addProduct').empty();
            for (i = 0; i < data.rows.length; i++) {
                $('#addProduct').append(
                              $('<option></option>').val(data.rows[i].Value).html(data.rows[i].Text)
                        );
            }

            //$("select#Product option[value='" + $('#ProductID').val() + "']").attr('selected', 'selected');
            //$('select#Product').change(onChangeProduct);
        }, 'json');
    }
</script>

<div style='clear:both;line-height:0px;height:0px;margin:0;padding:0;'>&nbsp;</div>

<p>
<label for="addFileNum">File #:</label>
<%= Html.TextBox("addFileNum", "", new { @style = "width:150px;" })%>
</p>

<p>
<label for="addProductDescription">Product Description:</label>
<%= Html.TextBox("addProductDescription", "", new { @style = "width:300px;" })%>
</p>

<p>
<label for="addProductDescription">Product Type:</label>
<%= Html.TextBox("addProductType", "", new { @style = "width:300px;" })%>
</p>

<p style='float:left;margin-bottom:3px;'>
<label for="addReference">Reference:</label>
<%= Html.TextBox("addReference", "", new { @style = "width:200px;" })%>
</p>

<p style='float:left;margin-bottom:3px;'>
<label for="addOrderedBy">Ordered By:</label>
<%= Html.TextBox("addOrderedBy", "", new { @style = "width:200px;" })%>
</p>

<div style='clear:both;line-height:0px;height:0px;margin:0;padding:0;'>&nbsp;</div>

<p>
<label for="addFName">Name:</label>
<%= Html.TextBox("addFName", "", new { @style = "width:120px;" })%>
<%= Html.TextBox("addMName", "", new { @style = "width:100px;" })%>
<%= Html.TextBox("addLName", "", new { @style = "width:160px;" })%>
</p>

<p>
<label for="addSSN">SSN:</label>
<%= Html.TextBox("addSSN", "", new { @style = "width:200px;" })%>
</p>

<p>
<label for="addBasePrice">Base Price:</label>

<% if (false)
   { //Imports at Base Price %>
    <%= Html.TextBox("addBasePrice", "", new { @style = "width:120px;" })%>
<% }
   else
   { //Imports at Sales Price %>
    <%= Html.Encode("0.00")%>
    <%= Html.Hidden("addBasePrice", "0.00")%>
<% } %>
</p>

<p>
<label for="addProductPrice">Product Price:</label>

<% if (true)
   { //Imports at Sales Price %>
    <%= Html.TextBox("addProductPrice", "", new { @style = "width:120px;" })%>
<% }
   else
   { //Imports at Base Price %>
    <%= Html.Encode("0.00")%>
    <%= Html.Hidden("addProductPrice", "0.00")%>
<% } %>
</p>

<%= Html.Hidden("addImportsAtBaseOrSales", "")%>
</fieldset>