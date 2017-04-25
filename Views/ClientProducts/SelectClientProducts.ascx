<%@ Control Language="C#" Inherits="System.Web.Mvc.ViewUserControl<ScreeningONE.ViewModels.ClientProducts_Modify>" %>

<script type="text/javascript">
    jQuery(document).ready(function() {
        $('#ClientVendorsList').change(function() {
            reloadClientProductsList();
        });

         reloadClientProductsList();

    });

    function reloadClientProductsList() {
        
        $.post('../../ClientProducts/GetClientProductsListJSON/<%= Model.ClientID %>',
                        { VendorID: $('#ClientVendorsList').val() },

                                        function(data) {
                                            if (data.success == false) {

                                                
                                            } else {

                                            $('#ClientProductsList').multiselect('destroy');
                                            $('#ClientProductsList').empty();
                                            for (i = 0; i < data.rows.length; i++) {
                                               
                                               if (data.rows[i].Selected == true) {
                                                    $('#ClientProductsList').append(
                                                        $('<option selected></option>').val(data.rows[i].Value).html(data.rows[i].Text)
                                                     );
                                               }
                                               else {
                                                    $('#ClientProductsList').append(
                                                        $('<option></option>').val(data.rows[i].Value).html(data.rows[i].Text)
                                                    );
                                               }
                
                                            };

                                            $('#ClientProductsList').multiselect({ sortable: false });
                                            }

                                        }, 'json');
       
    };

</script>


<div id="selectClientVendor">
    <b>Vendor: </b><br /><%= Html.DropDownList("ClientVendorsList", Model.ClientVendorsList, new { @style = "width:150px;" })%>
</div>
<br />

<div id="selectClientProducts" style="padding-top:0px; padding-right:0px; vertical-align:middle; width:750px"> 
     <%= Html.ListBox("ClientProductsList", Model.ClientProductsList, new { style="width:750px; height:220px;", multiple = "multiple" })%> 
</div> 




