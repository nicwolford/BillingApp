<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.BillingMessage_Details>" %>

<div style="margin-left:30px">
<%= Html.ValidationMessage("ErrorMessages")%>
<%= Html.Hidden("CntMsgClientID", Model.CntMsgClientID)%>
<%= Html.Hidden("CntMsgClientName", Model.CntMsgClientName)%>
<%= Html.Hidden("CntMsgClientContactID", Model.CntMsgClientContactID)%>
<%= Html.Hidden("CntMsgMessageToEmail", Model.CntMsgMessageToEmail)%>
<table>
<tr>
<td align='right'><b>To:</b></td>
<td><%=Model.CntMsgMessageToName%><%= Html.Hidden("CntMsgMessageToName", Model.CntMsgMessageToName)%></td>
</tr>
<tr>
<td align='right'><b>From:</b></td>
<td><%=Model.CntMsgMessageFromName%><%= Html.Hidden("CntMsgMessageFromName", Model.CntMsgMessageFromName)%></td>
</tr>
<tr>
<td align='right'><b>Email:</b></td>
<td><%=Model.CntMsgMessageFromEmail%><%= Html.Hidden("CntMsgMessageFromEmail", Model.CntMsgMessageFromEmail)%></td>
</tr>
<tr>
<td align='right'><b>Phone:</b></td>
<td><%=Model.CntMsgMessageFromPhone%><%= Html.Hidden("CntMsgMessageFromPhone", Model.CntMsgMessageFromPhone)%></td>
</tr>
<tr>
<td align='right'><b>Category:</b></td>
<td><select id="CntMsgMessageCategory" name="CntMsgMessageCategory">
        <option value='<%=Model.CntMsgMessageCategory%>'><%=Model.CntMsgMessageCategory%></option>
        <option value='Account Activity'>Account Activity</option>
        <option value='Account Change'>Account Change</option>
        <option value='Address Change'>Address Change</option>
        <option value='Billing Contact'>Billing Contact(s)</option>
        <option value='Billing Statement'>Billing Statement</option>
        <option value='General Billing Question'>General Billing Question</option>
        <option value='Invoice'>Invoice</option>
        <option value='Invoice Billing Detail'>Invoice Report</option>
        <option value='Passord Help'>Passord Help</option>
        <option value='System Help'>System Help</option>
        <option value='Other'>Other</option>
    </select> 
</td>
</tr>
<tr>
<td align='right'><b>Subject:</b></td>
<td><%= Html.TextBox("CntMsgMessageSubject", Model.CntMsgMessageSubject, new { @style = "width:290px;" })%> 
    <%= Html.ValidationMessage("CntMsgMessageSubject")%></td>
</tr>
<tr>
<td align='right' valign="top"><b>Message:</b></td>
<td><%= Html.TextArea("CntMsgMessageBody", Model.CntMsgMessageBody, new { @style = "width:290px; height:130px;" })%> 
    <%= Html.ValidationMessage("CntMsgMessageBody")%></td>
</tr>
</table>
<h2 style="font-size:15px">
    For further assistance please contact us directly:<br /><br />
    <div style="margin-left:80px"><%=ConfigurationManager.AppSettings["billingphone"] %><br />
    <%=ConfigurationManager.AppSettings["billingemail"] %></h2></div>
</div>

