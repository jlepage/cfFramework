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

	public base.engines.EngineDetector function init() {
		return this;
	}

	public base.engines.EngineInterface function getEngine() output=true {

		if (structKeyExists(server, 'lucee')) {
			var engine = createObject('component', 'base.engines.LuceeEngine').init();
			engine.setName( server.coldfusion.productName );
			engine.setVersion( server.lucee.version );
			return engine;

		}

		if (structKeyExists(server, 'railo')) {
			var engine = createObject('component', 'base.engines.RailoEngine').init();
			engine.setName( server.coldfusion.productName );
			engine.setVersion( server.railo.version );
			return engine;

		}

		if (structKeyExists(server, 'coldfusion') && findNoCase('coldfusion', server.coldfusion.productName) > 0) {
			var engine = createObject('component', 'base.engines.ColdfusionEngine').init();
			engine.setName( server.coldfusion.productName );
			engine.setVersion( server.coldfusion.productVersion );
			return engine;

		}

		throw('No Applicable Engine found !');

	}

}