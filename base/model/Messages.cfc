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
component output="false" {

	property struct messages;

	public any function init() {
		if (structKeyExists(request, 'messages')) {
			return request.messages;
		}
		clear();
		return this;
	}

	public void function addSuccess(required string message) {
		add('info', arguments.message);
	}

	public array function getSuccess() {
		return get('info');
	}

	public void function addInfo(required string message) {
		add('info', arguments.message);
	}

	public array function getInfo() {
		return get('info');
	}

	public void function addNotice(required string message) {
		add('notice', arguments.message);
	}

	public array function getNotice() {
		return get('notice');
	}

	public void function addWarning(required string message) {
		add('warning', arguments.message);
	}

	public array function getWarning() {
		return get('warning');
	}

	public void function addError(required string message) {
		add('error', arguments.message);
	}

	public array function getError() {
		return get('error');
	}


	public void function add(required string level, required string message) {
		if (!structKeyExists(variables.messages, arguments.level)) {
			variables.messages[arguments.level] = arrayNew(1);
		}

		arrayAppend(variables.messages[arguments.level], arguments.message);
		request.messages = this;
	}


	public array function get(required string level) {
		if (!structKeyExists(variables.messages, arguments.level)) {
			return arrayNew(1);
		}

		return variables.messages[arguments.level];
	}

	public void function clear() {
		variables.messages = structNew();
		request.messages = this;
	}
}