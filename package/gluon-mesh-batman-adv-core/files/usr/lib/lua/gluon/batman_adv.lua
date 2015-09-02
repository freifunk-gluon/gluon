local nixio = require 'nixio'

module 'gluon.batman_adv'

function interfaces(bat_if)
    local iter = nixio.fs.glob('/sys/class/net/' .. bat_if .. '/lower_*')
    return function()
            local path = iter()
            if path == nil then
                return nil
            end
            local ifname = path:match('/lower_([^/]+)$')
            return ifname
        end
end
