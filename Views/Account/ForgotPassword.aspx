<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="forgotPasswordTitle" ContentPlaceHolderID="TitleContent" runat="server">
	ForgotPassword
</asp:Content>

<asp:Content ID="forgotPasswordContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
<div style="float:left; margin-left:50px;"> 
    <h2>Forgot Password?</h2>
    <% using (Html.BeginForm()) { %>
        <div>
            <fieldset class="fieldset bottom">
                <p> <span class="span-instructions" id="InstructionLabel"></span>
                    <span id="UsernameResult"></span>
                    <label class="label-font"; id="UsernameLabel" for="username">User Name:</label>
                    <%= Html.TextBox("username", ViewData["username"], new { style="width:250px"})%>&nbsp;&nbsp;<button id="LookupUser" class="ui-priority-primary fg-button ui-state-default ui-corner-all" type="button">Lookup User ID</button>
                    <%= Html.ValidationMessage("username")%>
                                   
                <!--Hide related security question until User ID has been validated -->
 
                <script type="text/javascript">
                    //alert($('#username').val());
                   if($('#username').val() == ''){
                       $(document).ready(function() {
                           $('#SecurityAnswerLabel').hide();
                           $('#InstructionLabel').html('Please enter your User Name to request a password reset.<br></br>');
                           $('#QuestionLabel').hide();
                           $('#SecurityAnswer').hide();
                           $('#SendConfirmation').hide();
                           $('#username').focus();
                           $('#LookupUser').click(getNodeDetails);
                           $('#username').blur(getNodeDetails);
                       });
                       }
                    else 
                    {
                        //alert('In here');
                        $(document).ready(function() {
                               getNodeDetails()
                               $('#SecurityAnswer').focus();
                          });
                    };                           
                                    
                   function getNodeDetails() {
                       $.post("../../Account/getSecurityQuestionJSON/" + $('#username').val(),
                             function(result) {
                                 if (result.SecurityQuestion != "" && (result.SecurityQuestion != "unauthorized" && result.Unauthorized != "true")) {
                                     jQuery('#SecurityQuestion').html(result.SecurityQuestion);
                                     $('#LookupUser').hide();
                                     $('#username').hide();
                                     $('#UsernameLabel').hide();
                                     $('#LookupLabel').hide();
                                     $('#UsernameResult').html('<h3>User Name: ' + $('#username').val() + '</h3>');
                                     $('#InstructionLabel').html('Please answer the following security question to proceed.<br></br>');
                                     $('#QuestionLabel').show('slow');
                                     $('#SecurityAnswerLabel').show('slow');
                                     $('#SecurityAnswer').show('slow');
                                     $('#SendConfirmation').show('slow');
                                 }
                                 else {
                                     $('#UsernameResult').attr('class', 'span-error');
                                     if (result.Unauthorized == "true") {
                                         $('#UsernameResult').html('This login account has been deactivated. Please contact your account rep for more information.<br></br>');
                                     }
                                     else {
                                         $('#UsernameResult').html('The User Name entered cannot be located.  Please try again.<br></br>');
                                         $('#username').val('');
                                     }
                                     
                                 }
                             }, 'json');
                        }
                
                </script>
                <label class="label-font"; id="QuestionLabel">Password Reset Question:</label>
                <span id="SecurityQuestion"></span>

                </p>
                 <p>
                    <label class="label-font";  id="SecurityAnswerLabel" for="securityAnswer">Password Reset Answer:</label>
                    <%= Html.TextBox("SecurityAnswer", "", new { @size = "60" })%>
                    <%= Html.ValidationMessage("SecurityAnswer") %>
                </p>
                <p>
                    <button id="SendConfirmation" type="submit" class="ui-priority-primary fg-button ui-state-default ui-corner-all">Request Password Reset</button>
                </p>
                
            </fieldset>
        </div>
    <% } %>
</div>
<div style="float: left; margin-left:30px;">
  <!--Use this section later for user instructions to explain password retrieval process. -->
</div>

<div style="clear:both"></div>

</div>
</asp:Content>


