<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.Invoices_ComposeOverdueInvoiceReminder>"   %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Compose Overdue Invoice Reminder
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="art-content-wide">
        <h2>Compose Overdue Invoice Reminder</h2>
    </div>
    <% using (Html.BeginForm()) { %>
    <div>
        <b><%:"Finance Charge Date:" %></b><br /><%=Html.TextBox("FinanceChargeDate", Model.UserFinanceChargeDate.HasValue ? Model.UserFinanceChargeDate.Value.ToString("MM/dd/yyyy") : "", new { @style = "width:250px", @class = "financeChargeDate" }) %><br /><br />
        <b><%:"Subject:" %></b><br /><%=Html.TextBox("Subject", Model.Subject, new { @style = "width:850px" }) %><br /><br />
        <b><%:"Message:" %></b><br /><%=Html.TextArea("Message", Model.Message, 20, 90, new { @class = "ckeditor" }) %><br />
        <button type="submit" id="btnPreviewEmail" name="btnPreviewEmail" class="btnPreviewEmail" value="Send">Preview Email</button>
        <button type="button" id="btnResetEmail" name="btnResetEmail" class="btnResetEmail" value="Reset">Reset To Default Email</button>
    </div>
    <% } %>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">

    <script type='text/javascript'>

        function LoadCkEditorPlugin(callback) {
            if (!window.CKEDITOR) {
                var basePath = "/ckeditor/";
                var fullPath = basePath + "ckeditor.js";
                fullPath += "?id=" + Math.random().toString();

                window.CKEDITOR_BASEPATH = basePath;
                $.getScript(fullPath, function (a, b, c) {
                    //Set Ckeditor's base path
                    window.CKEDITOR_BASEPATH = basePath;

                    //Callback (if specified)
                    if (callback != undefined && callback != null) callback();
                });
            } else {
                //Callback (if specified)
                if (callback != undefined && callback != null) callback();
            }
        } //LoadCkEditorPlugin()
        
        $(function () {
            LoadCkEditorPlugin(function () {
                CKEDITOR.config.width = 950;
                CKEDITOR.config.height = 325;
                CKEDITOR.config.removePlugins = 'forms,flash,save,templates,print,newpage,preview,div,iframe';
                CKEDITOR.config.extraPlugins = 'lineheight';
            });

            $('.btnResetEmail').click(function (e) {
                if (this == e.target)
                {
                    window.location.assign("/Invoices/ComposeOverdueInvoiceReminder");
                }
            });

            $('.financeChargeDate').datepicker();

        });
        
    </script>

</asp:Content>
