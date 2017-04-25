<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.Invoices_OverdueInvoiceRemindersSent>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Overdue Invoice Reminders Sent
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="art-content-wide">
        <h2>Overdue Invoice Reminders Sent</h2>

        <div id="divLoadingData" style="width:100%;clear:both;background-color: #f9f9f9;"><br /><b>Loading Data...</b><br />
          <img src="/content/images/load.gif" alt="loading..." />
        </div>

        <div id="divMain" style="display:none;">
            <button type="button" id="btnToggleMessageText" name="btnToggleMessageText" class="btnToggleMessageText">Hide All Message Text</button>
            <button type="button" id="btnShowAllEmails" name="btnShowAllEmails" class="btnShowAllEmails">Show All Emails</button>
            <button type="button" id="btnShowOnlyFailedEmails" name="btnShowOnlyFailedEmails" class="btnShowOnlyFailedEmails">Show Only Failed Emails</button>
            <button type="button" id="btnShowOnlySuccessEmails" name="btnShowOnlySuccessEmails" class="btnShowOnlySuccessEmails">Show Only Success Emails</button>
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Sent Date
                        </th>
                        <th>Client Name
                        </th>
                        <th>Message To
                        </th>
                        <th>Message Subject
                        </th>
                        <th>Message Text
                        </th>
                        <th>Bad Email Address
                        </th>
                    </tr>

                </thead>
                <tbody>
                    <% foreach (var result in Model.Results)
                       { %>
                    <tr class="<%=(result.BadEmailAddress.GetValueOrDefault()? "trFailure": "trSuccess") %>">
                        <td><%: result.SentDate.GetValueOrDefault().ToString("MM/dd/yyyy hh:mm:ss tt") %>
                        </td>
                        <td><%: result.ClientName %>
                        </td>
                        <td><%: result.ToFullName %>
                        </td>
                        <td><%: result.MessageSubject %>
                        </td>
                        <td><span class="spanMessageText"><%= result.MessageText %></span>
                            <button style="display: none" type="button" class="btnShowThisOne">Show This</button>
                            <button type="button" class="btnHideThisOne">Hide This</button>
                        </td>
                        <td><%: result.BadEmailAddress.GetValueOrDefault().ToString() %>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>

        </div>

    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">

    <script type='text/javascript'>

        $(function () {
            $('.btnToggleMessageText').click(function (e) {
                if (this == e.target) {
                    if (String($(this).text()) == "Hide All Message Text") {
                        $('.spanMessageText').hide();
                        $('.btnShowThisOne').show();
                        $('.btnHideThisOne').hide();
                        $(this).text("Show All Message Text");
                    }
                    else {
                        $('.spanMessageText').show();
                        $('.btnShowThisOne').hide();
                        $('.btnHideThisOne').show();
                        $(this).text("Hide All Message Text");
                    }
                }
            });

            $('.btnShowThisOne').click(function (e) {
                if (this == e.target) {
                    $(this).prev().show();
                    $(this).hide();
                    if ($('.btnShowThisOne:visible').length <= 0) {
                        $('.btnToggleMessageText').text("Hide All Message Text");
                    }
                    $(this).next().show();
                }
            });

            $('.btnHideThisOne').click(function (e) {
                if (this == e.target) {
                    $(this).prev().prev().hide();
                    $(this).prev().show();
                    $(this).hide();
                }
            });

            $('.btnShowAllEmails').click(function (e) {
                if (this == e.target) {
                    $('.trFailure').show();
                    $('.trSuccess').show();
                }
            });

            $('.btnShowOnlyFailedEmails').click(function (e) {
                if (this == e.target) {
                    $('.trFailure').show();
                    $('.trSuccess').hide();
                }
            });

            $('.btnShowOnlySuccessEmails').click(function (e) {
                if (this == e.target) {
                    $('.trFailure').hide();
                    $('.trSuccess').show();
                }
            });

            $('.btnToggleMessageText').click();

            setTimeout(function () {
                $('#divLoadingData').hide();
                $('#divMain').show();
            }, 1000);

        });

    </script>
    <style type="text/css">
        .table-striped > tbody > tr:nth-child(odd) > td, .table-striped > tbody > tr:nth-child(odd) > th {
            background-color: #f9f9f9;
        }

        .table-striped > tbody > tr:nth-child(even) > td, .table-striped > tbody > tr:nth-child(even) > th {
            background-color: white;
        }

        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            padding: 8px;
            line-height: 1.42857143;
            vertical-align: top;
            border-top: 1px solid #ddd;
        }
    </style>
</asp:Content>
