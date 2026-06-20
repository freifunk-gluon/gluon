# Config-mode preview

A static, browser-viewable rendering of Gluon's **config mode** (a.k.a. setup
mode) wizard, generated with **mock data** — no router, no flashing, no Lua
runtime needed to view it.

It exists so the wizard UI can be:

- **referred to** when discussing or reviewing changes (link to the hosted page),
- **eyeballed** while iterating on the theme/CSS or a wizard section,
- **published from CI** as a GitHub Pages artifact.

## How it works

`generate.lua` runs the **real** gluon-web model classes
(`package/gluon-web-model/.../model/classes.lua`) and the **real**
`config-mode/wizard/*.lua` section files from *every* package in the tree, against
small stubbed backends (uci, `gluon.site`, platform, …). It then walks the
resulting form tree and emits HTML that mirrors the gluon-web view templates.

Because it runs the same section discovery the router does
(`glob('/lib/gluon/config-mode/wizard/*')`, ordered by file name), **any package
that ships a wizard section — including plugins — shows up automatically**. The
output is paired with the unmodified `gluon.css` and `gluon-web-model.js`, so
dependency show/hide, field validation and dynamic lists behave exactly as on a
device.

The only hand-written surface is the small HTML emitter in `generate.lua`, which
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
`nix-shell -p lua5_1`. Output lands in `out/` (git-ignored):

```
out/
  index.html
  static/gluon.css            (copied verbatim from the theme package)
  static/gluon-web-model.js   (copied verbatim)
```

## Mock data

All the values a real router would read from uci/site live in the `MOCK` table at
the top of `generate.lua`. Tweak them to exercise different states, e.g.:

- `outdoor_device = true/false` — show/hide the outdoor plugin section,
- `mesh_vpn_provider = nil` — hide the mesh-VPN section,
- `uci["gluon.mesh_vpn.enabled"]`, `…limit_enabled` — pre-check the VPN flags,
- `site.config_mode.geo_location.show_altitude` — toggle the altitude field,
- `domains` — the list offered by domain-select.

## Caveats

- The OpenStreetMap map widget (`gluon-config-mode-geo-location-osm`) is **not**
  rendered; the latitude/longitude fields are. Everything else is faithful.
- Translations use the English source strings (plus a few mocked `gluon-site`
  keys); this is a layout/behaviour preview, not an i18n preview.
- The emitter mirrors the widget templates by hand. If those templates change,
  update `generate.lua` to match (the CI job and a glance at the page will make
  drift obvious).
