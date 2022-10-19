--[[
Copyright 2008-2022 João Cardoso
Linfo is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of Linfo.

Linfo is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Linfo is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Linfo. If not, see <http://www.gnu.org/licenses/>.
--]]

local Meta = getmetatable(CreateFrame('GameTooltip', 'LinfoTooltip', nil, 'GameTooltipTemplate')).__index

local function Hook(api, handler)
	if Meta[api] then
		hooksecurefunc(Meta, api, handler)
	end
end

local function Print(self, ...)
	self:AddLine(...)
	self:Show()
end

local function PrintLink(self, link)
	link = strmatch(link or '', '([^H]+:[^|]+)') or format('No Link: %s', link)
	Print(self, '|n' .. link, 0, 0.6, 0.6)
end

local function PrintTexture(self, texture)
	Print(self, format('|T%s:0|t =%s', texture, texture), 0, 0.6, 0.6)
end


--[[ Actions ]]--

Hook('SetAction', function(self, slot)
	local kind, id = GetActionInfo(slot)
	if kind and id then
		PrintLink(self, (kind..':'..id))
		PrintTexture(self, GetActionTexture(slot))
	end
end)


--[[ Items ]]--

Hook('SetRecipeReagentItem', function(self, ...)
	local link = (C_TradeSkillUI.GetRecipeReagentItemLink or C_TradeSkillUI.GetRecipeFixedReagentItemLink)(...)
	local texture = select(2, C_TradeSkillUI.GetRecipeReagentInfo(...))
	if link then
		PrintLink(self, link)
		PrintTexture(self, texture)
	end
end)

local function PrintItem(self)
	local item = select(2, self:GetItem())
	if item then
		PrintLink(self, item)
		PrintTexture(self, GetItemIcon(item))
	end
end

for _,func in pairs({
	'SetLootRollItem',
	'SetMerchantCostItem',
	'SetMerchantItem',
	'SetQuestLogItem',
	'SetInventoryItem',
	'SetSocketedItem',
	'SetRecipeResultItem',
	'SetQuestLogSpecialItem',
	'SetBuybackItem',
	'SetAuctionItem',
	'SetAuctionSellItem',
	'SetInboxItem',
	'SetSendMailItem',
	'SetBagItem',
	'SetLootItem',
	'SetGuildBankItem',
	'SetQuestItem',
	'SetTradeTargetItem',
	'SetTradePlayerItem',
}) do
		Hook(func, PrintItem)
end


--[[ Spells ]]--

local function PrintSpell(self)
	local name, id = self:GetSpell()
	if id then
		PrintLink(self, GetSpellLink(id))
		PrintTexture(self, GetSpellTexture(id))
	end
end

for _,func in pairs({
	'SetPetAction',
	'SetShapeshift',
	'SetQuestRewardSpell',
	'SetQuestLogRewardSpell',
	'SetSpellBookItem',
	'SetSpellByID',
}) do
	Hook(func, PrintSpell)
end


--[[ Talents ]]--

local inspect
hooksecurefunc('InspectUnit', function(unit)
	inspect = unit ~= "player"
end)

Hook('SetTalent', function(self, arg1, arg2)
	local texture = GetTalentInfoByID and select(3, GetTalentInfoByID(arg1)) or select(2, GetTalentInfo(arg1, arg2, inspect))
	local link = GetTalentInfoByID and GetTalentLink(arg1, arg2, inspect) or GetTalentInfo(arg1, arg2, inspect)
	if link then
		PrintLink(self, link)
		PrintTexture(self, texture)
	end
end)

Hook('SetPvpTalent', function(self, id)
	local texture = select(3, GetPvpTalentInfoByID(id))
	local link = GetPvpTalentLink(id)
	if link then
		PrintLink(self, link)
		PrintTexture(self, texture)
	end
end)


--[[ Hyperlinks ]]--

Hook('SetHyperlink', function(self, link)
	if strmatch(link, 'item:') then
		PrintItem(self)
	elseif strmatch(link, 'spell:') then
		PrintSpell(self)
	else
		PrintLink(self, link)

		local type, id = strmatch(link, '(%D+):(%d+)')
		if type == 'achievement' then
			PrintTexture(self, select(10, GetAchievementInfo(id)))
		elseif type == 'talent' then
			PrintTexture(self, select(3, GetTalentInfoByID(id)))
		elseif type == 'pvptal' then
			PrintTexture(self, select(3, GetPvpTalentInfoByID(id)))
		end
	end
end)
