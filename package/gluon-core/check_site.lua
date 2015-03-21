need_string 'site_code'
need_string 'site_name'

need_string('hostname_prefix', false)
need_string 'timezone'

need_string_array('ntp_servers', false)

need_string_match('prefix4', '^%d+.%d+.%d+.%d+/%d+$')
need_string_match('prefix6', '^[%x:]+/%d+$')
