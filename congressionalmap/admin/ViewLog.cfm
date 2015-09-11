<cfsetting showdebugoutput="yes" requesttimeout="6000">
<cfscript>
	logFileName = 'CongressionalMap';
	logsFile = Server.ColdFusion.RootDir & '/logs/#logFileName#.log';
</cfscript>	

<cftry>

<cfoutput>
<h2>#logsFile#</h2>
<pre>
<cfscript>
myfile = FileRead(logsFile);
WriteOutput("#myfile#");
</cfscript>
</pre>
</cfoutput>
	<cfcatch>Log Not Intitialized</cfcatch>
</cftry>
