<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="confirmEmailTitle" ContentPlaceHolderID="TitleContent" runat="server">
	Email Confirmation
</asp:Content>

<asp:Content ID="confirmEmailContent" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide"> 
<div style="float:left; margin-left:50px;">  
    <h3>Email Confirmation</h3>  
    
        <% using (Html.BeginForm()) { %>
        <div>
             <p>
             <span id="registerSuccess" class="span-instructions">
                <%=Html.Encode(ViewData["emailSuccess"])%>
                <%= Html.ValidationMessage("emailSuccess")%>
            </span>
            </p>
        </div>
        <script type="text/javascript">

            $(function() { setTimeout(redirect,5000); });

            var redirect = function()
            {
                window.location.href = '<%= ViewData["ReturnUrl"] %>';
            }
        
        </script>

        
   <% } %>       
</div>
</div>
</asp:Content>




