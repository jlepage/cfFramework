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
component abstract='true' output='false' accessors='true' {

	property type="array" name="observers";

	public cffwk.base.abs.AbstractObservable function init() {
		variables.observers = arrayNew(1);
		return this;
	}

	public void function registerObserver(cffwk.base.abs.AbstractObserver observer) {
		arrayAppend(variables.observers, arguments.observer);
	}

	package void function notifyObservers(struct parameters = {}) {
		for (var i = 1; i <= arrayLen(variables.observers); i++) {
			variables.observers[i].notify(arguments.parameters);
		}
	}

}