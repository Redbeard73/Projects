<cfscript>
	if(!isDefined('application.maps.strExportersUS')) url.recacheCongMap = 1;
	if (!IsDefined('application.oExp') or isDefined('url.recacheCongMap')){
		application.oExp = CreateObject("component","cfc.exporters");
	}
	if (!IsDefined('application.oMap') or isDefined('url.recacheCongMap')){
		application.oMap = createobject('component','cfc.congmap'); 
	}
	if(!isDefined('application.init') or isDefined('url.recacheCongMap')){
		application.init = createobject('component','cfc.init');
	}
	if(!isDefined('application.maps') or isDefined('url.recacheCongMap')){			
		application.maps = structNew();		
		application.maps = application.init.settings();	
		application.maps.yrMax = application.oMap.GetMaxYear();
		application.maps.yrMin= application.oMap.GetMinYear();
		application.maps.qStates = application.oMap.GetStates();
	}
	if(!isDefined('application.maps.qExporterMaster') or isDefined('url.recacheCongMap')){
		application.maps.qExporterMaster = application.oExp.GetExporterMasterTable(application.maps.yrMin,application.maps.yrMax);
	}
	if(!isDefined('application.maps.qDestinationMaster') or isDefined('url.recacheCongMap')){
		application.maps.qDestinationMaster = application.oExp.GetDestinationMasterTable(application.maps.yrMin,application.maps.yrMax);
	}
</cfscript>

<cfif isDefined('url.recacheCongMap') or  isDefined('url.recacheCongMapData')>
	<cfset qry = application.oMap.GetDistricts()>
    <!--- Create US Data --->
    <cfset application.maps.strExportersUS = application.oExp.GetExporterCounts(application.maps.yrMin,application.maps.yrMax,'US')>
</cfif>