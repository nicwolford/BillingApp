<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="loginTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Log In
</asp:Content>

<asp:Content ID="loginContent" ContentPlaceHolderID="MainContent" runat="server">
<div> 
<div style="float:left; margin-left:50px;margin-top:30px;">  
    <h2>  Welcome to <%=ConfigurationManager.AppSettings["CompanyName"] %>'s Client Billing Site</h2>
    <h3>  Please log in to your account below to view, print or save your invoices.<br /></h3>
    

    <% using (Html.BeginForm()) { %>
        <div style="float:left; width:300px;">
            <fieldset>
                <p>
                    <label class="label-font"; for="username">User Name:</label>
                    <%= Html.TextBox("username", "", new { @style = "width:250px;" })%> 
                    <%= Html.ValidationMessage("username") %>
                </p>
                <p>
                    <label class="label-font"; for="password">Password:</label>
                    <%= Html.Password("password", "", new { @style = "width:250px;" })%>
                    <%= Html.ValidationMessage("password") %>
                </p>
                <p>
                    <button type="submit" class="fg-button ui-state-default ui-priority-primary ui-corner-all">Log In</button>
                </p>
                <p>
                  <%= Html.ActionLink("Forgot your Password?", "ForgotPassword", new { portal = ViewData["portal"], ClientID = ViewData["ClientID"] })%>
                
                </p>
            </fieldset>
        </div>
        <div style="float:right; margin-right:30px; margin-left:30px;"><br /><br /><h2 style="font-size:15px">
            To request access to our online billing system, please <a href="<%=ConfigurationManager.AppSettings["contacturl"]%>" style="font-size:15px; color:Maroon">click here</a>.<br /><br />
            If you require further assistance, you can contact our Billing Department directly:<br /><br />
            <div style="margin-left:100px"><%=ConfigurationManager.AppSettings["billingphone"]%> <br />
            <%= ConfigurationManager.AppSettings["billingemail"]%></h2></div>
        </div>
        
             <script type="text/javascript">
                 $(function() {
                     $('#username').focus();
                 });
             </script>
    <% } %>
</div>
</div>
</asp:Content>
