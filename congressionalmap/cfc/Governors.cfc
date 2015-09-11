<cfcomponent displayname="Governors" hint="Loads Governor Information from an external XML file for congressional map.">

	<cfscript>
		this.instance = StructNew();
		this.instance.xmlURL = "/customcf/congressionalmap/xml/governors.xml";
		this.instance.xmlFile = ExpandPath(this.instance.xmlURL);
		this.instance.governors_array = ArrayNew(1);
		this.instance.governors_struct = StructNew();
	</cfscript>
					 
	<cffunction name="init" output="false" returntype="void"
		hint="Pulls the governor XML file into application scope for usage" access="remote">
		<cftry>
        <cfset this.xmlGov = xmlParse(this.instance.xmlFile)>
        <cfcatch type="any">
        	<cfoutput>
        		<cfdump var="#cfcatch.Message#" label="Error in Governor XML file.">
        	</cfoutput>
        </cfcatch> 
        </cftry>
        <cfset populateGovernorArray()>
	</cffunction>

	<cffunction name="generateGovStructure" access="private" output="false" returntype="struct">
		<cfargument name="parentXML" type="any" required="true" />
		<cfset var governor = structNew() />
		<cfloop collection="#arguments.parentXML.xmlAttributes#" item="attrName">
			<cfset governor[attrName] = arguments.parentXML.xmlAttributes[attrName] />
		</cfloop>
		<cfreturn governor />
 	</cffunction> 
	
	<cffunction name="populateGovernorArray" access="public" output="false" returntype="void">
		<cfloop from="1" to="#arrayLen(this.xmlGov.governors.xmlChildren)#" index="i">
			<cfset myGovernor = generateGovStructure(this.xmlGov.governors.xmlChildren[i]) />
			<cfset ArrayAppend(this.instance.governors_array, myGovernor) />
			<cfset StructInsert(this.instance.governors_struct,this.xmlGov.governors.xmlChildren[i].xmlAttributes['id'], myGovernor, 'true')>
		</cfloop>
	</cffunction>


</cfcomponent>	