<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.Invoices_VerifyInvoiceSetupForClient>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Verify Invoice Setup for Client
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
    <h2>Verify Invoice Setup For Client</h2>
    
    <table border='1' cellpadding='3' cellspacing='0' style='width:100%'>
    <tr>
    <th>Error</th>
    <th>Client ID</th>
    <th>Client Name</th>
    <th>Product ID</th>
    <th>Product Name</th>
    </tr>
    <% foreach (var item in Model.invoiceVerifySetupsForClient) { %>
    
    <tr>
    <% 
        if (item.DataSetName == "Missing Reference in Reference")
        { %>
            <td><a href="#" onclick="OpenModalGetContent(<%= item.ClientID %>,'<%=Html.Encode(item.ProductName)%>')"><%= Html.Encode(item.DataSetName) %></a></td> <%
        }
        else { %>
             <td><%= Html.Encode(item.DataSetName) %></td><%
        }   
     %>
    <td><%= Html.Encode(item.ClientID.ToString()) %></td>
    <td><%= Html.Encode(item.ClientName) %></td>
    <td><%= Html.Encode(item.ProductID.ToString()) %></td>
    <td><%= Html.Encode(item.ProductName) %></td>
    </tr>
    <% } %>
    </table>

   
    
    <script type='text/javascript'>
        $(function() {
            $("#verifyInvoiceIssueFixdlg").dialog({
                bgiframe: true,
                autoOpen: false,
                height: 300,
                width: 300,
                modal: true,
                draggable: false,
                resizable: false
            });



        });
        function OpenModalGetContent(clientID,RefTxt) {
            alert("Link");
            $("#verifyInvoiceIssueFixdlg").dialog('open');
            $("#lblProductName").text(RefTxt.toString());
            $('#hdnProductName').val(RefTxt.toString());
            // call controller's action
            var url = '../../Invoices/GetReferenceSplitContactsForDropdownJSON';
            $.getJSON(url, { ClientID: clientID }, function(data) {
                $('#selReferenceContact').empty();
                for (i = 0; i < data.rows.length; i++) {
                    $('#selReferenceContact').append(
                        $('<option></option>').val(data.rows[i].Value).html(data.rows[i].Text)
                        );
                }
            });
        }
    </script>
    
    <div id='verifyInvoiceIssueFixdlg' title='Verify Invoice - Correct Issue' style='display:none;'>
        <div style='margin-top:25px;margin-bottom:5px; font-weight:bold;'>
            <div style='margin-bottom:15px; font-weight:bold;'><label id="lblProductName"></label><input type="hidden" id="hdnProductName" /></div>
            <div style='margin-bottom:5px; font-weight:bold;'>Reference Contacts:</div>
            <div style='margin-bottom:15px; font-weight:normal;'><select id='selReferenceContact' style='width:300px;' size='5'></select></div>
            
        </div>
    </div>
    
</div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>