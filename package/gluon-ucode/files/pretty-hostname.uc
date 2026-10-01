'use strict';

import * as uci from 'uci';

let cursor = uci ? uci.cursor() : null;

export function get() {
	let hostname = null;
	
	cursor.load('system');
	cursor.foreach('system', 'system', (section) => {
		if (section.pretty_hostname) {
			hostname = section.pretty_hostname;
			return false;
		}

		hostname = section.hostname;
		return false;
	});

	return hostname;
}
