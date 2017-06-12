/*
	Copyright 2008 Steven Barth <steven@midlink.org>
	Copyright 2008-2012 Jo-Philipp Wich <jow@openwrt.org>
	Copyright 2017 Matthias Schiffer <mschiffer@universe-factory.net>

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0
*/

/*
	Build using:

	uglifyjs javascript/gluon-web.js -o files/lib/gluon/web/www/static/resources/gluon-web.js -c -m --support-ie8
*/



(function() {
	var dep_entries = {};

	function Int(x) {
		return (/^-?\d+$/.test(x) ? +x : NaN);
	}

	function Dec(x) {
		return (/^-?\d*\.?\d+?$/.test(x) ? +x : NaN);
	}

	var validators = {

		'integer': function() {
			return !isNaN(Int(this));
		},

		'uinteger': function() {
			return (Int(this) >= 0);
		},

		'float': function() {
			return !isNaN(Dec(this));
		},

		'ufloat': function() {
			return (Dec(this) >= 0);
		},

		'ipaddr': function() {
			return validators.ip4addr.apply(this) ||
				validators.ip6addr.apply(this);
		},

		'ip4addr': function() {
			var match;
			if ((match = this.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/))) {
				return (match[1] >= 0) && (match[1] <= 255) &&
				       (match[2] >= 0) && (match[2] <= 255) &&
				       (match[3] >= 0) && (match[3] <= 255) &&
				       (match[4] >= 0) && (match[4] <= 255);
			}

			return false;
		},

		'ip6addr': function() {
			if (this.indexOf('::') < 0)
				return (this.match(/^(?:[a-f0-9]{1,4}:){7}[a-f0-9]{1,4}$/i) != null);

			if (
				(this.indexOf(':::') >= 0) || this.match(/::.+::/) ||
				this.match(/^:[^:]/) || this.match(/[^:]:$/)
			)
				return false;

			if (this.match(/^(?:[a-f0-9]{0,4}:){2,7}[a-f0-9]{0,4}$/i))
				return true;
			if (this.match(/^(?:[a-f0-9]{1,4}:){7}:$/i))
				return true;
			if (this.match(/^:(?::[a-f0-9]{1,4}){7}$/i))
				return true;

			return false;
		},

		'wpakey': function() {
			var v = this;

			if (v.length == 64)
				return (v.match(/^[a-f0-9]{64}$/i) != null);
			else
				return (v.length >= 8) && (v.length <= 63);
		},

		'range': function(min, max)	{
			var val = Dec(this);
			return (val >= +min && val <= +max);
		},

		'min': function(min) {
			return (Dec(this) >= +min);
		},

		'max': function(max) {
			return (Dec(this) <= +max);
		},

		'irange': function(min, max) {
			var val = Int(this);
			return (val >= +min && val <= +max);
		},

		'imin': function(min) {
			return (Int(this) >= +min);
		},

		'imax': function(max)	{
			return (Int(this) <= +max);
		},

		'minlength': function(min) {
			return ((''+this).length >= +min);
		},

		'maxlength': function(max) {
			return ((''+this).length <= +max);
		},
	};

	function compile(type) {
		var v, match;
		if ((match = type.match(/^([^\(]+)\(([^,]+),([^\)]+)\)$/)) && (v = validators[match[1]]) !== undefined) {
			return function() {
				return v.apply(this, [match[2], match[3]]);
			}
		} else if ((match = type.match(/^([^\(]+)\(([^,\)]+)\)$/)) && (v = validators[match[1]]) !== undefined) {
			return function() {
				return v.apply(this, [match[2]]);
			}
		} else {
			return validators[type];
		}
	}

	function checkvalue(target, ref) {
		var t = document.getElementById(target);
		var value;

		if (t) {
			if (t.type == "checkbox") {
				value = t.checked;
			} else if (t.value) {
				value = t.value;
			} else {
				value = "";

			}
		}

		return (value == ref)
	}

	function check(deps) {
		for (var i=0; i < deps.length; i++) {
			var stat = true;

			for (var j in deps[i]) {
				stat = (stat && checkvalue(j, deps[i][j]));
			}

			if (stat)
				return true;
		}

		return false;
	}

	function update() {
		var state = false;
		for (var id in dep_entries) {
			var entry = dep_entries[id];
			var node  = document.getElementById(id);
			var parent = document.getElementById(entry.parent);

			if (node && node.parentNode && !check(entry.deps)) {
				node.parentNode.removeChild(node);
				state = true;
			} else if (parent && (!node || !node.parentNode) && check(entry.deps)) {
				var next = undefined;

				for (next = parent.firstChild; next; next = next.nextSibling) {
					if (next.getAttribute && parseInt(next.getAttribute('data-index'), 10) > entry.index) {
						break;
					}
				}

				if (!next) {
					parent.appendChild(entry.node);
				} else {
					parent.insertBefore(entry.node, next);
				}

				state = true;
			}

			// hide optionals widget if no choices remaining
			if (parent && parent.parentNode && parent.getAttribute('data-optionals'))
				parent.parentNode.style.display = (parent.options.length <= 1) ? 'none' : '';
		}

		if (state) {
			update();
		}
	}

	function bind(obj, type, callback, mode) {
		if (!obj.addEventListener) {
			obj.attachEvent('on' + type,
				function() {
					var e = window.event;

					if (!e.target && e.srcElement)
						e.target = e.srcElement;

					return !!callback(e);
				}
			);
		} else {
			obj.addEventListener(type, callback, !!mode);
		}
		return obj;
	}

	function init_dynlist(parent, datatype, optional) {
		var prefix = parent.getAttribute('data-prefix');
		var holder = parent.getAttribute('data-placeholder');


		function dynlist_redraw(focus, add, del) {
			var values = [];

			while (parent.firstChild) {
				var n = parent.firstChild;
				var i = +n.index;

				if (i != del) {
					if (n.nodeName.toLowerCase() == 'input')
						values.push(n.value || '');
					else if (n.nodeName.toLowerCase() == 'select')
						values[values.length-1] = n.options[n.selectedIndex].value;
				}

				parent.removeChild(n);
			}

			if (add >= 0) {
				focus = add + 1;
				values.splice(add, 0, '');
			} else if (!optional && values.length == 0) {
				values.push('');
			}

			for (var i = 1; i <= values.length; i++) {
				var t = document.createElement('input');
					t.id = prefix + '.' + i;
					t.name = prefix;
					t.value = values[i-1];
					t.type = 'text';
					t.index = i;
					t.className = 'gluon-input-text';

				if (holder)
					t.placeholder = holder;

				parent.appendChild(t);

				if (datatype)
					validate_field(t, false, datatype);

				bind(t, 'keydown',  dynlist_keydown);
				bind(t, 'keypress', dynlist_keypress);

				if (i == focus) {
					t.focus();
				} else if (-i == focus) {
					t.focus();

					/* force cursor to end */
					var v = t.value;
					t.value = ' '
					t.value = v;
				}

				if (optional || values.length > 1) {
					var b = document.createElement('span');
						b.className = 'gluon-remove';

					parent.appendChild(b);

					bind(b, 'click', dynlist_btnclick(false));

					parent.appendChild(document.createElement('br'));
				}
			}

			var b = document.createElement('span');
				b.className = 'gluon-add';

			parent.appendChild(b);

			bind(b, 'click', dynlist_btnclick(true));
		}

		function dynlist_keypress(ev) {
			ev = ev ? ev : window.event;

			var se = ev.target ? ev.target : ev.srcElement;

			if (se.nodeType == 3)
				se = se.parentNode;

			switch (ev.keyCode) {
				/* backspace, delete */
				case 8:
				case 46:
					if (se.value.length == 0) {
						if (ev.preventDefault)
							ev.preventDefault();

						return false;
					}

					return true;

				/* enter, arrow up, arrow down */
				case 13:
				case 38:
				case 40:
					if (ev.preventDefault)
						ev.preventDefault();

					return false;
			}

			return true;
		}

		function dynlist_keydown(ev) {
			ev = ev ? ev : window.event;

			var se = ev.target ? ev.target : ev.srcElement;

			var index = 0;
			var prev, next;

			if (se) {
				if (se.nodeType == 3)
					se = se.parentNode;

				index = se.index;

				prev = se.previousSibling;
				while (prev && prev.name != prefix)
					prev = prev.previousSibling;

				next = se.nextSibling;
				while (next && next.name != prefix)
					next = next.nextSibling;
			}

			switch (ev.keyCode) {
				/* backspace, delete */
				case 8:
				case 46:
					var del = (se.nodeName.toLowerCase() == 'select')
						? true : (se.value.length == 0);

					if (del) {
						if (ev.preventDefault)
							ev.preventDefault();

						var focus = se.index;
						if (ev.keyCode == 8)
							focus = -focus+1;

						dynlist_redraw(focus, -1, index);

						return false;
					}

					break;

				/* enter */
				case 13:
					dynlist_redraw(-1, index, -1);
					break;

				/* arrow up */
				case 38:
					if (prev)
						prev.focus();

					break;

				/* arrow down */
				case 40:
					if (next)
						next.focus();

					break;
			}

			return true;
		}

		function dynlist_btnclick(add) {
			return function(ev) {
				ev = ev ? ev : window.event;

				var se = ev.target ? ev.target : ev.srcElement;
				var input = se.previousSibling;
				while (input && input.name != prefix) {
					input = input.previousSibling;
				}

				if (add) {
					dynlist_keydown({
						target:  input,
						keyCode: 13
					});
				} else {
					input.value = '';

					dynlist_keydown({
						target:  input,
						keyCode: 8
					});
				}

				return false;
			}
		}

		dynlist_redraw(NaN, -1, -1);
	}

	function validate_field(field, optional, type) {
		var check = compile(type);
		if (!check)
			return;

		var validator = function() {
			if (!field.form)
				return;

			field.className = field.className.replace(/ gluon-input-invalid/g, '');

			var value = (field.options && field.options.selectedIndex > -1)
				? field.options[field.options.selectedIndex].value : field.value;

			if (!(((value.length == 0) && optional) || check.apply(value)))
				field.className += ' gluon-input-invalid';
		};

		bind(field, "blur",  validator);
		bind(field, "keyup", validator);

		if (field.nodeName == 'SELECT') {
			bind(field, "change", validator);
			bind(field, "click",  validator);
		}

		validator();
	}

	function add(obj, dep, index) {
		var entry = dep_entries[obj.id];
		if (!entry) {
			entry = {
				"node": obj,
				"parent": obj.parentNode.id,
				"deps": [],
				"index": index
			};
			dep_entries[obj.id] = entry;
		}
		entry.deps.push(dep)
	}

	(function() {
		var nodes;

		nodes = document.querySelectorAll('[data-depends]');

		for (var i = 0, node; (node = nodes[i]) !== undefined; i++) {
			var index = parseInt(node.getAttribute('data-index'), 10);
			var depends = JSON.parse(node.getAttribute('data-depends'));
			if (!isNaN(index) && depends.length > 0) {
				for (var alt = 0; alt < depends.length; alt++) {
					add(node, depends[alt], index);
				}
			}
		}

		nodes = document.querySelectorAll('[data-update]');

		for (var i = 0, node; (node = nodes[i]) !== undefined; i++) {
			var events = node.getAttribute('data-update').split(' ');
			for (var j = 0, event; (event = events[j]) !== undefined; j++) {
				bind(node, event, update);
			}
		}

		nodes = document.querySelectorAll('[data-type]');

		for (var i = 0, node; (node = nodes[i]) !== undefined; i++) {
			validate_field(node, node.getAttribute('data-optional') === 'true',
			                   node.getAttribute('data-type'));
		}

		nodes = document.querySelectorAll('[data-dynlist]');

		for (var i = 0, node; (node = nodes[i]) !== undefined; i++) {
			var list = JSON.parse(node.getAttribute('data-dynlist'));

			init_dynlist(node, list.type, list.optional);
		}

		update();
	})();
})();
