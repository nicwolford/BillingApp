<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.BillingImport_Upload>" %>

            <fieldset>
                <div>
                    <%= Html.ValidationSummary()%>
                    <div style="padding-bottom:10px">Please match this Product Description with a Product.</div>
                     
                    <div style="float:left; padding-right:15px">
                    <label class="label-font">Description: </label>(Please change mis-spellings here before saving)
                    <%=Html.TextArea("productdesc", Model.ProductDesc, new { style = "width:450px; color:Navy; font-style:italic" })%>
                    </div>
                    <div class='spacer' style='margin: 0; padding: 0; line-height:5px'>&nbsp;</div>  
                    <div class='spacer' style='margin: 0; padding: 0; line-height:5px'>&nbsp;</div>  
                    <div>
                    <label class="label-font"; for="productlist">Product:</label>
                    <%=Html.DropDownList("productlist", Model.productlist, "ProductName - ProductCode", new { style = "width:450px", })%>
                    </div>
                    <%if (Model.errorcode == "104"){ %><div class='spacer' style='margin: 0; padding: 0; line-height:5px'>&nbsp;</div><div>
                    Permanent Match?<%=Html.CheckBox("ispermanentsearch", false) %>
                    </div>
                    <%} %>
                    <input id="importid" name="importid" type="hidden" value="<%=Model.ImportID%>"/>
                    <input id="errorcodeval" name="errorcodeval" type="hidden" value="<%=Model.errorcode%>"/>
                    <div class='spacer' style='margin: 0; padding: 0; line-height:5px'>&nbsp;</div>           
                </div>

            </fieldset>
            <p></p>