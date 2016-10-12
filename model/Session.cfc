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

	property type='string' name='session_uuid';
	property type='string' name='session_name';
	property type='cffwk.model.users.UserGateway' name='UserGateway';

	public cffwk.model.Session function init() {
		var prefix = '_cffwf_';
		var uuidKey = prefix & 'uuid';

		if (!structKeyExists(SESSION, uuidKey)) {
			variables.session_uuid = createUUID();
			variables.session_name = prefix & variables.session_uuid;

			SESSION[uuidKey] = variables.session_uuid;
			SESSION[variables.session_name] = structNew();
			SESSION[variables.session_name]['started'] = getTickCount();

		}

		return this;
	}

	public any function getSessionLife() {
		return getTickCount() - get('started', getTickCount());
	}

	public any function getUser() {
		return getUserGateway().getAuthUser();
	}

	public any function set(required string name, required any value) {
		SESSION[variables.session_name][arguments.name] = arguments.value;
	}

	public any function has(required string name) {
		if (structKeyExists(SESSION[variables.session_name], arguments.name)) {
			return true;
		}

		return false;
	}

	public any function get(required string name, any defaultValue = '') {
		if (structKeyExists(SESSION[variables.session_name], arguments.name)) {
			return SESSION[variables.session_name][arguments.name];
		}

		return arguments.defaultValue;
	}
}