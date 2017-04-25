<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	CreateEmails
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
    <h2>CreateUsers</h2>
    <%=Html.ValidationMessage("ErrorMessages")%>
        <% using (Html.BeginForm()) { %>
        <div style="float:left; width:300px;">
            <fieldset>
                Click the button to mass create emails for existing users.<br />
                <input type="submit" value="Create Emails" />
               
                <%= Html.Hidden("myname", "Dave")%>
            </fieldset>
        </div>
    <% } %>
</div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
