# Config-mode preview

A static, browser-viewable rendering of Gluon's **config mode** (a.k.a. setup
mode) — the setup **wizard** *and* the **Advanced settings** pages (network,
WLAN, remote access / SSH keys, automatic updates, node role, …) — generated
with **mock data**. No router, no flashing, no Lua runtime needed to view it.

It exists so config mode can be:

- **referred to** when discussing or reviewing changes (link to the hosted page),
- **eyeballed** while iterating on the theme/CSS or a model/section,
- **published from CI** as a GitHub Pages artifact.

## How it works

Config mode is a tree of pages registered by `entry()` controllers (the wizard
is just one such page). `generate.lua`:

1. runs the **real** controllers from every package to build the same
   navigation tree the dispatcher builds;
2. for each `model()` entry, runs the **real** model file (and, for the wizard,
   every package's `config-mode/wizard/*.lua` section) against small stubbed
   backends (uci, `gluon.site`, platform, wireless, …);
3. walks each resulting form tree and emits HTML mirroring the gluon-web view
   templates, writing **one HTML file per page** with a working menu.

Because it uses the same controller/model/section discovery the router does,
**any package — including plugins — that registers config-mode pages shows up
automatically**. The output is paired with the unmodified `gluon.css` and
`gluon-web-model.js`, so dependency show/hide, validation, dynamic lists and the
menu behave as on a device.

Pages that genuinely need live device state and fail to render **degrade to a
placeholder** (with the error) rather than breaking the whole site — so one
hardware-bound plugin can't take the preview down.

The only hand-written surface is the HTML emitter in `generate.lua`, which
mirrors the (rarely-changing) widget templates in
`package/gluon-web-model/files/lib/gluon/web/view/model/`.

## Usage

From anywhere:

```sh
contrib/config-mode-preview/build.sh
python3 -m http.server -d contrib/config-mode-preview/out 8000
# open http://localhost:8000/
```

`build.sh` uses `lua`/`lua5.1` if present, otherwise falls back to
`nix-shell -p lua5_1`. Output lands in `out/` (git-ignored): `index.html`
(redirects to the wizard), one `*.html` per page, and `static/` holding the
verbatim `gluon.css` and `gluon-web-model.js`.

## Mock data

All the values a real router would read from uci/site live in the `MOCK`,
`MOCK.site` and `MOCK_UCI` tables at the top of `generate.lua`. Tweak them to
exercise different states, e.g.:

- `outdoor_device` / `cellular_device` — gate the outdoor section / cellular page,
- `mesh_vpn_provider = nil` — hide the wizard's mesh-VPN section,
- `MOCK_UCI.network.wan.proto = "static"` — reveal the static WAN address fields,
- `MOCK.site.roles.list` — the roles offered on the Node role page,
- `MOCK.domains` — the list offered by domain-select.

## Caveats

- `template()` pages (e.g. Information) and `call()` actions (firmware upgrade)
  are shown in the navigation as **placeholders** — they render device-side
  templates/actions outside this static preview's scope.
- The WLAN page is rendered against **mock radios** (one 2.4 GHz, one 5 GHz)
  with representative txpower/HT-mode lists, since real values come from
  `iwinfo` on the device.
- The OpenStreetMap map widget (geo-location) is not rendered; its lat/lon
  fields are.
- Translations use the English source strings (plus a few mocked `gluon-site`
  keys); this is a layout/behaviour preview, not an i18n preview.
- The emitter mirrors the widget templates by hand. If those templates change,
  update `generate.lua` to match (the CI job and a glance at the pages make
  drift obvious).
