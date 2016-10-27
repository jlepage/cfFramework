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
<cfcomponent implements="cffwk.base.engines.ColdfusionEngine" accessors="true" output="false">

	<cffunction name="init" access="public" returntype="cffwk.base.engines.Cf9nEngine">
		<cfset super.init() />
		<cfreturn this />
	</cffunction>

	<cffunction name="hardRedirect" access="public" returntype="void">
		<cfargument name="location" type="string" required="true" />

		<cfheader name="Location" value="#arguments.location#" />
		<cfheader statuscode="302" statustext="Moved Temporarily"/>

	</cffunction>

	<cffunction name="invoke" access="public" returntype="void">
		<cfargument name="instance" type="component" required="true" />
		<cfargument name="cftName" type="string" required="true" />
		<cfargument name="params" type="struct" required="true" />

		<cfinvoke component="#arguments.instance#" method="#arguments.cftName#" argumentcollection="#arguments.params#" />

	</cffunction>

</cfcomponent>