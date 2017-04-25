<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.Clients_Details>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Client Settings
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


    <% decimal TotalAmount = 0; %>
    <div class="art-content-wide">
        <table>
            <tr>
                <td style='width: 500px; vertical-align: top;'>
                    <fieldset style='margin: 0; background-color: White; padding: 0px; height: 400px'>
                        <div class='fieldset-header'>
                            <h3><%=Model.ClientName%></h3>
                        </div>
                        <div style='padding: 0px;'>

                            <div id="clientinfo-tabs" style='display: none; font-size: 12px'>
                                <ul>
                                    <li><a href="#clientinfo-tab-1">Client Info</a></li>
                                    <li><a href="#clientinfo-tab-4">Contacts</a></li>
                                    <li><a href="#clientinfo-tab-2">Invoice Settings</a></li>
                                    <li><a href="#clientinfo-tab-3">Vendor IDs</a></li>
                                    <% if (Model.ParentClientID == 0)
                                        { %>
                                    <li><a href="#clientinfo-tab-5">Revenue</a></li>
                                    <% } %>
                                </ul>
                                <div id="clientinfo-tab-1">

                                    <table cellpadding='3' cellspacing='2' style='font-size: 12px; height: 244px'>
                                        <tr>
                                            <td>
                                                <b>Client Name:</b>
                                            </td>
                                            <td>
                                                <%= Html.TextBox("ClientName", Model.ClientName, new { @style = "width:290px;" })%>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <b>Parent Client:</b>
                                            </td>
                                            <td>
                                                <span id='spnParent' style='font-weight: bold;'><%= Html.Encode(Model.ParentClientName)%></span>

                                                <select id='Parent' style='width: 295px; display: none;'></select>
                                                <a href='javascript:void(0);' id='cnclParent' style='display: none'>Cancel</a>
                                                <% if (Model.ParentClientName != null)
                                                    { %><br />
                                                <% } %>
                                                <a href='javascript:void(0);' id='lnkParent'>Modify</a>
                                                <% if (Model.ParentClientName != null)
                                                    { %><label class='inline' id='sepParent'> | </label>
                                                <a href='javascript:void(0);' id='rmvParent'>Remove</a> <% } %>
                                                <%= Html.Hidden("ParentClientID", Model.ParentClientID.ToString()) %>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <b>Address Line 1:</b>
                                            </td>
                                            <td>
                                                <%= Html.TextBox("Address1", Model.Address1, new { @style = "width:290px;" })%>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <b>Address Line 2:</b>
                                            </td>
                                            <td>
                                                <%= Html.TextBox("Address2", Model.Address2, new { @style = "width:290px;" })%>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <b>City, State ZIP:</b>
                                            </td>
                                            <td>
                                                <%= Html.TextBox("City", Model.City, new { @style = "width:150px;" })%>, <%= Html.TextBox("State", Model.State, new { @style = "width:50px;" })%> <%= Html.TextBox("Zip", Model.Zip, new { @style = "width:65px;" })%>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <b>Quickbooks ID:</b>
                                            </td>
                                            <td>
                                                <%= Html.TextBox("BilledAsClientName", Model.BilledAsClientName, new { @style = "width:290px;" })%>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <b>Billing Group:</b>
                                            </td>
                                            <td>
                                                <select id='slctBillingGroup' style='width: 295px;'></select>
                                                <%= Html.Hidden("BillingGroupID", Model.BillingGroupID.ToString()) %>
                                                <!-- <%//= Html.CheckBox("AuditInvoices", Model.AuditInvoices) %> <b>Audit Invoices</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <%//= Html.CheckBox("DoNotInvoice", Model.DoNotInvoice) %> <b>Do Not Invoice</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                -->
                                            </td>
                                        </tr>
                                        <tr>
                                            <td valign="top"><b>Notes:</b></td>
                                            <td>
                                                <textarea id="billing_notes" name="billing_notes" style="width: 100%; height: 100px;"><%= Model.Notes %></textarea>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <b>Status:</b>
                                            </td>
                                            <td>
                                                <select id='ClientStatus' style='width: 150px;'>
                                                    <option value="Active">Active</option>
                                                    <option value="Inactive">Inactive</option>
                                                </select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href='javascript:void(0)' onclick='saveClientInfo()'>Save Changes</a>
                                            </td>
                                        </tr>
                                    </table>
                                </div>

                                <div id="clientinfo-tab-4" style="padding: 1px; margin: 0">
                                    <table id='list_ClientContacts'></table>
                                </div>

                                <div id="clientinfo-tab-2">



                                    <div id='HasInvoiceSettings_No' style='display: none; height: 244px; font-size: 12px'>
                                        This client is not configured to generate an invoice.<br />
                                        <br />
                                        <a href='javascript:void(0)' onclick='addClientInvoiceSettings()'>Configure Invoice Settings</a>
                                    </div>

                                    <div id='HasInvoiceSettings_Parent' style='display: none; height: 244px; font-size: 12px'>
                                        This client's billing activity rolls up to the parent account.<br />
                                        <br />
                                        <b>Parent Client:</b> <%=Model.ParentClientName%>.<br />
                                        <br />
                                        Please go to the parent client if you need to make invoice setting changes.
                                    </div>

                                    <div id='HasInvoiceSettings_Yes' style='display: none;'>
                                        <table cellpadding='3' cellspacing='2' style="height: 244px; font-size: 12px">
                                            <tr>
                                                <td>
                                                    <b>Client Split Mode:</b>
                                                </td>
                                                <td>
                                                    <select id='ClientSplitMode' style='width: 260px;'>
                                                        <option value="0">[Not Configured]</option>
                                                        <option value="1">Only this Client</option>
                                                        <option value="2">Include All Subclients</option>
                                                        <option value="3">Custom</option>
                                                    </select>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <b>Invoice Template:</b>
                                                </td>
                                                <td>
                                                    <select id='InvoiceTemplate' style='width: 260px;'>
                                                        <option value="0">[Not Configured]</option>
                                                        <option value="1">Standard 1.0</option>
                                                        <option value="3">Quantity / Rate</option>
                                                        <option value="5">Standard 2.0</option>
                                                        <option value="6">SEE ATTACHED DETAIL</option>
                                                        <option value="7">Summary by Client</option>
                                                        <option value="8">Summary by File #</option>
                                                        <option value="19">Summary By Reference</option>
                                                        <option value="9">Custom - Paylease</option>
                                                        <option value="10">Custom - B&amp;W Pantex</option>
                                                        <option value="11">Quantity / Rate - Separate Vendor</option>
                                                        <option value="12">Custom - Luth Research</option>
                                                        <option value="13">Custom - Paylease</option>
                                                        <option value="14">Custom - Village Green</option>
                                                        <option value="15">Custom - Pohanka</option>
                                                        <option value="16">Custom - Colorado Christian Univerity - Student</option>
                                                        <option value="18">Custom - Jani-King Franchise</option>
                                                    </select>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <b>Billing Detail Report:</b>
                                                </td>
                                                <td>
                                                    <select id='BillingDetailReport' style='width: 260px;'>
                                                        <option value="0">None</option>
                                                        <option value="1">Group By Reference</option>
                                                        <option value="2">Group By FileNum</option>
                                                        <option value="3">Group By Ordered By</option>
                                                        <option value="4">Group by Client</option>
                                                    </select>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan='2' align='left'>
                                                    <%= Html.CheckBox("ApplyFinanceCharges", Model.ApplyFinanceCharge) %> <b>Apply Finance Charges</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%= Html.CheckBox("Collections", Model.SentToCollections) %> <b>Sent to Collections</b>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan='2' align='left'>
                                                    <%= Html.TextBox("FinChargeDays", Model.FinanceChargeDays, new { @style = "width:40px;margin-left:40px; text-align:right" })%> <b>-Days</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%= Html.CheckBox("ExcludeFromReminders", Model.ExcludeFromReminders) %> <b>Exclude From Reminders</b>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan='2' align='left'>
                                                    <%= Html.TextBox("FinChargePct", Model.FinanceChargePercent * 100, new { @style = "width:40px;margin-left:40px; text-align:right" })%> <b>-Percent</b>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan='2' align='right'>
                                                    <a href='javascript:void(0)' onclick='removeClientInvoiceSettings()'>Remove Invoice Settings</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href='javascript:void(0)' onclick='saveClientInvoiceSettings()'>Save Changes</a>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>

                                </div>
                                <div id="clientinfo-tab-3">

                                    <div id='HasVendorSettings_No' style='display: none; height: 244px; font-size: 12px'>
                                        This client has not yet been associated with a vendor.<br />
                                        <br />
                                        <a href='javascript:void(0)' onclick='addClientVendor()'>Create Vendor IDs</a>
                                    </div>


                                    <div id='HasVendorSettings_Yes' style='display: none;'>
                                        <table cellpadding='3' cellspacing='2' style='height: 244px; font-size: 12px'>
                                            <tr>
                                                <td align="center">
                                                    <b><u>VENDOR</u></b>
                                                </td>
                                                <td>
                                                    <b><u>VENDOR'S CLIENT ID</u></b>
                                                </td>
                                            </tr>
                                            <tr style="padding-top: 0px; padding-bottom: 0px;">
                                                <td align="right">
                                                    <b>Tazworks 1.0 System:</b>
                                                </td>
                                                <td>
                                                    <%= Html.TextBox("Vendor1", Model.Tazworks1ID, new { @style = "width:150px;" })%>
                                                </td>
                                            </tr>
                                            <tr style="padding-top: 0px; padding-bottom: 0px;">
                                                <td align="right">
                                                    <b>Tazworks 2.0 System:</b>
                                                </td>
                                                <td>
                                                    <%= Html.TextBox("Vendor2", Model.Tazworks2ID, new { @style = "width:150px;" })%>
                                                </td>
                                            </tr>
                                            <tr style="padding-top: 0px; padding-bottom: 0px;">
                                                <td align="right">
                                                    <b>DebtorONE:</b>
                                                </td>
                                                <td>
                                                    <%= Html.TextBox("Vendor3", Model.Debtor1ID, new { @style = "width:150px;" })%>
                                                </td>
                                            </tr>
                                            <tr style="padding-top: 0px; padding-bottom: 0px;">
                                                <td align="right">
                                                    <b>TransUnion:</b>
                                                </td>
                                                <td>
                                                    <%= Html.TextBox("Vendor4", Model.TransUnionID, new { @style = "width:150px;" })%>
                                                </td>
                                            </tr>
                                            <tr style="padding-top: 0px; padding-bottom: 0px;">
                                                <td align="right">
                                                    <b>Experian:</b>
                                                </td>
                                                <td>
                                                    <%= Html.TextBox("Vendor5", Model.ExperianID, new { @style = "width:150px;" })%>
                                                </td>
                                            </tr>
                                            <tr style="padding-top: 0px; padding-bottom: 0px;">
                                                <td align="right">
                                                    <b>ApplicantONE:</b>
                                                </td>
                                                <td>
                                                    <%= Html.TextBox("Vendor7", Model.ApplicantONEID, new { @style = "width:150px;" })%>
                                                </td>
                                            </tr>
                                            <tr style="padding-top: 0px; padding-bottom: 0px;">
                                                <td align="right">
                                                    <b>Pembrooke eDrug:</b>
                                                </td>
                                                <td>
                                                    <%= Html.TextBox("Vendor8", Model.PembrookeID, new { @style = "width:150px;" })%>
                                                </td>
                                            </tr>
                                            <tr style="padding-top: 0px; padding-bottom: 0px;">
                                                <td align="right">
                                                    <b>RentTrack:</b>
                                                </td>
                                                <td>
                                                    <%= Html.TextBox("Vendor9", Model.RentTrackID, new { @style = "width:150px;" })%>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td></td>
                                                <td style='text-align: right;'>
                                                    <a href='javascript:void(0)' onclick='saveClientVendorSettings()'>Save Changes</a>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>
                                </div>

                                <% if (Model.ParentClientID == 0) { %>
                                <div id="clientinfo-tab-5">
                                    <table cellpadding='3' cellspacing='2' style='height: 244px; font-size: 12px'>
                                        <tr style="padding-top: 0px; padding-bottom: 0px;">
                                            <td align="right">
                                                <b>Expected Monthly Revenue:</b>
                                            </td>
                                            <td>
                                                <%= Html.TextBox("ExpectedMonthlyRevenue", Model.ExpectedMonthlyRevenue, new { @style = "width:150px;" })%>
                                            </td>
                                        </tr>
                                        <tr style="padding-top: 0px; padding-bottom: 0px;">
                                            <td align="right">
                                                <b>Account Create Date:</b>
                                            </td>
                                            <td>
                                                <%= Html.TextBox("AccountCreateDate", Model.AccountCreateDate, new { @style = "width:150px;" })%>
                                            </td>
                                        </tr>
                                        <tr style="padding-top: 0px; padding-bottom: 0px;">
                                            <td align="right">
                                                <b>Account Owner:</b>
                                            </td>
                                            <td>
                                                <%= Html.TextBox("AccountOwner", Model.AccountOwner, new { @style = "width:150px;" })%>
                                            </td>
                                        </tr>
                                        <tr style="padding-top: 0px; padding-bottom: 0px;">
                                            <td align="right">
                                                <b>Affiliate Name:</b>
                                            </td>
                                            <td>
                                                <%= Html.TextBox("AffiliateName", Model.AffiliateName, new { @style = "width:150px;" })%>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td></td>
                                            <td style='text-align: right;'>
                                                <a href='javascript:void(0)' id='btnSaveExpectedMonthlyRevenueSettings'>Save Changes</a>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                                <% } %>

                            </div>

                        </div>
                    </fieldset>


                </td>
                <td style='width: 450px; vertical-align: top;'>
                    <fieldset style='margin: 0; background-color: White; padding: 0;'>
                        <div class='fieldset-header'>
                            <h3 id='CurrentActivityHeader'>Account Activity</h3>
                        </div>
                        <div style='padding: 10px; height: 398px; overflow: auto;'>

                            <table border='0' style='width: 95%; margin-top: 10px;'>
                                <tr style='font-weight: bold;'>
                                    <th style='width: 110px; text-align: left;'>Invoice #</th>
                                    <th style='width: 70px; text-align: left;'>Date</th>
                                    <th style='width: 10px; text-align: left;'>&nbsp;</th>
                                    <th style='text-align: left;'>Description</th>
                                    <th style='width: 100px; text-align: right;'>Amount</th>
                                    <th style='width: 100px; text-align: right;'>Credit</th>
                                    <th style='width: 100px; text-align: right;'>Balance</th>
                                </tr>
                                <% if (Model.BillingContactID != 0)
                                   { %>
                                <% 
    
                                       foreach (var item in Model.AccountActivity.accountActivityRows)
                                       {
                                           TotalAmount += item.Amount; %>
                                <tr style='<%=(item.Balance == ((decimal)0) || item.Type == "Beginning Balance" ? "": "background-color:yellow;") %>'>
                                    <% if (item.LinkID == 0)
                                       { %>
                                    <td><%= Html.Encode(item.InvoiceNumber)%></td>
                                    <% }
                                       else
                                       { %>
                                    <td><a href='javascript:void(0)' onclick="openInvoice(<%= item.LinkID.ToString() %>)"><%= Html.Encode(item.InvoiceNumber)%></a></td>
                                    <% } %>

                                    <td><%= (item.Date.HasValue ? Html.Encode(item.Date.Value.ToString("MM/dd/yyyy")) : "&nbsp;")%></td>
                                    <td></td>
                                    <td>
                                        <input type="hidden" class="hidInvoiceNumber" value="<%: item.InvoiceNumber %>" />
                                        <input type="hidden" class="hidInvoiceID" value="<%: item.InvoiceID %>" />
                                        <input type="hidden" class="hidPaymentID" value="<%: item.PaymentID %>" />
                                        <input type="hidden" class="hidPaymentList" value="<%: item.PaymentList %>" />
                                        <input type="hidden" class="hidPaymentDateList" value="<%: item.PaymentDateList %>" />
                                        <input type="hidden" class="hidAmountReceivedList" value="<%: item.AmountReceivedList %>" />
                                        <input type="hidden" class="hidPQBTransactionIDList" value="<%: item.PQBTransactionIDList %>" />
                                        <input type="hidden" class="hidItpQBTransactionIDList" value="<%: item.ItpQBTransactionIDList %>" />
                                        <input type="hidden" class="hidInvoiceList" value="<%: item.InvoiceList %>" />
                                        <input type="hidden" class="hidInvoiceDateList" value="<%: item.InvoiceDateList %>" />
                                        <input type="hidden" class="hidPaymentSpentAmountList" value="<%: item.PaymentSpentAmountList %>" />
                                        <input type="hidden" class="hidIQBTransactionIDList" value="<%: item.IQBTransactionIDList %>" />
                                        <input type="hidden" class="hidPtiQBTransactionIDList" value="<%: item.PtiQBTransactionIDList %>" />
                                        <input type="hidden" class="hidInvoiceNumberList" value="<%: item.InvoiceNumberList %>" />
                                        <input type="hidden" class="hidTotalAmountSpent" value="<%: item.TotalAmountSpent %>" />
                                        <input type="hidden" class="hidTotalAmountReceived" value="<%: item.TotalAmountReceived  %>" />
                                        <span class="spanType"><%= Html.Encode(item.Type)%></span>
                                        <div class="lineItemDialog<%=(String.IsNullOrEmpty(item.InvoiceNumber) ? "" : " InvoiceType") + (String.IsNullOrEmpty(item.PaymentID) ? "" : " PaymentType") %>" title="<%: item.Type + ": " + (String.IsNullOrEmpty(item.InvoiceNumber) ? "" : "[InvoiceNumber: " + item.InvoiceNumber + "] ") + (String.IsNullOrEmpty(item.PaymentID) ? "" : "[PaymentID: " + item.PaymentID + "] ") + (item.Date.HasValue ? Html.Encode(item.Date.Value.ToString("MM/dd/yyyy")) + " Amount: " + item.Amount.ToString("F") : "&nbsp;") %>">
                                            <input type="hidden" class="hidDialogInvoiceID" value="<%: item.InvoiceID %>" />
                                            <input type="hidden" class="hidDialogPaymentID" value="<%: item.PaymentID %>" />
                                            <input type="hidden" class="hidDialogAmount" value="<%: item.Amount.ToString("F") %>" />
                                            <span class="spanData"></span>
                                        </div>
                                    </td>
                                    <td style='text-align: right;'><%= Html.Encode(item.Amount.ToString("F"))%></td>
                                    <td style='text-align: right;'><%= Html.Encode(item.CreditReceived.ToString("F"))%></td>
                                    <td style='text-align: right; <%=(item.Balance == ((decimal)0) || item.Type == "Beginning Balance" ? "background-color:lightgreen;": "") %>'><%= Html.Encode(item.Balance.ToString("F"))%></td>
                                </tr>

                                <% } %>
                                <%} //End BillingContactID check
                                   else
                                   {%>
                                <tr>
                                    <td colspan='7'>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td colspan='7'>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td colspan='7'>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td colspan='7'>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td colspan='7' align='center' style='color: Red; font-size: 16px'><b>No Activity Found</b></td>
                                </tr>
                                <tr>
                                    <td colspan='7'>&nbsp;</td>
                                </tr>
                                <tr>
                                    <td colspan='7' align='center' style='color: Red'><b>If this is a brand new client, this will be populated with the first invoice.</b></td>
                                </tr>
                                <tr>
                                    <td colspan='7' align='center' style='color: Red'><b>If this is an existing client that already has Quickbooks activity, please contact the IT Dept.</b></td>
                                </tr>
                                <% } %>
                            </table>

                        </div>
                    </fieldset>
                </td>

            </tr>
        </table>

        <div>
            <table>
                <tr>
                    <td>
                        <form id='frmlist_Products'>
                            <fieldset style='margin-top: 4px; background-color: White; padding: 0;'>
                                <div class='fieldset-header'>
                                    <h3>Products</h3>
                                </div>

                                <div style='padding: 3px;'>
                                    <table id='list_Products'></table>
                                </div>

                            </fieldset>
                        </form>
                    </td>
                </tr>

            </table>
        </div>
    </div>

    <!-- SHOW or HIDE Invoice Settings view -->
    <% if (Model.HasClientInvoiceSettings == 1)
       { %>
    <script type="text/javascript"> $('#HasInvoiceSettings_Yes').show();</script>
    <% }
       else
       {
           if (Model.HasClientInvoiceSettings == 2)
           { %>
    <script type="text/javascript"> $('#HasInvoiceSettings_Parent').show()</script>
    <%     }
           else
           { %>
    <script type="text/javascript"> $('#HasInvoiceSettings_No').show()</script>
    <% }
       } %>

    <!-- SHOW or HIDE Vendor view -->
    <% if (Model.HasVendorSettings == true)
       { %>
    <script type="text/javascript">$('#HasVendorSettings_Yes').show();</script>
    <% }
       else
       {%>
    <script type="text/javascript">$('#HasVendorSettings_No').show()</script>
    <% }%>

    <script type="text/javascript">
        var lineItemDialogArray = new Object();
        var attachInvoices = new Object();
        var attachPayments = new Object();
        var trackAttachInvoice = new Object();
        var trackAttachPayment = new Object();
        var trackDeletePayment = new Object();
        var newPaymentIDCache = {};
        var newPaymentDateCache = {};
        var newPaymentQBCache = {};
        var newPaymentAmountReceivedCache = {};
        var newInvoiceNumberCache = {};
        var newInvoiceDateCache = {};
        var newInvoiceQBCache = {};
        var newInvoicePaymentSpentCache = {};
        var spanTypeZ = {};
        var hidPaymentDateListZ = {};
        var hidAmountReceivedListZ = {};
        var hidPQBTransactionIDListZ = {};
        var hidInvoiceIDZ = {};
        var hidInvoiceNumberZ = {};
        var hidTotalAmountReceivedZ = {};
        var hidInvoiceDateListZ = {};
        var hidPaymentSpentAmountListZ = {};
        var hidIQBTransactionIDListZ = {};
        var hidPaymentIDZ = {};
        var hidInvoiceNumberListZ = {};
        var hidTotalAmountSpentZ = {};

        jQuery(document).ready(function() {
            $('#CurrentActivityHeader').html('Account Activity - Balance: <%= TotalAmount.ToString("C") %>&nbsp;&nbsp;&nbsp;<a class="aRefresh" style="color:yellow;display:none;" href="javascript:void(0);" onclick="javascript:location.reload();">Refresh</a>');

            $('#ClientSplitMode').val('<%= Model.ClientSplitMode %>');
            $('#InvoiceTemplate').val('<%= Model.InvoiceTemplate %>');
            $('#BillingDetailReport').val('<%= Model.BillingDetailReport %>');
            $('#ClientStatus').val('<%= Model.Status %>');
            $('#lnkParent').click(showChangeClient);
            $('#rmvParent').click(removeParent);
            $('#cnclParent').click(reloadPage);
            $('#ApplyFinanceCharges').click(showFinCharges);
            $('#Collections').click(disableFinCharges);

            UpdateBillingGroupDropDown();

            $('#Vendor1').val('<%= Model.Tazworks1ID %>');
            $('#Vendor2').val('<%= Model.Tazworks2ID %>');
            $('#Vendor3').val('<%= Model.Debtor1ID %>');
            $('#Vendor4').val('<%= Model.TransUnionID %>');
            $('#Vendor5').val('<%= Model.ExperianID %>');
            $('#Vendor7').val('<%= Model.ApplicantONEID %>');
            $('#Vendor8').val('<%= Model.PembrookeID %>');

            $('#AccountCreateDate').datepicker({ showOn: 'both', buttonImage: '../../Content/images/calendar.gif', buttonImageOnly: true, changeMonth: true, changeYear: true });

            $('#btnSaveExpectedMonthlyRevenueSettings').click(function() {

                if ($('#ExpectedMonthlyRevenue').val() == "")
                {
                    alert("Expected Monthly Revenue cannot be blank!");
                    return;
                }

                $('#ExpectedMonthlyRevenue').val($('#ExpectedMonthlyRevenue').val().trim().replace("$", "")); 
                
                if ($('#ExpectedMonthlyRevenue').val().indexOf(".") < 0)
                {
                    $('#ExpectedMonthlyRevenue').val($('#ExpectedMonthlyRevenue').val() + ".00")
                }

                var regexp = /^\d+\.\d{0,2}$/;
                if (!regexp.test($('#ExpectedMonthlyRevenue').val()))
                {
                    alert("Expected Monthly Revenue is not in the correct format!");
                    return;
                }

                if ($('#AccountCreateDate').val() == "")
                {
                    alert("Account Create Date cannot be blank!");
                    return;
                }

                $.post('../../Clients/SaveExpectedRevenueSettingsJSON', { ClientID: <%= Model.ClientID.ToString() %>, 
                        ExpectedMonthlyRevenue: $('#ExpectedMonthlyRevenue').val(), 
                        AccountCreateDate: $('#AccountCreateDate').val(), 
                        AccountOwner: $('#AccountOwner').val(), 
                        AffiliateName: $('#AffiliateName').val()
                }, function(data) {
                    if (data.success) {
                        alert('Expected Revenue Settings have been saved!');
                    }
                    else {
                        alert('Error saving Expected Revenue Settings!');
                        reloadPage();
                    }
                }, 'json');
            });

            //Client Contacts Grid
            $('#list_ClientContacts').jqGrid({
                url: '../../Clients/ClientContactsJSON',
                datatype: 'json',
                colModel: [
                        { name: 'id', index: 'id', key: true, hidden: true },
                        { name: 'ContactEmail', index: 'ContactEmail', hidden: true },
                        { name: 'ContactName', index: 'ContactName', align: 'left', width: 150 },
                        { name: 'LastLoginDate', index: 'LastLoginDate', align: 'center', width: 75 },
                        { name: 'DeliveryMethod', index: 'DeliveryMethod', align: 'center', width: 100 },
                        { name: 'IsPrimaryBillingContact', index: 'IsPrimaryBillingContact', align: 'left', width: 75 },
                        { name: 'ClientContactStatus', index: 'ClientContactStatus', align: 'left', width: 65 }
                ],
                colNames: ['id', 'ContactEmail', 'Contact Name', 'Last Login', 'Delivery', 'Billing', 'Status'],
                onSelectRow:
                    function(id) {
                        $('#addclientcontactdlgcontent').empty();
                        $('#updateclientcontactdlgcontent').empty();
                        $("#updateclientcontactdlgcontent").load('../../ClientContacts/AddClientContact/' + id + '?cmdType=update');
                        $("#updateclientcontactdlg").dialog('open');
                    },
                width: 485,
                height: 220,
                sortable: true,
                mtype: 'POST',
                rowNum: 100,
                rowList: [10, 50, 100],
                //pager: '#pager_ClientContacts',
                sortname: 'ClientContactName',
                viewrecords: true,
                sortorder: 'asc',
                //caption: 'Client Contacts',
                rownumbers: false,
                postData: { ClientID: '<%= Model.ClientID %>' },
                gridComplete: function() {
                    var ids = jQuery('#list_ClientContacts').jqGrid('getDataIDs');
                    for (var i = 0; i < ids.length; i++) {
                        var cl = ids[i];
                        var rowValues = jQuery("#list_ClientContacts").jqGrid('getRowData', cl);
                        var email = rowValues.ContactEmail;
                        $('#list_ClientContacts').jqGrid('setRowData', cl, { ContactName: "<a href='mailto:" + email + "?body=Dear Customer:%0A%0AYour invoice is attached.  Please remit payment at your earliest convenience. To make a phone payment by check or credit card free of charge please contact Accounts Receivable at <%=ConfigurationManager.AppSettings["billingphone"] %> or <%=ConfigurationManager.AppSettings["billingemail"] %>%0A%0AThank you for your business.%0A%0ASincerely,%0A%0A<%=ConfigurationManager.AppSettings["CompanyName"] %>&subject=Invoice from <%=ConfigurationManager.AppSettings["CompanyName"] %>'>" + rowValues.ContactName + "</a>" });
                    }
                },
                loadui: 'block',
                //footerrow: true,
                //userDataOnFooter: true,
                //multiselect: true,
                loadtext: 'Loading Client Contacts...',
                emptyrecords: 'No Client Contacts',
                toolbar: [true, "top"],
                gridview: true
            });

            $("#t_list_ClientContacts").append("<a id='lnkCreateBillingContact' href='javascript:void(0)' style='vertical-align:middle;line-height:18px;text-decoration:underline;color:#0000ff;margin-left:10px;'>Add New Client Contact</a>");

            $("a", "#t_list_ClientContacts").click(function() {
                //alert("Create Billing Contact");   
                $('#updateclientcontactdlgcontent').empty();
                $('#addclientcontactdlgcontent').empty();
                $("#addclientcontactdlgcontent").load('../../ClientContacts/AddClientContact/<%= Model.ClientID %>?cmdType=add');
                $("#addclientcontactdlg").dialog('open');
            });


            //Products Grid
            var lastsel;
            $('#list_Products').jqGrid({
                url: '../../ClientProducts/ProductsFromClientJSON',
                datatype: 'json',
                colModel: [
                        { name: 'id', index: 'id', key: true, hidden: true, editable: false },
                        { name: 'ProductCode', index: 'ProductCode', align: 'left', width: 90, editable: false },
                        { name: 'ProductName', index: 'ProductName', align: 'left', width: 340, editable: false },
                        { name: 'SalesPrice', index: 'SalesPrice', align: 'right', width: 40, editable: true },
                        { name: 'IncludeOnInvoice', index: 'IncludeOnInvoice', align: 'center', width: 90, editable: true, edittype: "select", editoptions: { value: "Always:Always;Non-Zero:Non-Zero;Never:Never"} },
                        { name: 'ImportsAtBaseOrSales', index: 'ImportsAtBaseOrSales', align: 'center', width: 60, editable: true, edittype: "select", editoptions: { value: "Yes:Yes;No:No"} },
                        { name: 'VendorName', index: 'VendorName', align: 'left', width: 100, editable: false },
                        { name: 'VendorID', index: 'VendorID', hidden: true, editable: false }
                ],
                colNames: ['id', 'Code', 'Product', 'Price', 'Invoice Display', 'Markup?', 'Vendor', 'VendorID'],
                onSelectRow: function(id) {
                    if (id && id !== lastsel) {
                        jQuery('#list_Products').jqGrid('restoreRow', lastsel);
                        jQuery('#list_Products').jqGrid('editRow', id, true);
                        lastsel = id;
                    }
                },
                editurl: '../../ClientProducts/EditClientProduct/',
                width: 944,
                height: 200,
                sortable: true,
                mtype: 'POST',
                //altRows: true,
                rowNum: 100,
                rowList: [10, 50, 100],
                //pager: '#pager_Products',
                sortname: 'ProductName',
                viewrecords: true,
                sortorder: 'asc',
                caption: 'Assigned Client Products',
                rownumbers: false,
                postData: { ClientID: '<%= Model.ClientID %>' },
                /*gridComplete: function() {
                var ids = jQuery('#list_Products').jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                var cl = ids[i];
                $('#list_Products').jqGrid('setRowData', cl, { Action: "<a href='javascript:openBillingContact(" + cl + ");'>Modify</a>" });
                }
                },*/
                loadui: 'block',
                //footerrow: true,
                //userDataOnFooter: true,
                //multiselect: true,
                loadtext: 'Loading Products...',
                emptyrecords: 'No Products assigned to this Client',
                toolbar: [true, "top"],
                gridview: true
            });
            jQuery("#rowed3").jqGrid('navGrid', "#list_Products", { edit: false, add: false, del: false });


            $("#t_list_Products").append("<a id='lnkCreateBillingContact' href='javascript:void(0)' style='vertical-align:middle;line-height:18px;text-decoration:underline;color:#0000ff;margin-left:10px;'>Assign Products to Client</a>");
            $("a", "#t_list_Products").click(function() {
                $('#selectclientproductsdlgcontent').empty();
                $("#selectclientproductsdlgcontent").load('../../ClientProducts/SelectClientProducts/<%= Model.ClientID %>');
                $("#selectclientproductsdlg").dialog('open');
            });


            $("#addclientcontactdlg").dialog({
                bgiframe: true,
                autoOpen: false,
                height: 630,
                width: 600,
                modal: true,
                draggable: false,
                resizable: false,
                buttons: {
                    Save: function() {
                        $.post('../../ClientContacts/CreateClientContact/<%= Model.ClientID %>',
                        { ClientContactFirstName: $('#ClientContactFirstName').val(),
                            ClientContactLastName: $('#ClientContactLastName').val(),
                            ClientContactTitle: $('#ClientContactTitle').val(),
                            ClientContactEmail: $('#ClientContactEmail').val(),
                            ClientContactAddress1: $('#ClientContactAddress1').val(),
                            ClientContactAddress2: $('#ClientContactAddress2').val(),
                            ClientContactCity: $('#ClientContactCity').val(),
                            ClientContactStateCode: $('#ClientContactStateCode').val(),
                            ClientContactZIP: $('#ClientContactZIP').val(),
                            ClientContactBusinessPhone: $('#ClientContactBusinessPhone').val(),
                            ClientContactCellPhone: $('#ClientContactCellPhone').val(),
                            ClientContactFax: $('#ClientContactFax').val(),
                            BillingContactName: $('#BillingContactName').val(),
                            BillingContactAddress1: $('#BillingContactAddress1').val(),
                            BillingContactAddress2: $('#BillingContactAddress2').val(),
                            BillingContactCity: $('#BillingContactCity').val(),
                            BillingContactStateCode: $('#BillingContactStateCode').val(),
                            BillingContactZIP: $('#BillingContactZIP').val(),
                            BillingContactBusinessPhone: $('#BillingContactBusinessPhone').val(),
                            BillingContactFax: $('#BillingContactFax').val(),
                            BillingContactPOName: $('#BillingContactPOName').val(),
                            BillingContactPONumber: $('#BillingContactPONumber').val(),
                            DeliveryMethod: $('#DeliveryMethod').val(),
                            IsPrimaryBillingContact: $('#IsPrimaryBillingContact').is(':checked'),
                            OnlyShowInvoices: $('#OnlyShowInvoices').is(':checked'),
                            cmdType: $('#cmdType').val(),
                            SendUserEmail: $('#SendUserEmail').is(':checked')
                        },

                                        function(data) {
                                            if (data.success == false) {

                                                $('#addclientcontactdlgcontent').empty();
                                                $('#addclientcontactdlgcontent').append(data.view);

                                            } else {
                                                if (data.billingcontactid == 0) {
                                                    alert('Warning: The Contact has been created, however, the Billing Contact could not be created.');
                                                }
                                                else {
                                                    alert('New Contact has been created.');
                                                }

                                                $('#addclientcontactdlg').dialog('close');
                                                location.reload(true);
                                            }

                                        }, 'json');
                    },
                    Cancel: function() {
                        $(this).dialog('close');
                    }
                }
            });


            $("#updateclientcontactdlg").dialog({
                bgiframe: true,
                autoOpen: false,
                height: 630,
                width: 600,
                modal: true,
                draggable: false,
                resizable: false,
                buttons: {
                    Save: function() {
                        $.post('../../ClientContacts/UpdateClientContact/',
                            { ClientContactID: $('#ClientContactID').val(),
                                ClientContactFirstName: $('#ClientContactFirstName').val(),
                                ClientContactLastName: $('#ClientContactLastName').val(),
                                ClientContactTitle: $('#ClientContactTitle').val(),
                                ClientContactEmail: $('#ClientContactEmail').val(),
                                ClientContactAddress1: $('#ClientContactAddress1').val(),
                                ClientContactAddress2: $('#ClientContactAddress2').val(),
                                ClientContactCity: $('#ClientContactCity').val(),
                                ClientContactStateCode: $('#ClientContactStateCode').val(),
                                ClientContactZIP: $('#ClientContactZIP').val(),
                                ClientContactBusinessPhone: $('#ClientContactBusinessPhone').val(),
                                ClientContactCellPhone: $('#ClientContactCellPhone').val(),
                                ClientContactFax: $('#ClientContactFax').val(),
                                BillingContactName: $('#BillingContactName').val(),
                                BillingContactAddress1: $('#BillingContactAddress1').val(),
                                BillingContactAddress2: $('#BillingContactAddress2').val(),
                                BillingContactCity: $('#BillingContactCity').val(),
                                BillingContactStateCode: $('#BillingContactStateCode').val(),
                                BillingContactZIP: $('#BillingContactZIP').val(),
                                BillingContactBusinessPhone: $('#BillingContactBusinessPhone').val(),
                                BillingContactFax: $('#BillingContactFax').val(),
                                BillingContactPOName: $('#BillingContactPOName').val(),
                                BillingContactPONumber: $('#BillingContactPONumber').val(),
                                DeliveryMethod: $('#DeliveryMethod').val(),
                                IsPrimaryBillingContact: $('#IsPrimaryBillingContact').is(':checked'),
                                OnlyShowInvoices: $('#OnlyShowInvoices').is(':checked'),
                                cmdType: $('#cmdType').val(),
                                ClientContactStatus: $('#ClientContactStatus').val(),
                                BillingContactStatus: $('#BillingContactStatus').val(),
                                ClientID: $('#ClientID').val(),
                                UserID: $('#UserID').val(),
                                BillingContactID: $('#BillingContactID').val(),
                                NewPrimaryContactID: $('#NewPrimaryContactID').val()

                            },

                                            function(data) {
                                                if (data.success == false) {
                                                    $('#updateclientcontactdlgcontent').empty();
                                                    $('#updateclientcontactdlgcontent').append(data.view);

                                                } else {
                                                    if (data.billingcontactid == 0) {
                                                        alert('Warning: The Contact has been updated, however, the Billing Contact could not be created.');
                                                    }
                                                    else {
                                                        alert('Contact has been updated.');
                                                    }
                                                    $('#updateclientcontactdlg').dialog('close');
                                                    location.reload(true);
                                                }

                                            }, 'json');
                    },
                    Cancel: function() {
                        $(this).dialog('close');
                    },
                    Delete: function() {

                        if ($('#IsPrimaryBillingContact').is(':checked')) {
                            alert('You cannot delete a Primary Billing contact');
                        }
                        else {
                            if (confirm('Are you sure you want to delete this client contact?')) {
                                $.post('../../ClientContacts/DeleteClientContactJSON',
                                    { ClientContactID: $('#ClientContactID').val(),
                                        BillingContactID: $('#BillingContactID').val(),
                                        ClientID: $('#ClientID').val(),
                                        UserID: $('#UserID').val()
                                    }, function(data) {
                                        if (data.success) {
                                            alert('Contact has been deleted.');
                                            $('#updateclientcontactdlg').dialog('close');
                                            location.reload(true);
                                        }
                                    }, 'json');
                            }
                        } 
                    }
                }
            });



            $("#selectclientproductsdlg").dialog({
                bgiframe: true,
                autoOpen: false,
                height: 420,
                width: 790,
                modal: true,
                draggable: true,
                resizable: false,
                buttons: {
                    Save: function() {
                        $('#ClientProductsList').multiselect('destroy');


                        var selectedClientProductIDs = "";

                        var clientproductsarray = [];
                        $('#ClientProductsList :selected').each(function(i, selected) {
                            clientproductsarray[i] = $(selected).val();
                        });

                        selectedClientProductIDs = clientproductsarray.join(",");



                        //alert(selectedClientProductIDs);
                        $.post('../../ClientProducts/SaveClientProductsListJSON/<%= Model.ClientID %>',
                        { selectedClientProductIDs: selectedClientProductIDs, VendorID: $('#ClientVendorsList').val() },

                                        function(data) {
                                            if (data.success == false) {
                                                alert('ERROR: Product Not Assigned. Please try again');
                                                $('#selectclientproductsdlgcontent').empty();
                                                $('#selectclientproductsdlgcontent').append(data.view);

                                            } else {
                                                $('#selectclientproductsdlg').dialog('close');
                                                if (data.rollupexists == true) {
                                                    alert('Product(s) successfully added to both this client and the rolled-up client.\nPlease set the Product options within the grid on the client screen.');
                                                }
                                                else {
                                                    alert('Product(s) successfully added.\nPlease set the Product Options within the grid on the client screen.');
                                                }

                                                location.reload(true);
                                            }

                                        }, 'json');
                    },
                    Cancel: function() {
                        $(this).dialog('close');
                    }
                }
            });


            //Tabs
            $('#clientinfo-tabs').tabs();
            $('#clientinfo-tabs').show();

            setTimeout(function() {

                spanTypeZ = $('.spanType');

                hidPaymentDateListZ = $('.hidPaymentDateList');
                hidAmountReceivedListZ = $('.hidAmountReceivedList');
                hidPQBTransactionIDListZ = $('.hidPQBTransactionIDList');
                hidInvoiceIDZ = $('.hidInvoiceID');
                hidInvoiceNumberZ = $('.hidInvoiceNumber');
                hidTotalAmountReceivedZ = $('.hidTotalAmountReceived');

                $('.hidPaymentList').each(function(index,element) {
                    var paymentList = String($(this).val());
                    var paymentDateList = String($(hidPaymentDateListZ[index]).val());
                    var amountReceivedList = String($(hidAmountReceivedListZ[index]).val());
                    var pQBTransactionIDList = String($(hidPQBTransactionIDListZ[index]).val());
                    var invoiceID = String($(hidInvoiceIDZ[index]).val());
                    var invoiceNumber = String($(hidInvoiceNumberZ[index]).val());
                    var totalAmountReceived = String($(hidTotalAmountReceivedZ[index]).val());
                    if (paymentList != '') {
                        var paymentArray = paymentList.split(",");
                        var paymentDateArray = paymentDateList.split(",");
                        var amountReceivedArray = amountReceivedList.split(",");
                        var pQBTransactionIDArray = pQBTransactionIDList.split(",");
                        var toolTip = "InvoiceNumber: " + String(invoiceNumber) + "\r\n";
                        for (var ix = 0; ix < paymentArray.length; ix++) 
                        {
                            toolTip = toolTip + "\r\n" +
                                      "PaymentID: " + String(paymentArray[ix]).replace("\"","").replace("\"","") + "     " +
                                      "Payment Date: " + String(paymentDateArray[ix]).replace("\"","").replace("\"","") + "     " +
                                      "QB: " + String(pQBTransactionIDArray[ix]).replace("\"","").replace("\"","") + "     " +
                                      "Amount Received: " + String(amountReceivedArray[ix]).replace("\"","").replace("\"","");
                        }

                        toolTip = toolTip + "\r\n\r\n" + 
                                            "Total Amount Received: " + totalAmountReceived;

                        $(spanTypeZ[index]).attr('title', toolTip);
                    }
                });

                hidInvoiceDateListZ = $('.hidInvoiceDateList');
                hidPaymentSpentAmountListZ = $('.hidPaymentSpentAmountList');
                hidIQBTransactionIDListZ = $('.hidIQBTransactionIDList');
                hidPaymentIDZ = $('.hidPaymentID');
                hidInvoiceNumberListZ = $('.hidInvoiceNumberList');
                hidTotalAmountSpentZ = $('.hidTotalAmountSpent');
        
                $('.hidInvoiceList').each(function(index,element) {        
                    var invoiceList = String($(this).val());
                    var invoiceDateList = String($(hidInvoiceDateListZ[index]).val());
                    var paymentSpentAmountList = String($(hidPaymentSpentAmountListZ[index]).val());
                    var iQBTransactionIDList = String($(hidIQBTransactionIDListZ[index]).val());
                    var paymentID = String($(hidPaymentIDZ[index]).val());
                    var invoiceNumberList = String($(hidInvoiceNumberListZ[index]).val()); 
                    var totalAmountSpent = String($(hidTotalAmountSpentZ[index]).val());
                    if (invoiceList != '') {
                        var invoiceArray = invoiceList.split(",");
                        var invoiceDateArray = invoiceDateList.split(",");
                        var paymentSpentAmountArray = paymentSpentAmountList.split(",");
                        var iQBTransactionIDArray = iQBTransactionIDList.split(",");
                        var invoiceNumberArray = invoiceNumberList.split(",");
                        var toolTip = "PaymentID: " + String(paymentID) + "\r\n";
                        for (var ix = 0; ix < invoiceArray.length; ix++) 
                        {
                            toolTip = toolTip + "\r\n" +
                                      "Invoice Number: " + String(invoiceNumberArray[ix]).replace("\"","").replace("\"","") + "     " +
                                      "Invoice Date: " + String(invoiceDateArray[ix]).replace("\"","").replace("\"","") + "     " +
                                      "QB: " + String(iQBTransactionIDArray[ix]).replace("\"","").replace("\"","") + "     " +
                                      "Payment Spent: " + String(paymentSpentAmountArray[ix]).replace("\"","").replace("\"","");
                        }

                        toolTip = toolTip + "\r\n\r\n" + 
                                  "Total Amount Spent: " + totalAmountSpent;

                        $(spanTypeZ[index]).attr('title', toolTip);
                    }
                });

                $(".lineItemDialog").each(function(i,element) {        
                    lineItemDialogArray[i] = element;
                });
            
                $(".spanType").click(function(e) {
                    if (e.target == this) {
                        $('.aRefresh').show();
                        var i = Number($(".spanType").index(this));

                        if ($(lineItemDialogArray[i]).hasClass('ui-dialog-content') == false &&
                            $(lineItemDialogArray[i]).hasClass("InvoiceType"))
                        {
                            $(lineItemDialogArray[i]).dialog({
                                height: "auto",
                                width: "auto",
                                autoOpen: false,
                                modal: false,
                                open: function(event,ui) {                    
                                    $('.aRemovePaymentFromInvoice').unbind();
                                    $('.aRemovePaymentFromInvoice').click(function() {                        
                                        var invoiceID = Number($(this).parentsUntil('.lineItemDialog').last().parent().find('.hidDialogInvoiceID').val());
                                        var invoiceNumber = String($.trim($(this).parentsUntil('.lineItemDialog').last().parent().find('.spanInvoiceNumber').text()));
                                        var paymentID = Number($(this).parent().find('.hidActionPaymentID').val());
                                        if (confirm("Are you sure that you want to remove this PaymentID: " + String(paymentID) + " from the InvoiceNumber: " + String(invoiceNumber) + "?")) 
                                        {
                                            $.post('/Clients/RemovePaymentFromInvoiceJSON', {
                                                clientID: '<%= Model.ClientID %>',
                                                paymentID: String(paymentID), 
                                                invoiceID: String(invoiceID),
                                                invoiceNumber: String(invoiceNumber)
                                            }, function(data) {
                                                if (data.success) {
                                                    alert('PaymentID ' + String(data.paymentID) + ' has been removed from the InvoiceNumber ' + String(data.invoiceNumber) + '.');
                                                    if (data.accountActivity != null &&
                                                        data.accountActivity.accountActivityRows != null) 
                                                    {    
                                                        for (var ix = 0; ix < data.accountActivity.accountActivityRows.length; ix++) 
                                                        {
                                                            var myrow = data.accountActivity.accountActivityRows[ix];
                                                            if (myrow.PaymentID != null &&
                                                                String(myrow.PaymentID) != "" &&
                                                                $(".hidPaymentID[value='" + String(myrow.PaymentID) + "']").length > 0)
                                                            {
                                                                var td = $(".hidPaymentID[value='" + String(myrow.PaymentID) + "']").parent().first();
                                                                $(td).find(".hidInvoiceNumber").val(String(myrow.InvoiceNumber));
                                                                $(td).find(".hidInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidPaymentList").val(String(myrow.PaymentList));
                                                                $(td).find(".hidPaymentDateList").val(String(myrow.PaymentDateList));
                                                                $(td).find(".hidAmountReceivedList").val(String(myrow.AmountReceivedList));
                                                                $(td).find(".hidPQBTransactionIDList").val(String(myrow.PQBTransactionIDList));
                                                                $(td).find(".hidItpQBTransactionIDList").val(String(myrow.ItpQBTransactionIDList));
                                                                $(td).find(".hidInvoiceList").val(String(myrow.InvoiceList));
                                                                $(td).find(".hidInvoiceDateList").val(String(myrow.InvoiceDateList));
                                                                $(td).find(".hidPaymentSpentAmountList").val(String(myrow.PaymentSpentAmountList));
                                                                $(td).find(".hidIQBTransactionIDList").val(String(myrow.IQBTransactionIDList));
                                                                $(td).find(".hidPtiQBTransactionIDList").val(String(myrow.PtiQBTransactionIDList));
                                                                $(td).find(".hidInvoiceNumberList").val(String(myrow.InvoiceNumberList));
                                                                $(td).find(".hidTotalAmountSpent").val(String(myrow.TotalAmountSpent));
                                                                $(td).find(".hidTotalAmountReceived").val(String(myrow.TotalAmountReceived));
                                                                $(td).find(".hidDialogInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidDialogPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidDialogAmount").val(String(myrow.Amount));
                                                            }
                                                            if (myrow.InvoiceID != null &&
                                                                String(myrow.InvoiceID) != "" &&
                                                                $(".hidInvoiceID[value='" + String(myrow.InvoiceID) + "']").length > 0)
                                                            {
                                                                var td = $(".hidInvoiceID[value='" + String(myrow.InvoiceID) + "']").parent().first();
                                                                $(td).find(".hidInvoiceNumber").val(String(myrow.InvoiceNumber));
                                                                $(td).find(".hidInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidPaymentList").val(String(myrow.PaymentList));
                                                                $(td).find(".hidPaymentDateList").val(String(myrow.PaymentDateList));
                                                                $(td).find(".hidAmountReceivedList").val(String(myrow.AmountReceivedList));
                                                                $(td).find(".hidPQBTransactionIDList").val(String(myrow.PQBTransactionIDList));
                                                                $(td).find(".hidItpQBTransactionIDList").val(String(myrow.ItpQBTransactionIDList));
                                                                $(td).find(".hidInvoiceList").val(String(myrow.InvoiceList));
                                                                $(td).find(".hidInvoiceDateList").val(String(myrow.InvoiceDateList));
                                                                $(td).find(".hidPaymentSpentAmountList").val(String(myrow.PaymentSpentAmountList));
                                                                $(td).find(".hidIQBTransactionIDList").val(String(myrow.IQBTransactionIDList));
                                                                $(td).find(".hidPtiQBTransactionIDList").val(String(myrow.PtiQBTransactionIDList));
                                                                $(td).find(".hidInvoiceNumberList").val(String(myrow.InvoiceNumberList));
                                                                $(td).find(".hidTotalAmountSpent").val(String(myrow.TotalAmountSpent));
                                                                $(td).find(".hidTotalAmountReceived").val(String(myrow.TotalAmountReceived));
                                                                $(td).find(".hidDialogInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidDialogPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidDialogAmount").val(String(myrow.Amount));
                                                            }
                                                        }
                                                    }
                                                }
                                                else {
                                                    alert('Failed: ' + String(data.message));
                                                }
                                            });
                                        }
                                    });
                                },
                                buttons: {
                                    "Done": function() {

                                        var invoiceID = String($(this).find('.hidDialogInvoiceID').first().val());

                                        attachPayments = new Object();
                                        attachPayments.PaymentIDs = new Array();
                                        attachPayments.PaymentDates = new Array();
                                        attachPayments.PaymentQBs = new Array();
                                        attachPayments.AmountsReceived = new Array();

                                        if ($(this).find('.inputNewPaymentID').length > 0) {  
                            
                                            $(this).find('.inputNewPaymentID').each(function(ix, element) {
                                                attachPayments.PaymentIDs.push(String($(element).val()));
                                            });
                                            $(this).find('.inputNewPaymentDate').each(function(ix, element) {
                                                attachPayments.PaymentDates.push(String($(element).val()));
                                            });
                                            $(this).find('.inputNewPaymentQB').each(function(ix, element) {
                                                attachPayments.PaymentQBs.push(String($(element).val()));
                                            });
                                            $(this).find('.inputNewAmountReceived').each(function(ix, element) {
                                                attachPayments.AmountsReceived.push(String($(element).val()));
                                            });

                                            var deleteWholeBlankLines = new Array();

                                            for (var iy = 0; iy < attachPayments.PaymentIDs.length; iy++) 
                                            {
                                                var checkOne = String($.trim(attachPayments.PaymentIDs[iy]));
                                                var checkTwo = String($.trim(attachPayments.PaymentDates[iy]));
                                                var checkThree = String($.trim(attachPayments.PaymentQBs[iy]));
                                                var checkFour = String($.trim(attachPayments.AmountsReceived[iy]));

                                                if (checkOne == "" &&
                                                    checkTwo == "" &&
                                                    checkThree == "" &&
                                                    checkFour == "") 
                                                {
                                                    deleteWholeBlankLines.push(iy);
                                                }
                                            }

                                            for (var iy = deleteWholeBlankLines.length - 1; iy >= 0; iy--) 
                                            {   
                                                attachPayments.PaymentIDs.splice(deleteWholeBlankLines[iy],1);
                                                attachPayments.PaymentDates.splice(deleteWholeBlankLines[iy],1);
                                                attachPayments.PaymentQBs.splice(deleteWholeBlankLines[iy],1);
                                                attachPayments.AmountsReceived.splice(deleteWholeBlankLines[iy],1);
                                            }

                                            if (attachPayments.PaymentIDs.length <= 0 ) {
                                                $(this).dialog("close");
                                                return;
                                            }

                                            trackAttachPayment[invoiceID] = this;
                                            $.post('/Clients/AttachPaymentToInvoiceJSON', {
                                                clientID: '<%= Model.ClientID %>',
                                                invoiceID: String(invoiceID), 
                                                paymentIDs: String(attachPayments.PaymentIDs.join("~*~")),
                                                paymentDates: String(attachPayments.PaymentDates.join("~*~")),
                                                paymentQBs: String(attachPayments.PaymentQBs.join("~*~")),
                                                amountsReceived: String(attachPayments.AmountsReceived.join("~*~"))
                                            }, function(data) {
                                                if (data.success) {
                                                    if (data.accountActivity != null &&
                                                        data.accountActivity.accountActivityRows != null) 
                                                    {  
                                                        for (var ix = 0; ix < data.accountActivity.accountActivityRows.length; ix++) 
                                                        {
                                                            var myrow = data.accountActivity.accountActivityRows[ix];
                                                            if (myrow.PaymentID != null &&
                                                                String(myrow.PaymentID) != "" &&
                                                                $(".hidPaymentID[value='" + String(myrow.PaymentID) + "']").length > 0)
                                                            {
                                                                var td = $(".hidPaymentID[value='" + String(myrow.PaymentID) + "']").parent().first();
                                                                $(td).find(".hidInvoiceNumber").val(String(myrow.InvoiceNumber));
                                                                $(td).find(".hidInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidPaymentList").val(String(myrow.PaymentList));
                                                                $(td).find(".hidPaymentDateList").val(String(myrow.PaymentDateList));
                                                                $(td).find(".hidAmountReceivedList").val(String(myrow.AmountReceivedList));
                                                                $(td).find(".hidPQBTransactionIDList").val(String(myrow.PQBTransactionIDList));
                                                                $(td).find(".hidItpQBTransactionIDList").val(String(myrow.ItpQBTransactionIDList));
                                                                $(td).find(".hidInvoiceList").val(String(myrow.InvoiceList));
                                                                $(td).find(".hidInvoiceDateList").val(String(myrow.InvoiceDateList));
                                                                $(td).find(".hidPaymentSpentAmountList").val(String(myrow.PaymentSpentAmountList));
                                                                $(td).find(".hidIQBTransactionIDList").val(String(myrow.IQBTransactionIDList));
                                                                $(td).find(".hidPtiQBTransactionIDList").val(String(myrow.PtiQBTransactionIDList));
                                                                $(td).find(".hidInvoiceNumberList").val(String(myrow.InvoiceNumberList));
                                                                $(td).find(".hidTotalAmountSpent").val(String(myrow.TotalAmountSpent));
                                                                $(td).find(".hidTotalAmountReceived").val(String(myrow.TotalAmountReceived));
                                                                $(td).find(".hidDialogInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidDialogPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidDialogAmount").val(String(myrow.Amount));
                                                            }
                                                            if (myrow.InvoiceID != null &&
                                                                String(myrow.InvoiceID) != "" &&
                                                                $(".hidInvoiceID[value='" + String(myrow.InvoiceID) + "']").length > 0)
                                                            {
                                                                var td = $(".hidInvoiceID[value='" + String(myrow.InvoiceID) + "']").parent().first();
                                                                $(td).find(".hidInvoiceNumber").val(String(myrow.InvoiceNumber));
                                                                $(td).find(".hidInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidPaymentList").val(String(myrow.PaymentList));
                                                                $(td).find(".hidPaymentDateList").val(String(myrow.PaymentDateList));
                                                                $(td).find(".hidAmountReceivedList").val(String(myrow.AmountReceivedList));
                                                                $(td).find(".hidPQBTransactionIDList").val(String(myrow.PQBTransactionIDList));
                                                                $(td).find(".hidItpQBTransactionIDList").val(String(myrow.ItpQBTransactionIDList));
                                                                $(td).find(".hidInvoiceList").val(String(myrow.InvoiceList));
                                                                $(td).find(".hidInvoiceDateList").val(String(myrow.InvoiceDateList));
                                                                $(td).find(".hidPaymentSpentAmountList").val(String(myrow.PaymentSpentAmountList));
                                                                $(td).find(".hidIQBTransactionIDList").val(String(myrow.IQBTransactionIDList));
                                                                $(td).find(".hidPtiQBTransactionIDList").val(String(myrow.PtiQBTransactionIDList));
                                                                $(td).find(".hidInvoiceNumberList").val(String(myrow.InvoiceNumberList));
                                                                $(td).find(".hidTotalAmountSpent").val(String(myrow.TotalAmountSpent));
                                                                $(td).find(".hidTotalAmountReceived").val(String(myrow.TotalAmountReceived));
                                                                $(td).find(".hidDialogInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidDialogPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidDialogAmount").val(String(myrow.Amount));
                                                            }
                                                        }
                                                    }
                                                    alert('Success.');
                                                    $(trackAttachPayment[data.invoiceID]).dialog("close");
                                                }
                                                else {
                                                    alert('Failed: ' + String(data.message));
                                                }
                                            });
                                        }
                                        else {
                                            $(this).dialog("close");
                                        }
                                    },
                                    "Add Payment": function() {
                                        alert("Add Payment not implemented yet.");
                                    },
                                    "Attach Payment": function() {
                                        var invoiceID = Number($(this).find('.hidDialogInvoiceID').first().val());                        
                                        var rowInfo = "<tr>\r\n" +
                                                      "<td style='text-align:center'><img src='/Content/images/add.png'></td>" +
                                                      "<td style='text-align:left'><input type='text' class='inputNewPaymentID myNewPaymentID'></td>" +
                                                      "<td style='text-align:right'><input type='text' class='inputNewPaymentDate myDates myNewPaymentDate'></td>" +
                                                      "<td style='text-align:left'><input type='text' class='inputNewPaymentQB myNewPaymentQB'></td>" +
                                                      "<td style='text-align:right'><input type='text' class='inputNewAmountReceived myNewPaymentAmountReceived'></td>" +
                                                      "</tr>\r\n";
                                        $(this).find('.trFooterSum').first().before(rowInfo);

                                        $('.myDates').datepicker();
                                        $('.myDates').removeClass('myDates');
                       
                                        $('.myNewPaymentID').autocomplete({
                                            minLength: 1,
                                            select: function(event, ui) {
                                                if (event.target == this) {
                                                    var tr = $(this).parent().parent().first();
                                                    var dt = new Date(parseInt(ui.item.fullObject.Date.substr(6)));
                                                    var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());                                
                                                    $(tr).find(".inputNewPaymentID").val(String(ui.item.fullObject.PaymentID));
                                                    $(tr).find(".inputNewPaymentDate").val(String(dString));
                                                    $(tr).find(".inputNewPaymentQB").val(String(ui.item.fullObject.QBTransactionID));
                                                    $(tr).find(".inputNewAmountReceived").val(String(ui.item.fullObject.TotalAmount));
                                                    return true;
                                                }
                                            },
                                            source: function(request, response) {
                                                var term = request.term;
                                                if (term in newPaymentIDCache) {
                                                    response(newPaymentIDCache[term]);
                                                    return;
                                                }
                                                $.post("/Clients/PaymentToInvoiceSearchByIDJSON",{ clientID: '<%= Model.ClientID %>', searchTerm: term }, function(data, status, xhr) {
                                                    var labelValues = new Array();
                                                    if (data != null &&
                                                        data.results != null) 
                                                    {
                                                        for(var iv = 0; iv < data.results.length; iv++) 
                                                        {
                                                            var dt = new Date(parseInt(data.results[iv].Date.substr(6)));
                                                            var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());
                                                            var label = String(data.results[iv].PaymentID) + " " + String(dString) + " " + String(data.results[iv].QBTransactionID) + " " + String(data.results[iv].ContactName) + " $" + String(data.results[iv].TotalAmount);
                                                            labelValues.push({ label: String(label),
                                                                value: String(data.results[iv].PaymentID),
                                                                fullObject: data.results[iv] });
                                                        }
                                                    }
                                                    newPaymentIDCache[term] = labelValues;
                                                    response(labelValues);
                                                });                            
                                            }
                                        });

                                        $('.myNewPaymentID').removeClass('myNewPaymentID');

                                        $('.myNewPaymentDate').autocomplete({
                                            minLength: 1,
                                            select: function(event, ui) {
                                                if (event.target == this) {
                                                    var tr = $(this).parent().parent().first();
                                                    var dt = new Date(parseInt(ui.item.fullObject.Date.substr(6)));
                                                    var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());                                
                                                    $(tr).find(".inputNewPaymentID").val(String(ui.item.fullObject.PaymentID));
                                                    $(tr).find(".inputNewPaymentDate").val(String(dString));
                                                    $(tr).find(".inputNewPaymentQB").val(String(ui.item.fullObject.QBTransactionID));
                                                    $(tr).find(".inputNewAmountReceived").val(String(ui.item.fullObject.TotalAmount));
                                                    return true;
                                                }
                                            },
                                            source: function(request, response) {
                                                var term = request.term;
                                                if (term in newPaymentDateCache) {
                                                    response(newPaymentDateCache[term]);
                                                    return;
                                                }
                                                $.post("/Clients/PaymentToInvoiceSearchByDateJSON",{ clientID: '<%= Model.ClientID %>', searchTerm: term }, function(data, status, xhr) {
                                                    var labelValues = new Array();
                                                    if (data != null &&
                                                        data.results != null) 
                                                    {
                                                        for(var iv = 0; iv < data.results.length; iv++) 
                                                        {
                                                            var dt = new Date(parseInt(data.results[iv].Date.substr(6)));
                                                            var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());
                                                            var label = String(data.results[iv].PaymentID) + " " + String(dString) + " " + String(data.results[iv].QBTransactionID) + " " + String(data.results[iv].ContactName) + " $" + String(data.results[iv].TotalAmount);
                                                            labelValues.push({ label: String(label),
                                                                value: String(dString),
                                                                fullObject: data.results[iv] });
                                                        }
                                                    }
                                                    newPaymentDateCache[term] = labelValues;
                                                    response(labelValues);
                                                });
                                            }                                                
                                        });
                        
                                        $('.myNewPaymentDate').removeClass('myNewPaymentDate');

                                        $('.myNewPaymentQB').autocomplete({
                                            minLength: 1,
                                            select: function(event, ui) {
                                                if (event.target == this) {
                                                    var tr = $(this).parent().parent().first();
                                                    var dt = new Date(parseInt(ui.item.fullObject.Date.substr(6)));
                                                    var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());                                
                                                    $(tr).find(".inputNewPaymentID").val(String(ui.item.fullObject.PaymentID));
                                                    $(tr).find(".inputNewPaymentDate").val(String(dString));
                                                    $(tr).find(".inputNewPaymentQB").val(String(ui.item.fullObject.QBTransactionID));
                                                    $(tr).find(".inputNewAmountReceived").val(String(ui.item.fullObject.TotalAmount));
                                                    return true;
                                                }
                                            },
                                            source: function(request, response) {
                                                var term = request.term;
                                                if (term in newPaymentQBCache) {
                                                    response(newPaymentQBCache[term]);
                                                    return;
                                                }
                                                $.post("/Clients/PaymentToInvoiceSearchByQBJSON",{ clientID: '<%= Model.ClientID %>', searchTerm: term }, function(data, status, xhr) {
                                                    var labelValues = new Array();
                                                    if (data != null &&
                                                        data.results != null) 
                                                    {
                                                        for(var iv = 0; iv < data.results.length; iv++) 
                                                        {
                                                            var dt = new Date(parseInt(data.results[iv].Date.substr(6)));
                                                            var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());
                                                            var label = String(data.results[iv].PaymentID) + " " + String(dString) + " " + String(data.results[iv].QBTransactionID) + " " + String(data.results[iv].ContactName) + " $" + String(data.results[iv].TotalAmount);
                                                            labelValues.push({ label: String(label),
                                                                value: String(data.results[iv].QBTransactionID),
                                                                fullObject: data.results[iv] });
                                                        }
                                                    }
                                                    newPaymentQBCache[term] = labelValues;
                                                    response(labelValues);
                                                });
                                            }
                                        });
                        
                                        $('.myNewPaymentQB').removeClass('myNewPaymentQB');
                        
                                        $('.myNewPaymentAmountReceived').autocomplete({
                                            minLength: 1,
                                            select: function(event, ui) {
                                                if (event.target == this) {
                                                    var tr = $(this).parent().parent().first();
                                                    var dt = new Date(parseInt(ui.item.fullObject.Date.substr(6)));
                                                    var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());                                
                                                    $(tr).find(".inputNewPaymentID").val(String(ui.item.fullObject.PaymentID));
                                                    $(tr).find(".inputNewPaymentDate").val(String(dString));
                                                    $(tr).find(".inputNewPaymentQB").val(String(ui.item.fullObject.QBTransactionID));
                                                    $(tr).find(".inputNewAmountReceived").val(String(ui.item.fullObject.TotalAmount));
                                                    return true;
                                                }
                                            },
                                            source: function(request, response) {
                                                var term = request.term;
                                                if (term in newPaymentAmountReceivedCache) {
                                                    response(newPaymentAmountReceivedCache[term]);
                                                    return;
                                                }
                                                $.post("/Clients/PaymentToInvoiceSearchByAmountJSON",{ clientID: '<%= Model.ClientID %>', searchTerm: term }, function(data, status, xhr) {
                                                    var labelValues = new Array();
                                                    if (data != null &&
                                                        data.results != null) 
                                                    {
                                                        for(var iv = 0; iv < data.results.length; iv++) 
                                                        {
                                                            var dt = new Date(parseInt(data.results[iv].Date.substr(6)));
                                                            var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());
                                                            var label = String(data.results[iv].PaymentID) + " " + String(dString) + " " + String(data.results[iv].QBTransactionID) + " " + String(data.results[iv].ContactName) + " $" + String(data.results[iv].TotalAmount);
                                                            labelValues.push({ label: String(label),
                                                                value: String(data.results[iv].TotalAmount),
                                                                fullObject: data.results[iv] });
                                                        }
                                                    }
                                                    newPaymentAmountReceivedCache[term] = labelValues;
                                                    response(labelValues);                                                                                
                                                });
                                            }                                                                        
                                        });

                                        $('.myNewPaymentAmountReceived').removeClass('myNewPaymentAmountReceived');

                                    }
                                }
                            });
                        }
                        else if ($(lineItemDialogArray[i]).hasClass('ui-dialog-content') == false &&
                                 $(lineItemDialogArray[i]).hasClass("PaymentType"))
                        {            
                            $(lineItemDialogArray[i]).dialog({
                                height: "auto",
                                width: "auto",
                                autoOpen: false,
                                modal: false,
                                open: function(event,ui) {
                                    $('.aRemoveInvoiceFromPayment').unbind();
                                    $('.aRemoveInvoiceFromPayment').click(function() {                        
                                        var invoiceID = Number($(this).parent().find('.hidActionInvoiceID').val());                        
                                        var invoiceNumber = String($.trim($(this).parent().parent().find('.tdInvoiceNumber').text()));
                                        var paymentID = Number($(this).parentsUntil('.lineItemDialog').last().parent().find('.hidDialogPaymentID').val());
                                        if (confirm("Are you sure that you want to remove this InvoiceNumber: " + invoiceNumber + " from the PaymentID: " + String(paymentID) + "?")) 
                                        {
                                            $.post('/Clients/RemovePaymentFromInvoiceJSON', {
                                                clientID: '<%= Model.ClientID %>',
                                                paymentID: String(paymentID), 
                                                invoiceID: String(invoiceID),
                                                invoiceNumber: String(invoiceNumber)
                                            }, function(data) {
                                                if (data.success) {
                                                    alert('InvoiceNumber ' + String(data.invoiceNumber) + ' has been removed from the PaymentID ' + String(data.paymentID) + '.');
                                                    if (data.accountActivity != null &&
                                                        data.accountActivity.accountActivityRows != null) 
                                                    {                                    
                                                        for (var ix = 0; ix < data.accountActivity.accountActivityRows.length; ix++) 
                                                        {
                                                            var myrow = data.accountActivity.accountActivityRows[ix];
                                                            if (myrow.PaymentID != null &&
                                                                String(myrow.PaymentID) != "" &&
                                                                $(".hidPaymentID[value='" + String(myrow.PaymentID) + "']").length > 0)
                                                            {
                                                                var td = $(".hidPaymentID[value='" + String(myrow.PaymentID) + "']").parent().first();
                                                                $(td).find(".hidInvoiceNumber").val(String(myrow.InvoiceNumber));
                                                                $(td).find(".hidInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidPaymentList").val(String(myrow.PaymentList));
                                                                $(td).find(".hidPaymentDateList").val(String(myrow.PaymentDateList));
                                                                $(td).find(".hidAmountReceivedList").val(String(myrow.AmountReceivedList));
                                                                $(td).find(".hidPQBTransactionIDList").val(String(myrow.PQBTransactionIDList));
                                                                $(td).find(".hidItpQBTransactionIDList").val(String(myrow.ItpQBTransactionIDList));
                                                                $(td).find(".hidInvoiceList").val(String(myrow.InvoiceList));
                                                                $(td).find(".hidInvoiceDateList").val(String(myrow.InvoiceDateList));
                                                                $(td).find(".hidPaymentSpentAmountList").val(String(myrow.PaymentSpentAmountList));
                                                                $(td).find(".hidIQBTransactionIDList").val(String(myrow.IQBTransactionIDList));
                                                                $(td).find(".hidPtiQBTransactionIDList").val(String(myrow.PtiQBTransactionIDList));
                                                                $(td).find(".hidInvoiceNumberList").val(String(myrow.InvoiceNumberList));
                                                                $(td).find(".hidTotalAmountSpent").val(String(myrow.TotalAmountSpent));
                                                                $(td).find(".hidTotalAmountReceived").val(String(myrow.TotalAmountReceived));
                                                                $(td).find(".hidDialogInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidDialogPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidDialogAmount").val(String(myrow.Amount));
                                                            }
                                                            if (myrow.InvoiceID != null &&
                                                                String(myrow.InvoiceID) != "" &&
                                                                $(".hidInvoiceID[value='" + String(myrow.InvoiceID) + "']").length > 0)
                                                            {
                                                                var td = $(".hidInvoiceID[value='" + String(myrow.InvoiceID) + "']").parent().first();
                                                                $(td).find(".hidInvoiceNumber").val(String(myrow.InvoiceNumber));
                                                                $(td).find(".hidInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidPaymentList").val(String(myrow.PaymentList));
                                                                $(td).find(".hidPaymentDateList").val(String(myrow.PaymentDateList));
                                                                $(td).find(".hidAmountReceivedList").val(String(myrow.AmountReceivedList));
                                                                $(td).find(".hidPQBTransactionIDList").val(String(myrow.PQBTransactionIDList));
                                                                $(td).find(".hidItpQBTransactionIDList").val(String(myrow.ItpQBTransactionIDList));
                                                                $(td).find(".hidInvoiceList").val(String(myrow.InvoiceList));
                                                                $(td).find(".hidInvoiceDateList").val(String(myrow.InvoiceDateList));
                                                                $(td).find(".hidPaymentSpentAmountList").val(String(myrow.PaymentSpentAmountList));
                                                                $(td).find(".hidIQBTransactionIDList").val(String(myrow.IQBTransactionIDList));
                                                                $(td).find(".hidPtiQBTransactionIDList").val(String(myrow.PtiQBTransactionIDList));
                                                                $(td).find(".hidInvoiceNumberList").val(String(myrow.InvoiceNumberList));
                                                                $(td).find(".hidTotalAmountSpent").val(String(myrow.TotalAmountSpent));
                                                                $(td).find(".hidTotalAmountReceived").val(String(myrow.TotalAmountReceived));
                                                                $(td).find(".hidDialogInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidDialogPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidDialogAmount").val(String(myrow.Amount));
                                                            }
                                                        }
                                                    }
                                                }
                                                else {
                                                    alert('Failed: ' + String(data.message));
                                                }                                    
                                            });
                                        }                            
                                    });                            
                                },
                                buttons: {                                
                                    "Done": function() {                        

                                        var paymentID = String($(this).find('.hidDialogPaymentID').first().val());

                                        attachInvoices = new Object();
                                        attachInvoices.InvoiceIDs = new Array();
                                        attachInvoices.InvoiceNumbers = new Array();
                                        attachInvoices.InvoiceDates = new Array();
                                        attachInvoices.InvoiceQBs = new Array();
                                        attachInvoices.PaymentSpents = new Array();

                                        if ($(this).find('.hidNewInvoiceID').length > 0) {  

                                            $(this).find('.hidNewInvoiceID').each(function(ix, element) {
                                                attachInvoices.InvoiceIDs.push(String($(element).val()));
                                            });
                                            $(this).find('.inputNewInvoiceNumber').each(function(ix, element) {
                                                attachInvoices.InvoiceNumbers.push(String($(element).val()));
                                            });
                                            $(this).find('.inputNewInvoiceDate').each(function(ix, element) {
                                                attachInvoices.InvoiceDates.push(String($(element).val()));
                                            });
                                            $(this).find('.inputNewInvoiceQB').each(function(ix, element) {
                                                attachInvoices.InvoiceQBs.push(String($(element).val()));
                                            });
                                            $(this).find('.inputNewPaymentSpent').each(function(ix, element) {
                                                attachInvoices.PaymentSpents.push(String($(element).val()));
                                            });

                                            var deleteWholeBlankLines = new Array();

                                            for (var iy = 0; iy < attachInvoices.InvoiceIDs.length; iy++) 
                                            {
                                                var checkOne = String($.trim(attachInvoices.InvoiceIDs[iy]));
                                                var checkTwo = String($.trim(attachInvoices.InvoiceNumbers[iy]));
                                                var checkThree = String($.trim(attachInvoices.InvoiceDates[iy]));
                                                var checkFour = String($.trim(attachInvoices.InvoiceQBs[iy]));
                                                var checkFive = String($.trim(attachInvoices.PaymentSpents[iy]));

                                                if (checkOne == "" &&
                                                    checkTwo == "" &&
                                                    checkThree == "" &&
                                                    checkFour == "" &&
                                                    checkFive == "") 
                                                {
                                                    deleteWholeBlankLines.push(iy);
                                                }
                                            }

                                            for (var iy = deleteWholeBlankLines.length - 1; iy >= 0; iy--) 
                                            {
                                                attachInvoices.InvoiceIDs.splice(deleteWholeBlankLines[iy],1);
                                                attachInvoices.InvoiceNumbers.splice(deleteWholeBlankLines[iy],1);
                                                attachInvoices.InvoiceDates.splice(deleteWholeBlankLines[iy],1);
                                                attachInvoices.InvoiceQBs.splice(deleteWholeBlankLines[iy],1);
                                                attachInvoices.PaymentSpents.splice(deleteWholeBlankLines[iy],1);
                                            }

                                            if (attachInvoices.InvoiceIDs.length <= 0 ) {
                                                $(this).dialog("close");
                                                return;
                                            }

                                            trackAttachInvoice[paymentID] = this;
                                            $.post('/Clients/AttachInvoiceToPaymentJSON', {
                                                clientID: '<%= Model.ClientID %>',
                                                paymentID: String(paymentID), 
                                                invoiceIDs: String(attachInvoices.InvoiceIDs.join("~*~")),
                                                invoiceNumbers: String(attachInvoices.InvoiceNumbers.join("~*~")),
                                                invoiceDates: String(attachInvoices.InvoiceDates.join("~*~")),
                                                invoiceQBs: String(attachInvoices.InvoiceQBs.join("~*~")),
                                                paymentSpents: String(attachInvoices.PaymentSpents.join("~*~"))
                                            }, function(data) {
                                                if (data.success) {
                                                    if (data.accountActivity != null &&
                                                        data.accountActivity.accountActivityRows != null) 
                                                    { 
                                                        for (var ix = 0; ix < data.accountActivity.accountActivityRows.length; ix++) 
                                                        {
                                                            var myrow = data.accountActivity.accountActivityRows[ix];
                                                            if (myrow.PaymentID != null &&
                                                                String(myrow.PaymentID) != "" &&
                                                                $(".hidPaymentID[value='" + String(myrow.PaymentID) + "']").length > 0)
                                                            {
                                                                var td = $(".hidPaymentID[value='" + String(myrow.PaymentID) + "']").parent().first();
                                                                $(td).find(".hidInvoiceNumber").val(String(myrow.InvoiceNumber));
                                                                $(td).find(".hidInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidPaymentList").val(String(myrow.PaymentList));
                                                                $(td).find(".hidPaymentDateList").val(String(myrow.PaymentDateList));
                                                                $(td).find(".hidAmountReceivedList").val(String(myrow.AmountReceivedList));
                                                                $(td).find(".hidPQBTransactionIDList").val(String(myrow.PQBTransactionIDList));
                                                                $(td).find(".hidItpQBTransactionIDList").val(String(myrow.ItpQBTransactionIDList));
                                                                $(td).find(".hidInvoiceList").val(String(myrow.InvoiceList));
                                                                $(td).find(".hidInvoiceDateList").val(String(myrow.InvoiceDateList));
                                                                $(td).find(".hidPaymentSpentAmountList").val(String(myrow.PaymentSpentAmountList));
                                                                $(td).find(".hidIQBTransactionIDList").val(String(myrow.IQBTransactionIDList));
                                                                $(td).find(".hidPtiQBTransactionIDList").val(String(myrow.PtiQBTransactionIDList));
                                                                $(td).find(".hidInvoiceNumberList").val(String(myrow.InvoiceNumberList));
                                                                $(td).find(".hidTotalAmountSpent").val(String(myrow.TotalAmountSpent));
                                                                $(td).find(".hidTotalAmountReceived").val(String(myrow.TotalAmountReceived));
                                                                $(td).find(".hidDialogInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidDialogPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidDialogAmount").val(String(myrow.Amount));
                                                            }
                                                            if (myrow.InvoiceID != null &&
                                                                String(myrow.InvoiceID) != "" &&
                                                                $(".hidInvoiceID[value='" + String(myrow.InvoiceID) + "']").length > 0)
                                                            {
                                                                var td = $(".hidInvoiceID[value='" + String(myrow.InvoiceID) + "']").parent().first();
                                                                $(td).find(".hidInvoiceNumber").val(String(myrow.InvoiceNumber));
                                                                $(td).find(".hidInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidPaymentList").val(String(myrow.PaymentList));
                                                                $(td).find(".hidPaymentDateList").val(String(myrow.PaymentDateList));
                                                                $(td).find(".hidAmountReceivedList").val(String(myrow.AmountReceivedList));
                                                                $(td).find(".hidPQBTransactionIDList").val(String(myrow.PQBTransactionIDList));
                                                                $(td).find(".hidItpQBTransactionIDList").val(String(myrow.ItpQBTransactionIDList));
                                                                $(td).find(".hidInvoiceList").val(String(myrow.InvoiceList));
                                                                $(td).find(".hidInvoiceDateList").val(String(myrow.InvoiceDateList));
                                                                $(td).find(".hidPaymentSpentAmountList").val(String(myrow.PaymentSpentAmountList));
                                                                $(td).find(".hidIQBTransactionIDList").val(String(myrow.IQBTransactionIDList));
                                                                $(td).find(".hidPtiQBTransactionIDList").val(String(myrow.PtiQBTransactionIDList));
                                                                $(td).find(".hidInvoiceNumberList").val(String(myrow.InvoiceNumberList));
                                                                $(td).find(".hidTotalAmountSpent").val(String(myrow.TotalAmountSpent));
                                                                $(td).find(".hidTotalAmountReceived").val(String(myrow.TotalAmountReceived));
                                                                $(td).find(".hidDialogInvoiceID").val(String(myrow.InvoiceID));
                                                                $(td).find(".hidDialogPaymentID").val(String(myrow.PaymentID));
                                                                $(td).find(".hidDialogAmount").val(String(myrow.Amount));
                                                            }
                                                        }
                                                    }
                                                    alert('Success.');
                                                    $(trackAttachInvoice[data.paymentID]).dialog("close");
                                                }
                                                else {
                                                    alert('Failed: ' + String(data.message));
                                                }
                                            });
                                        }
                                        else {
                                            $(this).dialog("close");
                                        }
                                    },
                                    "Delete Payment": function() {                                                
                                        var paymentID = Number($(this).find('.hidDialogPaymentID').first().val());
                                        if (confirm("Are you sure that you want to remove this PaymentID: " + String(paymentID) + " completely?"))                                                 
                                        {
                                            trackDeletePayment[paymentID] = this;
                                            $.post('/Clients/RemovePaymentJSON', {
                                                clientID: '<%= Model.ClientID %>',
                                                paymentID: String(paymentID)
                                            }, function(data) {
                                                if (data.success) {
                                                    alert('Success.');
                                                    $(trackDeletePayment[data.paymentID]).dialog("close");
                                                }
                                                else {
                                                    alert('Failed: ' + String(data.message));
                                                }
                                            });
                                        }
                                    },
                                    "Attach Invoice": function() {
                                        var paymentID = Number($(this).find('.hidDialogPaymentID').first().val());
                                        var rowInfo = "<tr>\r\n" +
                                            "<td style='text-align:center'><input type='hidden' class='hidNewInvoiceID'><img src='/Content/images/add.png'></td>" +
                                            "<td style='text-align:left'><input type='text' class='inputNewInvoiceNumber myNewInvoiceNumber'></td>" +
                                            "<td style='text-align:right'><input type='text' class='inputNewInvoiceDate myDates myNewInvoiceDate'></td>" +
                                            "<td style='text-align:left'><input type='text' class='inputNewInvoiceQB myNewInvoiceQB'></td>" +
                                            "<td style='text-align:right'><input type='text' class='inputNewPaymentSpent myNewPaymentSpent'></td>" +
                                            "</tr>\r\n";
                                        $(this).find('.trFooterSum').first().before(rowInfo);
                                    
                                        $('.myDates').datepicker();
                                        $('.myDates').removeClass('myDates');
                                    
                                        $('.myNewInvoiceNumber').autocomplete({
                                            minLength: 1,
                                            select: function(event, ui) {
                                                if (event.target == this) {
                                                    var tr = $(this).parent().parent().first();
                                                    var dt = new Date(parseInt(ui.item.fullObject.InvoiceDate.substr(6)));
                                                    var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());
                                                    $(tr).find(".inputNewInvoiceNumber").val(String(ui.item.fullObject.InvoiceNumber));
                                                    $(tr).find(".inputNewInvoiceDate").val(String(dString));
                                                    $(tr).find(".inputNewInvoiceQB").val(String(ui.item.fullObject.QBTransactionID));
                                                    $(tr).find(".inputNewPaymentSpent").val(String(ui.item.fullObject.Amount));
                                                    $(tr).find(".hidNewInvoiceID").val(String(ui.item.fullObject.InvoiceID));
                                                    return true;
                                                }
                                            },
                                            source: function(request, response) {
                                                var term = request.term;
                                                if (term in newInvoiceNumberCache) {
                                                    response(newInvoiceNumberCache[term]);
                                                    return;
                                                }
                                                $.post("/Clients/InvoiceToPaymentSearchByInvoiceNumberJSON",{ clientID: '<%= Model.ClientID %>', searchTerm: term }, function(data, status, xhr) {
                                                    var labelValues = new Array();
                                                    if (data != null &&
                                                        data.results != null) 
                                                    {
                                                        for(var iv = 0; iv < data.results.length; iv++) 
                                                        {
                                                            var dt = new Date(parseInt(data.results[iv].InvoiceDate.substr(6)));
                                                            var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());
                                                            var label = String(data.results[iv].InvoiceNumber) + " " + String(dString) + " " + String(data.results[iv].QBTransactionID) + " " + " $" + String(data.results[iv].Amount);
                                                            labelValues.push({ label: String(label),
                                                                value: String(data.results[iv].InvoiceNumber),
                                                                fullObject: data.results[iv] });
                                                        }
                                                    }
                                                    newInvoiceNumberCache[term] = labelValues;
                                                    response(labelValues);
                                                });
                                            }
                                        });
                        
                                        $('.myNewInvoiceNumber').removeClass('myNewInvoiceNumber');
                        
                                        $('.myNewInvoiceDate').autocomplete({
                                            minLength: 1,
                                            select: function(event, ui) {
                                                if (event.target == this) {
                                                    var tr = $(this).parent().parent().first();
                                                    var dt = new Date(parseInt(ui.item.fullObject.InvoiceDate.substr(6)));
                                                    var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());
                                                    $(tr).find(".inputNewInvoiceNumber").val(String(ui.item.fullObject.InvoiceNumber));
                                                    $(tr).find(".inputNewInvoiceDate").val(String(dString));
                                                    $(tr).find(".inputNewInvoiceQB").val(String(ui.item.fullObject.QBTransactionID));
                                                    $(tr).find(".inputNewPaymentSpent").val(String(ui.item.fullObject.Amount));
                                                    $(tr).find(".hidNewInvoiceID").val(String(ui.item.fullObject.InvoiceID));
                                                    return true;
                                                }
                                            },
                                            source: function(request, response) {
                                                var term = request.term;
                                                if (term in newInvoiceDateCache) {
                                                    response(newInvoiceDateCache[term]);
                                                    return;
                                                }
                                                $.post("/Clients/InvoiceToPaymentSearchByDateJSON",{ clientID: '<%= Model.ClientID %>', searchTerm: term }, function(data, status, xhr) {
                                                    var labelValues = new Array();
                                                    if (data != null &&
                                                        data.results != null) 
                                                    {
                                                        for(var iv = 0; iv < data.results.length; iv++) 
                                                        {
                                                            var dt = new Date(parseInt(data.results[iv].InvoiceDate.substr(6)));
                                                            var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());
                                                            var label = String(data.results[iv].InvoiceNumber) + " " + String(dString) + " " + String(data.results[iv].QBTransactionID) + " " + " $" + String(data.results[iv].Amount);
                                                            labelValues.push({ label: String(label),
                                                                value: String(dString),
                                                                fullObject: data.results[iv] });
                                                        }
                                                    }
                                                    newInvoiceDateCache[term] = labelValues;
                                                    response(labelValues);
                                                });
                                            }                                                
                                        });
                        
                                        $('.myNewInvoiceDate').removeClass('myNewInvoiceDate');
                        
                                        $('.myNewInvoiceQB').autocomplete({
                                            minLength: 1,
                                            select: function(event, ui) {
                                                if (event.target == this) {
                                                    var tr = $(this).parent().parent().first();
                                                    var dt = new Date(parseInt(ui.item.fullObject.InvoiceDate.substr(6)));
                                                    var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());
                                                    $(tr).find(".inputNewInvoiceNumber").val(String(ui.item.fullObject.InvoiceNumber));
                                                    $(tr).find(".inputNewInvoiceDate").val(String(dString));
                                                    $(tr).find(".inputNewInvoiceQB").val(String(ui.item.fullObject.QBTransactionID));
                                                    $(tr).find(".inputNewPaymentSpent").val(String(ui.item.fullObject.Amount));
                                                    $(tr).find(".hidNewInvoiceID").val(String(ui.item.fullObject.InvoiceID));
                                                    return true;
                                                }
                                            },
                                            source: function(request, response) {
                                                var term = request.term;
                                                if (term in newInvoiceQBCache) {
                                                    response(newInvoiceQBCache[term]);
                                                    return;
                                                }
                                                $.post("/Clients/InvoiceToPaymentSearchByQBJSON",{ clientID: '<%= Model.ClientID %>', searchTerm: term }, function(data, status, xhr) {
                                                    var labelValues = new Array();
                                                    if (data != null &&
                                                        data.results != null) 
                                                    {
                                                        for(var iv = 0; iv < data.results.length; iv++) 
                                                        {
                                                            var dt = new Date(parseInt(data.results[iv].InvoiceDate.substr(6)));
                                                            var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());
                                                            var label = String(data.results[iv].InvoiceNumber) + " " + String(dString) + " " + String(data.results[iv].QBTransactionID) + " " + " $" + String(data.results[iv].Amount);
                                                            labelValues.push({ label: String(label),
                                                                value: String(data.results[iv].QBTransactionID),
                                                                fullObject: data.results[iv] });
                                                        }
                                                    }
                                                    newInvoiceQBCache[term] = labelValues;
                                                    response(labelValues);
                                                });
                                            }
                                        });
                        
                                        $('.myNewInvoiceQB').removeClass('myNewInvoiceQB');
                        
                                        $('.myNewPaymentSpent').autocomplete({
                                            minLength: 1,
                                            select: function(event, ui) {
                                                if (event.target == this) {
                                                    var tr = $(this).parent().parent().first();
                                                    var dt = new Date(parseInt(ui.item.fullObject.InvoiceDate.substr(6)));
                                                    var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());
                                                    $(tr).find(".inputNewInvoiceNumber").val(String(ui.item.fullObject.InvoiceNumber));
                                                    $(tr).find(".inputNewInvoiceDate").val(String(dString));
                                                    $(tr).find(".inputNewInvoiceQB").val(String(ui.item.fullObject.QBTransactionID));
                                                    $(tr).find(".inputNewPaymentSpent").val(String(ui.item.fullObject.Amount));
                                                    $(tr).find(".hidNewInvoiceID").val(String(ui.item.fullObject.InvoiceID));
                                                    return true;
                                                }
                                            },
                                            source: function(request, response) {
                                                var term = request.term;
                                                if (term in newInvoicePaymentSpentCache) {
                                                    response(newInvoicePaymentSpentCache[term]);
                                                    return;
                                                }
                                                $.post("/Clients/InvoiceToPaymentSearchByAmountJSON",{ clientID: '<%= Model.ClientID %>', searchTerm: term }, function(data, status, xhr) {
                                                    var labelValues = new Array();
                                                    if (data != null &&
                                                        data.results != null) 
                                                    {
                                                        for(var iv = 0; iv < data.results.length; iv++) 
                                                        {
                                                            var dt = new Date(parseInt(data.results[iv].InvoiceDate.substr(6)));
                                                            var dString = String(dt.getMonth() + 1) + "/" + String(dt.getDate()) + "/" + String(dt.getFullYear());
                                                            var label = String(data.results[iv].InvoiceNumber) + " " + String(dString) + " " + String(data.results[iv].QBTransactionID) + " " + " $" + String(data.results[iv].Amount);
                                                            labelValues.push({ label: String(label),
                                                                value: String(data.results[iv].Amount),
                                                                fullObject: data.results[iv] });
                                                        }
                                                    }
                                                    newInvoicePaymentSpentCache[term] = labelValues;
                                                    response(labelValues);
                                                });
                                            }
                                        });

                                        $('.myNewPaymentSpent').removeClass('myNewPaymentSpent');

                                    }
                                }
                            });
                        }
    
                        if (!$(lineItemDialogArray[i]).dialog("isOpen")) {                                            
                            var invoiceID = String($(lineItemDialogArray[i]).find('.hidDialogInvoiceID').val());
                            var paymentID = String($(lineItemDialogArray[i]).find('.hidDialogPaymentID').val());
                            var amount = String($(lineItemDialogArray[i]).find('.hidDialogAmount').val()); 
                            if ($.trim(invoiceID) != "") {                    
                                var diaIndex = Number($(".hidInvoiceID").index($(".hidInvoiceID[value='" + String(invoiceID) + "']")));
                                var paymentList = String($($(".hidPaymentList")[diaIndex]).val());
                                var paymentDateList = String($($('.hidPaymentDateList')[diaIndex]).val());
                                var amountReceivedList = String($($('.hidAmountReceivedList')[diaIndex]).val());
                                var pQBTransactionIDList = String($($('.hidPQBTransactionIDList')[diaIndex]).val());
                                var invoiceNumber = $($('.hidInvoiceNumber')[diaIndex]).val();            
                                var totalAmountReceived = $($('.hidTotalAmountReceived')[diaIndex]).val();                        
                                var paymentArray = paymentList.split(",");
                                var paymentDateArray = paymentDateList.split(",");
                                var amountReceivedArray = amountReceivedList.split(",");
                                var pQBTransactionIDArray = pQBTransactionIDList.split(",");
                                var rowInfo = "<table style='width:100%' class='tablePayments table table-striped table-bordered'>\r\n" +
                                    "<thead>\r\n" +
                              "<tr>\r\n" +
                              "<th colspan='5' style='text-align:left'>InvoiceNumber: <span class='spanInvoiceNumber'>" + String(invoiceNumber) + "</span> Amount: " + String(amount) + "</th>\r\n" +
                              "</tr>\r\n" + 
                              "<tr>\r\n" +
                              "<th style='text-align:center'>Action</th><th style='text-align:left'>PaymentID</th><th style='text-align:right'>Payment Date</th><th style='text-align:left'>QB</th><th style='text-align:right'>Amount Applied</th>\r\n" +
                              "</tr>\r\n" + 
                              "</thead>\r\n" +
                              "<tbody>";
                                if ((paymentArray.length == 1 &&
                                    String(paymentArray[0]) != "") ||
                                    paymentArray.length > 1) {
                                    for (var ix = 0; ix < paymentArray.length; ix++) 
                                    {
                                        rowInfo = rowInfo + "<tr>\r\n" +
                                            "<td style='text-align:center'><input type='hidden' class='hidActionPaymentID' value='" + String(paymentArray[ix]).replace("\"","").replace("\"","") + "'><a class='aRemovePaymentFromInvoice' href='javascript:void(0);'><img src='/Content/images/delete.png'></a></td>" +
                                            "<td class='tdPaymentID' style='text-align:left'>" + String(paymentArray[ix]).replace("\"","").replace("\"","") + "</td>" +
                                            "<td style='text-align:right'>" + String(paymentDateArray[ix]).replace("\"","").replace("\"","") + "</td>" +
                                            "<td style='text-align:left'>" + String(pQBTransactionIDArray[ix]).replace("\"","").replace("\"","") + "</td>" +
                                            "<td style='text-align:right'>" + String(amountReceivedArray[ix]).replace("\"","").replace("\"","") + "</td>" +
                                            "</tr>\r\n";
                                    }
                                }
                                rowInfo = rowInfo + "<tr class='trFooterSum'>\r\n" +
                                    "<th colspan='5' style='text-align:right'>Total Amount Applied: " + totalAmountReceived + "</th>\r\n" +
                                    "</tr>\r\n" + 
                                    "</tbody>\r\n" +
                                    "</table>\r\n";
                                $(lineItemDialogArray[i]).find('.spanData').html(rowInfo);
                            }
                            else if ($.trim(paymentID) != "") {
                                var diaIndex = Number($(".hidPaymentID").index($(".hidPaymentID[value='" + String(paymentID) + "']")));
                                var invoiceList = String($($(".hidInvoiceList")[diaIndex]).val());
                                var invoiceDateList = String($($('.hidInvoiceDateList')[diaIndex]).val());
                                var paymentSpentAmountList = String($($('.hidPaymentSpentAmountList')[diaIndex]).val());
                                var iQBTransactionIDList = String($($('.hidIQBTransactionIDList')[diaIndex]).val());
                                var invoiceNumberList = String($($('.hidInvoiceNumberList')[diaIndex]).val()); 
                                var totalAmountSpent = $($('.hidTotalAmountSpent')[diaIndex]).val();                            
                                var invoiceArray = invoiceList.split(",");                            
                                var invoiceDateArray = invoiceDateList.split(",");                            
                                var paymentSpentAmountArray = paymentSpentAmountList.split(",");                            
                                var iQBTransactionIDArray = iQBTransactionIDList.split(",");                            
                                var invoiceNumberArray = invoiceNumberList.split(",");                            
                                var rowInfo = "<table style='width:100%' class='tableInvoices table table-striped table-bordered'>\r\n" +
                                    "<thead>\r\n" +
                              "<tr>\r\n" +
                              "<th colspan='5' style='text-align:left'>PaymentID: " + String(paymentID)  + " Amount: " + String(amount) + "</th>\r\n" +
                              "</tr>\r\n" + 
                              "<tr>\r\n" +
                              "<th style='text-align:center'>Action</th><th style='text-align:left'>Invoice Number</th><th style='text-align:right'>Invoice Date</th><th style='text-align:left'>QB</th><th style='text-align:right'>Payment Spent</th>\r\n" +
                              "</tr>\r\n" + 
                              "</thead>\r\n" +
                              "<tbody>";  
                                if ((invoiceArray.length == 1 &&
                                    String(invoiceArray[0]) != "") ||
                                    invoiceArray.length > 1) {
                                    for (var ix = 0; ix < invoiceArray.length; ix++)                             
                                    {
                                        rowInfo = rowInfo + "<tr>\r\n" +
                                            "<td style='text-align:center'><input type='hidden' class='hidActionInvoiceID' value='" + String(invoiceArray[ix]).replace("\"","").replace("\"","") + "'><a class='aRemoveInvoiceFromPayment' href='javascript:void(0);'><img src='/Content/images/delete.png'></a></td>" +
                                            "<td class='tdInvoiceNumber' style='text-align:left'>" + String(invoiceNumberArray[ix]).replace("\"","").replace("\"","") + "</td>" +
                                            "<td style='text-align:right'>" + String(invoiceDateArray[ix]).replace("\"","").replace("\"","") + "</td>" +
                                            "<td style='text-align:left'>" + String(iQBTransactionIDArray[ix]).replace("\"","").replace("\"","") + "</td>" +
                                            "<td style='text-align:right'>" + String(paymentSpentAmountArray[ix]).replace("\"","").replace("\"","") + "</td>" +
                                            "</tr>\r\n";                            
                                    }
                                }
                                rowInfo = rowInfo + "<tr class='trFooterSum'>\r\n" +
                                    "<th colspan='5' style='text-align:right'>Total Amount Spent: " + totalAmountSpent + "</th>\r\n" +
                                    "</tr>\r\n" + 
                                    "</tbody>\r\n" +
                                    "</table>\r\n";
                                $(lineItemDialogArray[i]).find('.spanData').html(rowInfo);
                            }                   
                            $(lineItemDialogArray[i]).dialog("open");                   
                        }
                        else 
                        {
                            $(lineItemDialogArray[i]).dialog("close");
                            $(lineItemDialogArray[i]).dialog("open");
                        }
                    }
                });

            },500);

        });

        function openContactEmail(clientcontactemail) {
            alert(clientcontactemail);

        }

        function removeParent() {
            if (confirm('Are you sure you want to remove the Parent Relationship this client?')) {
                $.post('../../Clients/RemoveParentRelationshipJSON/<%= Model.ClientID.ToString() %>', {}, function(data) {
                    if (data.success) {
                        $('#spnParent').hide();
                        $('#Parent').hide();
                        $('#cnclParent').hide();
                        $('#lnkParent').show();
                        $('#rmvParent').hide();
                        $('#sepParent').hide();
                        $('#ParentClientID').val(0);

                        reloadPage();
                    }
                }, 'json');
            }
        }
    
        function showChangeClient() {
            $('#spnParent').hide();
            $('#Parent').show();
            $('#cnclParent').show();
            $('#lnkParent').hide();
            $('#rmvParent').hide();
            $('#sepParent').hide();
            UpdateClientsDropdownItems();
        }

        function onChangeClient() {
            $('#ParentClientID').val($('select#Parent option:selected').val());
        }
    
        function UpdateClientsDropdownItems() {
            $('#Parent').empty();
            $('#Parent').append($('<option></option>').val(0).html('Loading...'));

            $.post("../../Clients/GetClientsForDropdownJSON/", function(data) {
                $('#Parent').empty();
                for (i = 0; i < data.rows.length; i++) {
                    $('#Parent').append($('<option></option>').val(data.rows[i].Value).html(data.rows[i].Text));
                }

                $("select#Parent option[value='" + $('#ParentClientID').val() + "']").attr('selected', 'selected');
                $('select#Parent').change(onChangeClient);
            }, 'json');
        }
            
        function saveClientInfo()
        {
            $.post('../../Clients/SaveClientInfoJSON/<%= Model.ClientID.ToString() %>', { ClientName: $('#ClientName').val(),
                Address1: $('#Address1').val(), Address2: $('#Address2').val(), City: $('#City').val(), State: $('#State').val(), Zip: $('#Zip').val(),
                ParentClientID: $('#ParentClientID').val(), BilledAsClientName: $('#BilledAsClientName').val(), Status: $('#ClientStatus').val(), BillingGroupID: $('#BillingGroupID').val(), notes: $("#billing_notes").val()
            }, function(data) {
                if (data.success) {
                    alert('Client Info has been updated!');
                    reloadPage();
                }
                else {
                    alert('UPDATE FAILED: The client was not updated. Is the name blank or is the state more than 2 characters? Please try again.');
                    reloadPage();
                }
            }, 'json');

        }
    
        function addClientInvoiceSettings()
        {
            if (confirm('Are you sure you want to configure Invoice Settings for this client?'))
            {
                $.post('../../Clients/CreateClientInvoiceSettingsJSON/<%= Model.ClientID.ToString() %>',{InvoiceTemplate: 8, 
                BillingDetailReport: 0, ClientSplitMode: 1, ApplyFinanceCharges: true, FinChargeDays: 45, FinChargePct: .015, 
                SentToCollections: false, ExcludeFromReminders: false },function(data){
                    if (data.success)
                    {
                        $('#HasInvoiceSettings_No').hide();
                        $('#HasInvoiceSettings_Yes').show();
                    
                        $('#ClientSplitMode').val(1);
                        $('#InvoiceTemplate').val(8);
                        $('#BillingDetailReport').val(0);
                        $('#ApplyFinanceCharges').attr('checked', true);
                        $('#FinChargeDays').val(45);
                        $('#FinChargePct').val(1.5);
                        $('#Collections').attr('checked', false);
                    }
                },'json');
        }
    }    
   
    function removeClientInvoiceSettings()
    {
        if (confirm('Are you sure you want to remove the Invoice Settings for this client?'))
        {
            $.post('../../Clients/RemoveClientInvoiceSettingsJSON/<%= Model.ClientID.ToString() %>', {}, function(data) {
            if (data.success) {
                $('#HasInvoiceSettings_Yes').hide();
                $('#HasInvoiceSettings_No').show();
            }
            else {
                alert('Error removing Invoice Settings for this client.  Please try again.');
                reloadPage();
            }
        }, 'json');
    }
}
    
function saveClientInvoiceSettings()
{
    $.post('../../Clients/SaveClientInvoiceSettingsJSON/<%= Model.ClientID.ToString() %>', { InvoiceTemplate: $('#InvoiceTemplate').val(),
        BillingDetailReport: $('#BillingDetailReport').val(), ClientSplitMode: $('#ClientSplitMode').val(),
        ApplyFinanceCharges: $('#ApplyFinanceCharges').is(':checked'), FinChargeDays: $('#FinChargeDays').val(), FinChargePct: $('#FinChargePct').val(),
        SentToCollections: $('#Collections').is(':checked'), ExcludeFromReminders: $('#ExcludeFromReminders').is(':checked')
    }, function(data) {
        if (data.success) {
            alert('Client Invoice Settings have been saved!');
        }
        else {
            alert('Error saving Invoice Settings changes!');
            reloadPage();
        }
    }, 'json');
}
    
function showFinCharges()
{
    if ($('#ApplyFinanceCharges').is(':checked'))
    {
        $('#FinChargeDays').removeAttr("disabled"); 
        $('#FinChargePct').removeAttr("disabled"); 
    }
    else
    {
        $('#FinChargeDays').attr("disabled", true); 
        $('#FinChargePct').attr("disabled", true);  
    }

}
    
function disableFinCharges()
{
    if ($('#Collections').is(':checked'))
    {
        $('#ApplyFinanceCharges').attr('checked', false);
        $('#ApplyFinanceCharges').attr("disabled", true);
        $('#FinChargeDays').attr("disabled", true); 
        $('#FinChargePct').attr("disabled", true);  
    }
    else
    {
        $('#ApplyFinanceCharges').removeAttr("disabled"); 

    }
}

function addClientVendor()
{

    $('#HasVendorSettings_No').hide();
    $('#HasVendorSettings_Yes').show();

}

function reloadPage() {
    location.reload(true);
}
        
    
function saveClientVendorSettings()
{
    $.post('../../Clients/SaveClientVendorSettingsJSON', { id:<%= Model.ClientID.ToString() %>, Tazworks1: $('#Vendor1').val(),
        Tazworks2: $('#Vendor2').val(),
        Debtor1: $('#Vendor3').val(),
        TransUnion: $('#Vendor4').val(),
        Experian: $('#Vendor5').val(),
        Pembrooke: $('#Vendor8').val(),
        applicantONE: $('#Vendor7').val(),
        RentTrack: $('#Vendor9').val()
    }, function(data) {
        if (data.success) {
            alert('Client Vendor Settings have been saved!');
        }
        else {
            alert('Error saving vendor changes!');
            reloadPage();
        }
    }, 'json');
}

function openInvoice(id) {
    window.open('../../Invoices/Details/' + id);
}

function pdfInvoice(id) {
    location.href('../../Invoices/PrintInvoiceToPDF/' + id);
}

function UpdateBillingGroupDropDown() {
    $('#slctBillingGroup').empty();
    $('#slctBillingGroup').append(
                          $('<option></option>').val(0).html('Loading...')
                    );

    $.post("../../Invoices/GetBillingGroupsForDropdownJSON/", function (data) {
        $('#slctBillingGroup').empty();

        $.each(data.rows, function () {
            var datatext = null;

            if (this.Text == '[All Clients]') {
                datatext = 'Do Not Invoice';
            } else {
                datatext = this.Text;
            }

            $("#slctBillingGroup").append($('<option></option>').val(this.Value).html(datatext));

        });

        $("#slctBillingGroup").val($("#BillingGroupID").val());
        $("#slctBillingGroup").change(onChangeBillingGroup);

    }, 'json');
}

function onChangeBillingGroup() {
    $('#BillingGroupID').val($('select#slctBillingGroup option:selected').val());
}
   

    </script>


    <div id='addclientcontactdlg' title='Add New Client Contact' style='display: none;'>
        <form id='formCreateClientContact' name='formCreateClientContact'>
            <div id='addclientcontactdlgcontent'></div>
        </form>
    </div>

    <div id='updateclientcontactdlg' title='Update Client Contact' style='display: none;'>
        <div id='updateclientcontactdlgcontent'></div>
    </div>

    <div id='selectclientproductsdlg' title='Select Client Products' style='display: none;'>
        <div id='selectclientproductsdlgcontent'></div>
    </div>

    <style type="text/css">
        table {
            border-spacing: 0;
            border-collapse: collapse;
        }

        .table > thead > tr > th, .table > tbody > tr > th, .table > tfoot > tr > th, .table > thead > tr > td, .table > tbody > tr > td, .table > tfoot > tr > td {
            padding: 8px;
            line-height: 1.42857143;
            vertical-align: top;
            border-top: 1px solid #ddd;
        }

        .table-striped > tbody > tr:nth-child(odd) {
            background-color: #f9f9f9;
        }

        .table-bordered > thead > tr > th, .table-bordered > tbody > tr > th, .table-bordered > tfoot > tr > th, .table-bordered > thead > tr > td, .table-bordered > tbody > tr > td, .table-bordered > tfoot > tr > td {
            border: 1px solid #ddd;
        }

        .spanType:hover {
            background-color: aqua;
            cursor: pointer;
        }
        .spanType {
            text-decoration: underline;
            cursor: pointer;
        }
    </style>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
