--[[
Copyright 2008-2025 João Cardoso
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

local function Print(self, text)
	self:AddLine(text, 0, 0.6, 0.6)
	self:Show()
end

local function PrintLink(self, link)
	link = strmatch(link or '', '([^H]+:[^|]+)') or ''
	Print(self, '|n' .. link)
end

local function PrintTexture(self, texture)
	if texture then
		Print(self, format('|T%s:0|t =%s', texture, texture))
	end
end


--[[ Primary Types ]]--

local function PrintItem(self)
	local _, item = (self.GetItem or TooltipUtil.GetDisplayedItem)(self)
	if item then
		PrintLink(self, item)
		PrintTexture(self, GetItemIcon(item))
	end
end

local function PrintSpell(self)
	local name, id = self:GetSpell()
	local link = id and C_Spell.GetSpellLink(id)
	if link then
		PrintLink(self, link)
		PrintTexture(self, C_Spell.GetSpellTexture(id))
	end
end

local function PrintUnit(self)
	local name, id = self:GetUnit()
	if id then
		Print(self, '|n' .. id)
	end
end

if C_TooltipInfo then
	local function PrintID(prefix, self, data)
		Print(self, '|n' .. prefix .. ':' .. data.id)
	end

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, PrintItem)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, PrintSpell)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, PrintUnit)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Quest, GenerateClosure(PrintID, 'quest'))
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Achievement, GenerateClosure(PrintID, 'achievement'))
else
	local function Hook(frame)
		frame:HookScript('OnTooltipSetItem', PrintItem)
		frame:HookScript('OnTooltipSetSpell', PrintSpell)
		frame:HookScript('OnTooltipSetUnit', PrintUnit)
	end

	for _,frame in pairs {UIParent:GetChildren()} do
		if not frame:IsForbidden() and frame:GetObjectType() == 'GameTooltip' then
			Hook(frame)
		end
	end

	hooksecurefunc('GameTooltip_OnLoad', Hook)
end


--[[ Old APIs ]]--

local Meta = getmetatable(GameTooltip).__index
local function Hook(api, handler)
	if Meta[api] then
		hooksecurefunc(Meta, api, handler)
	end
end

Hook('SetHyperlink', function(self, link)
	local type, id = strmatch(link, '(%D+):(%d+)')
	if type == 'achievement' then
		PrintLink(self, link)
		PrintTexture(self, select(10, GetAchievementInfo(id)))
	elseif type == 'talent' then
		PrintLink(self, link)
		PrintTexture(self, GetTalentInfoByID and select(3, GetTalentInfoByID(id)))
	elseif type == 'pvptal' then
		PrintLink(self, link)
		PrintTexture(self, GetPvpTalentInfoByID and select(3, GetPvpTalentInfoByID(id)))
	end
end)

Hook('SetAction', function(self, slot)
	if not self:GetSpell() and not self:GetItem() then
		local kind, id = GetActionInfo(slot)
		if kind and id then
			PrintLink(self, (kind..':'..id))
			PrintTexture(self, GetActionTexture(slot))
		end
	end
end)

Hook('SetTalent', function(self, arg1, arg2)
	local texture = GetTalentInfoByID and select(3, GetTalentInfoByID(arg1)) or select(2, GetTalentInfo(arg1, arg2))
	local link = GetTalentLink and GetTalentLink(arg1, arg2) or GetTalentInfo(arg1, arg2)
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
