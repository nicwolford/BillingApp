<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.Clients_Details>" %>
<script type="text/javascript">
    $(function() {
        $('#Tazworks1Client').click(disableNonTazworks);
        $('#Tazworks2Client').click(disableNonTazworks);
        $('#NonTazworksClient').click(disableTazworks);   
     });

     function disableNonTazworks() {
         if ($('#Tazworks1Client').is(':checked') || $('#Tazworks2Client').is(':checked')) {
             $('#NonTazworksClient').attr('checked', false);
             $('#NonTazworksClient').attr("disabled", true);
         }
         else {
             $('#NonTazworksClient').removeAttr("disabled");
         }
     }

     function disableTazworks() {
         if ($('#NonTazworksClient').is(':checked')) {
             $('#Tazworks1Client').attr('checked', false);
             $('#Tazworks2Client').attr('checked', false);
             $('#Tazworks1Client').attr("disabled", true);
             $('#Tazworks2Client').attr("disabled", true);
         }
         else {
             $('#Tazworks1Client').removeAttr("disabled");
             $('#Tazworks2Client').removeAttr("disabled");
         }
     }

</script>

<div>
<fieldset>
<h5>Client Info</h5>

<%= Html.Hidden("ClientID",Model.ClientID) %>
<table>
<tr>
<td align='right'>Client Name:</td>
<td><%= Html.TextBox("ClientName", Model.ClientName, new { @style = "width:200px;" }) %> *
    <%= Html.ValidationMessage("ClientName")%></td>
</tr>
<tr>
<td align='right'>Address Line 1:</td>
<td><%= Html.TextBox("Address1", Model.Address1, new { @style = "width:200px;" })%> *
    <%= Html.ValidationMessage("Address1")%></td>
</tr>
<tr>
<td align='right'>Address Line 2:</td>
<td><%= Html.TextBox("Address2", Model.Address2, new { @style = "width:200px;" })%></td>
</tr>
<tr>
<td align='right'>City:</td>
<td><%= Html.TextBox("City", Model.City, new { @style = "width:200px;" })%> *
    <%= Html.ValidationMessage("City")%></td>
</tr>
<tr>
<td align='right'>State:</td>
<td><select id="State">
        <option value='<%=Model.State%>'><%=Model.State%></option>
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
<td align='right'>ZIP:</td>
<td><%= Html.TextBox("Zip", Model.Zip, new { @style = "width:100px;" })%> *
    <%= Html.ValidationMessage("Zip")%></td>
</tr>
<tr>
<td></td>
<td><input type="checkbox" id="Tazworks1Client" name="Tazworks1Client" /><label class="inline" for="Tazworks1Client"> Tazworks 1.0</label></td>
</tr>
<tr>
<td></td>
<td><input type="checkbox" id="Tazworks2Client" name="Tazworks2Client" /><label class="inline" for="Tazworks2Client"> Tazworks 2.0</label>
</td>
</tr>
<tr>
<td></td>
<td><input type="checkbox" id="NonTazworksClient" name="NonTazworksClient" /><label class="inline" for="NonTazworksClient"> Non-Tazworks Client</label>
<br /><%= Html.ValidationMessage("TazworksClient")%>
</td>
</tr>
</table>

</fieldset>
</div>



