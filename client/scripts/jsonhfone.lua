local json = require('dkjson')
local reader = require('read14a')
result, error = reader.read1443a()
if not result then
	print(json.encode({error = error}, {indent = true}))
	return
end
print(json.encode(result, {indent = true}))
