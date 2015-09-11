<cfcomponent>
	
    <cffunction name="GetExporterCounts" access="remote" returnType="struct" returnFormat="json" output="true">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="ABBREVIATION_TXT" type="string" required="no" default="US">
        <cfargument name="CNGRSNL_DSTRCT" type="string" required="no" default="ALL"> 
        
        <cfscript>
			str = application.oExp.GetExporterCounts(yStart,yEnd,ABBREVIATION_TXT,CNGRSNL_DSTRCT);			
			ret = structNew();
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
			ret["TotalAuthorizations"] = NumberFormat(str.TotalAuthorizations,',');	
			ret["SalesSupportedAbbr"] = application.oMap.DollarAbbr(str.SalesSupported);
			ret["DisbursementsAbbr"] = application.oMap.DollarAbbr(str.Disbursements);
			ret["TotalAuthorizationsAbbr"] = application.oMap.DollarAbbr(str.TotalAuthorizations);
			
			return ret;
        </cfscript>

    </cffunction>
    
    <cffunction name="GetExpChart" access="remote" returnType="struct" returnFormat="json" output="true">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="ABBREVIATION_TXT" type="string" required="no" default="US">
        <cfargument name="CNGRSNL_DSTRCT" type="string" required="no" default="ALL">        
        <cfscript>
			data = application.oExp.GetExporterCounts(yStart,yEnd,ABBREVIATION_TXT,CNGRSNL_DSTRCT);
			percData = data.percData;
			ret = structNew();
			ret["percData"] = SerializeJSON(percData);
			return ret;
        </cfscript>
    </cffunction>
    
	<cffunction access="private" name="GetDataForTable" output="yes" returntype="query">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="ABBREVIATION_TXT" type="string" required="no" default="US">
        <cfargument name="CNGRSNL_DSTRCT" type="string" required="no" default="ALL">
        <cfargument name="FLAG_SB" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_MO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_WO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_ENV" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_RE" type="numeric" required="no" default="0">  
        <cfargument name="FLAG_OT" type="numeric" required="no" default="0">  
        
        <cfscript>
			flgList = 'SB,MO,WO,ENV,RE';
			whereFlg = "";
			for(i=1;i lte listlen(flgList);i=i+1)
			{
				flg = 'FLAG_#listgetat(flgList,i)#';
				if(len(whereFlg) neq 0 and evaluate('arguments.' & flg) eq 1) whereFlg = whereFlg & " OR ";
				if(evaluate('arguments.' & flg) eq 1) whereFlg = whereFlg & " #flg# = 'Yes' ";
			}
		</cfscript>
        
        
		<cfquery name="qGetDataForTable" dbtype="query">
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
                DT_YR_FSCL between #arguments.yStart# AND #arguments.yEnd#
                
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
                
                
                <cfif whereFlg neq "" or arguments.FLAG_OT>
                	AND(
					<cfif whereFlg neq "">
                        (#PreserveSingleQuotes(whereFlg)#)
                    </cfif>                   

						<cfif arguments.FLAG_OT>
							<cfif whereFlg neq "">
                            	OR
                        	</cfif>
                            (
                                FLAG_SB <> 'Yes' AND
                                FLAG_MO <> 'Yes' AND
                                FLAG_WO <> 'Yes' AND
                                FLAG_ENV <> 'Yes' AND
                                FLAG_RE <> 'Yes'
                            )
                        </cfif>
                    )
                </cfif>

			group by EXPORTER_NAME, EXPORTER_STATE, ABBREVIATION_TXT, CNGRSNL_DSTRCT, EXPORTER_CITY, EXPORTER_ZIP_CODE, 
	            EXPORTER_ADDRESS_LINE_1, EXPORTER_ADDRESS_LINE_2, EXPORTER_ADDRESS_LINE_3, 
                EXPORTER_NAICS_LVL2_DESC,
                FLAG_SB, FLAG_MO, FLAG_WO, FLAG_ENV, FLAG_RE, 
                LATITUDE, LONGITUDE
			order by EXPORTER_NAME
        </cfquery>  
        
        <cfscript>
			idArr = arrayNew(1);			
			authArr = ArrayNew(1);
			saleArr = ArrayNew(1);
			for(i=1;i lte qGetDataForTable.recordCount;i=i+1){
				ArrayAppend(idArr,i);
				ArrayAppend(authArr,'$' & NumberFormat(qGetDataForTable.AMT_SUPPORTED[i],','));
				ArrayAppend(saleArr,'$' & NumberFormat(qGetDataForTable.AMT_EXPORT_SUPPORTED[i],','));
			}
			QueryAddColumn(qGetDataForTable,'ROWID','Integer',idArr);
			QueryAddColumn(qGetDataForTable,'AUTHORIZEDFORMATTED','VarChar',authArr);
			QueryAddColumn(qGetDataForTable,'SALESUPPORTEDFORMATTED','VarChar',saleArr);			
		</cfscript>    
        
		
        
        <cfreturn qGetDataForTable>        
        
    </cffunction>
    
    <cffunction name="GetUSDataTable" access="remote" output="true" returntype="any" returnformat="json">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="isTerr" type="numeric" required="no" default="0">
        
        <cfset data = GetDataForTable(yStart,yEnd)>
		<cfset qGetUSDataTable = QueryNew('ABBREVIATION_TXT, NAME_TXT, EXPORTER_COUNT_TE, EXPORTER_COUNT_SB, EXPORTER_COUNT_MO, EXPORTER_COUNT_WO, EXPORTER_COUNT_ENV, EXPORTER_COUNT_RE')>

		<cfif !isTerr>
        	<cfset qS = application.maps.qStates>
        <cfelse>
        	<cfquery name="qS" dbtype="query">
            	select * from application.maps.qStates
                where 
                	ABBREVIATION_TXT in ('AK','AS','GU','HI','MP','PR','VI')
            </cfquery>
        </cfif>


		<cfoutput query="qS">
            <cfquery name="_qFLAG_TE" dbtype="query">select EXPORTER_NAME from data where ABBREVIATION_TXT = '#ABBREVIATION_TXT#'</cfquery>
            <cfquery name="_qFLAG_SB" dbtype="query">select EXPORTER_NAME from data where ABBREVIATION_TXT = '#ABBREVIATION_TXT#' AND FLAG_SB = 'Yes'</cfquery>
            <cfquery name="_qFLAG_MO" dbtype="query">select EXPORTER_NAME from data where ABBREVIATION_TXT = '#ABBREVIATION_TXT#' AND FLAG_MO = 'Yes'</cfquery>
            <cfquery name="_qFLAG_WO" dbtype="query">select EXPORTER_NAME from data where ABBREVIATION_TXT = '#ABBREVIATION_TXT#' AND FLAG_WO = 'Yes'</cfquery>
            <cfquery name="_qFLAG_ENV" dbtype="query">select EXPORTER_NAME from data where ABBREVIATION_TXT = '#ABBREVIATION_TXT#' AND FLAG_ENV = 'Yes'</cfquery>
            <cfquery name="_qFLAG_RE" dbtype="query">select EXPORTER_NAME from data where ABBREVIATION_TXT = '#ABBREVIATION_TXT#' AND FLAG_RE = 'Yes'</cfquery>
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
        
        <cfscript>
			strData = StructNew();
			strData['aaData'] = application.oMap.QueryToArray(qGetUSDataTable);
			return strData;
		</cfscript>
	</cffunction>
    
    <cffunction name="GetStateDataTable" access="remote" output="true" returntype="any" returnformat="json">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="ABBREVIATION_TXT" type="string" required="yes">
        <cfargument name="CNGRSNL_DSTRCT" type="string" required="no" default="ALL">
        <cfargument name="FLAG_SB" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_MO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_WO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_ENV" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_RE" type="numeric" required="no" default="0">  
        <cfargument name="FLAG_OT" type="numeric" required="no" default="0">  
        <cfargument name="startRec" type="numeric" required="no" default="0">
        <cfargument name="maxRec" type="numeric" required="no" default="0">  
        <cfscript>
			strData = StructNew();
			qry = GetDataForTable(yStart,yEnd,ABBREVIATION_TXT,CNGRSNL_DSTRCT,FLAG_SB,FLAG_MO,FLAG_WO,FLAG_ENV,FLAG_RE,FLAG_OT);
			if(arguments.maxRec gt 0)
			{
				QueryTrim(qry,arguments.maxRec);
			}
			strData['aaData'] = application.oMap.QueryToArray(qry);
			return strData;
		</cfscript>
	</cffunction>
    
    <cffunction name="GetStateDataMarkers" access="remote" output="true" returntype="any" returnformat="json">
        <cfargument name="yStart" type="numeric" required="no" default="#this.instance.yrMin#">
        <cfargument name="yEnd" type="numeric" required="no" default="#this.instance.yrMax#">
        <cfargument name="ABBREVIATION_TXT" type="string" required="yes">
        <cfargument name="CNGRSNL_DSTRCT" type="string" required="no" default="ALL">
        <cfargument name="FLAG_SB" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_MO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_WO" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_ENV" type="numeric" required="no" default="0"> 
        <cfargument name="FLAG_RE" type="numeric" required="no" default="0">  
        <cfargument name="FLAG_OT" type="numeric" required="no" default="0">  
        <cfargument name="isMarker" type="boolean" required="no" default="false">  
        <cfscript>
			strData = StructNew();
			qry = GetDataForTable(yStart,yEnd,ABBREVIATION_TXT,CNGRSNL_DSTRCT,FLAG_SB,FLAG_MO,FLAG_WO,FLAG_ENV,FLAG_RE,FLAG_OT);

			streetArr = ArrayNew(1);
			for(i=1;i lte qry.recordCount;i=i+1)
			{
				ArrayAppend(streetArr,application.oMap.GetStreetViewUrl(qry.LATITUDE[i],qry.LONGITUDE[i]));
			}
			QueryAddColumn(qry,'streetimage_url','VarChar',streetArr);
			
			strData['aaData'] = application.oMap.QueryToArray(qry);
			return strData;
		</cfscript>
	</cffunction>
    
<cffunction
    name="QueryTrim"
    access="public"
    returntype="query"
    output="false">
	<cfargument name="Query" type="query" required="true" />
	<cfargument name="RecordCount" type="numeric" required="true" />
 
<cfif (ARGUMENTS.Query.RecordCount GT ARGUMENTS.RecordCount)>
 
<cfset ARGUMENTS.Query.RemoveRows(
	JavaCast( "int", ARGUMENTS.RecordCount ),
	JavaCast( "int", (ARGUMENTS.Query.RecordCount - ARGUMENTS.RecordCount))
	) />
 
</cfif>
 
<cfreturn ARGUMENTS.Query />
</cffunction>
    
</cfcomponent>