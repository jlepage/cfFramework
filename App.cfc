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

	public component function getApp() {
		if (!structKeyExists(this, 'app')) {
			this.app = new cffwk.base.scopes.ApplicationScope();
		}

		return this.app;
	}

	public void function setVersion(required string vers) {
		getApp().set('version', arguments.vers);
	}

	public string function getVersion() {
		return getApp().get('version');
	}

	public void function setConfig(required cffwk.base.conf.Config conf) {
		getApp().set('config', arguments.config);
	}

	public cffwk.base.conf.Config function getConfig() {
		return getApp().get('config');
	}

	public void function setEngine(required cffwk.base.engines.EngineInterface currentEngine) {
		getApp().set('engine', arguments.currentEngine);
	}

	public cffwk.base.engines.EngineInterface function getEngine() {
		return getApp().get('engine');
	}

	public cffwk.base.Router function getRouter() {
		return getBeanFactory().getBean('Router');
	}

	public void function setRender(required component render) {
		getApp().set('render', arguments.render);
	}

	public component function getRender() {
		return getApp().get('render');
	}

	public void function setBeanFactory(required component factory) {
		getApp().set('beanFactory', arguments.factory);
	}

	public component function getBeanFactory() {
		return getApp().get('beanFactory');
	}

	public component function newConfigObject() {
		return new cffwk.base.conf.Config();
	}

	public cffwk.base.engines.EngineInterface function detectEngine() {
		var detector = new cffwk.base.engines.EngineDetector();
		return detector.getEngine();
	}

	public cffwk.model.Chrono function getChrono() {
		return getApp().get('chrono', new cffwk.model.Chrono());
	}

	private void function _restartConfig() {

		var app = getApp();
		app.set('load_in_progress', true);
		app.set('chrono', new cffwk.model.Chrono());
		app.get('chrono').start('Config');

		var cfg = newConfigObject();
		var engines = ['RailoEngine.cfc', 'LuceeEngine.cfc', 'ColdfusionEngine', 'Cf9Engine'];

		if (!isInstanceOf(cfg, 'cffwk.base.conf.Config')) {
			throw('Config object must be at least an heritance of base.conf.Config');
		}

		app.set('config', cfg);
		preConfigProcess();

		app.set('version', '0.10');
		addParam('version', getVersion());

		addParam('viewsPath', 'viewing/views/');
		addParam('layoutsPath', 'viewing/layouts/');
		addParam('widgetsPath', 'viewing/widgets/');

		addParam('render', 'Render');
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

		var excludes = ['App.cfc', 'Config.cfc', 'AbstractController.cfc', 'AbstractService.cfc', 'AbstractScope.cfc'];
		excludes = listToArray(listAppend(arrayToList(excludes), arrayToList(engines)));

		addParam('iocExcludeArray', excludes);

		addParamByEnv('debug', 'debug', true);

		app.get('chrono').start('Params init');
		setParams();
		app.get('chrono').end('Params init');

		app.get('chrono').start('Params load');
		getConfig().loadParams();
		app.get('chrono').end('Params load');

		app.get('chrono').start('Check views');
		_checkViewFolders();
		app.get('chrono').end('Check views');

		app.get('chrono').start('Detect engine');
		setEngine(detectEngine());
		app.get('chrono').end('Detect engine');

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

		app.get('chrono').start('Routes load');
		setRoutes();
		app.get('chrono').end('Routes load');

		app.get('chrono').end('Config');
		app.delete('load_in_progress');
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

	private void function _configBeanFactory() output=true {

		getApp().get('chrono').start('BeanFactory Init');
		if (getConfig().getParam('beanFactory') == 'cffwk.ext.ioc') {

			var path = getConfig().getParam('iocPath');
			var single = getConfig().getParam('iocSingletonRegex');
			var excludes = getConfig().getParam('iocExcludeArray');

			var beanFactory = new cffwk.ext.ioc(path, {'singletonPattern' = single, 'exclude'= excludes});

			beanFactory.addBean('config', getConfig());
			beanFactory.addBean('engine', getEngine());
			beanFactory.addBean('chrono', getChrono());

			beanFactory.addBean('RequestScope', beanFactory.getBean('RequestScope'));
			beanFactory.addBean('SessionScope', beanFactory.getBean('SessionScope'));

			if (!isNull(getConfig().getParam('datasource'))) {
				beanFactory.addBean('datasource', getConfig().getParam('datasource'));
			}

			if (!isNull(getConfig().getParam('render'))) {
				var render = beanFactory.getBean(getConfig().getParam('render'));
				setRender(render);
			}

			setBeanFactory(beanFactory);
		}

		getApp().get('chrono').end('BeanFactory Init');
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
		if (!getApp().has('load_in_progress')) {
			getBeanFactory().getBean('SessionScope').reset();
		}
	}

	public void function onRequestStart(string targetPage) {

		if (structKeyExists(URL, 'reload') && !getApp().has('load_in_progress')) {
			_restartConfig();

		} else {
			getApp().get('chrono').reset();

		}

		getBeanFactory().getBean('RequestScope');
		getApp().get('chrono').start('Request');
	}

	public void function onRequest(string targetPage) output=true {
		processService();
	}

	public void function onRequestEnd() {
		getApp().get('chrono').end('Request');

		if (getConfig().getParam('debug')) {
			getApp().get('chrono').printResults();

		}

		getBeanFactory().getBean('RequestScope').reset();

		ioc = new cffwk.ext.cfFactory();

		if (structKeyExists(URL, 'restart') && getConfig().getParam('debug')) {
			applicationStop();
		}
	}

	public void function onSessionStop() {
		getBeanFactory().getBean('SessionScope').reset();
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