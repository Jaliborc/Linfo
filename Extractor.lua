--[[ Small code used to extract the API function form the tooltips Meta. Not loaded by the TOC ]]--

--------------------------------
local TYPE = 'Item'
local FUNCTIONS = itemFunctions

local newFuns = {}
for k,v in pairs(Meta) do
	if type(v) == 'function' and strmatch(k, TYPE) and not strmatch(k, 'Get') and not strmatch(k, 'Is') then
		local known
		for _,func in pairs(FUNCTIONS) do
			if func == k then
				known = true
			end
		end
		if not known then
			tinsert(newFuns, k)
		end
	end
end

local string
for index = 1, #newFuns, 4 do
	string = '                      '
	for i = index, min(#newFuns, index + 3) do
		string = format("%s'%s',               ", string, newFuns[i])
	end
	SendChatMessage(string)
end
-------------------------------------------------
