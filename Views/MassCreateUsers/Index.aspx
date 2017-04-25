<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Index
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <h2>Index</h2>

    <form>
        <%=Html.ValidationMessage("ErrorMessages")%>
        
        <%=Html.ActionLink("Create Users", "CreateUsers", "MassCreateUsers")%>
       
        <%= Html.Hidden("id", 1)%>
    </form>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>

