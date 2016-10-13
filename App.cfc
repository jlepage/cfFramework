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

	this.name = 'cffwk_' & hash(getDirectoryFromPath(getBaseTemplatePath()));

	this.applicationTimeout = createTimeSpan(0, 8, 0, 0);
	this.sessionTimeout = createTimeSpan(0, 2, 0, 0);
	this.clientStorage = 'cookie';
	this.sessionManagement = true;
	this.clientManagement = false;
	this.setClientCookies = false;

	public function init() {
		return this;
	}

	public void function setVersion(required string vers) {
		Application._cfw.version = arguments.vers;
	}

	public string function getVersion() {
		return Application._cfw.version;
	}

	public void function setConfig(required cffwk.base.conf.Config conf) {
		Application._cfw.config = arguments.conf;
	}

	public cffwk.base.conf.Config function getConfig() {
		return Application._cfw.config;
	}

	public void function setEngine(required cffwk.base.engines.EngineInterface currentEngine) {
		Application._cfw.engine = arguments.currentEngine;
	}

	public cffwk.base.engines.EngineInterface function getEngine() {
		return Application._cfw.engine;
	}

	public cffwk.base.Router function getRouter() {
		return getBeanFactory().getBean('Router');
	}

	public void function setRender(required cffwk.base.Render render) {
		Application._cfw.render = arguments.render;
	}

	public cffwk.base.Render function getRender() {
		return Application._cfw.render;
	}

	public void function setBeanFactory(required component factory) {
		Application._cfw.beanFactory = arguments.factory;
	}

	public component function getBeanFactory() {
		return Application._cfw.beanFactory;
	}

	public component function newConfigObject() {
		return createObject('component', 'cffwk.base.conf.Config').init();
	}

	public cffwk.base.engines.EngineInterface function detectEngine() {
		var detector = createObject('component', 'cffwk.base.engines.EngineDetector').init();
		return detector.getEngine();
	}

	private void function _restartConfig() {

		Application._cfw = structNew();
		var cfg = newConfigObject();

		if (!isInstanceOf(cfg, 'cffwk.base.conf.Config')) {
			throw('Config object must be at least an heritance of base.conf.Config');
		}

		setConfig(cfg);
		preConfigProcess();

		setVersion('0.10');
		addParam('version', getVersion());

		addParam('viewsPath', 'viewing/views/');
		addParam('layoutsPath', 'viewing/layouts/');
		addParam('widgetsPath', 'viewing/widgets/');

		addParam('render', 'RenderBase');
		addParam('defaultController', 'DefaultCtrl');
		addParam('defaultControllerAction', 'defaultAction');

		addParam('skipURLIndex', false);

		addParam('authentication', false);
		addParam('loginURL', '/sign-in');

		addParam('sessionUserDAO', 'UserDAO'); 		// must implements base.model.users.io.UserDAOInterface
		addParam('sessionUserBean', 'User');		// must implements base.model.users.UserInterface
		addParam('sessionProfilBean', 'Profil');	// must implements base.model.users.ProfilInterface

		addParam('beanFactory', 'cffwk.ext.ioc');
		addParam('iocPath', '/cffwk/base,/cffwk/controllers,/cffwk/model,/base,/controllers,/helpers,/model,/services');
		addParam('iocSingletonRegex', '(Render|Router|Queue|Ctrl|Controller|DAO|Gw|Gateway|Service|Srv|Factory|Helper|Singleton)$');
		addParam('iocExcludeArray', ['App.cfc', 'Config.cfc', 'AbstractController.cfc', 'AbstractService.cfc', 'RailoEngine.cfc', 'LuceeEngine.cfc']);

		addParamByEnv('debug', 'debug', true);

		setParams();
		getConfig().loadParams();

		_checkViewFolders();

		setEngine(detectEngine());

		if (!isNull(getConfig().getParam('datasource'))) {
			this.datasource = getConfig().getParam('datasource');
			this.defaultdatasource = getConfig().getParam('datasource');
		}

		if (!isNull(getConfig().getParam('defaultLocale'))) {
			setLocale(getConfig().getParam('defaultLocale'));
		}

		preIOCLoadProcess();
		_configBeanFactory();
		postIOCLoadProcess();
		postConfigProcess();

		postConfigProcess();
		getBeanFactory().getBean('Router');
		setRoutes();

	}

	private string function _detectCorrectPath(required string folder) {
		var basePath = getDirectoryFromPath(getBaseTemplatePath());

		if (find('/', arguments.folder) != 1) {
			arguments.folder = '/' & arguments.folder;
		}

		if (!directoryExists(arguments.folder)) {
			if (directoryExists(basePath & arguments.folder)) {
				 return arguments.folder;
			}

			if (directoryExists(basePath & '/cffwk' & arguments.folder)) {
				return '/cffwk' & arguments.folder;
			}

			throw ('No good path found for your views/layouts, please check your config (' & arguments.folder & ')!' );
		}

		return arguments.folder;
	}

	private void function _checkViewFolders() {
		getConfig().setParam('viewsPath', _detectCorrectPath(getConfig().getParam('viewsPath')) );
		getConfig().setParam('layoutsPath', _detectCorrectPath(getConfig().getParam('layoutsPath')) );
		getConfig().setParam('widgetsPath', _detectCorrectPath(getConfig().getParam('widgetsPath')) );
	}

	private void function _configBeanFactory() {

		if (getConfig().getParam('beanFactory') == 'cffwk.ext.ioc') {

			var path = getConfig().getParam('iocPath');
			var single = getConfig().getParam('iocSingletonRegex');
			var excludes = getConfig().getParam('iocExcludeArray');

			var beanFactory = new cffwk.ext.ioc(path, {'singletonPattern' = single, 'exclude'= excludes});

			beanFactory.addBean('config', getConfig());
			beanFactory.addBean('engine', getEngine());

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

	public void function preIOCLoadProcess() {}
	public void function postIOCLoadProcess() {}
	public void function preConfigProcess() {}
	public void function postConfigProcess() {}


	private void function processService() output=true {
		getRouter().processRoute();
	}

	public boolean function onApplicationStart() {
		_restartConfig();
		return true;
	}

	public void function onSessionStart() {
		getBeanFactory().getBean('Session');
		session.user = false;
	}

	public void function onRequestStart(string targetPage) {
		request.started = getTickCount();
		if (structKeyExists(URL, 'reload')) {
			_restartConfig();
		}
	}

	public void function onRequest(string targetPage) output=true {
		processService();
	}

	public void function onRequestEnd() {
		if (getConfig().getParam('debug') && structKeyExists(request, 'renderTime')) {
			var ctrlTime = request.controllerTime - request.renderTime;
			writeOutput('<br/>Exec Time: ' & (getTickCount() - request.started) & 'ms');
			writeOutPut(' - Routing time: ' & request.routerTime & 'ms');
			writeOutPut(' - Controller time: ' & ctrlTime & 'ms');
			writeOutPut(' - Render time: ' & request.renderTime & 'ms');
		}

		if (structKeyExists(URL, 'restart') && getConfig().getParam('debug')) {
			applicationStop();
		}
	}

	public void function onSessionStop() {
		structDelete(session, 'user');
		structDelete(session, 'started');
	}

	/***
	* Shortcuts for cffwk.base.conf.Router object
	**/
	public void function addRoute(required string route, string controller, string action = 'default', string env = '*', string format = '*') {
		getRouter().addRoute(arguments.route, arguments.controller, arguments.action, arguments.env, arguments.format);
	}

	/***
	* Shortcuts for cffwk.base.conf.Config object
	**/
	public void function addParam(required string name, required any value) {
		getConfig().addParam(arguments.name, arguments.value);
	}

	public void function addEnvRule(required cffwk.base.conf.elements.EnvRuleInterface rule) {
		getConfig().addEnvRule(arguments.rule);
	}

	public void function addContextRule(required cffwk.base.conf.elements.ContextRuleInterface rule) {
		getConfig().addContextRule(arguments.rule);
	}

	public void function addParamByIp(required string ip, required string name, required any value) {
		getConfig().addParamByIp(arguments.ip, arguments.name, arguments.value);
	}

	public void function addParamByEnv(required string env, required string name, required any value) {
		getConfig().addParamByEnv(arguments.env, arguments.name, arguments.value);
	}

	public void function addParamByHostname(required string host, required string name, required any value) {
		getConfig().addParamByEnv(arguments.host, arguments.name, arguments.value);
	}

}