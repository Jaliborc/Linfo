--[[
Copyright 2008-2020 João Cardoso
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

local function Print(self, ...)
	if type(...) == 'string' then
		self:AddLine(...)
		self:Show()
	end
end

local function PrintLink(self, link)
	link = strmatch(link or '', '([^H]+:[^|]+)')
	Print(self, link, 0, 0.6, 0.6)
end

local function PrintTexture(self, texture)
	Print(self, texture, 0, 1, 1)
end


--[[ Actions ]]--

hooksecurefunc(Meta, 'SetAction', function(self, slot)
	local kind, id = GetActionInfo(slot)

	PrintTexture(self, GetActionTexture(slot))
	if kind and id then
		PrintLink(self, (kind..':'..id))
	end
end)


--[[ Spells ]]--

local spellFunctions = {
	'SetPetAction',
	'SetShapeshift',
	'SetQuestRewardSpell',
	'SetQuestLogRewardSpell',
	'SetSpellByID',
}

local function PrintSpell(self)
	local spell = self:GetSpell()
	if spell then
		PrintTexture(self, GetSpellTexture(spell))
		PrintLink(self, GetSpellLink(spell, rank))
	end
end

for _,Func in pairs(spellFunctions) do
	hooksecurefunc(Meta, Func, PrintSpell)
end


--[[ Talents ]]--

local inspect
hooksecurefunc('InspectUnit', function(unit)
	inspect = unit ~= "player"
end)

hooksecurefunc(Meta, 'SetTalent', function(self, tabIndex, talentIndex)
	local texture = select(2, GetTalentInfo(tabIndex, talentIndex, inspect))
	local link = GetTalentLink(tabIndex, talentIndex, inspect)

	PrintTexture(self, texture)
	PrintLink(self, link)
end)


--[[ Items ]]--

local itemFunctions = {
	'SetLootRollItem',
	'SetMerchantCostItem',
	'SetMerchantItem',
	'SetQuestLogItem',
	'SetInventoryItem',
	'SetSocketedItem',
	'SetRecipeReagentItem',
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
}

local function PrintItem(self)
	local item = select(2, self:GetItem())
	if item then
		PrintTexture(self, GetItemIcon(item))
		PrintLink(self, item)
	end
end

for _,func in pairs(itemFunctions) do
	if Meta[func] then
		hooksecurefunc(Meta, func, PrintItem)
	end
end


--[[ Hyperlinks ]]--

hooksecurefunc(Meta, 'SetHyperlink', function(self, link)
	if strmatch(link, 'item:') then
		PrintItem(self)
	elseif strmatch(link, 'spell:') then
		PrintSpell(self)
	--elseif strmatch(link, 'talent:') then
		----To do texture...
	else
		local id = strmatch(link, 'achievement:(%d+)')
		if id then
			PrintTexture(self, select(10, GetAchievementInfo(id)))
		end
		PrintLink(self, link)
	end
end)
