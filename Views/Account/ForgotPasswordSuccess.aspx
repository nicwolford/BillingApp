<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="forgotPasswordSuccessTitle" ContentPlaceHolderID="TitleContent" runat="server">
	ForgotPasswordSuccess
</asp:Content>

<asp:Content ID="forgotPasswordSuccessContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide"> 
<div style="float:left; margin-left:50px;">  
    <h3>You have requested a password reset.</h3>  
    <span class="span-instructions">An email has been sent to 
    
    <span id="forgotPasswordEmail" class="span-error">
        <%=Html.Encode(ViewData["email"])%>
    </span>
    
    . Please follow the instructions provided in the email to reset your password. </span>
    <p></p>
</div>
</div>
</asp:Content>
