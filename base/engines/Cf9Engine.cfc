<!---

Copyright (c) 2016, Jerome Lepage (j@cfm.io)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

--->
<cfcomponent implements="cffwk.base.engines.EngineInterface" accessors="true" output="false">

	<cfproperty type='string' name='name' />
	<cfproperty type='string' name='version' />

	<cffunction name="init" access="public" returntype="cffwk.base.engines.Cf9Engine">
		<cfreturn this />
	</cffunction>

	<cffunction name="setName" returntype="void">
		<cfargument type="string" name="name" required="true" />
		<cfset variables.name = arguments.name />
	</cffunction>

	<cffunction name="getName" returntype="string">
		<cfreturn variables.name />
	</cffunction>

	<cffunction name="getClassName" returntype="string">
		<cfreturn 'cffwk.base.engines.Cf9Engine' />
	</cffunction>

	<cffunction name="setVersion" returntype="void">
		<cfargument type="string" name="version" required="true" />
		<cfset variables.version = arguments.version />
	</cffunction>

	<cffunction name="getVersion" returntype="string">
		<cfreturn variables.version />
	</cffunction>

	<cffunction name="hardRedirect" access="public" returntype="void">
		<cfargument name="location" type="string" required="true" />

		<cfheader name="Location" value="#arguments.location#" />
		<cfheader statuscode="302" statustext="Moved Temporarily"/>

	</cffunction>

	<!--- public void function invoke(required component instance, required string fctName, required any params); --->

	<cffunction access="public" returntype="void" name="invoke">
		<cfargument required="true" type="component" name="instance" />
		<cfargument required="true" type="string" name="fctName" />
		<cfargument required="true" type="any" name="params" />

		<cfinvoke component="#arguments.instance#" method="#arguments.fctName#" argumentcollection="#arguments.params#">
		</cfinvoke>

	</cffunction>

</cfcomponent>