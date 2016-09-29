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

	property base.conf.Config config;
	property string context;
	property base.conf.Router router;
	property base.model.users.UserGateway userGateway;
	property component render;
	property component beanFactory;

	public any function init() {
		return this;
	}

	public string function getContext() {
		var req = getRequest();
		return getConfig().getContext(req);
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

		if (isNull(user) || user.isNew()) {
			messages.addError('User invalid or disconnected!');
			redirect(getConfig().getParam('loginURL'), false);
			return true;
		}

		return false;
	}

	public base.model.HttpRequest function getRequest() {
		return getBeanFactory().getBean('HttpRequest');
	}

	public any function get(required string serviceName) {
		return getBeanFactory().getBean(arguments.serviceName);
	}

	public void function redirect(required string path, boolean hard = false) {

		if (!structKeyExists(request, 'redirects')) {
			request.redirects = 0;
		}

		request.redirects++;

		if (request.redirects > 10) {
			throw({message = 'Too much redirections, maybe a infinite loop over here !'});
		}

		if (arguments.hard) {
			getPageContext().getResponse().getResponse().setHeader('Location', arguments.path);
			getPageContext().getResponse().getResponse().setStatus(302);

		} else {
			getRouter().processRoute(arguments.path);

		}
	}

}