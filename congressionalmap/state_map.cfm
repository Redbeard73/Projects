<cftry>
	
<cfsetting showdebugoutput="yes">    
<cfif not isDefined('url.state')><cflocation url="us_map.cfm" addtoken="no"></cfif>
<cfscript>
	yrMin = application.maps.yrMin;
	yrMax = application.maps.yrMax;
	qStates = application.maps.qStates;
	
	if(!isDefined('application.maps.qDistricts#url.state#'))
		SetVariable('application.maps.qDistricts#url.state#',application.oMap.GetDistricts(url.state));
	
	if(!isDefined('application.maps.strExporters#url.state#'))
		SetVariable('application.maps.strExporters#url.state#',application.oExp.GetExporterCounts(application.maps.yrMin,application.maps.yrMax,url.state));
	
	
	qDistricts = Evaluate('application.maps.qDistricts' & url.state);
	strExporters = Evaluate('application.maps.strExporters' & url.state);
	qExpChart = strExporters.percData;
</cfscript>

<cfquery datasource="#application.maps.datasource#" name="StateData">
    select USA_STATE.NAME_TXT,LATITUDE_CENTER_NBR, LONGITUDE_CENTER_NBR, ZOOM_INITIAL_NBR 
    from USA_STATE 
    where ABBREVIATION_TXT = <cfqueryparam value="#url.state#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<!DOCTYPE HTML>
<html lang="en" xmlns:fb="http://ogp.me/ns/fb#" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <title><cfoutput>#StateData.name_txt#</cfoutput> Export Data : Export-Import Bank of the United States</title>
        <meta name="description" content="Ex-Im Bank is focused on helping small businesses's and has a dedicated team to assist them.  See how many businesses have been helped all across <cfoutput>#StateData.name_txt#</cfoutput>.">
        <meta name="viewport" content="width=device-width, maximum-scale=1">
		<meta name="apple-mobile-web-app-capable" content="yes"/>
        <link rel="stylesheet" href="<cfoutput>#application.maps.url#</cfoutput>ui/css/main.css">
        <script type="text/javascript">
          // check if touch device supported
          var is_touch_device = 'ontouchstart' in document.documentElement || 'onmsgesturechange' in window;
          // if this is NOT a touch device add class
          if (!is_touch_device) {
              window.onload = function (){
              document.getElementsByTagName('body')[0].className+=' no-touch';
            }
          }
        </script>
        <!--[if IE 8]>
        <script type="text/javascript" src="<cfoutput>#application.maps.url#</cfoutput>ui/js/ie8-polyfills.js"></script>
        <style type="text/css">
          #lrgMapPageWrapper form .checkbox {
          	width: 25px;
          	height: 30px;
          	padding: 0 1px 0 0;
          	background: url(ui/images/checkbox-desktop.png) no-repeat;
          	display: block;
          	clear: left;
          	float: left;
          }
          #lrgMapPageWrapper form label {
          	padding: 0 1px 0 0;
          	background: none;
          	height: 30px;
          	line-height:38px;
          }
        </style>
        <![endif]-->
        
    <style type="text/css">
		  <cfif ListFindNoCase('AL,CA,DE,GA,ID,IL,IN,ME,MS,NH,NJ,RI,UT,VY',url.state)>
			#map_canvas { height: 675px; width: 500px; background-color: #b5ccda; }
		  <cfelse>
			#map_canvas { height: 500px; width: 500px; background-color: #b5ccda; }
		  </cfif>
		.popUpWin{font-size:11px; color:#44678a;}
		#legend{font: bold 11px/1.1 Arial, Helvetica, sans-serif;padding-left:0px;padding-right:0px;}
		#legend > div {border:1px solid #012;padding:5px 5px 5px 8px; background-color:#ffffff!important;}
		#legend table{font-weight:400;margin-top:2px;}
		#legend table td{margin:5px;}
		#legend tr td:first-child{line-height:10px;width:11px;height:10px;border:1px solid #012;}
		
		div.dataTables_paginate #ExpDataTable_first, 
		div.dataTables_paginate #ExpDataTable_previous, 
		div.dataTables_paginate #ExpDataTable_next,
		div.dataTables_paginate #ExpDataTable_last {
			color: #0099CC;
			padding: 9px;
		}
		
		div.dataTables_paginate .paginate_active {
        	padding: 5px;
			color:#03C;
			font-weight:bold;
		}
		
		
		div.dataTables_paginate .paginate_button {
        	padding: 5px;
		}


		
    </style>
<!-- load jQuery -->
	<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.min.js"></script>
    <script type="text/javascript">window.jQuery || document.write('<script src="/ui/js/libs/jquery-1.7.1.min.js"><\/script>')  </script>	
    <script type="text/javascript">var j$ = jQuery.noConflict();</script>
    <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?client=<cfoutput>#application.maps.clientId#</cfoutput>&sensor=false&libraries=visualization"></script>
    <script type="text/javascript" src="ui/js/MapStyles.js"></script>
    <script type="text/javascript" src="ui/js/func.js"></script>
        <script type="text/javascript">
		var map;		
		var layerThemed = new google.maps.FusionTablesLayer();
		var layerBasic = new google.maps.FusionTablesLayer();	
		var polygonArray = new Array();
		var markerArray = [];	
		var infoArray = [];	
		var mapMode;

		function initialize() {	
			
			<cfoutput>
				var mapOptions = {
					center: new google.maps.LatLng(#StateData.LATITUDE_CENTER_NBR#,#StateData.LONGITUDE_CENTER_NBR#),
					zoom: #StateData.ZOOM_INITIAL_NBR#,
					disableDefaultUI: true,	
					zoomControl: true,
					zoomControlOptions: {
						style: google.maps.ZoomControlStyle.SMALL
					},
					mapTypeId: google.maps.MapTypeId.ROADMAP
				};
			</cfoutput>
		
			var styledMap = new google.maps.StyledMapType(stylesInner, {name: "Styled Map"});			
			map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
			map.mapTypes.set('map_style', styledMap);
			map.setMapTypeId('map_style');
	
			layerThemed = new google.maps.FusionTablesLayer({
				query: {
					select: 'geometry',
					from: '<cfoutput>#application.maps.fusStateExporterDataInitPoly#</cfoutput>',
					where: "ABBREVIATION_TXT CONTAINS IGNORING CASE '<cfoutput>#ucase(url.state)#</cfoutput>'"
				},
				options: { suppressInfoWindows: true },
				map: map,
				styles: mStyleThemed
			});
	
			layerBasic = new google.maps.FusionTablesLayer({
				query: {
					select: 'geometry',
					from: '<cfoutput>#application.maps.fusStateExporterDataInitPoly#</cfoutput>',
					where: "ABBREVIATION_TXT CONTAINS IGNORING CASE '<cfoutput>#ucase(url.state)#</cfoutput>'"
				},
				options: { suppressInfoWindows: true },
				styles: mStyleBasic
			});	
		
			var legend = document.getElementById('legend');		
			<cfset ControlPosition = 'LEFT_BOTTOM'>
			<cfif ListFindNoCase('AL,AS,AR,GA,GU,IN,IA,KY,ME,MT,NJ,NM,OH,OR,TN,UT,VT,WA,WV',url.state)>
				<cfset ControlPosition = 'RIGHT_BOTTOM'>
			</cfif>
			map.controls[google.maps.ControlPosition.<cfoutput>#ControlPosition#</cfoutput>].push(legend);
			
			google.maps.event.addListener(layerThemed, 'click', function(e) {
				window.location='district_map.cfm?state=<cfoutput>#ucase(url.state)#</cfoutput>&district=' + e.row['CNGRSNL_DSTRCT'].value;
			});
			
			mapMode = 'theme';
			
		}		

		//RedrawMapLayer(<cfoutput>#application.maps.yrMin#,#application.maps.yrMax#</cfoutput>);

		google.maps.event.addDomListener(window, 'load', initialize);
		
		function RedrawMapLayer(yS,yE){
			layerThemed.setMap(null);
			layerBasic.setMap(map);
			
			mapMode = 'poly';
			var qry = "SELECT";		
				qry += " DISTRICT_NAME, geometry";	
				qry += " , SUM(WO_SUPPORTED) as WO";
				qry += " , SUM(MO_SUPPORTED) as MO";
				qry += " , SUM(EB_SUPPORTED) as EB";
				qry += " , SUM(RE_SUPPORTED) as RE";
				qry += " , SUM(SB_SUPPORTED) as SB";
				qry += " , SUM(EXPORTER_COUNT) as EXPORTER_COUNT";
				qry += " , SUM(AMT_SUPPORTED) as AMT_SUPPORTED";
				qry += " , SUM(AMT_EXPORT_SUPPORTED) as AMT_EXPORT_SUPPORTED";
				qry += " , CONGRESSIONAL_DISTRICT_NBR";
				qry += " FROM <cfoutput>#application.maps.fusStateMap#</cfoutput>";
				qry += " WHERE DT_YR_FSCL >= " + yS;
				qry += " AND DT_YR_FSCL <= " + yE;
				qry += " AND CONGRESSIONAL_DISTRICT_NBR >= 1";
				qry += " AND ABBREVIATION_TXT = '<cfoutput>#url.state#</cfoutput>'";
				qry += " GROUP BY DISTRICT_NAME, geometry, CONGRESSIONAL_DISTRICT_NBR";
				qry += " ORDER BY DISTRICT_NAME";
												
//if (navigator.userAgent.indexOf("Firefox")!=-1) console.log(qry);

			for (i=0;i<polygonArray.length;i++) polygonArray[i].setMap(null);
			var script = document.createElement('script');
			var url = ['https://www.googleapis.com/fusiontables/v1/query?'];
			url.push('sql=');
			var encodedQuery = encodeURIComponent(qry);
			url.push(encodedQuery);
			url.push('&callback=drawMap');
			url.push('&key=<cfoutput>#application.maps.apiKey#</cfoutput>');
			script.src = url.join('');
			var body = document.getElementsByTagName('body')[0];
			body.appendChild(script);
		}
		
		function drawMap(data) {
			var rows = data['rows'];
			for (var i in rows) {
				var DISTRICT_NAME = rows[i][0];
				
				var WO_SUPPORTED = (document.getElementById('chkWO').checked)?Math.round(parseFloat(rows[i][2])):0;
				var MO_SUPPORTED = (document.getElementById('chkMO').checked)?Math.round(parseFloat(rows[i][3])):0;
				var EB_SUPPORTED = (document.getElementById('chkEB').checked)?Math.round(parseFloat(rows[i][4])):0;
				var RE_SUPPORTED = (document.getElementById('chkRE').checked)?Math.round(parseFloat(rows[i][5])):0;
				var SB_SUPPORTED = (document.getElementById('chkSB').checked)?Math.round(parseFloat(rows[i][6])):0;
				var EXP_COUNT = parseFloat(rows[i][7]);
								
				var AMT_SUPPORTED = Math.round(WO_SUPPORTED + MO_SUPPORTED + EB_SUPPORTED + RE_SUPPORTED + SB_SUPPORTED);
				var AMT_EXPORT_SUPPORTED = parseFloat(rows[i][9]);
				var CONGRESSIONAL_DISTRICT_NBR = parseFloat(rows[i][10]);
				
				var newCoordinates = [];
				var geometries = rows[i][1]['geometries'];
				if (geometries) {
					for (var j in geometries) {
						newCoordinates.push(constructNewCoordinates(geometries[j]));
					}
				} else {
					newCoordinates = constructNewCoordinates(rows[i][1]['geometry']);
				}

				var fillColor = '#537090';
				var fillOpacity = .50;
				if(AMT_SUPPORTED < 75000000) fillColor = '#6896b0';
				if(AMT_SUPPORTED < 50000000) fillColor = '#a8becb';
				if(AMT_SUPPORTED < 25000000) fillColor = '#e8e6e7';
				if(AMT_SUPPORTED < 10) fillOpacity = 0;
				
				polygonArray[i] = new google.maps.Polygon({
					paths: newCoordinates,
					strokeColor: "#000000",
					strokeOpacity: 0,
					strokeWeight: 1,
					fillColor: fillColor,
					fillOpacity: fillOpacity
				});
				addlisteners(polygonArray[i],DISTRICT_NAME,AMT_SUPPORTED,AMT_EXPORT_SUPPORTED,EXP_COUNT,CONGRESSIONAL_DISTRICT_NBR)	
				
				if(document.getElementById('chkShowExportLayer').checked)
				{
					polygonArray[i].setMap(map);
				}				
			}
		}
		function addlisteners(polygon,DISTRICT_NAME,AMT_SUPPORTED,AMT_EXPORT_SUPPORTED,EXP_COUNT,DISTRICT_NBR)
		{	
		<cfoutput>
			var infoTxt = '<table class="popUpWin">' + 
				'<tr><td colspan="2" class="popUpWin"><strong>#StateData.name_txt#: District: ' + DISTRICT_NAME + '</strong></td></tr>' +
				'<tr><td class="popUpWin">Export Sales Supported:</td><td align="right" class="popUpWin">$' + addCommas(Math.round(AMT_SUPPORTED)) + '</td></tr>' +
				'<tr><td class="popUpWin">Total Authorizations:</td><td align="right" class="popUpWin">$' + addCommas(Math.round(AMT_EXPORT_SUPPORTED)) + '</td></tr>' +
				'</table>';
		</cfoutput>
			var _time;
			polygon.infoWindow = new google.maps.InfoWindow({
				content: infoTxt,
				disableAutoPan: false
			});
			google.maps.event.addListener(polygon, 'mouseover', function(e) {
				this.setOptions({strokeOpacity: 1});
				var latLng = e.latLng;
				polygon.infoWindow.setPosition(latLng);
				_time = setTimeout(function() {polygon.infoWindow.open(map)},1000);
				
			});
			google.maps.event.addListener(polygon, 'mouseout', function() {
				this.setOptions({strokeOpacity: 0});
				clearTimeout(_time);
				polygon.infoWindow.close(map);
			});	
			google.maps.event.addListener(polygon, 'click', function() {
				dist = DISTRICT_NBR;
				if(DISTRICT_NBR.length ==1 ) dist = '0' + DISTRICT_NBR;
				<cfoutput>window.location='#application.maps.url#district_map.cfm?state=#ucase(url.state)#&district=' + dist;</cfoutput>
			});
		}
		  
		function constructNewCoordinates(polygon) {
			var newCoordinates = [];
			var coordinates = polygon['coordinates'][0];
			for (var i in coordinates) {
				newCoordinates.push(
				new google.maps.LatLng(coordinates[i][1], coordinates[i][0]));
			}
			return newCoordinates;
		}
		
				
		function CloseStreet(){
			map.getStreetView().setVisible(false);
		}
		
		function ShowStreet(LATITUDE,LONGITUDE,ROWID){			
			point = new google.maps.LatLng(LATITUDE,LONGITUDE)						
			var panorama = map.getStreetView();
			panorama.setPosition(point);
			
			var streetViewService = new google.maps.StreetViewService();
				streetViewService.getPanoramaByLocation(point, 100, function (streetViewPanoramaData, status) {
				if(status === google.maps.StreetViewStatus.OK){
					var oldPoint = point;
						point = streetViewPanoramaData.location.latLng;
						heading = google.maps.geometry.spherical.computeHeading(point,oldPoint);
						panorama.setPosition(point);
						panorama.setPov({heading: heading,zoom: 1,pitch: 0});
						
						panorama.setOptions({
							'addressControlOptions': {
								'position': google.maps.ControlPosition.BOTTOM_RIGHT
							}
						});						
						
						panorama.set('enableCloseButton', false);
						
						var _closer = document.getElementById("butCloser");
						if (_closer == null)
						{
							var buttonnode= document.createElement('input');
								buttonnode.setAttribute('type','button');
								buttonnode.setAttribute('name','closePano');
								buttonnode.setAttribute('value','Close Street View');
								buttonnode.setAttribute('id','butCloser');
								buttonnode.setAttribute('OnClick','CloseStreet()');
							panorama.controls[google.maps.ControlPosition.TOP].push(buttonnode);
						}
						
						panorama.setVisible(true);
				} else {
					heading = 0;
					panorama.setPov({heading: 0,zoom: 1,pitch: 0});
					alert('Street View Not Available');
				}
			});			
		}
	</script>
</head>
<body>
    
<!--[if lt IE 7]>
<p class="chromeframe">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">activate Google Chrome Frame</a> to improve your experience.</p>
<![endif]-->

<div class="skip"><a href="#lrgMapPageWrapper">Skip to Main Content</a></div> 




<div id="lrgMapPageWrapper" class="clearfix">


<div class="headerWrapper clearfix">
  <a href="http://www.exim.gov/" id="logo">Back to main EXIM site</a>
  <div class="navWrapper clearfix">
    <ul id="nav" class="clearfix" role="navigation">			
      <li><a 	href="/about/">About Us</a></li>
      <li><a 	href="/newsandevents/">News & Events</a></li>
      <li><a 	href="/products/">Products</a></li>
      <li><a	href="/tools/">Tools</a></li>
      <li><a 	href="/smallbusiness/">Small Business</a></li>
    </ul>
  </div>
</div><!--header-->

<div id="shares">
       <div class="addthis_toolbox addthis_default_style"> <a class="addthis_button_facebook"></a>
         <a g:plusone:annotation="none" g:plusone:size="small" class="addthis_button_google_plusone"></a>
         <a class="addthis_button_print" id="sharePrint"></a> <a class="addthis_button_email"
           id="shareEmail"></a>
       </div>
     </div>

  <div class="skip"><a href="usa-homepage-text-equivelent.html" title="Opens a Table with the data dislayed on the map">View as Text</a></div> 
  
   
   
  <!-- start googlemap flag wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- start googlemap flag wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmm -->

  <div id="googleMapFlagWrapper">
    <div class="flag">
      <div class="shade clearfix"><span class="bg-node"><cfoutput><a href="us_map.cfm">Export Data - USA</a></span><span class="bg-node"><a href="state_map.cfm?state=#ucase(url.state)#">#StateData.name_txt#</a></cfoutput></span> </div>
      <cfinclude template="show-legislators.cfm">
    </div>
    <div class="tri"></div>
  </div><!--#googleMapFlagWrapper-->
  
  <!-- end googlemap flag wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- end googlemap flag wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmm -->









  <!-- start data wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- start data wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->

    
<cftry>
  <div class="lrgMapDataWrapper">
  
    <h2>EXPORTERS:</h2>

    <cfoutput>
    <div class="clearfix" >
      <div class="chartlegend">
        <ul>
          <li class="strong"><span class="smlMapNumber"><span id="dTE">#NumberFormat(strExporters.EXPORTER_COUNT,',')#</span><span class="sq te"></span></span>Total Exporters</li>
          <li><span class="smlMapNumber"><span id="dSB">#NumberFormat(strExporters.COUNT_SB,',')#</span><span class="sq sb"></span></span>Small Business</li>
          <li><span class="smlMapNumber"><span id="dMO">#NumberFormat(strExporters.COUNT_MO,',')#</span><span class="sq mo"></span></span>Minority Owned</li>
          <li><span class="smlMapNumber"><span id="dWO">#NumberFormat(strExporters.COUNT_WO,',')#</span><span class="sq wo"></span></span>Women Owned</li>
          <li><span class="smlMapNumber"><span id="dRE">#NumberFormat(strExporters.COUNT_RE,',')#</span><span class="sq re"></span></span>Renewable Energy</li>
          <li><span class="smlMapNumber"><span id="dEB">#NumberFormat(strExporters.COUNT_ENV,',')#</span><span class="sq eb"></span><br/>
            <br/>
            </span>
            <div style="display:inline-block;width:60px;">Environmentally Beneficial</div>
          </li>
                  
        </ul>
      </div><!-- legend -->
      </cfoutput>
      
      
      <!-- FORMULAS  -->
      
      <!-- formula to figure "top:" -->
      <!-- ( (parent div's width - current div's width ) - 1 ) ) = top: XXpx -->
      
      <!-- formula to figure "left:" -->
      <!-- ( (parent div's width - current div's width ) - 1 ) / 2 ) = left: XXpx -->
      
      <!-- other notes -->
      <!-- these nested div's need to be in order or largest number to smallest with the class on them. -->
      <!-- "left:" or "top:" are allowed to be a negitive number -->
      
      
    <!--- Circle Chart --->
    <div id="chart" class="chart" >
    	<div id="te" class="te" style="width:100px; height:100px;">
        	<cfset pW = 100>
        	<cfoutput query="qExpChart">
            	<cfif dataCol neq 'te'>
					<cfscript>
						p = perc;
						wd = pW-p-1;
						ld = wd/2;
						WriteOutput('<div id="#dataCol#" class="#dataCol#" style="width:#p#px; height:#p#px; top:#wd#px; left:#ld#px">');
						pW = p;
					</cfscript>
                </cfif>
            </cfoutput>
        	<cfoutput query="qExpChart">
            	<cfif dataCol neq 'te'>
						WriteOutput('</div>');
                </cfif>
            </cfoutput>
        </div>
	</div>
    </div>
    
    <cfoutput>
    <div class="exportSummary">
    
      <h3 class="clear"><cfoutput>#ucase(ucase(url.state))#</cfoutput> Export Summary:</h3>
      <ul>
        <li><span class="smlMapNumber"><strong><span id="dSalesSupported">#application.oMap.DollarAbbr(strExporters.SalesSupported)#</span></strong></span> - Sales Supported</li>
        <li><span class="smlMapNumber"><span id="dDisbursements">#application.oMap.DollarAbbr(strExporters.Disbursements)#</span></span> - Disbursements</li>
        <li><span class="smlMapNumber"><span id="dTotalAuthorizations">#application.oMap.DollarAbbr(strExporters.TotalAuthorizations)#</span></span> - Total Authorizations</li>
      </ul>
      
      <h3>Top #listlen(strExporters.topDestList)# Export Destinations:</h3>
      <p><span id="dTopDest"><cfif len(trim(strExporters.topDestList))>#strExporters.topDestList#</span><cfelse>No Destinations Reported</cfif></p>

      <h3>Top Exporters:</h3>
      	<cfif arrayLen(strExporters.topExportersArr)>
            <ol>
                <cfloop index="i" from="1" to="#arrayLen(strExporters.topExportersArr)#">
                    <cfif len(trim(strExporters.topExportersArr[i]))><li id="dTopExp#i#">#strExporters.topExportersArr[i]#</li></cfif>
                </cfloop>
            </ol>
        <cfelse>
        	No Exporters Reported
        </cfif>
    </div>
    </cfoutput>
    
    <cfcatch>
<!---    	<cfhttp url="admin/recache.cfm?state=#url.state#" resolveurl="no"></cfhttp>
        <cflocation url="state_map.cfm?state=#url.state#" addtoken="no">--->
    </cfcatch>
    
</cftry>
    
  </div><!--.smlMapDataWrapper --> 
  
  <!-- end data wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- end data wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->

  






  
  <!-- start googlemap wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- start googlemap wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  
  <div class="lrgGoogleMapWrapper">
   
    <div class="mapOutline">
    
      <div id="mapsGoHere">
        <div id="map_canvas"></div><!--mapsGoHere-->
        <div id="legend">
            <div "legend-inner">
                Export Dollars By State
                <table>
                    <tr><td style="background:#44678a">&nbsp;&nbsp;</td><td>&gt; $75 million</td></tr>
                    <tr><td style="background:#5f93ae"></td><td>&gt; $50 million</td></tr>
                    <tr><td style="background:#b4c1c8"></td><td>&gt; $25 million</td></tr>
                    <tr><td style="background:#e8e7e7"></td><td>&lt; $25 million</td></tr>
                </table>
            </div>
        </div>
      </div>
      <div class="lrgInstructions">
        <p>Hover map for more information. Click district to see detailed district view, or choose district from dropdown. &rarr;</p>
      </div>
    </div><!--mapOutline-->
    
	<div class="lrgDislaimer">
		<p>Note:  Exporters can belong to more than one category.</p>
	</div>
    
        
  </div><!--lrgGoogleMapWrapper-->
  
  <!-- end googlemap wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- end googlemap wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->

    
    
    
    
    
    
  
  

  <!-- start form wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- start form wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
    
    <form class="smlMapFormWrapper" action="post">
      <div class="fauxFieldset">
        <div class="fauxLegend">Filters</div>
        
          <div id="rangeWrapper">
          <h4>Choose Date Range:</h4>
              <div class="range1wrapper">
                <input type="input" id="range1" name="range1" min="<cfoutput>#application.maps.yrMin#</cfoutput>" max="<cfoutput>#application.maps.yrMax#</cfoutput>" value="<cfoutput>#application.maps.yrMin#</cfoutput>" step="1" />
              </div>
              <div class="range2wrapper">
                <input type="input" id="range2" name="range2" min="<cfoutput>#application.maps.yrMin#</cfoutput>" max="<cfoutput>#application.maps.yrMax#</cfoutput>" value="<cfoutput>#application.maps.yrMax#</cfoutput>" step="1" />
              </div>
          </div><!--rangeWrapper -->
        
        
        
        <fieldset class="checkboxFilters" id="chkFilters">
        
          <h4>Exporter Type:</h4>
          <input type='checkbox' name='chkSB' class="styled" value='valuable' checked="checked" id="chkSB" /><label for="chkSB" tabindex="0">Small Business</label>
          <input type='checkbox' name='chkMO' class="styled" value='valuable' checked="checked" id="chkMO" /><label for="chkMO" tabindex="0">Minority Owned</label>
          <input type='checkbox' name='chkWO' class="styled" value='valuable' checked="checked" id="chkWO" /><label for="chkWO" tabindex="0">Women Owned</label>
          <input type='checkbox' name='chkRE' class="styled" value='valuable' checked="checked" id="chkRE" /><label for="chkRE" tabindex="0">Renewable Energy</label>
          <input type='checkbox' name='chkEB' class="styled" value='valuable' checked="checked" id="chkEB" /><label  for="chkEB" tabindex="0">Environmentally <span style="display:block;margin-top:-20px;">Beneficial</span></label>
          <input type='checkbox' name='chkOT' class="styled" value='valuable' checked="checked" id="chkOT" /><label onclick="" for="chkOT" tabindex="0">Other Exporters</label>
          
        </fieldset>
        
        <br/>
        <fieldset>
        
        <h4>Choose District:</h4>
        <label for="distSelect" class="screenReadersOnly">Choose District:</label>
        <select name="distSelect" id="distSelect" class="smlMapSelect">
          <option value="<cfoutput>#url.state#</cfoutput>">Select District</option>
          <cfoutput query="qDistricts">
          	<Cfset CONGRESSIONAL_DISTRICT_TXT = iif(len(CONGRESSIONAL_DISTRICT_NBR) eq 1,de("0"),de("")) & CONGRESSIONAL_DISTRICT_NBR>
          	<option value="#CONGRESSIONAL_DISTRICT_NBR#">#ABBREVIATION_TXT# - #CONGRESSIONAL_DISTRICT_TXT#</option>
          </cfoutput>
        </select>
        
        </fieldset>

        <div style="padding-top:25px;">
          <fieldset>
            <input type='checkbox' name='chkShowExportLayer' class="styled" value='valuable' id="chkShowExportLayer"  checked="checked"/><label for="chkShowExportLayer" tabindex="0">Export Dollars by State</label><br>
          </fieldset>
        </div>
      </div><!-- end fauxFieldset -->
    </form>
    
  <!-- end form wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- end form wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->








  <!-- start table wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- start table wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->


  <div id="dataTableWrapper">
    
    <div class="dataTableBanner">
      <div class="show-icon"></div>
      <a href="##">
        <div class="showText" id="showText">Hide Detailed Data</div>
      </a>
    </div><!--datatablebanner -->
    
    <div id="dataTable">       

        <table class="data addsorting" id="ExpDataTable">
            <caption class="screenReadersOnly">EXIM Supported Export Activity</caption>
            <thead>
                <tr>
                    <th class="header">Exporter</th>
                    <th class="header">City</th>
                    <th class="header">District</th>
                    <th class="header">Product</th>
                    <th class="header">Total Disbursements</th>
                    <th class="header">Total Export Sales Supported</th>
                    <th class="header">ROWID</th>        
                </tr>
            </thead>
            <tbody>
            <!---
            	<cfoutput query="qDataTable">
            	<tr>
                	<td>#EXPORTER_NAME#</td>
                	<td>#EXPORTER_CITY#</td>
                	<td>#CNGRSNL_DSTRCT#</td>
                	<td>#EXPORTER_NAICS_LVL2_DESC#</td>
                	<td>#AMT_EXPORT_SUPPORTED#</td>
                	<td>#AMT_AUTH#</td>
                	<td>#currentRow#</td>
                </tr>
                </cfoutput>
				--->
            </tbody>
        </table>
        
    </div><!--dataTable-->
  
  
  </div><!--dataTableWrapper-->
        
  <!-- end table wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- end table wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  

</div><!-- #lrgMapWrapper -->






<!-- naturally deffered JS -->
<script type="text/javascript" src="ui/js/jquery.plugins.js"></script>
<script type="text/javascript" src="ui/js/common.js"></script>
<script type="text/javascript" src="ui/js/jquery.dataTables.js"></script>

<script>

		var loaded = false;
	j$(document).ready(function () {
		var yStart = j$('#range1').val();
		var yEnd = j$('#range2').val();		
		
		j$('#range1').change(function(){
			if(j$('#range1').val() > j$('#range2').val()) j$('#range2').val(j$('#range1').val());
			Reload(1,1,1,1,1);
		});
		j$('#range2').change(function(){
			if(j$('#range2').val() < j$('#range1').val()) j$('#range1').val(j$('#range2').val());
			Reload(1,1,1,1,1);
		});
		
		var Browser = {
		  Version: function() {
			var version = 0; 
			if (navigator.appVersion.indexOf("MSIE") != -1) version = parseFloat(navigator.appVersion.split("MSIE")[1]);
			return version;
		  }
		}
		
		function Reload(_Loading,_RedrawMapLayer,_LoadExpData,_DrawChart,_LoadExpMarkers)
		{
			if(_Loading) Loading();
			if(Browser.Version() == 0)
			{
				if(_RedrawMapLayer) RedrawMapLayer(j$('#range1').val(),j$('#range2').val());
			}
			if(_LoadExpData) LoadExpData(j$('#range1').val(),j$('#range2').val());
			if(_DrawChart) DrawChart(j$('#range1').val(),j$('#range2').val());
			if(_LoadExpMarkers){
				LoadExpMarkers(j$('#range1').val(),j$('#range2').val());
				LoadDataTable(j$('#range1').val(),j$('#range2').val());
			}		
		}
		
		
		j$("#chkShowExportLayer").bind('propertychange change', function(e) {
		//j$('#chkShowExportLayer').change(function(){
			if(mapMode == 'poly')
			{
				for (var p in polygonArray) {
					if (this.checked){
						polygonArray[p].setMap(map); 
					} else {
						polygonArray[p].setMap(null);
					}
				}
			} else {
				if (this.checked){
					layerBasic.setMap(null);
					layerThemed.setMap(map);		
				} else {
					layerThemed.setMap(null);
					layerBasic.setMap(map);	
				}	
			}
		});

		j$('#showText').click(function(){
			if(this.innerHTML == 'Show Detailed Data') this.innerHTML = 'Hide Detailed Data';
			else this.innerHTML = 'Show Detailed Data';
		});
		
		function Loading(){
			j$('#chart').html('<div style="background:#FFF;border:1px solid #C0C0C0;width:100px; height:100px;"></div>');
			j$('#dTE').html('&nbsp;');
			j$('#dSB').html('&nbsp;');
			j$('#dMO').html('&nbsp;');
			j$('#dWO').html('&nbsp;');
			j$('#dRE').html('&nbsp;');
			j$('#dEB').html('&nbsp;');					
			j$('#dSalesSupported').html('&nbsp;');
			j$('#dDisbursements').html('&nbsp;');
			j$('#dTotalAuthorizations').html('&nbsp;');
			j$('#dTopDest').html('&nbsp;');
			j$('#dTopExp1').html('&nbsp;');
			j$('#dTopExp2').html('&nbsp;');
			j$('#dTopExp3').html('&nbsp;');
		}	
		function LoadExpData(yS,yE)
		{
			j$.ajax({
				url: "cfc/expJSON.cfc",
				type: "get",
				dataType: "json",
				data: {
					method: "GetExporterCounts"
						, ABBREVIATION_TXT: "<cfoutput>#ucase(url.state)#</cfoutput>"
						, yStart: yS
						, yEnd: yE
					},
				success: function (data){
					j$('#dTE').text(data.COUNT_ALL);
					j$('#dSB').text(data.COUNT_SB);
					j$('#dMO').text(data.COUNT_MO);
					j$('#dWO').text(data.COUNT_WO);
					j$('#dRE').text(data.COUNT_RE);
					j$('#dEB').text(data.COUNT_ENV);					
					j$('#dSalesSupported').text(data.SalesSupportedAbbr);
					j$('#dDisbursements').text(data.DisbursementsAbbr);
					j$('#dTotalAuthorizations').text(data.TotalAuthorizationsAbbr);
					j$('#dTopDest').text(data.topDestList);
					j$('#dTopExp1').text(data.topExporter1);
					j$('#dTopExp2').text(data.topExporter2);
					j$('#dTopExp3').text(data.topExporter3);
				},
				error: function (xhr, textStatus, errorThrown){
					//alert(errorThrown);
				}
			});
		}
				
		function DrawChart(yS,yE)
		{
			j$.ajax({
				url: "cfc/expJSON.cfc",
				type: "get",
				dataType: "json",
				data: {
					method: "GetExpChart"
						, ABBREVIATION_TXT: "<cfoutput>#ucase(url.state)#</cfoutput>"
						, yStart: yS
						, yEnd: yE
					},
				success: function (data){
					var obj = j$.parseJSON(data.percData);
					
					j$('#chart').text('');
					var i = 0;
					var pW = 100;
					
					t = '<div id="te" class="te" style="width:100px; height:100px;">';
					for(i=1;i <= 4;i=i+1){
						id=obj.DATA[i][0];
						perc=obj.DATA[i][1];			
						wd = pW-perc-1;
						lt = wd/2;
						t = t + '<div id="' + id + '" class="' + id + '" style="width:' + perc + 'px; height:' + perc + 'px; top:' + wd + 'px; left:' + lt + 'px">';
						pW = perc;				
					}
					for(i=1;i <= 4;i=i+1) t = t + '</div>';	
					t = t + '</div>';	
					j$('#chart').append(t);	
					
				},
				error: function (xhr, textStatus, errorThrown){
					//alert(errorThrown);
				}
			});
		}
		
		function LoadExpMarkers(yS,yE)
		{
			for(i=1;i<markerArray.length;i++) markerArray[i].setMap(null);
			for(i=1;i<infoArray.length;i++) infoArray[i].setMap(null);
			markerArray = [];
			infoArray = [];
			j$.ajax({
				url: "cfc/expJSON.cfc",
				type: "get",
				dataType: "json",
				data: {
					method: "GetStateDataMarkers"
						, ABBREVIATION_TXT: "<cfoutput>#ucase(url.state)#</cfoutput>"
						, yStart: yS
						, yEnd: yE
						, FLAG_SB: (document.getElementById('chkSB').checked)?1:0  
						, FLAG_MO: (document.getElementById('chkMO').checked)?1:0  
						, FLAG_WO: (document.getElementById('chkWO').checked)?1:0  
						, FLAG_ENV: (document.getElementById('chkEB').checked)?1:0  
						, FLAG_RE: (document.getElementById('chkRE').checked)?1:0 
						, FLAG_OT: 0
					},
				success: function (results){
					for(i=0;i<results.aaData.length;i++){						
						EXPORTER_NAME = results.aaData[i].EXPORTER_NAME;
						EXPORTER_CITY = results.aaData[i].EXPORTER_CITY;
						CNGRSNL_DSTRCT = results.aaData[i].CNGRSNL_DSTRCT;
						EXPORTER_ADDRESS_LINE_1 = results.aaData[i].EXPORTER_ADDRESS_LINE_1;
						EXPORTER_ZIP_CODE = results.aaData[i].EXPORTER_ZIP_CODE;
						LATITUDE = results.aaData[i].LATITUDE;
						LONGITUDE = results.aaData[i].LONGITUDE;
						ROWID = Math.round(results.aaData[i].ROWID);
						STREETIMAGE_URL = results.aaData[i].STREETIMAGE_URL;						
			
						LatLng = new google.maps.LatLng(LATITUDE,LONGITUDE);
						isAcc = true;
						if(!isNumeric(LATITUDE) || !isNumeric(LONGITUDE)){ LatLng = map.getCenter(); isAcc = false;}						
						markerArray[ROWID] = new google.maps.Marker({position: LatLng, map: map, icon: 'ui/images/red-dot.png'});
						addInfoListener(ROWID,EXPORTER_NAME,EXPORTER_ADDRESS_LINE_1,EXPORTER_CITY,'<cfoutput>#url.state#</cfoutput>',CNGRSNL_DSTRCT,EXPORTER_ZIP_CODE,isAcc,STREETIMAGE_URL);
					}
				},
				error: function (xhr, textStatus, errorThrown){
					//alert(errorThrown);
				}
			});
		}
		
		function addInfoListener(ROWID,EXPORTER_NAME,EXPORTER_ADDRESS_LINE_1,EXPORTER_CITY,ABBREVIATION_TXT,CNGRSNL_DSTRCT,EXPORTER_ZIP_CODE,isAcc,STREETIMAGE_URL){
			
			var addr = "<strong>" + EXPORTER_NAME + "</strong><br>";
				if(EXPORTER_ADDRESS_LINE_1.replace(/\s/g,'') != '') addr = addr + EXPORTER_ADDRESS_LINE_1 + "<br>";
				addr = addr + EXPORTER_CITY + ", " + ABBREVIATION_TXT + "<br>" + zipcodeformat(EXPORTER_ZIP_CODE);
			var imgTag = "<img id='streetimage_" + ROWID + "' src='" + STREETIMAGE_URL + "' alt='" + EXPORTER_NAME + "' onclick='ShowStreet(" + markerArray[ROWID].getPosition().lat() + "," + markerArray[ROWID].getPosition().lng()  + "," + ROWID + ");'/>";
			
			var strButton = "<input id='streetbutton_" + ROWID + "' type='button' onclick='ShowStreet(" + markerArray[ROWID].getPosition().lat() + "," + markerArray[ROWID].getPosition().lng()  + "," + ROWID + ");' value='Open Street View'>";

			var txt="<table border='0' cellpadding='3' cellspacing='0'>";
				txt = txt + "<tr>";
				txt = txt + "<td valign='top' class='popUpWin'>" + addr + "</td>";
				txt = txt + "<td valign='top' class='popUpWin' rowspan='2'>" + imgTag + "</td>";
				txt = txt + "</tr>";
				txt = txt + "<tr>";
				txt = txt + "<td valign='bottom' class='popUpWin'>" + strButton + "</td>";
				txt = txt + "</tr>";
				txt = txt + "</table>";
				
			infoArray[ROWID] = new google.maps.InfoWindow({content: txt, disableAutoPan: false});
						
			google.maps.event.addListener(markerArray[ROWID], 'click', function () {
				for(i=1;i<infoArray.length;i++) infoArray[i].close(map);
				infoArray[ROWID].open(map, markerArray[ROWID]);	
			});	
		}

		function LoadDataTable(yS,yE)
		{			
			var params = 'ABBREVIATION_TXT=<cfoutput>#url.state#</cfoutput>' +
			'&yStart=' + yS +
			'&yEnd=' + yE +
			'&FLAG_SB=' + ((document.getElementById('chkSB').checked)?1:0).toString() +
			'&FLAG_MO=' + ((document.getElementById('chkMO').checked)?1:0).toString() +
			'&FLAG_WO=' + ((document.getElementById('chkWO').checked)?1:0).toString() +
			'&FLAG_ENV=' + ((document.getElementById('chkEB').checked)?1:0).toString() +
			'&FLAG_RE=' + ((document.getElementById('chkRE').checked)?1:0).toString() +
			'&FLAG_OT=' + ((document.getElementById('chkOT').checked)?1:0).toString();
			
			var oTable = j$('#ExpDataTable').dataTable({
				"bProcessing": true,
				"sAjaxSource": 'cfc/expJSON.cfc?method=GetStateDataTable&' + params,
				"aoColumns": [
					{ "mDataProp": "EXPORTER_NAME" , "sTitle": "Exporter"},
					{ "mDataProp": "EXPORTER_CITY" , "sTitle": "City"},
					{ "mDataProp": "CNGRSNL_DSTRCT" , "sTitle": "District"},
					{ "mDataProp": "EXPORTER_NAICS_LVL2_DESC_ALT" , "sTitle": "Product"},
					{ "mDataProp": "SALESUPPORTEDFORMATTED" , "sTitle": "Total Disbursements"},
					{ "mDataProp": "AUTHORIZEDFORMATTED" , "sTitle": "Total Export Sales Supported"},
					{ "mDataProp": "ROWID" , "sTitle": "ROWID", "bVisible": false }
				],
				"bPaginate": true,
				"bFilter": true,
				"bAutoWidth": false,
				"bDestroy": true,
				"bDeferRender": true,
				"bLengthChange": true,
				"sPagePrevEnabled": "",
				"sPaginationType": "full_numbers",
				iDisplayLength: 50,
				"fnInitComplete": function (){
					j$(oTable.fnGetNodes()).click(function (){	
						CloseStreet();					
						var aPos = oTable.fnGetPosition(this);
						var ROWID = Math.round(oTable.fnGetData(aPos,6));
						for(i=1;i<infoArray.length;i++) infoArray[i].close(map);
						infoArray[ROWID].open(map, markerArray[ROWID]);
						j$('body,html').animate({scrollTop: 0}, 800);
					});
				},
				"oLanguage": {
					
					"sInfo": "Showing _START_ to _END_ of _TOTAL_ exporters",
					"sProcessing": "",
						
					"oPaginate": {
						"sPrevious": "&lt;&lt;&nbsp;Previous&nbsp;&nbsp;&nbsp;",
						"sNext": "Next&nbsp;&nbsp;&gt;&gt;"
						}
				},
				"fnDrawCallback": function( oSettings ) {
					iCurrentPage = Math.ceil(oSettings._iDisplayStart / oSettings._iDisplayLength) + 1;
					
					if(iCurrentPage == 1) 
					{
						document.getElementById('ExpDataTable_previous').style.display='none';
						document.getElementById('ExpDataTable_first').style.display='none';						
					} else {
						document.getElementById('ExpDataTable_previous').style.display='';
						document.getElementById('ExpDataTable_first').style.display='';
					}
					
					if(oSettings.fnDisplayEnd() >= oSettings.fnRecordsDisplay())
					{
						document.getElementById('ExpDataTable_next').style.display='none';
						document.getElementById('ExpDataTable_last').style.display='none';
					} else {
						document.getElementById('ExpDataTable_next').style.display='';
						document.getElementById('ExpDataTable_last').style.display='';
					}
					
				}
			});	
		}
		

		j$('#distSelect').change(function(){			
			dist = j$('#distSelect').val();
			if(dist.length == 1) dist = '0' + dist;			
			window.location='district_map.cfm?state=<cfoutput>#ucase(url.state)#</cfoutput>&district=' + dist;
		});
	
	
		j$(window).load(function () {
			if(yStart != <cfoutput>#yrMin#</cfoutput> || yEnd != <cfoutput>#yrMax#</cfoutput> ||
			!document.getElementById('chkSB').checked ||
			!document.getElementById('chkWO').checked ||
			!document.getElementById('chkMO').checked ||
			!document.getElementById('chkEB').checked ||
			!document.getElementById('chkRE').checked ||
			!document.getElementById('chkOT').checked){
				Reload(1,1,0,1,1);
			}
			LoadExpMarkers(j$('#range1').val(),j$('#range2').val());
			LoadDataTable(j$('#range1').val(),j$('#range2').val());
/*
			var oTable = j$('#ExpDataTable').dataTable({
				"bPaginate": false,
				"bFilter": true,
				"bAutoWidth": false,
				"aoColumns": [
					null,
					null,
					null,
					null,
					null,
					null,
					{"bVisible": false }
				],			
			});
			j$(oTable.fnGetNodes()).click(function (){	
				CloseStreet();					
				var aPos = oTable.fnGetPosition(this);
				var ROWID = Math.round(oTable.fnGetData(aPos,6));
				for(i=1;i<infoArray.length;i++) infoArray[i].close(map);
				infoArray[ROWID].open(map, markerArray[ROWID]);
				j$('body,html').animate({scrollTop: 0}, 800);
			});
	*/		
			j$("#dataTable").show();	
	
			j$("#chkWO").bind('propertychange click', function(e) {
				Reload(0,1,0,0,1);
			});
			
			j$("#chkMO").bind('propertychange click', function(e) {
				Reload(0,1,0,0,1);
			});
			
			j$("#chkEB").bind('propertychange click', function(e) {
				Reload(0,1,0,0,1);
			});
			
			j$("#chkRE").bind('propertychange click', function(e) {
				Reload(0,1,0,0,1);
			});
			
			j$("#chkSB").bind('propertychange click', function(e) {
				Reload(0,1,0,0,1);
			});
	
			j$("#chkOT").bind('propertychange click', function(e) {
				Reload(0,1,0,0,1);
			});
		});
	

	});
	
</script>

<!-- init the AddThis code --> 
<script type="text/javascript">var addthis_config = {ui_508_compliant: true};</script>
<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=xa-4f916fc74c194553"></script> 



</body>

<cfcatch type="any"> 
	<cfdump var=#cfcatch#/>
</cfcatch>
</cftry>
