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

	property type="struct" name="chronos";

	public cffwk.model.Chrono function init() {
		variables.chronos = structNew();
		return this;
	}

	public void function reset() {
		variables.chronos = structNew();
	}

	public void function start(required string name) {
		variables.chronos[arguments.name] = structNew();
		variables.chronos[arguments.name].name = arguments.name;
		variables.chronos[arguments.name].start = getTickCount();
	}

	public string function end(required string name) {
		var timer = variables.chronos[arguments.name];
		timer.end = getTickCount();
		timer.time = timer.end - timer.start;
		variables.chronos[arguments.name] = timer;
	}

	public struct function getOrderedResults() {
		var ordered = structNew();
		var timers = structKeyArray(variables.chronos);

		for (var i = 1; i <= arrayLen(timers); i++) {
			var curTimer = variables.chronos[timers[i]];
			ordered[curTimer.start & i] = curTimer;
		}

		return ordered;
	}

	public void function printResults() output=true {
		var ordered = getOrderedResults();
		var timeKeys = structKeyArray(ordered);
		arraySort(timeKeys, 'numeric');
		var oldTime = 0;

		var out = '<table style="cellspacing: 3px; cellspadding: 1px;">';
		out &= '<tr><th>Name</th><th>Time</th><th>Before</th></tr>';

		for (var i = 1; i <= arrayLen(timeKeys); i++) {
			var curTimer = ordered[timeKeys[i]];

			out &= '<tr>';
			out &= '<td>' & curTimer.name & '</td>';
			out &= '<td>' & curTimer.time & '</td>';

			if (oldTime > 0 && oldTime <= curTimer.start) {
				out &= '<td>' & (curTimer.start - oldTime) & '</td>';

			} else {
				out &= '<td />';
			}

			out &= '</tr>';

			oldTime = curTimer.end;
		}

		out &= '</table>';
		writeOutput(out);
	}

}