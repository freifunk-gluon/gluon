local pkg_i18n = i18n 'gluon-config-mode-autoupdater-freifunk'
local site_i18n = i18n 'gluon-site'

local uci = require("simple-uci").cursor()
local autoupdater = uci:get_first("autoupdater", "autoupdater")


local consent = uci:get_bool("autoupdater-freifunk", "consent", "given")
local enabled = uci:get_bool("autoupdater", "settings", "enabled")

-- Usually, the form is active and users can make a choice regarding constent
-- One exception: Automatic Updates are enabled by default without given consent

-- This exception is based in the idea expressed in the discussion for bug #1618: To be compatible
-- with existing installation, Automatic updates can be enabled network-wide without asking users for consent
-- This is relevant, for networks using automatic updates, only.
local formActive = true

-- Usually, giving consent to automatic updates enables automatic updates. (as expected by users)
-- Again, there's one exception: If automatic updates are disabled, but consent is given, then we don't
-- enable automatic updates (since the question is already answered) - a message is shown instead
local changeAutomaticUpdates = true

local storedValue = uci:get("autoupdater-freifunk", "consent", "given")

-- By default, it is assmed, that out of band consent is not given.
local warningMsg = ''
if enabled and  not consent then
    warningMsg = site_i18n._translate('autoupdater-freifunk:constent_assumed_admin') or pkg_i18n.translate('<p />'
            .. ' <span style="color:red">You have already agreed to remote maintenance via automatic'
            .. ' upgrades by downloading and using this software. <br /> You can disable automatic updates by selecting no branch. </span>')
    formActive = false
end

if not enabled and consent then
    warningMsg = site_i18n._translate('autoupdater-freifunk:disabled_on_shell_admin') or
            pkg_i18n.translate('<p />You have manually disabled automatic updates after giving consent.')
    formActive = false
end

local f = Form(pkg_i18n.translate("Automatic updates"))
local s = f:section(Section,nil, site_i18n._translate('autoupdater-freifunk:description_admin')
        or pkg_i18n.translate('Node operators have the choice to allow remote maintenance. '..
        'Interventions on the nodes via automatic firmware upgrades are done with explicit agreement of the ' ..
        'respective operators.') .. ' ' .. warningMsg)
local o

local option_name = site_i18n._translate('autoupdater-freifunk:option_name') or
        pkg_i18n.translate("Remote Maintenance via Automatic Updates")

local dissent_option = site_i18n._translate('autoupdater-freifunk:option_dissent') or
        pkg_i18n.translate("Disable - I do not agree")
local consent_option = site_i18n._translate('autoupdater-freifunk:option_consent') or
        pkg_i18n.translate("Enable - I agree")

configValue = s:option(ListValue, 'given', option_name)
configValue.default = storedValue
configValue.subtemplate  = "model/gluon-config-mode-autoupdater-freifunk"
-- Override entries to remove empty default option from optional field
function configValue:entries()
    return {unpack(self.entry_list)}
end
configValue.widget = "radio"
configValue:value("0" , dissent_option)
configValue:value("1" , consent_option)

-- Inactive form => No choice possible
if not formActive then
    configValue.disabled = true
    configValue.optional = true
    configValue.default = uci:get("autoupdater", "settings", "enabled")
end

function configValue:write(data)
    if(formActive) then
        uci:set("autoupdater-freifunk", "consent", "given", data)
        if(formActive and changeAutomaticUpdates) then
            uci:set("autoupdater", "settings", "enabled", data)
        end
    end

end


local s = f:section(Section,pkg_i18n.translate('Branch'), site_i18n._translate('autoupdater-freifunk:description_admin') or pkg_i18n.translate('Pick a branch to receive updates from. If you disable automatic'
        ..' updates, this branch is used when executing autoupdater using the command shell.'
        .. ' Selecting no branch disables automatic updates.'))

o = s:option(ListValue, "branch", pkg_i18n.translate("Branch"))
o.optional = true
uci:foreach("autoupdater", "branch",
    function (section)
        o:value(section[".name"])
    end
)
o.default = uci:get("autoupdater", autoupdater, "branch")
function o:write(data)
    uci:set("autoupdater", autoupdater, "branch", data)
end

function f:write()
    uci:commit("autoupdater")
    uci:commit("autoupdater-freifunk")
end

return f
