<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ApplicantONE.ViewModels.Applicant_CreateProfile>" %>

<asp:Content ID="createProfileTitle" ContentPlaceHolderID="TitleContent" runat="server">
	CreateProfile
</asp:Content>

<asp:Content ID="createProfileContent" ContentPlaceHolderID="MainContent" runat="server">
<div>
<div style="float:left; "> 
    <h2>My Profile</h2>
    <% using (Html.BeginForm())
       { %>
            <div>
            <fieldset>
                <h3>Please complete your applicant profile.</h3>
                <%= Html.ValidationSummary()%>
                <div class='float'>
                <p> 

                    <label class="label-font"; for="firstname">First Name:</label>
                    <%= Html.TextBox("firstname", "", new { style = "width:150px" })%>
                    <%= Html.ValidationMessage("firstname")%>
                </p>
                </div>
                <div class='float'>
                <p> 
                    <label class="label-font"; >MI:</label>
                    <%= Html.TextBox("middleinit", "", new { style = "width:10px" })%>
                    <%= Html.ValidationMessage("middleinit")%>
                </p>
                </div>
                <div class='float'>
                <p> 
                    <label class="label-font"; for="lastname">Last Name:</label>
                    <%= Html.TextBox("lastname", "", new { style = "width:150px" })%>
                    <%= Html.ValidationMessage("lastname")%>
                </p>
                </div>
                <div class='spacer' style='margin: 0; padding: 0; line-height:10px'>&nbsp;</div>
                <div class='float'>
                <p> 
                    <SCRIPT type=text/javascript> $(function() { $('#nationalidnumber').mask("999-99-9999"); }); </SCRIPT>
                    <label class="label-font"; for="nationalidnumber">Social Security Number:</label>
                    <%= Html.TextBox("nationalidnumber", "", new { style = "width:150px" })%>
                    <%= Html.ValidationMessage("nationalidnumber")%> 
                    
                </p>
                </div>
                <div class='float'>
                <p> 
                    <label class="label-font"; for="gender">Gender:</label>
                    <%= Html.RadioButton("gender", 28)%>Female
                    <%= Html.RadioButton("gender", 27)%>Male
                    <%= Html.RadioButton("gender", 29, true)%>Not Disclosed
                </p>
                </div>
                <div class='spacer' style='margin: 0; padding: 0; line-height:10px'>&nbsp;</div>
                <div class='float'>
                <p> 
                    <label class="label-font"; for="hispaniclatino">Hispanic or Latin?:</label>
                   <%= Html.RadioButton("hispaniclatino", 43)%>Yes
                   <%= Html.RadioButton("hispaniclatino", 44)%>No
                   <%= Html.RadioButton("hispaniclatino", 45, true)%>Not Disclosed
                </p>
                </div>
                <div class='float'>
                <p> 
                    <label class="label-font"; for="racecategory">Ethnicity:</label>
                    <%= Html.DropDownList("racecategory", Model.racecategorylist)%>
                    <%= Html.ValidationMessage("racecategory")%>
                </p>
                </div>
                <div class='spacer' style='margin: 0; padding: 0; line-height:10px'>&nbsp;</div>
                <div class='float'>
                <p><label class="label-font"; for="veterantype">Are you a Veteran?:</label>
                   If you are a veteran of the Vietnam Era, or have other military status we would appreciate your assistance in telling us the following information by checking the appropriate items that may apply to you.
                    <div class='float' style="float:left; margin-left:15px; margin-right:15px;">
                    <div class='spacer' style='margin: 0; padding: 0; line-height:0px'>&nbsp;</div>
                    <%= Html.CheckBox("veterantype1")%>&nbsp;Not Applicable or I choose not to disclose
                    <div class='spacer' style='margin: 0; padding: 0; line-height:5px'>&nbsp;</div> 
                    <%= Html.CheckBox("veterantype2")%>&nbsp;Qualified Disabled Veteran: <div style="float:left; margin-left:25px; margin-right:15px;">Any person entitled to compensation by the Veterans Administration for a disability rated at 30 percent or more, or a person who was discharged or released from Active Duty by reason of a service connected disability. </div>
                    <div class='spacer' style='margin: 0; padding: 0; line-height:5px'>&nbsp;</div>
                    <%= Html.CheckBox("veterantype3")%>&nbsp;Veteran of the Vietnam Era: <div style="float:left; margin-left:25px; margin-right:15px;">Any veteran of the armed services who served on active duty for at least 180 days, any part of which occurred between August 5, 1964 and May 7, 1975, and was discharged honorably or released sooner because of service related disability. </div>
                    <div class='spacer' style='margin: 0; padding: 0; line-height:5px'>&nbsp;</div>
                    <%= Html.CheckBox("veterantype4")%>&nbsp;Reservist or member of the National Guard 
                    <div class='spacer' style='margin: 0; padding: 0; line-height:5px'>&nbsp;</div>
                    <%= Html.CheckBox("veterantype5")%>&nbsp;Other: <%= Html.TextBox("veteranotherdesc", "", new { style = "width:150px" })%>
                    <%= Html.ValidationMessage("veterantype")%> 
                    </div>    
                    
                <script type="text/javascript">

                    $(function() {
                        $('#firstname').focus();
                        $('#veterantype1').click(function() {
                            if ($('#veterantype1[checked=true]').length) {

                                $('#veterantype2').attr('disabled', 'disabled');
                                $('#veterantype3').attr('disabled', 'disabled');
                                $('#veterantype4').attr('disabled', 'disabled');
                                $('#veterantype5').attr('disabled', 'disabled');
                                $('#veteranotherdesc').attr('disabled', 'disabled');
                            }
                            else {
                                $('#veterantype2').attr('disabled', '');
                                $('#veterantype3').attr('disabled', '');
                                $('#veterantype4').attr('disabled', '');
                                $('#veterantype5').attr('disabled', '');
                                $('#veteranotherdesc').attr('disabled', '');
                            }
                        });
                    });
                </script>                                              

                </p>
                </div>
                <div class='float' style="float:left; margin-left:15px; margin-right:15px;">
                    <span id="success" style="color:Fuchsia; font-size:large; font-weight:bold"><%=Html.Encode(ViewData["successmessage"])%></span>
                </div>
                <div class='spacer' style='margin: 0; padding: 0; line-height:10px'>&nbsp;</div>
                <p>
                    <button type="submit" class="fg-button ui-state-default ui-priority-primary ui-corner-all">Save Profile</button>
               </p>

            </fieldset>
        </div>
     <% } %>
</div>
</div>
</asp:Content>



