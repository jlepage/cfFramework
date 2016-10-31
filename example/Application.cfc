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
component output='false' accessors='true' extends='cffwk.App' {
	pageencoding 'utf-8';

	this.sessionTimeout = createTimeSpan(0, 2, 0, 0);
	this.sessionManagement = true;

	public void function setParams() {

		addEnvRule( new cffwk.base.conf.elements.SimpleEnvRule(hostname = 'cffwk.local', name = 'debug') );
		addEnvRule( new cffwk.base.conf.elements.SimpleEnvRule(hostname = 'cffwktest.local', name = 'debug') );
		addEnvRule( new cffwk.base.conf.elements.SimpleEnvRule(ip = 'cfframework.net', name = 'prod') );

		addContextRule( new cffwk.base.conf.elements.SimpleContextRule(hostname = 'cfframework.local', name = 'full') );
		addContextRule( new cffwk.base.conf.elements.SimpleContextRule(hostname = 'cfw.local', name = 'short') );

		addParamByEnv('debug', 'debug', true);

		addParam('authentication', false);
		addParam('skipURLIndex', false);			// true for skipping "/index.cfm" on your url

		//addParam('authentication', true);			// must be a true for using authentication features
		//addParam('sessionUserDAO', 'UserDAO'); 	// must implements cffwk.model.users.io.UserDAOInterface
		//addParam('sessionUserBean', 'User');		// must implements cffwk.model.users.UserInterface
		//addParam('sessionProfilBean', 'Profil');	// must implements cffwk.model.users.ProfilInterface

		addParam('ApplicationName', 'MyOwnApplicationName');
		addParam('ApplicationVersion', '1.0');

		addParam('mediasPath', '/assets');
		addParam('datasource', 'cfw');
		addParam('defaultLocale', 'French (Standard)'); // Yeah I'm french ;)

		addParamByEnv('debug', 'Param1', 'valueForDebug');
		addParamByEnv('prod', 'Param1', 'ValueForProduction');

		addParam('defaultController', 'DefaultCtrl');
		addParam('defaultControllerAction', 'home');

	}


	public void function postIOCLoadProcess() {
		//getIocAdapter().addConstant('myIOCParam', getConfig().getParam('myObject'));

	}

	public void function setRoutes() {
		getRouter().addRoute(id='home', route='/home', controller='DefaultCtrl', action='home');
		getRouter().addRoute(id='testURL', route='/test/{id}/{revision}', controller='DefaultCtrl', action='test');
		getRouter().addRoute(id='testRedirect', route='/redirectHard', controller='DefaultCtrl', action='testRedirectHard');
	}

}