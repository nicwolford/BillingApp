<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.Commissions_PackageCommissions>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Package Commissions
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="art-content-wide">
        <h2>Package Commissions</h2>

        <div id="divLoadingData" style="width: 100%; clear: both; background-color: #f9f9f9;">
            <br />
            <b>Loading Data...</b><br />
            <img src="/content/images/load.gif" alt="loading..." />
        </div>
        <div id="divMain" style="display: none;">
            <table class="table table-striped">
                <thead class="theadPackageCommissions">
                    <tr>
                        <th>Action
                        </th>
                        <th colspan="2">Client Name
                        </th>
                        <th>Package Name
                        </th>
                        <th>Com. Rate
                        </th>
                    </tr>
                    <tr>
                        <th>
                            <button style="width: 100%; height: 100%;" type="button" name="btnAddCommission" class="btnAddCommission myControls new">Add</button>
                        </th>
                        <th colspan="2">
                            <textarea rows="3" cols="512" style="width: 23em;" name="txtClientName" class="txtClientName theadField myControls new"></textarea>
                        </th>
                        <th>
                            <textarea rows="3" cols="512" style="width: 32em;" name="txtPackageName" class="txtPackageName myControls new"></textarea>
                        </th>
                        <th>
                            <textarea rows="3" cols="512" style="width: 5em;" name="txtPackageCommissionRate" class="txtPackageCommissionRate myControls new"></textarea>
                        </th>
                    </tr>
                    <tr>
                        <th>Action
                        </th>
                        <th>Client Name
                        </th>
                        <th>Client ID
                        </th>
                        <th>Package Name
                        </th>
                        <th>Com. Rate
                        </th>
                    </tr>
                </thead>
                <tbody class="tbodyPackageCommissions">
                    <% foreach (var result in Model.Results)
                       { %>
                    <tr>
                        <td>
                            <button type="button" style="width: 100%;" name="btnEditCommission" class="btnEditCommission myControls new">Edit</button>
                            <button type="button" name="btnRemoveCommission" class="btnRemoveCommission myControls new">Remove</button>
                            <button type="button" style="width: 100%; display: none;" name="btnSaveCommission" class="btnSaveCommission myControls new">Save</button>
                            <button type="button" style="width: 100%; display: none;" name="btnCancelCommission" class="btnCancelCommission myControls new">Cancel</button>
                            <input type="hidden" name="hidPackageCommissionID" class="hidPackageCommissionID new" value="<%: result.PackageCommissionID %>" />
                        </td>
                        <td colspan="1" class="tdClientName">
                            <span class="spanClientName"><%: result.ClientName %></span>
                            <textarea rows="3" cols="512" style="width: 23em; display: none;" name="txtClientName" class="txtClientName myControls new"></textarea>
                        </td>
                        <td class="tdClientID">
                            <span class="spanClientID"><%: result.ClientID %></span>
                        </td>
                        <td class="tdPackageName">
                            <span class="spanPackageName"><%: result.PackageName %></span>
                            <textarea rows="3" cols="512" style="width: 32em; display: none;" name="txtPackageName" class="txtPackageName myControls new"></textarea>
                        </td>
                        <td class="tdPackageCommissionRate">
                            <span class="spanPackageCommissionRate"><%: result.PackageCommissionRate.ToString("f2") %></span>
                            <textarea rows="3" cols="512" style="width: 5em; display: none;" name="txtPackageCommissionRate" class="txtPackageCommissionRate myControls new"></textarea>
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
        var Commissions = new Object();
        Commissions.clientNamesCache = {};
        Commissions.tr = null;
        Commissions.btnAddCommission = null;
        Commissions.btnEditCommission = null;
        Commissions.hidPackageCommissionID = null;
        Commissions.btnRemoveCommission = null;
        Commissions.btnSaveCommission = null;
        Commissions.btnCancelCommission = null;
        Commissions.tdClientName = null;
        Commissions.tdClientID = null;
        Commissions.tdPackageName = null;
        Commissions.tdPackageCommissionRate = null;
        Commissions.spanClientID = null;
        Commissions.spanClientName = null;
        Commissions.txtClientName = null;
        Commissions.spanPackageName = null;
        Commissions.txtPackageName = null;
        Commissions.spanPackageCommissionRate = null;
        Commissions.txtPackageCommissionRate = null;
        Commissions.clientName = null;
        Commissions.packageName = null;
        Commissions.packageCommissionRate = null;
        Commissions.packageCommissionID = null;
        Commissions.oldClientName = null;
        Commissions.newClientName = null;
        Commissions.oldPackageName = null;
        Commissions.newPackageName = null;
        Commissions.oldPackageCommissionRate = null;
        Commissions.newPackageCommissionRate = null;
        Commissions.clientID = null;
        Commissions.oldPackageCommissionID = null;

        function bindEvents() {

            $('.txtClientName.new').autocomplete({
                minLength: 1,
                select: function (event, ui) {
                    if (event.target == this) {
                        Commissions.txtClientName = this;
                        if ($(this).hasClass('theadField'))
                        {
                            Commissions.tr = $(this).parentsUntil('thead').last();
                        }
                        else
                        {
                            Commissions.tr = $(this).parentsUntil('tbody').last();
                        }
                        Commissions.txtClientName = $(Commissions.tr).find(".txtClientName").first();
                        Commissions.txtPackageName = $(Commissions.tr).find(".txtPackageName").first();
                        Commissions.txtPackageCommissionRate = $(Commissions.tr).find(".txtPackageCommissionRate").first();
                        
                        $(Commissions.txtClientName).val(String(ui.item.fullObject.ClientName));
                        $(Commissions.txtPackageName).val(String(ui.item.fullObject.PackageName == null ? String($(Commissions.txtPackageName).val()) : ui.item.fullObject.PackageName));
                        $(Commissions.txtPackageCommissionRate).val(String(ui.item.fullObject.PackageCommissionRate == null ? String($(Commissions.txtPackageCommissionRate).val()) : ui.item.fullObject.PackageCommissionRate));
                        return true;
                    }
                },
                source: function (request, response) {
                    var term = request.term;
                    if (term in Commissions.clientNamesCache) {
                        response(Commissions.clientNamesCache[term]);
                        return;
                    }
                    $.post("/Commissions/ClientsSearchByClientNameJSON", { searchTerm: term }, function (data, status, xhr) {
                        var labelValues = new Array();
                        if (data != null &&
                            data.results != null) {
                            for (var iv = 0; iv < data.results.length; iv++) {
                                var label = String(data.results[iv].ClientName) + ' [' + String(data.results[iv].ClientID == null ? "" : data.results[iv].ClientID) + ']';
                                var value = String(data.results[iv].ClientName);
                                labelValues.push({
                                    label: String(label),
                                    value: String(value),
                                    fullObject: data.results[iv]
                                });
                            }
                        }
                        Commissions.clientNamesCache[term] = labelValues;
                        response(labelValues);
                    });
                }
            });

            $('.txtClientName.new').removeClass("new");

            $('.btnAddCommission.new').click(function (e) {

                if (e.target == this) {

                    Commissions.btnAddCommission = this;
                    Commissions.tr = $(this).parentsUntil('thead').last();
                    Commissions.txtClientName = $(Commissions.tr).find(".txtClientName").first();
                    Commissions.txtPackageName = $(Commissions.tr).find(".txtPackageName").first();
                    Commissions.txtPackageCommissionRate = $(Commissions.tr).find(".txtPackageCommissionRate").first();

                    Commissions.clientName = String($.trim($(Commissions.txtClientName).val()));
                    Commissions.packageName = String($.trim($(Commissions.txtPackageName).val()));
                    Commissions.packageCommissionRate = String($.trim($(Commissions.txtPackageCommissionRate).val()));

                    $.ajax({
                        url: "/Commissions/CreatePackageCommissionsJSON",
                        dataType: "json",
                        type: "post",
                        data: {
                            clientName: Commissions.clientName,
                            packageName: Commissions.packageName,
                            packageCommissionRate: Commissions.packageCommissionRate
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
                                alert("Record created.");
                                Commissions.packageCommissionID = data.packageCommissionID;
                                Commissions.clientID = data.clientID;
                                Commissions.clientName = data.clientName;
                                Commissions.packageCommissionRate = data.packageCommissionRate;

                                var arrayOfSpan = $('.spanClientName');
                                var inserted = false;

                                var cn = String($.trim(Commissions.clientName)).toLowerCase();
                                for (var i = 0; i < arrayOfSpan.length; i++) {
                                    if (cn < String($.trim($(arrayOfSpan[i]).text())).toLowerCase()) {
                                        Commissions.tr = $(arrayOfSpan[i]).parentsUntil('tbody').last();
                                        $(Commissions.tr).before(
                                        '<tr>\n' +
                                        '   <td>\n' +
                                        '       <button type="button" style="width: 100%;" name="btnEditCommission" class="btnEditCommission actionButton new">Edit</button>\n' +
                                        '       <button type="button" name="btnRemoveCommission" class="btnRemoveCommission actionButton new">Remove</button>\n' +
                                        '       <button type="button" style="width: 100%; display: none;" name="btnSaveCommission" class="btnSaveCommission actionButton new">Save</button>\n' +
                                        '       <button type="button" style="width: 100%; display: none;" name="btnCancelCommission" class="btnCancelCommission actionButton new">Cancel</button>\n' +
                                        '       <input type="hidden" name="hidPackageCommissionID" class="hidPackageCommissionID new" value="' + String(Commissions.packageCommissionID) + '" />\n' +
                                        '   </td>\n' +
                                        '   <td colspan="1" class="tdClientName">\n' +
                                        '       <span class="spanClientName">' + String($('<div></div>').text(String(Commissions.clientName)).html()) + '</span>\n' +
                                        '       <textarea rows="3" cols="512" style="width: 23em; display: none;" name="txtClientName" class="txtClientName new"></textarea>\n' +
                                        '   </td>\n' +
                                        '   <td class="tdClientID">\n' +
                                        '       <span class="spanClientID">' + String($('<div></div>').text(String(Commissions.clientID)).html()) + '</span>\n' +
                                        '   </td>\n' +
                                        '   <td class="tdPackageName">\n' +
                                        '       <span class="spanPackageName">' + String($('<div></div>').text(String(Commissions.packageName)).html()) + '</span>\n' +
                                        '       <textarea rows="3" cols="512" style="width: 34em; display: none;" name="txtPackageName" class="txtPackageName new"></textarea>\n' +
                                        '   </td>\n' +
                                        '   <td class="tdPackageCommissionRate">\n' +
                                        '       <span class="spanPackageCommissionRate">' + String($('<div></div>').text(String(Commissions.packageCommissionRate)).html()) + '</span>\n' +
                                        '       <textarea rows="3" cols="512" style="width: 3em; display: none;" name="txtPackageCommissionRate" class="txtPackageCommissionRate new"></textarea>\n' +
                                        '   </td>\n' +
                                        '</tr>\n');
                                        inserted = true;
                                        break;
                                    }
                                }

                                if (!inserted) {
                                    $('.tbodyPackageCommissions').prepend(
                                        '<tr>\n' +
                                        '   <td>\n' +
                                        '       <button type="button" style="width: 100%;" name="btnEditCommission" class="btnEditCommission actionButton new">Edit</button>\n' +
                                        '       <button type="button" name="btnRemoveCommission" class="btnRemoveCommission actionButton new">Remove</button>\n' +
                                        '       <button type="button" style="width: 100%; display: none;" name="btnSaveCommission" class="btnSaveCommission actionButton new">Save</button>\n' +
                                        '       <button type="button" style="width: 100%; display: none;" name="btnCancelCommission" class="btnCancelCommission actionButton new">Cancel</button>\n' +
                                        '       <input type="hidden" name="hidPackageCommissionID" class="hidPackageCommissionID new" value="' + String(Commissions.packageCommissionID) + '" />\n' +
                                        '   </td>\n' +
                                        '   <td colspan="1" class="tdClientName">\n' +
                                        '       <span class="spanClientName">' + String($('<div></div>').text(String(Commissions.clientName)).html()) + '</span>\n' +
                                        '       <textarea rows="3" cols="512" style="width: 23em; display: none;" name="txtClientName" class="txtClientName new"></textarea>\n' +
                                        '   </td>\n' +
                                        '   <td class="tdClientID">\n' +
                                        '       <span class="spanClientID">' + String($('<div></div>').text(String(Commissions.clientID)).html()) + '</span>\n' +
                                        '   </td>\n' +
                                        '   <td class="tdPackageName">\n' +
                                        '       <span class="spanPackageName">' + String($('<div></div>').text(String(Commissions.packageName)).html()) + '</span>\n' +
                                        '       <textarea rows="3" cols="512" style="width: 34em; display: none;" name="txtPackageName" class="txtPackageName new"></textarea>\n' +
                                        '   </td>\n' +
                                        '   <td class="tdPackageCommissionRate">\n' +
                                        '       <span class="spanPackageCommissionRate">' + String($('<div></div>').text(String(Commissions.packageCommissionRate)).html()) + '</span>\n' +
                                        '       <textarea rows="3" cols="512" style="width: 3em; display: none;" name="txtPackageCommissionRate" class="txtPackageCommissionRate new"></textarea>\n' +
                                        '   </td>\n' +
                                        '</tr>\n');
                                }

                                Commissions.tr = $(Commissions.btnAddCommission).parentsUntil('thead').last();
                                Commissions.txtClientName = $(Commissions.tr).find(".txtClientName").first();
                                Commissions.txtPackageName = $(Commissions.tr).find(".txtPackageName").first();
                                Commissions.txtPackageCommissionRate = $(Commissions.tr).find(".txtPackageCommissionRate").first();

                                $(Commissions.txtClientName).val("");
                                $(Commissions.txtPackageName).val("");
                                $(Commissions.txtPackageCommissionRate).val("");

                                bindEvents();
                            }
                        },
                        error: function (XMLHttpRequest, textStatus, errorThrown) {
                            alert("Unknown error occurred.");
                        }
                    });

                }

            });

            $('.btnAddCommission.new').removeClass("new");

            $('.btnRemoveCommission.new').click(function (e) {

                if (e.target == this) {

                    Commissions.btnRemoveCommission = this;
                    Commissions.tr = $(this).parentsUntil('tbody').last();
                    Commissions.hidPackageCommissionID = $(Commissions.tr).find(".hidPackageCommissionID").first();
                    Commissions.tdClientName = $(Commissions.tr).find(".tdClientName").first();
                    Commissions.tdClientID = $(Commissions.tr).find(".tdClientID").first();
                    Commissions.tdPackageName = $(Commissions.tr).find(".tdPackageName").first();
                    Commissions.tdPackageCommissionRate = $(Commissions.tr).find(".tdPackageCommissionRate").first();
                    Commissions.spanClientID = $(Commissions.tdClientID).find(".spanClientID").first();
                    Commissions.spanClientName = $(Commissions.tdClientName).find(".spanClientName").first();
                    Commissions.spanPackageName = $(Commissions.tdPackageName).find(".spanPackageName").first();
                    Commissions.spanPackageCommissionRate = $(Commissions.tdPackageCommissionRate).find(".spanPackageCommissionRate").first();

                    Commissions.clientName = String($.trim($(Commissions.spanClientName).text()));
                    Commissions.packageName = String($.trim($(Commissions.spanPackageName).text()));
                    Commissions.packageCommissionRate = String($.trim($(Commissions.spanPackageCommissionRate).text()));

                    Commissions.packageCommissionID = String($.trim($(Commissions.hidPackageCommissionID).val()));

                    if (confirm("Are you sure that you want to remove this record \n\n\"" + Commissions.clientName + "\", \n\n\"" + Commissions.packageName + "\", and \n\n\"" + Commissions.packageCommissionRate + "\"\n\n?")) {
                        $.ajax({
                            url: "/Commissions/RemovePackageCommissionsJSON",
                            dataType: "json",
                            type: "post",
                            data: {
                                packageCommissionID: Commissions.packageCommissionID
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
                                    alert("Record deleted.");
                                    Commissions.packageCommissionID = data.packageCommissionID;
                                    Commissions.tr = $('.hidPackageCommissionID[value="' + String(Commissions.packageCommissionID) + '"]').parentsUntil('tbody').last();
                                    $(Commissions.tr).remove();
                                }
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                alert("Unknown error occurred.");
                            }
                        });
                    }

                }

            });

            $('.btnRemoveCommission.new').removeClass("new");

            $('.btnEditCommission.new').click(function (e) {

                if (e.target == this) {

                    Commissions.btnEditCommission = this;
                    Commissions.tr = $(this).parentsUntil('tbody').last();
                    Commissions.hidPackageCommissionID = $(Commissions.tr).find(".hidPackageCommissionID").first();
                    Commissions.btnRemoveCommission = $(Commissions.tr).find(".btnRemoveCommission").first();
                    Commissions.btnSaveCommission = $(Commissions.tr).find(".btnSaveCommission").first();
                    Commissions.btnCancelCommission = $(Commissions.tr).find(".btnCancelCommission").first();
                    Commissions.tdClientName = $(Commissions.tr).find(".tdClientName").first();
                    Commissions.tdClientID = $(Commissions.tr).find(".tdClientID").first();
                    Commissions.tdPackageName = $(Commissions.tr).find(".tdPackageName").first();
                    Commissions.tdPackageCommissionRate = $(Commissions.tr).find(".tdPackageCommissionRate").first();
                    Commissions.spanClientID = $(Commissions.tdClientID).find(".spanClientID").first();
                    Commissions.spanClientName = $(Commissions.tdClientName).find(".spanClientName").first();
                    Commissions.txtClientName = $(Commissions.tdClientName).find(".txtClientName").first();
                    Commissions.spanPackageName = $(Commissions.tdPackageName).find(".spanPackageName").first();
                    Commissions.txtPackageName = $(Commissions.tdPackageName).find(".txtPackageName").first();
                    Commissions.spanPackageCommissionRate = $(Commissions.tdPackageCommissionRate).find(".spanPackageCommissionRate").first();
                    Commissions.txtPackageCommissionRate = $(Commissions.tdPackageCommissionRate).find(".txtPackageCommissionRate").first();

                    Commissions.packageCommissionID = String($.trim($(Commissions.hidPackageCommissionID).val()));

                    $(Commissions.btnEditCommission).hide();
                    $(Commissions.btnRemoveCommission).hide();
                    $(Commissions.btnSaveCommission).show();
                    $(Commissions.btnCancelCommission).show();

                    $(Commissions.tdClientID).hide();
                    $(Commissions.tdClientName).attr("colspan", "2");

                    $(Commissions.spanClientName).hide();
                    $(Commissions.txtClientName).show();
                    $(Commissions.txtClientName).val($.trim($(Commissions.spanClientName).text()));
                    $(Commissions.txtClientName).text($.trim($(Commissions.spanClientName).text()));

                    $(Commissions.spanPackageName).hide();
                    $(Commissions.txtPackageName).show();
                    $(Commissions.txtPackageName).val($.trim($(Commissions.spanPackageName).text()));
                    $(Commissions.txtPackageName).text($.trim($(Commissions.spanPackageName).text()));

                    $(Commissions.spanPackageCommissionRate).hide();
                    $(Commissions.txtPackageCommissionRate).show();
                    $(Commissions.txtPackageCommissionRate).val($.trim($(Commissions.spanPackageCommissionRate).text()));
                    $(Commissions.txtPackageCommissionRate).text($.trim($(Commissions.spanPackageCommissionRate).text()));

                }

            });

            $('.btnEditCommission.new').removeClass("new");

            $('.btnSaveCommission.new').click(function (e) {

                if (e.target == this) {

                    Commissions.btnSaveCommission = this;
                    Commissions.tr = $(this).parentsUntil('tbody').last();
                    Commissions.hidPackageCommissionID = $(Commissions.tr).find(".hidPackageCommissionID").first();
                    Commissions.btnEditCommission = $(Commissions.tr).find(".btnEditCommission").first();
                    Commissions.btnRemoveCommission = $(Commissions.tr).find(".btnRemoveCommission").first();
                    Commissions.btnCancelCommission = $(Commissions.tr).find(".btnCancelCommission").first();
                    Commissions.tdClientName = $(Commissions.tr).find(".tdClientName").first();
                    Commissions.tdClientID = $(Commissions.tr).find(".tdClientID").first();
                    Commissions.tdPackageName = $(Commissions.tr).find(".tdPackageName").first();
                    Commissions.tdPackageCommissionRate = $(Commissions.tr).find(".tdPackageCommissionRate").first();
                    Commissions.spanClientID = $(Commissions.tdClientID).find(".spanClientID").first();
                    Commissions.spanClientName = $(Commissions.tdClientName).find(".spanClientName").first();
                    Commissions.txtClientName = $(Commissions.tdClientName).find(".txtClientName").first();
                    Commissions.spanPackageName = $(Commissions.tdPackageName).find(".spanPackageName").first();
                    Commissions.txtPackageName = $(Commissions.tdPackageName).find(".txtPackageName").first();
                    Commissions.spanPackageCommissionRate = $(Commissions.tdPackageCommissionRate).find(".spanPackageCommissionRate").first();
                    Commissions.txtPackageCommissionRate = $(Commissions.tdPackageCommissionRate).find(".txtPackageCommissionRate").first();

                    Commissions.packageCommissionID = String($.trim($(Commissions.hidPackageCommissionID).val()));

                    Commissions.oldClientName = String($.trim($(Commissions.spanClientName).text()));
                    Commissions.newClientName = String($.trim($(Commissions.txtClientName).val()));

                    Commissions.oldPackageName = String($.trim($(Commissions.spanPackageName).text()));
                    Commissions.newPackageName = String($.trim($(Commissions.txtPackageName).val()));

                    Commissions.oldPackageCommissionRate = String($.trim($(Commissions.spanPackageCommissionRate).text()));
                    Commissions.newPackageCommissionRate = String($.trim($(Commissions.txtPackageCommissionRate).val()));

                    if (confirm("Are you sure that you want to change this record \n\nFROM \n\n\"" + Commissions.oldClientName + "\", \n\n\"" + Commissions.oldPackageName + "\", and \n\n\"" + Commissions.oldPackageCommissionRate + "\" \n\nTO \n\n\"" + Commissions.newClientName + "\", \n\n\"" + Commissions.newPackageName + "\", and \n\n\"" + Commissions.newPackageCommissionRate + "\"\n\n?")) {
                        $.ajax({
                            url: "/Commissions/UpdatePackageCommissionsJSON",
                            dataType: "json",
                            type: "post",
                            data: {
                                packageCommissionID: Commissions.packageCommissionID,
                                clientName: Commissions.newClientName,
                                packageName: Commissions.newPackageName,
                                packageCommissionRate: Commissions.newPackageCommissionRate
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
                                    alert("Record updated.");
                                    Commissions.packageCommissionID = data.packageCommissionID;
                                    Commissions.clientID = data.clientID;
                                    Commissions.clientName = data.clientName;
                                    Commissions.packageCommissionRate = data.packageCommissionRate;
                                    Commissions.oldPackageCommissionID = data.oldPackageCommissionID;

                                    Commissions.tr = $('.hidPackageCommissionID[value="' + String(Commissions.oldPackageCommissionID) + '"]').parentsUntil('tbody').last();

                                    Commissions.hidPackageCommissionID = $(Commissions.tr).find(".hidPackageCommissionID").first();
                                    Commissions.btnEditCommission = $(Commissions.tr).find(".btnEditCommission").first();
                                    Commissions.btnRemoveCommission = $(Commissions.tr).find(".btnRemoveCommission").first();
                                    Commissions.btnCancelCommission = $(Commissions.tr).find(".btnCancelCommission").first();
                                    Commissions.tdClientName = $(Commissions.tr).find(".tdClientName").first();
                                    Commissions.tdClientID = $(Commissions.tr).find(".tdClientID").first();
                                    Commissions.tdPackageName = $(Commissions.tr).find(".tdPackageName").first();
                                    Commissions.tdPackageCommissionRate = $(Commissions.tr).find(".tdPackageCommissionRate").first();
                                    Commissions.spanClientID = $(Commissions.tdClientID).find(".spanClientID").first();
                                    Commissions.spanClientName = $(Commissions.tdClientName).find(".spanClientName").first();
                                    Commissions.txtClientName = $(Commissions.tdClientName).find(".txtClientName").first();
                                    Commissions.spanPackageName = $(Commissions.tdPackageName).find(".spanPackageName").first();
                                    Commissions.txtPackageName = $(Commissions.tdPackageName).find(".txtPackageName").first();
                                    Commissions.spanPackageCommissionRate = $(Commissions.tdPackageCommissionRate).find(".spanPackageCommissionRate").first();
                                    Commissions.txtPackageCommissionRate = $(Commissions.tdPackageCommissionRate).find(".txtPackageCommissionRate").first();

                                    $(Commissions.spanClientID).text(Commissions.clientID);
                                    $(Commissions.spanClientName).text(Commissions.clientName);
                                    $(Commissions.spanPackageName).text(Commissions.newPackageName);
                                    $(Commissions.spanPackageCommissionRate).text(Commissions.packageCommissionRate);

                                    $(Commissions.btnSaveCommission).hide();
                                    $(Commissions.btnEditCommission).show();
                                    $(Commissions.btnRemoveCommission).show();
                                    $(Commissions.btnCancelCommission).hide();

                                    $(Commissions.tdClientID).show();
                                    $(Commissions.tdClientName).attr("colspan", "1");

                                    $(Commissions.spanClientName).show();
                                    $(Commissions.txtClientName).hide();

                                    $(Commissions.spanPackageName).show();
                                    $(Commissions.txtPackageName).hide();

                                    $(Commissions.spanPackageCommissionRate).show();
                                    $(Commissions.txtPackageCommissionRate).hide();
                                }
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                alert("Unknown error occurred.");
                            }
                        });
                    }

                }

            });

            $('.btnSaveCommission.new').removeClass("new");

            $('.btnCancelCommission.new').click(function (e) {

                if (e.target == this) {

                    Commissions.btnCancelCommission = this;
                    Commissions.tr = $(this).parentsUntil('tbody').last();
                    Commissions.hidPackageCommissionID = $(Commissions.tr).find(".hidPackageCommissionID").first();
                    Commissions.btnEditCommission = $(Commissions.tr).find(".btnEditCommission").first();
                    Commissions.btnRemoveCommission = $(Commissions.tr).find(".btnRemoveCommission").first();
                    Commissions.btnSaveCommission = $(Commissions.tr).find(".btnSaveCommission").first();
                    Commissions.tdClientName = $(Commissions.tr).find(".tdClientName").first();
                    Commissions.tdClientID = $(Commissions.tr).find(".tdClientID").first();
                    Commissions.tdPackageName = $(Commissions.tr).find(".tdPackageName").first();
                    Commissions.tdPackageCommissionRate = $(Commissions.tr).find(".tdPackageCommissionRate").first();
                    Commissions.spanClientID = $(Commissions.tdClientID).find(".spanClientID").first();
                    Commissions.spanClientName = $(Commissions.tdClientName).find(".spanClientName").first();
                    Commissions.txtClientName = $(Commissions.tdClientName).find(".txtClientName").first();
                    Commissions.spanPackageName = $(Commissions.tdPackageName).find(".spanPackageName").first();
                    Commissions.txtPackageName = $(Commissions.tdPackageName).find(".txtPackageName").first();
                    Commissions.spanPackageCommissionRate = $(Commissions.tdPackageCommissionRate).find(".spanPackageCommissionRate").first();
                    Commissions.txtPackageCommissionRate = $(Commissions.tdPackageCommissionRate).find(".txtPackageCommissionRate").first();

                    Commissions.packageCommissionID = String($.trim($(Commissions.hidPackageCommissionID).val()));

                    $(Commissions.btnCancelCommission).hide();
                    $(Commissions.btnEditCommission).show();
                    $(Commissions.btnRemoveCommission).show();
                    $(Commissions.btnSaveCommission).hide();

                    $(Commissions.tdClientID).show();
                    $(Commissions.tdClientName).attr("colspan", "1");

                    $(Commissions.spanClientName).show();
                    $(Commissions.txtClientName).hide();

                    $(Commissions.spanPackageName).show();
                    $(Commissions.txtPackageName).hide();

                    $(Commissions.spanPackageCommissionRate).show();
                    $(Commissions.txtPackageCommissionRate).hide();

                }

            });

            $('.btnCancelCommission.new').removeClass("new");
        }

        $(function () {

            setTimeout(function () {
                $('#divLoadingData').hide();
                $('#divMain').show();
            }, 1000);

            bindEvents();

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

        .toRemove {
            background-color: #FF5858 !important;
        }
    </style>
</asp:Content>
