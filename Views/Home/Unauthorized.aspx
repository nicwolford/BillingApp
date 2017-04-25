<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Print.Master" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Unauthorized
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <h2>Unauthorized</h2>

    You do not have permission to access this feature or content.  If you believe you are receiving this message in error, please contact your administrator.
        
    <div style="line-height: 22px;">
        <br />
        Where do you want to go now?    
            <br />
        &nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0)" id="PrevPageLink">Back to previous page</a>
        <br />
        &nbsp;&nbsp;&nbsp;&nbsp;<a href="/Home/Index">Main Menu</a>
    </div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
    <script type="text/javascript">
        $(function () {
            $("#PrevPageLink").click(function () {
                if (document.referrer == "") { //alternatively, window.history.length == 0
                    window.location = "/Home/Index";
                } else {
                    history.back();
                }
                return false;
            });
        });
    </script>
</asp:Content>
