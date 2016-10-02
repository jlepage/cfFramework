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
	pageencoding 'utf-8';

	property base.conf.Config config;
	property base.conf.Router router;
	property base.model.users.UserGateway userGateway;
	property base.ext.ioc BeanFactory;

	public base.Render function init() {
		return this;
	}

	private string function _generateView(required string viewFile, struct args = {}) {
		debugPath(arguments.viewFile);
		arguments.args = _populateArgs(arguments.args);
		structAppend(local, args);

		savecontent variable='response' {
			include arguments.viewFile;

		}

		return response;
	}

	public string function getUrl(required string routeId, struct args = {}) {
		return variables.router.getFormtedUrl(arguments.routeId, arguments.args);
	}

	public any function getUser() {
		var user = getUserGateway().getAuthUser();

		if (isNull(user) || !user.isValid()) {
			return false;
		}

		return user;
	}

	public boolean function isLoggedIn() {
		if (isObject(getUser())) {
			return true;

		}

		return false;
	}

	public any function getDebugPath() {
		return request.path;
	}

	public void function debugPath(required string viewFile) {

		if (variables.config.getParam('debug')) {

			if (!structKeyExists(request, 'path')) {
				request.path = arrayNew(1);

			}

			arrayAppend(request.path, arguments.viewFile);
		}
	}

	public string function getVersion() {
		return 'cfFramework v' & variables.config.getParam('version');
	}

	public string function getCopyrights() {
		return 'Copyright (c) ' & dateFormat(now(), 'YYYY') & ', Jerome Lepage (j@cfm.io)';
	}

	public boolean function isAnonymous() {
		return ! isLoggedIn();
	}

	private struct function _populateArgs(required struct args) {

		if (!structKeyExists(arguments.args, 'messages')) {

			if (structKeyExists(request, 'messages')) {
				arguments.args['messages'] = request.messages;

			} else {
				arguments.args['messages'] = variables.BeanFactory.getBean('Messages');

			}
		}

		if (variables.config.getParam('authentication') == true) {
			if (!structKeyExists(arguments.args, 'user') && isLoggedIn()) {
				arguments.args['user'] = getUser();
			}

			arguments.args['login'] = getAuthUser();
			arguments.args['logged'] = isUserLoggedIn();

		}

		if (variables.config.getEnv() == 'debug') {
			arguments.args['debug'] = true;
			arguments.args['path'] = getDebugPath();
		}


		return arguments.args;
	}

	public string function layout(required string layoutFile, struct args = {}) {
		return _generateView(variables.config.getParam('layoutsPath') & arguments.layoutFile, arguments.args);
	}

	public string function view(required string viewFile, struct args = {}, string layoutFile = 'default.cfm') {
		arguments.args['body'] = _generateView(variables.config.getParam('viewsPath') & arguments.viewFile, arguments.args);
		return layout(arguments.layoutFile, arguments.args);
	}

	public void function widget(required string widgetFile, struct args = {}) {
		writeOutput( _generateView(variables.config.getParam('widgetsPath') & arguments.widgetFile, arguments.args) );
	}

	public void function render(required string template, struct args = {}, string layout = 'default.cfm') {
		if (getConfig().getParam('debug')) {
			request.renderStart = getTickCount();

		}

		writeOutput( view(arguments.template, arguments.args, arguments.layout) );

		if (getConfig().getParam('debug')) {
			request.renderTime = getTickCount() - request.renderStart;

		}
	}

	public string function get(required string configParams) {
		return variables.config.getParam(arguments.configParams);
	}

	public any function getBean(required string beanName) {
		return variables.BeanFactory.getBean(arguments.beanName);
	}

	public string function getContext() {
		var req = variables.BeanFactory.getBean('HttpRequest');
		return variables.config.getContext(req);
	}

}