<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="clientHelpHomeTitle" ContentPlaceHolderID="TitleContent" runat="server">
	Help
</asp:Content>

<asp:Content ID="clientHelpHomeMain" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
    <h2>Additional Invoice Formats</h2>
    
    <ul style='list-style:disc;'>
    <li><a href='http://www.screeningone.com/pdf/Invoice_Standard1.0_Sample.pdf' target='_blank'>1 - Standard 1.0</a></li>
    <li><a href='http://www.screeningone.com/pdf/Invoice_QuantityRate_Sample.pdf' target='_blank'>3 - Quantity/Rate</a></li>
    <li><a href='http://www.screeningone.com/pdf/Invoice_Standard2.0_Sample.pdf' target='_blank'>5 - Standard 2.0</a></li>
    <li><a href='http://www.screeningone.com/pdf/Invoice_SeeAttachedDetail_Sample.pdf' target='_blank'>6 - SEE ATTACHED DETAIL</a></li>
    <li><a href='http://www.screeningone.com/pdf/Invoice_SummaryByCompany_Sample.pdf' target='_blank'>7 - Summary by Client</a></li>
    <li><a href='http://www.screeningone.com/pdf/Invoice_SummaryByFileNum_Sample.pdf' target='_blank'>8 - Summary by File Number</a></li>
    </ul>
    
    <h2>Additional Billing Detail Report Formats</h2>
    <ul style='list-style:disc;'>
    <li>0 - None</li>
    <li><a href='http://www.screeningone.com/pdf/BillingDetail_GroupByReference_Sample.pdf' target='_blank'>1 - Group by Reference</a></li>
    <li><a href='http://www.screeningone.com/pdf/BillingDetail_GroupByOrderedBy_Sample.pdf' target='_blank'>3 - Group by Ordered By (User)</a></li>
    <li><a href='http://www.screeningone.com/pdf/BillingDetail_GroupByClient_Sample.pdf' target='_blank'>4 - Group by Client</a></li>
    <li><a href='http://www.screeningone.com/pdf/BillingDetail_CustomExcel.pdf' target='_blank'>Custom - Custom Excel</a></li>
    </ul>
</div>

<div id='billingmessagedlg' title='Contact Us' style='display:none;'>
    <div id='billingmessagedlgcontent'></div>
</div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
