/*****

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

****/
component extends='cffwk.model.scopes.AbstractScope' output='false' {

	public cffwk.model.scopes.HttpRequest function init() {
		super.init(REQUEST);
		return this;
	}

	public numeric function getRequestLife() {
		return super.getScopeLife();
	}

	public string function getHostname() {
		return CGI.SERVER_NAME;
	}

	public string function getUri() {
		var path = CGI.SCRIPT_NAME;

		if (CGI.PATH_INFO != '') {
			path = CGI.PATH_INFO;
		}

		return path;
	}

	public string function getMethod() {
		return uCase(CGI.REQUEST_METHOD);
	}

	public boolean function isMethod(required string methodName) {
		return (getMethod() == uCase(arguments.methodName));
	}

	public any function get(required string name, any defaultValue = '') {
		if (structKeyExists(FORM, arguments.name)) {
			return FORM[arguments.name];
		}

		if (structKeyExists(URL, arguments.name)) {
			return URL[arguments.name];
		}

		return arguments.defaultValue;
	}
}