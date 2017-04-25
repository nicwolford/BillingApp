<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.ClientProducts_Modify>" %>

    <%= Html.ValidationSummary("Edit was unsuccessful. Please correct the errors and try again.") %>

            <%= Html.Hidden("ProductID", Model.ProductID)%>
            <%= Html.Hidden("ClientID", Model.ClientID) %>
            <p>
                <label>Product Name:&nbsp;<%= Model.ProductName%></label>
            </p>
            <p>
                <label for="SalesPrice">Product Price:</label>
                <%= Html.TextBox("SalesPrice", Model.SalesPrice) %>
                <%= Html.ValidationMessage("SalesPrice", "*")%>
            </p>
            <p>
                <label for="IncludeOnInvoice">Invoice Display:</label>
                <%= Html.TextBox("IncludeOnInvoice", Model.IncludeOnInvoice)%>
                <%= Html.ValidationMessage("IncludeOnInvoice", "*")%>
            </p>
            <p>
                <label class="inline" for="ImportsAtBaseOrSales">Use Imported Price? </label>
                <%= Html.CheckBox("ImportsAtBaseOrSales", true, Model.ImportsAtBaseOrSales)%>
            </p>





