local json = require('dkjson')
local cmds = require('commands')
local getopt = require('getopt')

local TIMEOUT = 2000 -- Shouldn't take longer than 2 seconds
local keyA
local block = {}

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

for o, a in getopt.getopt(args, 'k:b:') do
	if o == "k" then keyA = a end
	if o == "b" then blockNo = a end
end
if keyA == nil then
	print(json.encode({error = 'no key A specified'}, {indent = true}))
	return
end
if blockNo == nil then
	print(json.encode({error = 'no block number specified'}, {indent = true}))
	return
end

result = Command:new{cmd = cmds.CMD_MIFARE_READBL, arg1 = blockNo ,arg2 = 0,arg3 = 0, data = keyA}
local error = core.SendCommand(result:getBytes())
if error then
	block = error
else
	local blockdata, error = waitCmd()
	if error then
		block = error
	else
		if blockNo%4 ~= 3 then
			block = blockdata
		else
			block = keyA .. blockdata:sub(13,32) 
		end
	end		
end

print(json.encode({block}, {indent = true}))
