need_string_match('next_node.ip4', '^%d+.%d+.%d+.%d+$')
need_string_match('next_node.ip6', '^[%x:]+$')

need_string_match('next_node.mac', '^%x[02468aAcCeE]:%x%x:%x%x:%x%x:%x%x:%x%x$')
