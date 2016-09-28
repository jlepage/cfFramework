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
<cfcomponent accessors="true" output="false">

	<cfproperty name="config" type="base.conf.Config" />
	<cfproperty name="beanFactory" type="component" />

	<cffunction name="init" returntype="base.model.users.UserGateway">
		<cfreturn this />
	</cffunction>

	<cffunction name="getUserDAO" returntype="base.model.users.io.UserDAOInterface">
		<cfreturn getBeanFactory().getBean( getConfig().getParam('Session.UserDAO') ) />
	</cffunction>


	<cffunction name="findUser" returntype="base.model.users.UserInterface">
		<cfargument name="login" type="string" required="true" />
		<cfargument name="password" type="string" required="true" />

		<cfset var dao = getUserDAO() />
		<cfset var user = dao.getByAccess(arguments.login, arguments.password) />

		<cfif isNull(user) || !user.isValid()>
			<cfreturn getBeanFactory().getBean( getConfig().getParam('Session.UserBean') ) />
		</cfif>

		<cfreturn user />

	</cffunction>


	<cffunction name="getAuthUser" returntype="base.model.users.UserInterface">

		<cfset var dao = getUserDAO() />

		<cfif ! isUserLoggedIn()>
			<cfif structKeyExists(session, 'user') && session.user neq ''>
				<cfreturn dao.get(session.user) />
			</cfif>
			<cfreturn getBeanFactory().getBean( getConfig().getParam('Session.UserBean') ) />
		</cfif>

		<cfset var user = dao.getByLogin(getAuthUser()) />

		<cfif isNull(user) || !user.isValid()>
			<cfreturn getBeanFactory().getBean( getConfig().getParam('Session.UserBean') ) />
		</cfif>

		<cfreturn user />

	</cffunction>

	<cffunction name="signIn" returntype="void">
		<cfargument name="user" type="base.model.users.UserInterface" required="true"/>

		<cfif isNull(arguments.user) || !arguments.user.isValid()>
			<cfreturn />
		</cfif>

		<cfset var roles = arrayToList(user.getProfil().getRights(), ',') />
		<cfloginuser name="#arguments.user.getLogin()#" roles="#roles#" password="#hash(getTickcount())#" />
		<cfset session.user = arguments.user.getUUID() />

	</cffunction>

	<cffunction name="signOut" returntype="void">

		<cflogout />
		<cfset structClear(session) />

	</cffunction>

</cfcomponent>