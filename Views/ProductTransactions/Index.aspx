<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.ProductTransactions_Index>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Index
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
    <h2>Product Transactions</h2>
    
    <div style='margin-bottom:5px; font-weight:bold;'>Transaction Date - Start:
        <span style='margin-left:3px;'><%= Html.TextBox("txtStartDate", Model.StartDate) %></span>
        <span style='margin-left:15px;'>End:</span>
        <span style='margin-left:3px;'><%= Html.TextBox("txtEndDate", Model.EndDate) %></span>
        <span style='margin-left:15px;'>File #</span>
        <span style='margin-left:3px;'><%= Html.TextBox("txtFileNumberSearch", "", new { @style = "width:80px;" })%></span>
        <span style='margin-left:15px;'>
            <input id='btnCreateInvoices' type='button' value='Create Invoices'  />
        </span>
    </div>
    <div style='margin-bottom:5px; font-weight:bold;'>
    Client:
    <span style='margin-left:3px;'><select id='selClient' style='width:300px;'>
        <%--<option value='0'>[All Clients]</option>--%>
        <% foreach (var client in Model.ClientsList)
           { %>
        
            <option value='<%= client.Value %>'><%= Html.Encode(client.Text) %></option>
        
        <% } %>
    </select>
    </span>
    <span id='spanStatusDropdown' style='margin-left:20px;'>
    Status:
    <span style='margin-left:3px;'><select id='selStatus' style='width:300px;'>
        <option value='0'>All Transactions</option>
        <option value='1' selected='selected'>Open Transactions</option>
        <option value='2'>Invoiced Transactions</option>
        <option value='3'>Un-Invoiced Transactions</option>
    </select>
    </span>
    </span>
    </div>
    
    <table id='list2'></table>
    <div id='pager2'></div>

<script type='text/javascript'>
    $(function () {
        $('#txtStartDate').datepicker({ showOn: 'both', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true, changeMonth: true, changeYear: true });
        $('#txtEndDate').datepicker({ showOn: 'both', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true, changeMonth: true, changeYear: true });
        $('#createInvoices_StartDate').datepicker({ showOn: 'both', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true, changeMonth: true, changeYear: true });
        $('#createInvoices_EndDate').datepicker({ showOn: 'both', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true, changeMonth: true, changeYear: true });
        $('#createInvoiceDate').datepicker({ showOn: 'both', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true, changeMonth: true, changeYear: true });

        $('#createInvoices_StartDate').change(function () {
            $('#divBillingGroup').hide();
            $('#divClient').hide();
            $('#divClientLoading').hide();
            $('#radBilling').removeAttr('checked');
            $('#radClient').removeAttr('checked');
        });

        $('#createInvoices_EndDate').change(function () {
            $('#divBillingGroup').hide();
            $('#divClient').hide();
            $('#divClientLoading').hide();
            $('#radBilling').removeAttr('checked');
            $('#radClient').removeAttr('checked');
        });

        $('#selClient').change(function () {
            if ($('#selClient').val() != 0) {
            }
            else {
            }

            reloadGrid();
        });

        $('#selStatus').change(function () {
            var selClientID = $('#selClient').val();
            var url = '../../ProductTransactions/GetAllClientsJSON';

            if ($('#selStatus').val() == '1') {
                $('#lnkCreateManualInvoice').show();
            }
            else {
                $('#lnkCreateManualInvoice').hide();
            }
            if ($('#selStatus').val() == '3') {
                url = '../../ProductTransactions/GetUninvoicedClientsJSON';
            }
            // call controller's action
            $.post(url, { StartDate: '<%= Model.StartDate %>', EndDate: '<%= Model.EndDate %>' }, function (data) {
                $('#selClient').empty();
                //$('#selClient').append($('<option></option>').val('0').html("[All Clients]"));
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

        $('#txtStartDate').change(function () {
            reloadGrid();
        });

        $('#txtEndDate').change(function () {
            reloadGrid();
        });

        $('#txtFileNumberSearch').change(function () {
            reloadGrid();
        });

        /*
        function UpdateBillingContactDropdownItems() {
        //Billing Contact Dropdown
        $.getJSON("../../Invoices/GetBillingContactsForClient/" + $('#selClient').val(), function(data) {
        $('#selBillingContact').empty();
        $('#selBillingContact').append(
        $('<option></option>').val('0').html("[All Billing Contacts]")
        );
        for (i = 0; i < data.rows.length; i++) {
        $('#selBillingContact').append(
        $('<option></option>').val(data.rows[i].Value).html(data.rows[i].Text)
        );
        }
        });
        }
        */
        $('#list2').jqGrid({
            url: '../../ProductTransactions/IndexJSON',
            datatype: 'json',
            colModel: [
            { name: 'id', index: 'id', key: true, hidden: true },
            { name: 'Action', index: 'Action', align: 'left', width: 120 },
            { name: 'TransactionDate', index: 'TransactionDate', align: 'left', width: 100 },
            { name: 'DateOrdered', index: 'DateOrdered', align: 'left', width: 100, hidden: true },
            { name: 'ClientName', index: 'ClientName', align: 'left', width: 180, hidden: true },
            { name: 'ProductType', index: 'ProductType', align: 'left', width: 100 },
            { name: 'ProductName', index: 'ProductName', align: 'left', width: 200, hidden: true },
            { name: 'ProductDescription', index: 'ProductDescription', align: 'left', width: 360 },
            { name: 'FileNum', index: 'FileNum', align: 'right', width: 60 },
            { name: 'Reference', index: 'Reference', align: 'left', width: 120, hidden: true },
            { name: 'OrderedBy', index: 'OrderedBy', align: 'left', width: 200, hidden: true },
            { name: 'ProductPrice', index: 'ProductPrice', align: 'right', width: 100, formatter: customFormatter },
            { name: 'IncludeOnInvoice', index: 'IncludeOnInvoice', align: 'left', width: 20, hidden: true }
            ],
            colNames: ['id', 'Action', 'Transaction Date', 'Date Ordered', 'Client Name', 'Product Type', 'Product Name', 'Product Description',
            'File #', 'Reference', 'Ordered By', 'Product Price', 'Include On Invoice'],
            //onSelectRow: function(id) { document.location.href = '../../ProductTransactions/Details/' + id; },
            width: 966,
            height: 250,
            sortable: true,
            mtype: 'POST',
            rowNum: 10,
            rowList: [10, 100, 1000],
            pager: '#pager2',
            sortname: 'id',
            viewrecords: true,
            sortorder: 'desc',
            caption: 'Invoices',
            rownumbers: false,
            postData: { Status: 1, ClientID: '<%=Model.ClientsList[0].Value %>', StartDate: '<%= Model.StartDate %>', EndDate: '<%= Model.EndDate %>', FileNum: '' },
            gridComplete: function () {
                var ids = $('#list2').jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                    var cl = ids[i];
                    $('#list2').jqGrid('setRowData', cl, { Action: "<a href='javascript:editTransaction(" + cl + ");'>Edit</a>" });
                }
            },
            loadui: 'block',
            multiselect: true,
            loadtext: 'Loading Product Transactions...',
            emptyrecords: 'No Product Transactions',
            toolbar: [true, "top"],
            gridview: true
        });

        function customFormatter(cellvalue, options, rowObject) {
            var gridId = options.gid;
            var rowId = options.rowId;
            var cellIncludeOnInvoice = rowObject[12];

            var color = (cellIncludeOnInvoice == "0" || cellIncludeOnInvoice == "1") ? "000000" : "FF0000";

            var cellHtml = "<span style='color:" + color + "' originalValue='" + cellvalue + "'>" + cellvalue + "</span>";
            return cellHtml;



        }
        jQuery('#list2').jqGrid('navGrid', '#pager2', { edit: false, add: false, del: false, search: false, refresh: false },
{}, // edit options
{}, // add options
{}, //del options
{}
);

        jQuery("#list2").jqGrid('navButtonAdd', '#pager2', {
            caption: "", buttonicon: "ui-icon-print", title: "Excel Export",
            onClickButton: function () {

                $.post('../../ProductTransactions/ExcelJSON', { Status: 1, ClientID: '<%=Model.ClientsList[0].Value %>', StartDate: '<%= Model.StartDate %>', EndDate: '<%= Model.EndDate %>', FileNum: '' }, function (data) {
                    console.log(data);
                });
                //                $.ajax({
                //                    type: "POST",
                //                    url: "../../ProductTransactions/ExcelJSON",
                //                    data: "{ 'Status': 1, 'ClientID': '<%=Model.ClientsList[0].Value %>', 'StartDate': '<%= Model.StartDate %>', 'EndDate': '<%= Model.EndDate %>', 'FileNum': '' }",
                //                    contentType: "application/json; charset=utf-8",
                //                    dataType: "json",
                //                    success: function (data, status) {

                //                        console.log(data);

                //                    }
                //                });
            }
        });

        $("#t_list2").append("<a id='lnkCreateProductTransaction' href='javascript:void(0)' style='vertical-align:middle;line-height:18px;text-decoration:underline;color:#0000ff;margin-left:10px;'>Add New Product Transaction</a>");
        $("a", "#t_list2").click(function () {
            //alert("Create Product Transaction");
            addTransaction();
        });

        //setTimeout(function() { InitialGridReload }, 1);

        $('#list2').jqGrid('navButtonAdd', '#pager2', {
            caption: 'Columns',
            title: 'Select Columns',
            onClickButton: function () { $('#list2').jqGrid('columnChooser'); }
        });

        $("#editdlg").dialog({
            bgiframe: true,
            autoOpen: false,
            height: 380,
            width: 600,
            modal: true,
            draggable: false,
            resizable: false,
            buttons: {
                Save: function () {
                    //alert('Saving...');
                    //alert($('#BasePrice').val());
                    //alert($('#ImportsAtBaseOrSales').val());
                    /*int saveClientID;
                    if ($('#ClientID').val() == null) {
                    saveClientID = 
                    } else {
                    saveClientID = $('#ClientID').val();
                    }

                    int saveVendorID;
                    if ($('#VendorID').val() == null) {

                    }
                
                    int saveProductID;
                    if ($('#ProductID').val() == null) {
                    
                    }*/

                    $.post('../../ProductTransactions/UpdateProductTransaction', {
                        _ProductTransactionID: $('#ProductTransactionID').val(),
                        _ClientID: $('#ClientID').val(), _TransactionDate: $('#TransactionDate').val(),
                        _DateOrdered: $('#DateOrdered').val(),
                        _ProductID: $('#ProductID').val(), _ProductType: $('#ProductType').val(),
                        _ProductDescription: $('#ProductDescription').val(), _ProductPrice: $('#ProductPrice').val(),
                        _FName: $('#FName').val(), _MName: $('#MName').val(), _LName: $('#LName').val(),
                        _Reference: $('#Reference').val(), _OrderedBy: $('#OrderedBy').val(),
                        _FileNum: $('#FileNum').val(), _VendorID: $('#VendorID').val(), _SSN: $('#SSN').val(),
                        _BasePrice: $('#BasePrice').val(), _ImportsAtBaseOrSales: $('#ImportsAtBaseOrSales').val()
                    },
                    function (data) {
                        if (data.success) {
                            $("#editdlg").dialog('close');
                            reloadGrid();
                        }
                    }, 'json');
                },
                'Remove Product Transaction': function () {
                    if (confirm('Are you sure you want to remove this Product Transaction? (This operation cannot be undone)')) {
                        $.post('../../ProductTransactions/RemoveProductTransaction', {
                            _ProductTransactionID: $('#ProductTransactionID').val()
                        }, function (data) {
                            if (data.success) {
                                $("#editdlg").dialog('close');
                                reloadGrid();
                            }
                        }, 'json');
                    }
                    else {
                        alert('The Product Transaction has NOT been removed!');
                    }
                },
                Cancel: function () {
                    $(this).dialog('close');
                }
            }
        });


        $("#adddlg").dialog({
            bgiframe: true,
            autoOpen: false,
            height: 380,
            width: 600,
            modal: true,
            draggable: false,
            resizable: false,
            buttons: {
                Save: function () {

                    //alert($('#BasePrice').val());
                    //alert($('#Product').val());

                    if ($('#addProduct').val() == null || $('#addProduct').val() == 0) {
                        alert('Please select a valid product!');
                        return false;
                    }

                    /*
                    alert('Saving... ' + $('#Client').val() + ' | ' + $('#TransactionDate').val() + ' | ' + $('#DateOrdered').val() + ' | '
                    + $('#Product').val() + ' | ' + $('#ProductType').val() + ' | ' + $('#ProductDescription').val() + ' | ' +
                    $('#ProductPrice').val() + ' | ' + $('#Vendor').val());
                    */

                    $.post('../../ProductTransactions/CreateProductTransaction', {
                        _ClientID: $('#addClient').val(), _TransactionDate: $('#addTransactionDate').val(),
                        _DateOrdered: $('#addDateOrdered').val(),
                        _ProductID: $('#addProduct').val(), _ProductType: $('#addProductType').val(),
                        _ProductDescription: $('#addProductDescription').val(), _ProductPrice: $('#addProductPrice').val(),
                        _FName: $('#addFName').val(), _MName: $('#addMName').val(), _LName: $('#addLName').val(),
                        _Reference: $('#addReference').val(), _OrderedBy: $('#addOrderedBy').val(),
                        _FileNum: $('#addFileNum').val(), _VendorID: $('#addVendor').val(), _SSN: $('#addSSN').val(),
                        _BasePrice: $('#addBasePrice').val()
                    },
                    function (data) {
                        if (data.success) {
                            $("#adddlg").dialog('close');
                            reloadGrid();
                        }
                    }, 'json');

                },
                Cancel: function () {
                    $(this).dialog('close');
                }
            }
        });


        $('#btnCreateInvoices').click(function () {
            $('#createinvoicesdlg').dialog('open');
        });

        $("#processsteploadingdlg").dialog({
            bgiframe: true,
            autoOpen: false,
            height: 100,
            width: 300,
            modal: true,
            draggable: false,
            resizable: false
        });

        $("#processsteploadingdlg").dialog({ dialogClass: "ats-loading-popup" });

        $("#createinvoicesdlg").dialog({
            bgiframe: true,
            autoOpen: false,
            height: 300,
            width: 525,
            modal: true,
            draggable: false,
            resizable: false,
            buttons: {
                'Verify Invoice Setup': VerifyInvoices,
                'Create Invoices': function () {
                    $('#processsteploadingdlg').dialog('open');

                    var forclient = $('#ForClient').val();

                    //alert($('#BillingGroup').val());
                    if (forclient == null) {
                        forclient = 0;
                    }
                   // alert($('#ForClient').val());

                    $.post('../../Invoices/CreateInvoicesJSON', { StartDate: $('#createInvoices_StartDate').val(),
                        EndDate: $('#createInvoices_EndDate').val(), InvoiceDate: $('#createInvoiceDate').val(),
                        BillingGroup: $('#BillingGroup').val(), ClientID: forclient, RunInvoicesForBilling: $('#radBilling').attr('checked')
                    }, function (data) {
                        if (data.success) {
                            $('#processsteploadingdlg').dialog('close');
                            $("#createinvoicesdlg").dialog('close');
                            document.URL = "../../Invoices/Index";
                        }
                    }, 'json');
                },
                'Cancel': function () { $("#createinvoicesdlg").dialog('close'); }
            }
        });

        var firstOfTheMonthDateZ = new Date();
        firstOfTheMonthDateZ = new Date(firstOfTheMonthDateZ.getFullYear(), firstOfTheMonthDateZ.getMonth(), 1);
        var lastMonthDateZ = new Date(firstOfTheMonthDateZ.getFullYear(), firstOfTheMonthDateZ.getMonth(), firstOfTheMonthDateZ.getDate());
        lastMonthDateZ = new Date(lastMonthDateZ.setDate(lastMonthDateZ.getDate() - 1));

        var invoiceDateZ = new Date(lastMonthDateZ.getFullYear(), lastMonthDateZ.getMonth(), lastMonthDateZ.getDate());

        var startDateZ = new Date(lastMonthDateZ.getFullYear(), lastMonthDateZ.getMonth(), 1);
        var endDateZ = new Date(lastMonthDateZ.getFullYear(), lastMonthDateZ.getMonth(), lastMonthDateZ.getDate());

        $('#createInvoices_StartDate').datepicker("setDate", String((startDateZ.getMonth() + 1) + "/" + startDateZ.getDate() + "/" + startDateZ.getFullYear()));
        $('#createInvoices_EndDate').datepicker("setDate", String((endDateZ.getMonth() + 1) + "/" + endDateZ.getDate() + "/" + endDateZ.getFullYear()));
        $('#createInvoiceDate').datepicker("setDate", String((invoiceDateZ.getMonth() + 1) + "/" + invoiceDateZ.getDate() + "/" + invoiceDateZ.getFullYear()));

    });

    function CreateInvoices() {

    }

    function VerifyInvoices(){
        if ($('#radBilling').attr('checked') == true) {
            window.open('../../Invoices/VerifyInvoiceSetup?StartTransactionDate=' + escape($('#createInvoices_StartDate').val())
            + '&EndTransactionDate=' + escape($('#createInvoices_EndDate').val())
            + '&InvoiceDate=' + escape($('#createInvoices_EndDate').val())
            + '&BillingGroup=' + $('#BillingGroup').val());
        }
        else {
            window.open('../../Invoices/VerifyInvoiceSetupForClient?StartTransactionDate=' + escape($('#createInvoices_StartDate').val())
            + '&EndTransactionDate=' + escape($('#createInvoices_EndDate').val())
            + '&InvoiceDate=' + escape($('#createInvoices_EndDate').val())
            + '&ClientID=' + $('#ForClient').val());
           
        }
    }
    function SetRunInvoicesFor() {
        
        if ($('#radBilling').attr('checked') == true) {
            $('#divBillingGroup').show();
            $('#divClient').hide();
            $('#divClientLoading').hide();
        }
        else {
            $('#divBillingGroup').hide();
            $('#divClient').hide();
            $('#divClientLoading').show();
             // call controller's action
             var url = '../../Clients/GetClientsBySplitModeForDropdownJSON';
             $.post(url, { SplitMode: 1, StartDate: $('#createInvoices_StartDate').val(),
                 EndDate: $('#createInvoices_EndDate').val()
             }, function (data) {
                 $('#ForClient').empty();

                 $.each(data.rows, function () {
                     $('#ForClient').append(
                    $('<option></option>').val(this.Value).html(this.Text))
                 });
                 $('#divClientLoading').hide();
                 $('#divClient').show();
             }, 'json');
            //$('#divClient').show();
        }
    }
    function editTransaction(id) {
        $('#editdlgcontent').load('../../ProductTransactions/Edit/' + id);
        $('#editdlg').dialog('open');
    }

    function addTransaction() {
        $('#adddlgcontent').load('../../ProductTransactions/Add/');
        $("#adddlg").dialog('open');
    }

    function reloadGrid() {
        $("#list2").jqGrid('appendPostData', { 
            ClientID: $('#selClient').val(),
            Status: $('#selStatus').val(), 
            StartDate: $('#txtStartDate').val(),
            EndDate: $('#txtEndDate').val(),
            FileNum: $('#txtFileNumberSearch').val()
            });
            $("#list2").jqGrid('setGridParam', { page: 1 }).trigger("reloadGrid");
    }

</script>

    <div id='editdlg' title='Edit Product Transaction' style='display:none;'>
    <div id='editdlgcontent'></div>
    </div>
    
    <div id='adddlg' title='Add New Product Transaction' style='display:none;'>
    <div id='adddlgcontent'></div>
    </div>

    <div id='createinvoicesdlg' title='Create Invoices' style='display:none;'>
        <div style='padding:20px 2px 20px 2px;'>
        <span>Transaction Date - Start:</span>
        <input id='createInvoices_StartDate' type='text' style='width:100px;'/>
        <span>End:</span>
        <input id='createInvoices_EndDate' type='text' style='width:100px;'/>
            <div style='margin-top:18px;'>
            <span>Invoice Date:</span>
            <input id='createInvoiceDate' type='text' style='width:100px;'/>
            </div>
            <div style='margin-top:18px;'>
                <span>Run Invoices for:</span>
                <%= Html.RadioButton("radRunIvoicesFor","Billing",new {id="radBilling", @onclick = "SetRunInvoicesFor(this)"}) %>Billing Group
                <%= Html.RadioButton("radRunIvoicesFor", "Client", new { id = "radClient", @onclick = "SetRunInvoicesFor(this)" })%>Client
            </div>
            <div style='margin-top:18px;display:none;' id='divBillingGroup'>
            <span>Billing Group:</span>
            <%= Html.DropDownList("BillingGroup", Model.BillingGroups, new { @style = "width:300px;'" } )%>
            </div>
            <div style='margin-top:18px;display:none;' id='divClientLoading'>
                <span>Client:</span>
                ...Loading
            </div>

            <div style='margin-top:18px;display:none;' id='divClient'>
                <span>Client:</span>
                <select id='ForClient' name='ForClient' style='width:300px;'></select>
            </div>
        </div>
    </div>
    
    <div id='processsteploadingdlg' style='margin:0; padding:0; display:none;'>
         <p style='padding:0; margin-top:32px; margin-left:86px;'>
         <span style='font-size:16px; font-weight:bold; margin:0px; padding:0;'>Loading</span><br />
         <img src="../../Content/images/load.gif" border="0" alt="..." style='margin:2px 0px 0px 0px; padding:0;'/>
         </p>
     </div>

</div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
