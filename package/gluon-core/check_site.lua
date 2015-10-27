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

need_string_match('prefix4', '^%d+.%d+.%d+.%d+/%d+$')
need_string_match('prefix6', '^[%x:]+/%d+$')


for _, config in ipairs({'wifi24', 'wifi5'}) do
  if need_table(config, nil, false) then
    need_string('regdom') -- regdom is only required when wifi24 or wifi5 is configured

    need_number(config .. '.channel')
  end
end
