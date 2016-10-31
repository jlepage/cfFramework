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

	property type="cffwk.ext.ioc" name="diOne";

	public cffwk.model.iocAdapters.diOneAdapter function init() {
		return this;
	}

	public void function initIOC(required cffwk.base.conf.Config config) {

		var path = arguments.config.getParam('iocPath');
		var single = arguments.config.getParam('iocSingletonRegex');
		var excludes = arguments.config.getParam('iocExcludeArray');

		variables.diOne = new cffwk.ext.ioc(path, {'singletonPattern' = single, 'exclude'= excludes});

		variables.diOne.addBean('iocAdapter', variables.diOne);
		variables.diOne.addBean('config', arguments.config);

		variables.diOne.addBean('RequestScope', variables.diOne.getBean('RequestScope'));
		variables.diOne.addBean('SessionScope', variables.diOne.getBean('SessionScope'));

		if (!isNull(arguments.config.getParam('datasource'))) {
			variables.diOne.addBean('datasource',arguments.config.getParam('datasource'));
		}

	}

	public component function getIOC() {
		return variables.diOne;
	}

	public void function addObject(required any object, string name = '') {
		variables.diOne.addBean(arguments.name, arguments.object);
	}

	public void function addConstant(required string name, required any value) {
		variables.diOne.addConstant(arguments.name, arguments.value);
	}

}