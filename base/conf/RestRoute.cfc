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
component extends='cffwk.base.conf.Route' accessors='true' output='false' persistent='false' {

	property type='string' name='method';

	public function init() {
		super.inig();
		variables.env = '*';
		return this;
	}

	public function load(required struct args) {
		super.load(arguments.args);

		if (structKeyExists(arguments.args, 'method')) {
			variables.method = arguments.args['method'];
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