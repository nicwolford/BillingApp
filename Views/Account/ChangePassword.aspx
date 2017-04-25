<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="changePasswordTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Change Password
</asp:Content>

<asp:Content ID="changePasswordContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
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
                    <!-- Test the password strength and display to user.-->
                    <script type="text/javascript">
                                       $(document).ready(function() {
                                       $('#newPassword').addClass('password_test');
                                           $('.password_test').passStrength(
                            {
                                userid: "",
                                messageloc: 1
                            }
                        );

                                       });
                    </script>
               
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
                    <input type="submit" value="Change Password" />
                </p>
            </fieldset>
        </div>
    <% } %>
</div>
</div>
</asp:Content>
