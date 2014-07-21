local time = os.time()
local timestamp = os.date('%F %T', time)
local timezone = os.date('%z', time):gsub('^([%+%-]%d%d)(%d%d)$', '%1:%2')

print(timestamp .. timezone)
