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
	property type='string' name='fileName';

	public cffwk.base.logs.FileAppender function init(required cffwk.base.logs.Logger logger, required string filename, string minLevel = 'info') {
		super.init(arguments.logger);
		variables.filename = arguments.filename;
		variables.minLevel = arguments.minLevel;

		if (!fileExists(variables.filename)) {
			notify({'level'= 'info', 'message'= 'init this log file', 'caller'= this});
			
		}

		return this;
	}


	public void function notify() {
		if (structKeyExists(arguments, 'level') && structKeyExists(arguments, 'message') && structKeyExists(arguments, 'caller')) {

			if (variables.observable.isApplicable(arguments.level, variables.minLevel)) {
				var toAppend = variables.observable.getDefautMessageLine(argumentCollection= arguments);
				fileAppend(variables.filename, toAppend);

			}
		}
	}

}