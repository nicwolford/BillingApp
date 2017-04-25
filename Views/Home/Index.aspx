<%@ Page Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="indexTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Home Page
</asp:Content>

<asp:Content ID="indexContent" ContentPlaceHolderID="MainContent" runat="server">
   <br />
   <%if (ConfigurationManager.AppSettings["adminName"] == "ScreeningOne")
        { %>
        <iframe style="margin-left:15px" id="ifrReportContent" scrolling="no" height="558px" width="935px" src="https://701743-db2/ReportServer?%2fBilling+Reports%2fBillingDashboard&rs:Command=RenderHTML&rs:Toolbar=false">
        </iframe>
        <% }
    else
    { %>
        <iframe style="margin-left:15px" id="ifrReportContent" scrolling="no" height="558px" width="935px" src="https://701743-db2/ReportServer?%2fBilling+Reports%2fBillingDashboard+-+Western&rs:Command=RenderHTML&rs:Toolbar=false">
        </iframe>
    <% } %>

</asp:Content>
