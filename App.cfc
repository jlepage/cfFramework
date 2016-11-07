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

	public void function setLogger(required component logger) {
		getApp().set('logger', arguments.logger);
	}

	public component function getLogger() {
		return getApp().get('logger');
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
		return getIocAdapter().getObject('Router');
	}

	public void function setRender(required component render) {
		getApp().set('render', arguments.render);
	}

	public component function getRender() {
		return getApp().get('render');
	}

	public void function setIocAdapter(required cffwk.model.iocAdapters.iocAdapterInterface adapter) {
		getApp().set('iocAdapter', arguments.adapter);
	}

	public cffwk.model.iocAdapters.iocAdapterInterface function getIocAdapter() {
		return getApp().get('iocAdapter');
	}

	public component function newConfigObject() {
		return new cffwk.base.conf.Config();
	}

	public cffwk.base.logs.Logger function createLogger() {
		var logger = new cffwk.base.logs.Logger();
		var fileName = getDirectoryFromPath(getBaseTemplatePath()) & 'cffwk-' & dateFormat(now(), 'yyyymmdd') & '.log';
		var file = new cffwk.base.logs.FileAppender(logger, fileName, 'all');
		var screen = new cffwk.base.logs.ScreenAppender(logger, 'all');
		getApp().set('screenLogger', screen);
		return logger;
	}

	public cffwk.base.engines.EngineInterface function detectEngine() {
		var detector = new cffwk.base.engines.EngineDetector();
		return detector.getEngine();
	}

	public cffwk.model.Chrono function getChrono() {
		return getApp().get('chrono', new cffwk.model.Chrono());
	}

	private void function _restartConfig(boolean isApplicationStart = false) {

		var app = getApp();
		app.reset();
		var log = createLogger();

		log.info('start configuration of cffwk', this);
		app.set('load_in_progress', true);
		app.set('chrono', new cffwk.model.Chrono());
		app.get('chrono').start('Config');

		log.debug('create new instance of config object', this);
		var cfg = newConfigObject();
		log.debug('instance is ' & getComponentMetaData(cfg).fullName, this);
		var engines = ['RailoEngine.cfc', 'LuceeEngine.cfc', 'ColdfusionEngine', 'Cf9Engine'];

		if (!isInstanceOf(cfg, 'cffwk.base.conf.Config')) {
			log.error('Config object must be at least an heritance of base.conf.Config', this);
			throw('Config object must be at least an heritance of base.conf.Config');
		}

		app.set('config', cfg);
		log.debug('Call preConfigProcess', this);
		preConfigProcess();
		log.debug('preConfigProcess called', this);

		log.debug('Start to add default parameters', this);
		app.set('version', '0.12');
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

		addParam('iocAdapter', 'cffwk.model.iocAdapters.elIocNessAdapter'); // cffwk.model.iocAdapters.diOneAdapter
		addParam('iocPath', '/cffwk,/controllers,/helpers,/model,/services');
		addParam('iocSingletonRegex', '(Render|Router|Queue|Ctrl|Controller|DAO|Gw|Gateway|Service|Srv|Factory|Helper|Singleton)$');

		var excludes = ['App.cfc', 'Config.cfc', 'AbstractController.cfc', 'AbstractService.cfc', 'AbstractScope.cfc'];
		excludes = listToArray(listAppend(arrayToList(excludes), arrayToList(engines)));

		addParam('iocExcludeArray', excludes);

		addParamByEnv('debug', 'debug', true);

		log.debug('Call setParams(), specific and overrided parameters', this);
		app.get('chrono').start('Params init');
		setParams();
		app.get('chrono').end('Params init');
		log.debug('setParams() called', this);

		log.debug('Load config parameters', this);
		app.get('chrono').start('Params load');
		getConfig().loadParams();
		app.get('chrono').end('Params load');
		log.debug('Config parameters loaded', this);

		log.debug('Correct views folders', this);
		app.get('chrono').start('Check views');
		_checkViewFolders();
		app.get('chrono').end('Check views');
		log.debug('Views folders corrected', this);

		log.debug('Detect engine', this);
		app.get('chrono').start('Detect engine');
		setEngine(detectEngine());
		app.get('chrono').end('Detect engine');
		log.debug('Engine detected', this);

		if (!isNull(getConfig().getParam('datasource'))) {
			log.debug('Set Datasource', this);
			this.datasource = getConfig().getParam('datasource');
			this.defaultdatasource = getConfig().getParam('datasource');
		}

		if (!isNull(getConfig().getParam('defaultLocale'))) {
			log.debug('Set defaultLocale', this);
			setLocale(getConfig().getParam('defaultLocale'));
		}

		preIOCLoadProcess();
		_configIOCAdapter();
		postIOCLoadProcess();
		postConfigProcess();

		postConfigProcess();
		getIocAdapter().getObject('Router');

		app.get('chrono').start('Routes load');
		setRoutes();
		app.get('chrono').end('Routes load');

		app.get('chrono').end('Config');
		if (arguments.isApplicationStart) {
			app.set('applicationStart', true);

		}

		setLogger(log);
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

	private void function _configIOCAdapter() output=true {

		getApp().get('chrono').start('IOCAdapter Init');
		var iocAdapter = createObject('component', getConfig().getParam('iocAdapter')).init();


		iocAdapter.initIOC(getConfig());

		iocAdapter.addObject(getEngine(), 'engine');
		iocAdapter.addObject(getChrono(), 'chrono');
		iocAdapter.addObject(getLogger(), 'logger');

		if (!isNull(getConfig().getParam('render'))) {
			var render = iocAdapter.getObject( getConfig().getParam('render') );
			setRender(render);

		}

		setIocAdapter(iocAdapter);

		getApp().get('chrono').end('IOCAdapter Init');
	}

	public void function preIOCLoadProcess() {}
	public void function postIOCLoadProcess() {}

	public void function preConfigProcess() {}
	public void function postConfigProcess() {}


	private void function processService() output=true {
		getRouter().processRoute();
	}

	public boolean function onApplicationStart() {
		getApp().set('ApplicationStart', true);
		return true;
	}

	public void function onSessionStart() {
		if (!getApp().has('ApplicationStart') && !structKeyExists(URL, 'reload')) {
			getIocAdapter().getObject('SessionScope').reset();
		}
	}

	public void function onRequestStart(string targetPage) {
		var loadConfig = false;

		if (getApp().has('ApplicationStart')) {
			loadConfig = true;
		}

		if (structKeyExists(URL, 'reload') && !getApp().has('load_in_progress')) {
			loadConfig = true;
		}

		if (loadConfig) {
			_restartConfig();
			getApp().delete('ApplicationStart');

		} else {
			getApp().get('chrono').reset();
			getApp().delete('load_in_progress');

		}

		getIocAdapter().getObject('RequestScope');
		getApp().get('chrono').start('Request');
	}

	public void function onRequest(string targetPage) output=true {
		processService();
	}

	public void function onRequestEnd() {
		getApp().get('chrono').end('Request');

		if (getConfig().getParam('debug')) {
			getApp().get('chrono').printResults();
			getApp().get('screenLogger').printLogs();

		}

		getIocAdapter().getObject('RequestScope').reset();

		if (structKeyExists(URL, 'restart') && getConfig().getParam('debug')) {
			getApp().reset();
			applicationStop();
		}
	}

	public void function onSessionStop() {
		getIocAdapter().getObject('SessionScope').reset();
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