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
component output='false' {

	property type='struct' name='scope';
	property type='string' name='scope_uuid';
	property type='string' name='scope_name';

	private cffwk.base.scopes.AbstractScope function init(required struct scope) {
		variables.scope = arguments.scope;
		_createScope();
		return this;
	}

	private void function _createScope(boolean force = false) output=true {
		var prefix = '_cffwf_';
		var uuidKey = prefix & 'uuid';

		if (!structKeyExists(variables.scope, uuidKey) || arguments.force) {
			variables.scope_uuid = createUUID();
			variables.scope_name = prefix & variables.scope_uuid;
			variables.scope[uuidKey] = variables.scope_uuid;

		} else {
			variables.scope_name = prefix & variables.scope[uuidKey];

		}
	}

	private void function _checkScope() {
		if (!structKeyExists(variables.scope, variables.scope_name)) {
			variables.scope[variables.scope_name] = structNew();
			variables.scope[variables.scope_name]['started'] = getTickCount();

		}
	}

	public void function reset() {
		_createScope(true);
	}

	public numeric function getScopeLife() {
		_checkScope();
		return getTickCount() - get('started', getTickCount());
	}

	public void function set(required string name, required any value) {
		_checkScope();
		variables.scope[variables.scope_name][arguments.name] = arguments.value;
	}

	public void function append(required string name, required any value, boolean forceList = false) {
		_checkScope();

		if (!has(arguments.name)) {
			if (arguments.forceList == true) {
				variables.scope[variables.scope_name][arguments.name] = '';

			} else {
				variables.scope[variables.scope_name][arguments.name] = arrayNew(1);

			}

		}

		if (isSimpleValue(variables.scope[variables.scope_name][arguments.name])) {
			listAppend(variables.scope[variables.scope_name][arguments.name], arguments.value);

		}

		if (isArray(variables.scope[variables.scope_name][arguments.name])) {
			arrayAppend(variables.scope[variables.scope_name][arguments.name], arguments.value);

		}

	}

	public void function incr(required string name, numeric increment = 1) {
		_checkScope();

		if (!has(arguments.name)) {
			set(arguments.name, 0);

		}

		variables.scope[variables.scope_name][arguments.name] += arguments.increment;
	}

	public void function decr(required string name, numeric increment = 1) {
		_checkScope();

		if (!has(arguments.name)) {
			set(arguments.name, 0);

		}

		variables.scope[variables.scope_name][arguments.name] -= arguments.increment;
	}

	public boolean function has(required string name) {
		_checkScope();

		if (structKeyExists(variables.scope[variables.scope_name], arguments.name)) {
			return true;
		}

		return false;
	}

	public void function delete(required string name) {
		_checkScope();

		if (structKeyExists(variables.scope[variables.scope_name], arguments.name)) {
			structDelete(variables.scope[variables.scope_name], arguments.name);
		}
	}

	public any function get(required string name, any defaultValue = '') {
		_checkScope();

		if (structKeyExists(variables.scope[variables.scope_name], arguments.name)) {
			return variables.scope[variables.scope_name][arguments.name];
		}

		return arguments.defaultValue;
	}
}