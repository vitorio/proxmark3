local json = require('dkjson')
local cmds = require('commands')
local getopt = require('getopt')

local TIMEOUT = 2000 -- Shouldn't take longer than 2 seconds
local keysA
local numBlocks
local blocks = {}

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
	if o == "k" then keysA = a end
	if o == "b" then numBlocks = a end
end
if keysA == nil then
	print(json.encode({error = 'no keys A specified'}, {indent = true}))
	return
end
if numBlocks == nil then
	print(json.encode({error = 'no number of blocks specified'}, {indent = true}))
	return
end

for blockNo = 0, numBlocks-1, 1 do

	if core.ukbhit() then
		print(json.encode({error = 'cancelled at hardware'}, {indent = true}))
		return
	end

	pos = (math.floor( blockNo / 4 ) * 12)+1
	key = keysA:sub(pos, pos + 11 )
	result = Command:new{cmd = cmds.CMD_MIFARE_READBL, arg1 = blockNo ,arg2 = 0,arg3 = 0, data = key}
	local error = core.SendCommand(result:getBytes())
	if error then
		blocks[blockNo+1] = error
	else
		local blockdata, error = waitCmd()
		if error then
			blocks[blockNo+1] = error
		else
			if blockNo%4 ~= 3 then
				blocks[blockNo+1] = blockdata
			else
				blocks[blockNo+1] = key .. blockdata:sub(13,32) 
			end
		end		
	end
	
end

print(json.encode({blocks = blocks}, {indent = true}))
