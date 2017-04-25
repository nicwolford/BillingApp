<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.BillingStatement_PrintPackages>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Print Packages
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
    <h2>Print Packages</h2>
    
    <div style='margin-bottom:8px;'>
    <select id='selectPrintedFilter'>
        <option value='0'>Show All</option>
        <option value='1' selected="selected">Email to be sent Automatically</option>
        <option value='2'>Email to be sent Manually</option>
        <option value='3'>Mail only to be printed</option>
    </select>
    
    <span style='margin-left:20px'>Billing Group: </span>
    <%= Html.DropDownList("BillingGroup", Model.BillingGroups, new { @style = "width:300px;'" } )%>  
    </div>
    
    <table id='list2'></table>
    <div id='pager2'></div>
    
    
</div>

<script type="text/javascript">

    $(function() {

        $('#selectPrintedFilter').change(function() {

            if ($('#selectPrintedFilter').val() == '2' || $('#selectPrintedFilter').val() == '3') {
                $('#lnkAutoEmail').hide();
                $('#lnkMarkAsPrinted').show();
            }

            if ($('#selectPrintedFilter').val() == '0') {
                $('#lnkAutoEmail').hide();
                $('#lnkMarkAsPrinted').hide();
            }

            if ($('#selectPrintedFilter').val() == '1') {
                $('#lnkAutoEmail').show();
                $('#lnkMarkAsPrinted').hide();
            }

            reloadGrid();
        });

        $('#BillingGroup').change(function() {
            reloadGrid();
        });

        $('#list2').jqGrid({
            url: '../../BillingStatement/GetStatementsListJSON',
            datatype: 'json',
            colModel: [
            { name: 'id', index: 'id', key: true, hidden: true },
            { name: 'Action', index: 'Action', align: 'left', width: 150 },
            { name: 'ClientName', index: 'ClientName', align: 'left', width: 280 },
            { name: 'BillingContactName', index: 'BillingContactName', align: 'left', width: 220 },
            { name: 'DeliveryMethod', index: 'DeliveryMethod', align: 'left', width: 80 },
            { name: 'LastPrinted', index: 'LastPrinted', align: 'left', width: 100 },
            { name: 'CurrentActivity', index: 'CurrentActivity', align: 'left', width: 80 },
            { name: 'Amount', index: 'Amount', align: 'right', width: 120 },
            { name: 'ContactEmail', index: 'ContactEmail', hidden: true }

            ],
            colNames: ['id', 'Action', 'Client', 'Billing Contact', 'Delivery', 'Last Printed', 'Activity', 'Amount', 'Email'],
            //onSelectRow: function(id) { window.open('../../Invoices/Details/' + id); },
            width: 966,
            height: 250,
            sortable: true,
            mtype: 'POST',
            rowNum: 50,
            rowList: [50, 100, 500],
            pager: '#pager2',
            sortname: 'id',
            viewrecords: true,
            sortorder: 'asc',
            caption: 'Billing Statements',
            rownumbers: false,
            postData: { ExcludePrinted: '1', ExcludeZero: '1', BillingGroup: $('#BillingGroup').val() },
            gridComplete: function() {
                var ids = jQuery('#list2').jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                    var cl = ids[i];
                    var rowValues = jQuery("#list2").jqGrid('getRowData', cl);

                    if (rowValues.DeliveryMethod == 'Email') {
                        $('#list2').jqGrid('setRowData', cl, {
                            Action: "<a href='javascript:void(0);' onclick='javascript:pdfInvoice(" + cl + ");'><img src='../../Content/images/pdficon_small.gif' alt='Print PDF'/></a>&nbsp; <a style='display:none' href='mailto:"
                            + rowValues.ContactEmail + "?body=Dear Customer:%0A%0AYour invoice is attached.  Please remit payment at your earliest convenience. To make a phone payment by check or credit card free of charge please contact Accounts Receivable at <%=ConfigurationManager.AppSettings["billingphone"] %> or <%=ConfigurationManager.AppSettings["billingemail"] %>%0A%0AThank you for your business.%0A%0ASincerely,%0A%0A<%=ConfigurationManager.AppSettings["CompanyName"] %>&subject=Invoice from <%=ConfigurationManager.AppSettings["CompanyName"] %>'>Create Email</a>"
                            + " <a href='javascript:void(0);' onclick='javascript:makeAnEmailFile(" + cl + ");'>Create Email</a>"
                        });
                    }
                    else {
                        $('#list2').jqGrid('setRowData', cl, {
                            Action: "<a href='javascript:void(0);' onclick='javascript:pdfInvoice(" + cl + ");'><img src='../../Content/images/pdficon_small.gif' alt='Print PDF'/></a>"
                        });
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


        $("#t_list2").append("<a id='lnkMarkAsPrinted' href='javascript:void(0)' style='vertical-align:middle;line-height:18px;text-decoration:underline;color:#0000ff;margin-left:10px;'>Mark Selected Packages as Printed</a>");
        $("#t_list2").append("<a id='lnkAutoEmail' href='javascript:void(0)' style='vertical-align:middle;line-height:18px;text-decoration:underline;color:#0000ff;margin-left:10px;'>Automatically Email the Selected Packages</a>");
        $("#t_list2").append("<a id='lnkZipInvoices' href='javascript:void(0)' style='vertical-align:middle;line-height:18px;text-decoration:underline;color:#0000ff;margin-left:10px;'>Zip Selected</a>");

        $('#lnkMarkAsPrinted').hide();

        $('#lnkMarkAsPrinted').click(function() {
            if (confirm('Are you sure you want to mark the selected packages as printed?')) {
                var IDs = $('#list2').getGridParam('selarrrow').join(",");
                //alert(IDs);

                $.post('../../BillingStatement/MarkAsPrintedJSON', { BillingContactIDs: IDs }, function(data) {
                    $('#list2').trigger("reloadGrid");
                    if (data.success) {
                        alert('The selected packages have been marked as printed!');
                    }
                    else {
                        alert('Error: Packages were not marked as printed!');
                    }
                }, 'json');
            }
        });

        $('#lnkZipInvoices').click(function (e) {
            if (e.target == this) {
                if (confirm('Are you sure you want to zip and download selected packages?')) {
                    var IDs = String($('#list2').getGridParam('selarrrow').join(","));
                    $.download('../../BillingStatement/ZipInvoices', String("BillingContactIDs=") + String(IDs) , "post");
                }
            }
        });
      
        $('#lnkAutoEmail').click(function() {
            if (confirm('Are you sure you want to automatically email the selected packages?')) {
                var IDs = $('#list2').getGridParam('selarrrow').join(",");
                //alert(IDs);

                $.post('../../BillingStatement/AutomaticallyEmailJSON', { BillingContactIDs: IDs }, function(data) {
                    $('#list2').trigger("reloadGrid");
                    if (data.success) {
                        alert('The selected packages have been automatically emailed!');
                    }
                    else {
                        alert('Error: Packages were not emailed!');
                    }
                }, 'json');
            }
        });

        if (jQuery.download == null) {

            jQuery.download = function (url, data, method) {
                //url and data options required
                if (url && data) {
                    //data can be string of parameters or array/object
                    data = typeof data == 'string' ? data : jQuery.param(data);
                    //split params into form inputs
                    var inputs = '';
                    jQuery.each(data.split('&'), function () {
                        var pair = this.split('=');
                        inputs += '<input type="hidden" name="' + pair[0] + '" value="' + pair[1] + '" />';
                    });
                    //send request
                    jQuery('<form action="' + url + '" method="' + (method || 'post') + '">' + inputs + '</form>')
                    .appendTo('body').submit().remove();
                };
            };
        }
    });

    function reloadGrid() {
        $("#list2").jqGrid('appendPostData', { ExcludePrinted: $('#selectPrintedFilter').val(), ExcludeZero: '1', 
            BillingGroup: $('#BillingGroup').val()
        });
        $("#list2").jqGrid('setGridParam', { page: 1 }).trigger("reloadGrid");
    }

    function pdfInvoice(id) { //id = BillingContactID
        location.href = '../../BillingStatement/PrintPackageToPDF/' + String(id);
    }

    function makeAnEmailFile(id) { //id = BillingContactID
        $.download('../../BillingStatement/MakeAnEmlFile', String("BillingContactID=") + String(id), "post");
    }

</script>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
