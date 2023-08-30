/*
	Build using:

	uglifyjs javascript/status-page.js -o javascript/status-page.min.js -c -m
*/

'use strict';

(function() {
	const interfaces = {};
	const _ = JSON.parse(document.body.getAttribute('data-translations'));

	String.prototype.sprintf = function() {
		let i = 0;
		const args = arguments;

		return this.replace(/%s/g, function() {
			return args[i++];
		});
	};

	function formatNumberFixed(d, digits) {
		return d.toFixed(digits).replace(/\./, _['.'])
	}

	function formatNumber(d, digits) {
		digits--;

		for (let v = d; v >= 10 && digits > 0; v /= 10)
			digits--;

		// avoid toPrecision as it might produce strings in exponential notation
		return formatNumberFixed(d, digits);
	}

	function prettyPackets(d) {
		return _['%s packets/s'].sprintf(formatNumberFixed(d, 0));
	}

	function prettyPrefix(prefixes, step, d) {
		let prefix = 0;

		if (d === undefined)
			return '- ';

		while (d > step && prefix < prefixes.length - 1) {
			d /= step;
			prefix++;
		}

		d = formatNumber(d, 3);
		return d + ' ' + prefixes[prefix];
	}

	function prettySize(d) {
		return prettyPrefix([ '', 'K', 'M', 'G', 'T' ], 1024, d);
	}

	function prettyBits(d) {
		return prettySize(8 * d) + 'bps';
	}

	function prettyBytes(d) {
		return prettySize(d) + 'B';
	}

	const formats = {
		'id': function(value) {
			return value;
		},
		'decimal': function(value) {
			return formatNumberFixed(value, 2);
		},
		'percent': function(value) {
			return _['%s used'].sprintf(formatNumber(100 * value, 3) + '%');
		},
		'memory': function(memory) {
			const usage = 1 - memory.available / memory.total;
			return formats.percent(usage);
		},
		'time': function(seconds) {
			let minutes = Math.round(seconds / 60);

			const days = Math.floor(minutes / 1440);
			const hours = Math.floor((minutes % 1440) / 60);
			minutes = Math.floor(minutes % 60);

			let out = '';

			if (days === 1)
				out += _['1 day'] + ', ';
			else if (days > 1)
				out += _['%s days'].sprintf(days) + ', ';

			out += hours + ':';

			if (minutes < 10)
				out += '0';

			out += minutes;

			return out;
		},
		'packetsDiff': function(packets, packetsPrev, diff) {
			if (diff > 0)
				return prettyPackets((packets - packetsPrev) / diff);

		},
		'bytesDiff': function(bytes, bytesPrev, diff) {
			if (diff > 0)
				return prettyBits((bytes - bytesPrev) / diff);
		},
		'bytes': function(bytes) {
			return prettyBytes(bytes);
		},
		'neighbour': function(addr) {
			if (!addr)
				return '';

			for (const i in interfaces) {
				const iface = interfaces[i];
				const neigh = iface.lookup_neigh(addr);
				if (!neigh)
					continue;

				const span = document.createElement('span');
				span.appendChild(document.createTextNode('via '));
				const a = document.createElement('a');
				a.href = 'http://[' + neigh.get_addr() + ']/';
				a.textContent = neigh.get_hostname();
				span.appendChild(a);
				span.appendChild(document.createTextNode(' (' + i + ')'));
				return span;
			}

			return 'via ' + addr + ' (unknown iface)';
		},
		'tq': function(value) {
			return formatNumber(100/255 * value, 1) + '%';
		}
	};


	function resolve_key(obj, key) {
		key.split('/').forEach(function(part) {
			if (obj)
				obj = obj[part];
		});

		return obj;
	}

	function add_event_source(url, handler) {
		const source = new EventSource(url);
		let prev = {};
		source.onmessage = function(m) {
			const data = JSON.parse(m.data);
			handler(data, prev);
			prev = data;
		}
		source.onerror = function() {
			source.close();
			window.setTimeout(function() {
				add_event_source(url, handler);
			}, 3000);
		}
	}

	const node_address = document.body.getAttribute('data-node-address');

	let location;
	try {
		location = JSON.parse(document.body.getAttribute('data-node-location'));
	} catch (e) {
		console.error(e);
	}


	function update_mesh_vpn(data) {
		function add_group(peers, d) {
			Object.keys(d.peers || {}).forEach(function(peer) {
				peers.push([peer, d.peers[peer]]);
			});

			Object.keys(d.groups || {}).forEach(function(group) {
				add_group(peers, d.groups[group]);
			});

			return peers;
		}

		const div = document.getElementById('mesh-vpn');
		if (!data) {
			div.style.display = 'none';
			return;
		}

		div.style.display = '';
		const tbody = document.getElementById('mesh-vpn-peers');
		while (tbody.lastChild)
			tbody.removeChild(tbody.lastChild);

		const peers = add_group([], data);
		peers.sort();

		peers.forEach(function(peer) {
			const tr = document.createElement('tr');

			const th = document.createElement('th');
			th.textContent = peer[0];
			tr.appendChild(th);

			const td = document.createElement('td');
			if (peer[1] && peer[1].established != null)
				td.textContent = _['connected'] + ' (' + formats.time(peer[1].established) + ')';
			else
				td.textContent = _['not connected'];
			tr.appendChild(td);

			tbody.appendChild(tr);
		});
	}

	const statisticsElems = document.querySelectorAll('[data-statistics]');

	add_event_source('/cgi-bin/dyn/statistics', function(data, dataPrev) {
		const diff = data.uptime - dataPrev.uptime;

		statisticsElems.forEach(function(elem) {
			const stat = elem.getAttribute('data-statistics');
			const format = elem.getAttribute('data-format');

			const valuePrev = resolve_key(dataPrev, stat);
			const value = resolve_key(data, stat);
			try {
				const format_result = formats[format](value, valuePrev, diff);
				switch (typeof format_result) {
					case 'object':
						if (elem.lastChild)
							elem.removeChild(elem.lastChild);
						elem.appendChild(format_result);
						break;
					default:
						elem.textContent = format_result;
				}
			} catch (e) {
				console.error(e);
			}
		});

		try {
			update_mesh_vpn(data.mesh_vpn);
		} catch (e) {
			console.error(e);
		}
	})

	function haversine(lat1, lon1, lat2, lon2) {
		const rad = Math.PI / 180;
		lat1 *= rad; lon1 *= rad; lat2 *= rad; lon2 *= rad;

		const R = 6372.8; // km
		const dLat = lat2 - lat1;
		const dLon = lon2 - lon1;
		const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2);
		const c = 2 * Math.asin(Math.sqrt(a));
		return R * c;
	}

	function Signal(color) {
		const canvas = document.createElement('canvas');
		const ctx = canvas.getContext('2d', {willReadFrequently: true});
		let value = null;
		const radius = 1.2;

		function drawPixel(x, y) {
			ctx.beginPath();
			ctx.fillStyle = color;
			ctx.arc(x, y, radius, 0, 2 * Math.PI, false);
			ctx.closePath();
			ctx.fill();
		}

		return {
			'canvas': canvas,
			'highlight': false,

			'resize': function(w, h) {
				let lastImage;
				try {
					lastImage = ctx.getImageData(0, 0, w, h);
				} catch (e) {
					console.error(e);
				}
				canvas.width = w;
				canvas.height = h;
				if (lastImage)
					ctx.putImageData(lastImage, 0, 0);
			},

			'draw': function(x, scale) {
				const y = scale(value);

				ctx.clearRect(x, 0, 5, canvas.height)

				if (y)
					drawPixel(x, y)
			},

			'set': function(d) {
				value = d;
			},
		};
	}

	function SignalGraph() {
		const min = -100, max = 0;
		let i = 0;

		const signals = [];

		const canvas = document.createElement('canvas');
		canvas.className = 'signalgraph';
		canvas.height = 200;

		const ctx = canvas.getContext('2d');

		function scaleInverse(n, min, max, height) {
			return (min * n + max * (height - n)) / height;
		}

		function scale(n, min, max, height) {
			return (1 - (n - min) / (max - min)) * height;
		}

		function drawGrid() {
			const nLines = Math.floor(canvas.height / 40);
			ctx.save();
			ctx.lineWidth = 0.5;
			ctx.strokeStyle = 'rgba(0, 0, 0, 0.25)';
			ctx.fillStyle = 'rgba(0, 0, 0, 0.5)';
			ctx.textAlign = 'end';
			ctx.textBaseline = 'bottom';

			ctx.beginPath();

			for (let i = 0; i < nLines; i++) {
				const y = canvas.height - i * 40;
				ctx.moveTo(0, y - 0.5);
				ctx.lineTo(canvas.width, y - 0.5);
				const dBm = Math.round(scaleInverse(y, min, max, canvas.height)) + ' dBm';

				ctx.save();
				ctx.strokeStyle = 'rgba(255, 255, 255, 0.9)';
				ctx.lineWidth = 4;
				ctx.miterLimit = 2;
				ctx.strokeText(dBm, canvas.width - 5, y - 2.5);
				ctx.fillText(dBm, canvas.width - 5, y - 2.5);
				ctx.restore();
			}

			ctx.stroke();

			ctx.strokeStyle = 'rgba(0, 0, 0, 0.83)';
			ctx.lineWidth = 1.5;
			ctx.strokeRect(0.5, 0.5, canvas.width - 1, canvas.height - 1);

			ctx.restore();
		}

		function resize() {
			canvas.width = canvas.clientWidth;
			signals.forEach(function(signal) {
				signal.resize(canvas.width, canvas.height);
			});
		}
		resize();

		function draw() {
			if (canvas.clientWidth === 0)
				return;

			if (canvas.width !== canvas.clientWidth)
				resize();

			ctx.clearRect(0, 0, canvas.width, canvas.height);

			let highlight = false;
			signals.forEach(function(signal) {
				if (signal.highlight)
					highlight = true;
			});

			ctx.save();
			signals.forEach(function(signal) {
				if (highlight)
					ctx.globalAlpha = 0.2;

				if (signal.highlight)
					ctx.globalAlpha = 1;

				signal.draw(i, function(value) {
					return scale(value, min, max, canvas.height);
				});
				ctx.drawImage(signal.canvas, 0, 0);
			});
			ctx.restore();

			ctx.save();
			ctx.beginPath();
			ctx.strokeStyle = 'rgba(255, 180, 0, 0.15)';
			ctx.lineWidth = 5;
			ctx.moveTo(i + 2.5, 0);
			ctx.lineTo(i + 2.5, canvas.height);
			ctx.stroke();

			drawGrid();
		}

		window.addEventListener('resize', draw);

		let last = 0;

		function step(timestamp) {
			const delta = timestamp - last;

			if (delta > 40) {
				draw();
				i = (i + 1) % canvas.width;
				last = timestamp;
			}

			window.requestAnimationFrame(step);
		}

		window.requestAnimationFrame(step);

		return {
			'el': canvas,

			'addSignal': function(signal) {
				signals.push(signal);
				signal.resize(canvas.width, canvas.height);
			},

			'removeSignal': function(signal) {
				signals.splice(signals.indexOf(signal), 1);
			},
		};
	}

	function Neighbour(iface, addr, color, destroy) {
		const th = iface.tbody.querySelector('tr');
		const el = iface.tbody.insertRow();

		const tdHostname = el.insertCell();
		tdHostname.setAttribute('data-label', th.children[0].textContent);

		if (iface.wireless) {
			const marker = document.createElement('span');
			marker.textContent = '⬤ ';
			marker.style.color = color;
			tdHostname.appendChild(marker);
		}

		let hostname = document.createElement('span');
		hostname.textContent = addr;
		tdHostname.appendChild(hostname);

		const meshAttrs = {};

		function add_attr(attr) {
			const key = attr.getAttribute('data-key');
			if (!key)
				return;

			const suffix = attr.getAttribute('data-suffix') || '';

			const td = el.insertCell();
			td.textContent = '-';
			td.setAttribute('data-label', attr.textContent);

			meshAttrs[key] = {
				'td': td,
				'suffix': suffix,
			};
		}

		for (let i = 0; i < th.children.length; i++) {
			add_attr(th.children[i]);
		}

		let tdSignal;
		let tdDistance;
		let tdInactive;
		let signal;

		if (iface.wireless) {
			tdSignal = el.insertCell();
			tdSignal.textContent = '-';
			tdSignal.setAttribute(
				'data-label',
				th.children[Object.keys(meshAttrs).length + 1].textContent
			);

			tdDistance = el.insertCell();
			tdDistance.textContent = '-';
			tdDistance.setAttribute(
				'data-label',
				th.children[Object.keys(meshAttrs).length + 2].textContent
			);

			tdInactive = el.insertCell();
			tdInactive.textContent = '-';
			tdInactive.setAttribute(
				'data-label',
				th.children[Object.keys(meshAttrs).length + 3].textContent
			);

			signal = Signal(color);
			iface.signalgraph.addSignal(signal);
		}

		el.onmouseenter = function() {
			el.classList.add('highlight');
			if (signal)
				signal.highlight = true;
		};

		el.onmouseleave = function() {
			el.classList.remove('highlight');
			if (signal)
				signal.highlight = false;
		};

		let timeout;

		function updated() {
			if (timeout)
				window.clearTimeout(timeout);

			timeout = window.setTimeout(function() {
				if (signal)
					iface.signalgraph.removeSignal(signal);

				el.parentNode.removeChild(el);
				destroy();
			}, 60000);
		}
		updated();

		function address_to_groups(addr) {
			if (addr.slice(0, 2) === '::')
				addr = '0' + addr;
			if (addr.slice(-2) === '::')
				addr = addr + '0';

			const parts = addr.split(':');
			let n = parts.length;
			/** @type number[] **/
			const groups = [];

			for (let i = 0; i < parts.length; i++) {
				const part = parts[i];
				if (part === '') {
					while (n++ <= 8)
						groups.push(0);
				} else {
					if (!/^[a-f0-9]{1,4}$/i.test(part))
						return;

					groups.push(parseInt(part, 16));
				}
			}

			return groups;
		}

		function address_to_binary(addr) {
			const groups = address_to_groups(addr);
			if (!groups)
				return;

			let ret = '';
			groups.forEach(function(group) {
				ret += ('0000000000000000' + group.toString(2)).slice(-16);
			});

			return ret;
		}

		function common_length(a, b) {
			const maxLength = Math.min(a.length, b.length);
			for (let i = 0; i < maxLength; i++) {
				if(a[i] !== b[i])
					return i;
			}
			return maxLength;
		}

		function choose_address(addresses) {
			const node_bin = address_to_binary(node_address);

			if (!addresses || !addresses[0])
				return;

			addresses = addresses.map(function(addr) {
				const addr_bin = address_to_binary(addr);
				if (!addr_bin)
					return [-1];

				let common_prefix = 0;
				if (node_bin)
					common_prefix = common_length(node_bin, addr_bin);

				return [common_prefix, addr_bin, addr];
			});

			addresses.sort(function(a, b) {
				if (a[0] < b[0])
					return 1;
				else if (a[0] > b[0])
					return -1;
				else if (a[1] < b[1])
					return -1;
				else if (a[1] > b[1])
					return 1;
				else
					return 0;

			});

			const address = addresses[0][2];
			if (address && !/^fe80:/i.test(address))
				return address;
		}

		return {
			'get_hostname': function() {
				return hostname.textContent;
			},
			'get_addr': function() {
				return addr;
			},
			'update_nodeinfo': function(nodeinfo) {
				addr = choose_address(nodeinfo.network.addresses);
				if (addr) {
					if (hostname.nodeName.toLowerCase() === 'span') {
						const oldHostname = hostname;
						hostname = document.createElement('a');
						oldHostname.parentNode.replaceChild(hostname, oldHostname);
					}

					hostname.href = 'http://[' + addr + ']/';
				}

				hostname.textContent = nodeinfo.hostname;

				if (location && nodeinfo.location) {
					const distance = haversine(
						location.latitude, location.longitude,
						nodeinfo.location.latitude, nodeinfo.location.longitude
					);
					tdDistance.textContent = Math.round(distance * 1000) + ' m'
				}

				updated();
			},
			'update_mesh': function(mesh) {
				Object.keys(meshAttrs).forEach(function(key) {
					const attr = meshAttrs[key];
					attr.td.textContent = mesh[key] + attr.suffix;
				});

				updated();
			},
			'update_wifi': function(wifi) {
				const inactiveLimit = 200;

				tdSignal.textContent = wifi.signal;
				tdInactive.textContent = Math.round(wifi.inactive / 1000) + ' s';

				el.classList.toggle('inactive', wifi.inactive > inactiveLimit);
				signal.set(wifi.inactive > inactiveLimit ? null : wifi.signal);

				updated();
			},
		};
	}

	function Interface(el, ifname, wireless) {
		const neighs = {};

		let signalgraph;
		if (wireless) {
			signalgraph = SignalGraph();
			el.appendChild(signalgraph.el);
		}

		const info = {
			'tbody': el.querySelector('tbody'),
			'signalgraph': signalgraph,
			'ifname': ifname,
			'wireless': wireless,
		};

		let nodeinfo_running = false;
		const want_nodeinfo = {};

		let graphColors = [];
		function get_color() {
			if (!graphColors[0])
				graphColors = ['#396AB1', '#DA7C30', '#3E9651', '#CC2529', '#535154', '#6B4C9A', '#922428', '#948B3D'];

			return graphColors.shift();
		}

		function neigh_addresses(nodeinfo) {
			const addrs = [];

			const mesh = nodeinfo.network.mesh;
			Object.keys(mesh).forEach(function(meshif) {
				const ifaces = mesh[meshif].interfaces;
				Object.keys(ifaces).forEach(function(ifaceType) {
					ifaces[ifaceType].forEach(function(addr) {
						addrs.push(addr);
					});
				});
			});

			return addrs;
		}

		function load_nodeinfo() {
			if (nodeinfo_running)
				return;

			nodeinfo_running = true;

			const source = new EventSource('/cgi-bin/dyn/neighbours-nodeinfo?' + encodeURIComponent(ifname));
			source.addEventListener('neighbour', function(m) {
				try {
					const data = JSON.parse(m.data);
					neigh_addresses(data).forEach(function(addr) {
						const neigh = neighs[addr];
						if (neigh) {
							delete want_nodeinfo[addr];
							try {
								neigh.update_nodeinfo(data);
							} catch (e) {
								console.error(e);
							}
						}
					});
				} catch (e) {
					console.error(e);
				}
			}, false);

			source.onerror = function() {
				source.close();
				nodeinfo_running = false;

				Object.keys(want_nodeinfo).forEach(function(addr) {
					if (want_nodeinfo[addr] > 0) {
						want_nodeinfo[addr]--;
						load_nodeinfo();
					}
				});
			}
		}

		function lookup_neigh(addr) {
			return neighs[addr];
		}

		function get_neigh(addr) {
			let neigh = neighs[addr];
			if (!neigh) {
				want_nodeinfo[addr] = 3;
				neigh = neighs[addr] = Neighbour(info, addr, get_color(), function() {
					delete want_nodeinfo[addr];
					delete neighs[addr];
				});
				load_nodeinfo();
			}

			return neigh;
		}

		if (wireless) {
			add_event_source('/cgi-bin/dyn/stations?' + encodeURIComponent(ifname), function(data) {
				Object.keys(data).forEach(function(addr) {
					const wifi = data[addr];

					get_neigh(addr).update_wifi(wifi);
				});
			});
		}

		return {
			'get_neigh': get_neigh,
			'lookup_neigh': lookup_neigh
		};
	}

	document.querySelectorAll('[data-interface]').forEach(function(elem) {
		const ifname = elem.getAttribute('data-interface');
		const wireless = !!elem.getAttribute('data-interface-wireless');

		interfaces[ifname] = Interface(elem, ifname, wireless);
	});

	const mesh_provider = document.body.getAttribute('data-mesh-provider');
	if (mesh_provider) {
		add_event_source(mesh_provider, function(data) {
			Object.keys(data).forEach(function(addr) {
				const mesh = data[addr];
				const iface = interfaces[mesh.ifname];
				if (!iface)
					return;

				iface.get_neigh(addr).update_mesh(mesh);
			});
		});
	}
})();
