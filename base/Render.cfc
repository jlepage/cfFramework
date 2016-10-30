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

	property type='cffwk.base.scopes.Applicationscope' name='Application';
	property type='cffwk.base.conf.Config' name='config';
	property type='cffwk.base.Router' name='router';

	property type='cffwk.model.users.UserGateway' name='userGateway';

	property type='cffwk.base.scopes.SessionScope' name='SessionScope';
	property type='cffwk.base.scopes.RequestScope' name='RequestScope';

	property type='cffwk.ext.cfFactory' name='BeanFactory';
	property type='string' name='datasource';

	public cffwk.base.Render function init() {
		return this;
	}

	private string function _generateView(required string viewFile, struct fctArgs = {}) {
		if (variables.config.getParam('debug')) {
			debugPath(arguments.viewFile);
		}

		arguments.fctArgs = _populateArgs(arguments.fctArgs);
		structAppend(local, arguments.fctArgs);

		var args = variables.beanFactory.getBean('RenderScope');
		args.setParams(arguments.fctArgs);

		savecontent variable='response' {
			include arguments.viewFile;

		}

		return response;
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

	public boolean function isAnonymous() {
		return ! isLoggedIn();
	}

	public any function getDebugPath() {
		return variables.requestScope.get('path');
	}

	public void function debugPath(required string viewFile) {
		if (variables.config.getParam('debug')) {
			variables.requestScope.append('path', arguments.viewFile);
		}
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
			getChrono().start('Render');
		}

		writeOutput( view(arguments.template, arguments.args, arguments.layout) );

		if (getConfig().getParam('debug')) {
			getChrono().end('Render');
		}
	}

	public string function get(required string configParams) {
		return variables.config.getParam(arguments.configParams);
	}

	public any function getBean(required string beanName) {
		return variables.BeanFactory.getBean(arguments.beanName);
	}

	public string function getContext() {
		return variables.config.getContext(variables.RequestScope);
	}

	public cffwk.base.scopes.RequestScope function getRequest() {
		return variables.requestScope;
	}

	public cffwk.base.scopes.SessionScope function getSession() {
		return variables.sessionScope;
	}

	public cffwk.model.Chrono function getChrono() {
		return variables.BeanFactory.getBean('Chrono');
	}

	public string function getUrl(required string routeId, struct args = {}) {
		return variables.router.getFormatedUrl(arguments.routeId, arguments.args);
	}

	public string function getVersion() {
		return 'cfFramework v' & variables.config.getParam('version');
	}

	public string function getCopyrights() {
		return 'Copyright (c) ' & dateFormat(now(), 'YYYY') & ', Jerome Lepage (j@cfm.io)';
	}

}