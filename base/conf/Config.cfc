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

	public function init() {

		setEnv('_default_');
		setEnvRules(arrayNew(1));
		setContextRules(arrayNew(1));

		setParams(structNew());
		setParamsByIp(structNew());
		setParamsByEnv(structNew());
		setParamsByHostname(structNew());

		setIp( createObject('java', 'java.net.InetAddress').getByName(CGI.SERVER_NAME).getHostAddress() );

		return this;
	}

	public void function loadParams() {
		_loadEnv();
		_loadParams();
	}

	private void function _loadEnv() {
		var envRules = getEnvRules();
		var ip = getIp();

		for (var i = 1; i <= arrayLen(envRules); i++) {
			if (envRules[i].isApplicable(hostname = CGI.SERVER_NAME, ip = ip)) {
				setEnv(envRules[i].getEnvName());
			}
		}
	}

	public string function getContext(required base.model.HttpRequest httpRequest) {
		var contextRules = getContextRules();

		for (var i = 1; i <= arrayLen(contextRules); i++) {
			if (contextRules[i].isApplicable(arguments.httpRequest)) {
				return contextRules[i].getContextName();
			}
		}

		return '';
	}

	private void function _loadParams() {


		var paramByIp = getParamsByIp();
		var ips = structKeyArray(paramByIp);
		for (var i = 1; i <= arrayLen(ips); i++) {
			if (ips[i] == getIp()) {
				structAppend(getParams(), paramByIp[ips[i]]);
			}
		}

		var paramsByEnv = getParamsByEnv();
		var envs = structKeyArray(paramsByEnv);
		for (i = 1; i <= arrayLen(envs); i++) {
			if (envs[i] == getEnv()) {
				structAppend(getParams(), paramsByEnv[envs[i]]);
			}
		}

		var paramsByHost = getParamsByHostname();
		var hosts = structKeyArray(paramsByHost);
		for (i = 1; i <= arrayLen(hosts); i++) {
			if (hosts[i] == CGI.SERVER_NAME) {
				structAppend(getParams(), paramsByHost[hosts[i]]);
			}
		}

	}

	public void function addEnvRule(required base.conf.elements.EnvRuleInterface envRule) {
		arrayAppend(getEnvRules(), arguments.envRule);
	}

	public void function addContextRule(required base.conf.elements.ContextRuleInterface contextRule) {
		arrayAppend(getContextRules(), arguments.contextRule);
	}

	public any function getParam(string name) {
		if (structKeyExists(getParams(), arguments.name)) {
			return getParams()[arguments.name];
		}
		return false;
	}

	public void function addParam(string name, any value) {
		var params = getParams();
		params[arguments.name] = arguments.value;
	}

	public void function addParamByIp(string ip, string name, any value) {
		var paramsByIp = getParamsByIp();
		if (!structKeyExists(paramsByIp, arguments.ip)) {
			paramsByIp[arguments.ip] = structNew();
		}

		paramsByIp[arguments.ip][arguments.name] = arguments.value;
	}

	public void function addParamByEnv(string env, string name, any value) {
		var paramsByEnv = getParamsByEnv();
		if (!structKeyExists(paramsByEnv, arguments.env)) {
			paramsByEnv[arguments.env] = structNew();
		}

		paramsByEnv[arguments.env][arguments.name] = arguments.value;
	}

	public void function addParamByHostname(string host, string name, any value) {
		var paramsByHost = getParamsByHostname();
		if (!structKeyExists(paramsByHost, arguments.host)) {
			paramsByHost[arguments.host] = structNew();
		}

		paramsByHost[arguments.host][arguments.name] = arguments.value;
	}

}