<cfcomponent>
	<cfscript>
		this.instance = StructNew();
		this.instance.url = '/customcf/congressionalmap/';
		this.instance.xmlURL = this.instance.url & "init.xml";
		this.instance.xmlFile = ExpandPath(this.instance.xmlURL);
	</cfscript>
	<cffunction name="settings" output="yes" returntype="struct">
    	<cftry>
			<cfscript>
                retStr = structNew();		
                xmlTxt = XMLParse(FileRead(this.instance.xmlFile));
                retStr.apiKey = xmlTxt.settings.apiKey.xmlAttributes.variable;
                retStr.clientId = xmlTxt.settings.clientId.xmlAttributes.variable;
                retStr.datasource = xmlTxt.settings.datasource.xmlAttributes.variable;
                retStr.us_center = xmlTxt.settings.us_center.xmlAttributes.variable;
                retStr.url = this.instance.url;
                retStr.dir = ListDeleteAt(ExpandPath(retStr.url),listlen(ExpandPath(retStr.url),'/'),'/') & '/';
                for(i=1;i lte ArrayLen(xmlTxt.settings.fusionTables.xmlChildren);i=i+1)
                {
                    tbl = xmlTxt.settings.fusionTables.xmlChildren[i];
                    SetVariable('retStr.' & tbl.xmlAttributes.variable,tbl.xmlAttributes.key);
                }			
                return retStr;
            </cfscript>
        	<cfcatch><cfdump var="#cfcatch#"></cfcatch>
       	</cftry>
    </cffunction>
    
    <cffunction access="public" name="CacheState" output="no" returntype="void">
    	<cfargument name="state" type="string" required="yes">        
        <cfquery name='qDist' datasource="#application.maps.datasource#">
            SELECT s.ABBREVIATION_TXT,
              d.USA_STATE_ID,
              NVL(d.CONGRESSIONAL_DISTRICT_NBR,'00') as CONGRESSIONAL_DISTRICT_NBR
            FROM CONGRESSIONAL_DISTRICT d
            RIGHT JOIN USA_STATE s
            ON s.USA_STATE_ID        = d.USA_STATE_ID
            WHERE s.ABBREVIATION_TXT = '#UCase(url.state)#'
        </cfquery>    
		<cfscript>    
			oMap = createobject('component','cfc.congmap'); 
            st = arguments.state;    
            SetVariable('application.maps.strHomeData' & st,oMap.GetExpCounts(application.maps.yrMin,application.maps.yrMax,st));
            SetVariable('application.maps.qExpDataTable' & st,oMap.GetStateDataTable(st,application.maps.yrMin,application.maps.yrMax));
            SetVariable('application.maps.qExpChart' & st,oMap.GetExpChart(application.maps.yrMin,application.maps.yrMax,st));
            SetVariable('application.maps.qDistricts' & st,oMap.GetDistricts(st));        
            for(i=1;i lte qDist.recordcount;i=i+1)
            {
                di = qDist.CONGRESSIONAL_DISTRICT_NBR[i];
                if(len(di) eq 1) di = '0' & di;			
                SetVariable('application.maps.strHomeData' & st & di,oMap.GetExpCounts(application.maps.yrMin,application.maps.yrMax,st,di));
                SetVariable('application.maps.qExpChart' & st & di,oMap.GetExpChart(application.maps.yrMin,application.maps.yrMax,st,di));
                SetVariable('application.maps.qExpDataTable' & st & di,oMap.GetDistDataTable(st,di,application.maps.yrMin,application.maps.yrMax));			
            }
        </cfscript>       
        <cfreturn/>     
    </cffunction>
    
    <cffunction access="public" name="CacheDist" output="no" returntype="void">
    	<cfargument name="state" type="string" required="yes">        
    	<cfargument name="district" type="string" required="yes">        
		<cfscript>    
            st = arguments.state;    
			di = arguments.district;
			if(len(di) eq 1) di = '0' & di;			
			oMap = createobject('component','cfc.congmap'); 
			SetVariable('application.maps.strHomeData' & st & di,oMap.GetExpCounts(application.maps.yrMin,application.maps.yrMax,st,di));
			//SetVariable('application.maps.strHomeData' & st & di,application.oMap.GetExpCounts(application.maps.yrMin,application.maps.yrMax,st,di));
        </cfscript>        
        <cfreturn/>
    </cffunction>
    
</cfcomponent>