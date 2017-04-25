<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.Security_Users>" %>


                <%= Html.ValidationSummary()%>
                
                
                <style type="text/css">
                #userstable {width:200px;}
                </style>
                <table id="userstable" border="1">
                <thead>
                    <tr>
                        <th id='userid'>ID</th>
                        <th id='username'>
                            User Name
                        </th>
                        <th id='status'>
                            Status
                        </th>
                     </tr>
                </thead>
                <tbody>
                <% foreach (var item in Model.userlist) { %>
                    <tr>
                        <td style="width:150px"><%= Html.Encode(item.UserID) %></td>
                        <td style="width:150px"><%= Html.Encode(item.ShortName) %></td>
                        <td style="width:50px;"><%= Html.Encode(item.Status) %></td>
                    </tr>
                <% } %> 
                </tbody>
                </table>
                

                  
                
