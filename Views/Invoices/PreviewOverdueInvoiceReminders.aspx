<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.Invoices_OverdueInvoiceRemindersToSend>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Overdue Invoice Reminders Preview
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="art-content-wide">
        <h2>Overdue Invoice Reminders Preview</h2>

        <div id="divLoadingData" style="width:100%;clear:both;background-color: #f9f9f9;"><br /><b>Loading Data...</b><br />
          <img src="/content/images/load.gif" alt="loading..." />
        </div>

        <div id="divMain" style="display:none;">
            <button type="button" id="btnToggleMessageText" name="btnToggleMessageText" class="btnToggleMessageText">Hide All Message Text</button>
            <button type="button" id="btnShowAllEmails" name="btnShowAllEmails" class="btnShowAllEmails">Show All Emails</button>
            <button type="button" id="btnShowOnlyBadEmails" name="btnShowOnlyBadEmails" class="btnShowOnlyBadEmails">Show Only Bad Emails</button>
            <button type="button" id="btnShowOnlyGoodEmails" name="btnShowOnlyGoodEmails" class="btnShowOnlyGoodEmails">Show Only Good Emails</button>
            <input type="checkbox" id="cbQuickRemove" name="cbQuickRemove" class="cbQuickRemove" /><label for="cbQuickRemove">Quick Remove</label>
            <button style="display:none;" type="button" id="btnRemoveHighlighted" name="btnRemoveHighlighted" class="btnRemoveHighlighted">Remove Highlighted</button>
            <span style="display:none;" class="spanPleaseWait">Please wait...</span>
            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Action
                        </th>
                        <th>Preview Date
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
                        <td><button type="button" name="btnRemoveMessage" class="btnRemoveMessage">Remove</button>
                            <input type="hidden" name="iptGuid" class="iptGuid" value="<%: result.MessageGUID %>" />
                        </td>
                        <td><%: result.SentDate.GetValueOrDefault().ToString("MM/dd/yyyy hh:mm:ss tt") %>
                        </td>
                        <td class="tdClientName"><%: result.ClientName %>
                        </td>
                        <td class="tdFullName"><%: result.ToFullName %>
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
            <% using (Html.BeginForm()) { %>
            <br />
            <button type="submit" id="btnSendEmail" name="btnSendEmail" class="btnSendEmail" value="Send">Send Email</button>&nbsp;&nbsp;
            <button type="submit" id="btnCancel" name="btnCancel" class="btnCancel" value="Cancel">Cancel</button>
            <% } %>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">

    <script type='text/javascript'>
        var PreviewMessages = new Object();
        PreviewMessages.Row = null;
        PreviewMessages.HighlightedCount = null;
        PreviewMessages.HighlightedRemoveWaiting = function () {
            if (PreviewMessages.HighlightedCount == null ||
                PreviewMessages.HighlightedCount == 0) {
                if ($("#cbQuickRemove").is(":checked")) {
                    $('.btnRemoveHighlighted').show();
                }
                $('.spanPleaseWait').hide();

                var elmnts = $('.toRemove').parent();
                if (elmnts.length > 0) {
                    alert("ERROR: Some of the items were not removed. Try again.");
                }
                else {
                    alert("Highlighted Messages Were Removed.");
                }
            }
            else {
                setTimeout(function () {
                    PreviewMessages.HighlightedRemoveWaiting();
                }, 1000);
            }
        };

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

            $('.btnShowOnlyBadEmails').click(function (e) {
                if (this == e.target) {
                    $('.trFailure').show();
                    $('.trSuccess').hide();
                }
            });

            $('.btnShowOnlyGoodEmails').click(function (e) {
                if (this == e.target) {
                    $('.trFailure').hide();
                    $('.trSuccess').show();
                }
            });

            $('.btnRemoveMessage').click(function (e) {
                if (this == e.target) {
                    PreviewMessages.Row = $(this).parent().parent();

                    if (!$("#cbQuickRemove").is(":checked")) {
                        $(PreviewMessages.Row).find("td").addClass("toRemove");

                        setTimeout(function () {
                            var clientName = String($.trim($(PreviewMessages.Row).find('.tdClientName').text()));
                            var fullName = String($.trim($(PreviewMessages.Row).find('.tdFullName').text()));
                            var messageGuid = String($.trim($(PreviewMessages.Row).find('.iptGuid').val()));
                            if (confirm("Are you sure that you want to remove this message for client \"" + clientName + "\" addressed to \"" + fullName + "\"?")) {
                                $.ajax({
                                    url: "/Invoices/RemovePreviewMessageForOverdueInvoiceJSON",
                                    dataType: "json",
                                    type: "post",
                                    data: {
                                        messageGuid: messageGuid
                                    },
                                    success: function (data, textStatus, jqXHR) {
                                        if (!data.success) {
                                            if (data.message != null &&
                                                String($.trim(data.message)) != "") {
                                                alert(String($.trim(data.message)));
                                            }
                                            else {
                                                alert("Unknown error occurred.");
                                            }
                                        }
                                        else {
                                            var messageGuidRemove = String(data.messageGuid);
                                            $('.iptGuid[value="' + String(messageGuidRemove) + '"]').parentsUntil("tr").parent().remove();
                                            alert("Removed Message.");
                                        }
                                    },
                                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                                        alert("Unknown error occurred.");
                                    }
                                });

                            }
                            else {
                                $(".toRemove").removeClass("toRemove");
                            }
                        }, 1);
                    }
                    else {
                        var elmnt = $(PreviewMessages.Row).find("td").first();
                        if ($(elmnt).is(".toRemove")) {
                            $(elmnt).parent().find("td").removeClass("toRemove");
                        }
                        else {
                            $(elmnt).parent().find("td").addClass("toRemove");
                        }
                    }
                }
            });

            $('.cbQuickRemove').change(function () {
                if ($(this).is(":checked")) {
                    $('.tdClientName').addClass("myPointer");
                    $('.btnRemoveHighlighted').show();
                }
                else {
                    $('.tdClientName').removeClass("myPointer");
                    $('.btnRemoveHighlighted').hide();
                }
            });

            $('.btnRemoveHighlighted').click(function (e) {
                if (this == e.target) {
                    var elmnts = $('.toRemove').parent();
                    if (elmnts.length > 0) {
                        PreviewMessages.HighlightedCount = elmnts.length;
                        $('.spanPleaseWait').show();
                        $(this).hide();
                        PreviewMessages.HighlightedRemoveWaiting();

                        $(elmnts).each(function (index) {
                            var messageGuid = String($.trim($(this).find('.iptGuid').val()));
                            $.ajax({
                                url: "/Invoices/RemovePreviewMessageForOverdueInvoiceJSON",
                                dataType: "json",
                                type: "post",
                                data: {
                                    messageGuid: messageGuid
                                },
                                success: function (data, textStatus, jqXHR) {
                                    if (!data.success) {
                                        if (data.message != null &&
                                            String($.trim(data.message)) != "") {
                                            alert(String($.trim(data.message)));
                                        }
                                        else {
                                            //alert("Unknown error occurred.");
                                        }
                                    }
                                    else {
                                        var messageGuidRemove = String(data.messageGuid);
                                        $('.iptGuid[value="' + String(messageGuidRemove) + '"]').parentsUntil("tr").parent().remove();
                                    }
                                    PreviewMessages.HighlightedCount = PreviewMessages.HighlightedCount - 1;
                                },
                                error: function (XMLHttpRequest, textStatus, errorThrown) {
                                    //alert("Unknown error occurred.");
                                    PreviewMessages.HighlightedCount = PreviewMessages.HighlightedCount - 1;
                                }
                            });
                        });
                    }
                }
            });

            $('.tdClientName').click(function () {
                if ($("#cbQuickRemove").is(":checked")) {
                    var cn = String($(this).text());
                    var elmts = $(".tdClientName:contains(" + String(cn) + ")");
                    var isToRemove = $(elmts).is(".toRemove");

                    $(".tdClientName:contains(" + String(cn) + ")").each(function (index) {
                        if (String(cn) == String($(this).text())) {
                            var elmt = $(this).parent().first().find("td");
                            if (isToRemove) {
                                $(elmt).removeClass("toRemove");
                            }
                            else {
                                $(elmt).addClass("toRemove");
                            }
                        }
                    });
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
        .myPointer {
            cursor: pointer;
        }

        .btnRemoveMessage {
            height: 100%;
        }

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

        .toRemove {
            background-color: #FF5858 !important;
        }
    </style>
</asp:Content>
