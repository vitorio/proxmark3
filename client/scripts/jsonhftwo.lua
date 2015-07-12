local json = require('dkjson')
local reader = require('read14a')
local pre = require('precalc')

result, error = reader.read1443a()
if not result then
	print(json.encode({error = error}, {indent = true}))
	return
end

akeys = pre.GetAll(result.uid)
local keysA = {}
for i = 0, 15 do
	keysA[i] = string.sub(akeys, i*12+1, i*12+12)
end
result['keysA'] = keysA

print(json.encode(result, {indent = true}))
