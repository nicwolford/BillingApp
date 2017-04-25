<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.Security_Users>" %>

            <fieldset>
                <div style="float:left">
                    <%= Html.ValidationSummary()%>
                    <p>All Fields Required.</p>
                    <label class="label-font"; for="firstname">First Name:</label>
                    <%= Html.TextBox("firstname", "", new { style = "width:200px" })%>
                    <%= Html.ValidationMessage("firstname")%>
                    <br />
                    <label class="label-font"; for="lastname">Last Name:</label>
                    <%= Html.TextBox("lastname", "", new { style = "width:200px" })%>
                    <%= Html.ValidationMessage("lastname")%>
                    <br />
                    <label class="label-font"; for="email">Email:</label>
                    <%= Html.TextBox("email", "", new { style = "width:200px" })%>
                    <%= Html.ValidationMessage("email")%>
                   <br />
                   <hr />
                    <label class="label-font"; for="primarycompany">Primary Company:</label>
                    <%=Html.DropDownList("primarycompany", Model.securitycompanieslist2, new { style = "width:200px", })%>
                    <%= Html.ValidationMessage("primarycompany")%>
                    <br />
                    <label class="label-font"; for="usertypelist">User Role:</label>
                    <%=Html.DropDownList("usertypelist", Model.usertypelist, new { style = "width:200px", })%>
                    <%= Html.ValidationMessage("usertypelist")%>    
                    <br />
                    <hr />
                    <br />
                    <label class="label-font"; for="username">User Name:</label>
                    <%= Html.TextBox("username", "", new { style = "width:200px" })%>
                    <%= Html.ValidationMessage("username")%>
                    <br />
                    <label class="label-font"; >Password:</label>
                    <%= Html.Password("password", "", new { style = "width:200px" })%>
                    <%= Html.ValidationMessage("password")%>
                    <script type="text/javascript">
                        $(document).ready(function() {
                            $('#username').focus();
                            $('#password').addClass('password_test');
                            $('.password_test').passStrength(
                            {
                                userid: "#username",
                                messageloc: 1
                            }
                        );

                        });
                    </script>
                    <br />
                    <label class="label-font"; for="confirmPassword">Confirm password:</label>
                    <%= Html.Password("confirmPassword", "", new { style = "width:200px" })%>
                    <%= Html.ValidationMessage("confirmPassword")%>
                
                    
                </div>


            </fieldset>
