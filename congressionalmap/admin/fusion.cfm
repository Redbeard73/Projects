<h1>Fusion</h1>

<script>
	function go(){
		var r=confirm("Are you sure you would like to Upload Fusion Table Data?")
		if (r==true)
			document.goSubForm.submit();
		else
			return false;
	}
</script>

<cfscript>

// PRODUCTION TABLES
HomepageData_tbl = application.maps.fusStateExporterData;
USMapData_tbl = application.maps.fusus_map;
StateInitMapData_tbl = application.maps.fusStateExporterDataInit;
StateMapData_tbl = application.maps.fusSDistrictExporterDataMain;

/*
//DEV TABLES
HomepageData_tbl = '1AP84SolAqcQ_z4SK7HOmVGgnSqznZGsmZ1C7MCM';
USMapData_tbl = '17spQE_kempTvjf4PaEdvkiDmhWYZq6Dg6Zew384';
StateInitMapData_tbl = '1yGdZ0TsrdkI3FSokAvTttxRReIaHWt0QgMaaTRo';
StateMapData_tbl = '15XbjEcxjtrIGNMHJe_IjgAKB2KWLG60n7HlBcdo';
*/

</cfscript>

<cfoutput>
<table>
	<tr>
    	<td><a href="https://www.google.com/fusiontables/data?docid=#HomepageData_tbl#" target="_blank">HOMEPAGE MAP</a></a></td><td>fusStateExporterData : #HomepageData_tbl#</td><td><a href="fusion/current/HomepageData.csv">View CSV File</a></td>
	</tr>
	<tr>
    	<td><a href="https://www.google.com/fusiontables/data?docid=#USMapData_tbl#" target="_blank">US MAP</a></td><td>fusus_map : #USMapData_tbl#</td><td><a href="fusion/current/USMapData.csv">View CSV File</a></td>
	</tr>
	<tr>
    	<td><a href="https://www.google.com/fusiontables/data?docid=#StateInitMapData_tbl#" target="_blank">STATE INIT MAP</a></td><td>fusStateExporterDataInit : #StateInitMapData_tbl#</td><td><a href="fusion/current/StateInitMapData.csv">View CSV File</a></td>
	</tr>
	<tr>
    	<td><a href="https://www.google.com/fusiontables/data?docid=#StateMapData_tbl#" target="_blank">STATE MAP POLY</a></td><td>fusSDistrictExporterDataMain : #StateMapData_tbl#</td><td><a href="fusion/current/StateMapData.csv">View CSV File</a></td>
	</tr>
    <form action="fusion.cfm?goFusion=1" method="post" name="goSubForm">
        <tr>
            <td colspan="3"><input name="btnCheckGo" type="button" value="Upload Fusion Table Data" onclick="go();" /></td>
        </tr>
    </form>
</table>
</cfoutput>

<cfif isDefined('url.goFusion')>

    <cftry>
    
        <cfscript>
            WriteLog(type="Information", file="CongressionalMap", text="Fusion Upload BEGIN");
            dirCurrent = ExpandPath('/customcf/congressionalmap/admin/fusion/current/');
            DATE_UPDATED = dateformat(now(),"mm/dd/yyyy");
        </cfscript>
        
        <!--- HOMEPAGE MAP Info (districts) --->
        <cfscript>
        WriteOutput('<h2>HOMEPAGE MAP Info</h2><br>');
        //HOMEPAGE MAP
        //fusStateExporterData : 1O6Hhd1m4lRPSdAgievkjD0cIESo7LPVlktXc-rM
            colsHome = 'ABBREVIATION_TXT,SalesSupported,Disbursements,Authorizations,TotalAuthorizations,EXPORTER_COUNT,DATE_UPDATED';
            fDataHome = application.oFusion.select('select rowid, #colsHome# from #HomepageData_tbl#');	
            ArchiveData('HomepageData',colsHome,fDataHome);
            cErr=0;cUpd=0;cIns=0;
            
            csvTxt = colsHome;
            for(i=1;i lte application.maps.qStates.recordCount;i=i+1)
            {
                abbreviation_txt = application.maps.qStates.abbreviation_txt[i];
                RowID = GetRowID(fDataHome,abbreviation_txt);		
                qExpCount = application.oExp.GetExporterSubTable(application.maps.yrMin,application.maps.yrMax,abbreviation_txt);
                subQry = qry("select Sum(AMT_SUPPORTED) as Disbursements, sum(AMT_EXPORT_SUPPORTED) as SalesSupported, sum(AMT_AUTH) as TotalAuthorizations,
                    sum(SB_SUPPORTED) as SB_SUPPORTED,sum(MO_SUPPORTED) as MO_SUPPORTED,sum(WO_SUPPORTED) as WO_SUPPORTED,sum(RE_SUPPORTED) as RE_SUPPORTED,sum(EB_SUPPORTED) as EB_SUPPORTED
                    from application.maps.qExporterMaster
                    where abbreviation_txt = '#abbreviation_txt#'");		
                qExpCountDistinct = qry("select distinct EXPORTER_NAME, CNGRSNL_DSTRCT, EXPORTER_CITY, EXPORTER_ZIP_CODE 
                    from qExpCount 
                    group by EXPORTER_NAME, CNGRSNL_DSTRCT, EXPORTER_CITY, EXPORTER_ZIP_CODE
                    order by EXPORTER_NAME");
                    
                SalesSupported = iif(subQry.recordCount eq 0,0,subQry.SalesSupported);
                Disbursements = iif(subQry.recordCount eq 0,0,subQry.Disbursements);
                TotalAuthorizations = iif(subQry.recordCount eq 0,0,subQry.TotalAuthorizations);
                EXPORTER_COUNT = iif(subQry.recordCount eq 0,0,qExpCountDistinct.recordCount);
                
                line = '#abbreviation_txt#,#SalesSupported#,#Disbursements#,0,#TotalAuthorizations#,#EXPORTER_COUNT#,#DATE_UPDATED#';
                csvTxt = ListAppend(csvTxt,line,chr(10));		
                sql = '';		
                if(RowID eq 0){
                    //INSERT
                    sql = "INSERT INTO #HomepageData_tbl# (#colsHome#) VALUES " &
                        "('#abbreviation_txt#',#SalesSupported#,#Disbursements#,0,#TotalAuthorizations#,#EXPORTER_COUNT#,'#DATE_UPDATED#')";
                        
                    retStatus = application.oFusion.post(sql);					
                    if(retStatus eq '200 OK') {
                        cIns=cIns+1;
                    } else {
                        cErr=cErr+1;
                            WriteLog(type="Error", file="CongressionalMap", text="INSERT {#abbreviation_txt#} HomepageData - #retStatus# [#sql#]");
                    }
                } else {
                    doUpdate = fDoUpdate1(fDataHome,RowID,SalesSupported,Disbursements,TotalAuthorizations,EXPORTER_COUNT);
                    if(doUpdate){
                        //UPDATE
                        sql = "UPDATE #HomepageData_tbl# SET ";
                        sql = sql & "SalesSupported = #SalesSupported#, ";
                        sql = sql & "Disbursements = #Disbursements#, ";
                        sql = sql & "TotalAuthorizations = #TotalAuthorizations#, ";
                        sql = sql & "EXPORTER_COUNT = #EXPORTER_COUNT#, ";
                        sql = sql & "DATE_UPDATED = '#DATE_UPDATED#' ";
                        sql = sql & "WHERE ROWID = '#RowID#'";
                        retStatus = application.oFusion.post(sql);					
                        if(retStatus eq '200 OK') {
                            cUpd=cUpd+1;
                        } else {
                            cErr=cErr+1;
                            WriteLog(type="Error", file="CongressionalMap", text="UPDATE {#abbreviation_txt#} HomepageData - #retStatus# [#sql#]");
                        }
                    }
                }
            }
            csvFile = dirCurrent & 'HomepageData.csv';
            FileWrite(csvFile,csvTxt);
            WriteLog(type="Information", file="CongressionalMap", text="HomepageData.csv created : INS[#cIns#] UPD[#cUpd#] ERR[#cErr#]");
        
        </cfscript>
        
        <!--- US MAP Info (districts) --->
        <cfscript>
        WriteOutput('<h2>US MAP Info</h2><br>');
        //US MAP
        //fusus_map : 1YP42sgYnaii7fPXNiBsTCn7rVl6Eb7LIRmXhpDc
            colsUS = 'ABBREVIATION_TXT,DT_YR_FSCL,AMT_SUPPORTED,AMT_EXPORT_SUPPORTED,AMT_AUTH,WO_SUPPORTED,MO_SUPPORTED,RE_SUPPORTED,EB_SUPPORTED,SB_SUPPORTED,OT_SUPPORTED,DATE_UPDATED';
            fDataUS = application.oFusion.select('select rowid, #colsUS# from #USMapData_tbl#');
            ArchiveData('USMapData',colsUS,fDataUS);
            cErr=0;cUpd=0;cIns=0;
            csvTxt = colsUS;
            for(i=1;i lte application.maps.qStates.recordCount;i=i+1)
            {
                abbreviation_txt = application.maps.qStates.abbreviation_txt[i];
                for(DT_YR_FSCL=2008;DT_YR_FSCL <= 2013;DT_YR_FSCL=DT_YR_FSCL+1){
                    RowID = GetRowID(fDataUS,abbreviation_txt,'-',DT_YR_FSCL);
                    subQry = qry("select DT_YR_FSCL, Sum(AMT_SUPPORTED) as AMT_SUPPORTED, sum(AMT_EXPORT_SUPPORTED) as AMT_EXPORT_SUPPORTED, sum(AMT_AUTH) as AMT_AUTH,
                        sum(SB_SUPPORTED) as SB_SUPPORTED,sum(MO_SUPPORTED) as MO_SUPPORTED,sum(WO_SUPPORTED) as WO_SUPPORTED,sum(RE_SUPPORTED) as RE_SUPPORTED,sum(EB_SUPPORTED) as EB_SUPPORTED
                        from application.maps.qExporterMaster
                        where abbreviation_txt = '#abbreviation_txt#' and DT_YR_FSCL = #DT_YR_FSCL#
                        GROUP BY DT_YR_FSCL");	
                        
                    AMT_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.AMT_SUPPORTED);
                    AMT_EXPORT_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.AMT_EXPORT_SUPPORTED);
                    AMT_AUTH = iif(subQry.recordCount eq 0,0,subQry.AMT_AUTH);
                    WO_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.WO_SUPPORTED);
                    MO_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.MO_SUPPORTED);
                    RE_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.RE_SUPPORTED);
                    EB_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.EB_SUPPORTED);
                    SB_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.SB_SUPPORTED);
                    OT_SUPPORTED = iif(subQry.recordCount eq 0,0,AMT_EXPORT_SUPPORTED - WO_SUPPORTED - MO_SUPPORTED - RE_SUPPORTED - EB_SUPPORTED - SB_SUPPORTED);	
        			if(!isNumeric(OT_SUPPORTED)) OT_SUPPORTED = 0;
					if(OT_SUPPORTED lt 0) OT_SUPPORTED = 0;	
					
					line = '#abbreviation_txt#,#DT_YR_FSCL#,#AMT_SUPPORTED#,#AMT_EXPORT_SUPPORTED#,#AMT_AUTH#,#WO_SUPPORTED#,#MO_SUPPORTED#,#RE_SUPPORTED#,#EB_SUPPORTED#,#SB_SUPPORTED#,#OT_SUPPORTED#,#DATE_UPDATED#';
                    csvTxt = ListAppend(csvTxt,line,chr(10));
                    sql = '';
                    if(RowID eq 0){
                        //INSERT	
                        sql = "INSERT INTO #USMapData_tbl# (#colsUS#) VALUES " &
                            "('#abbreviation_txt#',#DT_YR_FSCL#,#AMT_SUPPORTED#,#AMT_EXPORT_SUPPORTED#,#AMT_AUTH#,#WO_SUPPORTED#,#MO_SUPPORTED#,#RE_SUPPORTED#,#EB_SUPPORTED#,#SB_SUPPORTED#,#OT_SUPPORTED#,'#DATE_UPDATED#')";
                        retStatus = application.oFusion.post(sql);					
                        if(retStatus eq '200 OK') {
                            cIns=cIns+1;
                        } else {
                            cErr=cErr+1;
                            WriteLog(type="Error", file="CongressionalMap", text="INSERT {#abbreviation_txt# #DT_YR_FSCL#} USMapData - #retStatus# [#sql#]");
                        }
                    } else {
                        doUpdate = fDoUpdate2(fDataUS,RowID,AMT_SUPPORTED,AMT_EXPORT_SUPPORTED,AMT_AUTH,WO_SUPPORTED,MO_SUPPORTED,RE_SUPPORTED,EB_SUPPORTED,SB_SUPPORTED,OT_SUPPORTED);
                        if(doUpdate){
                            //UPDATE
                            sql = "UPDATE #USMapData_tbl# SET ";					
                            sql = sql & "AMT_SUPPORTED = #AMT_SUPPORTED#, ";
                            sql = sql & "AMT_EXPORT_SUPPORTED = #AMT_EXPORT_SUPPORTED#, ";
                            sql = sql & "AMT_AUTH = #AMT_AUTH#, ";
                            sql = sql & "WO_SUPPORTED = #WO_SUPPORTED#, ";
                            sql = sql & "MO_SUPPORTED = #MO_SUPPORTED#, ";
                            sql = sql & "RE_SUPPORTED = #RE_SUPPORTED#, ";
                            sql = sql & "EB_SUPPORTED = #EB_SUPPORTED#, ";
                            sql = sql & "SB_SUPPORTED = #SB_SUPPORTED#, ";
                            sql = sql & "OT_SUPPORTED = #OT_SUPPORTED#, ";					
                            sql = sql & "DATE_UPDATED = '#DATE_UPDATED#' ";
                            sql = sql & "WHERE ROWID = '#RowID#'";
                            retStatus = application.oFusion.post(sql);					
                            if(retStatus eq '200 OK') {
                                cUpd=cUpd+1;
                            } else {
                                cErr=cErr+1;
                            WriteLog(type="Error", file="CongressionalMap", text="UPDATE {#abbreviation_txt# #DT_YR_FSCL#} USMapData - #retStatus# [#sql#]");
                            }
                        }
                    }
                }
            }
            csvFile = dirCurrent & 'USMapData.csv';
            FileWrite(csvFile,csvTxt);
            WriteLog(type="Information", file="CongressionalMap", text="USMapData.csv created : INS[#cIns#] UPD[#cUpd#] ERR[#cErr#]");
            
        </cfscript>
        
        <!--- STATE INIT MAP Info (districts) --->
        <cfscript>
        WriteOutput('<h2>STATE INIT MAP Info</h2><br>');
        //STATE INIT MAP
        //fusStateExporterDataInit : 1vQdA-4liW1BqnM8tDA4RXN0CKYJj8AdnqmzOPg0
            colsStateInit = 'ABBREVIATION_TXT,CNGRSNL_DSTRCT,DISTRICT_NAME,EXPORTER_COUNT,WO_SUPPORTED,MO_SUPPORTED,RE_SUPPORTED,EB_SUPPORTED,SB_SUPPORTED,OT_SUPPORTED,AMT_SUPPORTED,AMT_EXPORT_SUPPORTED,DATE_UPDATED';
            fStateDataInit = application.oFusion.select('select rowid, #colsStateInit# from #StateInitMapData_tbl#');
            ArchiveData('StateInitMapData',colsStateInit,fStateDataInit);
            cErr=0;cUpd=0;cIns=0;
            csvTxt = colsStateInit;
            for(i=1;i lte application.maps.qDistricts.recordCount;i=i+1)
            {
                abbreviation_txt = application.maps.qDistricts.abbreviation_txt[i];
                CNGRSNL_DSTRCT_TXT = application.maps.qDistricts.CONGRESSIONAL_DISTRICT_NBR[i];
                if(len(CNGRSNL_DSTRCT_TXT) eq 1) CNGRSNL_DSTRCT_TXT = '0' & CNGRSNL_DSTRCT_TXT;
                distName = '#abbreviation_txt#-#CNGRSNL_DSTRCT_TXT#';
                RowID = GetRowID(fStateDataInit,abbreviation_txt,distName);
                
                subQry = qry("select Sum(AMT_SUPPORTED) as AMT_SUPPORTED, sum(AMT_EXPORT_SUPPORTED) as AMT_EXPORT_SUPPORTED, 
                    sum(SB_SUPPORTED) as SB_SUPPORTED, sum(MO_SUPPORTED) as MO_SUPPORTED, sum(WO_SUPPORTED) as WO_SUPPORTED, sum(RE_SUPPORTED) as RE_SUPPORTED, sum(EB_SUPPORTED) as EB_SUPPORTED
                    from application.maps.qExporterMaster
                    where ABBREVIATION_TXT = '#abbreviation_txt#'
                        and (CNGRSNL_DSTRCT = '#CNGRSNL_DSTRCT_TXT#' or CNGRSNL_DSTRCT = '#application.maps.qDistricts.CONGRESSIONAL_DISTRICT_NBR[i]#')");
                    
                AMT_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.AMT_SUPPORTED);
                AMT_EXPORT_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.AMT_EXPORT_SUPPORTED);
                WO_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.WO_SUPPORTED);
                MO_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.MO_SUPPORTED);
                RE_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.RE_SUPPORTED);
                EB_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.EB_SUPPORTED);
                SB_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.SB_SUPPORTED);
                OT_SUPPORTED = iif(subQry.recordCount eq 0,0,AMT_EXPORT_SUPPORTED - WO_SUPPORTED - MO_SUPPORTED - RE_SUPPORTED - EB_SUPPORTED - SB_SUPPORTED);	
        		if(!isNumeric(OT_SUPPORTED)) OT_SUPPORTED = 0;
				if(OT_SUPPORTED lt 0) OT_SUPPORTED = 0;	
		
                line = '#abbreviation_txt#,#CNGRSNL_DSTRCT_TXT#,#distName#,0,#WO_SUPPORTED#,#MO_SUPPORTED#,#RE_SUPPORTED#,#EB_SUPPORTED#,#SB_SUPPORTED#,#OT_SUPPORTED#,#AMT_SUPPORTED#,#AMT_EXPORT_SUPPORTED#,#DATE_UPDATED#';
                csvTxt = ListAppend(csvTxt,line,chr(10));		
                sql = '';
                if(RowID eq 0){
                    //INSERT
                    sql = "INSERT INTO #StateInitMapData_tbl# (#colsStateInit#) VALUES " &
                        "('#abbreviation_txt#',#CNGRSNL_DSTRCT_TXT#,#distName#,0,#WO_SUPPORTED#,#MO_SUPPORTED#,#RE_SUPPORTED#,#EB_SUPPORTED#,#SB_SUPPORTED#,#OT_SUPPORTED#,#AMT_SUPPORTED#,#AMT_EXPORT_SUPPORTED#,'#DATE_UPDATED#')";	
                    retStatus = application.oFusion.post(sql);					
                    if(retStatus eq '200 OK') {
                        cIns=cIns+1;
                    } else {
                        cErr=cErr+1;
                            WriteLog(type="Error", file="CongressionalMap", text="INSERT {#distName#} StateInitMapData - #retStatus# [#sql#]");
                    }
                } else {
                    doUpdate = fDoUpdate3(fStateDataInit,RowID,WO_SUPPORTED,MO_SUPPORTED,RE_SUPPORTED,EB_SUPPORTED,SB_SUPPORTED,OT_SUPPORTED,AMT_SUPPORTED,AMT_EXPORT_SUPPORTED);
                    if(doUpdate){
                        //UPDATE
                        sql = "UPDATE #StateInitMapData_tbl# SET ";
                        sql = sql & "WO_SUPPORTED = #WO_SUPPORTED#, ";
                        sql = sql & "MO_SUPPORTED = #MO_SUPPORTED#, ";
                        sql = sql & "RE_SUPPORTED = #RE_SUPPORTED#, ";
                        sql = sql & "EB_SUPPORTED = #EB_SUPPORTED#, ";
                        sql = sql & "SB_SUPPORTED = #SB_SUPPORTED#, ";
                        sql = sql & "OT_SUPPORTED = #OT_SUPPORTED#, ";
                        sql = sql & "AMT_SUPPORTED = #AMT_SUPPORTED#, ";
                        sql = sql & "AMT_EXPORT_SUPPORTED = #AMT_EXPORT_SUPPORTED#, ";					
                        sql = sql & "DATE_UPDATED = '#DATE_UPDATED#' ";
                        sql = sql & "WHERE ROWID = '#RowID#'";
                        retStatus = application.oFusion.post(sql);					
                        if(retStatus eq '200 OK') {
                            cUpd=cUpd+1;
                        } else {
                            cErr=cErr+1;
                            WriteLog(type="Error", file="CongressionalMap", text="UPDATE {#distName#} StateInitMapData - #retStatus# [#sql#]");
                        }
                    }
                }
            }
            csvFile = dirCurrent & 'StateInitMapData.csv';
            FileWrite(csvFile,csvTxt);
            WriteLog(type="Information", file="CongressionalMap", text="StateInitMapData.csv created : INS[#cIns#] UPD[#cUpd#] ERR[#cErr#]");
            
        </cfscript>
        
        <!--- State Map Poly Info (districts) --->
        <cfscript>
        WriteOutput('<h2>State Map Poly Info</h2><br>');
        //STATE MAP POLY
        //fusSDistrictExporterDataMain : 13N4zANBoKvgKjBn9kQ4gj7zMMVRlDM-NPqCCTMM
            colsState = 'ABBREVIATION_TXT,DISTRICT_NAME,CONGRESSIONAL_DISTRICT_NBR,DT_YR_FSCL,EXPORTER_COUNT,WO_SUPPORTED,MO_SUPPORTED,RE_SUPPORTED,EB_SUPPORTED,SB_SUPPORTED,OT_SUPPORTED,AMT_SUPPORTED,AMT_EXPORT_SUPPORTED,DATE_UPDATED';
            fStateData = application.oFusion.select('select rowid, #colsState# from #StateMapData_tbl#');
            ArchiveData('StateMapData',colsState,fStateData);
            cErr=0;cUpd=0;cIns=0;
            csvTxt = colsState;	
            for(i=1;i lte application.maps.qDistricts.recordCount;i=i+1)
            {
                abbreviation_txt = application.maps.qDistricts.abbreviation_txt[i];
                for(DT_YR_FSCL=2008;DT_YR_FSCL <= 2013;DT_YR_FSCL=DT_YR_FSCL+1){
                    abbreviation_txt = application.maps.qDistricts.abbreviation_txt[i];
                    CNGRSNL_DSTRCT_TXT = application.maps.qDistricts.CONGRESSIONAL_DISTRICT_NBR[i];
                    if(len(CNGRSNL_DSTRCT_TXT) eq 1) CNGRSNL_DSTRCT_TXT = '0' & CNGRSNL_DSTRCT_TXT;
                    distName = '#abbreviation_txt#-#CNGRSNL_DSTRCT_TXT#';
                    RowID = GetRowID(fStateData,abbreviation_txt,distName,DT_YR_FSCL);
                    
                    subQry = qry("select Sum(AMT_SUPPORTED) as AMT_SUPPORTED, sum(AMT_EXPORT_SUPPORTED) as AMT_EXPORT_SUPPORTED, 
                        sum(SB_SUPPORTED) as SB_SUPPORTED, sum(MO_SUPPORTED) as MO_SUPPORTED, sum(WO_SUPPORTED) as WO_SUPPORTED, sum(RE_SUPPORTED) as RE_SUPPORTED, sum(EB_SUPPORTED) as EB_SUPPORTED
                        from application.maps.qExporterMaster
                    where ABBREVIATION_TXT = '#abbreviation_txt#'
                        and DT_YR_FSCL = #DT_YR_FSCL#
                        and (CNGRSNL_DSTRCT = '#CNGRSNL_DSTRCT_TXT#' or CNGRSNL_DSTRCT = '#application.maps.qDistricts.CONGRESSIONAL_DISTRICT_NBR[i]#')");
            
                    AMT_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.AMT_SUPPORTED);
                    AMT_EXPORT_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.AMT_EXPORT_SUPPORTED);
                    EXPORTER_COUNT = 0;
                    WO_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.WO_SUPPORTED);
                    MO_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.MO_SUPPORTED);
                    RE_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.RE_SUPPORTED);
                    EB_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.EB_SUPPORTED);
                    SB_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.SB_SUPPORTED);
                    SB_SUPPORTED = iif(subQry.recordCount eq 0,0,subQry.SB_SUPPORTED);
                    OT_SUPPORTED = iif(subQry.recordCount eq 0,0,AMT_EXPORT_SUPPORTED - WO_SUPPORTED - MO_SUPPORTED - RE_SUPPORTED - EB_SUPPORTED - SB_SUPPORTED);
        			if(!isNumeric(OT_SUPPORTED)) OT_SUPPORTED = 0;	
					if(OT_SUPPORTED lt 0) OT_SUPPORTED = 0;	
            
                    line = '#abbreviation_txt#,#distName#,#CNGRSNL_DSTRCT_TXT#,#DT_YR_FSCL#,#EXPORTER_COUNT#,#WO_SUPPORTED#,#MO_SUPPORTED#,#RE_SUPPORTED#,#EB_SUPPORTED#,#SB_SUPPORTED#,#OT_SUPPORTED#,#AMT_SUPPORTED#,#AMT_EXPORT_SUPPORTED#,#DATE_UPDATED#';
                    csvTxt = ListAppend(csvTxt,line,chr(10));			
                    sql = '';
                    if(RowID eq 0){
                        //INSERT
                        sql = "INSERT INTO #StateMapData_tbl# (#colsState#) VALUES " &
                            "('#abbreviation_txt#',#distName#,#CNGRSNL_DSTRCT_TXT#,#DT_YR_FSCL#,#EXPORTER_COUNT#,#WO_SUPPORTED#,#MO_SUPPORTED#,#RE_SUPPORTED#,#EB_SUPPORTED#,#SB_SUPPORTED#,#OT_SUPPORTED#,#AMT_SUPPORTED#,#AMT_EXPORT_SUPPORTED#,'#DATE_UPDATED#')";		
                        retStatus = application.oFusion.post(sql);					
                        if(retStatus eq '200 OK') {
                            cIns=cIns+1;
                        } else {
                            cErr=cErr+1;
                            WriteLog(type="Error", file="CongressionalMap", text="INSERT {#distName# #DT_YR_FSCL#} StateMapData - #retStatus# [#sql#]");
                        }
                    } else {
                        doUpdate = fDoUpdate4(fStateData,RowID,WO_SUPPORTED,MO_SUPPORTED,RE_SUPPORTED,EB_SUPPORTED,SB_SUPPORTED,OT_SUPPORTED,AMT_SUPPORTED,AMT_EXPORT_SUPPORTED);
                        if(doUpdate){
                            //UPDATE
                            sql = "UPDATE #StateMapData_tbl# SET ";	
                            sql = sql & "EXPORTER_COUNT = #EXPORTER_COUNT#, ";
                            sql = sql & "WO_SUPPORTED = #WO_SUPPORTED#, ";
                            sql = sql & "MO_SUPPORTED = #MO_SUPPORTED#, ";
                            sql = sql & "RE_SUPPORTED = #RE_SUPPORTED#, ";
                            sql = sql & "EB_SUPPORTED = #EB_SUPPORTED#, ";
                            sql = sql & "SB_SUPPORTED = #SB_SUPPORTED#, ";
                            sql = sql & "OT_SUPPORTED = #OT_SUPPORTED#, ";
                            sql = sql & "AMT_SUPPORTED = #AMT_SUPPORTED#, ";
                            sql = sql & "AMT_EXPORT_SUPPORTED = #AMT_EXPORT_SUPPORTED#, ";				
                            sql = sql & "DATE_UPDATED = '#DATE_UPDATED#' ";
                            sql = sql & "WHERE ROWID = '#RowID#'";
                            retStatus = application.oFusion.post(sql);					
                            if(retStatus eq '200 OK') {
                                cUpd=cUpd+1;
                            } else {
                                cErr=cErr+1;
                            WriteLog(type="Error", file="CongressionalMap", text="UPDATE {#distName# #DT_YR_FSCL#} StateMapData - #retStatus# [#sql#]");
                            }
                        }
                    }
                }		
            }
            csvFile = dirCurrent & 'StateMapData.csv';
            FileWrite(csvFile,csvTxt);
            WriteLog(type="Information", file="CongressionalMap", text="StateMapData.csv created : INS[#cIns#] UPD[#cUpd#] ERR[#cErr#]");
            WriteLog(type="Information", file="CongressionalMap", text="Fusion Upload COMPLETE");
        </cfscript>
    
        <cfcatch>
            <cfscript>
                WriteLog(type="Error", file="CongressionalMap", text="#cfcatch.Message# - #cfcatch.Detail#");
            </cfscript>
        </cfcatch>
    </cftry>

</cfif>

<cffunction access="public" name="ArchiveData" output="false" returntype="void">
	<cfargument name="FileName" type="string" required="yes">
	<cfargument name="Cols" type="string" required="yes">
	<cfargument name="Qry" type="query" required="yes">    
    <cfset dirArchive = ExpandPath('/customcf/congressionalmap/admin/fusion/archive/')>
    <cfset thisFileName = arguments.FileName & '_#DateFormat(now(),"yyyymmdd")#.csv'>
    <cfset csvFile = dirArchive & thisFileName>
    <cfset txt = cols>
    <cfoutput query="Qry">
    	<cfset row = ''>        
        <cfloop index="c" list="#cols#">
        	<cfset cell = Evaluate('Qry.' & c)>
            <cfset row = ListAppend(row,cell)>
        </cfloop>
    	<cfset txt = ListAppend(txt,row,chr(10))>        
    </cfoutput>    
    <cffile action="write" file="#csvFile#" output="#txt#">
    <Cfscript>
	WriteLog(type="Information", file="CongressionalMap", text="#thisFileName# archived");
	</Cfscript>
</cffunction>

<cffunction access="public" name="qry" output="false" returntype="query">
	<cfargument name="sql" type="string" required="yes">
	<cfquery name="_qry" dbtype="query">
    	#PreserveSingleQuotes(sql)#
    </cfquery>
    <cfreturn _qry>
</cffunction>

<cffunction access="private" name="GetRowID" output="false" returntype="boolean">
    <cfargument name="fData" type="query" required="yes">
    <cfargument name="ABBREVIATION_TXT" type="string" required="no" default="-">
    <cfargument name="DISTRICT_NAME" type="string" required="no" default="-">
    <cfargument name="DT_YR_FSCL" type="numeric" required="no" default="0">
    <Cfquery name="q" dbtype="query">
        select * from fData where  
        <cfif arguments.ABBREVIATION_TXT neq '-'>
            ABBREVIATION_TXT = '#arguments.ABBREVIATION_TXT#'
        </cfif>
        <cfif arguments.DISTRICT_NAME neq '-'>
            AND DISTRICT_NAME = '#arguments.DISTRICT_NAME#'
        </cfif>
        <cfif arguments.DT_YR_FSCL neq 0>
            AND DT_YR_FSCL = #arguments.DT_YR_FSCL#
        </cfif>
    </Cfquery>
    <cfif q.recordCount>
        <cfreturn q.rowid>
    <cfelse>
        <cfreturn 0>
    </cfif>
</cffunction>

<cffunction access="private" name="fDoUpdate1" output="false" returntype="boolean">
	<cfargument name="fData" type="query" required="yes">
	<cfargument name="RowID" type="numeric" required="yes">
	<cfargument name="SalesSupported" type="numeric" required="yes">
	<cfargument name="Disbursements" type="numeric" required="yes">
	<cfargument name="TotalAuthorizations" type="numeric" required="yes">
	<cfargument name="EXPORTER_COUNT" type="numeric" required="yes">
	<Cfquery name="q" dbtype="query">
    	select * from fData where rowid = #arguments.rowid#
    </Cfquery>    
    <cfscript>	
		_doUpdate = false;
		if(ROUND(q.SalesSupported) != ROUND(arguments.SalesSupported)) _doUpdate = true;
		if(ROUND(q.Disbursements) != ROUND(arguments.Disbursements)) _doUpdate = true;
		if(ROUND(q.TotalAuthorizations) != ROUND(arguments.TotalAuthorizations)) _doUpdate = true;
		if(ROUND(q.EXPORTER_COUNT) != ROUND(arguments.EXPORTER_COUNT)) _doUpdate = true;
	</cfscript>   
    <cfreturn _doUpdate>
</cffunction>

<cffunction access="private" name="fDoUpdate2" output="false" returntype="boolean">
	<cfargument name="fData" type="query" required="yes">
	<cfargument name="RowID" type="numeric" required="yes">    
	<cfargument name="AMT_SUPPORTED" type="numeric" required="yes">
	<cfargument name="AMT_EXPORT_SUPPORTED" type="numeric" required="yes">
	<cfargument name="AMT_AUTH" type="numeric" required="yes">    
	<cfargument name="WO_SUPPORTED" type="numeric" required="yes">
	<cfargument name="MO_SUPPORTED" type="numeric" required="yes">
	<cfargument name="RE_SUPPORTED" type="numeric" required="yes">
	<cfargument name="EB_SUPPORTED" type="numeric" required="yes">
	<cfargument name="SB_SUPPORTED" type="numeric" required="yes">
	<cfargument name="OT_SUPPORTED" type="numeric" required="yes">    
	<Cfquery name="q" dbtype="query">
    	select * from fData where rowid = #arguments.rowid#
    </Cfquery>  
    <cfscript>
		_doUpdate = false;		
		if(ROUND(q.AMT_SUPPORTED) != ROUND(arguments.AMT_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.AMT_EXPORT_SUPPORTED) != ROUND(arguments.AMT_EXPORT_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.AMT_AUTH) != ROUND(arguments.AMT_AUTH)) _doUpdate = true;
		if(ROUND(q.WO_SUPPORTED) != ROUND(arguments.WO_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.MO_SUPPORTED) != ROUND(arguments.MO_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.RE_SUPPORTED) != ROUND(arguments.RE_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.EB_SUPPORTED) != ROUND(arguments.EB_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.SB_SUPPORTED) != ROUND(arguments.SB_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.OT_SUPPORTED) != ROUND(arguments.OT_SUPPORTED)) _doUpdate = true;
	</cfscript>     
    <cfreturn _doUpdate>
</cffunction>

<cffunction access="private" name="fDoUpdate3" output="false" returntype="boolean">
	<cfargument name="fData" type="query" required="yes">
	<cfargument name="RowID" type="numeric" required="yes">
	<cfargument name="WO_SUPPORTED" type="numeric" required="yes">
	<cfargument name="MO_SUPPORTED" type="numeric" required="yes">
	<cfargument name="RE_SUPPORTED" type="numeric" required="yes">
	<cfargument name="EB_SUPPORTED" type="numeric" required="yes">
	<cfargument name="SB_SUPPORTED" type="numeric" required="yes">
	<cfargument name="OT_SUPPORTED" type="numeric" required="yes">
	<cfargument name="AMT_SUPPORTED" type="numeric" required="yes">
	<cfargument name="AMT_EXPORT_SUPPORTED" type="numeric" required="yes">
	<Cfquery name="q" dbtype="query">
    	select * from fData where rowid = #arguments.rowid#
    </Cfquery>  
    <cfscript>
		_doUpdate = false;
		if(ROUND(q.WO_SUPPORTED) != ROUND(arguments.WO_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.MO_SUPPORTED) != ROUND(arguments.MO_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.RE_SUPPORTED) != ROUND(arguments.RE_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.EB_SUPPORTED) != ROUND(arguments.EB_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.SB_SUPPORTED) != ROUND(arguments.SB_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.OT_SUPPORTED) != ROUND(arguments.OT_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.AMT_SUPPORTED) != ROUND(arguments.AMT_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.AMT_EXPORT_SUPPORTED) != ROUND(arguments.AMT_EXPORT_SUPPORTED)) _doUpdate = true;
	</cfscript> 
    <cfreturn _doUpdate>
</cffunction>

<cffunction access="private" name="fDoUpdate4" output="false" returntype="boolean">
	<cfargument name="fData" type="query" required="yes">
	<cfargument name="RowID" type="numeric" required="yes">
	<cfargument name="WO_SUPPORTED" type="numeric" required="yes">
	<cfargument name="MO_SUPPORTED" type="numeric" required="yes">
	<cfargument name="RE_SUPPORTED" type="numeric" required="yes">
	<cfargument name="EB_SUPPORTED" type="numeric" required="yes">
	<cfargument name="SB_SUPPORTED" type="numeric" required="yes">
	<cfargument name="OT_SUPPORTED" type="numeric" required="yes">
	<cfargument name="AMT_SUPPORTED" type="numeric" required="yes">
	<cfargument name="AMT_EXPORT_SUPPORTED" type="numeric" required="yes">
	<Cfquery name="q" dbtype="query">
    	select * from fData where rowid = #arguments.rowid#
    </Cfquery>  
    <cfscript>
		_doUpdate = false;
		if(ROUND(q.WO_SUPPORTED) != ROUND(arguments.WO_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.MO_SUPPORTED) != ROUND(arguments.MO_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.RE_SUPPORTED) != ROUND(arguments.RE_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.EB_SUPPORTED) != ROUND(arguments.EB_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.SB_SUPPORTED) != ROUND(arguments.SB_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.OT_SUPPORTED) != ROUND(arguments.OT_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.AMT_SUPPORTED) != ROUND(arguments.AMT_SUPPORTED)) _doUpdate = true;
		if(ROUND(q.AMT_EXPORT_SUPPORTED) != ROUND(arguments.AMT_EXPORT_SUPPORTED)) _doUpdate = true;
	</cfscript> 
    <cfreturn _doUpdate>
</cffunction>