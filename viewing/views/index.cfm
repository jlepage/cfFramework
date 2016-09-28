<h2>Welcome to cfFramework !</h2>

<cfoutput>
	<cfif !isDefined('id')>
		<a href="#getURL('testURL', {'id' = 1, 'revision' = 2})#">Click to test URL</a><br/>
	<cfelse>
		ID: #id#<br/>
		Revision: #revision#<br/>
	</cfif>
	<br/>
	Context: #getContext()#<br/>
	<br/>
	#getVersion()# - #getCopyRights()#
</cfoutput>