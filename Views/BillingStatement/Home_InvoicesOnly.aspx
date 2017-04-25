<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.BillingStatement_AccountActivity>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Home
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
    <div style='float:left;'>
    <h2 style='margin-bottom:5px;'>Welcome to <%=ConfigurationManager.AppSettings["CompanyName"] %>'s Online Billing</h2>
    </div>
    
    <% decimal TotalStatementAmount = 0; %>
    
    <% if (Model.BillingContacts.Count > 1)
       { %>
    <div id='divSelectBillingContact' style='float:right; margin-right:5px;'>
        <table style='margin-top:2px;'>
            <tr>
                <td style='font-size:14px; font-weight:bold;'><span>Accounts:</span></td>
                <td>
                    <%= Html.DropDownList("SelectBillingContact", Model.BillingContacts, new { @style = "width:600px;" })%>
                </td>
            </tr>
        </table>
        <script type="text/javascript">
            $(function() {
                $('#SelectBillingContact').val('<%= Model.BillingContactID %>');

                $('#SelectBillingContact').change(function() {
                    location.href = '../../BillingStatement/Home/' + $('#SelectBillingContact').val();
                });
            });
        </script>
    </div>
    <% } %>
    
    <div style='clear:both; line-height:0.1;'>&nbsp;</div>
        
    <div style='float:left; width:50%;'>
    
    <table>
    <tr>
        <td style='width:960px; vertical-align:top;'>
            <fieldset style='margin: 0; background-color:White; padding:0; height:320px'>
                
                <div style='padding:10px;'>
                <p>&nbsp;</p>
                <p>Paperless invoices are a great way to save time, help our environment and reduce the risk of mail fraud.</p>
                
                <p>At the beginning of each month your invoices will appear in the box to the right. You will also be notified via email when a new invoice has been posted to your account.</p>
                <p>To view an invoice, please click on the invoice number.</p>

                <p>Thank you for partnering with <%=ConfigurationManager.AppSettings["CompanyName"] %>.  We are committed to providing you with the best screening solutions in the industry.  Please feel free to contact our Billing Department if you have any questions or concerns.</p>


                <p>Sincerely,<br />
                   <%=ConfigurationManager.AppSettings["CompanyName"] %> Billing Department<br />
                   <%=ConfigurationManager.AppSettings["billingphone"] %> <br />
                   <a href='javascript:void(0)' onclick="$('#CntMsgBillingMessagecontent').load('../../Help/BillingMessage?CntMsgMessageCategory=Account%20Activity&CntMsgMessageSubject=Billing%20Question'); $('#CntMsgBillingMessagedlg').dialog('open')"><%=ConfigurationManager.AppSettings["billingemail"] %></a><br />
                </p>
                
                </div>
             </fieldset>
         </td>
     </tr>
     </table>
    
    </div>
    
    <div style='float:right; width:50%'>
    
    <table>
    <tr>
    
    <td style='width:960px; vertical-align:top;'>
    <fieldset style='margin: 0; background-color:White; padding:0;'>
        <div class='fieldset-header'>
            <h3>Invoices</h3>
        </div>
        <div style='padding:10px;'>
            <table id='list_Invoices'></table>
            <div id='pager_Invoices'></div>
        </div>
    </fieldset>
    </td>
    
    </tr>
    
    </table>
    
    </div>
    
</div>


<script type="text/javascript">
    function openInvoice(id) {
        window.open('../../Invoices/ClientRenderInvoice/' + id);
    }

    function pdfInvoice(id) {
        location.href('../../Invoices/PrintInvoiceToPDF/' + id);
    }

    $(function() {
        //Invoices Grid
        $('#list_Invoices').jqGrid({
            url: '../../Invoices/InvoicesByBillingContactJSON',
            datatype: 'json',
            colModel: [
            { name: 'id', index: 'id', key: true, hidden: true },
            { name: 'Action', index: 'Action', align: 'left', width: 80, hidden: true },
            { name: 'InvoiceDate', index: 'InvoiceDate', align: 'left', width: 120 },
            { name: 'InvoiceNumber', index: 'InvoiceNumber', align: 'left', width: 130 },
            { name: 'InvoiceTypeDesc', index: 'InvoiceTypeDesc', align: 'left', width: 110, hidden: true },
            { name: 'ClientName', index: 'ClientName', align: 'left', width: 200, hidden: true },
            { name: 'BillingContactName', index: 'BillingContactName', align: 'left', width: 200, hidden: true },
            { name: 'OriginalAmount', index: 'OriginalAmount', align: 'right', width: 120 },
            { name: 'InvoiceAmount', index: 'InvoiceAmount', align: 'right', width: 120 }
            ],
            colNames: ['id', 'Action', 'Invoice Date', 'Invoice #', 'Type', 'Client', 'Billing Contact',
            'Original', 'Amount Due'],
            onSelectRow: function(id) { window.open('../../Invoices/ClientRenderInvoice/' + id); },
            width: 453,
            height: 200,
            sortable: true,
            mtype: 'POST',
            rowNum: 10,
            rowList: [10, 50, 100],
            pager: '#pager_Invoices',
            sortname: 'InvoiceDate',
            viewrecords: true,
            sortorder: 'desc',
            caption: 'Invoices',
            rownumbers: false,
            postData: { BillingContactID: '<%= Model.BillingContactID %>' },
            /*gridComplete: function() {
            var ids = jQuery('#list_Invoices').jqGrid('getDataIDs');
            for (var i = 0; i < ids.length; i++) {
            var cl = ids[i];
            $('#list_Invoices').jqGrid('setRowData', cl, { Action: "<a href='javascript:openInvoice(" + cl + ");'>View Invoice</a>" });
            }
            },*/
            loadui: 'block',
            footerrow: false,
            userDataOnFooter: false,
            //multiselect: true,
            loadtext: 'Loading Invoice...',
            emptyrecords: 'No Invoices',
            gridview: true
        });

        jQuery('#list_Invoices').jqGrid('navGrid', '#pager_Invoices', { edit: false, add: false, del: false, search: false, refresh: false },
            {}, // edit options
            {}, // add options
            {}, //del options
            {}
        );
    });
</script>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
