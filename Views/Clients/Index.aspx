<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.Clients_Details>" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
	Clients
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="art-content-wide">
    <h2>Clients</h2>
    
    <table id='list2'></table>
    <div id='pager2'></div>

</div>

<script type="text/javascript">

    $(function() {
        $('#list2').jqGrid({
            url: '../../Clients/IndexJSON',
            datatype: 'json',
            colModel: [
            { name: 'id', index: 'id', key: true, hidden: true },
            { name: 'ClientName', index: 'ClientName', align: 'left', width: 200, searchoptions: { sopt: ['cn']} },
            { name: 'ParentClientName', index: 'ParentClientName', align: 'left', width: 200, searchoptions: { sopt: ['cn']} },
            { name: 'BillAsClientName', index: 'BillAsClientName', align: 'left', width: 200, searchoptions: { sopt: ['cn']} },
            { name: 'Status', index: 'Status', align: 'right', width: 50, search: false },
            { name: 'CurrentBalance', index: 'CurrentBalance', align: 'right', width: 100, search: false }
            ],
            colNames: ['id', 'Client Name', 'Parent Client', 'Quickbooks Name', 'Status', 'Current Balance'],
            onSelectRow: function(id) { window.open('../../Clients/Details/' + id); },
            width: 966,
            height: 250,
            sortable: true,
            mtype: 'POST',
            rowNum: 100,
            rowList: [50, 100, 500],
            pager: '#pager2',
            sortname: 'id',
            viewrecords: true,
            sortorder: 'asc',
            caption: 'Clients',
            rownumbers: false,
            postData: {},
            //gridComplete: function() { },
            loadui: 'block',
            //footerrow: true,
            //userDataOnFooter: true,
            multiselect: false,
            toolbar: [true, "top"],
            gridview: true
        });
        jQuery('#list2').jqGrid('navGrid', '#pager2', { edit: false, add: false, del: false, search: true, refresh: false}, 
        {}, // edit options
        {}, // add options
        {}, //del options
        {closeOnEscape: true, closeAfterSearch: true} //Search Options
        );

        $("#t_list2").append("<a id='lnkCreateClient' href='javascript:void(0)' style='vertical-align:middle;line-height:18px;text-decoration:underline;color:#0000ff;margin-left:10px;'>Create New Client</a>");

        $("a", "#t_list2").click(function() {
            //alert("Create New Client");            
            $("#createclientdlgcontent").load('../../Clients/CreateClient');
            $("#createclientdlg").dialog('open');
        });

        $("#createclientdlg").dialog({
            bgiframe: true,
            autoOpen: false,
            height: 450,
            width: 500,
            modal: true,
            draggable: false,
            resizable: false,
            buttons: {
                Save: function() {
                    $.post('../../Clients/CreateClientJSON', { ClientName: $('#ClientName').val(), Address1: $('#Address1').val(),
                        Address2: $('#Address2').val(), City: $('#City').val(), State: $('#State').val(),
                        Zip: $('#Zip').val(), Tazworks1Client: $('#Tazworks1Client').is(':checked'), Tazworks2Client: $('#Tazworks2Client').is(':checked'), 
                        NonTazworksClient: $('#NonTazworksClient').is(':checked')
                    },

                                            function(data) {
                                                if (data.success == false) {

                                                    $('#createclientdlgcontent').empty();
                                                    $('#createclientdlgcontent').append(data.view);

                                                } else {
                                                    alert('New Client created. Please continue setup on next screen.');
                                                    openClient(data.clientid);
                                                    $('#createclientdlg').dialog('close');
                                                }

                                            }, 'json');
                },
                Cancel: function() {
                    $(this).dialog('close');
                }
            }
        });
    });

function openClient(id) {
    window.open('../../Clients/Details/' + id);
}
</script>


    <div id='createclientdlg' title='Create New Client' style='display:none;'>
    <form id='formCreateClient' name='formCreateClient'>
        <div id='createclientdlgcontent'></div>
    </form>
    </div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptIncludePlaceHolder" runat="server">
</asp:Content>
