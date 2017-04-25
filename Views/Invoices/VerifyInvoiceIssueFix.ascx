<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.Invoices_VerifyInvoiceSetup>" %>

<div id='missingReferenceFix'>
<span style='margin-left:3px;'>
    <select id='selReferenceSplitContact' style='width:300px;'>
        <% foreach (var contact in Model.referenceSplitContacts)
           { %>
        
            <option value='<%= contact.Value %>'><%= Html.Encode(contact.Text) %></option>
        
        <% } %>
        </select>
</span>
</div>



