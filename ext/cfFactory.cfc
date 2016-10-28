/**
 * cfFactory
 *
 * @author JLepage
 * @date 28/10/16
 **/
component accessors=true output=false persistent=false {

	property type="string" name="exclusionRegex";
	property type="array" name="aComponents";

	public component function init() {

		variables.exclusionRegex = '(Abstract[a-zA-Z]+|App|Null)\.cfc$';
		variables.aComponents = arrayNew(1);

		browseDirectory('/cffwk');
		return this;


	}

	private void function browseDirectory(required string directory) {
		var path2Escape = replace(expandPath(arguments.directory), arguments.directory, '');
		var files = directoryList(expandPath(arguments.directory), true, 'path', '*.cfc');

		for (var i = 1; i < arrayLen(files); i++) {
			var curFile = replace(files[i], path2Escape, '');
			curFile = replace(curFile, '\', '.', 'all');
			curFile = replace(curFile, '/', '.', 'all');
			curFile = reReplace(curFile, '^\.', '');
			curFile = arguments.directory & '.' & curFile;

			if (!reFind(variables.exclusionRegex, curFile, 1, false)) {
				arrayAppend(variables.aComponents, curFile);
				if (isSimpleValue(curFile)) {
					_addBeanInfo(curFile);
				}
			}

		}

		writeDump(variables.aComponents);

	}

	private void function _addBeanInfo(required string beanName) {
		arguments.beanName = reReplace(arguments.beanName, '\.cfc$', '');
		var infos = _populateBeanInfo(getComponentMetaData(arguments.beanName));
		writeDump(infos);
	}

	private struct function _populateBeanInfo(required struct beanInfo) {
		var infos = {name= arguments.beanInfo.fullName};

		if (structKeyExists(arguments.beanInfo, 'properties')) {
			infos.properties = arguments.beanInfo.properties;
		}

		if (structKeyExists(arguments.beanInfo, 'functions')) {

			for (var i = 1; i <= arrayLen(arguments.beanInfo.functions); i++) {

				if (reFindNoCase('^((is|set)[a-zA-Z]+|init)$', arguments.beanInfo.functions[i].name, 1, false)) {
					infos.functions = arguments.beanInfo.functions;

				}
			}
		}

		if (structKeyExists(arguments.beanInfo, 'extends')) {
			structAppend(infos, _populateBeanInfo(arguments.beanInfo.extends));
		}

		return infos;


	}

}