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
		variables.env = '*';
		return this;
	}


	public function load(required struct args) {

		if (structKeyExists(arguments.args, 'id')) {
			variables.id = arguments.args['id'];
		}

		if (structKeyExists(arguments.args, 'controller')) {
			variables.controller = arguments.args['controller'];
		}

		if (structKeyExists(arguments.args, 'route')) {
			variables.route = arguments.args['route'];
		}

		if (structKeyExists(arguments.args, 'action')) {
			variables.action = arguments.args['action'];
		}

		if (structKeyExists(arguments.args, 'env')) {
			variables.env = arguments.args['env'];
		}

		if (structKeyExists(arguments.args, 'format')) {
			variables.format = arguments.args['format'];
		}

		return this;
	}

	public string function getRegexRoute() {
		return '^' & reReplace(variables.route, '\{[^\}]+\}', '([^\/]+)', 'all') & '$';
	}

	public struct function completeResults(required struct results) {
		arguments.results.controllerClass = variables.controller;
		arguments.results.action = variables.action;
		return results;
	}

	public boolean function isEnvMatch(required string env) {
		if (variables.env == arguments.env || variables.env == '*') {
			return true;
		}

		return false;
	}

}