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
component extends='cffwk.base.scopes.AbstractScope' output='false' {

	property type='cffwk.model.users.UserGateway' name='UserGateway';

	public cffwk.base.scopes.SessionScope function init() {
		super.init(SESSION);

		if (!super.has('user')) {
			super.set('user', false);

		}

		return this;
	}

	public numeric function getSessionLife() {
		return super.getScopeLife();
	}

	public any function getUser() {
		return getUserGateway().getAuthUser();
	}
}