local json = require('dkjson')
local cmds = require('commands')
local getopt = require('getopt')

local TIMEOUT = 2000 -- Shouldn't take longer than 2 seconds
local keyA

local function waitCmd()
	local response = core.WaitForResponseTimeout(cmds.CMD_ACK, TIMEOUT)
	if response then
		local count,cmd,arg0 = bin.unpack('LL',response)
		if(arg0==1) then
			local count,arg1,arg2,data = bin.unpack('LLH511',response,count)
			return data:sub(1,32)
		else
			return nil, "#db#"
		end
	end
	return nil, "No response from device"
end

for o, a in getopt.getopt(args, 'k:') do
	if o == "k" then keyA = a end
end
if keyA == nil then
	print(json.encode({error = 'no key A specified'}, {indent = true}))
	return
end

-- Read block 0
result = Command:new{cmd = cmds.CMD_MIFARE_READBL, arg1 = 0, arg2 = 0, arg3 = 0, data = keyA}
error = core.SendCommand(result:getBytes())
if error then
	print(json.encode({error = error}, {indent = true}))
	return
end
local block, error = waitCmd()
if error then
	print(json.encode({error = error}, {indent = true}))
	return
end

print(json.encode({block = block}, {indent = true}))
