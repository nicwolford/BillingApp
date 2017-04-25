<%@Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="changePasswordTitle" ContentPlaceHolderID="TitleContent" runat="server">
    Change Password
</asp:Content>

<asp:Content ID="changePasswordSuccessContent" ContentPlaceHolderID="MainContent" runat="server">

<script type="text/javascript">

    $(function() { setTimeout(redirect,5000); });

    var redirect = function()
    {
        window.location.href = '<%= ViewData["ReturnUrl"] %>';
    }

</script>
<div class="art-content-wide"> 
<div style="float:left; margin-left:50px;">  
    <h2>Change Password</h2>
    <h3>Your password has been changed successfully!</h3>
    <p></p><p></p>
</div>
</div>
</asp:Content>
