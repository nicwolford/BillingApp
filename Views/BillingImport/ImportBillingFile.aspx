<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.Master" Inherits="System.Web.Mvc.ViewPage<ScreeningONE.ViewModels.BillingImport_Upload>" %>

<asp:Content ID="importBillingFileTitle" ContentPlaceHolderID="TitleContent" runat="server">
	ImportBillingFile
</asp:Content>

<asp:Content ID="importBillingFileContent" ContentPlaceHolderID="MainContent" runat="server">

<script type="text/javascript">

    $(function () {
        $('#transactionname').focus();
        $('#fileimportcontrols').hide();
        $('#transactionname').change(
            function getList() {
                if ($('#transactionname').val() == '') {
                    $('#fileimportcontrols').hide()
                }
                else {
                    $('#fileimportcontrols').show();
                }
            });

        $('#submitUpload').click(function opend() {
            $('#importfiledialog').dialog('open').delay(60000).queue(function () {

                var import_type = $("#transactionname").val();
                var import_val = 0;
                switch (import_type) {

                    case 'tazworks1':
                        import_val = 1;
                        break;
                    case 'tazworks2':
                        import_val = 2;
                        break;
                    case 'edrug':
                        import_val = 8;
                        break;
                    case 'tu':
                        import_val = 4;
                        break;
                    case 'xp':
                        import_val = 5;
                        break;
                    case 'QB':
                        import_val = 7;
                        break;
                }

                var redirect_url = '';

                if (import_val == 7) {
                    redirect_url = '/Reports/Index';
                } else {
                    redirect_url = '/BillingImport/VerifyImport?vendorid=' + import_val;
                }

                $("#tiredofwaiting").html('It&#39;s been 1 minute - Did it freeze? Then just click here - <a href="' + redirect_url + '">Verify Import</a>');
            });
        });

        $("#importfiledialog").dialog({
            bgiframe: true,
            autoOpen: false,
            height: 100,
            width: 300,
            modal: true,
            draggable: false,
            resizable: false
        });

        $("#importfiledialog").dialog({ dialogClass: "ats-loading-popup" });

        var nofileerror = "<%= string.IsNullOrWhiteSpace(ViewBag.nofileerror) ? "" : ViewBag.nofileerror %>";
        if (nofileerror != "")
        {
            alert(nofileerror);
        }

    });



</script>

<div class="art-content-wide">
    <h2>Import Billing Files</h2>
    
    <%= Html.ValidationSummary()%>
    
    <form method="post" enctype="multipart/form-data">
        <div>
            <label class="label-font"; for="transactionname">Import Type:</label>
            <select id="transactionname" name="transactionname" style="width:200px">
                <option label="Please select an import type..." style="color:Gray"></option>
                <option value="tazworks1">Tazworks 1.0 CSV File</option>
                <option value="tazworks2">Tazworks 2.0 CSV File</option>
                <option value="edrug">eDrug CSV File</option>
                <option value="xp">Experian CSV File</option>
                <option value="tu">TransUnion CSV File</option>
                <option value="QB">Quickbooks Billing Summary</option>
            </select>
        </div>
        <br />
        <div id="fileimportcontrols" style="margin-left:75px">
            <input type="file" id="billingimportfile" name="billingimportfile" runat="server"/><br /><br />
            <button type="submit" id="submitUpload" name="submitUpload" class="fg-button ui-state-default ui-priority-primary ui-corner-all" >Upload File</button>
        </div>
    
        <%--<div id='importfileloadingdlg' style='margin:0; padding:0; display:none;'>
            <p style='padding:0; margin-top:32px; margin-left:86px;'>
            Loading...</span><br />
            <!-- <img src="../../Content/images/load.gif" border="0" alt="..." style='margin:2px 0px 0px 0px; padding:0;'/> -->
            </p>
        </div>--%>

        <div id="importfiledialog" style="margin:0; padding: 20 20 20 20; display:none;max-width:300px;height:83px;">
            <div id="nowloading"><span style='font-size:16px; font-weight:bold; margin:0px; padding:0;'>Now Loading Records...</span><br />
                <img src="/Content/images/load.gif" border="0" alt="..." />
            </div>
            <br clear="all" />
            <div id="tiredofwaiting">
                
            </div>
        </div>
    
    </form>
</div>
</asp:Content>


