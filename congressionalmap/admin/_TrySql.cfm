<cfparam name="form._sql" default="">
<form action="_TrySql.cfm" method="post" name="frmTry">
	<textarea name="_sql" style="width: 800px; height: 400px;"><cfoutput>#trim(form._sql)#</cfoutput></textarea>
    <input name="btnSubmit" type="submit" value="Run SQL">
</form>


<cfif form._sql neq ''>
	<cfset qData = application.oFusion.batchGet(trim(form._sql))>
	<cfflush>
    <hr>
    <cfdump var="#qData#">
</cfif>
