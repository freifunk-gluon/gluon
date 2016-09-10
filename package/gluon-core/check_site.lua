need_string 'site_code'
need_string 'site_name'

if need_table('opkg', nil, false) then
  need_string('opkg.openwrt', false)

  function check_repo(k, _)
    -- this is not actually a uci name, but using the same naming rules here is fine
    assert_uci_name(k)

    need_string(string.format('opkg.extra[%q]', k))
  end

  need_table('opkg.extra', check_repo, false)
end

need_string('hostname_prefix', false)
need_string 'timezone'

need_string_array('ntp_servers', false)

need_string_match('prefix6', '^[%x:]+/%d+$')


for _, config in ipairs({'wifi24', 'wifi5'}) do
  if need_table(config, nil, false) then
    need_string('regdom') -- regdom is only required when wifi24 or wifi5 is configured

    need_number(config .. '.channel')

    local rates = {1000, 2000, 5500, 6000, 9000, 11000, 12000, 18000, 24000, 36000, 48000, 54000}
    local supported_rates = need_array_of(config .. '.supported_rates', rates, false)
    if supported_rates then
      need_array_of(config .. '.basic_rate', supported_rates, true)
    else
      need_array_of(config .. '.basic_rate', rates, false)
    end
  end
end

need_boolean('poe_passthrough', false)
