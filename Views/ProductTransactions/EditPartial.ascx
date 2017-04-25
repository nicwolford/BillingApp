<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.ProductTransactions_Edit>" %>

<fieldset>

<%= Html.Hidden("ProductTransactionID",Model.productTransaction.ProductTransactionID) %>

<p>
<label for="Client">Client:</label>
<span id='spnClient' style='font-weight:bold;'><%= Html.Encode(Model.productTransaction.ClientName)%></span>
<select id='Client' style='width:500px; display:none;'></select>
<a href='javascript:void(0);' id='lnkClient'>Change</a>
<%= Html.Hidden("ClientID",Model.productTransaction.ClientID.ToString()) %>
</p>

<p>
<label for="Vendor">Vendor:</label>
<span id='spnVendor' style='font-weight:bold;'><%= Html.Encode(Model.productTransaction.VendorName)%></span>
<select id='Vendor' style='width:500px; display:none;'></select>
<a href='javascript:void(0);' id='lnkVendor'>Change</a>
<%= Html.Hidden("VendorID",Model.productTransaction.VendorID.ToString()) %>
</p>

<p>
<label for="Product">Product:</label>
<span id='spnProduct' style='font-weight:bold;'><%= Html.Encode(Model.productTransaction.ProductName)%></span>
<select id='Product' style='width:500px; display:none;'></select>
<a href='javascript:void(0);' id='lnkProduct'>Change</a>
<%= Html.Hidden("ProductID",Model.productTransaction.ProductID.ToString()) %>
</p>


<p style='float:left;margin-bottom:3px;'>
<label for="TransactionDate">Transaction Date:</label>
<%= Html.TextBox("TransactionDate", Model.productTransaction.TransactionDate.ToShortDateString(), new { @style = "width:120px;" })%>
</p>

<p style='float:left;margin-bottom:3px;'>
<label for="DateOrdered">Date Ordered:</label>
<%= Html.TextBox("DateOrdered", Model.productTransaction.DateOrdered.ToShortDateString(), new { @style = "width:120px;" })%>
</p>

<script type="text/javascript">
    $(function() {
        $('#TransactionDate').datepicker({ showOn: 'both', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true, changeMonth: true, changeYear: true });
        $('#DateOrdered').datepicker({ showOn: 'both', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true, changeMonth: true, changeYear: true });

        //UpdateClientsDropdownItems();
    });

    $('#lnkClient').click(showChangeClient);
    $('#lnkVendor').click(showChangeVendor);
    $('#lnkProduct').click(showChangeProduct);

    function showChangeClient() {
        $('#spnClient').hide();
        $('#Client').show();
        $('#lnkClient').hide();
        UpdateClientsDropdownItems();
    }

    function onChangeClient() {
        $('#ClientID').val($('select#Client option:selected').val());
    }

    function showChangeVendor() {
        $('#spnVendor').hide();
        $('#Vendor').show();
        $('#lnkVendor').hide();
        UpdateVendorsDropdownItems();
    }

    function onChangeVendor() {
        $('#VendorID').val($('select#Vendor option:selected').val());
    }

    function showChangeProduct() {
        $('#spnProduct').hide();
        $('#Product').show();
        $('#lnkProduct').hide();
        UpdateProductsDropdownItems();
    }

    function onChangeProduct() {
        $('#ProductID').val($('select#Product option:selected').val());
    }

function UpdateClientsDropdownItems() {
    $('#Client').empty();
    $('#Client').append(
                              $('<option></option>').val(0).html('Loading...')
                        );

    $.post("../../Clients/GetClientsForDropdownJSON/", function(data) {
        $('#Client').empty();
        for (i = 0; i < data.rows.length; i++) {
            $('#Client').append(
                              $('<option></option>').val(data.rows[i].Value).html(data.rows[i].Text)
                        );
        }

        $("select#Client option[value='" + $('#ClientID').val() + "']").attr('selected', 'selected');
        $('select#Client').change(onChangeClient);
    }, 'json');
}

function UpdateVendorsDropdownItems() {
    $('#Vendor').empty();
    $('#Vendor').append(
                              $('<option></option>').val(0).html('Loading...')
                        );

    $.post("../../Vendors/GetVendorsForDropdownJSON/", function(data) {
        $('#Vendor').empty();
        for (i = 0; i < data.rows.length; i++) {
            $('#Vendor').append(
                              $('<option></option>').val(data.rows[i].Value).html(data.rows[i].Text)
                        );
        }

        $("select#Vendor option[value='" + $('#VendorID').val() + "']").attr('selected', 'selected');
        $('select#Vendor').change(onChangeVendor);
    }, 'json');
}

function UpdateProductsDropdownItems() {
    $('#Product').empty();
    $('#Product').append(
                              $('<option></option>').val(0).html('Loading...')
                        );

    $.post("../../Products/GetProductsForDropdownJSON/", function(data) {
        $('#Product').empty();
        for (i = 0; i < data.rows.length; i++) {
            $('#Product').append(
                              $('<option></option>').val(data.rows[i].Value).html(data.rows[i].Text)
                        );
        }

        $("select#Product option[value='" + $('#ProductID').val() + "']").attr('selected', 'selected');
        $('select#Product').change(onChangeProduct);
    }, 'json');
}
</script>

<div style='clear:both;line-height:0px;height:0px;margin:0;padding:0;'>&nbsp;</div>

<p>
<label for="FileNum">File #:</label>
<%= Html.TextBox("FileNum", Model.productTransaction.FileNum, new { @style = "width:150px;" })%>
</p>

<p>
<label for="ProductDescription">Product Description:</label>
<%= Html.TextBox("ProductDescription", Model.productTransaction.ProductDescription, new { @style = "width:300px;" })%>
</p>

<p>
<label for="ProductDescription">Product Type:</label>
<%= Html.TextBox("ProductType", Model.productTransaction.ProductType, new { @style = "width:300px;" })%>
</p>

<p style='float:left;margin-bottom:3px;'>
<label for="Reference">Reference:</label>
<%= Html.TextBox("Reference", Model.productTransaction.Reference, new { @style = "width:200px;" })%>
</p>

<p style='float:left;margin-bottom:3px;'>
<label for="OrderedBy">Ordered By:</label>
<%= Html.TextBox("OrderedBy", Model.productTransaction.OrderedBy, new { @style = "width:200px;" })%>
</p>

<div style='clear:both;line-height:0px;height:0px;margin:0;padding:0;'>&nbsp;</div>

<p>
<label for="FName">Name:</label>
<%= Html.TextBox("FName", Model.productTransaction.FName, new { @style = "width:120px;" })%>
<%= Html.TextBox("MName", Model.productTransaction.MName, new { @style = "width:100px;" })%>
<%= Html.TextBox("LName", Model.productTransaction.LName, new { @style = "width:160px;" })%>
</p>

<p>
<label for="SSN">SSN:</label>
<%= Html.TextBox("SSN", Model.productTransaction.SSN, new { @style = "width:200px;" })%>
</p>

<p>
<label for="BasePrice">Base Price:</label>

<% if (!Model.productTransaction.ImportsAtBaseOrSales)
   { //Imports at Base Price %>
    <%= Html.TextBox("BasePrice", Model.productTransaction.BasePrice.ToString("F"), new { @style = "width:120px;" })%>
<% }
   else
   { //Imports at Sales Price %>
    <%= Html.Encode(Model.productTransaction.BasePrice.ToString("F"))%>
    <%= Html.Hidden("BasePrice", Model.productTransaction.BasePrice.ToString("F"))%>
<% } %>
</p>

<p>
<label for="ProductPrice">Product Price:</label>

<% if (Model.productTransaction.ImportsAtBaseOrSales)
   { //Imports at Sales Price %>
    <%= Html.TextBox("ProductPrice", Model.productTransaction.ProductPrice.ToString("F"), new { @style = "width:120px;" })%>
<% }
   else
   { //Imports at Base Price %>
    <%= Html.Encode(Model.productTransaction.ProductPrice.ToString("F"))%>
    <%= Html.Hidden("ProductPrice", Model.productTransaction.ProductPrice.ToString("F"))%>
<% } %>
</p>

<%= Html.Hidden("ImportsAtBaseOrSales", Model.productTransaction.ImportsAtBaseOrSales)%>
</fieldset>