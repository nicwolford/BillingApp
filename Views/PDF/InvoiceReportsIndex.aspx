<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.InvoiceReports_Index>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Index
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

<div class="art-content-wide">
    <% if (!Model.toPrint)
       { %>
    <div style='float:left;'><h2>Invoice Report</h2></div>
    <div style='float:right;margin-top:28px;margin-right:5px;'>
        <a href='../../InvoiceReports/PrintReportToPDF?InvoiceID=<%= Model.InvoiceID.ToString() %>&GroupID=<%= Model.GroupID.ToString() %>'>Export to PDF</a>
    </div>
    <div style='float:right;margin-top:28px;margin-right:5px;'>
        <% if (Model.ClientView)
           { %>
                <a href='../../Invoices/ClientRenderInvoice/<%= Model.InvoiceID.ToString() %>'>Invoice</a>
        <% }
           else
           { %>
                <a href='../../Invoices/Details/<%= Model.InvoiceID.ToString() %>'>Invoice</a>
        <% } %>
    </div>
    <div style='clear:both;height:0px;line-height:0px;'></div>
        
    <div style='font-size:10px; background-color:White; border:solid 1px black;padding:8px;'>
    <% }
       else
       { %>    
       
    <div style='font-size:10px;'>
    
    <% } %>
    
    
    <%
        //int LinesPerPage = 10;
        string SplitByPreviousValue = "****";
        //int NumberOfPages = (int)Math.Ceiling((decimal)Model.invoicerptlist.Count / LinesPerPage);
        int GroupNumber = 1;
        int CountOfGroup = 0;
        int CurRow = 0;
        int PrevCurRow = 0;
        int MaxLinesPerPage = 14;
        string GroupByText = "";
        string PrevCompany = "";
        bool companyGroupMode = false;
        string previousGroupName = "";
        string ClientName = "";
        
        
        Dictionary<string, int> groups = new Dictionary<string, int>();
        foreach (var item in Model.invoicerptlist)
        {
            if (item.ClientName != "" && item.ClientName != null && item.ClientName != "zzzzzzzzzz")
            {
                ClientName = item.ClientName;
            }
            
            
            switch (item.GroupOrder)
            {
                case "REFERENCE":
                    GroupByText = item.Reference; 
                    break;
                case "FILE #":
                    GroupByText = item.FileNum;
                    break;
                case "ORDERED BY":
                    GroupByText = item.OrderBy;
                    break;
                case "COMPANY":
                    GroupByText = item.ClientName;
                    break;
            }

            //if the first item in a group after the first group starts with a subtotal, add it to the previous group
            if (CountOfGroup == MaxLinesPerPage && item.Detail == 2 && GroupNumber > 1 && !String.IsNullOrEmpty(previousGroupName))
            {
                previousGroupName = GroupByText + GroupNumber.ToString();
                groups.Add(previousGroupName, CountOfGroup + 1);
                CountOfGroup = -1;
                GroupNumber++;
            }
            else if ((SplitByPreviousValue != GroupByText && SplitByPreviousValue != "****") || CountOfGroup >= MaxLinesPerPage)
            {
                previousGroupName = GroupByText + GroupNumber.ToString();
                groups.Add(previousGroupName, CountOfGroup);                
                CountOfGroup = 0;
                GroupNumber++;
            }
         
            CountOfGroup++;
            SplitByPreviousValue = GroupByText;   
        }
        groups.Add(GroupByText, CountOfGroup);
        
        int NumberOfPages = groups.Count;

        for (int CurPage = 0; CurPage < NumberOfPages; CurPage++)
        {
         %>
        <% if ((ClientName != "The Johnny Rockets Group Inc" && ClientName != "Compassion International-Tours" && ClientName != "Village Green Holding, LLC.")|| CurPage == 0)
           {%>
    <div style='margin-left:3px;float:left;'>
        <div style='float:left;'>
            <table border='0' cellpadding='5' cellspacing='0' style='width:250px; text-align:left; margin-top:20px; font-weight:bold; border:double 3px black;'>
            <tr><td>
            BILL TO:<br />
            <%= Html.Encode(Model.invoicerptlist[1].PrimaryClientName)%><br />
            <%= Html.Encode(Model.invoicerptlist[1].Address1)%><br />
            <% if (Model.invoicerptlist[1].Address2 != null)
               {
                   %><%= Html.Encode(Model.invoicerptlist[1].Address2)%><br />
             <%}%>
            <%= Html.Encode(Model.invoicerptlist[1].Address3)%>
            </td></tr>
            </table>
        
        </div>
    </div>
    <div style='text-align:left;float:left;margin-left:100px'><img src="<%=ConfigurationManager.AppSettings["logourl"] %>" style='max-width:200px; max-height:55px;' /></div>
    <div style='margin-right:3px;float:right;margin-top:20px'>
        <div style='font-weight:bold; font-size:14px; float:right; margin-right:0px;'>Invoice Billing Detail</div>
        <br /><br />
        <div style='font-weight:bold; font-size:12px; float:right; margin-right:0px;'>Invoice: <%= Html.Encode(Model.invoicerptlist[1].InvoiceNumber.ToString())%> - <%= Html.Encode(Model.invoicerptlist[1].InvoiceDate.ToShortDateString())%></div>
        <br /><br />
        <div style='font-size:10px; float:right; margin-right:0px;'>Payment Terms: Due on Receipt</div>
    </div>
        
    <div style='clear:both;'></div>
    
    <br /><br />
    
    <div style='margin-left:3px; text-align:center'>
    <span style='font-size:12px;'>All Discrepancies Must Be Brought To Our Attention Within 30 Days. All Late Fees, 
    Collection Costs, And Attorney's Fees May Be Added To Past Due Accounts.</span>
    </div>
    <%} %>
    <div style='clear:both;'></div>
    
    <br />

    <table border='0' cellpadding='4' cellspacing='0' width='100%' style='margin-bottom:0px;'>
    <thead style='font-weight:bold;'>
    <% if ((ClientName != "The Johnny Rockets Group Inc" && ClientName != "Compassion International-Tours" && ClientName != "Village Green Holding, LLC.") || CurPage == 0)
       {%>
    <tr>
        <th style='text-align:left; border-top:double 3px black; border-bottom:solid 1px black; '>FILE #</th>
        <th style='text-align:right; border-top:double 3px black; border-bottom:solid 1px black; '>DATE</th>
        <th style='text-align:left; border-top:double 3px black; border-bottom:solid 1px black; '>NAME</th>
        <th style='text-align:right; border-top:double 3px black; border-bottom:solid 1px black; '>SSN</th>
        <th style='text-align:left; border-top:double 3px black; border-bottom:solid 1px black; white-space:nowrap;'>ORDERED BY</th>
        <th style='text-align:left; border-top:double 3px black; border-bottom:solid 1px black; white-space:nowrap;'>PRODUCT DESCRIPTION</th>
        <th style='text-align:left; border-top:double 3px black; border-bottom:solid 1px black; '>REFERENCE</th>
        <th style='text-align:right; border-top:double 3px black; border-bottom:solid 1px black;'>AMOUNT</th>
    </tr>
       <%} %>
    </thead>    
    <tbody id='invoice_rows'>
        
    <% bool subtotalfilenum = false;
       bool spacefilenumgroup = true;
       string sFileNum = null;
       bool firstItemInGroup = true;
       PrevCurRow = CurRow;
       int ItemsInGroup = groups[groups.Keys.ToList()[CurPage]];
       int StartRow = PrevCurRow;
       int EndRow = PrevCurRow + ItemsInGroup;
            
       foreach (var item in Model.invoicerptlist)
       {
           //if (item.LineNumber > (CurPage * LinesPerPage) && item.LineNumber <= ((CurPage + 1) * LinesPerPage))
           //{           

           if (item.LineNumber > StartRow && item.LineNumber <= EndRow)
           {
               if (firstItemInGroup)
               {
                   
                   CurRow += ItemsInGroup;
                   firstItemInGroup = false;
                   subtotalfilenum = true;
                   sFileNum = item.FileNum;
               }

               if (companyGroupMode && item.LineNumber == (StartRow + 1) && !firstItemInGroup && item.Detail != 0)
                {
                    %>
                    <tr>
                    <td colspan='8' style='text-align:left;'>
                    COMPANY: <%= Html.Encode(PrevCompany)%>
                    </td>
                    </tr>
                    <%
                }           
           %>
    
    <tr>
        <% switch (item.Detail)
           {

               case 0: %>
                    <td colspan='8' style='text-align:left;'>
                    <%= Html.Encode(item.GroupOrder)%>:&nbsp;<%
        switch (item.GroupOrder)
        {
            case "REFERENCE":%>
                            <%= Html.Encode(item.Reference)%>
                            <%break;
            case "FILE #":%>
                            <%= Html.Encode(item.FileNum)%>
                            <%break;
            case "ORDERED BY":%>    
                            <%= Html.Encode(item.OrderBy)%>
                            <%break;
            case "COMPANY":%>                
                            <%= Html.Encode(item.ClientName)%>
                            <%
                                PrevCompany = item.ClientName;
                                companyGroupMode = true;
                                break;
        } %></td>
                     
                    <%break;
               case 1:
                      
                   if (item.RecordCount > 1 && spacefilenumgroup == true)
                      {
                          subtotalfilenum = true;
                          spacefilenumgroup = false;
                          %><td style='padding-top:20px; text-align:left;'><%= Html.Encode(item.FileNum)%></td>
                            <td style='padding-top:20px; text-align:right; white-space:nowrap;'><%= Html.Encode(item.DateOrdered.ToShortDateString())%></td>
                            <td style='padding-top:20px; text-align:left; white-space:nowrap;'><%= Html.Encode(item.Name)%></td>
                            <td style='padding-top:20px; text-align:right; white-space:nowrap;'><%= Html.Encode(item.SSN)%></td>
                            <td style='padding-top:20px; text-align:left; white-space:nowrap;'><%= Html.Encode(item.OrderBy)%></td>
                            <td style='padding-top:20px; text-align:left;'><%= Html.Encode(item.ProductDescription)%></td>
                            <td style='padding-top:20px; text-align:left; white-space:nowrap;'><%=Html.Encode(item.Reference) %></td>               
                            <td style='padding-top:20px; text-align:right;'>
                                <% if (item.ProductPrice != 0)
                                   { %>
                                        <%= Html.Encode(item.ProductPrice.ToString("F"))%>
                                <% }
                                   else
                                   { %>
                                    0.00
                                <% } %>
                            </td>
                    <%}
                      else
                      {%>
                    <td style='text-align:left;'><%= Html.Encode(item.FileNum)%></td>
                    <td style='text-align:right; white-space:nowrap;'><%= Html.Encode(item.DateOrdered.ToShortDateString())%></td>
                    <td style='text-align:left; white-space:nowrap;'><%= Html.Encode(item.Name)%></td>
                    <td style='text-align:right; white-space:nowrap;'><%= Html.Encode(item.SSN)%></td>
                    <td style='text-align:left; white-space:nowrap;'><%= Html.Encode(item.OrderBy)%></td>
                    <td style='text-align:left;'><%= Html.Encode(item.ProductDescription)%></td>
                    <td style='text-align:left; white-space:nowrap;'><%= Html.Encode(item.Reference)%></td>               
                    <td style='text-align:right;'>
                        <% if (item.ProductPrice != 0)
                           { %>
                                <%= Html.Encode(item.ProductPrice.ToString("F"))%>
                        <% }
                           else
                           { %>
                            &nbsp;
                        <% } %>
                    </td>
                    <%}

                      if (sFileNum != item.FileNum)
                      {
                          sFileNum = item.FileNum;

                          if (item.RecordCount > 1)
                          {
                              subtotalfilenum = true;
                          }
                      }

                      break;
               case 2:
                     if (subtotalfilenum == true || ClientName == "Biscuitville, Inc.")
                     {%>
                    <td style='text-align:right;' colspan='7'>SUBTOTAL FOR FILE <%= sFileNum%></td>   
                    <td style='border-top:solid 1px black; text-align:right;'>
                        <% if (item.ProductPrice != 0)
                           { %>
                                <%= Html.Encode(item.ProductPrice.ToString("F"))%>
                        <% }
                           else
                           { %>
                            &nbsp;
                        <% } %>
                    </td>
                    <%}

                      subtotalfilenum = false;
                      spacefilenumgroup = true;
                      break;
               case 3: %>
                    <td colspan='7' style='background-color:Yellow;  border-top:solid 1.5px red; border-left:solid 1.5px red; border-bottom:solid 1.5px red; text-align:right; font-weight:bold;'>TOTAL FOR <%
                    switch (item.GroupOrder)
                    {
                        case "REFERENCE":%>
                                        <%= Html.Encode(item.Reference)%>
                                        <%break;
                        case "FILE #":%>
                                        <%= Html.Encode(item.FileNum)%>
                                        <%break;
                        case "ORDERED BY":%>    
                                        <%= Html.Encode(item.OrderBy)%>
                                        <%break;
                        case "COMPANY":%>                
                                        <%= Html.Encode(item.ClientName)%>
                                        <%break;
                    } %>:</td>
                    <td style='background-color:Yellow;  border-top:solid 1.5px red; border-right:solid 1.5px red; border-bottom:solid 1.5px red; text-align:right; font-weight:bold;'>
                        <% if (item.ProductPrice != 0)
                           { %>
                                <%= Html.Encode(item.ProductPrice.ToString("F"))%>
                        <% }
                           else
                           { %>
                            &nbsp;
                        <% } %>
                    </td>
                    <% 
                break;
               case 4: %>
                    <td colspan='7' style='text-align:right;'>GRAND TOTAL:</td>
                    <td style='border-top:solid 1px black; text-align:right;'>
                        <% if (item.ProductPrice != 0)
                           { %>
                                <%= Html.Encode(item.ProductPrice.ToString("F"))%>
                        <% }
                           else
                           { %>
                            &nbsp;
                        <% } %>
                    </td>
                    <% 
                break;
           } %>
    
   
    </tr>
    
    <% } %>    
        
    <% } %>
    </tbody>
    </table>
    
       
    <% if (CurPage < NumberOfPages - 1 && ClientName != "The Johnny Rockets Group Inc" && ClientName != "Compassion International-Tours" && ClientName != "Village Green Holding, LLC.")
       { %>
        <div style='page-break-after:always;'></div> 
    <%} %>
    
    <% } //End for %>
    
    </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>

