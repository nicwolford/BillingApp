<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.Invoices_Credit>" %>

<fieldset>

<p style='float: left;'>
<input type='hidden' id='hiddenModifyCredit' value='<%= Model.ModifyCreditID.ToString() %>' />
<input type='hidden' id='hiddenClientID' value='<%= Model.ClientID.ToString() %>' />
<input type='hidden' id='hiddenBillingContactID' value='<%= Model.BillingContactID.ToString() %>' />
<input type='hidden' id='hiddenRelatedInvoiceID' value='<%= Model.RelatedInvoiceID.ToString() %>' />
<label for='creditClientID'>Client</label>
<%// Html.DropDownList("creditBillingContactID")%>
<select id='creditClientID' style='width:550px;'></select>
<script type="text/javascript">
    var firstLoad;
    $(function() {
        firstLoad = true;
        UpdateClientsDropdownItems();

        $('#creditClientID').change(function() {
            UpdateBillingContactDropdownItems();
        });

        $('#creditBillingContactID').change(function() {
            UpdateInvoicesDropdownItems();
        });

        
    });

    function UpdateClientsDropdownItems() {
        //Billing Contact Dropdown
        $('#creditClientID').empty();
        $('#creditClientID').append(
                              $('<option></option>').val(0).html('Loading...')
                        );

        $.post("../../Clients/GetClientsWithBillingContactsForDropdownJSON/", function(data) {
            $('#creditClientID').empty();
            for (i = 0; i < data.rows.length; i++) {
                $('#creditClientID').append(
                              $('<option></option>').val(data.rows[i].Value).html(data.rows[i].Text)
                        );
            }

            //alert($('#hiddenClientID').val());
            if ($('#hiddenClientID').val() > 0 && firstLoad) {
                $('#creditClientID').val($('#hiddenClientID').val());
                UpdateBillingContactDropdownItems();
            }
            else {
                if ($('#selClient').val() > 0) {
                    $('#creditClientID').val($('#selClient').val());
                    UpdateBillingContactDropdownItems();
                }
            }

        }, 'json');
    }
    

    function UpdateBillingContactDropdownItems() {
        //Billing Contact Dropdown
        $.post("../../Invoices/GetBillingContactsForClient/" + $('#creditClientID').val(), function(data) {
            $('#creditBillingContactID').empty();
            for (i = 0; i < data.rows.length; i++) {
                $('#creditBillingContactID').append(
                              $('<option></option>').val(data.rows[i].Value).html(data.rows[i].Text)
                        );
            }
            if ($('#hiddenBillingContactID').val() > 0 && firstLoad) {
                $('#creditBillingContactID').val($('#hiddenBillingContactID').val());
            }
            UpdateInvoicesDropdownItems();
        }, 'json');
    }

    function UpdateInvoicesDropdownItems() {
        //Billing Contact Dropdown
        $.post("../../Invoices/GetUnpaidInvoicesForBillingContactForDropdown/" + $('#creditBillingContactID').val(), function(data) {
            $('#creditInvoiceID').empty();
            $('#creditInvoiceID').append(
                              $('<option></option>').val(0).html("[Do not Attach to an Invoice]")
                        );
            for (i = 0; i < data.rows.length; i++) {
                $('#creditInvoiceID').append(
                              $('<option></option>').val(data.rows[i].Value).html(data.rows[i].Text)
                        );
            }

            if ($('#hiddenRelatedInvoiceID').val() > 0 && firstLoad) {
                $('#creditInvoiceID').val($('#hiddenRelatedInvoiceID').val());
            }
            firstLoad = false;
        }, 'json');
    }
</script>
</p>

<div style='clear:both;'></div>

<p style='float: left;'>
<label for='creditBillingContactID'>Billing Contact</label>
<select id='creditBillingContactID' style='width:550px;'></select>
</p>

<div style='clear:both;'></div>

<p style='float: left;'>
<label for='creditInvoiceID'>Attach to Invoice</label>
<select id='creditInvoiceID' style='width:550px;'></select>
</p>

<div style='clear:both;'></div>

<p style='float: left;'>
<label for='creditInvoiceDate'>Date</label>
<%= Html.TextBox("creditInvoiceDate", Model.InvoiceDate.ToString("MM/dd/yyyy"), new { @style = "width:105px;" } )%>
<script type="text/javascript">
    $(function() {
        $('#creditInvoiceDate').datepicker({ showOn: 'both', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true,
            changeMonth: true, changeYear: true
        });
    });
</script>
</p>

<p style='float: left;'>
<label for='creditPublicDescription'>Description (Client CAN see)</label>
<%= Html.TextBox("creditPublicDescription", Model.PublicDescription, new { @style = "width:400px;" })%>
</p>

<div style='clear:both;'></div>

<p style='float: left;'>
<label for='creditPrivateDescription'>Description (Client CAN NOT see)</label>
<%= Html.TextBox("creditPrivateDescription", Model.PrivateDescription, new { @style = "width:400px;" })%>
</p>

<p style='float: left;'>
<label for='creditAmount'>Amount</label>
<%= Html.TextBox("creditAmount", Model.InvoiceAmount.ToString("F"), new { @style = "width:120px;" })%>
</p>

<div style='clear:both;'></div>
</fieldset>