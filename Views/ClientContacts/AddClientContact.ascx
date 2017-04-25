<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.ClientContacts_Details>" %>


<script type="text/javascript">
    $(function() {
        $('#addclientcontacttabs').tabs();
        $('#addclientcontacttabs').show();
        $('#FillBillingContact').click(fillBillingTab);
        $('#lblFillBillingContact').text(' Prefill the next tab?');
        $('#lblSendUserEmail').text(' Send UserID Email if new User?');
        $('#disEmail').text('');
        $('#disEmail').hide('');
        $('#ClientContactStatus').hide();
        $('#BillingContactStatus').hide();
        $('#rwClientContactStatus').hide();
        $('#rwBillingContactStatus').hide();
        $('#OnlyShowInvoices').hide();
        $('#IsPrimaryBillingContact').click(setShowInvoices);
        $('#NewPrimaryContact').change(onChangeContact);


        if ('<%=Model.IsPrimaryBillingContact%>' == 'True') {
            $('#IsPrimaryBillingContact').attr('checked', true);
        }

        if ('<%=Model.OnlyShowInvoices%>' == 'True') {
            $('#OnlyShowInvoices').attr('checked', true);
        }

        if ($('#cmdType').val() == 'update') {
            $('#lblFillBillingContact').text('');
            $('#FillBillingContact').hide();
            $('#lblSendUserEmail').text('');
            $('#SendUserEmail').hide();
            $('#BillingContactStatus').show();
            $('#rwBillingContactStatus').show();
            $('#ClientContactStatus').show();
            $('#rwClientContactStatus').show();
            $('#ClientContactEmail').attr("disabled", true);
            $('#disEmail').show('');
            $('#disEmail').text('(change in Security)');
        }

        $('#ClientContactEmail').blur(function() {
            $.post('../../ClientContacts/GetClientContactFromEmail', { Email: $('#ClientContactEmail').val() }, function(data) {


                if (data.success) {
                    $('#ClientContactID').val(data.clientcontact.ClientContactID);
                    $('#ClientContactFirstName').val(data.clientcontact.ClientContactFirstName);
                    $('#ClientContactLastName').val(data.clientcontact.ClientContactLastName);
                    $('#ClientContactTitle').val(data.clientcontact.ClientContactTitle);
                    $('#ClientContactAddress1').val(data.clientcontact.ClientContactAddress1);
                    $('#ClientContactAddress2').val(data.clientcontact.ClientContactAddress2);
                    $('#ClientContactCity').val(data.clientcontact.ClientContactCity);
                    $('#ClientContactStateCode').val(data.clientcontact.ClientContactStateCode);
                    $('#ClientContactZIP').val(data.clientcontact.ClientContactZIP);
                    $('#ClientContactBusinessPhone').val(data.clientcontact.ClientContactBusinessPhone);
                    $('#ClientContactCellPhone').val(data.clientcontact.ClientContactCellPhone);
                    $('#ClientContactFax').val(data.clientcontact.ClientContactFax);

                }
                else {
                    $('#ClientContactAddress1').val($('#Address1').val());
                    $('#ClientContactAddress2').val($('#Address2').val());
                    $('#ClientContactCity').val($('#City').val());
                    $('#ClientContactStateCode').val($('#State').val());
                    $('#ClientContactZIP').val($('#Zip').val());

                }
            }, 'json');
        })
    });

    function fillBillingTab() {

            if ($('#FillBillingContact').is(':checked')) {
                    $('#BillingContactName').val($('#ClientContactFirstName').val() + ' ' + $('#ClientContactLastName').val());
                    $('#BillingContactAddress1').val($('#ClientContactAddress1').val());
                    $('#BillingContactAddress2').val($('#ClientContactAddress2').val());
                    $('#BillingContactCity').val($('#ClientContactCity').val());
                    $('#BillingContactStateCode').val($('#ClientContactStateCode').val());
                    $('#BillingContactZIP').val($('#ClientContactZIP').val());
                    $('#BillingContactBusinessPhone').val($('#ClientContactBusinessPhone').val());
                    $('#BillingContactFax').val($('#ClientContactFax').val());
                    $('#addclientcontacttabs').tabs('select', 'tb2');


            }
            else {
                $('#BillingContactName').val('');
                $('#BillingContactAddress1').val('');
                $('#BillingContactAddress1').val('');
                $('#BillingContactCity').val('');
                $('#BillingContactStateCode').val('');
                $('#BillingContactZIP').val('');
                $('#BillingContactBusinessPhone').val('');
                $('#BillingContactFax').val('');
                $('#BillingContactPOName').val('');
                $('#BillingContactPONumber').val('');

            }
    }

    function setShowInvoices() {

        if ($('#IsPrimaryBillingContact').is(':checked')) {

            $('#OnlyShowInvoices').attr('checked', false);
            $('#trNewPrimaryContact').hide();
            $('#NewPrimaryContactID').val(0);
            
        }
        else {
            $('#OnlyShowInvoices').attr('checked', true);

            if ('<%=Model.IsPrimaryBillingContact%>' == 'True') {
                showChangeContact();        
            
            }
            
        }
    }


    function showChangeContact() {
        $('#trNewPrimaryContact').show();
        UpdateContactsDropdownItems();
    }

    function onChangeContact() {
        $('#NewPrimaryContactID').val($('select#NewPrimaryContact option:selected').val());
    }

    function UpdateContactsDropdownItems() {
        $('#NewPrimaryContact').empty();
        $('#NewPrimaryContact').append(
                              $('<option></option>').val(0).html('Loading...')
                        );

        $.post("../../ClientContacts/GetClientContactsForDropdownJSON/<%=Model.ClientID%>", function(data) {
            $('#NewPrimaryContact').empty();
            for (i = 0; i < data.rows.length; i++) {
                $('#NewPrimaryContact').append(
                                  $('<option></option>').val(data.rows[i].Value).html(data.rows[i].Text)
                            );
            }

            //$('#NewPrimaryContact').find('option[value=' + $('#NewPrimaryContactID').val() + ']').attr('selected', 'selected');
            $('#NewPrimaryContactID').val($('select#NewPrimaryContact option:selected').val());
        }, 'json');
    }
    
</script> 


<div id='addclientcontacttabs' style='display:none;'>
        <ul>
            <li id='tb1'><a href="#addclientcontact-tab-1">Contact Info</a></li>
            <li id='tb2'><a href="#addclientcontact-tab-2">Billing Info</a></li>
        </ul> 
<div id='addclientcontact-tab-1'>

<%=Html.Hidden("cmdType", Model.cmdType)%>
<%=Html.Hidden("ClientID", Model.ClientID)%>
<%=Html.Hidden("BillingContactID", Model.BillingContactID)%>
<%=Html.Hidden("ClientContactID", Model.ClientContactID)%>
<%=Html.Hidden("UserID", Model.UserID)%>
<%= Html.ValidationMessage("ErrorMessages")%>
<fieldset>

<table id="tblClientContact">
<tr>
<td align="right"><b>Email:</b></td>
<td><%= Html.TextBox("ClientContactEmail", Model.ClientContactEmail, new { @style = "width:200px;" })%> *
    <%= Html.ValidationMessage("ClientContactEmail")%><span id="disEmail" style="font-size:10px"></span></td>
</tr>
<tr>
<td align="right"><b>First Name:</b></td>
<td><%= Html.TextBox("ClientContactFirstName", Model.ClientContactFirstName, new { @style = "width:200px;" })%> *
    <%= Html.ValidationMessage("ClientContactFirstName")%></td>
</tr>
<tr>
<td align="right"><b>Last Name:</b></td>
<td><%= Html.TextBox("ClientContactLastName", Model.ClientContactLastName, new { @style = "width:200px;" })%> *
    <%= Html.ValidationMessage("ClientContactLastName")%></td>
</tr>
<tr>
<td align="right"><b>Title:</b></td>
<td><%= Html.TextBox("ClientContactTitle", Model.ClientContactTitle, new { @style = "width:200px;" })%></td>
</tr>
<tr>
<td align="right"><b>Address Line 1:</b></td>
<td><%= Html.TextBox("ClientContactAddress1", Model.ClientContactAddress1, new { @style = "width:200px;" })%> *
    <%= Html.ValidationMessage("ClientContactAddress1")%></td>
</tr>
<tr>
<td align="right"><b>Address Line 2:</b></td>
<td><%= Html.TextBox("ClientContactAddress2", Model.ClientContactAddress2, new { @style = "width:200px;" })%></td>
</tr>
<tr>
<td align="right"><b>City:</b></td>
<td><%= Html.TextBox("ClientContactCity", Model.ClientContactCity, new { @style = "width:150px;" })%> *
    <%= Html.ValidationMessage("ClientContactCity")%></td> 
</tr>
<tr>
<td align="right"><b>State:</b></td>
<td><select id="ClientContactStateCode" name="ClientContactStateCode">
        <option value='<%=Model.ClientContactStateCode%>'><%=Model.ClientContactStateCode%></option>
        <option value='AL'>Alabama</option>
        <option value='AK'>Alaska</option>
        <option value='AZ'>Arizona</option>
        <option value='AR'>Arkansas</option>
        <option value='CA'>California</option>
        <option value='CO'>Colorado</option>
        <option value='CT'>Connecticut</option>
        <option value='DE'>Delaware</option>
        <option value='DC'>District Of Columbia</option>
        <option value='FL'>Florida</option>
        <option value='GA'>Georgia</option>
        <option value='HI'>Hawaii</option>
        <option value='ID'>Idaho</option>
        <option value='IL'>Illinois</option>
        <option value='IN'>Indiana</option>
        <option value='IA'>Iowa</option>
        <option value='KS'>Kansas</option>
        <option value='KY'>Kentucky</option>
        <option value='LA'>Louisiana</option>
        <option value='ME'>Maine</option>
        <option value='MD'>Maryland</option>
        <option value='MA'>Massachusetts</option>
        <option value='MI'>Michigan</option>
        <option value='MN'>Minnesota</option>
        <option value='MS'>Mississippi</option>
        <option value='MO'>Missouri</option>
        <option value='MT'>Montana</option>
        <option value='NE'>Nebraska</option>
        <option value='NV'>Nevada</option>
        <option value='NH'>New Hampshire</option>
        <option value='NJ'>New Jersey</option>
        <option value='NM'>New Mexico</option>
        <option value='NY'>New York</option>
        <option value='NC'>North Carolina</option>
        <option value='ND'>North Dakota</option>
        <option value='OH'>Ohio</option>
        <option value='OK'>Oklahoma</option>
        <option value='OR'>Oregon</option>
        <option value='PA'>Pennsylvania</option>
        <option value='RI'>Rhode Island</option>
        <option value='SC'>South Carolina</option>
        <option value='SD'>South Dakota</option>
        <option value='TN'>Tennessee</option>
        <option value='TX'>Texas</option>
        <option value='UT'>Utah</option>
        <option value='VT'>Vermont</option>
        <option value='VA'>Virginia</option>
        <option value='WA'>Washington</option>
        <option value='WV'>West Virginia</option>
        <option value='WI'>Wisconsin</option>
        <option value='WY'>Wyoming</option>
    </select> *
<%= Html.ValidationMessage("ClientContactStateCode")%></td>
</tr>
<tr>
<td align="right"><b>ZIP:</b></td>
<td><%= Html.TextBox("ClientContactZIP", Model.ClientContactZIP, new { @style = "width:150px;" })%> *
    <%= Html.ValidationMessage("ClientContactZIP")%></td>
</tr>
<tr>
<td align="right"><b>Business Phone:</b></td>
<td><%= Html.TextBox("ClientContactBusinessPhone", Model.ClientContactBusinessPhone, new { @style = "width:150px;" })%> </td>
</tr>
<tr>
<td align="right"><b>Cell Phone:</b></td>
<td><%= Html.TextBox("ClientContactCellPhone", Model.ClientContactCellPhone, new { @style = "width:150px;" })%></td>
</tr>
<tr>
<td align="right"><b>Fax:</b></td>
<td><%= Html.TextBox("ClientContactFax", Model.ClientContactFax, new { @style = "width:150px;" })%></td>
</tr>
<tr id="rwClientContactStatus" name="rwClientContactStatus">
<td align="right"><b>Status:</b></td>
<td><select id="ClientContactStatus" name="ClientContactStatus">
        <option value='<%=Model.ClientContactStatus ? "1" : "0"%>'><%=Model.ClientContactStatus ? "Active" : "Inactive"%></option>
        <option value='1'>Active</option>
        <option value='0'>Inactive</option>
    </select> 
</td>
</tr>
<tr>
<td></td>
<td><input type="checkbox" id="FillBillingContact" name="FillBillingContact" /><span id="lblFillBillingContact" name="lblFillBillingContact"></span>
</td>
</tr>
<tr>
<td></td>
<td><input type="checkbox" checked="checked" id="SendUserEmail" name="SendUserEmail" /><span id="lblSendUserEmail" name="lblSendUserEmail"></span>
</td>
</tr>
</table>
</fieldset>
</div>

<div id='addclientcontact-tab-2'> 
<fieldset>
<table id="tblBillingContact">
<tr>
<td align="right"><b>Billing Name:</b></td>
<td><%= Html.TextBox("BillingContactName", Model.BillingContactName, new { @style = "width:200px;" })%><br /><span style="font-size:10px; font-style:italic; font-weight:lighter">(blank will default Accounts Payable)</span>
</td>
</tr>
<tr>
<td colspan="2">&nbsp;</td>
</tr>
<tr>
<td align="right"><b>Billing Address 1:</b></td>
<td><%= Html.TextBox("BillingContactAddress1", Model.BillingContactAddress1, new { @style = "width:200px;" })%> *
    <%= Html.ValidationMessage("BillingContactAddress1")%></td>
</tr>
<tr>
<td align="right"><b>Billing Address 2:</b></td>
<td><%= Html.TextBox("BillingContactAddress2", Model.BillingContactAddress2, new { @style = "width:200px;" })%></td>
</tr>
<tr>
<td align="right"><b>Billing City:</b></td>
<td><%= Html.TextBox("BillingContactCity", Model.BillingContactCity, new { @style = "width:150px;" })%> *
    <%= Html.ValidationMessage("BillingContactCity")%></td>
</tr>
<tr>
<td align="right"><b>Billing State:</b></td>
<td><select id="BillingContactStateCode" name="BillingContactStateCode">
        <option value='<%=Model.BillingContactStateCode%>'><%=Model.BillingContactStateCode%></option>
        <option value='AL'>Alabama</option>
        <option value='AK'>Alaska</option>
        <option value='AZ'>Arizona</option>
        <option value='AR'>Arkansas</option>
        <option value='CA'>California</option>
        <option value='CO'>Colorado</option>
        <option value='CT'>Connecticut</option>
        <option value='DE'>Delaware</option>
        <option value='DC'>District Of Columbia</option>
        <option value='FL'>Florida</option>
        <option value='GA'>Georgia</option>
        <option value='HI'>Hawaii</option>
        <option value='ID'>Idaho</option>
        <option value='IL'>Illinois</option>
        <option value='IN'>Indiana</option>
        <option value='IA'>Iowa</option>
        <option value='KS'>Kansas</option>
        <option value='KY'>Kentucky</option>
        <option value='LA'>Louisiana</option>
        <option value='ME'>Maine</option>
        <option value='MD'>Maryland</option>
        <option value='MA'>Massachusetts</option>
        <option value='MI'>Michigan</option>
        <option value='MN'>Minnesota</option>
        <option value='MS'>Mississippi</option>
        <option value='MO'>Missouri</option>
        <option value='MT'>Montana</option>
        <option value='NE'>Nebraska</option>
        <option value='NV'>Nevada</option>
        <option value='NH'>New Hampshire</option>
        <option value='NJ'>New Jersey</option>
        <option value='NM'>New Mexico</option>
        <option value='NY'>New York</option>
        <option value='NC'>North Carolina</option>
        <option value='ND'>North Dakota</option>
        <option value='OH'>Ohio</option>
        <option value='OK'>Oklahoma</option>
        <option value='OR'>Oregon</option>
        <option value='PA'>Pennsylvania</option>
        <option value='RI'>Rhode Island</option>
        <option value='SC'>South Carolina</option>
        <option value='SD'>South Dakota</option>
        <option value='TN'>Tennessee</option>
        <option value='TX'>Texas</option>
        <option value='UT'>Utah</option>
        <option value='VT'>Vermont</option>
        <option value='VA'>Virginia</option>
        <option value='WA'>Washington</option>
        <option value='WV'>West Virginia</option>
        <option value='WI'>Wisconsin</option>
        <option value='WY'>Wyoming</option>
    </select> *
</td>
</tr>
<tr>
<td align="right"><b>Billing ZIP:</b></td>
<td><%= Html.TextBox("BillingContactZIP", Model.BillingContactZIP, new { @style = "width:150px;" })%> *
    <%= Html.ValidationMessage("BillingContactZIP")%></td>
</tr>
<tr>
<td align="right"><b>Phone:</b></td>
<td><%= Html.TextBox("BillingContactBusinessPhone", Model.BillingContactBusinessPhone, new { @style = "width:150px;" })%></td>
</tr>
<tr>
<td align="right"><b>FAX:</b></td>
<td><%= Html.TextBox("BillingContactFax", Model.BillingContactFax, new { @style = "width:150px;" })%></td>
</tr>
<tr><td colspan="2" align="center"><hr /></td></tr>
<tr>
<td><b>Invoice Delivery:</b></td>
<td><select id="DeliveryMethod" name="DeliveryMethod" style="width:150px">
    <option value='<%=Model.DeliveryMethodVal%>'><%=Model.DeliveryMethod%></option>
    <option value="0">Online</option>
    <option value="1">Email-Auto</option>
    <option value="2">Email-Manual</option> 
    <option value="3">Mail Only</option>     
</select> *
</td>
</tr>
<tr>
<td align="right"><b>PO Name:</b></td>
<td><%= Html.TextBox("BillingContactPOName", Model.BillingContactPOName, new { @style = "width:150px;" })%></td>
</tr>
<tr>
<td align="right"><b>PO Number:</b></td>
<td><%= Html.TextBox("BillingContactPONumber", Model.BillingContactPONumber, new { @style = "width:150px;" })%></td>
</tr>
<tr id="rwBillingContactStatus" name="rwBillingContactStatus">
<td align="right"><b>Status:</b></td>
<td><select id="BillingContactStatus" name="BillingContactStatus">
        <option value='<%=Model.BillingContactStatus ? "1" : "0"%>'><%=Model.BillingContactStatus ? "Active" : "Inactive"%></option>
        <option value='1'>Active</option>
        <option value='0'>Inactive</option>
    </select> 
</td>
</tr>
<tr>
<td></td>
<td><input type="checkbox" id="IsPrimaryBillingContact" name="IsPrimaryBillingContact" /><span id="lblIsPrimaryBillingContact" name="lblIsPrimaryBillingContact"> Primary billing contact?</span>
</td>
</tr>
<tr id="trNewPrimaryContact" style="display:none">
<td align="right">
    <b>New Primary?:</b>
</td>
<td>
        <select id='NewPrimaryContact' style='width:295px;'></select>
        <%= Html.Hidden("NewPrimaryContactID", Model.NewPrimaryContactID)%>
</td>
</tr>
<tr>
<td></td>
<td><input type="checkbox" id="OnlyShowInvoices" name="OnlyShowInvoices" />
</td>
</tr>
</table>
</fieldset>
</div>
</div>
