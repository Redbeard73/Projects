<cftry>
    <cfapplication name="congressionalmap" sessionmanagement="yes">
    <cfsetting showdebugoutput="yes">
    <cfinclude template="buildCache.cfm">
    <cffunction access="public" name="abort" output="no" returntype="void">
        <cfabort>
    </cffunction>
    
	<cfcatch type="any"> 
		<cfdump var="#cfcatch.message#"/>
	</cfcatch>
</cftry>