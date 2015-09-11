<cfcomponent displayname="Congressional Map" hint="Data handler for Congressional Maps">

	<cfscript>
		this.instance = StructNew();
		this.instance.URL = "/customcf/congressionalmap/";
		this.instance.FilePath = ExpandPath(this.instance.URL);
		this.instance.yrMin = 2008;
		this.instance.yrMax = year(now());
		if(month(now()) gte 10) this.instance.yrMax = this.instance.yrMax + 1;
	</cfscript>
    
<!--- GetMaxYear --->
	<cffunction access="public" name="GetMaxYear" output="no" returntype="numeric">
        <cfreturn this.instance.yrMax>
	</cffunction>
    
<!--- GetMinYear --->
	<cffunction access="public" name="GetMinYear" output="no" returntype="numeric">
        <cfreturn this.instance.yrMin>
	</cffunction>
    
<!--- GetStates --->
	<cffunction access="public" name="GetStates" output="no" returntype="query">
    	<cfquery name="qStates" datasource="#application.maps.datasource#">
            SELECT USA_STATE.NAME_TXT,USA_STATE.ABBREVIATION_TXT,USA_STATE.ABBREVIATION_TXT,USA_STATE.LATITUDE_CENTER_NBR,USA_STATE.LONGITUDE_CENTER_NBR,USA_STATE.ZOOM_INITIAL_NBR
            FROM USA_STATE
            ORDER BY USA_STATE.ABBREVIATION_TXT
        </cfquery>
        <cfreturn qStates>
	</cffunction>
    
<!--- GetDistricts --->
	<cffunction access="public" name="GetDistricts" output="yes" returntype="query">
    	<cfargument name="ABBREVIATION_TXT" type="string" required="no" default="XX">
    	<cfquery name="qDistricts" datasource="#application.maps.datasource#">
            SELECT DISTINCT  s.NAME_TXT, s.ABBREVIATION_TXT, c.CONGRESSIONAL_DISTRICT_NBR, c.LATITUDE_CENTER_NBR, c.LONGITUDE_CENTER_NBR, c.ZOOM_INITIAL_NBR
            FROM USA_STATE s INNER JOIN CONGRESSIONAL_DISTRICT c ON s.USA_STATE_ID = c.USA_STATE_ID
            <cfif arguments.ABBREVIATION_TXT neq 'XX'>
            	WHERE s.ABBREVIATION_TXT = '#arguments.ABBREVIATION_TXT#'
            </cfif>
            ORDER BY s.ABBREVIATION_TXT, c.CONGRESSIONAL_DISTRICT_NBR
        </cfquery>            
        <cfreturn qDistricts>
	</cffunction>
    
<!--- GetStateExpDataAll --->
	<cffunction access="public" name="GetStateExpDataAll" output="no" returntype="query">
    	<cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
    	<cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <Cfset where = ' d.DT_YR_FSCL >= #arguments.yStart# AND d.DT_YR_FSCL <= #arguments.yEnd#'>
    	<cfquery name="qData" datasource="#application.maps.datasource#">
            SELECT USA_STATE.NAME_TXT,
              USA_STATE.ABBREVIATION_TXT,
              NVL(d.Disbursements, 0)  AS Disbursements,
              NVL(d.Authorizations, 0) AS Authorizations,
              NVL(a.SalesSupported, 0) AS SalesSupported,
              NVL(d.TotalAuthorizations, 0) AS TotalAuthorizations,
              NVL(c.EXPORTER_COUNT, 0) AS EXPORTER_COUNT,
              NVL(d.WO_SUPPORTED, 0)   AS WO_SUPPORTED,
              NVL(d.MO_SUPPORTED, 0)   AS MO_SUPPORTED,
              NVL(d.RE_SUPPORTED, 0)   AS RE_SUPPORTED,
              NVL(d.EB_SUPPORTED, 0)   AS EB_SUPPORTED,
              NVL(d.SB_SUPPORTED, 0)   AS SB_SUPPORTED
            FROM USA_STATE
            LEFT JOIN
              (SELECT d.EXPORTER_STATE,
                SUM(d.AMT_SUPPORTED)        AS Disbursements,
                COUNT(d.AMT_SUPPORTED)      AS Authorizations,
                SUM(d.WO_SUPPORTED)         AS WO_SUPPORTED,
                SUM(d.MO_SUPPORTED)         AS MO_SUPPORTED,
                SUM(d.RE_SUPPORTED)         AS RE_SUPPORTED,
                SUM(d.EB_SUPPORTED)         AS EB_SUPPORTED,
                SUM(d.SB_SUPPORTED)         AS SB_SUPPORTED,
                SUM(d.AMT_EXPORT_SUPPORTED) AS TotalAuthorizations
              FROM MAP_CONG_DIST_DTL d
              WHERE #PreserveSingleQuotes(where)#
              GROUP BY d.EXPORTER_STATE
              ) d
            ON USA_STATE.NAME_TXT = d.EXPORTER_STATE
            LEFT JOIN
              (SELECT d.EXPORTER_STATE,
                SUM(d.AMT_AUTH) AS SalesSupported
              FROM MAP_CONG_DIST_AUTH d
              WHERE #PreserveSingleQuotes(where)#
              GROUP BY d.EXPORTER_STATE
              ORDER BY d.EXPORTER_STATE
              ) a
            ON USA_STATE.NAME_TXT = a.EXPORTER_STATE
            LEFT JOIN
              (SELECT COUNT(DISTINCT d.EXPORTER_NAME) AS EXPORTER_COUNT,
                d.EXPORTER_STATE
              FROM MAP_CONG_DIST_DTL d
              WHERE #PreserveSingleQuotes(where)#
              GROUP BY d.EXPORTER_STATE
              ORDER BY d.EXPORTER_STATE
              ) c
            ON USA_STATE.NAME_TXT = c.EXPORTER_STATE
            ORDER BY USA_STATE.ABBREVIATION_TXT
        </cfquery>
        <cfreturn qData>
	</cffunction>
    
<!--- GetDistExpDataAll --->
	<cffunction access="public" name="GetDistExpDataAll" output="no" returntype="query">
    	<cfargument name="DT_YR_FSCL" type="numeric" required="no">
    	<cfquery name="qData" datasource="#application.maps.datasource#">
            SELECT s.ABBREVIATION_TXT,
              NVL(d.CNGRSNL_DSTRCT, '00') AS CNGRSNL_DSTRCT,
              COUNT(d.EXPORTER_NAME)      AS EXPORTER_COUNT,
              SUM(d.WO_SUPPORTED)         AS WO_SUPPORTED,
              SUM(d.MO_SUPPORTED)         AS MO_SUPPORTED,
              SUM(d.RE_SUPPORTED)         AS RE_SUPPORTED,
              SUM(d.EB_SUPPORTED)         AS EB_SUPPORTED,
              SUM(d.SB_SUPPORTED)         AS SB_SUPPORTED,
              SUM(d.AMT_SUPPORTED)        AS AMT_SUPPORTED,
              SUM(d.AMT_EXPORT_SUPPORTED) AS AMT_EXPORT_SUPPORTED
            FROM USA_STATE s
            INNER JOIN MAP_CONG_DIST_DTL d
            ON s.NAME_TXT      = d.EXPORTER_STATE
            WHERE d.DT_YR_FSCL = #DT_YR_FSCL#
            GROUP BY s.ABBREVIATION_TXT,
              NVL(d.CNGRSNL_DSTRCT, '00'),
              d.DT_YR_FSCL
            ORDER BY s.ABBREVIATION_TXT,
              NVL(d.CNGRSNL_DSTRCT, '00')
        </cfquery>
        <cfreturn qData>
	</cffunction>
    
    

    
<!--- GetExpCounts --->
    <cffunction access="public" name="GetExpCounts" output="yes" returntype="struct">
    	<cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
    	<cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
    	<cfargument name="State_List" type="string" required="no" default="">
    	<cfargument name="CNGRSNL_DSTRCT" type="string" required="no" default="">

        <cfset retStr = StructNew()>
        <Cfset retStr.created = now()> 
        <Cfset where = 'd.DT_YR_FSCL >= #arguments.yStart# AND d.DT_YR_FSCL <= #arguments.yEnd#'>
		<cfif len(arguments.CNGRSNL_DSTRCT)>
			<cfset where = where & " AND NVL(d.CNGRSNL_DSTRCT, '00') = '#arguments.CNGRSNL_DSTRCT#'">
        </cfif>
		<cfif len(arguments.State_List)>
            <cfset stList = ''>
            <cfloop index="st" list="#State_List#"><cfset stList = ListAppend(stList,"'" & st & "'")></cfloop>
            <cfset where  = where & " AND s.ABBREVIATION_TXT IN (#stList#)">
        </cfif>
        <cfquery name="qMain" datasource="#application.maps.datasource#">
            SELECT DISTINCT d.EXPORTER_NAME, d.FLAG_SB,d.FLAG_MO,d.FLAG_WO,d.FLAG_ENV,d.FLAG_RE
            FROM MAP_CONG_DIST_DTL d INNER JOIN USA_STATE s ON d.EXPORTER_STATE = s.NAME_TXT
            WHERE #PreserveSingleQuotes(where)#
            ORDER BY d.EXPORTER_NAME
        </cfquery>
        <cfset retStr.COUNT_ALL = qMain.recordCount>
        
        <cfset lst = 'SB,WO,MO,ENV,RE'>
        <cfloop index="flg" list="#lst#">
            <cfquery name="qFlagData" dbtype="query">
                select count(*) as EXPORTER_COUNT from qMain WHERE FLAG_#flg# = 'Yes'
            </cfquery>              
            <cfset SetVariable('retStr.COUNT_' & flg, iif(isNumeric(qFlagData.EXPORTER_COUNT),qFlagData.EXPORTER_COUNT,0))>
        </cfloop>

        <cfquery name="qTopDest" maxrows="3" datasource="#application.maps.datasource#">
            SELECT d.EXPORT_DESTINATION, SUM(d.AMT_SUPPORTED)   AS exportdollars, COUNT(d.AMT_SUPPORTED) AS exports
            FROM MAP_CONG_DIST_DTL d RIGHT JOIN USA_STATE s ON d.EXPORTER_STATE = s.NAME_TXT
            WHERE #PreserveSingleQuotes(where)#
            AND d.EXPORT_DESTINATION <> 'Various'
            GROUP BY d.EXPORT_DESTINATION
            ORDER BY SUM(d.AMT_SUPPORTED) DESC
        </cfquery>
        <cfset retStr.topDestArr = ArrayNew(1)> 
        <cfloop query="qTopDest">
        	<cfset ArrayAppend(retStr.topDestArr,qTopDest.EXPORT_DESTINATION)>
        </cfloop>
        <cfset retStr.topDestList = Replace(ArrayToList(retStr.topDestArr),',',', ','ALL')>
        
        <cfquery name="GetAuth" datasource="#application.maps.datasource#">
            SELECT NVL(SUM(d.AMT_AUTH),0) AS SalesSupported
            FROM MAP_CONG_DIST_AUTH d INNER JOIN USA_STATE s ON d.EXPORTER_STATE = s.NAME_TXT
            WHERE #PreserveSingleQuotes(where)#
        </cfquery>
        <cfquery name="GetAmts" datasource="#application.maps.datasource#">
            SELECT NVL(SUM(d.AMT_SUPPORTED),0) AS Disbursements, NVL(COUNT(d.AMT_SUPPORTED),0) AS Authorizations, NVL(SUM(d.AMT_EXPORT_SUPPORTED),0) AS TotalAuthorizations
            FROM MAP_CONG_DIST_DTL d
            INNER JOIN USA_STATE s
            ON d.EXPORTER_STATE = s.NAME_TXT
            WHERE #PreserveSingleQuotes(where)#
        </cfquery>
        
        <cfset retStr.SalesSupported = GetAuth.SalesSupported>
        <cfset retStr.Disbursements = GetAmts.Disbursements>
        <cfset retStr.Authorizations = GetAmts.Authorizations>
        <cfset retStr.TotalAuthorizations = GetAmts.TotalAuthorizations>
        <cfquery name="GetTopExp" maxrows="3" datasource="#application.maps.datasource#">        
            SELECT d.EXPORTER_NAME
            FROM USA_STATE s LEFT JOIN MAP_CONG_DIST_DTL d ON s.NAME_TXT = d.EXPORTER_STATE
            WHERE #PreserveSingleQuotes(where)#
            GROUP BY d.EXPORTER_NAME
            ORDER BY SUM(d.AMT_SUPPORTED) DESC Nulls Last        
        </cfquery>
        <cfset retStr.topExportersArr = ArrayNew(1)> 
        <cfloop query="GetTopExp">
        	<cfset ArrayAppend(retStr.topExportersArr,GetTopExp.EXPORTER_NAME)>
        </cfloop>
        <cfset retStr.topExportersList = Replace(ArrayToList(retStr.topExportersArr),',',', ','ALL')>
        <cfreturn retStr>
    </cffunction>
    
<!--- GetExpCountsJSON --->
    <cffunction name="GetExpCountsJSON" access="remote" returnType="struct" returnFormat="json" output="false">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="State_List" type="string" required="no" default="">
        <cfargument name="CNGRSNL_DSTRCT" type="string" required="no" default="">        
        <cfscript>
			str = GetExpCounts(yStart,yEnd,State_List,CNGRSNL_DSTRCT);			
			ret = structNew();
			ret["created"] = str.created;
			ret["topDestList"] = str.topDestList;			
			for(i=1;i lte arraylen(str.topExportersArr);i=i+1) ret["topExporter" & i] = str.topExportersArr[i];			
			ret["COUNT_ALL"] = NumberFormat(str.COUNT_ALL,',');
			ret["COUNT_SB"] = NumberFormat(str.COUNT_SB,',');
			ret["COUNT_WO"] = NumberFormat(str.COUNT_WO,',');
			ret["COUNT_MO"] = NumberFormat(str.COUNT_MO,',');
			ret["COUNT_ENV"] = NumberFormat(str.COUNT_ENV,',');
			ret["COUNT_RE"] = NumberFormat(str.COUNT_RE,',');
			ret["SalesSupported"] = NumberFormat(str.SalesSupported,',');
        	ret["Disbursements"] = NumberFormat(str.Disbursements,',');
			ret["Authorizations"] = NumberFormat(str.Authorizations,',');
			ret["TotalAuthorizations"] = NumberFormat(str.TotalAuthorizations,',');	
			ret["SalesSupportedAbbr"] = DollarAbbr(str.SalesSupported);
			ret["DisbursementsAbbr"] = DollarAbbr(str.Disbursements);
			ret["TotalAuthorizationsAbbr"] = DollarAbbr(str.TotalAuthorizations);
			
			return ret;
        </cfscript>
	</cffunction>
    
<!--- GetExpChart --->
    <cffunction name="GetExpChart" access="remote" returnType="query" output="false">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="State_List" type="string" required="no" default="">
        <cfargument name="CNGRSNL_DSTRCT" type="string" required="no" default="">      
        <cfscript>
			str = GetExpCounts(yStart,yEnd,State_List,CNGRSNL_DSTRCT);			
			percData = QueryNew('dataCol,perc');
			
			//Total Exports
			QueryAddRow(percData);
			QuerySetCell(percData,'dataCol','te');
			QuerySetCell(percData,'perc',100);
			
			//Small Business
			QueryAddRow(percData);
			QuerySetCell(percData,'dataCol','sb');
			if(!isDefined('str.COUNT_SB') or str.COUNT_SB eq 0 or str.COUNT_ALL eq 0) QuerySetCell(percData,'perc',0);
			else QuerySetCell(percData,'perc',str.COUNT_SB/str.COUNT_ALL*100);			
			
			//Women Owned
			QueryAddRow(percData);
			QuerySetCell(percData,'dataCol','wo');
			if(!isDefined('str.COUNT_WO') or str.COUNT_WO eq 0 or str.COUNT_ALL eq 0) QuerySetCell(percData,'perc',0);
			else QuerySetCell(percData,'perc',str.COUNT_WO/str.COUNT_ALL*100);
			
			//Minority Owned
			QueryAddRow(percData);
			QuerySetCell(percData,'dataCol','mo');
			if(!isDefined('str.COUNT_MO') or str.COUNT_MO eq 0 or str.COUNT_ALL eq 0) QuerySetCell(percData,'perc',0);
			else QuerySetCell(percData,'perc',str.COUNT_MO/str.COUNT_ALL*100);
			
			//Environmentally Beneficial
			QueryAddRow(percData);
			QuerySetCell(percData,'dataCol','env');
			if(!isDefined('str.COUNT_ENV') or str.COUNT_ENV eq 0 or str.COUNT_ALL eq 0) QuerySetCell(percData,'perc',0);
			else QuerySetCell(percData,'perc',str.COUNT_ENV/str.COUNT_ALL*100);
			
			//Renewable Energy
			QueryAddRow(percData);
			QuerySetCell(percData,'dataCol','re');
			if(!isDefined('str.COUNT_RE') or str.COUNT_RE eq 0 or str.COUNT_ALL eq 0) QuerySetCell(percData,'perc',0);
			else QuerySetCell(percData,'perc',str.COUNT_RE/str.COUNT_ALL*100);
        </cfscript>
        <cfquery name="_retQry" dbtype="query">
        	select * from percData order by perc desc
        </cfquery>
        <cfreturn _retQry>
    </cffunction>
    
<!--- GetExpChartJSON --->
    <cffunction name="GetExpChartJSON" access="remote" returnType="struct" returnFormat="json" output="false">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="State_List" type="string" required="no" default="">
        <cfargument name="CNGRSNL_DSTRCT" type="string" required="no" default="">        
        <cfscript>
			str = GetExpCounts(yStart,yEnd,State_List,CNGRSNL_DSTRCT);			
			ret = structNew();
			ret["created"] = str.created;
			ret["percData"] = SerializeJSON(GetExpChart(yStart,yEnd,State_List,CNGRSNL_DSTRCT));			
			return ret;
        </cfscript>        
        <cfquery name="qPercData" dbtype="query">
        	select dataCol,perc from percData order by per perc
        </cfquery>
        <cfset ret["percData"] = SerializeJSON(qPercData)>        
        <cfreturn ret>
    </cffunction>
    
<!--- GetUSDataTable --->
    <cffunction access="public" name="GetUSDataTable" output="no" returntype="query"> 
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#"> 
        <cfargument name="STATE_LIST" type="string" required="no" default=""> 
        <Cfset where = ' d.DT_YR_FSCL >= #arguments.yStart# AND d.DT_YR_FSCL <= #arguments.yEnd#'>
        
		<cfquery name="GetUSDataTable" datasource="#application.maps.datasource#">
            SELECT s.ABBREVIATION_TXT,
              s.NAME_TXT,
              NVL(te.EXPORTER_COUNT, 0)  AS EXPORTER_COUNT_TE,
              NVL(sb.EXPORTER_COUNT, 0)  AS EXPORTER_COUNT_SB,
              NVL(wo.EXPORTER_COUNT, 0)  AS EXPORTER_COUNT_WO,
              NVL(mo.EXPORTER_COUNT, 0)  AS EXPORTER_COUNT_MO,
              NVL(env.EXPORTER_COUNT, 0) AS EXPORTER_COUNT_ENV,
              NVL(re.EXPORTER_COUNT, 0)  AS EXPORTER_COUNT_RE
            FROM USA_STATE s
            LEFT JOIN
              (SELECT d.EXPORTER_STATE,
                COUNT(DISTINCT d.EXPORTER_NAME) AS EXPORTER_COUNT
              FROM MAP_CONG_DIST_DTL d
              WHERE #PreserveSingleQuotes(where)#
              GROUP BY d.EXPORTER_STATE
              ORDER BY d.EXPORTER_STATE
              ) te
            ON s.NAME_TXT = te.EXPORTER_STATE
            LEFT JOIN
              (SELECT d.EXPORTER_STATE,
                COUNT(DISTINCT d.EXPORTER_NAME) AS EXPORTER_COUNT
              FROM MAP_CONG_DIST_DTL d
              WHERE #PreserveSingleQuotes(where)# AND d.FLAG_SB = 'Yes'
              GROUP BY d.EXPORTER_STATE
              ORDER BY d.EXPORTER_STATE
              ) sb
            ON s.NAME_TXT = sb.EXPORTER_STATE
            LEFT JOIN
              (SELECT d.EXPORTER_STATE,
                COUNT(DISTINCT d.EXPORTER_NAME) AS EXPORTER_COUNT
              FROM MAP_CONG_DIST_DTL d
              WHERE #PreserveSingleQuotes(where)# AND d.FLAG_WO = 'Yes'
              GROUP BY d.EXPORTER_STATE
              ORDER BY d.EXPORTER_STATE
              ) wo
            ON s.NAME_TXT = wo.EXPORTER_STATE
            LEFT JOIN
              (SELECT d.EXPORTER_STATE,
                COUNT(DISTINCT d.EXPORTER_NAME) AS EXPORTER_COUNT
              FROM MAP_CONG_DIST_DTL d
              WHERE #PreserveSingleQuotes(where)# AND d.FLAG_MO = 'Yes'
              GROUP BY d.EXPORTER_STATE
              ORDER BY d.EXPORTER_STATE
              ) mo
            ON s.NAME_TXT = mo.EXPORTER_STATE
            LEFT JOIN
              (SELECT d.EXPORTER_STATE,
                COUNT(DISTINCT d.EXPORTER_NAME) AS EXPORTER_COUNT
              FROM MAP_CONG_DIST_DTL d
              WHERE #PreserveSingleQuotes(where)# AND d.FLAG_ENV = 'Yes'
              GROUP BY d.EXPORTER_STATE
              ORDER BY d.EXPORTER_STATE
              ) env
            ON s.NAME_TXT = env.EXPORTER_STATE
            LEFT JOIN
              (SELECT d.EXPORTER_STATE,
                COUNT(DISTINCT d.EXPORTER_NAME) AS EXPORTER_COUNT
              FROM MAP_CONG_DIST_DTL d
              WHERE #PreserveSingleQuotes(where)# AND d.FLAG_RE = 'Yes'
              GROUP BY d.EXPORTER_STATE
              ORDER BY d.EXPORTER_STATE
              ) re
            ON s.NAME_TXT = re.EXPORTER_STATE
			<cfif len(arguments.State_List)>
                <cfset stList = ''>
                <cfloop index="st" list="#State_List#">
                    <cfset stList = ListAppend(stList,"'" & st & "'")>
                </cfloop>
                 WHERE s.ABBREVIATION_TXT IN ('AK','AS','GU','HI','MP','PR','VI')
            </cfif>
            ORDER BY s.NAME_TXT        
        </cfquery>
        <cfreturn GetUSDataTable> 
	</cffunction>
    
<!--- GetUSDataTableJSON --->
    <cffunction name="GetUSDataTableJSON" access="remote" returnType="struct" returnFormat="json" output="false">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="STATE_LIST" type="string" required="no" default=""> 
        <cfscript>
			qry = GetUSDataTable(yStart,yEnd,State_List);
			ret = structNew();
			ret["created"] = now();
			ret["qry"] = qry;
			ret["recordCount"] = qry.recordCount;
		</cfscript>
        <cfreturn ret>
	</cffunction>
    
<!--- GetStateDataTable --->
    <cffunction access="public" name="GetStateDataTable" output="yes" returntype="query"> 
        <cfargument name="ABBREVIATION_TXT" type="string" required="yes">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="FLAG_SB" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_MO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_WO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_ENV" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_RE" type="numeric" required="no" default="0">
		<cfset stList = ''>
        <cfloop index="st" list="#ABBREVIATION_TXT#">
        	<cfset stList = ListAppend(stList,"'" & st & "'")>
        </cfloop>
        <Cfset where = " d.DT_YR_FSCL >= #arguments.yStart# AND d.DT_YR_FSCL <= #arguments.yEnd#  AND s.ABBREVIATION_TXT IN (#stList#)">                
        <cfscript>
			flgList = 'SB,MO,WO,ENV,RE';
			whereFlg = "";
			for(i=1;i lte listlen(flgList);i=i+1)
			{
				flg = 'FLAG_#listgetat(flgList,i)#';
				if(len(whereFlg) neq 0 and evaluate('arguments.' & flg) eq 1) whereFlg = whereFlg & " OR ";
				if(evaluate('arguments.' & flg) eq 1) whereFlg = whereFlg & " d.#flg# = 'Yes' ";
			}
		</cfscript>
        
		<cfquery name="GetStateDataTable" datasource="#application.maps.datasource#">
            SELECT m.EXPORTER_NAME,
              m.EXPORTER_CITY,
              m.CNGRSNL_DSTRCT,
              m.EXPORTER_NAICS_LVL2_DESC,
              m.EXPORTER_ADDRESS_LINE_1,
              m.EXPORTER_ADDRESS_LINE_2,
              m.EXPORTER_ADDRESS_LINE_3,
              m.EXPORTER_ZIP_CODE,
              m.authorized,
              m.salesupported,
              m.LATITUDE,
              m.LONGITUDE,
              (rownum-1) as rNum
            FROM
              (SELECT DISTINCT d.EXPORTER_NAME,
                d.EXPORTER_CITY,
                NVL(d.CNGRSNL_DSTRCT, '00') AS CNGRSNL_DSTRCT,
                d.EXPORTER_NAICS_LVL2_DESC,
                d.EXPORTER_ADDRESS_LINE_1,
                d.EXPORTER_ADDRESS_LINE_2,
                d.EXPORTER_ADDRESS_LINE_3,
                d.EXPORTER_ZIP_CODE,
                SUM(d.AMT_SUPPORTED)        AS authorized,
                SUM(d.AMT_EXPORT_SUPPORTED) AS salesupported,
                d.LATITUDE,
                d.LONGITUDE
              FROM USA_STATE s
              INNER JOIN MAP_CONG_DIST_DTL d
              ON s.NAME_TXT = d.EXPORTER_STATE
                        WHERE 
            #PreserveSingleQuotes(where)#
            <cfif whereFlg neq "">
            	AND (#PreserveSingleQuotes(whereFlg)#)
            </cfif>
              GROUP BY d.EXPORTER_NAME,
                d.EXPORTER_CITY,
                d.EXPORTER_NAICS_LVL2_DESC,
                d.EXPORTER_ADDRESS_LINE_1,
                d.EXPORTER_ADDRESS_LINE_2,
                d.EXPORTER_ADDRESS_LINE_3,
                d.EXPORTER_ZIP_CODE,
                d.LATITUDE,
                d.LONGITUDE,
                d.CNGRSNL_DSTRCT
              ORDER BY d.EXPORTER_NAME
              ) m
        </cfquery>
        
        <cfscript>
			StrArray = ArrayNew(1);
			idArray = ArrayNew(1);
			authArray = ArrayNew(1);
			saleArray = ArrayNew(1);
			for(i=1;i lte GetStateDataTable.recordCount;i=i+1)
			{
				ArrayAppend(StrArray,GetStreetViewUrl(GetStateDataTable.LATITUDE[i],GetStateDataTable.LONGITUDE[i]));
				ArrayAppend(idArray,i);				
				ArrayAppend(authArray,'$' & NumberFormat(GetStateDataTable.authorized[i],','));
				ArrayAppend(saleArray,'$' & NumberFormat(GetStateDataTable.salesupported[i],','));
			}
			QueryAddColumn(GetStateDataTable,'streetimage_url','VarChar',StrArray);
			QueryAddColumn(GetStateDataTable,'RowID','Integer',idArray);
			QueryAddColumn(GetStateDataTable,'authorizedFormatted','VarChar',authArray);
			QueryAddColumn(GetStateDataTable,'salesupportedFormatted','VarChar',saleArray);
		</cfscript>        
            
        <cfreturn GetStateDataTable> 
	</cffunction>
    
<!--- GetStateDataTableJSON --->
    <cffunction name="GetStateDataTableJSON" access="remote" returnType="struct" returnFormat="json" output="false">
        <cfargument name="ABBREVIATION_TXT" type="string" required="yes">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="FLAG_SB" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_MO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_WO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_ENV" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_RE" type="numeric" required="no" default="0">  
        <cfscript>
			qry = GetStateDataTable(ABBREVIATION_TXT,yStart,yEnd,FLAG_SB,FLAG_MO,FLAG_WO,FLAG_ENV,FLAG_RE);
			ret = structNew();
			ret["created"] = now();
			ret["qry"] = qry;
			ret["recordCount"] = qry.recordCount;
		</cfscript>
        <cfreturn ret>
	</cffunction>
    
<!--- GetStateDataTableDT --->
    <cffunction name="GetStateDataTableDT" access="remote" output="false" returntype="any" returnformat="json">
        <cfargument name="ABBREVIATION_TXT" type="string" required="yes">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="FLAG_SB" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_MO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_WO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_ENV" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_RE" type="numeric" required="no" default="0">  
        <cfscript>
			strData = StructNew();
			qry = GetStateDataTable(ABBREVIATION_TXT,yStart,yEnd,FLAG_SB,FLAG_MO,FLAG_WO,FLAG_ENV,FLAG_RE);			
			</cfscript>
            <cfquery name="_qry" dbtype="query">
            	select EXPORTER_NAME, EXPORTER_CITY, CNGRSNL_DSTRCT, EXPORTER_NAICS_LVL2_DESC, authorized, salesupported, authorizedFormatted, salesupportedFormatted, RowID
                from qry
            </cfquery>
            <cfscript>			
			strData['aaData'] = QueryToArray(_qry);
			return strData;
		</cfscript>
	</cffunction>
    
<!--- GetDistDataTable --->
    <cffunction access="public" name="GetDistDataTable" output="yes" returntype="query"> 
        <cfargument name="ABBREVIATION_TXT" type="string" required="yes">
        <cfargument name="CNGRSNL_DSTRCT" type="string" required="yes">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="FLAG_SB" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_MO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_WO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_ENV" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_RE" type="numeric" required="no" default="0">
		<cfset stList = ''>
        <cfloop index="st" list="#ABBREVIATION_TXT#"><cfset stList = ListAppend(stList,"'" & st & "'")></cfloop>
        <Cfset where = " d.DT_YR_FSCL >= #arguments.yStart# AND d.DT_YR_FSCL <= #arguments.yEnd# AND d.CNGRSNL_DSTRCT = '#arguments.CNGRSNL_DSTRCT#' AND s.ABBREVIATION_TXT = '#arguments.ABBREVIATION_TXT#'">
        <cfscript>
			flgList = 'SB,MO,WO,ENV,RE';
			whereFlg = "";
			for(i=1;i lte listlen(flgList);i=i+1){
				flg = 'FLAG_#listgetat(flgList,i)#';
				if(len(whereFlg) neq 0 and evaluate('arguments.' & flg) eq 1) whereFlg = whereFlg & " OR ";
				if(evaluate('arguments.' & flg) eq 1) whereFlg = whereFlg & " d.#flg# = 'Yes' ";}
		</cfscript>        
		<cfquery name="GetDistDataTable" datasource="#application.maps.datasource#">
            SELECT m.EXPORTER_NAME,
                m.EXPORTER_CITY,
                m.CNGRSNL_DSTRCT,
                m.EXPORTER_NAICS_LVL2_DESC,
                m.EXPORTER_ADDRESS_LINE_1,
                m.EXPORTER_ADDRESS_LINE_2,
                m.EXPORTER_ADDRESS_LINE_3,
                m.EXPORTER_ZIP_CODE,
                m.authorized,
                m.salesupported,
                m.LATITUDE,
                m.LONGITUDE,
                (rownum-1) as rNum
                FROM
                (
                    SELECT DISTINCT d.EXPORTER_NAME,
                      d.EXPORTER_CITY,
                      NVL(d.CNGRSNL_DSTRCT,'00') as CNGRSNL_DSTRCT,
                      d.EXPORTER_NAICS_LVL2_DESC,
                      d.EXPORTER_ADDRESS_LINE_1,
                      d.EXPORTER_ADDRESS_LINE_2,
                      d.EXPORTER_ADDRESS_LINE_3,
                      d.EXPORTER_ZIP_CODE,
                      SUM(d.AMT_SUPPORTED)        AS authorized,
                      SUM(d.AMT_EXPORT_SUPPORTED) AS salesupported,
                      d.LATITUDE,
                      d.LONGITUDE
                    FROM USA_STATE s
                    INNER JOIN MAP_CONG_DIST_DTL d
                    ON s.NAME_TXT            = d.EXPORTER_STATE
                    WHERE 
                    #PreserveSingleQuotes(where)#
                    <cfif whereFlg neq "">
                        AND (#PreserveSingleQuotes(whereFlg)#)
                    </cfif>
                    GROUP BY d.EXPORTER_NAME,
                      d.EXPORTER_CITY,
                      d.CNGRSNL_DSTRCT,
                      d.EXPORTER_NAICS_LVL2_DESC,
                      d.EXPORTER_ADDRESS_LINE_1,
                      d.EXPORTER_ADDRESS_LINE_2,
                      d.EXPORTER_ADDRESS_LINE_3,
                      d.EXPORTER_ZIP_CODE,
                      d.LATITUDE,
                      d.LONGITUDE
                    ORDER BY d.EXPORTER_NAME
				) m
        </cfquery>     
        
        <cfscript>
			StrArray = ArrayNew(1);
			idArray = ArrayNew(1);
			authArray = ArrayNew(1);
			saleArray = ArrayNew(1);
			for(i=1;i lte GetDistDataTable.recordCount;i=i+1)
			{
				ArrayAppend(StrArray,GetStreetViewUrl(GetDistDataTable.LATITUDE[i],GetDistDataTable.LONGITUDE[i]));
				ArrayAppend(idArray,i);				
				ArrayAppend(authArray,'$' & NumberFormat(GetDistDataTable.authorized[i],','));
				ArrayAppend(saleArray,'$' & NumberFormat(GetDistDataTable.salesupported[i],','));
			}
			QueryAddColumn(GetDistDataTable,'streetimage_url','VarChar',StrArray);
			QueryAddColumn(GetDistDataTable,'RowID','Integer',idArray);
			QueryAddColumn(GetDistDataTable,'authorizedFormatted','VarChar',authArray);
			QueryAddColumn(GetDistDataTable,'salesupportedFormatted','VarChar',saleArray);
		</cfscript> 
        
        <cfreturn GetDistDataTable> 
	</cffunction>
    
<!--- GetDistDataTableJSON --->
    <cffunction name="GetDistDataTableJSON" access="remote" returnType="struct" returnFormat="json" output="false">
        <cfargument name="ABBREVIATION_TXT" type="string" required="yes">
        <cfargument name="CNGRSNL_DSTRCT" type="string" required="yes">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="FLAG_SB" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_MO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_WO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_ENV" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_RE" type="numeric" required="no" default="0">  
        <cfscript>
			qry = GetDistDataTable(ABBREVIATION_TXT,CNGRSNL_DSTRCT,yStart,yEnd,FLAG_SB,FLAG_MO,FLAG_WO,FLAG_ENV,FLAG_RE);
			ret = structNew();
			ret["created"] = now();
			ret["qry"] = qry;
			ret["recordCount"] = qry.recordCount;
		</cfscript>
        <cfreturn ret>
	</cffunction>   
    
<!--- GetDistDataTableDT --->
    <cffunction name="GetDistDataTableDT" access="remote" output="false" returntype="any" returnformat="json">
        <cfargument name="ABBREVIATION_TXT" type="string" required="yes">
        <cfargument name="CNGRSNL_DSTRCT" type="string" required="yes">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="FLAG_SB" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_MO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_WO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_ENV" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_RE" type="numeric" required="no" default="0">  
        <cfscript>
			strData = StructNew();
			qry = GetDistDataTable(ABBREVIATION_TXT,CNGRSNL_DSTRCT,yStart,yEnd,FLAG_SB,FLAG_MO,FLAG_WO,FLAG_ENV,FLAG_RE);			
			</cfscript>
            <cfquery name="_qry" dbtype="query">
            	select EXPORTER_NAME, EXPORTER_CITY, CNGRSNL_DSTRCT, EXPORTER_NAICS_LVL2_DESC, authorized, salesupported, authorizedFormatted, salesupportedFormatted, RowID
                from qry
            </cfquery>
        
            <cfscript>
			
			strData['aaData'] = QueryToArray(_qry);
			return strData;
		</cfscript>
	</cffunction>
 
<!--- GetStateDistDataInit --->
    <cffunction access="public" name="GetStateDistDataInit" output="yes" returntype="query">
		<cfquery name="qStateDistDataInit" datasource="#application.maps.datasource#">
            SELECT s.ABBREVIATION_TXT,
              NVL(d.CNGRSNL_DSTRCT, '00') AS CNGRSNL_DSTRCT,
              COUNT(d.EXPORTER_NAME) AS EXPORTER_COUNT,
              SUM(NVL(d.WO_SUPPORTED, 0)) AS WO_SUPPORTED,
              SUM(NVL(d.MO_SUPPORTED, 0)) AS MO_SUPPORTED,
              SUM(NVL(d.RE_SUPPORTED, 0)) AS RE_SUPPORTED,
              SUM(NVL(d.EB_SUPPORTED, 0)) AS EB_SUPPORTED,
              SUM(NVL(d.SB_SUPPORTED, 0)) AS SB_SUPPORTED,
              SUM(NVL(d.AMT_SUPPORTED, 0)) AS AMT_SUPPORTED,
              SUM(NVL(d.AMT_EXPORT_SUPPORTED, 0)) AS AMT_EXPORT_SUPPORTED
            FROM USA_STATE s
            	LEFT JOIN MAP_CONG_DIST_DTL d
            	ON s.NAME_TXT = d.EXPORTER_STATE
            GROUP BY s.ABBREVIATION_TXT, NVL(d.CNGRSNL_DSTRCT, '00')
            ORDER BY s.ABBREVIATION_TXT, NVL(d.CNGRSNL_DSTRCT, '00')
        </cfquery>
        <cfreturn qStateDistDataInit>
	</cffunction>
    
<!--- GetStreetViewUrl --->
    <cffunction access="public" name="GetStreetViewUrl" output="yes">
    	<cfargument name="LATITUDE" type="string" required="yes">
    	<cfargument name="LONGITUDE" type="string" required="yes">        
        <cfscript>
			google_mapapi_url = "http://maps.googleapis.com";
			streetviewimage_endpoint = "/maps/api/streetview";
			LatLon = URLEncodedFormat(arguments.LATITUDE & ',' & arguments.LONGITUDE);
			
			encodedParameters = 'size=#URLEncodedFormat("150x100")#&location=#LatLon#&sensor=false&client=gme-exportimportbank';
			full_url = google_mapapi_url & streetviewimage_endpoint & "?" & encodedParameters;
			url_to_sign = streetviewimage_endpoint & "?" & encodedParameters;
			
			privatekey = "o7vV0KDhxMJNm-7ET32_grwzrUw=";
			privatekeyBase64 = Replace(Replace(privatekey,"-","+","all"),"_","/","all");  
			decodedKeyBinary = BinaryDecode(privatekeyBase64,"base64");
			
			secretKeySpec = CreateObject("java", "javax.crypto.spec.SecretKeySpec").init(decodedKeyBinary,"HmacSHA1");
			Hmac = CreateObject("java", "javax.crypto.Mac").getInstance("HmacSHA1");
			Hmac.init(secretKeySpec);
			
			encryptedBytes = Hmac.doFinal(toBinary(toBase64(url_to_sign)));
			signature = BinaryEncode(encryptedBytes, "base64");
			signatureModified = Replace(Replace(signature,"+","-","all"),"/","_","all"); 
			
			streetimage_url =  full_url & "&signature=" & signatureModified;
		</cfscript>
        <cfreturn streetimage_url>        
    </cffunction>
 
<!--- DollarAbbr --->
    <cffunction access="public" name="DollarAbbr" output="yes" returntype="string">
    	<cfargument name="amt" type="numeric" required="yes">
        <cfscript>
			_amt = numberformat(amt,',');
//			if(amt gte 1000) _amt = round(amt/1000) & 'Th';
			if(amt gte 1000000) _amt = numberformat(round(amt/1000000),',') & 'M';
			if(amt gte 1000000000) _amt = numberformat(round(amt/1000000000),',') & 'B';
			return '$' & _amt;
		</cfscript>
    </cffunction>
    
<cffunction name="QueryToArray" access="public" returntype="array" output="false">
	<cfargument name="Data" type="query" required="yes" />
	<cfscript>
		var LOCAL = StructNew();
		LOCAL.Columns = ListToArray( ARGUMENTS.Data.ColumnList );
		LOCAL.QueryArray = ArrayNew( 1 );
		for (LOCAL.RowIndex = 1 ; LOCAL.RowIndex LTE ARGUMENTS.Data.RecordCount ; LOCAL.RowIndex = (LOCAL.RowIndex + 1)){
			LOCAL.Row = StructNew();
			for (LOCAL.ColumnIndex = 1 ; LOCAL.ColumnIndex LTE ArrayLen( LOCAL.Columns ) ; LOCAL.ColumnIndex = (LOCAL.ColumnIndex + 1)){
				LOCAL.ColumnName = LOCAL.Columns[ LOCAL.ColumnIndex ];
				LOCAL.Row[ LOCAL.ColumnName ] = ARGUMENTS.Data[ LOCAL.ColumnName ][ LOCAL.RowIndex ];
			}
			ArrayAppend( LOCAL.QueryArray, LOCAL.Row );
		}
		return( LOCAL.QueryArray );
	</cfscript>
</cffunction>
    
</cfcomponent>
