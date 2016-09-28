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
component accessors='true' {

	this.name = 'cfw_' & hash(getDirectoryFromPath(getBaseTemplatePath()));

	this.applicationTimeout = createTimeSpan(0, 8, 0, 0);
	this.sessionTimeout = createTimeSpan(0, 2, 0, 0);
	this.clientStorage = 'cookie';
	this.sessionManagement = true;
	this.clientManagement = false;
	this.setClientCookies = false;

	public function init() {
		return this;
	}

	public void function setVersion(string vers) {
		Application._cfw.version = arguments.vers;
	}

	public string function getVersion() {
		return Application._cfw.version;
	}

	public void function setConfig(base.conf.Config conf) {
		Application._cfw.config = arguments.conf;
	}

	public base.conf.Config function getConfig() {
		return Application._cfw.config;
	}

	public base.conf.Router function getRouter() {
		return getBeanFactory().getBean('Router');
	}

	public void function setRender(base.Render render) {
		Application._cfw.render = arguments.render;
	}

	public base.Render function getRender() {
		return Application._cfw.render;
	}

	public void function setBeanFactory(component factory) {
		Application._cfw.beanFactory = arguments.factory;
	}

	public component function getBeanFactory() {
		return Application._cfw.beanFactory;
	}

	private void function _restartConfig() {

		Application._cfw = structNew();

		setVersion('0.9');
		setConfig(createObject('component', 'base.conf.Config').init());

		getConfig().addParam('version', getVersion());
		getConfig().addParam('beanFactory', 'base.ext.ioc');
		getConfig().addParam('render', 'RenderBase');
		getConfig().addParam('viewsPath', '../viewing/views/');
		getConfig().addParam('layoutsPath', '../viewing/layouts/');
		getConfig().addParam('widgetsPath', '../viewing/widgets/');
		getConfig().addParam('defaultController', 'DefaultCtrl');
		getConfig().addParam('defaultControllerAction', 'defaultAction');

		getConfig().addParam('iocPath', '/base,/controllers,/helpers,/model,/services');
		getConfig().addParam('iocSingletonRegex', '(Render|Router|Queue|Ctrl|Controller|DAO|Gw|Gateway|Service|Srv|Factory|Helper|Singleton)$');
		getConfig().addParam('iocExcludeArray', ['App.cfc', 'Config.cfc', 'AbstractController.cfc', 'AbstractService.cfc']);

		addParamByEnv('debug', 'debug', true);

		setParams();
		getConfig().loadParams();

		if (!isNull(getConfig().getParam('datasource'))) {
			this.datasource = getConfig().getParam('datasource');
			this.defaultdatasource = getConfig().getParam('datasource');
		}

		if (!isNull(getConfig().getParam('defaultLocale'))) {
			setLocale(getConfig().getParam('defaultLocale'));
		}

		_configBeanFactory();
		postConfigProcess();

		getBeanFactory().getBean('Router');
		setRoutes();

	}

	private void function _configBeanFactory() {

		if (getConfig().getParam('beanFactory') == 'base.ext.ioc') {

			var path = getConfig().getParam('iocPath');
			var single = getConfig().getParam('iocSingletonRegex');
			var excludes = getConfig().getParam('iocExcludeArray');

			var beanFactory = new base.ext.ioc(path, {'singletonPattern' = single, 'exclude'= excludes});

			beanFactory.addBean('config', getConfig());

			if (!isNull(getConfig().getParam('datasource'))) {
				beanFactory.addBean('datasource', getConfig().getParam('datasource'));
			}

			if (!isNull(getConfig().getParam('render'))) {
				var render = beanFactory.getBean(getConfig().getParam('render'));
				setRender(render);
			}

			setBeanFactory(beanFactory);
		}

	}

	public void function postConfigProcess() {}


	private void function processService() output=true {
		getRouter().processRoute();
	}

	public boolean function onApplicationStart() {
		_restartConfig();
		return true;
	}

	public void function onSessionStart() {
		session.user = false;
		session.started = now();
	}

	public void function onRequestStart(string targetPage) {
		request.started = getTickCount();
		if (structKeyExists(URL, 'reload')) {
			_restartConfig();
		}
	}

	public void function onRequest(string targetPage) output=true {
		processService();
		//getRender().view(arguments.targetPage);
	}

	public void function onRequestEnd() {
		if (getConfig().getParam('debug')) {
			writeOutput('<br/>Exec Time: ' & (getTickCount() - request.started) & 'ms');
		}
		if (structKeyExists(URL, 'restart')) {
			applicationStop();
		}
	}

	public void function onSessionStop() {
		structDelete(session, 'user');
		structDelete(session, 'started');
	}

	/***
	* Shortcuts for base.conf.Router object
	**/
	public void function addRoute(string route, string controller, string action = 'default', string env = '*', string format = '*') {
		getRouter().addRoute(arguments.route, arguments.controller, arguments.action, arguments.env, arguments.format);
	}

	/***
	* Shortcuts for base.conf.Config object
	**/
	public void function addParam(string name, any value) {
		getConfig().addParam(arguments.name, arguments.value);
	}

	public void function addEnvRule(required base.conf.elements.EnvRuleInterface rule) {
		getConfig().addEnvRule(arguments.rule);
	}

	public void function addContextRule(required base.conf.elements.ContextRuleInterface rule) {
		getConfig().addContextRule(arguments.rule);
	}

	public void function addParamByIp(string ip, string name, any value) {
		getConfig().addParamByIp(arguments.ip, arguments.name, arguments.value);
	}

	public void function addParamByEnv(string env, string name, any value) {
		getConfig().addParamByEnv(arguments.env, arguments.name, arguments.value);
	}

	public void function addParamByHostname(string host, string name, any value) {
		getConfig().addParamByEnv(arguments.host, arguments.name, arguments.value);
	}

}