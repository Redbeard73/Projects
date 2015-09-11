<cftry>
<cfscript>
	yrMin = application.maps.yrMin;
	yrMax = application.maps.yrMax;
	qStates = application.maps.qStates;
	strExporters = application.maps.strExportersUS;
	qExpChart = strExporters.percData;
</cfscript>
<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en"> 
<head>
    <title>Homepage Map : Export-Import Bank of the United States</title>
	<meta http-equiv="X-UA-Compatible" content="IE=edge"> 
    <meta http-equiv="cache-control" content="no-cache"> <!-- tells browser not to cache -->
    <meta http-equiv="expires" content="0"> <!-- says that the cache expires 'now' -->
    <meta http-equiv="pragma" content="no-cache"> <!-- says not to use cached stuff, if there is any -->
	<!---- The following JavaScript function will cause the JavaScript error, but won't fail the ajax JSON callback.  ---->
	<!---<script type="text/javascript" src="/commonspot/javascript/browser-all.js"></script>--->

    <link href="<cfoutput>#application.maps.url#</cfoutput>ui/css/google-map-styles.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?client=<cfoutput>#application.maps.clientId#</cfoutput>&sensor=false"></script>
	<script type="text/javascript" src="ui/js/MapStyles.js"></script>
    <script type="text/javascript" src="ui/js/func.js"></script>
    <script type="text/javascript">
		var map;
		var layer;
		var polygonArray = new Array();
		function initialize() {	
						
			var mapOptions = {
				center: new google.maps.LatLng(<cfoutput>#application.maps.us_center#</cfoutput>),
				zoom: 3,
				disableDefaultUI: true,	
				zoomControl: true,
				scaleControl: false,
				scrollwheel: true,
				disableDoubleClickZoom: true,
				zoomControlOptions: {
					style: google.maps.ZoomControlStyle.SMALL
				},
				mapTypeId: google.maps.MapTypeId.ROADMAP
        	};
			
			var styledMap = new google.maps.StyledMapType(stylesHome, {name: "Styled Map"});			
       		map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
			map.mapTypes.set('map_style', styledMap);
			map.setMapTypeId('map_style');
        
			var layer = new google.maps.FusionTablesLayer({
				query: {
					select: "geometry",
					from: "<cfoutput>#application.maps.fusStateExporterDataPoly#</cfoutput>"
				},
				options: {
            		suppressInfoWindows: true
          		},
				map: map,
				styles: mStyleHomepage
			});

			google.maps.event.addListener(layer, 'click', function(e) {
				<cfoutput>parent.location='#application.maps.url#state_map.cfm?state=' + e.row['ABBREVIATION_TXT'].value;</cfoutput>
			});

			layer.setMap(map);	
			var legend = document.getElementById('legend');		
			map.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(legend);	

			google.maps.event.addListener(map, 'zoom_changed', function() {
				if (map.getZoom() < 2) map.setZoom(2);
				if (map.getZoom() > 8) map.setZoom(6);
			});
			
			//Create SQL
			var qry = "SELECT";	
				qry += " geometry";		
				qry += " , ABBREVIATION_TXT";			
				qry += " , NAME_TXT";		
				qry += " , SalesSupported";		
				qry += " , Disbursements";		
				qry += " , Authorizations";		
				qry += " , TotalAuthorizations";
				qry += " , EXPORTER_COUNT";
				qry += " FROM <cfoutput>#application.maps.fusStateExporterDataPoly#</cfoutput>";
				qry += " ORDER BY ABBREVIATION_TXT";
				
			// Initialize JSONP request
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
			legend.style.display = '';
			
		}
		google.maps.event.addDomListener(window, 'load', initialize);
		
		function drawMap(data) {
			var rows = data['rows'];
			for (var i in rows) {
				var geometries = rows[i][0]['geometries'];	
				var ABBREVIATION_TXT = rows[i][1];	
				var NAME_TXT = rows[i][2];		
				var SalesSupported = rows[i][3];
				var Disbursements = rows[i][4];
				var Authorizations = rows[i][5];
				var TotalAuthorizations = rows[i][6];
				var EXPORTER_COUNT = rows[i][7];
				
				var newCoordinates = [];
				
				if (geometries) {
					for (var j in geometries) {
						newCoordinates.push(constructNewCoordinates(geometries[j]));
					}
				} else {
					newCoordinates = constructNewCoordinates(rows[i][0]['geometry']);
				}
				
				polygonArray[i] = new google.maps.Polygon({
					paths: newCoordinates,
					strokeColor: "#FFFFFF",
					strokeOpacity: 0,
					strokeWeight: 0,
					fillColor: "#FFFFFF",
					fillOpacity: 0
				});
				
				infoTxt = infotext(NAME_TXT,SalesSupported,Disbursements,TotalAuthorizations,EXPORTER_COUNT);
				
				addlisteners(polygonArray[i],ABBREVIATION_TXT,infoTxt)		
				
				polygonArray[i].setMap(map);
			}
		}
		
		function addlisteners(polygon,state_abbr,infoTxt)
		{	
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
				<cfoutput>parent.location='#application.maps.url#state_map.cfm?state=' + state_abbr;</cfoutput>
			});
		}
		function addCommas(str)
		{
			str += '';
			str = str.replace(/,/g, '')
			v = str.split('.');
			v1 = v[0];
			v2 = v.length > 1 ? '.' + v[1] : '';
			var rgx = /(\d+)(\d{3})/;
			while (rgx.test(v1)) {
				v1 = v1.replace(rgx, '$1' + ',' + '$2');
			}
			return v1 + v2;
		}
		function infotext(NAME_TXT, SalesSupported, Disbursements, TotalAuthorizations,TotalExporters)
		{
			var txt = '<table class="infoWin">' + 
				'<tr><td colspan="2"><strong>' + NAME_TXT + '</strong></td>' + 
				'<tr><td>Export Sales Supported:</td><td align="right">$' + addCommas(Math.round(SalesSupported)) + '</td></tr>' +
				'<tr><td>Disbursements:</td><td align="right">$' + addCommas(Math.round(Disbursements)) + '</td></tr>' +
				'<tr><td>Total Authorizations:</td><td align="right">$' + addCommas(Math.round(TotalAuthorizations)) + '</td></tr>' +
				'<tr><td><strong>Total Exporters:</strong></td><td align="right"><strong>' + addCommas(Math.round(TotalExporters)) + '</strong></td></tr>' +
				'</table>';
			return txt;	
		} 
		function constructNewCoordinates(polygon) {
			try
			{
				var newCoordinates = [];
				var coordinates = polygon['coordinates'][0];
				for (var i in coordinates) {
					if(coordinates[i][1]!=undefined)
					newCoordinates.push(
					new google.maps.LatLng(coordinates[i][1], coordinates[i][0]));
				}
			} catch(err){}
			return newCoordinates;
		}  
		<cfoutput>
		function GoToState(sel){
			if(sel.value != 'XX'){
				if(sel.value == 'US')
				{
					parent.location = '#application.maps.url#us_map.cfm';
				} else {
					parent.location = '#application.maps.url#state_map.cfm?state=' + sel.value;
				}
				
			}
		}
		</cfoutput>
    </script>
  </head>
<body>	


<div id="smlMapWrapper" class="podblue textflag clearfix">
  
    <div id="googleMapFlagWrapper">
        <div class="flag">
            <div class="shade clearfix">Discover How EXIM Bank Supports Over One Billion in Export Sales</div>
        </div>
        <div class="tri"></div>
        <div class="flagshade"></div>
    </div>
  
    <div class="smlGoogleMapWrapper">
        <h3>EXIM Supported Export Activity <cfoutput>#yrMin# - #yrMax#</cfoutput> <a target="_parent" href="<cfoutput>#application.maps.url#</cfoutput>us_map_text.cfm" title="Opens a Table with the data dislayed on the map">[ View as text ]</a> </h3>
        <div id="mapsGoHere" style="overflow:hidden; height:300px;">
        	<div id="map_canvas" style="background-image:url(ui/images/map_load.gif)"></div>
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
        	<p>Hover map for more information. Click state to see detailed state view, or choose state from dropdown. &rarr;</p>
        </div>
        <div><a href="/customcf/congressionalmap/us_map.cfm" target="_parent" style="color: ##0099CC;">Click here to view entire United States</a></div>
    </div>
  
    <div class="smlMapDataWrapper">
		<cfoutput>
        <ul>
            <li><strong><span class="smlMapNumber">#NumberFormat(strExporters.EXPORTER_COUNT,',')# -&nbsp;</span>Total Exporters</strong></li>
            <li><span class="smlMapNumber">#NumberFormat(strExporters.COUNT_SB,',')# -&nbsp;</span>Small Business</li>
            <li><span class="smlMapNumber">#NumberFormat(strExporters.COUNT_MO,',')# -&nbsp;</span>Minority Owned</li>
            <li><span class="smlMapNumber">#NumberFormat(strExporters.COUNT_WO,',')# -&nbsp;</span>Women Owned</li>
            <li><span class="smlMapNumber">#NumberFormat(strExporters.COUNT_RE,',')# -&nbsp;<br/><br/></span><div style="display:inline-block;width:60px;">Renewable Energy</div></li>
            <li><span class="smlMapNumber">#NumberFormat(strExporters.COUNT_ENV,',')# -&nbsp;<br/><br/></span><div style="display:inline-block;width:60px;">Environmentally Beneficial</div></li>
        </ul>    
        <h3>US Export Summary</h3>
        <ul class="exportSummary">
            <li><span class="smlMapNumber"><strong><span id="dSalesSupported">#application.oMap.DollarAbbr(strExporters.SalesSupported)#</span></strong></span> - Sales Supported</li>
            <li><span class="smlMapNumber"><span id="dDisbursements">#application.oMap.DollarAbbr(strExporters.Disbursements)#</span></span> - Disbursements</li>
            <li><span class="smlMapNumber"><span id="dTotalAuthorizations">#application.oMap.DollarAbbr(strExporters.TotalAuthorizations)#</span></span> - Total Authorizations</li>
        </ul>    
        <h3>Top 3 Export Destinations</h3>
        <p>#strExporters.topDestList#</p>
        <form method="post" class="smlMapForm" id="frmSelState" target="_parent">
            <label for="state"><strong>Choose State:</strong></label>
            <select name="state" class="smlMapSelect" onChange="GoToState(this);">
                <option value="XX" selected>Select State or Territory</option>
                <option value="US">All States</option>  
                <cfloop query="qStates">
                    <option value="#qStates.ABBREVIATION_TXT#">#qStates.NAME_TXT#</option>        
                </cfloop>
            </select>
            <a class="smlInstructions" href="#application.maps.url#us_terr_map.cfm">View Alaska, Hawaii, and US Territories</a>
        </form>    
		</cfoutput>
	</div>
</div>
</body>
</html>
    
	<cfcatch type="any"> 
		<cfdump var="#cfcatch.message#"/>
	</cfcatch>
</cftry>
