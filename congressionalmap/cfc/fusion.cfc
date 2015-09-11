<cfcomponent>

	<cffunction name="auth" output="no" returntype="string">
        <cfhttp  url="https://www.google.com/accounts/ClientLogin"  method="post" charset="utf-8">
            <cfhttpparam type="formfield" name="accountType" value="GOOGLE"></cfhttpparam>
            <cfhttpparam type="formfield" name="Email" value="cmap@exim.gov"></cfhttpparam>
            <cfhttpparam type="formfield" name="Passwd" value="c0NgM4ps"></cfhttpparam>
            <cfhttpparam type="formfield" name="accountType" value="GOOGLE"></cfhttpparam>
            <cfhttpparam type="formfield" name="service" value="fusiontables"></cfhttpparam>
        </cfhttp>
        <cfreturn listtoarray(cfhttp.FileContent,'=')[4]>        
    </cffunction>

	<cffunction name="get" output="true" returntype="string">
		<cfargument name="sql" type="string" required="yes">
        <cfhttp url="https://www.googleapis.com/fusiontables/v1/query" method="get"> 
            <cfhttpparam type="url" name="sql" value="#arguments.sql#" /> 
            <cfhttpparam type="url" name="key" value="#application.maps.apiKey#" /> 
        </cfhttp>  
<!---     
		<cfoutput>
        	<span<cfif cfhttp.statusCode neq '200 OK'> style="color:##F00;"</cfif>>#now()#,"#cfhttp.statusCode#","#sql#"</span><cfflush>
		</cfoutput>
--->
        <cfreturn cfhttp.filecontent>
	</cffunction>
    
	<cffunction name="post" output="no" returntype="string" verifyclient="no" securejson="false">
		<cfargument name="sql" type="string" required="yes">        
        <cfhttp url="https://www.google.com/fusiontables/api/query" method="post" charset="utf-8">
            <cfhttpparam type="formfield" name="sql" value="#sql#"/>
            <cfhttpparam type="header" name="Authorization" value="GoogleLogin auth=#application.maps.gAuth#"></cfhttpparam>
            <cfhttpparam type="header" name="token" value="#application.maps.gAuth#"></cfhttpparam>
        </cfhttp>    
<!---        
		<cfoutput>
        	<span<cfif cfhttp.statusCode neq '200 OK'> style="color:##F00;"</cfif>>#now()#,"#cfhttp.statusCode#","#sql#"</span><cfflush>
		</cfoutput>
--->
        <cfreturn cfhttp.statusCode>
	</cffunction>

	<cffunction name="select" returntype="query" output="true">
		<cfargument name="sql" type="string" required="yes">	
		<cftry>
            <cfscript>
				json = get(sql);				
                cols = ArrayToList(deserializeJSON(replace(json,'NaN','""','ALL')).columns);
				qry = querynew(cols);
				try{
					rows = deserializeJSON(replace(json,'NaN','""','ALL').toString()).rows;
					for(r=1;r lte arrayLen(rows);r=r+1){
						QueryAddRow(qry);
						for(c=1;c lte listlen(cols);c=c+1)
							QuerySetCell(qry,listgetat(cols,c),rows[r][c]);
					}
				} catch (any e) {}
            </cfscript>
            <cfreturn qry>
        	<cfcatch><cfdump var="#sql#"><cfdump var="#cfcatch#"></cfcatch>
        </cftry>
	</cffunction>
    
	<cffunction name="update" returntype="boolean" output="true">
    	<cfargument name="tbl" type="string" required="yes">
    	<cfargument name="valPairs" type="string" required="yes">
    	<cfargument name="where" type="string" required="yes">
        <cfset ret = false>
		<cftry>        
			<cfscript>
				if(lcase(listfirst(where,'=')) neq 'rowid'){          
					sql_get = 'select ROWID from #tbl# where #where#';                
					q = select(sql_get); 
					if(q.recordCount)
					{
						ret = post("UPDATE #tbl# SET #valPairs# WHERE ROWID = '#q.rowid#'");
					}
				} else {
                    ret = post("UPDATE #tbl# SET #valPairs# WHERE #where#");
                }
            </cfscript>
        	<cfcatch><cfdump var="#cfcatch#"></cfcatch>
        </cftry>        
        <cfreturn ret>
    </cffunction>
    
	<cffunction name="batchPost" returntype="void" output="true">
    	<cfargument name="sql" type="string" required="yes">
		<cftry>        
			<cfscript>
				post(sql);
            </cfscript>
        	<cfcatch><cfdump var="#cfcatch#"></cfcatch>
        </cftry>        
    </cffunction>
    
	<cffunction name="batchGet" returntype="query" output="true">
    	<cfargument name="sql" type="string" required="yes">
		<cftry>        
			<cfscript>
				json = get(sql);				
                cols = ArrayToList(deserializeJSON(replace(json,'NaN','""','ALL')).columns);
                rows = deserializeJSON(replace(json,'NaN','""','ALL').toString()).rows;
                qry = querynew(cols);
                for(r=1;r lte arrayLen(rows);r=r+1){
                    QueryAddRow(qry);
                    for(c=1;c lte listlen(cols);c=c+1)
						QuerySetCell(qry,listgetat(cols,c),rows[r][c]);
                }
				return qry;
            </cfscript>
        	<cfcatch><cfdump var="#cfcatch#"></cfcatch>
        </cftry>        
    </cffunction>
    
	<cffunction name="insert" returntype="boolean" output="true">
    	<cfargument name="tbl" type="string" required="yes">
    	<cfargument name="columns" type="string" required="yes">
    	<cfargument name="values" type="string" required="yes">
        <cfset ret = false>
		<cftry>        
			<cfscript>
				ret = post("INSERT INTO #tbl# (#columns#) VALUES (#values#)");
            </cfscript>
        	<cfcatch><cfdump var="#cfcatch#"></cfcatch>
        </cftry>   
        <cfreturn ret>     
    </cffunction>
    
	<cffunction name="deleteAll" returntype="void" output="true">
    	<cfargument name="tbl" type="string" required="yes">	
		<cftry>        
			<cfscript>
				post("DELETE FROM #tbl#");
            </cfscript>
        	<cfcatch><cfdump var="#cfcatch#"></cfcatch>
        </cftry>        
    </cffunction>
    
    <cffunction access="public" name="GetTables" output="yes" returntype="any" returnformat="JSON">
    	<cfhttp url="https://www.googleapis.com/fusiontables/v1/tables">
        	<cfhttpparam type="header" name="Authorization" value="GoogleLogin auth=#application.maps.gAuth#"></cfhttpparam>
        	<cfhttpparam type="url" name="key" value="#application.maps.apiKey#" />
        </cfhttp>
		<cfreturn cfhttp.FileContent>
    </cffunction>
    
    
    <cffunction access="public" name="GetLatLon" output="yes" returntype="struct">
    	<cfargument name="EXPORTER_ADDRESS" type="string" required="yes">
    
    	<cfscript>
			address = Replace(EXPORTER_ADDRESS,' ','+','ALL');
			address = Replace(address,'.','+','ALL');
			ret = structNew();
			ret.address = address;
			ret.lat = 0;
			ret.lon = 0;
			ret.error = '';
		</cfscript>


		<cfhttp url="http://maps.googleapis.com/maps/api/geocode/json?address=#ret.address#&sensor=false" result="thisVar" charset="UTF-8" />     
		<cfscript>
			ret.Statuscode = thisVar.Statuscode;
			results = DeserializeJSON(thisVar.Filecontent.toString()).results;			
            if(ret.StatusCode eq '200 OK')
            {
				try{
            	ret.lat = results[1].geometry.location.lat;
                ret.lon = results[1].geometry.location.lng;
				} catch(any e){}
            }
       	</cfscript>
        
    	<cfreturn ret>
    </cffunction>
    
</cfcomponent>