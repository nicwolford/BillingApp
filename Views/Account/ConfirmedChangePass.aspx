<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.Account_ConfirmedChangePass>" %>

<asp:Content ID="confirmedChangePassTitle" ContentPlaceHolderID="TitleContent" runat="server">
	Change Password
</asp:Content>

<asp:Content ID="confirmedChangePassContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
<div style="float:left; margin-left:50px;"> 
    <h2>Change Password</h2>
    <h3>Use the form below to change your password.</h3>         
    <%= Html.ValidationSummary()%>

    <% using (Html.BeginForm()) { %>
        <div>
        <% if (Model.ShowFieldSet) { %>
            <fieldset id="changepassform">
                <p>

                    <label class="label-font"; for="newPassword">New password:</label>
                    <%= Html.Password("newPassword", "", new { style = "width:150px" }) %>
                    <%= Html.ValidationMessage("newPassword") %>
                    <!-- Test the password strength and display to user.-->
                    <script type="text/javascript">
                        $(document).ready(function() {
                            $('#newPassword').focus();
                            $('#newPassword').addClass('password_test');
                            $('.password_test').passStrength(
                            {
                                userid: "#username",
                                messageloc: 1
                            }
                        );

                        });
                    </script>
                </p>
                <p>
                    <label class="label-font"; for="confirmPassword">Confirm new password:</label>
                    <%= Html.Password("confirmPassword", "", new { style = "width:150px" })%>
                    <%= Html.ValidationMessage("confirmPassword") %>
                </p>
                <p>
                    <input type="submit" value="Change Password" />
                    <%= Html.Hidden("username", Model.sUserName)%>
                </p>
            </fieldset>
            <% } %> 
        </div>
    <% } %>
</div>
</div>

</asp:Content>


