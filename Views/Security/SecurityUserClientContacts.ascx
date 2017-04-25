<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<IEnumerable<ScreeningONE.ViewModels.ClientContacts_Details>>" %>

    <table>
        <tr>
            <th></th>
            <th>
                ClientContactID
            </th>
            <th>
                ClientContactFirstName
            </th>
            <th>
                ClientContactLastName
            </th>
            <th>
                ClientContactTitle
            </th>
            <th>
                ClientContactAddress1
            </th>
            <th>
                ClientContactAddress2
            </th>
            <th>
                ClientContactCity
            </th>
            <th>
                ClientContactStateCode
            </th>
            <th>
                ClientContactZIP
            </th>
            <th>
                ClientContactBusinessPhone
            </th>
            <th>
                ClientContactCellPhone
            </th>
            <th>
                ClientContactFax
            </th>
            <th>
                ClientContactEmail
            </th>
            <th>
                ClientContactStatus
            </th>
            <th>
                DeliveryMethod
            </th>
            <th>
                DeliveryMethodVal
            </th>
            <th>
                BillingContactName
            </th>
            <th>
                BillingContactAddress1
            </th>
            <th>
                BillingContactAddress2
            </th>
            <th>
                BillingContactCity
            </th>
            <th>
                BillingContactStateCode
            </th>
            <th>
                BillingContactZIP
            </th>
            <th>
                BillingContactBusinessPhone
            </th>
            <th>
                BillingContactFax
            </th>
            <th>
                BillingContactEmail
            </th>
            <th>
                BillingContactPOName
            </th>
            <th>
                BillingContactPONumber
            </th>
            <th>
                BillingContactNotes
            </th>
            <th>
                IsPrimaryBillingContact
            </th>
            <th>
                OnlyShowInvoices
            </th>
            <th>
                BillingContactStatus
            </th>
            <th>
                BillingContactID
            </th>
            <th>
                NewPrimaryContactID
            </th>
            <th>
                NewPrimaryContactName
            </th>
            <th>
                ClientID
            </th>
            <th>
                UserID
            </th>
            <th>
                IsBillingContact
            </th>
            <th>
                LastLoginDate
            </th>
            <th>
                cmdType
            </th>
        </tr>

    <% foreach (var item in Model) { %>
    
        <tr>
            <td>
                <%= Html.ActionLink("Edit", "Edit", new { /* id=item.PrimaryKey */ }) %> |
                <%= Html.ActionLink("Details", "Details", new { /* id=item.PrimaryKey */ })%>
            </td>
            <td>
                <%= Html.Encode(item.ClientContactID) %>
            </td>
            <td>
                <%= Html.Encode(item.ClientContactFirstName) %>
            </td>
            <td>
                <%= Html.Encode(item.ClientContactLastName) %>
            </td>
            <td>
                <%= Html.Encode(item.ClientContactTitle) %>
            </td>
            <td>
                <%= Html.Encode(item.ClientContactAddress1) %>
            </td>
            <td>
                <%= Html.Encode(item.ClientContactAddress2) %>
            </td>
            <td>
                <%= Html.Encode(item.ClientContactCity) %>
            </td>
            <td>
                <%= Html.Encode(item.ClientContactStateCode) %>
            </td>
            <td>
                <%= Html.Encode(item.ClientContactZIP) %>
            </td>
            <td>
                <%= Html.Encode(item.ClientContactBusinessPhone) %>
            </td>
            <td>
                <%= Html.Encode(item.ClientContactCellPhone) %>
            </td>
            <td>
                <%= Html.Encode(item.ClientContactFax) %>
            </td>
            <td>
                <%= Html.Encode(item.ClientContactEmail) %>
            </td>
            <td>
                <%= Html.Encode(item.ClientContactStatus) %>
            </td>
            <td>
                <%= Html.Encode(item.DeliveryMethod) %>
            </td>
            <td>
                <%= Html.Encode(item.DeliveryMethodVal) %>
            </td>
            <td>
                <%= Html.Encode(item.BillingContactName) %>
            </td>
            <td>
                <%= Html.Encode(item.BillingContactAddress1) %>
            </td>
            <td>
                <%= Html.Encode(item.BillingContactAddress2) %>
            </td>
            <td>
                <%= Html.Encode(item.BillingContactCity) %>
            </td>
            <td>
                <%= Html.Encode(item.BillingContactStateCode) %>
            </td>
            <td>
                <%= Html.Encode(item.BillingContactZIP) %>
            </td>
            <td>
                <%= Html.Encode(item.BillingContactBusinessPhone) %>
            </td>
            <td>
                <%= Html.Encode(item.BillingContactFax) %>
            </td>
            <td>
                <%= Html.Encode(item.BillingContactEmail) %>
            </td>
            <td>
                <%= Html.Encode(item.BillingContactPOName) %>
            </td>
            <td>
                <%= Html.Encode(item.BillingContactPONumber) %>
            </td>
            <td>
                <%= Html.Encode(item.BillingContactNotes) %>
            </td>
            <td>
                <%= Html.Encode(item.IsPrimaryBillingContact) %>
            </td>
            <td>
                <%= Html.Encode(item.OnlyShowInvoices) %>
            </td>
            <td>
                <%= Html.Encode(item.BillingContactStatus) %>
            </td>
            <td>
                <%= Html.Encode(item.BillingContactID) %>
            </td>
            <td>
                <%= Html.Encode(item.NewPrimaryContactID) %>
            </td>
            <td>
                <%= Html.Encode(item.NewPrimaryContactName) %>
            </td>
            <td>
                <%= Html.Encode(item.ClientID) %>
            </td>
            <td>
                <%= Html.Encode(item.UserID) %>
            </td>
            <td>
                <%= Html.Encode(item.IsBillingContact) %>
            </td>
            <td>
                <%= Html.Encode(item.LastLoginDate) %>
            </td>
            <td>
                <%= Html.Encode(item.cmdType) %>
            </td>
        </tr>
    
    <% } %>

    </table>

    <p>
        <%= Html.ActionLink("Create New", "Create") %>
    </p>


