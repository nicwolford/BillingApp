<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.Security_Users>" %>

    <!-- This loads the multiselect to the Security tab -->
<p></p>
<div id="securitytabs" style="padding-top:0px; vertical-align:top; padding-left:0px; padding-right:0px; width:410px; height:200px; float:right;">
            <script type="text/javascript">
                $(function() {

                    if ($('#OldUserName').val() == '') {
                        $('#emptyUsrMessage').show();
                        $('#usrtble').hide();
                        $('#UserName').attr('disabled', true);
                        $('#Inactive').attr('disabled', true);
                        $('#cmdSaveUserProfileChanges').attr('disabled', true);
                        $('#cmdResetUserPassword').attr('disabled', true);
                    }
                    else {
                        $('#emptyUsrMessage').hide();
                        $('#usrtble').show();
                        $('#UserName').attr('disabled', false);
                        $('#Inactive').attr('disabled', false);
                        $('#cmdSaveUserProfileChanges').attr('disabled', false);
                        $('#cmdResetUserPassword').attr('disabled', false);
                    }

                    $('#cmdSaveUserProfileChanges').click(function() {
                        $.post('../../Security/SaveUserProfileJSON', { OldUserName: $('#OldUserName').val(),
                            UserNameEmail: $('#UserName').val(), Inactive: $('#Inactive').is(':checked')
                        }, function(data) {
                            if (data.error != '') {
                                alert(data.error);
                            }
                            if (data.success) {
                                $('#OldUserName').val($('#UserName').val());
                            }
                        }, 'json');
                    });

                    $('#cmdResetUserPassword').click(function() {
                        $.post('../../Security/ResetUserPasswordJSON', { OldUserName: $('#OldUserName').val(), UserID: $('#UserID').val(),
                            UserNameEmail: $('#UserName').val(), Inactive: $('#Inactive').is(':checked')
                        }, function(data) {
                            if (data.error != '') {
                                alert(data.error);
                            }
                            if (data.success) {
                                //do nothing
                            }
                        }, 'json');
                    });

                });
            </script>
        <ul>
            <li><a href="#securitytabs-1">User Profile</a></li>
            <li><a href="#securitytabs-2">Permissions</a></li>
            <li><a href="#securitytabs-3">Activity Log</a></li>
        </ul>
        <div id="securitytabs-1"> 
            <div id="usrtble">
            <%= Html.Hidden("OldUserName", Model.username)%>
            <%= Html.Hidden("UserID", Model.UserID)%>
            <table cellpadding="3" cellspacing="2">
            <tr>
            <td>User Name / Email:</td><td><%= Html.TextBox("UserName", Model.username, new { @style = "width:250px;" }) %></td>
            </tr>
            <tr>
            <td>Inactive:</td><td><%= Html.CheckBox("Inactive", !Model.IsApproved) %></td>
            </tr>
            </table>
            <br />
            <button id='cmdSaveUserProfileChanges' style='width:140px'>Save User Changes</button>&nbsp;&nbsp;&nbsp;&nbsp;<button id='cmdResetUserPassword' style='width:200px' >Reset Password/Send Email</button>
            </div>
            <div id="emptyUsrMessage"><br /><br /><br /><span style="margin-left:75px;"><b>Please select a User to view.</b></span></div>
        
        </div> 
        <div id="securitytabs-2" > 
            <%// Html.ListBox("vMenuOptionsListItems", Model.menuoptionslist, new { style = "width:425px; height:200px;", multiple = "multiple" })%> 
        </div>  
        <div id="securitytabs-3" > 
            &nbsp;
        </div>   
       
 </div>
