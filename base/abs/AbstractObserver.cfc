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

	public cffwk.base.abs.AbstractObserver function init(cffwk.base.abs.AbstractObservable observable) {
		if (!isNull(variables.observable)) {
			register(arguments.observable);
		}

		return this;
	}

	public void function register(required cffwk.base.abs.AbstractObservable observable) {
		variables.observable = arguments.observable;
		arguments.observable.registerObserver(this);
	}

	public void function notify() {
		writeOutput('Notification recieved from observable object ' & getComponentMetaData(variables.observable).fullName);
	}

}