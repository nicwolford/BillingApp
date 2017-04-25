<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.BillingStatement_AccountActivity>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Billing
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
    <div style='float:left;'>
    <h2 style='margin-bottom:5px;'>Billing</h2>
    </div>
    
    <% 
        decimal TotalStatementAmount = 0;
        decimal TotalAmount = 0;
    %>
    
    <% if (Model.BillingContacts.Count > 2)
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
            <fieldset style='margin: 0; background-color:White; padding:0;'>
                <div class='fieldset-header'>
                    <h3 style='text-align:left;' id='CurrentStatementHeader'>Amount Due</h3>
                </div>
                
                <div style='padding:10px;'>
<% if (Model.BillingContactID == 0 && Model.IsPrimaryContact)
   { %>
        <table border='0' cellpadding='4' cellspacing='0' width='100%' style='margin-bottom:0px;'>
            <thead style='font-weight:bold;'>
            <tr>
                <th style='width:80px; text-align:left; border:solid 1px black;'>Date</th>
                <th style='text-align:left;  text-align:left; border-top:solid 1px black; border-right:solid 1px black; border-bottom:solid 1px black;'>Description</th>
                <th style='text-align:right; border-top:solid 1px black; border-right:solid 1px black; border-bottom:solid 1px black;'>Amount</th>
                <th style='text-align:right; border-top:solid 1px black; border-right:solid 1px black; border-bottom:solid 1px black;'>Balance</th>    
            </tr>
            </thead>
            <tbody>
            
            <% foreach (var statementItem in Model.BillingSatementList)
               { 
                TotalStatementAmount += Decimal.Parse(statementItem.billingContact.ClientContactAddress1);
                   %>
               <tr>
               <td style='border-left:solid 1px black; border-right:solid 1px black;'>
                    <%= Html.Encode(statementItem.billingContact.DueText)%>
               </td>
               <td style='border-right:solid 1px black;'>
                <a href="../../BillingStatement/Home/<%= statementItem.billingContact.BillingContactID %>">
                    <% if (statementItem.billingContact.BillingContactName == statementItem.billingContact.ClientContactName)
                       { %>
                        <%= Html.Encode(statementItem.billingContact.BillingContactName)%>
                    <% }
                       else
                       { %>
                        <%= Html.Encode(statementItem.billingContact.BillingContactName) + "<br/>" + Html.Encode(statementItem.billingContact.ClientContactName)%>
                    <% } %>
                </a>
               </td>
               <td style='text-align:right; border-right:solid 1px black;'><%= Html.Encode(statementItem.billingContact.ClientContactAddress1)%></td>
               <td style='text-align:right; border-right:solid 1px black;'><%= Html.Encode(TotalStatementAmount.ToString("F"))%></td>
               </tr>
               
            
            <% } %>            
            </tbody>
        </table>
<% }
   else
   { %>
                <table style='margin-bottom:8px; width:100%; border:0;'>
                <tr>
                <td style='width:50%;'>
                    <% if (Model.BillingContacts.Count > 2 && Model.IsPrimaryContact)
                       { %>
                            <a href="../../BillingStatement/Home/0">All Accounts</a>
                    <% } %>                        
                </td>
                <td style='width:50%; text-align:right; margin-right:8px;'>
                    <a href='../../BillingStatement/Index/<%= Model.BillingContactID %>'>Print</a>
                </td>
                </tr>
                </table>
                
                <p>
                <%= Html.Encode(Model.BillingStatement.billingContact.BillAsClientName)%><br />
                <% if (String.IsNullOrEmpty(Html.Encode(Model.BillingStatement.billingContact.BillingContactName)))
                   { %>
                        Attn: Accounts Payable
                    <% }
                   else
                   { %>
                        <%= Html.Encode(Model.BillingStatement.billingContact.BillingContactName)%>
                    <% } %>
                    <br />
                <%= Html.Encode(Model.BillingStatement.billingContact.ClientContactAddress1)%><br />
                <% if (!String.IsNullOrEmpty(Model.BillingStatement.billingContact.ClientContactAddress2))
                   { %>
                        <%= Html.Encode(Model.BillingStatement.billingContact.ClientContactAddress2)%><br />
                <% } %>
                <%= Html.Encode(Model.BillingStatement.billingContact.ClientContactCity)%>, 
                <%= Html.Encode(Model.BillingStatement.billingContact.ClientContactStateCode)%> 
                <%= Html.Encode(Model.BillingStatement.billingContact.ClientContactZIP)%>
                <br />
                </p>
                
                <table border='0' cellpadding='4' cellspacing='0' width='100%' style='margin-bottom:0px;'>
    <thead style='font-weight:bold;'>
    <tr>
    <th style='width:80px; text-align:left; border:solid 1px black;'>Invoice #</th>
    <th style='width:20px; text-align:left; border-top:solid 1px black; border-right:solid 1px black; border-bottom:solid 1px black;'>&nbsp;</th>
    <th style='width:80px; text-align:left; border-top:solid 1px black; border-right:solid 1px black; border-bottom:solid 1px black;'>Date</th>
    <th style='text-align:left;  text-align:left; border-top:solid 1px black; border-right:solid 1px black; border-bottom:solid 1px black;'>Description</th>
    <th style='text-align:right; border-top:solid 1px black; border-right:solid 1px black; border-bottom:solid 1px black;'>Amount</th>
    <th style='text-align:right; border-top:solid 1px black; border-right:solid 1px black; border-bottom:solid 1px black;'>Balance</th>    
    </tr>
    </thead>
    <% 
    
    foreach (var item in Model.BillingStatement.billingStatementRows)
    {
        TotalStatementAmount += item.Amount; %>
    <tr>    
    
    <% if (item.LinkID != 0)
       { %>
            <td style=' border-right:solid 1px black; border-left:solid 1px black;'>
                <a href='javascript:void(0)' onclick="openInvoice(<%= item.LinkID.ToString() %>)"><%= Html.Encode(item.InvoiceNumber)%></a>
           </td>
           <td style=' border-right:solid 1px black;'>
                <a href='javascript:void(0)' onclick="pdfInvoice(<%= item.LinkID.ToString() %>)">
                    <img src="../../Content/images/pdficon_small.gif" alt="Export to PDF" />
                </a>
            </td>
    <% }
       else
       { %>
            <% if (String.IsNullOrEmpty(item.InvoiceNumber))
               {  %>
                <td style=' border-right:solid 1px black; border-left:solid 1px black;'>&nbsp;</td>
            <% }
               else
               { %>
                <td style=' border-right:solid 1px black; border-left:solid 1px black;'><%= Html.Encode(item.InvoiceNumber)%></td>
            <% } %>
            <td style=' border-right:solid 1px black;'>&nbsp;</td>
    <% } %>
    
    <td style=' border-right:solid 1px black;'><%= (item.Date.HasValue ? Html.Encode(item.Date.Value.ToString("MM/dd/yyyy")) : "&nbsp;")%></td>
    
    <td style=' border-right:solid 1px black;'><%= Html.Encode(item.Type)%></td>
    <td style='text-align:right; border-right:solid 1px black;'><%= Html.Encode(item.Amount.ToString("F"))%></td>
    <td style='text-align:right; border-right:solid 1px black;'><%= Html.Encode(TotalStatementAmount.ToString("F"))%></td>
    </tr>
    
    <% } %>
    </table>
 
 <% } // End if (Model.BillingContactID == 0) %>
    
    <table width='100%' cellpadding='4' cellspacing='0' style='margin-top:0px;'>
    <tr>
    <td style='text-align:center; font-weight:bold; border:solid 1px black;'>
    For your convenience we offer payment by phone<br />with check or credit card completely free of charge.<br />Call 888-327-6511 x206 to pay by phone.  Thank you.
    </td>    
    <td style='text-align:right; font-weight:bold; border:solid 1px black; white-space:nowrap; width:100px;'>
        <span style='font-size:14px;'>Total Due:</span>
        <br />
        <span style='font-size:14px;'><%= Html.Encode((TotalStatementAmount < 0 ? 0 : TotalStatementAmount).ToString("C"))%></span>
    </td>
    </tr>
    <tr>
    <td style='text-align:center; font-weight:bold;'>
    All amounts not paid within 30 days from invoice date shall be assessed a finance charge.
    </td>
    <td>&nbsp;</td>
    </tr>
    <tr>
    <td style='text-align:center;'>
    Vist us online at <%=ConfigurationManager.AppSettings["websiteurl"] %>
    </td>
    <td>&nbsp;</td>
    </tr>
    </table>
    
    <table border='0' cellpadding='5' cellspacing='0' style='width:250px; text-align:center; margin-left:80px; margin-top:20px; font-weight:bold; border:double 3px black;'>
    <tr><td>
    PLEASE REMIT TO<br />
    Screening One, Inc.<br />
    PO BOX 749363<br />
    Los Angeles, CA 90074-9363
    </td></tr>
    </table>


                
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

<% if (Model.BillingContactID != 0)
   { %>

    <tr>   
    <td style='width:960px; vertical-align:top;'>
    <fieldset style='margin: 0; background-color:White; padding:0;'>
        <div class='fieldset-header'>
            <h3 id='CurrentActivityHeader'>Account Activity</h3>
        </div>
        <div style='padding:10px;'>
        
        
        
        <!--<div style='width:50%; text-align:left;'>
            <select style='width:150px;'>
                <option>Last 30 Days</option>
                <option>Last 60 Days</option>
                <option>This Year</option>
                <option>All Activity</option>
            </select>
        </div>-->
        
        <table border='0' style='width:100%; margin-top:10px;'>
    <tr style='font-weight:bold;'>
    <th style='width:110px; text-align:left;'>Invoice #</th>
    <th style='width:70px; text-align:left;'>Date</th>
    <th style='width:20px; text-align:left;'>&nbsp;</th>
    <th style=' text-align:left;'>Description</th>
    <th style='width:100px; text-align:right;'>Amount</th>
    </tr>
    <% 
    
    foreach (var item in Model.AccountActivity.accountActivityRows)
    {
        TotalAmount += item.Amount; %>
    <tr>
    <% if (item.LinkID == 0)
       { %>
            <td><%= Html.Encode(item.InvoiceNumber)%></td>
    <% }
       else
       { %>
            <td><a href='javascript:void(0)' onclick="openInvoice(<%= item.LinkID.ToString() %>)"><%= Html.Encode(item.InvoiceNumber)%></a></td>
    <% } %>
    
    <td><%= (item.Date.HasValue ? Html.Encode(item.Date.Value.ToString("MM/dd/yyyy")) : "&nbsp;") %></td>    
    <td><a href='javascript:void(0)' onclick="$('#CntMsgBillingMessagecontent').load('../../Help/BillingMessage?CntMsgMessageCategory=Account%20Activity&CntMsgMessageSubject=<%= HttpUtility.UrlEncode(item.Type + (item.Date.HasValue ? " - " + item.Date.Value.ToShortDateString() : "")) %>'); $('#CntMsgBillingMessagedlg').dialog('open')"><img src="../../Content/images/question.gif" alt="Click for help with this item..." /></a></td>
    <td><%= Html.Encode(item.Type)%></td>    
    <td style='text-align:right;'><%= Html.Encode(item.Amount.ToString("F"))%></td>
    </tr>
    
    <% } %>
    </table>
        
        </div>
    </fieldset>
    </td>
    
    </tr>
    <% } //End if (Model.BillingContactID != 0) %>
    </table>
    
    </div>
    
</div>

<script type="text/javascript">
    $(function() {
    $('#CurrentStatementHeader').html('<%= Model.StatementDate.ToString("MMMM") %> <%= Model.StatementDate.Year.ToString() %> Statement');

        $('#CurrentActivityHeader').html('Account Activity - Current Balance: <%= TotalAmount.ToString("C") %>');
    });
</script>

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
            <% if (Model.BillingContactID != 0)
            { %>
                height: 70,
            <% } else { %>
                height: 220,
            <% } %>
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
