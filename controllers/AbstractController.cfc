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
component output='false' accessors='true' {

	property type='cffwk.base.conf.Config' name='config';

	property type='cffwk.base.Router' name='router';
	property type='cffwk.model.users.UserGateway' name='userGateway';

	property type='component' name='render';
	property type='component' name='beanFactory';

	public cffwk.controllers.AbstractController function init() {
		return this;
	}

	public cffwk.base.scopes.RequestScope function getRequest() {
		return getBeanFactory().getBean('RequestScope');
	}

	public cffwk.base.scopes.SessionScope function getSession() {
		return getBeanFactory().getBean('SessionScope');
	}

	public string function getContext() {
		return getConfig().getContext( getRequest() );
	}

	public boolean function signInUser(required string login, required string password) {
		var user = getUserGateway().findUser(arguments.login, arguments.password);
		if (user.isValid()) {
			getUserGateway().signIn(user);
			return true;
		}

		return false;
	}

	public void function signOutUser() {
		getUserGateway().signOut();
	}

	public boolean function redirectAnonymous() {
		var messages = get('Messages');
		var user = getUserGateway().getAuthUser();

		if (isNull(user) || !user.isValid()) {
			messages.addError('User invalid or disconnected!');
			redirect(getConfig().getParam('loginURL'), false);
			return true;
		}

		return false;
	}

	public any function get(required string serviceName) {
		return getBeanFactory().getBean(arguments.serviceName);
	}

	public string function getURL(required string routeId, struct args = {}) {
		return getRouter().getFormatedURL(arguments.routeId, arguments.args);
	}

	public void function redirect(required string path, boolean hard = false) {
		getRouter().redirectTo(arguments.path, arguments.hard);
	}

}