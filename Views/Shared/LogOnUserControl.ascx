<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl" %>
<%
    if (Request.IsAuthenticated) {
%>
        Welcome <b><%= Html.Encode(Page.User.Identity.Name) %></b>!
        [ <%= Html.ActionLink("Log Out", "LogOff", "Account")%> ]
<%
    }
    else {
        if (Request.Path.ToString() == "/Account/LogOn" || Request.Path.ToString().ToUpper().Contains("/TASKS/")) 
         {
             //Do not show the logon link   
         }
        else
        {
          %>
            [ 
                <%= Html.ActionLink("Log On", "Logon", "Account", new { portal = (String.IsNullOrEmpty(Request.Params["portal"]) ? "" : Request.Params["portal"].ToString()), ReturnURL = (String.IsNullOrEmpty(Request.Params["ReturnURL"]) ? "" : Request.Params["ReturnURL"].ToString()), ClientID = (String.IsNullOrEmpty(Request.Params["ClientID"]) ? "" : Request.Params["ClientID"].ToString()) } )%> 
            ]
            <%
        }
    }
%>


