<cfcomponent displayname="Legislators" 
			 hint="Loads Senator Information from an external XML file for congressional map.">

	<cfscript>
		this.instance = StructNew();
		this.instance.xmlURL = "/customcf/congressionalmap/xml/congress.xml";
		this.instance.xmlFile = ExpandPath(this.instance.xmlURL);
		this.instance.senators_array = ArrayNew(1);
		this.instance.senators_struct = StructNew();
		this.instance.representatives_array = ArrayNew(1);
		this.instance.representatives_struct = StructNew();
	</cfscript>
					 
	<cffunction name="init" output="false" returntype="void"
		hint="Pulls the senator XML file into application scope for usage" access="remote">
		<cftry>
        <cfset this.xmlGov = xmlParse(this.instance.xmlFile)>
        <cfcatch type="any">
        	<cfoutput>
        		<cfdump var="#cfcatch.Message#" label="Error in Congress XML file.">
        	</cfoutput>
        </cfcatch> 
        </cftry>
        <cfset populateLegislatorsArray()>
		<cfset populateSenatorsStruct()>
		<cfset populateRepresentativesStruct()>
	</cffunction>

	<cffunction name="generateCongressStructure" access="private" output="false" returntype="struct">
		<cfargument name="parentXML" type="any" required="true" />
		<cfset var senator = structNew() />
		<cfloop collection="#arguments.parentXML.xmlAttributes#" item="attrName">
			<cfset senator[attrName] = arguments.parentXML.xmlAttributes[attrName] />
		</cfloop>
		<cfreturn senator />
 	</cffunction> 
	
	<cffunction name="populateLegislatorsArray" access="public" output="false" returntype="void">
		<cfloop from="1" to="#arrayLen(this.xmlGov.congress.xmlChildren)#" index="i">
			<cfset mySenator = generateCongressStructure(this.xmlGov.congress.xmlChildren[i]) />
			<cfif StructKeyExists(mysenator,"ROLE_TYPE") AND CompareNoCase("Senator", mysenator.ROLE_TYPE) EQ 0>
				<cfset ArrayAppend(this.instance.senators_array, mySenator) />
			<cfelseif StructKeyExists(mysenator, "ROLE_TYPE") AND CompareNoCase("Representative", mysenator.ROLE_TYPE EQ 0)>
				<cfset ArrayAppend(this.instance.representatives_array, mySenator)/>	
			</cfif>	
		</cfloop>
	</cffunction>

	<cffunction name="populateSenatorsStruct" access="public" output="false" returntype="void">
		<cfloop array="#this.instance.senators_array#" index="iSenator">
			<cfif NOT StructKeyExists(this.instance.senators_struct, iSenator.state)>
				<cfset senators_array = ArrayNew(1)>
				<cfset senators_array[1] = iSenator/>
				<cfset StructInsert(this.instance.senators_struct, "#iSenator.state#", senators_array, 'true')/>
			<cfelse>
				<cfset this.instance.senators_struct["#iSenator.state#"][2] = iSenator/>	
			</cfif>					
		</cfloop>
	</cffunction>


	<cffunction name="populateRepresentativesStruct" access="public" output="false" returntype="void">
		<cfloop array="#this.instance.representatives_array#" index="iRep">
			<cfif NOT StructKeyExists(this.instance.representatives_struct, iRep.state)>
				<cfset members_struct = StructNew()/>
				<cfset Variables.district_number = "00"/>
				<cfset StructInsert(this.instance.representatives_struct, "#iRep.state#", members_struct, true)/>
				<cfif StructKeyExists(iRep, "district") AND Len(Trim(iRep.district)) GT 0>
					<cfif Len(iRep.district) EQ 1>
						<cfset Variables.district_number = "0" & Trim(iRep.district)/>
					<cfelseif Len(iRep.district) GT 1>
						<cfset Variables.district_number = Trim(iRep.district)/> 
					</cfif>		
					<cfset Variables.district_key = UCase(Trim(iRep.state)) & "-" & Trim(Variables.district_number)>
					<!---<cfset members_struct["#iRep.district_name#"] = iRep/>--->
					<cfset this.instance.representatives_struct["#iRep.state#"].members_struct["#Variables.district_key#"] = iRep/>
				</cfif>	
				<!---<cfset StructInsert(this.instance.representatives_struct, "#iRep.state#", members_struct["#iRep.district_name#"], 'true')/>--->
				
			<cfelse>
				<cfif StructKeyExists(iRep, "district_name") AND Len(Trim(iRep.district_name)) GT 0>
					<cfset this.instance.representatives_struct["#iRep.state#"].members_struct["#iRep.district_name#"] = iRep/>
				</cfif>	
			</cfif>					
		</cfloop>
	</cffunction>

			<!---<cfset StructInsert(this.instance.senators_struct,this.xmlGov.congress.xmlChildren[i].xmlAttributes['state'], myGovernor, 'true')>--->


</cfcomponent>	