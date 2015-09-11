<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.min.js"></script>
<script>
	$(document).ready(function () {
		$('#btnLoadHomepageStateData').click(function(){
			document.frmAdmin.action='LoadHomepageStateData.cfm';
			document.frmAdmin.submit();
		});
		$('#btnLoadUSStateData').click(function(){
			document.frmAdmin.action='LoadUSStateData.cfm';
			document.frmAdmin.submit();
		});
		$('#btnLoadStateDistData').click(function(){
			document.frmAdmin.action='LoadStateDistData.cfm';
			document.frmAdmin.submit();
		});
		$('#btnCreateExportersCSV').click(function(){
			document.frmAdmin.action='CreateExportersCSV.cfm';
			document.frmAdmin.submit();
		});

		$('#btnRefreshMapSettings').click(function(){
			window.location='admin.cfm?refreshCongMap=1';
		});
		$('#btnStop').click(function(){
			window.location='admin.cfm';
		});
	});
</script>

<form action="admin.cfm" method="post" name="frmAdmin" target="iAdmin">

	<input name="btnStop" id="btnStop" type="button" value="Stop">
	<input name="btnRefreshMapSettings" id="btnRefreshMapSettings" type="button" value="Refresh Map Settings">
	<input name="btnLoadHomepageStateData" id="btnLoadHomepageStateData" type="button" value="Load Homepage State Data">
	<input name="btnLoadUSStateData" id="btnLoadUSStateData" type="button" value="Load US Map State Data">
	<input name="btnLoadStateDistData" id="btnLoadStateDistData" type="button" value="Load State District Data">
	<input name="btnCreateExportersCSV" id="btnCreateExportersCSV" type="button" value="CreateExportersCSV.cfm">

</form>

<iframe src="" name="iAdmin" id="iAdmin" width="100%" height="600" scrolling="yes"></iframe>
<!---
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
    	<td width="50%"><iframe src="" name="iAdmin" id="iAdmin" width="100%" height="300" scrolling="yes"></iframe></td>
    	<td width="50%"><div id="txContent" style="width: 100%; height:300px; background-color:#CCC;"></div></td>
    </tr>
</table>--->
<Cfif isDefined('url.refreshCongMap')>
	<cfdump var="#application.maps#" label="application.maps">
</Cfif>