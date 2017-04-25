<%@ Page Title="Security" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.Security_Users>" %>

<asp:Content ID="SecurityTitle" ContentPlaceHolderID="TitleContent" runat="server">
	Security
</asp:Content>

<asp:Content ID="SecurityContent" ContentPlaceHolderID="MainContent" runat="server">
 
<script type="text/javascript">
    $(function() {
        UpdateSecuritySettings(0);
        $('#securitytabs').tabs();

        //Client Contacts Grid
        $('#list_ClientContacts').jqGrid({
            url: '../../Security/UserClientContactsJSON',
            datatype: 'json',
            colModel: [
                    { name: 'id', index: 'id', key: true, hidden: true },
                    { name: 'ContactEmail', index: 'ContactEmail', hidden: true },
                    { name: 'ContactName', index: 'ContactName', align: 'left', width: 150 },
                    { name: 'ClientName', index: 'ClientName', align: 'left', width: 250 },
                    { name: 'ClientContactStatus', index: 'ClientContactStatus', align: 'left', width: 65 }
                ],
            colNames: ['id', 'ContactEmail', 'Contact Name', 'Client Name', 'Status'],
            //onSelectRow:
            //            function(id) {
            //                $('#addclientcontactdlgcontent').empty();
            //                $('#updateclientcontactdlgcontent').empty();
            //                $("#updateclientcontactdlgcontent").load('../../ClientContacts/AddClientContact/' + id + '?cmdType=update');
            //                $("#updateclientcontactdlg").dialog('open');
            //            },
            width: 400,
            height: 200,
            sortable: true,
            mtype: 'POST',
            rowNum: 100,
            rowList: [10, 50, 100],
            //pager: '#pager_ClientContacts',
            sortname: 'ClientContactName',
            viewrecords: true,
            sortorder: 'asc',
            caption: 'User Client Contacts',
            rownumbers: false,
            postData: { UserID: 0},
            gridComplete: function() {
                var ids = jQuery('#list_ClientContacts').jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                    var cl = ids[i];
                    var rowValues = jQuery("#list_ClientContacts").jqGrid('getRowData', cl);
                    var email = rowValues.ContactEmail;
                    $('#list_ClientContacts').jqGrid('setRowData', cl, { ContactName: "<a href='mailto:" + email + "?subject=" + "<%=ConfigurationManager.AppSettings["CompanyName"] %>" + " Billing: &body=To: " + rowValues.ContactName + ", '>" + rowValues.ContactName + "</a>" });
                }
            },
            loadui: 'block',
            //footerrow: true,
            //userDataOnFooter: true,
            //multiselect: true,
            loadtext: 'Loading Client Contacts...',
            emptyrecords: 'No Client Contacts',
            toolbar: [true, "top"],
            gridview: true
        });


        $('#list2').jqGrid({
            url: '../../Security/GetSecurityUsersJSON/',
            datatype: 'json',
            colModel: [
            { name: 'id', index: 'id', key: true, hidden: true },
            { name: 'UserID', index: 'UserID', hidden: true },
            { name: 'UserName', index: 'UserName', align: 'left', width: 250, searchoptions: { sopt: ['cn']} },
            { name: 'ClientName', index: 'ClientName', align: 'left', width: 250, searchoptions: { sopt: ['cn']} },
            { name: 'IsApproved', index: 'IsApproved', align: 'left', width: 50, search: false }
            ],
            colNames: ['id', 'UserID', 'User Name', 'Client', 'Status'],
            onSelectRow: function(id) {
                var rowValues = jQuery("#list2").jqGrid('getRowData', id);
                UpdateSecuritySettings(rowValues.UserID); 
            },
            width: 550,
            height: 450,
            sortable: true,
            mtype: 'POST',
            rowNum: 100,
            rowList: [10, 50, 100],
            pager: '#pager2',
            sortname: 'id',
            viewrecords: true,
            sortorder: 'asc',
            caption: 'Users',
            rownumbers: false,
            postData: {},
            gridComplete: function() {
                var ids = jQuery('#list2').jqGrid('getDataIDs');
                for (var i = 0; i < ids.length; i++) {
                    var cl = ids[i];
                    var rowValues = jQuery("#list2").jqGrid('getRowData', cl);
                }
            },
            loadui: 'block',
            gridview: true
        });
        jQuery('#list2').jqGrid('navGrid', '#pager2', { edit: false, add: false, del: false, search: true, refresh: false },
        {}, // edit options
        {}, // add options
        {}, //del options
        {closeOnEscape: true, closeAfterSearch: true} //Search Options
        );

    });




function UpdateSecuritySettings(id)
{    
    $('#ajaxsecuritycontent').load('../../Security/SecurityUserSettings/' + id, function() {
        ajaxsecuritycontentonsuccess();
        $("#list_ClientContacts").jqGrid('appendPostData', { UserID: id });
        $('#list_ClientContacts').trigger("reloadGrid");
    });

}


function ajaxsecuritycontentonsuccess() {
    $('#securitytabs').tabs();
}


    
    /*
    $("#createuserdlg").dialog({
        bgiframe: true,
        autoOpen: false,
        height: 550,
        width: 390,
        modal: true,
        //close:
        buttons: {
            Save: function() {
                $.post('../../Security/CreateClientUser', $('#formCreateClientUser').serialize(),

                                            function(data) {
                                                if (data.success == false) {

                                                    $('#ajaxsecuritycontent1').empty();
                                                    $('#ajaxsecuritycontent1').append(data.view);

                                                } else {
                                                    alert('New user has been created.');
                                                    $('#createuserdlg').dialog('close');
                                                }

                                            }, 'json');
            },
            Cancel: function() {
                $(this).dialog('close');
            }
        }
    });
*/
</script>  


<div class="art-content-wide">
    <div style="float:left"><h2>Security</h2></div>
    <div class='spacer' style='margin: 0; padding: 0; line-height:0px'>&nbsp;</div> 
    <div style="float:left; margin-left:0px" >
        <table id='list2'></table>
        <div id='pager2'></div>
    </div>
    <div style="float:left">
        <div id="ajaxsecuritycontent">
        
        </div>
        <div class='spacer' style='margin: 10; padding: 10; line-height:10px'>&nbsp;</div>
        <fieldset style='margin:0; background-color:White; padding:0; width:410px'>
                <div class='fieldset-header'>
                <h3>Contacts</h3>
                </div>
                
                <div style='padding:3px;'>
                    <table id='list_ClientContacts'></table>
                </div>              
         </fieldset>
    </div> 
            
</div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>

