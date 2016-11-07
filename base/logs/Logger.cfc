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
component output='false' extends='cffwk.base.abs.AbstractObservable' accessors='true' {

	public cffwk.base.logs.Logger function init() {
		super.init();
		variables.levels = {'all'= 0, 'debug'= 1, 'info'= 2, 'warning'= 3, 'error'= 4, 'critic' = 5, 'off'= 666};
		return this;
	}

	public void function registerObserver(cffwk.base.abs.AbstractObserver observer) {
		super.registerObserver(arguments.observer);
		this.log('info', 'Add observer to logger', this);
	}

	public numeric function getLevelValue(required string levelName) {
		if (structKeyExists(variables.levels, arguments.levelName)) {
			return variables.levels[arguments.levelName];
		}
	}

	public void function log(required string level, required string message, required component caller) output=true {
		if (structKeyExists(variables.levels, lCase(arguments.level))) {
			writeDump(arguments);
			notifyObservers({'level'= lCase(arguments.level), 'message'= arguments.message, 'caller'= arguments.caller});

		} else {
			throw('the Log Level "' & arguments.level & '" is unknow');

		}
	}

	public string function getDefautMessageLine(required string caller, required string level, required string message) {
		var date = dateFormat(now(), 'yyyy/mm/dd') & ' - ' & timeFormat(now(), 'HH:mm:ss:l'); 
		var className = getComponentMetaData(arguments.caller).fullName;
		return date & ' [' & className & '] ' & uCase(arguments.level) & ' ' & arguments.message & ' - ' & getTickCount();
	}

	public boolean function isApplicable(required string currentLevel, string minLevel = 'all') {
		if (getLevelValue(arguments.currentLevel) >= getLevelValue(arguments.minLevel)) {
			return true;
		}

		return false;
	}

	public void function debug(required string message, required component caller) {
		this.log('debug', arguments.message, arguments.caller);
	}

	public void function info(required string message, required component caller) {
		this.log('info', arguments.message, arguments.caller);
	}

	public void function warning(required string message, required component caller) {
		this.log('warning', arguments.message, arguments.caller);
	}

	public void function error(required string message, required component caller) {
		this.log('error', arguments.message, arguments.caller);
	}

	public void function critic(required string message, required component caller) {
		this.log('critic', arguments.message, arguments.caller);
	}

}