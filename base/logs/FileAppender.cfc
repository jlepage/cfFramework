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
		variables.filename = arguments.filename;
		variables.minLevel = arguments.minLevel;

		super.init(arguments.logger);
		register(arguments.logger);

		if (!fileExists(variables.filename)) {
			this.notify({'level'= 'info', 'message'= 'init this log file', 'caller'= this});

		}

		return this;
	}


	public void function notify(struct parameters = {}) {
		if (structKeyExists(arguments.parameters, 'level') && structKeyExists(arguments.parameters, 'message') && structKeyExists(arguments.parameters, 'caller')) {

			if (variables.observable.isApplicable(arguments.parameters.level, variables.minLevel)) {
				var toAppend = variables.observable.getDefautMessageLine(argumentCollection= arguments.parameters);
				var pFile = fileOpen(variables.filename, 'append');
				fileWriteLine(pFile, toAppend);
				fileClose(pFile);

			}
		}
	}

}