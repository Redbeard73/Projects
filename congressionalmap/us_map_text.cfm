<cftry>
<cfscript>
	strExporters = application.maps.strExportersUS;
</cfscript>
<!DOCTYPE HTML>
<html lang="en" xmlns:fb="http://ogp.me/ns/fb#" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
<head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <title>U.S. Export Data : Export-Import Bank of the United States</title>
        <meta name="description" content="Ex-Im Bank is focused on helping small businesses's and has a dedicated team to assist them.  See how many businesses have been helped all across the USA.">
        <meta name="viewport" content="width=device-width, maximum-scale=1">
		<meta name="apple-mobile-web-app-capable" content="yes"/>
        <link rel="stylesheet" href="ui/css/main.css">
        <script type="text/javascript">
          // check if touch device supported
          var is_touch_device = 'ontouchstart' in document.documentElement || 'onmsgesturechange' in window;
          //if(is_touch_device) alert("touch is enabled!");
          if (!is_touch_device) {
            window.onload = function (){
              document.getElementsByTagName('body')[0].className+=' no-touch';
            }
          }
        </script>
        <style>
			a{color:#00F;}
		</style>
        <!--[if IE 8]>
        <script type="text/javascript" src="ui/js/ie8-polyfills.js"></script>
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
      <li><a href="/about/">About Us</a></li>
      <li><a href="/newsandevents/">News & Events</a></li>
      <li><a href="/products/">Products</a></li>
      <li><a href="/tools/">Tools</a></li>
      <li><a href="/smallbusiness/">Small Business</a></li>
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

  <div id="googleMapFlagWrapper">
    <div class="flag">
      <div class="shade clearfix"><span class="bg-node"><a href="##">Discover How EXIM Bank Supports Over One Billion in Export Sales</a></span> </div>
     </div>
    <div class="tri"></div>
  </div>
  
  <div id="dataTableWrapper" style="font-size:14px;">
    	<table>
  			<cfoutput>
                <tr><td colspan="2"><strong>US Export Summary</strong></td></tr>
                <tr style="background-color:##CCC;"><td style="padding-left:5px;">Total Exporters</td><td align="right">#NumberFormat(strExporters.EXPORTER_COUNT,',')#</td></tr>
                <tr><td style="padding-left:5px;">Small Business</td><td align="right">#NumberFormat(strExporters.COUNT_SB,',')#</td></tr>
                <tr style="background-color:##CCC;"><td style="padding-left:5px;">Minority Owned</td><td align="right">#NumberFormat(strExporters.COUNT_MO,',')#</td></tr>
                <tr><td style="padding-left:5px;">Women Owned</td><td align="right">#NumberFormat(strExporters.COUNT_WO,',')#</td></tr>
                <tr style="background-color:##CCC;"><td style="padding-left:5px;">Renewable Energy</td><td align="right">#NumberFormat(strExporters.COUNT_RE,',')#</td></tr>
                <tr><td style="padding-left:5px;">Environmentally Beneficial</td><td align="right">#NumberFormat(strExporters.COUNT_ENV,',')#</td></tr>
                <tr><td colspan="2"><strong>US Export Summary</strong></td></tr>
                <tr style="background-color:##CCC;"><td style="padding-left:5px;">Sales Supported</td><td align="right">#application.oMap.DollarAbbr(strExporters.SalesSupported)#</td></tr>
                <tr><td style="padding-left:5px;">Disbursements</td><td align="right">#application.oMap.DollarAbbr(strExporters.Disbursements)#</td></tr>
                <tr style="background-color:##CCC;"><td style="padding-left:5px;">Total Authorizations</td><td align="right">#application.oMap.DollarAbbr(strExporters.TotalAuthorizations)#</td></tr>
                <tr><td colspan="2"><strong>Top 3 Export Destinations</strong></td></tr>
                <tr style="background-color:##CCC;"><td colspan="2" style="padding-left:5px;">#strExporters.topDestList#</td></tr>
                <tr><td colspan="2"><br><strong>EXIM Supported Export Activity <cfoutput>#application.maps.yrMin# - #application.maps.yrMax#</strong></cfoutput></td>
  			</cfoutput>
            	<tr>
                	<td colspan="2">
                    	<table>
                            <tr>
                                <td><strong>State</strong></td>
                                <td align="right"><strong>Export Sales Supported</strong></td>
                                <td align="right"><strong>Disbursements</strong></td>
                                <td align="right"><strong>Total Authorizations</strong></td>
                                <td align="right"><strong>Total Exporters</strong></td>
                            </tr>
                            <cfscript>
								_SalesSupported = 0;
								_Disbursements = 0;
								_TotalAuthorizations = 0;
								_EXPORTER_COUNT = 0;
							</cfscript>
                            
                            <cfoutput query="application.maps.qStates">
                            	<cfset stData = evaluate('application.maps.strExporters#ABBREVIATION_TXT#')>
                                <tr <cfif currentrow mod 2> style="background-color:##CCC;"</cfif>>
                            		<td><a href="#application.maps.url#state_map.cfm?state=#ABBREVIATION_TXT#">#NAME_TXT#</a></td>
                                    
                                    <cfif !IsNumeric(stData.SalesSupported)><cfset stData.SalesSupported = 0></cfif>
                                    <cfif !IsNumeric(stData.Disbursements)><cfset stData.Disbursements = 0></cfif>
                                    <cfif !IsNumeric(stData.TotalAuthorizations)><cfset stData.TotalAuthorizations = 0></cfif>
                                    <cfif !IsNumeric(stData.EXPORTER_COUNT)><cfset stData.EXPORTER_COUNT = 0></cfif>
                                    
                                    <td align="right">$#NumberFormat(Round(stData.SalesSupported),',')#</td>
                                    <td align="right">$#NumberFormat(Round(stData.Disbursements),',')#</td>
                                    <td align="right">$#NumberFormat(Round(stData.TotalAuthorizations),',')#</td>
                                    <td align="right">#NumberFormat(Round(stData.EXPORTER_COUNT),',')#</td>
                            
                                </tr>
								<cfscript>
                                    _SalesSupported = _SalesSupported + Round(stData.SalesSupported);
                                    _Disbursements = _Disbursements + Round(stData.Disbursements);
                                    _TotalAuthorizations = _TotalAuthorizations + Round(stData.TotalAuthorizations);
                                    _EXPORTER_COUNT = _EXPORTER_COUNT + Round(stData.EXPORTER_COUNT);
                                </cfscript>
                            </cfoutput>
                            
                            
                            <cfoutput>
                                <tr <cfif (application.maps.qStates.recordcount+1) mod 2> style="background-color:##CCC;"</cfif>>
                                    <td><a href="#application.maps.url#us_map.cfm">All United States</a></td>
                                    <td align="right">$#NumberFormat(_SalesSupported,',')#</td>
                                    <td align="right">$#NumberFormat(_Disbursements,',')#</td>
                                    <td align="right">$#NumberFormat(_TotalAuthorizations,',')#</td>
                                    <td align="right">#NumberFormat(_EXPORTER_COUNT,',')#</td>
                                </tr>
                            </cfoutput>                
                        </table>
					</td>
				</tr>
			
        </table>
     <a href="<cfoutput>#application.maps.url#</cfoutput>us_terr_map.cfm">View Alaska, Hawaii, and US Territories</a>
  </div><!--dataTableWrapper-->
        
  <!-- end table wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  <!-- end table wrapper mmmmmmmmmmmmmmmmmmmmmmmmmmmm -->
  
  

  
</div><!-- #lrgMapWrapper -->


<!-- load jQuery -->
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.min.js"></script>
<script type="text/javascript">window.jQuery || document.write('<script src="/ui/js/libs/jquery-1.7.1.min.js"><\/script>')  </script>	
<script type="text/javascript">var j$ = jQuery.noConflict();</script>

<!-- naturally deffered JS -->
<script type="text/javascript" src="ui/js/jquery.plugins.js"></script>
<script type="text/javascript" src="ui/js/common.js"></script>

<!-- init the AddThis code --> 
<script type="text/javascript">var addthis_config = {ui_508_compliant: true};</script>
<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=xa-4f916fc74c194553"></script> 

</body>
    
	<cfcatch type="any"> 
		<cfdump var="#cfcatch.message#"/>
	</cfcatch>
</cftry>