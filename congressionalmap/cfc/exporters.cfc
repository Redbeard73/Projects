<cfcomponent>

	<cffunction access="public" name="GetExporterMasterTable" output="yes" returntype="query">
		<cfargument name="yMin" type="numeric" required="yes">
		<cfargument name="yMax" type="numeric" required="yes">
		<cfquery name="qGetExporterMasterTable" datasource="#application.maps.datasource#">
            SELECT DISTINCT d.DT_YR_FSCL,
                d.EXPORTER_NAME,
                d.EXPORTER_STATE,
                s.ABBREVIATION_TXT,
                NVL(d.CNGRSNL_DSTRCT, '00') AS CNGRSNL_DSTRCT,
                d.EXPORTER_CITY,
                d.EXPORTER_ZIP_CODE,
                d.EXPORTER_ADDRESS_LINE_1,
                d.EXPORTER_ADDRESS_LINE_2,
                d.EXPORTER_ADDRESS_LINE_3,
				d.EXPORTER_NAICS_LVL2_DESC,
                d.FLAG_SB,
                d.FLAG_MO,
                d.FLAG_WO,
                d.FLAG_ENV,
                d.FLAG_RE,
                d.LATITUDE,
                d.LONGITUDE,
                SUM(d.AMT_SUPPORTED) 		AS AMT_SUPPORTED,
                SUM(d.AMT_EXPORT_SUPPORTED) AS AMT_EXPORT_SUPPORTED,
				NVL(a.AMT_AUTH, 0)          AS AMT_AUTH,
                NVL(SUM(d.WO_SUPPORTED), 0)          AS WO_SUPPORTED,
                NVL(SUM(d.MO_SUPPORTED), 0)          AS MO_SUPPORTED,
                NVL(SUM(d.RE_SUPPORTED), 0)          AS RE_SUPPORTED,
                NVL(SUM(d.EB_SUPPORTED), 0)          AS EB_SUPPORTED,
                NVL(SUM(d.SB_SUPPORTED), 0)          AS SB_SUPPORTED
            FROM MAP_CONG_DIST_DTL d
                INNER JOIN USA_STATE s
                ON d.EXPORTER_STATE = s.NAME_TXT
                INNER JOIN (
                	SELECT MAP_CONG_DIST_AUTH.DT_YR_FSCL,
                    MAP_CONG_DIST_AUTH.EXPORTER_STATE,
                    NVL(MAP_CONG_DIST_AUTH.CNGRSNL_DSTRCT, '00') AS CNGRSNL_DSTRCT,
                    MAP_CONG_DIST_AUTH.AMT_AUTH
                    FROM MAP_CONG_DIST_AUTH
				) a
                ON d.DT_YR_FSCL                 = a.DT_YR_FSCL
                AND d.EXPORTER_STATE            = a.EXPORTER_STATE
                AND NVL(d.CNGRSNL_DSTRCT, '00') = a.CNGRSNL_DSTRCT
            WHERE d.DT_YR_FSCL BETWEEN #arguments.yMin# AND #arguments.yMax#
            GROUP BY d.DT_YR_FSCL,
                d.EXPORTER_NAME,
                d.EXPORTER_STATE,
                s.ABBREVIATION_TXT,
                NVL(d.CNGRSNL_DSTRCT, '00'),
                d.EXPORTER_CITY,
                d.EXPORTER_ZIP_CODE,
                d.EXPORTER_ADDRESS_LINE_1,
                d.EXPORTER_ADDRESS_LINE_2,
                d.EXPORTER_ADDRESS_LINE_3,
				d.EXPORTER_NAICS_LVL2_DESC,
                d.FLAG_SB,
                d.FLAG_MO,
                d.FLAG_WO,
                d.FLAG_ENV,
                d.FLAG_RE,
                d.LATITUDE,
                d.LONGITUDE,
				NVL(a.AMT_AUTH, 0)
            ORDER BY d.DT_YR_FSCL,
                d.EXPORTER_NAME,
                d.EXPORTER_STATE,
                NVL(d.CNGRSNL_DSTRCT, '00')
		</cfquery>
                
        <cfreturn qGetExporterMasterTable>
    </cffunction>
    

	<cffunction access="public" name="GetDestinationMasterTable" output="yes" returntype="query">
		<cfargument name="yMin" type="numeric" required="yes">
		<cfargument name="yMax" type="numeric" required="yes">
		<cfquery name="qGetDestinationMasterTable" datasource="#application.maps.datasource#">
            SELECT d.EXPORT_DESTINATION,
              d.DT_YR_FSCL,
              s.ABBREVIATION_TXT,
              d.CNGRSNL_DSTRCT,
              SUM(d.AMT_SUPPORTED) AS AMT_SUPPORTED
            FROM MAP_CONG_DIST_DTL d
            INNER JOIN USA_STATE s
            ON d.EXPORTER_STATE = s.NAME_TXT
            WHERE d.DT_YR_FSCL BETWEEN #arguments.yMin# AND #arguments.yMax#
            GROUP BY d.EXPORT_DESTINATION,
              d.DT_YR_FSCL,
              d.CNGRSNL_DSTRCT,
              s.ABBREVIATION_TXT
            ORDER BY d.DT_YR_FSCL,
              s.ABBREVIATION_TXT,
              d.CNGRSNL_DSTRCT,
              d.EXPORT_DESTINATION
        </cfquery>
        <cfreturn qGetDestinationMasterTable>        
	</cffunction>
    
    
	<cffunction access="public" name="GetExporterSubTable" output="false" returntype="query">
		<cfargument name="yMin" type="numeric" required="yes">
		<cfargument name="yMax" type="numeric" required="yes">
		<cfargument name="ABBREVIATION_TXT" type="string" required="no" default="US">
		<cfargument name="CNGRSNL_DSTRCT" type="string" required="no" default="ALL">
        
		<cfquery name="qGetExportersSub" dbtype="query">
            select distinct EXPORTER_NAME, EXPORTER_STATE, ABBREVIATION_TXT, CNGRSNL_DSTRCT, EXPORTER_CITY, EXPORTER_ZIP_CODE, 
	            EXPORTER_ADDRESS_LINE_1, EXPORTER_ADDRESS_LINE_2, EXPORTER_ADDRESS_LINE_3, 
                EXPORTER_NAICS_LVL2_DESC,
                FLAG_SB, FLAG_MO, FLAG_WO, FLAG_ENV, FLAG_RE, 
                LATITUDE, LONGITUDE,
                Sum(AMT_SUPPORTED) as AMT_SUPPORTED, 
                Sum(AMT_EXPORT_SUPPORTED) as AMT_EXPORT_SUPPORTED,
                Sum(AMT_AUTH) as AMT_AUTH
            from application.maps.qExporterMaster
            where
                DT_YR_FSCL between #arguments.yMin# AND #arguments.yMax#
                <cfif arguments.ABBREVIATION_TXT neq 'US'>
                	<cfif listlen(arguments.ABBREVIATION_TXT) eq 1>
                    	AND ABBREVIATION_TXT = '#arguments.ABBREVIATION_TXT#'
                    <cfelse>
                        AND ABBREVIATION_TXT IN ('AK','AS','GU','HI','MP','PR','VI') 
                    </cfif>
                </cfif>
                <cfif arguments.CNGRSNL_DSTRCT neq 'ALL'>
                    AND CNGRSNL_DSTRCT = '#arguments.CNGRSNL_DSTRCT#'
                </cfif> 
			group by EXPORTER_NAME, EXPORTER_STATE, ABBREVIATION_TXT, CNGRSNL_DSTRCT, EXPORTER_CITY, EXPORTER_ZIP_CODE, 
	            EXPORTER_ADDRESS_LINE_1, EXPORTER_ADDRESS_LINE_2, EXPORTER_ADDRESS_LINE_3, 
                EXPORTER_NAICS_LVL2_DESC,
                FLAG_SB, FLAG_MO, FLAG_WO, FLAG_ENV, FLAG_RE, 
                LATITUDE, LONGITUDE
			order by EXPORTER_NAME
        </cfquery>

        <cfreturn qGetExportersSub>
    </cffunction>
        
	<cffunction access="public" name="GetUSDataTable" output="yes" returntype="query">
		<cfargument name="yMin" type="numeric" required="yes">
		<cfargument name="yMax" type="numeric" required="yes">

        <cfset qGetExportersSub = GetExporterSubTable(yMin,yMax)>
        <cfset qGetExportersSubDistinct = GetExporterSubTableDistinct(yMin,yMax)>

		<cfset qGetUSDataTable = QueryNew('ABBREVIATION_TXT, NAME_TXT, EXPORTER_COUNT_TE, EXPORTER_COUNT_SB, EXPORTER_COUNT_MO, EXPORTER_COUNT_WO, EXPORTER_COUNT_ENV, EXPORTER_COUNT_RE')>

		<cfoutput query="application.maps.qStates">
            <cfquery name="_qFLAG_TE" dbtype="query">select EXPORTER_NAME from qGetExportersSub where ABBREVIATION_TXT = '#ABBREVIATION_TXT#'</cfquery>
            <cfquery name="_qFLAG_SB" dbtype="query">select EXPORTER_NAME from qGetExportersSub where ABBREVIATION_TXT = '#ABBREVIATION_TXT#' AND FLAG_SB = 'Yes'</cfquery>
            <cfquery name="_qFLAG_MO" dbtype="query">select EXPORTER_NAME from qGetExportersSub where ABBREVIATION_TXT = '#ABBREVIATION_TXT#' AND FLAG_MO = 'Yes'</cfquery>
            <cfquery name="_qFLAG_WO" dbtype="query">select EXPORTER_NAME from qGetExportersSub where ABBREVIATION_TXT = '#ABBREVIATION_TXT#' AND FLAG_WO = 'Yes'</cfquery>
            <cfquery name="_qFLAG_ENV" dbtype="query">select EXPORTER_NAME from qGetExportersSub where ABBREVIATION_TXT = '#ABBREVIATION_TXT#' AND FLAG_ENV = 'Yes'</cfquery>
            <cfquery name="_qFLAG_RE" dbtype="query">select EXPORTER_NAME from qGetExportersSub where ABBREVIATION_TXT = '#ABBREVIATION_TXT#' AND FLAG_RE = 'Yes'</cfquery>
			<cfscript>
				QueryAddRow(qGetUSDataTable);
				QuerySetCell(qGetUSDataTable,'ABBREVIATION_TXT','#ABBREVIATION_TXT#');
				QuerySetCell(qGetUSDataTable,'NAME_TXT','#NAME_TXT#');
				QuerySetCell(qGetUSDataTable,'EXPORTER_COUNT_TE',_qFLAG_TE.recordCount);
				QuerySetCell(qGetUSDataTable,'EXPORTER_COUNT_SB',_qFLAG_SB.recordCount);
				QuerySetCell(qGetUSDataTable,'EXPORTER_COUNT_MO',_qFLAG_MO.recordCount);
				QuerySetCell(qGetUSDataTable,'EXPORTER_COUNT_WO',_qFLAG_WO.recordCount);
				QuerySetCell(qGetUSDataTable,'EXPORTER_COUNT_ENV',_qFLAG_ENV.recordCount);
				QuerySetCell(qGetUSDataTable,'EXPORTER_COUNT_RE',_qFLAG_RE.recordCount);
			</cfscript>
        
        </cfoutput>
		<cfreturn qGetUSDataTable>    
    </cffunction>
    
    
	<cffunction access="public" name="GetExporterCounts" output="yes" returntype="struct">
		<cfargument name="yMin" type="numeric" required="yes">
		<cfargument name="yMax" type="numeric" required="yes">
		<cfargument name="ABBREVIATION_TXT" type="string" required="no" default="US">
		<cfargument name="CNGRSNL_DSTRCT" type="string" required="no" default="ALL">

        <cfset qGetExporterSubTable = GetExporterSubTable(yMin,yMax,ABBREVIATION_TXT,CNGRSNL_DSTRCT)>
                
		<cfquery name="qFLAG_SB" dbtype="query">
        	select count(*) as cnt from qGetExporterSubTable where FLAG_SB = 'Yes'
        </cfquery>
        <cfquery name="qFLAG_MO" dbtype="query">
        	select count(*) as cnt from qGetExporterSubTable where FLAG_MO = 'Yes'
        </cfquery>
        <cfquery name="qFLAG_WO" dbtype="query">
        	select count(*) as cnt from qGetExporterSubTable where FLAG_WO = 'Yes'
        </cfquery>
        <cfquery name="qFLAG_ENV" dbtype="query">
        	select count(*) as cnt from qGetExporterSubTable where FLAG_ENV = 'Yes'
        </cfquery>
        <cfquery name="qFLAG_RE" dbtype="query">
        	select count(*) as cnt from qGetExporterSubTable where FLAG_RE = 'Yes'
        </cfquery>  		
        <cfquery name="qTotals" dbtype="query">
        	select sum(AMT_SUPPORTED) as AMT_SUPPORTED, sum(AMT_EXPORT_SUPPORTED) as AMT_EXPORT_SUPPORTED, sum(AMT_AUTH) as AMT_AUTH from qGetExporterSubTable
        </cfquery> 
        
		<cfquery name="qDistinct" dbtype="query">
            select distinct EXPORTER_NAME, CNGRSNL_DSTRCT, EXPORTER_CITY, EXPORTER_ZIP_CODE
            from qGetExporterSubTable
			group by EXPORTER_NAME,  CNGRSNL_DSTRCT, EXPORTER_CITY, EXPORTER_ZIP_CODE
			order by EXPORTER_NAME
        </cfquery>  

        
		<cfscript>
			ret = structNew();
			
			ret.updated = now();
			
			ret.EXPORTER_COUNT = qDistinct.recordCount;
			
			ret.COUNT_SB = iif(isNumeric(qFLAG_SB.cnt),qFLAG_SB.cnt,0);
			ret.COUNT_MO = iif(isNumeric(qFLAG_MO.cnt),qFLAG_MO.cnt,0);
			ret.COUNT_WO = iif(isNumeric(qFLAG_WO.cnt),qFLAG_WO.cnt,0);
			ret.COUNT_ENV = iif(isNumeric(qFLAG_ENV.cnt),qFLAG_ENV.cnt,0);
			ret.COUNT_RE = iif(isNumeric(qFLAG_RE.cnt),qFLAG_RE.cnt,0);
			
			ret.COUNT_ALL = qGetExporterSubTable.recordCount;
			
			ret.perc.sb = 0;
			ret.perc.mo = 0;
			ret.perc.wo = 0;
			ret.perc.env = 0;
			ret.perc.re = 0;
			if(ret.COUNT_ALL gt 0){
				ret.perc.sb = round(ret.COUNT_SB / ret.COUNT_ALL * 100);
				ret.perc.mo = round(ret.COUNT_MO / ret.COUNT_ALL * 100);
				ret.perc.wo = round(ret.COUNT_WO / ret.COUNT_ALL * 100);
				ret.perc.env = round(ret.COUNT_ENV / ret.COUNT_ALL * 100);
				ret.perc.re = round(ret.COUNT_RE / ret.COUNT_ALL * 100);
			}			
			
			
			
			ret.salessupported = iif(isNumeric(qTotals.AMT_EXPORT_SUPPORTED),qTotals.AMT_EXPORT_SUPPORTED,0);
			ret.totalauthorizations = iif(isNumeric(qTotals.AMT_AUTH),qTotals.AMT_AUTH,0);
			ret.disbursements = iif(isNumeric(qTotals.AMT_SUPPORTED),qTotals.AMT_SUPPORTED,0);
			
			ret.topDestList = GetTopDestination(2008,2013,ABBREVIATION_TXT,CNGRSNL_DSTRCT);
			
			ret.topExportersArr = arrayNew(1);		
			
			percData = QueryNew('dataCol,perc');
			
			QueryAddRow(percData);
			QuerySetCell(percData,'dataCol','te');
			QuerySetCell(percData,'perc',100);
			
			QueryAddRow(percData);
			QuerySetCell(percData,'dataCol','sb');
			QuerySetCell(percData,'perc',ret.perc.sb);
			
			QueryAddRow(percData);
			QuerySetCell(percData,'dataCol','mo');
			QuerySetCell(percData,'perc',ret.perc.mo);
			
			QueryAddRow(percData);
			QuerySetCell(percData,'dataCol','wo');
			QuerySetCell(percData,'perc',ret.perc.wo);
			
			QueryAddRow(percData);
			QuerySetCell(percData,'dataCol','env');
			QuerySetCell(percData,'perc',ret.perc.env);
			
			QueryAddRow(percData);
			QuerySetCell(percData,'dataCol','re');
			QuerySetCell(percData,'perc',ret.perc.re);
			
		</cfscript>
        <cfquery name="qTopExpSet" dbtype="query">
            SELECT distinct EXPORTER_NAME, Sum(AMT_SUPPORTED) as AMT_SUPPORTED
            FROM qGetExporterSubTable
            GROUP BY EXPORTER_NAME
            ORDER BY EXPORTER_NAME
        </cfquery>
        <cfquery name="qTopExp" dbtype="query">
            SELECT distinct EXPORTER_NAME
            FROM qTopExpSet
            ORDER BY AMT_SUPPORTED DESC
        </cfquery>
        
        
        <cfoutput query="qTopExp" maxrows="3" group="EXPORTER_NAME">
        	<cfset ArrayAppend(ret.topExportersArr,EXPORTER_NAME)>
        </cfoutput>    
        <cfloop index="i" from="#evaluate(arrayLen(ret.topExportersArr)+1)#" to="3">
        	<cfset ArrayAppend(ret.topExportersArr,'')>
        </cfloop>    
        <cfquery name="_percData" dbtype="query">
        	select * from percData order by perc desc
        </cfquery>
        
        <cfset ret.percData = percData>
        
    	<cfreturn ret>
	</cffunction>
    
    <cffunction access="public" name="GetTopDestination" output="no" returntype="string" verifyclient="no" securejson="false">
		<cfargument name="yMin" type="numeric" required="yes">
		<cfargument name="yMax" type="numeric" required="yes">
		<cfargument name="ABBREVIATION_TXT" type="string" required="no" default="US">
		<cfargument name="CNGRSNL_DSTRCT" type="string" required="no" default="ALL">
        
        <cfquery name="qGetTopDestination" dbtype="query">
	        SELECT DISTINCT EXPORT_DESTINATION, sum(AMT_SUPPORTED) as AMT_SUPPORTED 
            FROM application.maps.qDestinationMaster
            WHERE DT_YR_FSCL BETWEEN #arguments.yMin# AND #arguments.yMax#
            	and EXPORT_DESTINATION <> 'Various'
                <cfif arguments.ABBREVIATION_TXT neq 'US'>
                	<cfif listlen(arguments.ABBREVIATION_TXT) eq 1>
                    	AND ABBREVIATION_TXT = '#arguments.ABBREVIATION_TXT#'
                    <cfelse>
                    	AND ABBREVIATION_TXT IN ('AK','AS','GU','HI','MP','PR','VI')                 
                    </cfif>
                </cfif>
                <cfif arguments.CNGRSNL_DSTRCT neq 'ALL'>
                    AND CNGRSNL_DSTRCT      = '#arguments.CNGRSNL_DSTRCT#'
                </cfif>
            GROUP BY EXPORT_DESTINATION
			ORDER BY AMT_SUPPORTED desc
		</cfquery>
        
		<cfset destList = ''>
        <cfoutput query="qGetTopDestination" maxrows="3">
        	<cfset destList = ListAppend(destList,EXPORT_DESTINATION,',&nbsp;')>
        </cfoutput>
    	<cfreturn destList>
    </cffunction>
</cfcomponent>