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
component accessors='true' output='false' persistent='false' {

	property type='string' name='id';
	property type='string' name='route';
	property type='string' name='controller';
	property type='string' name='action';
	property type='string' name='env';
	property type='string' name='format';


	public function init() {
		return this;
	}


	public function load(required struct args) {

		if (structKeyExists(arguments.args, 'id')) {
			setId(arguments.args['id']);
		}

		if (structKeyExists(arguments.args, 'controller')) {
			setController(arguments.args['controller']);
		}

		if (structKeyExists(arguments.args, 'route')) {
			setRoute(arguments.args['route']);
		}

		if (structKeyExists(arguments.args, 'action')) {
			setAction(arguments.args['action']);
		}

		if (structKeyExists(arguments.args, 'env')) {
			setEnv(arguments.args['env']);
		}

		if (structKeyExists(arguments.args, 'format')) {
			setFormat(arguments.args['format']);
		}

		return this;
	}

	public string function getRegexRoute() {
		return '^' & reReplace( getRoute(), '\{[^\}]+\}', '([^\/]+)', 'all') & '$';
	}

	public struct function completeResults(required struct results) {
		arguments.results.controllerClass = getController();
		arguments.results.action = getAction();
		return results;
	}

	public boolean function isEnvMatch(required string env) {
		if (getEnv() == arguments.env || getEnv() == '*') {
			return true;
		}

		return false;
	}

}