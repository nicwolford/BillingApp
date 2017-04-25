<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.Security_Users>" %>

<asp:Content ID="changePasswordTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Change Password
</asp:Content>

<asp:Content ID="changePasswordContent" ContentPlaceHolderID="MainContent" runat="server">

<script type="text/javascript">
    $(document).ready(function() {

        //Test the password strength and display to user
        $('#newPassword').addClass('password_test');
        $('.password_test').passStrength(
            {
                userid: "#UserName ",
                messageloc: 1
            }
        );

    });
</script>

<div class="art-content-wide">
<%=Html.Hidden("UserName", Model.username)%>
<div style="float:left; margin-left:50px;"> 
    <h2>Change Password</h2>
    <h3>Use the form below to change your password.</h3>         

    <span class="span-instructions">New passwords are required to be a minimum of <%=Html.Encode(ViewData["PasswordLength"])%> characters in length.</span>
  
    <%= Html.ValidationSummary("Password change was unsuccessful. Please correct the errors and try again.")%>

    <% using (Html.BeginForm()) { %>
        <div>
            <fieldset>
                <p>
                    <label class="label-font"; for="currentPassword">Current password:</label>
                    <%= Html.Password("currentPassword") %>  <%= Html.ActionLink("Forgot your Password?", "ForgotPassword", "Account")%>
                    <%= Html.ValidationMessage("currentPassword") %>
               </p>
                <p>
                    <label class="label-font"; for="newPassword">New password:</label>
                    <%= Html.Password("newPassword") %>
                    <%= Html.ValidationMessage("newPassword") %>
                </p>
                <p>
                    <label class="label-font"; for="confirmPassword">Confirm new password:</label>
                    <%= Html.Password("confirmPassword") %>
                    <%= Html.ValidationMessage("confirmPassword") %>
                </p>
                <p>
                    <label class="label-font"; for="newSecurityQuestion">New Security Question: </label><i>(Example: What is my Company's ZipCode?)</i><br />
                    <%= Html.TextBox("newSecurityQuestion", "", new { style="width:260px"})%>
                    <%= Html.ValidationMessage("newSecurityQuestion")%>
                </p>
                <p>
                    <label class="label-font"; for="newSecurityAnswer">New Security Answer:</label>
                    <%= Html.TextBox("newSecurityAnswer", "", new { style = "width:260px" })%>
                    <%= Html.ValidationMessage("newSecurityAnswer")%>
                </p>
                <p>
                    <input type="submit" value="Change Password" />
                </p>
            </fieldset>
        </div>
    <% } %>
</div>
</div>
</asp:Content>
