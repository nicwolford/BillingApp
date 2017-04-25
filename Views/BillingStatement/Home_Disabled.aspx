<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Home
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
    <div style='float:left;'>
    <h2 style='margin-bottom:5px;'>Billing</h2>
    </div>
    
    <div style='width:100%;'>
    
    <table>
    <tr>
        <td style='width:960px; vertical-align:top;'>
            <fieldset style='margin: 0; background-color:White; padding:0;'>
                <div class='fieldset-header'>
                    <h3 style='text-align:left;' id='CurrentStatementHeader'>Current Statement</h3>
                </div>
                
                <div style='padding:10px;'>
               
               <p><b>Please note:</b> Invoices will not be accessible until you receive your first invoice notice via email.  You may currently log in to the system and change your password, but invoices are not viewable at this time.  Should you need assistance when logging into the system, please contact billing at <%=ConfigurationManager.AppSettings["billingphone"] %>  <a href='mailto:<%=ConfigurationManager.AppSettings["billingemail"] %>'><%=ConfigurationManager.AppSettings["billingemail"] %></a></p>
                
                </div>
             </fieldset>
         </td>
     </tr>
     </table>
    
    </div>
    
</div>




</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
