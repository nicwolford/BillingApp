<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.Security_Users>" %>

            <fieldset>
                <div>
                    <%= Html.ValidationSummary()%>
                    <div style="padding-bottom:10px">Please choose a client and a user to associate with that client.</div>
                     
                    <div style="float:left; padding-right:15px">
                    <label class="label-font"; for="client">Client:</label>
                    <%=Html.DropDownList("client", Model.securitycompanieslist, new { style = "width:200px", })%>
                    <%= Html.ValidationMessage("client")%>
                    </div>
                    <div>
                    <label class="label-font"; for="userlist">User:</label>
                    <%=Html.DropDownList("userlist", Model.adduserlist, new { style = "width:200px", })%>
                    <%= Html.ValidationMessage("userlist")%>    
                    </div>
                    <div class='spacer' style='margin: 0; padding: 0; line-height:5px'>&nbsp;</div>           
                </div>

            </fieldset>
            <p></p>

