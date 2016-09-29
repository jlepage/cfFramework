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
component output='false' accessors='true' extends='base.App' {
	pageencoding 'utf-8';

	this.sessionTimeout = createTimeSpan(0, 2, 0, 0);
	this.sessionManagement = true;

	public void function setParams() {

		addEnvRule( new base.conf.elements.SimpleEnvRule(hostname = 'cfw.local', name = 'debug') );
		addEnvRule( new base.conf.elements.SimpleEnvRule(ip = 'cfframework.net', name = 'prod') );

		addContextRule( new base.conf.elements.SimpleContextRule(hostname = 'cfframework.local', name = 'full') );
		addContextRule( new base.conf.elements.SimpleContextRule(hostname = 'cfw.local', name = 'short') );

		addParamByEnv('debug', 'debug', true);

		addParam('authentication', false);
		addParam('skipURLIndex', false);			// true for skipping "/index.cfm" on your url

		//addParam('authentication', true);			// must be a true for using authentication features
		//addParam('sessionUserDAO', 'UserDAO'); 	// must implements base.model.users.io.UserDAOInterface
		//addParam('sessionUserBean', 'User');		// must implements base.model.users.UserInterface
		//addParam('sessionProfilBean', 'Profil');	// must implements base.model.users.ProfilInterface


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

	public void function postConfigProcess() {
		//getBeanFactory().addBean('myIOCParam', getConfig().getParam('myAppParam'));

	}

	public void function setRoutes() {
		getRouter().addRoute(id='home', route='/home', controller='DefaultCtrl', action='home');
		getRouter().addRoute(id='testURL', route='/test/{id}/{revision}', controller='DefaultCtrl', action='test');
	}

}