import { Fragment, h } from "preact";
import { useState } from 'preact/hooks';

import Components from "./components"

const GluonWeb2 = ({ id, component, data: initialData }: { id: string, component: string, data: any }) => {
  let { data, setData } = useState<any>({ "phy_interfaces": ["wan", "lan4", "lan2", "lan3", "lan1"], "uci": [{ ".name": "iface_wan", ".type": "interface", "name": "\\/wan", "role": ["nothing"], ".anonymous": false, ".index": 1 }, { ".name": "iface_lan", ".type": "interface", "name": "\\/lan", "role": ["uplink"], ".anonymous": false, ".index": 2 }, { ".name": "iface_wan_vlan11", ".type": "interface", "name": "wan.11", "role": ["mesh"], ".anonymous": false, ".index": 5 }, { ".name": "iface_lan1_vlan255", ".type": "interface", "name": "lan1.255", "role": ["mesh"], ".anonymous": false, ".index": 6 }, { ".name": "iface_lan2_vlan255", ".type": "interface", "name": "lan2.255", "role": ["mesh"], ".anonymous": false, ".index": 7 }, { ".name": "iface_lan3_vlan255", ".type": "interface", "name": "lan3.255", "role": ["mesh"], ".anonymous": false, ".index": 8 }, { ".name": "iface_lan4_vlan255", ".type": "interface", "name": "lan4.255", "role": ["mesh"], ".anonymous": false, ".index": 9 }, { ".name": "iface_lan1_vlan3", ".type": "interface", "name": "lan1.3", "role": ["client"], ".anonymous": false, ".index": 10 }, { ".name": "iface_lan2_vlan3", ".type": "interface", "name": "lan2.3", "role": ["client"], ".anonymous": false, ".index": 11 }, { ".name": "iface_lan3_vlan3", ".type": "interface", "name": "lan3.3", "role": ["client"], ".anonymous": false, ".index": 12 }, { ".name": "iface_lan4_vlan3", ".type": "interface", "name": "lan4.3", "role": ["client"], ".anonymous": false, ".index": 13 }] })

  data = { "phy_interfaces": ["wan", "lan4", "lan2", "lan3", "lan1"], "uci": [{ ".name": "iface_wan", ".type": "interface", "name": "\\/wan", "role": ["nothing"], ".anonymous": false, ".index": 1 }, { ".name": "iface_lan", ".type": "interface", "name": "\\/lan", "role": ["uplink"], ".anonymous": false, ".index": 2 }, { ".name": "iface_wan_vlan11", ".type": "interface", "name": "wan.11", "role": ["mesh"], ".anonymous": false, ".index": 5 }, { ".name": "iface_lan1_vlan255", ".type": "interface", "name": "lan1.255", "role": ["mesh"], ".anonymous": false, ".index": 6 }, { ".name": "iface_lan2_vlan255", ".type": "interface", "name": "lan2.255", "role": ["mesh"], ".anonymous": false, ".index": 7 }, { ".name": "iface_lan3_vlan255", ".type": "interface", "name": "lan3.255", "role": ["mesh"], ".anonymous": false, ".index": 8 }, { ".name": "iface_lan4_vlan255", ".type": "interface", "name": "lan4.255", "role": ["mesh"], ".anonymous": false, ".index": 9 }, { ".name": "iface_lan1_vlan3", ".type": "interface", "name": "lan1.3", "role": ["client"], ".anonymous": false, ".index": 10 }, { ".name": "iface_lan2_vlan3", ".type": "interface", "name": "lan2.3", "role": ["client"], ".anonymous": false, ".index": 11 }, { ".name": "iface_lan3_vlan3", ".type": "interface", "name": "lan3.3", "role": ["client"], ".anonymous": false, ".index": 12 }, { ".name": "iface_lan4_vlan3", ".type": "interface", "name": "lan4.3", "role": ["client"], ".anonymous": false, ".index": 13 }] }

  const Comp = Components[component]

  return (
    <Fragment>
      <input type="text" style="display: none" name={id} value={JSON.stringify(data)} />,
      <Comp data={data} setData={setData} />
    </Fragment>
  )
}

export default GluonWeb2;
