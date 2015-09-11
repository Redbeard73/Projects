<cfcomponent>

    <cffunction name="SetVariable" access="remote" returnType="struct" returnFormat="json" output="true">
    	<cfargument name="dist" type="string" required="yes">
    	<cfargument name="coords" type="string" required="yes">
        
        <cfscript>
		
			dName = replace(arguments.dist,'-','');
			SetVariable('application.maps.coords.#dName#', arguments.coords);
			
			ret = structNew();
			ret["created"] = now();
			return ret;
		</cfscript>
        
    </cffunction>
    
</cfcomponent>