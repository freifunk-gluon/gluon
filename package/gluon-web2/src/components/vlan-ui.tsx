import { h } from "preact";

const ROLES = {
  'uplink': 'Uplink',
  'mesh': 'Mesh',
  'client': 'Client'
}

const VlanUI = ({ data, setData }: { data: any, setData: (data: any) => void }) => {
  /* return data.uci.map(intf => {
    (
      <div>
        <label class="gluon-value-title" for="id.1.4.iface_wan_vlan11">{intf.name}</label>
        <div class="gluon-value-field">
          <div>

          <label data-index="1">
            {(intf.roles ?? [])}
            <input data-update="click change" type="checkbox" id="id.1.4.iface_wan_vlan11.uplink" name="id.1.4.iface_wan_vlan11" value="uplink" data-exclusive-with="[&#34;client&#34;]" data-update="change">
              <label for="id.1.4.iface_wan_vlan11.uplink"></label>
              <span class="gluon-multi-list-option-descr">Uplink</span>
  		      </label>
            &#160;&#160;&#160;

  		<label data-index="2">
              <input data-update="click change" type="checkbox" id="id.1.4.iface_wan_vlan11.mesh" name="id.1.4.iface_wan_vlan11" value="mesh" checked="checked" data-exclusive-with="[&#34;client&#34;]" data-update="change">
                <label for="id.1.4.iface_wan_vlan11.mesh"></label>
                <span class="gluon-multi-list-option-descr">Mesh</span>
  		</label>
              &#160;&#160;&#160;

  		<label data-index="3">
                <input data-update="click change" type="checkbox" id="id.1.4.iface_wan_vlan11.client" name="id.1.4.iface_wan_vlan11" value="client" data-exclusive-with="[&#34;uplink&#34;,&#34;mesh&#34;]" data-update="change">
                  <label for="id.1.4.iface_wan_vlan11.client"></label>
                  <span class="gluon-multi-list-option-descr">Client</span>
  		</label>


  </div>

              )
  }) */

  return <h1>VLANUI {JSON.stringify(data)}</h1>
};

export default VlanUI;
