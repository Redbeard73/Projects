<cfset application.oExp = CreateObject("component","cfc.exporters")>

<cftry>

<cfif not isDefined('application.maps.arrTerr')>
	<cfset url.refreshCongMapTerritory = 1>
    <cfinclude template="init.cfm">
</cfif>

<cfscript>
	yrMin = application.maps.yrMin;
	yrMax = application.maps.yrMax;
	qStates = application.maps.qStates;
	lsTerr = application.maps.lsTerr;
	arrTerr = application.maps.arrTerr;
	strExporters = application.maps.strExportersTerr;

	strExporters = application.maps.strExportersTerr;
	qExpChart = strExporters.percData;
	
</cfscript>

<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <title>Non-contiguous States and Territories Export Data : Export-Import Bank of the United States</title>
        <meta name="description" content="">
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
		<cfloop index="t" list="#lsTerr#">
		#map_canvas<cfoutput>#t#</cfoutput> { height: 100px; width: 100px; }
		#map_canvas<cfoutput>#t#</cfoutput> > div > div.gmnoprint {
			top: 4000px!important;
		}
		#map_canvas<cfoutput>#t#</cfoutput> > div > a[target] > div > img[draggable]{
			visibility: hidden!important;
			background-color:red!important;
		}
		#terms-o-use {font-family:verdana, sans-serif;font-size:11px;white-space: nowrap;text-align:right;}
		</cfloop>
    </style>
    <!-- load jQuery -->
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.min.js"></script>
    <script type="text/javascript">window.jQuery || document.write('<script src="/ui/js/libs/jquery-1.7.1.min.js"><\/script>')  </script>	
    <script type="text/javascript">var j$ = jQuery.noConflict();</script>
    <script type="text/javascript">window.jQuery || document.write('<script src="/ui/js/libs/jquery-1.7.1.min.js"><\/script>')  </script>
    <script type="text/javascript" src="ui/js/jquery.dataTables.js"></script>
    <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?client=gme-exportimportbank&sensor=false"></script>
    <script type="text/javascript" src="ui/js/MapStyles.js"></script>
    <script type="text/javascript">
	<cfoutput>
	
		<cfloop index="t" list="#lsTerr#">
			var map#t#;
			var polygonArray#t# = new Array();
			var layerThemed#t#;
		</cfloop>
		
        <cfloop index="i" from="1" to="#arrayLen(arrTerr)#">
			<cfset t = arrTerr[i].ABBREVIATION_TXT>
			function initialize#t#() {		
				var mapOptions#t# = {
					center: new google.maps.LatLng(#arrTerr[i].LATITUDE_CENTER_NBR#,#arrTerr[i].LONGITUDE_CENTER_NBR#),
					zoom: #arrTerr[i].TerrZoomLevel#,
					disableDefaultUI: true,	
					zoomControl: false,
					mapTypeId: google.maps.MapTypeId.ROADMAP
				};
				var styledMap#t# = new google.maps.StyledMapType(stylesInner, {name: "Styled Map #t#"});					
				map#t# = new google.maps.Map(document.getElementById("map_canvas#t#"),mapOptions#t#);
				map#t#.mapTypes.set('map_style', styledMap#t#);
				map#t#.setMapTypeId('map_style');
	
				layerThemed#t# = new google.maps.FusionTablesLayer({
					query: {
						select: 'geometry',
						from: '<cfoutput>#application.maps.fusStateExporterDataInitPoly#</cfoutput>',
						where: "ABBREVIATION_TXT CONTAINS IGNORING CASE '<cfoutput>#t#</cfoutput>'"
					},
					options: { suppressInfoWindows: true },
					map: map#t#,
					styles: mStyleThemed
				});
				
				redraw#t#(#application.maps.yrMin#,#application.maps.yrMax#,'#t#');
			};
			google.maps.event.addDomListener(window, 'load', initialize#t#);
			
			function redraw#t#(yS,yE)
			{
				var qry = "SELECT";		
					qry += " geometry";	
					qry += " , SUM(WO_SUPPORTED) as WO";
					qry += " , SUM(MO_SUPPORTED) as MO";
					qry += " , SUM(EB_SUPPORTED) as EB";
					qry += " , SUM(RE_SUPPORTED) as RE";
					qry += " , SUM(SB_SUPPORTED) as SB";
					qry += " , NAME_TXT";
					
					qry += " , SUM(SalesSupported) as SalesSupported";
					qry += " , SUM(Disbursements) as Disbursements";
					qry += " , SUM(Authorizations) as Authorizations";
					qry += " , SUM(TotalAuthorizations) as TotalAuthorizations";
					qry += " , SUM(EXPORTER_COUNT) as EXPORTER_COUNT";
					
					qry += " FROM <cfoutput>#application.maps.fusUSMap#</cfoutput>";
					qry += " WHERE DT_YR_FSCL >= " + yS + " AND DT_YR_FSCL <= " + yE + " AND ABBREVIATION_TXT = '#t#' GROUP BY geometry, NAME_TXT";
				

				for (i=0;i<polygonArray#t#.length;i++) polygonArray#t#[i].setMap(null);
				
				var script = document.createElement('script');
				var url = ['https://www.googleapis.com/fusiontables/v1/query?'];
				url.push('sql=');
				var encodedQuery = encodeURIComponent(qry);
				url.push(encodedQuery);
				url.push('&callback=drawMap#t#');
				url.push('&key=<cfoutput>#application.maps.apiKey#</cfoutput>');
				script.src = url.join('');
				var body = document.getElementsByTagName('body')[0];
				body.appendChild(script);
				
			}
			
			function drawMap#t#(data) {
				var rows = data['rows'];
				for (var i in rows) {
					var ABBREVIATION_TXT = '#t#';
					
					var WO_SUPPORTED = (document.getElementById('chkWO').checked)?Math.round(parseFloat(rows[i][1])):0;
					var MO_SUPPORTED = (document.getElementById('chkMO').checked)?Math.round(parseFloat(rows[i][2])):0;
					var EB_SUPPORTED = (document.getElementById('chkEB').checked)?Math.round(parseFloat(rows[i][3])):0;
					var RE_SUPPORTED = (document.getElementById('chkRE').checked)?Math.round(parseFloat(rows[i][4])):0;
					var SB_SUPPORTED = (document.getElementById('chkSB').checked)?Math.round(parseFloat(rows[i][5])):0;
					
					var NAME_TXT = rows[i][6];
					
					var SalesSupported = rows[i][7];
					var Disbursements = rows[i][8];
					var Authorizations = rows[i][9];
					var TotalAuthorizations = rows[i][10];
					var EXPORTER_COUNT = rows[i][11];
					
					var AMT_SUPPORTED = Math.round(WO_SUPPORTED + MO_SUPPORTED + EB_SUPPORTED + RE_SUPPORTED + SB_SUPPORTED);
				
					var newCoordinates = [];
					var geometries = rows[i][0]['geometries'];
					if (geometries) {
						for (var j in geometries) {
							newCoordinates.push(constructNewCoordinates(geometries[j]));
						}
					} else {
						newCoordinates = constructNewCoordinates(rows[i][0]['geometry']);
					}

					var fillColor = '##537090';
					var fillOpacity = .50;
					if(AMT_SUPPORTED < 75000000) fillColor = '##6896b0';
					if(AMT_SUPPORTED < 50000000) fillColor = '##a8becb';
					if(AMT_SUPPORTED < 25000000) fillColor = '##e8e6e7';
					if(AMT_SUPPORTED < 10) fillOpacity = 0;
					
					polygonArray#t#[i] = new google.maps.Polygon({
						paths: newCoordinates,
						strokeColor: "##000000",
						strokeOpacity: 0,
						strokeWeight: 1,
						fillColor: fillColor,
						fillOpacity: fillOpacity
					});
					addlisteners(map#t#,polygonArray#t#[i],ABBREVIATION_TXT)	
					polygonArray#t#[i].setMap(map#t#);
				}
			}
			
		</cfloop>
		
		
		
	</cfoutput>
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
		function addlisteners(map,polygon,state_abbr,infoTxt)
		{	
			google.maps.event.addListener(polygon, 'mouseover', function(e) {
				this.setOptions({strokeOpacity: 1});
				
			});
			google.maps.event.addListener(polygon, 'mouseout', function() {
				this.setOptions({strokeOpacity: 0});
			});	
			google.maps.event.addListener(polygon, 'click', function() {
				<cfoutput>window.location='#application.maps.url#state_map.cfm?state=' + state_abbr;</cfoutput>
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
       <div class="addthis_toolbox addthis_default_style">
         <a g:plusone:annotation="none" g:plusone:size="small" class="addthis_button_google_plusone"></a> <a class="addthis_button_facebook"></a>
         <a class="addthis_button_print" id="sharePrint"></a> <a class="addthis_button_email"
           id="shareEmail"></a>
       </div>
     </div>

  <div class="skip"><a href="usa-homepage-text-equivelent.html" title="Opens a Table with the data dislayed on the map">View as Text</a></div> 
  
   
   
  <!-- start googlemap flag wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- start googlemap flag wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmm -->

  <div id="googleMapFlagWrapper">
    <div class="flag">
      <div class="shade clearfix"><span class="bg-node"><a href="us_map.cfm">Export Data - USA</a></span><span class="bg-node"><a href="us_terr_map.cfm">Non-contiguous States and Territories</a></span> </div>
    </div>
    <div class="tri"></div>
  </div><!--#googleMapFlagWrapper-->
  
  <!-- end googlemap flag wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- end googlemap flag wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmm -->









  <!-- start data wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- start data wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm -->

  <div class="lrgMapDataWrapper">

<cftry>
  
    <h2>EXPORTERS:</h2>
    
    <cfoutput>
    <div class="clearfix" >
      <div class="chartlegend">
        <ul>
          <li class="strong"><span class="smlMapNumber"><span id="dTE">#NumberFormat(strExporters.COUNT_ALL,',')#</span><span class="sq te"></span></span>Total Exporters</li>
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
    
      <h3 class="clear">Territory Export Summary:</h3>
      <ul>
        <li><span class="smlMapNumber"><strong><span id="dSalesSupported">#application.oMap.DollarAbbr(strExporters.SalesSupported)#</span></strong></span> - Sales Supported</li>
        <li><span class="smlMapNumber"><span id="dDisbursements">#application.oMap.DollarAbbr(strExporters.Disbursements)#</span></span> - Disbursements</li>
        <li><span class="smlMapNumber"><span id="dTotalAuthorizations">#application.oMap.DollarAbbr(strExporters.TotalAuthorizations)#</span></span> - Total Authorizations</li>
      </ul>
      
      <h3>Top 3 Export Destinations:</h3>
      <p><span id="dTopDest">#strExporters.topDestList#</span></p>
      
      

      <h3>Top Exporters:</h3>
        <ol>
          <li id="dTopExp1">#strExporters.topExportersArr[1]#</li>
          <li id="dTopExp2">#strExporters.topExportersArr[2]#</li>
          <li id="dTopExp3">#strExporters.topExportersArr[3]#</li>
        </ol>
    </div>
    </cfoutput>
    
    <cfcatch>
<!---    	<cfhttp url="admin/recache.cfm?state=#url.state#&district=#url.district#" resolveurl="no"></cfhttp>
        <cflocation url="state_map.cfm?district=#url.state#&district=#url.district#" addtoken="no">--->
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
        <ul class="map">
        	<cfloop index="i" from="1" to="#arrayLen(arrTerr)#">
          		<cfoutput><li><div id="map_canvas#arrTerr[i].ABBREVIATION_TXT#"></div><a href="state_map.cfm?state=#arrTerr[i].ABBREVIATION_TXT#" style="color:##036; font-weight:bold; font-size:11px;">#arrTerr[i].NAME_TXT#</a></li></cfoutput>
            </cfloop>
        </ul>
      </div><!--mapsGoHere-->
      
      
      <div class="lrgInstructions">
        <p>Hover map for more information. Click state to see detailed state view or choose state from dropdown. &rarr;</p>
      </div>
    </div><!--mapOutline-->
	<div class="lrgDislaimer">
		<p>Note:  Exporters can belong to more than one category.</p>
	</div>
    <div id="terms-o-use">
        <span>Map data &copy;<cfoutput>#year(now())#</cfoutput>  Google - </span><a class="gmnoprint terms-of-use-link" target="_blank" href="http://www.google.com/intl/en_us/help/terms_maps.html" style="color:#036;">Terms of Use</a>
    </div>
    
    
    <form class="mapToggleForm" action="post">
      <fieldset>
        <input type='checkbox' name='chkShowExportLayer' class="styled" value='valuable' id="chkShowExportLayer"  checked="checked"/><label for="chkShowExportLayer" tabindex="0">Export Dollars by State</label>
        <ul class="noListStyle">
          <li><span class="sq exportColor1"></span>$1 Billion + </li>
          <li><span class="sq exportColor2"></span>$500M to $999M</li>
          <li><span class="sq exportColor3"></span>$100M to $499M</li>
          <li><span class="sq exportColor4"></span>&lt; $99M</li>
        </ul>
      </fieldset>
    </form>
    
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
          	<cfoutput>
              <div class="range1wrapper">
                <input type="input" id="range1" name="range1" min="#application.maps.yrMin#" max="#application.maps.yrMax#" value="#application.maps.yrMin#" step="1" />
              </div>
              <div class="range2wrapper">
                <input type="input" id="range2" name="range2" min="#application.maps.yrMin#" max="#application.maps.yrMax#" value="#application.maps.yrMax#" step="1" />
              </div>
             </cfoutput>
          </div><!--rangeWrapper -->
        
        
        
        <fieldset class="checkboxFilters">
        
          <h4>Exporter Type:</h4>
          <input type='checkbox' name='chkSB' class="styled" value='valuable' checked="checked" id="chkSB" /><label for="chkSB" tabindex="0">Small Business</label>
          <input type='checkbox' name='chkMO' class="styled" value='valuable' checked="checked" id="chkMO" /><label for="chkMO" tabindex="0">Minority Owned</label>
          <input type='checkbox' name='chkWO' class="styled" value='valuable' checked="checked" id="chkWO" /><label for="chkWO" tabindex="0">Women Owned</label>
          <input type='checkbox' name='chkRE' class="styled" value='valuable' checked="checked" id="chkRE" /><label for="chkRE" tabindex="0">Renewable Energy</label>
          <input type='checkbox' name='chkEB' class="styled" value='valuable' checked="checked" id="chkEB" /><label  for="chkEB" tabindex="0">Environmentally <span style="display:block;margin-top:-20px;">Beneficial</span></label>
        
        </fieldset>
        
        <br/>

        <fieldset>
        
        <h4>Choose State:</h4>
        <label for="stateSelect" class="screenReadersOnly">Choose State:</label>
        <select name="stateSelect" id="stateSelect" class="smlMapSelect">
            <option value="XX">Select State</option>
        	<cfloop index="i" from="1" to="#arrayLen(arrTerr)#">
                <cfoutput><option value="#arrTerr[i].ABBREVIATION_TXT#">#arrTerr[i].NAME_TXT#</option></cfoutput>
            </cfloop>
        </select>
        <a class="smlInstructions" style="color:#666" href="#">View contiguous US states</a>
        </fieldset>
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
        <div class="showText">Show Detailed Data</div>
      </a>
    </div><!--datatablebanner -->
    
    <div id="dataTable">

        <table class="data addsorting" id="ExpDataTable">
            <caption class="screenReadersOnly">EXIM Supported Export Activity</caption>
            <thead>
                  <tr>
                    <!---<th class="header">ABBREVIATION_TXT</th>--->
                    <th class="header">State</th>
                    <th class="header">Total Exporters</th>
                    <th class="header">Small Business</th>
                    <th class="header">Minority Owned</th>
                    <th class="header">Women Owned</th>
                    <th class="header">Environmentally Beneficial</th>
                    <th class="header">Renewable Energy</th>
                  </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
        
    </div><!--dataTable-->
  
  
  </div><!--dataTableWrapper-->
        
  <!-- end table wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- end table wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  
  

  
</div><!-- #lrgMapWrapper -->


<!-- load jQuery -->
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.min.js"></script>
<script type="text/javascript">window.jQuery || document.write('<script src="/ui/js/libs/jquery-1.7.1.min.js"><\/script>')  </script>	
<script type="text/javascript">var j$ = jQuery.noConflict();</script>
<script type="text/javascript" src="ui/js/jquery.dataTables.js"></script>

<!-- naturally deffered JS -->
<script type="text/javascript" src="ui/js/jquery.plugins.js"></script>
<script type="text/javascript" src="ui/js/common.js"></script>

<script>
	function GetStateAbbrByName(st)
	{
		var stRet = '';
		<cfoutput query="application.maps.qStates">
			if(st == '#qStates.NAME_TXT#') stRet = '#qStates.ABBREVIATION_TXT#';
		</cfoutput>		
		return stRet;
	}
	j$(document).ready(function () {	
		var yStart = j$('#range1').val();
		var yEnd = j$('#range2').val();	

		j$("#chkShowExportLayer").bind('propertychange change', function(e) {
			<cfloop index="t" list="#lsTerr#">
			<cfoutput>
				for (var p in polygonArray#t#) {
					if (this.checked) polygonArray#t#[p].setMap(map#t#); else polygonArray#t#[p].setMap(null);
				}
			</cfoutput>
			</cfloop>
		});
		
		j$('#range1').change(function(){
			if(j$('#range1').val() > j$('#range2').val()) j$('#range2').val(j$('#range1').val());
			Loading();
			<cfloop index="t" list="#lsTerr#">
				<cfoutput>redraw#t#(j$('##range1').val(),j$('##range2').val());</cfoutput>
			</cfloop>
			LoadExpData(j$('#range1').val(),j$('#range2').val());
			DrawChart(j$('#range1').val(),j$('#range2').val());
			LoadTerrExpDataTable(j$('#range1').val(),j$('#range2').val());
		});
		j$('#range2').change(function(){
			if(j$('#range2').val() < j$('#range1').val()) j$('#range1').val(j$('#range2').val());
			Loading();
			<cfloop index="t" list="#lsTerr#">
				<cfoutput>redraw#t#(j$('##range1').val(),j$('##range2').val());</cfoutput>
			</cfloop>
			LoadExpData(j$('#range1').val(),j$('#range2').val());
			DrawChart(j$('#range1').val(),j$('#range2').val());
			LoadTerrExpDataTable(j$('#range1').val(),j$('#range2').val());
		});
		j$('#chkWO').change(function(){
			<cfloop index="t" list="#lsTerr#">
				<cfoutput>redraw#t#(j$('##range1').val(),j$('##range2').val());</cfoutput>
			</cfloop>
		});
		
		j$('#chkMO').change(function(){
			<cfloop index="t" list="#lsTerr#">
				<cfoutput>redraw#t#(j$('##range1').val(),j$('##range2').val());</cfoutput>
			</cfloop>
		});
		
		j$('#chkEB').change(function(){
			<cfloop index="t" list="#lsTerr#">
				<cfoutput>redraw#t#(j$('##range1').val(),j$('##range2').val());</cfoutput>
			</cfloop>
		});
		
		j$('#chkRE').change(function(){
			<cfloop index="t" list="#lsTerr#">
				<cfoutput>redraw#t#(j$('##range1').val(),j$('##range2').val());</cfoutput>
			</cfloop>
		});
		
		j$('#chkSB').change(function(){
			<cfloop index="t" list="#lsTerr#">
				<cfoutput>redraw#t#(j$('##range1').val(),j$('##range2').val());</cfoutput>
			</cfloop>
		});
		function Loading(){
			j$('#chart').html('<div id="te" class="te" style="width:100px; height:100px;"></div>');
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
				url: "cfc/congmap.cfc",
				type: "get",
				dataType: "json",
				data: {
					method: "GetExpCountsJSON"
						, State_List: "<cfoutput>#application.maps.lsTerr#</cfoutput>"
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
				url: "cfc/congmap.cfc",
				type: "get",
				dataType: "json",
				data: {
					method: "GetExpChartJSON"
						, State_List: "<cfoutput>#application.maps.lsTerr#</cfoutput>"
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
		
		
		function LoadTerrExpDataTable(yS,yE)
		{
			var oTable = j$('#ExpDataTable').dataTable({
				"bProcessing": true,
				"sAjaxSource": 'cfc/expJSON.cfc?method=GetUSDataTable&isTerr=1&yStart=' + yS + '&yEnd=' + yE,
				"aoColumns": [
					{ "mDataProp": "NAME_TXT" , "sTitle": "State"},
					{ "mDataProp": "EXPORTER_COUNT_TE" , "sTitle": "Total Exporters"},
					{ "mDataProp": "EXPORTER_COUNT_SB" , "sTitle": "Small Business"},
					{ "mDataProp": "EXPORTER_COUNT_MO" , "sTitle": "Minority Owned"},
					{ "mDataProp": "EXPORTER_COUNT_WO" , "sTitle": "Women Owned"},
					{ "mDataProp": "EXPORTER_COUNT_ENV" , "sTitle": "Environmentally Beneficial"},
					{ "mDataProp": "EXPORTER_COUNT_RE" , "sTitle": "Renewable Energy"},
					{ "mDataProp": "ABBREVIATION_TXT" , "sTitle": "State Abbr", "bVisible": false }
				],
				"bPaginate": false,
				"bFilter": true,
				"bAutoWidth": false,
				"bDestroy": true,
				"fnInitComplete": function (){
					j$(oTable.fnGetNodes()).click(function (){		
						var aPos = oTable.fnGetPosition(this);
						window.location='state_map.cfm?state=' + oTable.fnGetData(aPos,7);
					});
				}
			});
		}
		
		j$(window).load(function () {
			LoadTerrExpDataTable(j$('#range1').val(),j$('#range2').val());
			j$("#dataTable").show();
			
			j$("#chkWO").bind('propertychange click', function(e) {
			//j$('#chkWO').change(function(){
				<cfloop index="t" list="#lsTerr#">
					<cfoutput>redraw#t#(j$('##range1').val(),j$('##range2').val());</cfoutput>
				</cfloop>
			});
			
			j$("#chkMO").bind('propertychange click', function(e) {
			//j$('#chkMO').change(function(){
				<cfloop index="t" list="#lsTerr#">
					<cfoutput>redraw#t#(j$('##range1').val(),j$('##range2').val());</cfoutput>
				</cfloop>
			});
			
			j$("#chkEB").bind('propertychange click', function(e) {
			//j$('#chkEB').change(function(){
				<cfloop index="t" list="#lsTerr#">
					<cfoutput>redraw#t#(j$('##range1').val(),j$('##range2').val());</cfoutput>
				</cfloop>
			});
			
			j$("#chkRE").bind('propertychange click', function(e) {
			//j$('#chkRE').change(function(){
				<cfloop index="t" list="#lsTerr#">
					<cfoutput>redraw#t#(j$('##range1').val(),j$('##range2').val());</cfoutput>
				</cfloop>
			});
			
			j$("#chkSB").bind('propertychange click', function(e) {
			//j$('#chkSB').change(function(){
				<cfloop index="t" list="#lsTerr#">
					<cfoutput>redraw#t#(j$('##range1').val(),j$('##range2').val());</cfoutput>
				</cfloop>
			});
		});
	
	});
		
	

</script>
<!-- init the AddThis code --> 
<script type="text/javascript">var addthis_config = {ui_508_compliant: true};</script>
<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=xa-4f916fc74c194553"></script> 

</body>
    
	<cfcatch type="any"> 
		<cfdump var="#cfcatch.message#"/>
	</cfcatch>
</cftry>
