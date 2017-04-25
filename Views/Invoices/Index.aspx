<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.Invoices_Index>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Invoices, Credits, and Finance Charges
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
    <h2>Invoices, Credits, and Finance Charges</h2>
    
   <div style='margin-bottom:5px; font-weight:bold;'>Invoice Date - Start:
        <span style='margin-left:3px;'><%= Html.TextBox("txtStartDate", Model.StartDate, new { style = "width:60px;" })%></span>
        <span style='margin-left:10px;'>End:</span>
        <span style='margin-left:3px;'><%= Html.TextBox("txtEndDate", Model.EndDate, new { style = "width:60px;" })%></span>
        <span style='margin-left:10px;'>Audit Clients Only:</span>
        <span style='margin-left:3px;'><%= Html.CheckBox("chkAuditOnly",false) %></span>
        <span style='margin-left:20px;'>Invoice #:</span>
        <span style='margin-left:3px;'><%= Html.TextBox("txtInvoiceNumber","",new { style="width:60px;"})%></span>
        <span style='margin-left:20px;'>Status:</span>
        <span style='margin-left:3px;'>
        <select id='selStatusFilter'>
            <option value="0">All</option>
            <option value="1">In Progress-All</option>
            <option value="2">In Progress-Online</option>
            <option value="3">In Progress-Email-Auto</option>
            <option value="4">In Progress-Email-Manual</option>
            <option value="5">In Progress-Mail</option>
            <option value="6">Released</option>
            <option value="7">Emailed</option>
            <option value="8">Mailed</option>
            <option value="9">Pending Release</option>
        </select>
        </span>
        
    </div>
    <div style='margin-bottom:5px; font-weight:bold;'>
    Client:
    <span style='margin-left:3px;'><select id='selClient' style='width:300px;'>
        <%--Removing this to avoid running invoices for all clients. Jira:16 --%>
        <%--<option value='0'>[All Clients]</option>--%>
        <% foreach (var client in Model.ClientsList)
        { %>
        
            <option value='<%= client.Value %>'><%= Html.Encode(client.Text) %></option>
        
        <% } %>
    </select>
    </span>
    <span id='spanBillingContactDropdown' style='display:none; margin-left:20px;'>
    Billing Contact: 
        <span style='margin-left:3px;'><select id='selBillingContact' style='width:500px;'>
            <option value='0'>[All Billing Contacts]</option>
        </select>
        </span>
        
    </span>
    </div>
   

    <table id='list2'></table>
    <div id='pager2'></div>

<script type='text/javascript'>



    jQuery(document).ready(function() {
        $('#txtStartDate').datepicker({ showOn: 'both', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true, changeMonth: true, changeYear: true });
        $('#txtEndDate').datepicker({ showOn: 'both', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true, changeMonth: true, changeYear: true });

        $('#selClient').change(function() {
            if ($('#selClient').val() != 0) {
                UpdateBillingContactDropdownItems();
                $('#spanBillingContactDropdown').show();
            }
            else {
                $('#selBillingContact').val('0');
                $('#spanBillingContactDropdown').hide();
            }

            reloadGrid();
        });



        $('#chkAuditOnly').change(function() {

            var selClientID = $('#selClient').val();
            var url = "../../Invoices/GetClientListNonAuditForDropdownJSON/";
            var allClientTxt = "[All Clients]";
            if ($('#chkAuditOnly').is(':checked')) {
                allClientTxt = "[All Clients - Audit Only]";
                url = "../../Invoices/GetClientListAuditOnlyForDropdownJSON/"
            }
            // call controller's action
            $.post(url, { StartDate: $('#txtStartDate').val(), EndDate: $('#txtEndDate').val() }, function(data) {
                $('#selClient').empty();
                $('#selClient').append($('<option></option>').val('0').html(allClientTxt));
                for (i = 0; i < data.rows.length; i++) {
                    if (selClientID == data.rows[i].Value) {
                        $('#selClient').append(
                        $('<option selected></option>').val(data.rows[i].Value).html(data.rows[i].Text)
                        );
                    }
                    else {
                        $('#selClient').append(
                        $('<option></option>').val(data.rows[i].Value).html(data.rows[i].Text)
                        );

                    }
                }

                reloadGrid();
            }, 'json');

        });


        $('#selBillingContact').change(function() {
            if ($('#selBillingContact').val() == 0) {
                $('#chkBillingContactForAnyClient').removeAttr('checked');
            }

            reloadGrid();
        });

        $('#txtStartDate').change(function() {
            reloadGrid();
        });

        $('#txtEndDate').change(function() {
            reloadGrid();
        });

        $('#chkBillingContactForAnyClient').change(function() {
            if ($('#selBillingContact').val() == 0) {
                $('#chkBillingContactForAnyClient').removeAttr('checked');
            }
            reloadGrid();
        });

        $('#txtInvoiceNumber').blur(function() {
            reloadGrid();
        });

        $('#selStatusFilter').change(function() {
            reloadGrid();
        });

        function UpdateBillingContactDropdownItems() {
            //Billing Contact Dropdown
            $.post("../../Invoices/GetBillingContactsForClient/" + $('#selClient').val(), function(data) {
                $('#selBillingContact').empty();
                $('#selBillingContact').append(
                        $('<option></option>').val('0').html("[All Billing Contacts]")
                    );
                for (i = 0; i < data.rows.length; i++) {
                    $('#selBillingContact').append(
                              $('<option></option>').val(data.rows[i].Value).html(data.rows[i].Text)
                        );
                }
            }, 'json');
        }

        $('#list2').jqGrid({
            url: '../../Invoices/IndexJSON',
            datatype: 'json',
            colModel: [
            { name: 'id', index: 'id', key: true, hidden: true },
            { name: 'Action', index: 'Action', align: 'left', width: 120 },
            { name: 'InvoiceDate', index: 'InvoiceDate', align: 'left', width: 120 },
            { name: 'InvoiceNumber', index: 'InvoiceNumber', align: 'left', width: 120 },
            { name: 'InvoiceTypeDesc', index: 'InvoiceTypeDesc', align: 'left', width: 110 },
            { name: 'ClientName', index: 'ClientName', align: 'left', width: 280 },
            { name: 'ReleasedStatus', index: 'ReleasedStatus', align: 'left', width: 120 },
            { name: 'OriginalAmount', index: 'OriginalAmount', align: 'right', width: 100 },
            { name: 'InvoiceAmount', index: 'InvoiceAmount', align: 'right', width: 100 }
            ],
            colNames: ['id', 'Action', 'Invoice Date', 'Invoice #', 'Type', 'Client', 'Status',
            'Original Amount', 'Amount Due'],
            //onSelectRow: function(id) { window.open('../../Invoices/Details/' + id); },
            width: 966,
            height: 250,
            sortable: true,
            mtype: 'POST',
            rowNum: 10,
            rowList: [10, 50, 100],
            pager: '#pager2',
            sortname: 'id',
            viewrecords: true,
            sortorder: 'desc',
            caption: 'Invoices',
            rownumbers: false,
            postData: { ClientID: 0, BillingContactID: 0, StartDate: '<%= Model.StartDate %>', EndDate: '<%= Model.EndDate %>', BillingContactForAnyClient: false,
                InvoiceNumber: '', DeliveryMethod: -1, ReleaseStatus: -1, AuditClientsOnly: false
            },
            gridComplete: function() {
                var ids = jQuery('#list2').jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                    var cl = ids[i];
                    var rowValues = jQuery("#list2").jqGrid('getRowData', cl);

                    if (rowValues.InvoiceTypeDesc == 'Invoice') {
                        $('#list2').jqGrid('setRowData', cl, { Action: "<a href='javascript:openInvoice(" + cl + ");' title='View Invoice'>View Invoice</a>&nbsp;<a href='javascript:pdfInvoice(" + cl + ");'><img src='../../Content/images/pdficon_small.gif' alt='Print PDF'/></a>" });
                    }
                    if (rowValues.InvoiceTypeDesc == 'Finance Charge') {
                        $('#list2').jqGrid('setRowData', cl, { Action: "<a href='javascript:openInvoice(" + cl + ");' title='View Charge'>View Charge</a>&nbsp;<a href='javascript:pdfInvoice(" + cl + ");'><img src='../../Content/images/pdficon_small.gif' alt='Print PDF'/></a>" });
                    }
                    else if (rowValues.InvoiceTypeDesc == 'Credit') {
                        $('#list2').jqGrid('setRowData', cl, { Action: "<a href='javascript:modifyCredit(" + cl + ");'>Modify Credit</a>" });
                    }

                    if (rowValues.ReleasedStatus == 'Pending Release') {
                        $('#list2').jqGrid('setRowData', cl, { ReleasedStatus: "<a href='javascript:openPendingRelease(" + cl + ");'>Pending Release</a>" });
                    }
                }
            },
            loadui: 'block',
            footerrow: true,
            userDataOnFooter: true,
            multiselect: true,
            toolbar: [true, "top"],
            gridview: true
        });



        jQuery('#list2').jqGrid('navGrid', '#pager2', { edit: false, add: false, del: false, search: false, refresh: false },
{}, // edit options
{}, // add options
{}, //del options
{}
);

        $("#relatedinvoicesdlg").dialog({
            bgiframe: true,
            autoOpen: false,
            height: 300,
            width: 700,
            modal: true,
            draggable: false,
            resizable: false,
            buttons: {
                Close: function() {
                    $(this).dialog('close');
                }
            }
        });


        $("#createnewcreditdlg").dialog({
            bgiframe: true,
            autoOpen: false,
            height: 467,
            width: 700,
            modal: true,
            draggable: false,
            resizable: false,
            buttons: {
                'Save': function() {
                    var hiddenModifyCredit;
                    if ($('#hiddenModifyCredit').val() == '') {
                        hiddenModifyCredit = 0;
                    }
                    else {
                        hiddenModifyCredit = $('#hiddenModifyCredit').val();
                    }

                    //alert('InvoiceDate:' + $('#creditInvoiceDate').val() + ' InvoiceAmount: ' + $('#creditAmount').val() + ' PublicDescription: ' + $('#creditPublicDescription').val() + ' PrivateDescription: ' + $('#creditPrivateDescription').val() + ' BillingContactID: ' + $('#creditBillingContactID').val() + ' RelatedInvoiceID: ' + $('#creditInvoiceID').val() + ' ModifyCredit: ' + hiddenModifyCredit);

                    $.post('../../Invoices/SaveCreditJSON', {
                        InvoiceDate: $('#creditInvoiceDate').val(),
                        InvoiceAmount: $('#creditAmount').val(),
                        PublicDescription: $('#creditPublicDescription').val(),
                        PrivateDescription: $('#creditPrivateDescription').val(),
                        BillingContactID: $('#creditBillingContactID').val(),
                        RelatedInvoiceID: $('#creditInvoiceID').val(),
                        ModifyCreditID: hiddenModifyCredit
                    },
                    function(data) {
                        if (data.success) {
                            alert('Changes have been saved');
                            reloadGrid();
                        }
                        else {
                            alert('Error creating/modifying credit!');
                        }
                    }, 'json');

                    $(this).dialog('close');
                },
                Close: function() {
                    $(this).dialog('close');
                }
            }
        });


    });

    function openInvoice(id) {
        window.open('../../Invoices/Details/' + id);
    }

    function pdfInvoice(id) {
        location.href = '/Invoices/PrintInvoiceToPDF/' + id;
    }

    function openPendingRelease(id) {
        $('#relatedinvoicesdlgcontent').empty();
        $('#relatedinvoicesdlgcontent').load('../../Invoices/RelatedInvoices/' + id);
        $('#relatedinvoicesdlg').dialog('open');
    }

    function openCreateNewCredit() {
        $('#relatedinvoicesdlgcontent').empty();
        $('#createnewcreditdlgcontent').load('../../Invoices/CreateNewCredit');
        $('#createnewcreditdlg').dialog('open');
    }

    function modifyCredit(id) {
        $('#createnewcreditdlgcontent').load('../../Invoices/ModifyCredit/' + id);
        $('#createnewcreditdlg').dialog('open');
    }

    function reloadGrid() {
        //alert($('#chkBillingContactForAnyClient').val());
        var BillingContactForAnyClient, DeliveryMethod, ReleaseStatus;

        if ($('#selStatusFilter').val() == "0") {
            DeliveryMethod = -1;
            ReleaseStatus = -1;
        }
        else if ($('#selStatusFilter').val() == "1") {
            DeliveryMethod = -1;
            ReleaseStatus = 0;
        }
        else if ($('#selStatusFilter').val() == "2") {
            DeliveryMethod = 0;
            ReleaseStatus = 0;
        }
        else if ($('#selStatusFilter').val() == "3") {
            DeliveryMethod = 1;
            ReleaseStatus = 0;
        }
        else if ($('#selStatusFilter').val() == "4") {
            DeliveryMethod = 2;
            ReleaseStatus = 0;
        }
        else if ($('#selStatusFilter').val() == "5") {
            DeliveryMethod = 3;
            ReleaseStatus = 0;
        }
        else if ($('#selStatusFilter').val() == "6") {
            DeliveryMethod = -1;
            ReleaseStatus = 1;
        }
        else if ($('#selStatusFilter').val() == "7") {
            DeliveryMethod = -1;
            ReleaseStatus = 2;
        }
        else if ($('#selStatusFilter').val() == "8") {
            DeliveryMethod = -1;
            ReleaseStatus = 3;
        }
        else if ($('#selStatusFilter').val() == "9") {
            DeliveryMethod = -1;
            ReleaseStatus = 4;
        }
        else {
            DeliveryMethod = -1;
            ReleaseStatus = -1;
        }

        if ($('#chkBillingContactForAnyClient:checked').length>0)
            BillingContactForAnyClient = true;
        else
            BillingContactForAnyClient = false;

        if ($('#chkAuditOnly:checked').length > 0)
            AuditClientsOnly = true;
        else
            AuditClientsOnly = false;

        $("#list2").jqGrid('appendPostData', { ClientID: $('#selClient').val(), BillingContactID: $('#selBillingContact').val(),
            StartDate: $('#txtStartDate').val(), EndDate: $('#txtEndDate').val(), BillingContactForAnyClient: BillingContactForAnyClient,
            InvoiceNumber: $('#txtInvoiceNumber').val(), DeliveryMethod: DeliveryMethod, ReleaseStatus: ReleaseStatus,AuditClientsOnly: AuditClientsOnly
          
        });
        $("#list2").jqGrid('setGridParam', { page: 1 });
        $("#list2").trigger("reloadGrid");

    }
</script>

<% if (User.IsInRole("Admin_CanVoidInvoices"))
   { %>
   
<script type="text/javascript">
    $(function() {
        $("#t_list2").append("<a id='lnkVoidInvoices' href='javascript:void(0)' style='vertical-align:middle;line-height:18px;text-decoration:underline;color:#0000ff;margin-left:10px;'>Void Selected Invoices</a> &nbsp; ");

        $('#lnkVoidInvoices').click(function() {
            if (confirm('Are you sure you want to void the selected invoices?')) {
                var IDs = $('#list2').getGridParam('selarrrow').join(",");
                //alert(IDs);
                
                $.post('../../Invoices/VoidInvoicesJSON', { InvoiceIDs: IDs }, function(data) {
                    if (data.success) {
                        $('#list2').trigger("reloadGrid");
                        alert('The selected invoices have been voided!');
                    }
                    else {
                        alert('Error: Invoices were not voided!');
                    }
                }, 'json');
            }
        });

        

        
    });
</script>
   
<% } %>

<% if (User.IsInRole("Admin_CanReleaseInvoices"))
   { %>
   
<script type="text/javascript">
$(function() {
    $("#t_list2").append("<a id='lnkReleaseInvoices' href='javascript:void(0)' style='vertical-align:middle;line-height:18px;text-decoration:underline;color:#0000ff;margin-left:10px;'>Release Selected Invoices</a> &nbsp; ");

    $('#lnkReleaseInvoices').click(function() {
        if (confirm('Are you sure you want to release the selected invoices?  This will make them visible to the client.')) {
            var IDs = $('#list2').getGridParam('selarrrow').join(",");
            //alert(IDs);

            $.post('../../Invoices/ReleaseInvoicesJSON', { InvoiceIDs: IDs }, function(data) {
                if (data.success) {
                    $('#list2').trigger("reloadGrid");
                    alert('The selected invoices have been released!');
                }
                else {
                    alert('Error: Invoices were not released!');
                }
            }, 'json');
        }
    });
});
</script>

<% } %>


<script type="text/javascript">
    $(function() {
    $("#t_list2").append("<a id='lnkCreateNewCredit' href='javascript:void(0)' style='vertical-align:middle;line-height:18px;text-decoration:underline;color:#0000ff;margin-left:10px;'>Create New Credit</a> &nbsp; ");
    
        $('#lnkCreateNewCredit').click(function() {
            openCreateNewCredit();
        });
    });
</script>
    
    
</div>

<div id='relatedinvoicesdlg' title='Related Invoices'><div id='relatedinvoicesdlgcontent'></div></div>
<div id='createnewcreditdlg' title='Credit'><div id='createnewcreditdlgcontent'></div></div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
