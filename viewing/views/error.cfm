
<h2>Erreur</h2>
<cfoutput>#error#</cfoutput>

<cfif isDefined('debug')>
	<div style="border: 1px solid #dcdcdc; padding: 15px; margin: 15px;">
		<h5>Debug</h5>
		<hr/>
	<cfloop array="#path#" index="curTemplate">
		<cfoutput><h6>#curTemplate#</h6></cfoutput>
	</cfloop>
		<hr/>
		<cfoutput><h6>#request.route#</h6></cfoutput>
	</div>
	<!---cfdump var="#request.routeDebug#"/--->
	<!---cfdump var="#cgi#"/--->
</cfif>

<!---cfscript>

	path = '/user/83fddb8a-942a-11e4-b34b-001e8c66dc33/to/001e8c66dc33-83fddb8a-942a-11e4-b34b';
	route = '/user/{id}/to/{group}';

	writeOutput(path & '<br/>');
	writeOutput(route & '<br/>');

	interpretedRoute = '^' & reReplace(route, '\{[^\}]+\}', '(.*)', 'all') & '$';
	writeOutput(interpretedRoute & '<br/>');

	dump(reFind(interpretedRoute, path));

	vars = reMatch('\{([a-zA-Z0-9\-]+)\}', route);
	currentRoute = route;
	currentRoute = reReplace(currentRoute, '\{[^\}]+\}', '(.*)', 'all');
	replaceString = '';

	for (i = 1; i <= arrayLen(vars); i++) {
		name = reReplace(vars[i], '\{([^\}]+)\}', '\1', 'one');
		replaceString = listAppend(replaceString, name & '=\' & i, '||');
	}
	dump(currentRoute);
	dump(replaceString);
	raws = reReplace(path, currentRoute, replaceString);
	params = listToArray(raws, '|');
	dump(params);

	dump(reFind(interpretedRoute, path));
	dump(reMatch(interpretedRoute, path));



</cfscript--->