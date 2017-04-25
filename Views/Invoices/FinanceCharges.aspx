<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Finance Charges
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
    <h2>Finance Charges</h2>
    
    <p>
        Date to Assess Finance Charges: 
        <%= Html.TextBox("txtFinanceChargeDate", DateTime.Now.ToString("MM/dd/yyyy"), new { @style = "width:80px;" })%>
    </p>
    
    <table id='list_NewFinanceCharges'></table>
    <div id='pager_NewFinanceCharges'></div>
    
    
<script type="text/javascript">
    jQuery(document).ready(function() {
        $('#txtFinanceChargeDate').datepicker({ showOn: 'both', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true, changeMonth: true, changeYear: true });
        $('#txtFinanceChargeDate').change(function() {
            $('#list_NewFinanceCharges').jqGrid('setPostData', { FinanceChargeDate: $('#txtFinanceChargeDate').val() });
            $('#list_NewFinanceCharges').trigger('reloadGrid');
        });

        //New Finance Charges Grid
        $('#list_NewFinanceCharges').jqGrid({
            url: '../../Invoices/FinanceChargesToCreateJSON',
            datatype: 'json',
            colModel: [
            { name: 'id', index: 'id', key: true, hidden: true },
            { name: 'Action', index: 'Action', align: 'left', width: 80 },
            { name: 'InvoiceDate', index: 'InvoiceDate', align: 'left', width: 120 },
            { name: 'InvoiceNumber', index: 'InvoiceNumber', align: 'left', width: 130 },
            { name: 'ClientName', index: 'ClientName', align: 'left', width: 200 },
            { name: 'OriginalInvoiceAmount', index: 'OriginalInvoiceAmount', align: 'right', width: 100 },
            { name: 'InvoiceAmountDue', index: 'InvoiceAmountDue', align: 'right', width: 100 },
            { name: 'FinanceChargeAmount', index: 'FinanceChargeAmount', align: 'right', width: 120 }
            ],
            colNames: ['id', 'Action', 'Invoice Date', 'Invoice #', 'Client', 'Original', 'Amount Due', 'Finance Charge'],
            //onSelectRow: function(id) { window.open('../../Invoices/Details/' + id); },
            width: 960,
            height: 200,
            sortable: true,
            mtype: 'POST',
            rowNum: 9999,
            rowList: [],
            pager: '#pager_NewFinanceCharges',
            sortname: 'ClientName',
            viewrecords: true,
            sortorder: 'asc',
            caption: 'New Finance Charges',
            rownumbers: false,
            postData: { FinanceChargeDate: $('#txtFinanceChargeDate').val() },
            gridComplete: function() {
                var ids = jQuery('#list_NewFinanceCharges').jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                    var cl = ids[i];
                    $('#list_NewFinanceCharges').jqGrid('setRowData', cl, { Action: "<a href='javascript:openInvoice(" + cl + ");'>View Invoice</a>" });
                }
            },
            loadui: 'block',
            footerrow: true,
            userDataOnFooter: true,
            multiselect: true,
            loadtext: 'Loading New Finance Charges...',
            emptyrecords: 'No New Finance Charges',
            toolbar: [true, "top"],
            gridview: true
        });

        $("#t_list_NewFinanceCharges").append("<a id='lnkCreateFinanceCharges' href='javascript:void(0)' style='vertical-align:middle;line-height:18px;text-decoration:underline;color:#0000ff;margin-left:10px;'>Create Finance Charges for Selected Invoices</a>");

        jQuery('#list_NewFinanceCharges').jqGrid('navGrid', '#pager_NewFinanceCharges', { edit: false, add: false, del: false, search: false, refresh: false },
            {}, // edit options
            {}, // add options
            {}, //del options
            {}
        );

        $('#lnkCreateFinanceCharges').click(function() {
            if (confirm('Are you sure you want to created finance charges for the selected invoices?')) {
                var IDs = $('#list_NewFinanceCharges').getGridParam('selarrrow').join(",");
                //alert(IDs);

                $.post('../../Invoices/CreateFinanceChargesJSON', { InvoiceIDs: IDs,
                    FinanceChargeDate: $('#txtFinanceChargeDate').val()
                }, function(data) {
                    if (data.success) {
                        alert('Finance Charges have been created!');
                    }
                    else {
                        alert('Error: Finance Charges were not created!');
                    }
                }, 'json');
            }
        });

    });
</script>

</div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
