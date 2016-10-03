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
component implements='base.conf.elements.EnvRuleInterface' accessors=true output=false {

	property type='string' name='hostname';
	property type='string' name='ip';
	property type='string' name='name';

	public base.conf.elements.SimpleEnvRule function init(required string name, string hostname = '', string ip = '') {
		setHostname(arguments.hostname);
		setIp(arguments.ip);
		setName(arguments.name);
		return this;
	}

	public string function getEnvName() {
		return getName();
	}

	public boolean function isApplicable(string hostname = '', string ip = '') {

		if (trim(arguments.hostname) != '' && arguments.hostname == variables.hostname) {
			return true;
		}

		if (trim(arguments.ip) != '' && arguments.ip == variables.ip) {
			return true;
		}

		return false;
	}


}