<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Reports
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

<script type="text/javascript">

    $(function() {

        $('#selReports').change(function() {
            $('#ifrReportContent').attr("src", $('#selReports').val());
        });

    });


</script>


<div class="art-content-wide">
        <select id="selReports" style="width:400px">
            <%if (ConfigurationManager.AppSettings["adminName"] == "ScreeningOne")
                { %>
            <optgroup label="Admin Reports">
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fBilling+-+Clients+To+Audit&rs%3aCommand=Render">Audit List</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fBillingDashboard&rs:Command=Render">Billing Dashboard</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fMissingQBNames&rs:Command=Render">Missing Quickbooks Names</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fOverpayments&rs:Command=Render">OverPayments</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fUnapplied+Payments&rs:Command=Render">Unapplied Payments</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fUnbalanced+Accounts&rs:Command=Render">Unbalanced Accounts</option>
            </optgroup>
         
            <optgroup label="Client Reports">
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fInvoiceDetailByRef+-+GENERAL&rs:Command=Render">ByRef Report - Any Client</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fInvoiceDetailByOrderByAllianceImaging&rs:Command=Render">Alliance Imaging Detail By OrderBy</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fInvoiceDetailByRefBelfor&rs:Command=Render">Belfor (Environmental and USA)</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fInvoiceDetailByRefBillJacobsCombined&rs:Command=Render">Bill Jacobs Combined</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fCareer+Path+Training+-+Invoice+Summary&rs:Command=Render">Career Path Training Invoice Summary</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fCenterStone&rs:Command=Render">CenterStone Invoice Summary</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fCenterStone+Indiana&rs:Command=Render">CenterStone Indiana</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fCity+of+Cape+Coral+-+Invoice+Detail&rs:Command=Render">City of Cape Coral Invoice Detail</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fCommunity+Options+-+Invoice+Summary&rs:Command=Render">Community Options Invoice Summary</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fFlynt+Non-HH+-+Invoice+Summary&rs:Command=Render">Flynt Non-HH - Invoice Summary</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fFlynt+-+Invoice+Summary&rs:Command=Render">Flynt - Invoice Summary</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fInvoiceDetailGreatDane&rs:Command=Render">Great Dane</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fGreen+Mountain+-+Invoice+Summary&rs:Command=Render">Green Mountain Invoice Summary</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fInvoice+Detail+By+Ref+-+Staffing+Companies&rs:Command=Render">Invoice Detail by Ref - Staffing Companies</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fInvoiceDetailByRefHospice&rs:Command=Render">Hospice Detail By Ref</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fPaylease+-+Invoice+Summary&rs:Command=Render">PayLease Invoice Summary</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fInvoiceDetailByRefProvidian&rs:Command=Render">Providian Detail By Ref</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fRoman+Catholic+Diocese+-+Invoice+Summary&rs:Command=Render">Roman Catholic Diocese Invoice Summary</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fSanMar+Report&rs:Command=Render">SanMar Detail</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fTU+and+XP+Report&rs:Command=Render">TU and XP Invoice Details</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fInvoiceDetailByRefUnitedRefining&rs:Command=Render">United Refining Detail By Ref</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fInvoiceDetailByRefVXI&rs:Command=Render">VXI Detail By Ref</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fInvoiceDetailByRefWellbridgeCombined&rs:Command=Render">Wellbridge Billing Report</option>

            </optgroup>
        <% }
            else
            { %>
            <optgroup label="Admin Reports">
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fBilling+-+Clients+To+Audit+-+Western&rs%3aCommand=Render">Audit List</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fBillingDashboard+-+Western&rs:Command=Render">Billing Dashboard</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fMissingQBNames+-+Western&rs:Command=Render">Missing Quickbooks Names</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fOverpayments+-+Western&rs:Command=Render">OverPayments</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fUnapplied+Payments+-+Western&rs:Command=Render">Unapplied Payments</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fUnbalanced+Accounts+-+Western&rs:Command=Render">Unbalanced Accounts</option>
            </optgroup>
         
            <optgroup label="Client Reports">
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fInvoiceDetailByRef+-+GENERAL+-+Western&rs:Command=Render">ByRef Report - Any Client</option>
            <option value="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fTU+and+XP+Report+-+Western&rs:Command=Render">TU and XP Invoice Details</option>
            </optgroup>
            <% } %>
        </select>
        
        <%if (ConfigurationManager.AppSettings["adminName"] == "ScreeningOne")
            { %>
        <iframe id="ifrReportContent" height="420px" width="960px" src="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fUnbalanced+Accounts&rs:Command=Render">
        </iframe>
        <% }  else { %>
        <iframe id="ifrReportContent" height="420px" width="960px" src="https://701743-db2/ReportServer/Pages/ReportViewer.aspx?%2fBilling+Reports%2fUnbalanced+Accounts+-+Western&rs:Command=Render">
        </iframe>
        <% } %>
    
</div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
