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
component implements='base.conf.elements.ContextRuleInterface' accessors=true output=false {

	property string hostname;
	property string uri;
	property string name;

	public base.conf.elements.SimpleContextRule function init(required string name, string hostname = '', string uri = '') {
		setHostname(arguments.hostname);
		setUri(arguments.uri);
		setName(arguments.name);
		return this;
	}

	public string function getContextName() {
		return getName();
	}

	public boolean function isApplicable(required base.model.HttpRequest httpRequest) {

		if (variables.hostname != '' && arguments.httpRequest.getHostname() == variables.hostname) {
			return true;
		}

		if (variables.uri != '' && arguments.httpRequest.getUri() == variables.uri) {
			return true;
		}

		return false;
	}



}