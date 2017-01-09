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
component output='false' extends='cffwk.base.abs.AbstractObserver' accessors='true' {

	property type='string' name='minLevel';
	property type='array' name='logs';

	public cffwk.base.logs.ScreenAppender function init(required cffwk.base.logs.Logger logger, string minLevel = 'info') {
		super.init(arguments.logger);
		variables.minLevel = arguments.minLevel;
		variables.logs = arrayNew(1);
		return this;
	}


	public void function notify(struct parameters = {}) {
		if (structKeyExists(arguments.parameters, 'level') && structKeyExists(arguments.parameters, 'message') && structKeyExists(arguments.parameters, 'caller')) {

			if (variables.observable.isApplicable(arguments.parameters.level, variables.minLevel)) {
				var toAppend = variables.observable.getDefautMessageLine(argumentCollection= arguments.parameters);
				arrayAppend(variables.logs, toAppend);

			}
		}
	}

	public void function printLogs() output=true {
		writeDump(variables.logs);

	}

}