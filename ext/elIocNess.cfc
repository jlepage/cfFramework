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

	property type="string" name="exclusionRegex";
	property type="array" name="aComponents";
	property type="struct" name="definitions";
	property type="struct" name="constants";

	public component function init() {

		variables.version = '0.9';

		variables.exclusionRegex = '(Abstract[a-zA-Z]+|App|Null|Engine|Application)\.cfc$';
		variables.singletonRegex = '(Config|Render|Router|Queue|Ctrl|Controller|DAO|Gw|Gateway|Service|Srv|Factory|Helper|Singleton)$';

		variables.definitions = {components= {}, alias= {}};
		variables.constants = {};
		variables.beansCache = {'cffwk.ext.elIocNess' = this};

		variables.simpleValueTypes = ['struct', 'array', 'numeric', 'string', 'date', 'query', 'binary', 'guid', 'uuid', 'any'];

		return this;
	}

	public void function addDirectories(required array directory) output=true {
		for (var i = 1; i <= arrayLen(arguments.directory); i++) {
			_browseDirectory(arguments.directory[i]);

		}

	}

	public void function addConstant(required string name, required any value) {
		variables.constants[arguments.name] = arguments.value;
	}

	public void function addToCache(required any object, string alias = '') {
		var className = getMetaData(arguments.object).fullName;
		variables.beansCache[className] = arguments.object;
		_addBeanInfo(className);

		if (arguments.alias != '') {
			addAlias(arguments.alias, className);
		}

	}

	public void function addAlias(required string alias, required string className) {
		variables.definitions.alias[arguments.alias] = arguments.className;
	}

	public any function getBean(required string className) {
		return getObject(arguments.className);
	}

	public any function getObject(required string className) output=true {
		var cmpDefinition = _getDefinition(arguments.className);
		var bean = false;

		if (structIsEmpty(cmpDefinition)) {
			throw('Unable to get object for name "' & arguments.className & '"');
			return bean;
		}

		if (structKeyExists(variables.beansCache, cmpDefinition.className)) {
			bean = variables.beansCache[cmpDefinition.className];

		} else {
			var initArgs = {};

			if (structKeyExists(cmpDefinition.functions, 'init')) {
				var initDef = cmpDefinition.functions.init;
				var paramNames = structKeyArray(initDef.parameters);

				for (var i = 1; i <= arrayLen(paramNames); i++) {
					initArgs[ initDef.parameters[paramNames[i]].name ] = _getArgumentValue(initDef.parameters[paramNames[i]]);
				}
			}

			evaluate('bean = new ' & cmpDefinition.className & '( argumentCollection = initArgs )');

			if (cmpDefinition.singleton == true) {
				variables.beansCache[cmpDefinition.className] = bean;

			}

		}

		for (var p = 1; p <= arrayLen(cmpDefinition.properties); p++) {
			var setter = 'set' & cmpDefinition.properties[p].name;

			if (structKeyExists(cmpDefinition.functions, setter)) {
				var value = _getArgumentValue(cmpDefinition.properties[p]);

				if (!isNull(value)) {
					evaluate('bean.' & setter & '(value)');

				}
			}
		}


		return bean;
	}

	public function getDefinition(required string className) {
		return _getDefinition(arguments.className);
	}

	private struct function _getDefinition(required string className) {

		if (structKeyExists(variables.definitions.components, arguments.className)) {
			return variables.definitions.components[arguments.className];

		} else if (structKeyExists(variables.definitions.alias, arguments.className)) {
			arguments.className = variables.definitions.alias[arguments.className];
			return variables.definitions.components[arguments.className];

		}

		return {};
	}

	private any function _getBeanByDefName(required string definitionName) {
		var def = _getDefinition(arguments.definitionName);

		if (!structIsEmpty(def)) {
			return getObject(def.className);

		}

	}

	private any function _getArgumentValue(required struct argFunct) {

		if (structKeyExists(arguments.argFunct, 'type') && !arrayContains(variables.simpleValueTypes, arguments.argFunct.type)) {

			if (arguments.argFunct.type != 'component') {
				return _getBeanByDefName(arguments.argFunct.type);

			} else {
				return _getBeanByDefName(arguments.argFunct.name);

			}


		} else {

			if (structKeyExists(variables.constants, arguments.argFunct.name)) {
				return variables.constants[arguments.argFunct.name];
			}

			if (!structKeyExists(arguments.argFunct, 'type')) {
				return _getBeanByDefName(arguments.argFunct.name);
			}


		}

		return ;
	}

	private void function _browseDirectory(required string directory) {
		var path2Escape = replace(expandPath(arguments.directory), arguments.directory, '');

		if (directoryExists(expandPath(arguments.directory))) {
			var files = directoryList(expandPath(arguments.directory), true, 'path', '*.cfc');

			for (var i = 1; i <= arrayLen(files); i++) {
				var curFile = arguments.directory & replace(files[i], path2Escape, '');
				curFile = replace(curFile, '\', '.', 'all');
				curFile = replace(curFile, '/', '.', 'all');
				curFile = reReplace(curFile, '^\.', '');


				if (!reFind(variables.exclusionRegex, curFile, 1, false)) {
					if (isSimpleValue(curFile)) {
						_addBeanInfo(curFile);

					}
				}
			}
		}
	}

	private void function _addBeanInfo(required string className) {
		if (findNoCase('WEB-INF', arguments.className) <= 0) {
			arguments.className = reReplace(arguments.className, '\.cfc$', '');
			var metaData = getComponentMetaData(arguments.className);

			if (metaData.type != 'interface') {
				var infos = _populateBeanInfo(metaData);
				variables.definitions.components[infos.name] = infos;
				variables.definitions.alias[infos.alias] = infos.name;
				variables.definitions.alias[infos.shortName] = infos.name;

			}

		}
	}

	private boolean function _isFunctionApplicable(required struct functMeta) {
		if (arrayLen(arguments.functMeta.parameters) > 1 && lCase(arguments.functMeta.name) != 'init') {
			return false;
		}

		if (structKeyExists(arguments.functMeta, 'access') && arguments.functMeta.access != 'public') {
			return false;
		}

		if (!reFindNoCase('^(set.*|init)$', arguments.functMeta.name, 1, false)) {
			return false;
		}

		return true;

	}

	private struct function _getFunctionLightInfo(required struct functMeta) {
		var parameters = {};
		for (var i = 1; i <= arrayLen(arguments.functMeta.parameters); i++) {
			parameters[ arguments.functMeta.parameters[i].name ] = arguments.functMeta.parameters[i];
		}


		return {'name'= arguments.functMeta.name, 'parameters'= parameters};
	}

	private struct function _populateBeanInfo(required struct beanInfo) {
		var infos = {'name'= '', 'properties'= arrayNew(1), 'functions'= structNew()};

		if (structKeyExists(arguments.beanInfo, 'extends')) {
			structAppend(infos, _populateBeanInfo(arguments.beanInfo.extends));

		}

		if (structKeyExists(arguments.beanInfo, 'properties')) {
			for (var i = 1; i <= arrayLen(arguments.beanInfo.properties); i++) {
				arrayAppend(infos.properties, arguments.beanInfo.properties[i]);
			}

		}

		if (structKeyExists(arguments.beanInfo, 'functions')) {
			for (var i = 1; i <= arrayLen(arguments.beanInfo.functions); i++) {
				if (_isFunctionApplicable(arguments.beanInfo.functions[i])) {
					var curInfo = _getFunctionLightInfo(arguments.beanInfo.functions[i]);
					infos.functions[curInfo.name] = curInfo;
				}
			}
		}


		if (structKeyExists(arguments.beanInfo, 'accessors')) {
			infos.accessors = arguments.beanInfo.accessors;
		}

		infos.className = arguments.beanInfo.fullName;
		infos.singleton = false;

		infos.name = arguments.beanInfo.fullName;
		infos.shortName = listGetAt(infos.name, listLen(infos.name, '.'), '.');
		infos.alias = listGetAt(infos.name, listLen(infos.name, '.') - 1, '.') & '.' & infos.shortName;

		if (reFindNoCase(variables.singletonRegex, infos.name) >= 1) {
			infos.singleton = true;
		}

		return infos;
	}

}