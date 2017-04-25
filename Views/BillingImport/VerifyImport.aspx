<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.BillingImport_Upload>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	VerifyImport
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">   
    <h2>Import Validation</h2>
    
    <% using (Html.BeginForm()) { %>
    <%= Html.ValidationSummary()%>
    <div><button id="btnreloadpage" type="button">Refresh List</button></div>
    <div  id="tblAuditResults">
    <center>
    <table>
        <tr>
            <td align="right" style="font-weight:bold">
                Total Number of Records Imported:
            </td>
            <td align="right">
                <%= Html.Encode(Model.totalrecords.ToString("N0"))%>
            </td>
        </tr>
        <tr>
            <td align="right" style="font-weight:bold">
               Total Sum of Price:
            </td>
            <td align="right">
                <%= Html.Encode(Model.totalprice.ToString("C")) %>
            </td>
        </tr>
        <tr>
            <td align="right">
            <button id="submitContinueImport" type="submit" class="fg-button ui-state-default ui-priority-primary ui-corner-all">Continue Import</button>
            </td>
            <td align="right"></td>
        </tr>
    </table>
</center>
</div>
 <% } %>

<div id="importerrorgrid">
    <table id='list2'></table>
    <div id='pager2'></div>
    
    <input id="vendorid" type="hidden" value="<%= Model.VendorID %>"/>
<script type='text/javascript'>
    jQuery(document).ready(function () {
        $('#btnreloadpage').click(function () { location.reload(); });
        $('#tblAuditResults').hide();
        $('#submitContinueImport').click(function () { $('#submitContinueImport').hide(); });
        $('#btnreloadpage').hide();
        $('#list2').jqGrid({
            url: '../../BillingImport/VerifyImportJSON',
            datatype: 'json',
            colModel: [
            { name: 'id', index: 'id', key: true, hidden: true },
            { name: 'ErrorCode', index: 'ErrorCode', hidden: true },
            { name: 'LineNumber', index: 'LineNumber', align: 'right', width: 50 },
            { name: 'ErrorMsg', index: 'ErrorMsg', align: 'left', width: 150 },
            { name: 'FileNum', index: 'FileNum', align: 'right', width: 75 },
            { name: 'ErrorDetail', index: 'ErrorDetail', align: 'left', width: 650 }
            ],
            colNames: ['id', 'Error Code', 'Line #', 'Error Message', 'FileNum', 'Error Detail'],
            onSelectRow: function (id, ErrorCode) {
                if ($('#list2').jqGrid('getRowData', id).ErrorCode == '101') {

                    $("#matchtoclientdlgcontent").load('../../Clients/CreateClient');
                    $("#matchtoclientdlg").dialog('open');

                    //alert('See Dave T. or Eric to set up new client before continuing.');
                };

                if ($('#list2').jqGrid('getRowData', id).ErrorCode == '102') {

                    //alert('VendorID=' + $("#vendorid").val() + ' Line Number=' + id);

                    $("#editproductdlgcontent").load('../../Products/TazworksErrorFix/' + id);
                    $("#editproductdlg").dialog('open');
                };

                if ($('#list2').jqGrid('getRowData', id).ErrorCode == '103') {
                    $('#matchtoproductdlgcontent').load('../../BillingImport/MatchDescToProduct/' + id + "?VendorID=" + $('#vendorid').val() + "&errorcode=" + $('#list2').jqGrid('getRowData', id).ErrorCode);
                    $('#matchtoproductdlg').dialog('open');
                };

                if ($('#list2').jqGrid('getRowData', id).ErrorCode == '104') {
                    $('#matchtoproductdlgcontent').load('../../BillingImport/MatchDescToProduct/' + id + "?VendorID=" + $('#vendorid').val() + "&errorcode=" + $('#list2').jqGrid('getRowData', id).ErrorCode);
                    $('#matchtoproductdlg').dialog('open');
                };

            },
            width: 966,
            height: 250,
            sortable: true,
            mtype: 'POST',
            rowNum: -1,
            rowList: [],
            pager: '#pager2',
            sortname: 'id',
            viewrecords: true,
            loadui: 'block',
            loadtext: 'Searching for Errors...',
            sortorder: 'asc',
            caption: 'Errors',
            rownumbers: false,
            postData: { vendorid: '<%= Model.VendorID %>' },
            gridComplete: function () {
                var ids = jQuery('#list2').jqGrid('getDataIDs');
                /*for (var i = 0; i < ids.length; i++) {
                var cl = ids[i];
                }*/
                if (ids.length == 0) {
                    $('#importerrorgrid').hide();
                    $('#tblAuditResults').show();
                }
                else {
                    $('#btnreloadpage').show();
                }
            },
            gridview: true
        });

        jQuery('#list2').jqGrid('navGrid', '#pager2', { edit: false, add: false, del: false, search: false, refresh: false },
        {}, // edit options
        {}, // add options
        {}, //del options
        {}
        );


        $("#matchtoproductdlg").dialog({
            bgiframe: true,
            autoOpen: false,
            height: 350,
            width: 525,
            modal: true,
            //close:
            buttons: {
                Save: function () {
                    $.post('../../BillingImport/MatchDescToProduct/', $('#frmmatchtoproduct').serialize(),

                                                    function (data) {
                                                        if (data.success == false) {
                                                            alert('The Product match failed.  Please try again.');
                                                            $(this).dialog('close');
                                                        } else {
                                                            alert('Product description has been successfully matched to a product.');
                                                            $('#list2').delRowData(data.importid);
                                                            var ids = jQuery('#list2').jqGrid('getDataIDs');
                                                            if (ids.length == 0) {
                                                                $('#btnreloadpage').click();
                                                                // $('#importerrorgrid').hide();
                                                                // $('#tblAuditResults').show();
                                                            }
                                                            $('#matchtoproductdlg').dialog('close');
                                                        }

                                                    }, 'json');
                },
                Cancel: function () {
                    $(this).dialog('close');
                }
            }
        });

        $("#matchtoclientdlg").dialog({
            bgiframe: true,
            autoOpen: false,
            height: 450,
            width: 500,
            modal: true,
            draggable: false,
            resizable: false,
            buttons: {
                Save: function () {
                    $.post('../../Clients/CreateClientJSON', { ClientName: $('#ClientName').val(), Address1: $('#Address1').val(),
                        Address2: $('#Address2').val(), City: $('#City').val(), State: $('#State').val(),
                        Zip: $('#Zip').val(), Tazworks1Client: $('#Tazworks1Client').is(':checked'), Tazworks2Client: $('#Tazworks2Client').is(':checked'),
                        NonTazworksClient: $('#NonTazworksClient').is(':checked')
                    },

                                            function (data) {
                                                if (data.success == false) {

                                                    $('#createclientdlgcontent').empty();
                                                    $('#createclientdlgcontent').append(data.view);

                                                    alert('Create Client Failed. This may be a duplicate client.');

                                                } else {
                                                    alert('New Client created. Please continue setup on next screen.');
                                                    openClient(data.clientid);
                                                    $('#createclientdlg').dialog('close');
                                                }

                                            }, 'json');
                },
                Cancel: function () {
                    $(this).dialog('close');
                }
            }

        });

        function openClient(id) {
            window.open('../../Clients/Details/' + id);
        }
        $("#addproductdlg").dialog({
            bgiframe: true,
            autoOpen: false,
            height: 640,
            width: 500,
            modal: true,
            draggable: false,
            resizable: false,
            buttons: {
                Save: function () {
                    $.post('../../Products/AddProductJSON', { ProductCode: $('#ProductCode').val(), ProductName: $('#ProductName').val(),
                        BaseCost: $('#Base_Cost').val(), BaseCommission: $("#BaseCommission").val(), IncludeOnInvoice: $('#IncludeOnInvoice').val(), Employment: $('#Employment').val(),
                        Tenant: $('#Tenant').val(), Business: $('#Business').val(), Volunteer: $('#Volunteer').val(),
                        Other: $('#Other').val()
                    },

                                            function (data) {
                                                if (data.success == false) {

                                                    $("#product_info_header").html('Product Insert Failed');


                                                } else {
                                                    $("#vendor-list li").each(function (index) {
                                                        if ($(this).find(":first-child").is(':checked')) {
                                                            //console.log('productID: ' + data.productid + ' VendorID: ' + $(this).find(":first-child").attr('id').replace('vendor', ''));

                                                            $.post('../../Products/AddVendorToProduct', { productID: data.productid, vendorID: $(this).find(":first-child").attr('id').replace('vendor', '') },
                                                            function (data) {


                                                            }, 'json');
                                                        }
                                                    });

                                                    alert('New Product created.');
                                                    $('#addproductdlg2').dialog('close');
                                                }

                                            }, 'json');
                },
                Cancel: function () {
                    $(this).dialog('close');
                }
            }
        });

        $("#editproductdlg").dialog({
            bgiframe: true,
            autoOpen: false,
            height: 495,
            width: 500,
            modal: true,
            draggable: false,
            resizable: false,
            buttons: {
                Save: function () {
                    $.post('../../Products/FixImportError', { ImportID: $('#ImportID').val(), ProductName: $('#ProductName').val(),
                        ProductType: $('#ProductType').val(), ItemCode: $("#ItemCode").val(), ProductDesc: $('#ProductDesc').val()
                    },

                                            function (data) {
                                                if (data.success == false) {

                                                    alert('Error Line Update Failed');


                                                } else {
                                                    alert('Error Line Updated');
                                                    $('#editproductdlg').dialog('close');
                                                }

                                            }, 'json');
                },
                Add: function () {
                    $("#addproductdlgcontent").load('../../Products/AddProduct');
                    $("#addproductdlg").dialog('open');
                    $(this).dialog('close');
                },
                Cancel: function () {
                    $(this).dialog('close');
                }
            }
        });

    });


</script>
</div>
<div id="matchtoproductdlg" >
    <form id="frmmatchtoproduct">
    <div id="matchtoproductdlgcontent"></div>
    </form>
</div>

<div id="matchtoclientdlg">
    <form id="frmmatchtoclient">
        <div id="matchtoclientdlgcontent"></div>
    </form>
</div>

<div id="addproductdlg">
    <form id="frmaddproduct">
        <div id="addproductdlgcontent"></div>
    </form>
</div>

<div id="editproductdlg">
    <form id="frmeditproduct">
        <div id="editproductdlgcontent"></div>
    </form>
</div>

</div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
