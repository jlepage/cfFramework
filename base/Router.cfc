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

	property type='array' name='routes';
	property type='cffwk.base.conf.Config' name='config';
	property type='component' name='engine';
	property type='cffwk.model.iocAdapters.iocAdapterInterface' name='iocAdapter';

	property type='struct' name='cacheRouteIds';

	public function init() {
		variables.cacheRouteIds = structNew();
		variables.routes = arrayNew(1);
		return this;
	}

	public string function getPath() {
		var path = CGI.SCRIPT_NAME;
		if (CGI.PATH_INFO != '') {
			path = CGI.PATH_INFO;
		}

		path = replaceNoCase(path, '.cfm', '');
		path = replaceNoCase(path, '/index.cfm', '/');
		return path;
	}

	private struct function _getRuleToProcess(required string path) output='true' {

		if (variables.config.getParam('debug')) {
			variables.iocAdapter.getObject('Chrono').start('Router');

		}

		var routes = variables.routes;
		var result = {'path' = arguments.path, 'hasParameters' = false, 'parameters' = structNew()};
		var curEnv = variables.config.getEnv();

		for (var i = 1; i <= arrayLen(variables.routes); i++) {

			var interpretedRoute = variables.routes[i].getRegexRoute();

			if (arrayLen(reMatch(interpretedRoute, arguments.path)) && variables.routes[i].isEnvMatch(curEnv) ) {
				result = variables.routes[i].completeResults(result);
				result.hasParameters = true;

				var varNames = reMatch('\{([a-zA-Z0-9\-]+)\}', variables.routes[i].getRoute());
				var replacementExp = '';

				for (var j = 1; j <= arrayLen(varNames); j++) {
					var currentName = reReplace(varNames[j], '\{([^\}]+)\}', '\1', 'one');
					replacementExp = listAppend(replacementExp, currentName & '=\' & j, '||');
				}

				var regexMatch = reReplace(variables.routes[i].getRoute(), '\{[^\}]+\}', '(.*)', 'all');
				var rawParams = listToArray(reReplace(arguments.path, regexMatch, replacementExp), '|');

				for (var k = 1; k <= arrayLen(rawParams); k++) {
					var paramName = listFirst(rawParams[k], '=');
					var paramValue = listLast(rawParams[k], '=');
					result.parameters[paramName] = paramValue;
				}

			}

			if (variables.config.getParam('debug')) {
				variables.iocAdapter.getObject('RequestScope').append('routeDebug', interpretedRoute);
			}

			if (variables.routes[i].getRoute() == arguments.path && variables.routes[i].isEnvMatch(curEnv) ) {
				result = routes[i].completeResults(result);
			}

			if (structKeyExists(result, 'controllerClass')) {
				result.controller = variables.iocAdapter.getObject(result.controllerClass);

				if (!isInstanceOf(result.controller, 'cffwk.controllers.AbstractController')) {
					throw('Your controller ' & result.controllerClass & ' must be an instance of cffwk.controllers.AbstractController');

				}

				if (variables.config.getParam('debug')) {
					variables.iocAdapter.getObject('RequestScope').set('route', interpretedRoute);
					variables.iocAdapter.getObject('Chrono').end('Router');

				}

				return result;
			}

		}

		result.controllerClass = variables.config.getParam('defaultController');
		result.action = variables.config.getParam('defaultControllerAction');
		result.controller = variables.iocAdapter.getObject(result.controllerClass);

		if (!isInstanceOf(result.controller, 'cffwk.controllers.AbstractController')) {
			throw('Your default controller ' & result.controllerClass & ' must be an instance of cffwk.controllers.AbstractController');

		}

		if (variables.config.getParam('debug')) {
			variables.iocAdapter.getObject('RequestScope').set('route', 'default');
			variables.iocAdapter.getObject('Chrono').end('Router');

		}

		return result;

	}

	public any function getRouteByID(required string routeId) {
		if (structKeyExists(variables.cacheRouteIds, arguments.routeId)) {
			return variables.cacheRouteIds[arguments.routeId];
		}

		for (var i = 1; i <= arrayLen(variables.routes); i++) {
			if (lCase(variables.routes[i].getId()) == lCase(arguments.routeId)) {
				return variables.routes[i];
			}
		}
	}

	public string function getFormatedUrl(required string routeId, struct args = {}) {
		var route = getRouteByID(arguments.routeId);
		var skip = variables.config.getParam('skipURLIndex');

		if (!isNull(route)) {
			var urlRoute = route.getRoute();
			var varNames = reMatch('\{([a-zA-Z0-9\-]+)\}', urlRoute);

			for (var j = 1; j <= arrayLen(varNames); j++) {
				var key = reReplace(varNames[j], '[\{\}]', '', 'all');

				if (!structKeyExists(arguments.args, key)) {
					throw('Argument "' & key & '" not found on route "' & arguments.routeId & '"');

				}

				var value = arguments.args[key];
				urlRoute = reReplace(urlRoute, '\{' & key & '\}', value, 'all');

			}

			if (skip != true) {
				urlRoute = '/index.cfm' & urlRoute;
			}

			return urlRoute;
		}

		throw('Route "' & arguments.routeId & '" not found');
	}

	public void function addRoute(string id, string route, string controller, string action = 'default', string env = '*', string format = 'text/html') {
		var curRoute = variables.iocAdapter.getObject('Route').load(arguments);
		variables.cacheRouteIds[arguments.id] = curRoute;
		arrayAppend(variables.routes, curRoute);
	}

	public void function processRoute(required string pathToProcess = '') {
		if (arguments.pathToProcess == '') {
			arguments.pathToProcess = getPath();
		}

		if (variables.config.getParam('debug')) {
			variables.iocAdapter.getObject('Chrono').start('Controller');
		}

		var process = _getRuleToProcess(arguments.pathToProcess);
		variables.engine.invoke(process.controller, process.action, process.parameters);

		if (variables.config.getParam('debug')) {
			variables.iocAdapter.getObject('Chrono').end('Controller');
		}
	}

	public void function redirectTo(required string path, boolean hard = false) {

		if (arguments.hard) {
			variables.engine.hardRedirect(arguments.path);
			return;
		}

		if (!variables.iocAdapter.getObject('RequestScope').has('redirects')) {
			variables.iocAdapter.getObject('RequestScope').set('redirects', 0);
		}

		variables.iocAdapter.getObject('RequestScope').incr('redirects');

		if (variables.iocAdapter.getObject('RequestScope').get('redirects') > 10) {
			throw({message = 'Too much redirections, maybe a infinite loop over here !'});
		}

		processRoute(arguments.path);

	}

}