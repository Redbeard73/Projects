<!---------
	Author:	Theonic Way, Fig Leaf Software
	Date Created: January 02, 2013 
	Purpose:	
		1) Initialize memory structures for legislators by reading the information from an external XML file that holds the governor information.
		2) Display the Senators, Representatives, and Governor for each state.  	
----------->

<cfparam name="URL.state" default="">
<cfparam name="URL.district" default="">

<cfif Len(Trim(URL.state)) AND Len(Trim(URL.district))>
	<cfset Variables.district_name = Trim(URL.state) & "-" & Trim(URL.district)>
<cfelse>
	<cfset Variables.district_name = ""/>	 
</cfif>


<!--- Set the Request Scope Variables for the current server. ------->
<cfscript>
	Request.basehref = "/customcf/congressionalmap/";
	Request.baseurl = "http://dev.exim.gov/";
	Request.ui_path = Request.basehref & "ui/";
	Request.xml_path = Request.basehref & "xml/";
	Request.cfc_path = "customcf.congressionalmap.cfc.";
</cfscript>

<cfif !IsDefined("Application.Governor_CFC") || IsDefined("URL.recachelegislators")>
	 <cftry> 
		<cfscript>
			Application.Governor_CFC = CreateObject("component", "#Request.cfc_path#Governors");
			Application.Governor_CFC.init();
		</cfscript>
		<cfcatch type="any">
			<cfdump var=#cfcatch.message#>
		</cfcatch>	 		
	 </cftry>	 	
</cfif>

<cfif !IsDefined("Application.Legislators_CFC") || IsDefined("URL.recachelegislators")>
	 <cftry> 
		<cfscript>
			Application.Legislators_CFC = CreateObject("component", "#Request.cfc_path#Legislators");
			Application.Legislators_CFC.init();
		</cfscript>
		<cfcatch type="any">
			<cfdump var=#cfcatch.message#>
		</cfcatch>	 		
	 </cftry>	 	
</cfif>

<!---<cftry>
	<cfdump var=#Application.Governor_CFC.instance.governors_struct#/>
	<cfdump var=#Application.Legislators_CFC#/>
	<cfdump var=#Application.Legislators_CFC.instance.representatives_struct#/>
	<cfcatch type="any">
		<cfdump var=#cfcatch.message#/>
	</cfcatch> 
</cftry>		--->




<cfif StructKeyExists(Application.Governor_CFC.instance.governors_struct, URL.state)>

<cftry>	
			
	<cfscript>
		governor_struct = Application.Governor_CFC.instance.governors_struct["#URL.state#"];
		if ( StructKeyExists(Application.Legislators_CFC.instance.senators_struct, "#URL.state#"))
			senators_array = Application.Legislators_CFC.instance.senators_struct["#URL.state#"];
		else
			senators_array = ArrayNew(1);
		if ( StructKeyExists(Application.Legislators_CFC.instance.representatives_struct, "#URL.state#"))		
			members_struct = Application.Legislators_CFC.instance.representatives_struct["#URL.state#"].members_struct;
		else
			members_struct = StructNew();	
	</cfscript>

	<cfoutput>
		<div class="shade lawDown clearfix">
		         <ul class="noListStyle">
		            <li>
		              <a href="##">Legislators <div class="law-icon"></div></a>
		              <ul>
		              	
						<cfif IsDefined("senators_array") AND IsArray(senators_array)>
							<cfloop array="#senators_array#" index="iSenator">
				                <li>
				                  <a href="#iSenator.weburl#" target="_blank">
				                    <span class="lawInfo">Senator<br><strong>#iSenator.name#</strong><br>#iSenator.party#</span>
									<cfif Len(Trim(iSenator.imageurl)) EQ 0>
										<img height="50" src="#Request.ui_path#images/placeholder-anonymous.jpg" alt="#iSenator.state# Senator #iSenator.name#">
									<cfelse>	 
				                    	<img height="50" src="#iSenator.imageurl#" alt="#iSenator.state# Senator #iSenator.name#">
									</cfif>
				                  </a>
				                </li>
							</cfloop>	
						</cfif>							

						<!---<cfif IsDefined("URL.district") AND Len(Trim(URL.district)) EQ 2>--->
						<cfif Len(Trim(Variables.district_name)) 
								AND IsDefined("members_struct") 
								AND IsStruct(members_struct) 
								AND StructKeyExists(members_struct, "#Trim(Variables.district_name)#")>
								<cfset iRep = members_struct["#Trim(Variables.district_name)#"]/>							
				                <li>
				                  <a href="#iRep.weburl#" target="_blank">
				                    <span class="lawInfo">Representative<br><strong>#iRep.name#</strong><br>#iRep.party#</span>
									<cfif Len(Trim(iRep.imageurl)) EQ 0>
										<img height="50" src="#Request.ui_path#images/placeholder-anonymous.jpg" alt="#iRep.district_name# Representative #iRep.name#">
									<cfelse>	 
				                    	<img height="50" src="#iRep.imageurl#" alt="#iRep.district_name# Representative #iRep.name#">
									</cfif>
				                  </a>
				                </li>
						<cfelse>
								<!---<li>Representative missing</li>	--->
						</cfif>

						<cfif IsDefined("governor_struct") AND IsStruct(governor_struct)>
			                <li>
			                  <a target="_blank" href="#governor_struct.govweburl#">
			                    <span class="lawInfo">Governor<br><strong>#governor_struct.governor#</strong><br>#governor_struct.party#</span>
			                    <img height="50" src="#governor_struct.govimageurl#" alt="#governor_struct.name# Governor #governor_struct.governor#">
			                  </a>
			                </li>
						</cfif>							
		              </ul>
		            </li>
		        </ul> 
		</div>
	</cfoutput>			

	<cfcatch type="any"> 
		<cfdump var="#cfcatch.message#"/>
	</cfcatch>

</cftry>

	<cfif FindNoCase("show-legislators.cfm", CGI.SCRIPT_NAME)>
		<cfoutput>
			<h1>Current District Name: #Variables.district_name#;  District Number = #Trim(URL.district)#</h1>
			<cfdump var=#members_struct#/>
		</cfoutput>	
	</cfif>	

</cfif>

