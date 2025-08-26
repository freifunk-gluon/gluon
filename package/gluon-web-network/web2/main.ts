import Uplink from './uplink.tsx'
import Interfaces from './interfaces.tsx'

window.RegisterModule({
  path: '/network/uplink',
  component: Uplink,
})

window.RegisterModule({
  path: '/network/interfaces',
  component: Interfaces,
})
