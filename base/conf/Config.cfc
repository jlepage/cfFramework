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
component output='false' accessors='true' {

	property type='string' name='env';
	property type='string' name='ip';
	property type='struct' name='params';

	property type='struct' name='paramsByIp';
	property type='struct' name='paramsByEnv';
	property type='struct' name='paramsByHostname';

	property type='array' name='envRules';
	property type='array' name='contextRules';

	public cffwk.base.conf.Config function init() {
		variables.env = '_default_';
		variables.envRules = arrayNew(1);
		variables.contextRules = arrayNew(1);

		variables.params = structNew();

		variables.paramsByIp = structNew();
		variables.paramsByEnv = structNew();
		variables.paramsByHostname = structNew();

		variables.ip = createObject('java', 'java.net.InetAddress').getByName(CGI.SERVER_NAME).getHostAddress();

		return this;
	}

	public string function getFileSeparator() {
		return createObject('java', 'java.io.File').separator;
	}


	public void function loadParams() {
		_loadEnv();
		_loadParams();
	}

	private void function _loadEnv() {
		var ip = getIp();

		for (var i = 1; i <= arrayLen(variables.envRules); i++) {
			if (variables.envRules[i].isApplicable(hostname = CGI.SERVER_NAME, ip = ip)) {
				variables.env = variables.envRules[i].getEnvName();
			}
		}
	}

	public string function getContext(required cffwk.base.scopes.RequestScope requestScope) {
		for (var i = 1; i <= arrayLen(variables.contextRules); i++) {
			if (variables.contextRules[i].isApplicable(arguments.requestScope)) {
				return variables.contextRules[i].getContextName();
			}
		}

		return '';
	}

	private void function _loadParams() {
		var ips = structKeyArray(variables.paramsByIp);
		for (var i = 1; i <= arrayLen(ips); i++) {
			if (ips[i] == variables.ip) {
				structAppend(variables.params, variables.paramsByIp[ips[i]]);
			}
		}

		var envs = structKeyArray(variables.paramsByEnv);
		for (i = 1; i <= arrayLen(envs); i++) {
			if (envs[i] == variables.env) {
				structAppend(variables.params, variables.paramsByEnv[envs[i]]);
			}
		}

		var hosts = structKeyArray(variables.paramsByHostname);
		for (i = 1; i <= arrayLen(hosts); i++) {
			if (hosts[i] == CGI.SERVER_NAME) {
				structAppend(variables.params, variables.paramsByHostname[hosts[i]]);
			}
		}
	}

	public void function addEnvRule(required cffwk.base.conf.elements.EnvRuleInterface envRule) {
		arrayAppend(variables.envRules, arguments.envRule);
	}

	public void function addContextRule(required cffwk.base.conf.elements.ContextRuleInterface contextRule) {
		arrayAppend(variables.contextRules, arguments.contextRule);
	}

	public any function getParam(required string name) {
		if (structKeyExists(variables.params, arguments.name)) {
			return variables.params[arguments.name];
		}

		return false;
	}

	public void function addParam(string name, any value) {
		variables.params[arguments.name] = arguments.value;
	}

	public void function setParam(string name, any value) {
		variables.params[arguments.name] = arguments.value;
	}

	public void function addParamByIp(required string ip, required string name, required any value) {
		if (!structKeyExists(variables.paramsByIp, arguments.ip)) {
			variables.paramsByIp[arguments.ip] = structNew();
		}

		variables.paramsByIp[arguments.ip][arguments.name] = arguments.value;
	}

	public void function addParamByEnv(required string env, required string name, required any value) {
		if (!structKeyExists(variables.paramsByEnv, arguments.env)) {
			variables.paramsByEnv[arguments.env] = structNew();
		}

		variables.paramsByEnv[arguments.env][arguments.name] = arguments.value;
	}

	public void function addParamByHostname(required string host, required string name, required any value) {
		if (!structKeyExists(variables.paramsByHost, arguments.host)) {
			variables.paramsByHost[arguments.host] = structNew();
		}

		variables.paramsByHost[arguments.host][arguments.name] = arguments.value;
	}

}