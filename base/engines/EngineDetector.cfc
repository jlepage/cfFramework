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
component accessors=true output=false persistent=false {

	public cffwk.base.engines.EngineDetector function init() {
		return this;
	}

	private cffwk.base.engines.EngineInterface function _initEngine(required string engineClass, required string name, required string version) {
		var engine = createObject('component', arguments.engineClass).init();
		engine.setName( arguments.name );
		engine.setVersion( arguments.version );
		return engine;
	}

	public cffwk.base.engines.EngineInterface function getEngine() output=true {

		if (structKeyExists(server, 'lucee')) {
			return _initEngine('cffwk.base.engines.LuceeEngine', server.coldfusion.productName, server.lucee.version);
		}

		if (structKeyExists(server, 'railo')) {
			return _initEngine('cffwk.base.engines.RailoEngine', server.coldfusion.productName, server.railo.version);
		}

		if (structKeyExists(server, 'coldfusion') && findNoCase('coldfusion', server.coldfusion.productName) > 0) {

			var cfEngineClass = '';
			var majorVersion = listGetAt(server.coldfusion.productVersion, 1, ',');

			if (majorVersion == '9') {
				cfEngineClass = 'cffwk.base.engines.Cf9Engine';

			} else {
				cfEngineClass = 'cffwk.base.engines.ColdfusionEngine';

			}

			return _initEngine(cfEngineClass, server.coldfusion.productName, server.coldfusion.productVersion);
		}

		throw('No Applicable Engine found !');

	}

}