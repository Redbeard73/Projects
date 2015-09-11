<cfscript>
	logFileName = 'CongressionalMap';	
    logsFile = Server.ColdFusion.RootDir & '/logs/#logFileName#.log';
	
	if(!isDefined('application.maps.strExportersUS')) url.recacheCongMap = 1;

	if (!IsDefined('application.oExp') or isDefined('url.recacheCongMap')){
		application.oExp = CreateObject("component","cfc.exporters");
	}
	if (!IsDefined('application.oFusion') or isDefined('url.recacheCongMap')){
		application.oFusion = createobject('component','cfc.fusion');     
	}
	if (!IsDefined('application.oMap') or isDefined('url.recacheCongMap')){
		application.oMap = createobject('component','cfc.congmap'); 
	}
	if(!isDefined('application.init') or isDefined('url.recacheCongMap')){
		application.init = createobject('component','cfc.init');
	}
	if(!isDefined('application.maps') or isDefined('url.recacheCongMap')){
		WriteLog(type="Information", file="#logFileName#", text="Rebuild Congressional Maps Cache");				
		application.maps = structNew();		
		application.maps = application.init.settings();
		application.maps.gAuth = application.oFusion.auth();	
		application.maps.yrMax = application.oMap.GetMaxYear();
		application.maps.yrMin= application.oMap.GetMinYear();
		application.maps.qStates = application.oMap.GetStates();
		application.maps.qDistricts = application.oMap.GetDistricts();	
	}
	if(!isDefined('application.maps.qExporterMaster') or isDefined('url.recacheCongMap')){
		application.maps.qExporterMaster = application.oExp.GetExporterMasterTable(application.maps.yrMin,application.maps.yrMax);
	}
	if(!isDefined('application.maps.qDestinationMaster') or isDefined('url.recacheCongMap')){
		application.maps.qDestinationMaster = application.oExp.GetDestinationMasterTable(application.maps.yrMin,application.maps.yrMax);
	}
</cfscript>

<cfif isDefined('url.recacheCongMap') or isDefined('url.recacheCongMapData')>
	<cfset qry = application.oMap.GetDistricts()>
    <!--- Create US Data --->
    <cfset application.maps.strExportersUS = application.oExp.GetExporterCounts(application.maps.yrMin,application.maps.yrMax,'US')>
    
    <!--- Create Territiry Data --->
    <cfset application.maps.lsTerr = 'AK,AS,GU,HI,MP,PR,VI'>
    <cfset application.maps.lsTerrZoom = '1,8,7,4,7,6,8'>
    <cfset application.maps.strExportersTerr = application.oExp.GetExporterCounts(application.maps.yrMin,application.maps.yrMax,application.maps.lsTerr)>
    
    <cfset application.maps.arrTerr = ArrayNew(1)>
    <cfloop index="i" from="1" to="#listlen(application.maps.lsTerr)#">
        <cfset st = ListGetAt(application.maps.lsTerr,i)>      
        <cfquery name="q" dbtype="query">
            select * from application.maps.qStates where abbreviation_txt = '#st#'
        </cfquery>                
        <cfscript>
            QueryAddColumn(q,'TerrZoomLevel', ArrayNew(1));
            QuerySetCell(q,'TerrZoomLevel',listgetat(application.maps.lsTerrZoom,i),1);		
            ArrayAppend(application.maps.arrTerr,q);
        </cfscript>
    </cfloop>
    
    <!--- Create State / District Data --->
    <cfoutput query="qry" group="ABBREVIATION_TXT">
        <Cfset SetVariable('application.maps.strExporters#ABBREVIATION_TXT#',application.oExp.GetExporterCounts(application.maps.yrMin,application.maps.yrMax,ABBREVIATION_TXT))>
        <Cfset SetVariable('application.maps.qDistricts#ABBREVIATION_TXT#',application.oMap.GetDistricts(ABBREVIATION_TXT))>
        <cfoutput>
            <Cfset CONGRESSIONAL_DISTRICT_TXT = iif(len(CONGRESSIONAL_DISTRICT_NBR) eq 1,de('0'),de('')) & CONGRESSIONAL_DISTRICT_NBR>
            <Cfset SetVariable('application.maps.strExporters#ABBREVIATION_TXT##CONGRESSIONAL_DISTRICT_TXT#',application.oExp.GetExporterCounts(application.maps.yrMin,application.maps.yrMax,ABBREVIATION_TXT,CONGRESSIONAL_DISTRICT_TXT))>
            <cfflush>        
        </cfoutput>    
    </cfoutput>
    
</cfif>