<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.Invoices_InvoiceAndPaymentBalancer>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Invoice and Payment Balancer
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
    <h2>Invoice and Payment Balancer</h2>
</div>
    
<div>
    <%:"Client:" %>&nbsp;<%=Html.DropDownList("ddlClients", Model.ClientsSelectListItemList, "Clients", new { @class="ddlClients" })%>&nbsp;&nbsp;
    <%:"Start:" %>&nbsp;<%=Html.TextBox("txtStartDate", Model.StartDate.ToString("MM/dd/yyyy"), new { @class="txtStartDate" }) %>&nbsp;&nbsp;
    <%:"End:" %>&nbsp;<%=Html.TextBox("txtEndDate",Model.EndDate.ToString("MM/dd/yyyy"), new { @class="txtEndDate" }) %>&nbsp;&nbsp;
    <button type="button" id="btnFind" name="btnFind" class="btnFind">Find</button>

    <table id="tabPayments" class="table table-striped tabPayments">
        <thead id="theadPayments">
            <tr>
                <th style='text-align:right'>Payment Date</th>
                <!--<th style='text-align:left'>Payment Id</th>-->
                <th style='text-align:right'>Total Amount</th>
                <!--<th style='text-align:left'>Client Id</th>-->
                <th style='text-align:left'>Client Name</th>
                <th style='text-align:left'>Billing Contact</th>
                <th style='text-align:left'>Invoices</th>
            </tr>
        </thead>
        <tbody id="tbodyPayments">
        </tbody>
    </table>

</div>
        
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">

<script type='text/javascript'>
    var PaymentsCSS = new Object();
    PaymentsCSS.PaymentDate = "PaymentDate";
    PaymentsCSS.PaymentId = "PaymentId";
    PaymentsCSS.PaymentTotalAmount = "PaymentTotalAmount";
    PaymentsCSS.ClientId = "ClientId";
    PaymentsCSS.ClientName = "ClientName";
    PaymentsCSS.ClientContacts = "ClientContacts";
    PaymentsCSS.ContactLastName = "ContactLastName";
    PaymentsCSS.ContactFirstName = "ContactFirstName";
    PaymentsCSS.ddlClientContacts = "ddlClientContacts";
    PaymentsCSS.Invoices = "Invoices";
    PaymentsCSS.ddlInvoices = "ddlInvoices";

    var PaymentsDATA = new Object();
    PaymentsDATA.PaymentDate = "Date";
    PaymentsDATA.PaymentId = "PaymentID";
    PaymentsDATA.PaymentTotalAmount = "TotalAmount";
    PaymentsDATA.ClientId = "ClientID";
    PaymentsDATA.ClientName = "ClientName";
    PaymentsDATA.ClientContacts = "ClientContacts";
    PaymentsDATA.IsPaymentContact = "IsPaymentContact";
    PaymentsDATA.BillingContactID = "BillingContactID";
    PaymentsDATA.ClientContactID = "ClientContactID";
    PaymentsDATA.ContactLastName = "ContactLastName";
    PaymentsDATA.ContactFirstName = "ContactFirstName";
    PaymentsDATA.Invoices = "Invoices";
    PaymentsDATA.IsPaymentInvoice = "IsPaymentInvoice";
    PaymentsDATA.InvoiceID = "InvoiceID";
    PaymentsDATA.InvoiceNumber = "InvoiceNumber";
    PaymentsDATA.InvoiceDate = "InvoiceDate";
    PaymentsDATA.IpQBTransactionID = "IpQBTransactionID";
    PaymentsDATA.IpAmount = "IpAmount";

    var sizeMe = new Object();

    $(function() {

        $('.txtStartDate').datepicker();

        $('.txtEndDate').datepicker();

        $('.ddlClients').change(function (e) {
            if (e.target == this) {
                ;
            }
        });


        $('.btnFind').click(function (e) {
            if (e.target == this) {
                var optionSelected = 0;
                var startDate = null;
                var endDate = null;
                if ($('.ddlClients option:selected').length > 0) {
                    optionSelected = Number($('.ddlClients option:selected').first().val());
                }
                if ($('.txtStartDate').length > 0 &&
                    (!isNaN(Number(new Date($('.txtStartDate').first().val()))))) {
                    var sTempDate = new Date($('.txtStartDate').first().val());
                    startDate = sTempDate.toLocaleDateString();
                }
                if ($('.txtEndDate').length > 0 &&
                    (!isNaN(Number(new Date($('.txtEndDate').first().val()))))) {
                    var eTempDate = new Date($('.txtEndDate').first().val());
                    endDate = eTempDate.toLocaleDateString();
                }
                $('#tbodyPayments').html("");
                $('#tbodyPayments').append("<tr class='trNoPayments'><td style='align:center' colspan='8'>Loading <img src='/Content/images/load.gif'></td>" + "</tr>");

                $.post("/Invoices/GetPaymentsForInvoiceBalancerJSON", {
                    clientID: Number(optionSelected),
                    startDate: startDate,
                    endDate: endDate
                }, function (data) {
                    if (data.success) {
                        $('#tbodyPayments').html("");
                        for (var i = 0; i < data.rows.length; i++)
                        {
                            var clientContacts = data.rows[i][PaymentsDATA.ClientContacts];
                            var invoices = data.rows[i][PaymentsDATA.Invoices];

                            $('#tbodyPayments').append("<tr class='trPayment'>" +
                                                           "<td style='text-align:right' class='" + PaymentsCSS.PaymentDate + "'></td>" +
                                                           /*"<td style='text-align:left' class='" + PaymentsCSS.PaymentId + "'></td>" +*/
                                                           "<td style='text-align:right' class='" + PaymentsCSS.PaymentTotalAmount + "'></td>" +
                                                           /*"<td style='text-align:left' class='" + PaymentsCSS.ClientId + "'></td>" +*/
                                                           "<td style='text-align:left' class='" + PaymentsCSS.ClientName + "'></td>" +
                                                           "<td style='text-align:left' class='" + PaymentsCSS.ClientContacts + "'><select multiple class='" + PaymentsCSS.ddlClientContacts + "'></select></td>" +
                                                           "<td style='text-align:left' class='" + PaymentsCSS.Invoices + "'><select multiple class='" + PaymentsCSS.ddlInvoices + "'></select></td>" +
                                                       "</tr>");
                            $($('#tbodyPayments tr')[i]).find("." + PaymentsCSS.PaymentDate).first().text(data.rows[i][PaymentsDATA.PaymentDate]);
                            //$($('#tbodyPayments tr')[i]).find("." + PaymentsCSS.PaymentId).first().text(String(data.rows[i][PaymentsDATA.PaymentId]));
                            $($('#tbodyPayments tr')[i]).find("." + PaymentsCSS.PaymentTotalAmount).first().text(String(data.rows[i][PaymentsDATA.PaymentTotalAmount]));
                            //$($('#tbodyPayments tr')[i]).find("." + PaymentsCSS.ClientId).first().text(String(data.rows[i][PaymentsDATA.ClientId]));
                            $($('#tbodyPayments tr')[i]).find("." + PaymentsCSS.ClientName).first().text(String(data.rows[i][PaymentsDATA.ClientName]));
                            
                            for (var ci = 0; ci < clientContacts.length; ci++) {
                                $($('#tbodyPayments tr')[i]).find("." + PaymentsCSS.ClientContacts).first().find("." + PaymentsCSS.ddlClientContacts).first().append($("<option " + (String(clientContacts[ci][PaymentsDATA.IsPaymentContact]).toLowerCase() == "true" ? "selected='selected'": "" ) + " ></option>").attr("value", String(clientContacts[ci][PaymentsDATA.ClientContactID])).text($.trim(String(clientContacts[ci][PaymentsDATA.ContactFirstName]) + " " + String(clientContacts[ci][PaymentsDATA.ContactLastName]))));
                            }

                            for (var ii = 0; ii < invoices.length; ii++) {
                                $($('#tbodyPayments tr')[i]).find("." + PaymentsCSS.Invoices).first().find("." + PaymentsCSS.ddlInvoices).first().append($("<option " + (String(invoices[ii][PaymentsDATA.IsPaymentInvoice]).toLowerCase() == "true" ? "selected='selected'" : "") + " ></option>").attr("value", String(invoices[ii][PaymentsDATA.InvoiceID])).text($.trim(String(invoices[ii][PaymentsDATA.InvoiceNumber]) + " " + String(invoices[ii][PaymentsDATA.InvoiceDate]) + " " + String(invoices[ii][PaymentsDATA.IpQBTransactionID]) + " " + String(invoices[ii][PaymentsDATA.IpAmount]))));
                            }
                        }

                        if (data.rows.length <= 0) {
                            $('#tbodyPayments').html("");
                            $('#tbodyPayments').append("<tr class='trNoPayments'><td style='align:center' colspan='8'>No Records.</td>" +
                                                       "</tr>");
                        }
                        else
                        {
                            setTimeout(function () {
                                var width = Number($($('#tbodyPayments tr')).first().find("." + PaymentsCSS.ClientContacts).first().width());
                                if (!isNaN(width) && width > 0) {
                                    $("." + PaymentsCSS.ddlClientContacts).width(width);
                                }
                                width = Number($($('#tbodyPayments tr')).first().find("." + PaymentsCSS.Invoices).first().width());
                                if (!isNaN(width) && width > 0) {
                                    $("." + PaymentsCSS.ddlInvoices).width(width);
                                }

                                $("." + PaymentsCSS.ddlInvoices).each(function (index, element) {
                                    var len = $(this).find('option').length;
                                    if (Number(len) <= 5) {
                                        len = 5;
                                    }
                                    sizeMe[index] = Number(len);
                                    $(this).attr("size", String(len));
                                });

                                $("." + PaymentsCSS.ddlClientContacts).each(function (index, element) {
                                    var len = $(this).find('option').length;
                                    if (Number(len) <= 5) {
                                        len = 5;
                                    }
                                    if (Number(sizeMe[index]) > Number(len))
                                    {
                                        len = Number(sizeMe[index]);
                                    }
                                    $(this).attr("size", String(len));
                                });

                            }, 100);
                        }

                    } else {
                        $('#tbodyPayments').html("");
                        $('#tbodyPayments').append("<tr class='trNoPayments'><td style='align:center' colspan='8'>Error!</td>" +
                                                       "</tr>");

                    } //if success
                }, 'json');
            }
        });

      });

</script>
<style type="text/css">

.table-striped>tbody>tr:nth-child(odd)>td, .table-striped>tbody>tr:nth-child(odd)>th {
background-color: whitesmoke;
}

.table-striped>tbody>tr:nth-child(even)>td, .table-striped>tbody>tr:nth-child(even)>th {
background-color: white;
}

.table>thead>tr>th, .table>tbody>tr>th, .table>tfoot>tr>th, .table>thead>tr>td, .table>tbody>tr>td, .table>tfoot>tr>td {
padding: 8px;
line-height: 1.42857143;
vertical-align: top;
border-top: 1px solid #ddd;
}
</style>
</asp:Content>
