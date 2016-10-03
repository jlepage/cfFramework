<h2>Welcome to cfFramework !</h2>

<cfoutput>
	<br/>
	<cfif !args.has('id')>
		For testing if an arguments is defined on view, you can test with :<br/>
		args.has('myVar'); <br/>
		<br/>
		Or old school like :<br/>
		structKeyExists(local, 'myVar'); <br/>
		<br/>
		Or if you want to be beated by your colleagues after work (not recommended) :<br/>
		isDefined('myVar');<br/>
		<br />

		<a href="#getURL('testURL', {'id' = 1, 'revision' = 2})#">Click to test URL</a><br/>
	<cfelse>
		For access to arguments given by controller, you can use : <br/>
		ID: #args.get('id')# - args.get('myVar')<br/>
		Revision: #args.get('revision')#<br/>
		<br/>
		Or direct access : <br/>
		ID: #local.id# - local.myVar<br/>
		Revision: #local.revision#<br/>
		<br/>
		Or unscoped vars (not recommended) : <br/>
		ID: #id# - myVar<br/>
		Revision: #revision#<br/>
	</cfif>
	<br/>
	Context: #getContext()# - getContext()<br/>
	<br/>
	#getVersion()# - #getCopyRights()#
</cfoutput>