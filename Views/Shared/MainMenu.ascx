<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.MainMenu>" %>

   <script type="text/javascript">
       $(function() {
           $("#CntMsgLnkBillingMessage").click(function() {
                $("#CntMsgBillingMessagecontent").load('../../Help/BillingMessage');
                $("#CntMsgBillingMessagedlg").dialog('open');
           });

           $("#CntMsgBillingMessagedlg").dialog({
               bgiframe: true,
               autoOpen: false,
               height: 485,
               width: 460,
               modal: false,
               draggable: true,
               resizable: false,
               buttons: {
                   Save: function() {
                   $.post('../../Help/BillingMessage', { CntMsgClientID: $('#CntMsgClientID').val(), CntMsgClientName: $('#CntMsgClientName').val(),
                           CntMsgClientContactID: $('#CntMsgClientContactID').val(), CntMsgMessageSubject: $('#CntMsgMessageSubject').val(), CntMsgMessageFromName: $('#CntMsgMessageFromName').val(),
                           CntMsgMessageBody: $('#CntMsgMessageBody').val(), CntMsgMessageToName: $('#CntMsgMessageToName').val(), CntMsgMessageFromEmail: $('#CntMsgMessageFromEmail').val(),
                           CntMsgMessageToEmail: $('#CntMsgMessageToEmail').val(), CntMsgMessageCategory: $('#CntMsgMessageCategory').val(), CntMsgMessageFromPhone: $('#CntMsgMessageFromPhone').val()
                       },
                       function(data) {
                       if (data.success == false) {

                           $('#CntMsgBillingMessagecontent').empty();
                           $('#CntMsgBillingMessagecontent').append(data.view);

                       } else {
                           alert('Your contact request was sent successfully!');
                           $('#CntMsgBillingMessagedlg').dialog('close');
                       }

                   }, 'json');
                   },
                   Cancel: function() {
                       $(this).dialog('close');
                   }
               }
           });
          
           $("[href$='/Invoices/Index']").parent().find("a").click(function (e) {
               if (this == e.target) {
                   $('#divThisIsTheMainDiv').html('<div style="height:100%;width:100%;clear:both;background-color: #f9f9f9;"><br /><b>Loading...</b><br /><img src="/content/images/load.gif" alt="loading..." /><br /></div>')
               }
           });

       });

       function openClient(id) {
           window.open('../../Clients/Details/' + id);
       }

       function openProduct() {


           $("#addproductdlgcontent2").load('../../Products/AddProduct');
           $("#addproductdlg2").dialog('open');
       }

       $(document).ready(function () {

           $("#addproductdlg2").dialog({
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

       });

</script>

<ul class="art-menu">
    <!--class=" active"-->
    <li><a href="/"><span class="l"></span><span class="r"></span><span class="t">Home</span></a></li>
    
    <% if (Model.Portal == "Client")
       { %>
    <li><a href="/BillingStatement/Home"><span class="l"></span><span class="r"></span><span class="t">Billing</span></a>
        <ul>
		    <li><%= Html.ActionLink("View Invoices", "Home", "BillingStatement")%></li>
		</ul>
    </li>
    <li><a href="/Security/ChangePassword"><span class="l"></span><span class="r"></span><span class="t">Change Password</span></a></li>
    
    <% if (Model.IsSalesDemoClient)
       { %>    
    
    <li><a href="/Help/ClientHelpHome"><span class="l"></span><span class="r"></span><span class="t">Help</span></a>
        <ul>
		    <li><a href="http://www.screeningone.com/pdf/BillingSystemFAQ.pdf">Billing System FAQ</a></li>
		</ul>
    </li>
    
    <% } else { %>
    <li><a href="http://www.screeningone.com/pdf/BillingSystemFAQ.pdf"><span class="l"></span><span class="r"></span><span class="t">Help</span></a>
        <ul>
		    <li><a href="http://www.screeningone.com/pdf/BillingSystemFAQ.pdf">Billing System FAQ</a></li>
		</ul>
    </li>
    <% } %>
    
    <li><a id='CntMsgLnkBillingMessage' href='javascript:void(0)' ><span class="l"></span><span class="r"></span><span class="t">Contact Us</span></a></li>
       
    <% } %>
    
    
    
    <% if (Model.Portal == "Admin")
       {  %>
    
    <li><a href="/Invoices/Index"><span class="l"></span><span class="r"></span><span class="t">Billing</span></a>
        <ul>
		    <li><%= Html.ActionLink("View Product Transactions", "Index", "ProductTransactions")%></li>
		    <li><%= Html.ActionLink("Invoices, Credits, and Finance Charges", "Index", "Invoices")%></li>
		    <li><%= Html.ActionLink("Create Finance Charges", "FinanceCharges", "Invoices")%></li>
		    <li><%= Html.ActionLink("Print/Email Packages", "PrintPackages", "BillingStatement")%></li>
		    <li><%= Html.ActionLink("Compose Current Invoice Reminder", "ComposeCurrentInvoiceReminder", "Invoices")%></li>
		    <li><%= Html.ActionLink("Preview Current Invoice Reminders", "PreviewCurrentInvoiceReminders", "Invoices")%></li>
		    <li><%= Html.ActionLink("Current Invoice Reminders Sent", "CurrentInvoiceRemindersSent", "Invoices")%></li>
		    <li><%= Html.ActionLink("Compose Overdue Invoice Reminder", "ComposeOverdueInvoiceReminder", "Invoices")%></li>
		    <li><%= Html.ActionLink("Preview Overdue Invoice Reminders", "PreviewOverdueInvoiceReminders", "Invoices")%></li>           
		    <li><%= Html.ActionLink("Overdue Invoice Reminders Sent", "OverdueInvoiceRemindersSent", "Invoices")%></li>
		    <!--<li><%= Html.ActionLink("Invoice and Payment Balancer", "InvoiceAndPaymentBalancer", "Invoices")%></li>-->
	    </ul>
    </li>
    
    <li><a href="/Clients/Index"><span class="l"></span><span class="r"></span><span class="t">Clients</span></a>
        <ul>
		    <li><%= Html.ActionLink("View Clients", "Index", "Clients")%></li>
	    </ul>
    </li>
    
    <li><a href="/Utils/Index"><span class="l"></span><span class="r"></span><span class="t">Utilities</span></a>
        <ul>
		    <li><%= Html.ActionLink("Billing File Import", "ImportBillingFile", "BillingImport")%></li>
		    <li><%= Html.ActionLink("Quickbooks Export", "Index", "QBExport")%></li>
		    <li><%= Html.ActionLink("Security", "Security", "Security")%></li>
            <li><a href="#" onclick="openProduct()">Add Product</a></li>
            <li><%= Html.ActionLink("Package Commissions", "Index", "Commissions")%></li>
	    </ul>
    </li>
    
    <li><a href="/Reports/Index"><span class="l"></span><span class="r"></span><span class="t">Reporting</span></a>
    </li>
    
    
    <% } %>
    
    
    <% if (Model.Portal == "Sales")
       { %>
       

       
    <% } %>
    

     
</ul>

<div id='CntMsgBillingMessagedlg' title='Contact Us' style='display:none;'>
    <div id='CntMsgBillingMessagecontent'></div>
</div>


    