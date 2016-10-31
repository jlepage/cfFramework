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
component accessors=true output=false persistent=false implements="cffwk.model.iocAdapters.iocAdapterInterface" {

	property type="cffwk.ext.elIocNess" name="elIocNess";

	public cffwk.model.iocAdapters.elIocNessAdapter function init() {
		return this;
	}

	public void function initIOC(required cffwk.base.conf.Config config) {

		variables.elIocNess = new cffwk.ext.elIocNess();
		variables.elIocNess.addDirectories( listToArray(getConfig().getParam('iocPath'), ',;') );

		variables.elIocNess.addAlias('iocAdapter', 'cffwk.ext.elIocNess');
		variables.elIocNess.addToCache(getConfig());

		if (!isNull(arguments.config.getParam('datasource'))) {
			variables.elIocNess.addConstant('datasource', arguments.config.getParam('datasource'));

		}

	}

	public component function getIOC() {
		return variables.elIocNess;
	}

	public void function addObject(required any object, string name = '') {
		variables.elIocNess.addToCache(arguments.object, arguments.name);
	}

	public void function addConstant(required string name, required any value) {
		variables.elIocNess.addConstant(arguments.name, arguments.value);
	}


}