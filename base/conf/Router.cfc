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
	property type='base.conf.Config' name='config';
	property type='base.engines.EngineInterface' name='engine';
	property type='component' name='beanFactory';

	property type='struct' name='cacheRouteIds';

	public function init() {
		variables.cacheRouteIds = structNew();
		setRoutes(arrayNew(1));
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

		if (getConfig().getParam('debug')) {
			request.routerStart = getTickCount();
			request.routeDebug = arrayNew(1);

		}

		var routes = getRoutes();
		var result = {'path' = arguments.path, 'hasParameters' = false, 'parameters' = structNew()};

		for (var i = 1; i <= arrayLen(routes); i++) {

			var interpretedRoute = routes[i].getRegexRoute();

			if (arrayLen(reMatch(interpretedRoute, arguments.path)) && routes[i].isEnvMatch(getConfig().getEnv()) ) {
				result = routes[i].completeResults(result);
				result.hasParameters = true;

				var varNames = reMatch('\{([a-zA-Z0-9\-]+)\}', routes[i].getRoute());
				var replacementExp = '';

				for (var j = 1; j <= arrayLen(varNames); j++) {
					var currentName = reReplace(varNames[j], '\{([^\}]+)\}', '\1', 'one');
					replacementExp = listAppend(replacementExp, currentName & '=\' & j, '||');
				}

				var regexMatch = reReplace(routes[i].getRoute(), '\{[^\}]+\}', '(.*)', 'all');
				var rawParams = listToArray(reReplace(arguments.path, regexMatch, replacementExp), '|');

				for (var k = 1; k <= arrayLen(rawParams); k++) {
					var paramName = listFirst(rawParams[k], '=');
					var paramValue = listLast(rawParams[k], '=');
					result.parameters[paramName] = paramValue;
				}

			}

			if (getConfig().getParam('debug')) {
				arrayAppend(request.routeDebug, interpretedRoute);
			}

			if ( routes[i].getRoute() == arguments.path && routes[i].isEnvMatch(getConfig().getEnv()) ) {
				result = routes[i].completeResults(result);
			}

			if (structKeyExists(result, 'controllerClass')) {
				result.controller = getBeanFactory().getBean(result.controllerClass);

				if (!isInstanceOf(result.controller, 'base.controllers.AbstractController')) {
					throw('Your controller must be an instance of base.controllers.AbstractController');

				}

				if (getConfig().getParam('debug')) {
					request.route = interpretedRoute;
					request.routerTime = getTickCount() - request.routerStart;

				}

				return result;
			}

		}

		result.controllerClass = getConfig().getParam('defaultController');
		result.action = getConfig().getParam('defaultControllerAction');
		result.controller = getBeanFactory().getBean(result.controllerClass);

		if (!isInstanceOf(result.controller, 'base.controllers.AbstractController')) {
			throw('Your default controller must be an instance of base.controllers.AbstractController');

		}

		if (getConfig().getParam('debug')) {
			request.routerTime = getTickCount() - request.routerStart;
			request.route = 'default';

		}

		return result;

	}

	public any function getRouteByID(required string routeId) {
		if (structKeyExists(variables.cacheRouteIds, arguments.routeId)) {
			return variables.cacheRouteIds[arguments.routeId];
		}

		var routes = getRoutes();

		for (var i = 1; i <= arrayLen(routes); i++) {
			if (lCase(routes[i].getId()) == lCase(arguments.routeId)) {
				return routes[i];
			}
		}
	}

	public string function getFormtedUrl(required string routeId, struct args = {}) {
		var route = getRouteByID(arguments.routeId);
		var skip = getConfig().getParam('skipURLIndex');

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
		var cur = getBeanFactory().getBean('Route').load(arguments);
		variables.cacheRouteIds[arguments.id] = cur;
		arrayAppend(getRoutes(), cur);
	}

	public void function processRoute(string pathToProcess = '') {
		if (arguments.pathToProcess == '') {
			arguments.pathToProcess = getPath();
		}

		if (getConfig().getParam('debug')) {
			request.controllerStart = getTickCount();
		}

		var process = _getRuleToProcess(arguments.pathToProcess);
		var args = process.parameters;
		var call = 'process.controller.#process.action#(argumentCollection = args)';
		evaluate(call);

		if (getConfig().getParam('debug')) {
			request.controllerTime = getTickCount() - request.controllerStart;
		}
	}

	public void function redirectTo(required string path, boolean hard = false) {

		if (arguments.hard) {
			getEngine().hardRedirect(arguments.path);
			return;
		}

		if (!structKeyExists(request, 'redirects')) {
			request.redirects = 0;
		}

		request.redirects++;

		if (request.redirects > 10) {
			throw({message = 'Too much redirections, maybe a infinite loop over here !'});
		}

		processRoute(arguments.path);

	}

}