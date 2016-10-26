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
component implements='cffwk.base.engines.EngineInterface' accessors=true output=false {

	property type='string' name='name';
	property type='string' name='version';

	public base.engines.RailoEngine function init() {
		return this;
	}

	public void function setName(required string name) {
		variables.name = arguments.name;
	}

	public string function getName(){
		return variables.name;
	}

	public void function setVersion(required string version) {
		variables.version = arguments.version;
	}

	public string function getVersion() {
		return variables.version;
	}

	public void function hardRedirect(required string location) {
		header statuscode = '302' statustext = 'Moved Temporarily';
		header name = 'Location', value = arguments.location ;
	}

	public void function invoke(required component instance, required string fctName, required any params) {
		invoke(arguments.instance, arguments.fctName, arguments.params);
	}

}