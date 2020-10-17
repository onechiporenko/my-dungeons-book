--[[--
@module MyDungeonsBook
]]

--[[--
UI
@section UI
]]
local L = LibStub("AceLocale-3.0"):GetLocale("MyDungeonsBook");

--[[--
Create a frame for Damage Done To Units tab (data is taken from `mechanics[**-DAMAGE-DONE-TO-UNITS]`).

Mouse hover/out handler are included.

@param[type=Frame] parentFrame
@return[type=Frame] tableWrapper
]]
function MyDungeonsBook:DamageDoneToUnitsFrame_Create(parentFrame)
	local ScrollingTable = LibStub("ScrollingTable");
	local cols = self:DamageDoneToUnitsFrame_GetHeadersForTable();
	local tableWrapper = CreateFrame("Frame", nil, parentFrame);
	tableWrapper:SetWidth(900);
	tableWrapper:SetHeight(450);
	tableWrapper:SetPoint("TOPLEFT", 0, -120);
	local table = ScrollingTable:CreateST(cols, 11, 40, nil, tableWrapper);
	table:RegisterEvents({
		OnEnter = function (...)
			self:DamageDoneToUnitsFrame_RowHover(...);
	    end,
		OnLeave = function (_, _, _, _, _, realrow)
			if (realrow) then
				self:Table_Cell_MouseOut();
			end
	    end
	});
	tableWrapper.table = table;
	return tableWrapper;
end

--[[--
Generate columns for Damage Done To Units table.

Depending on `challengeId` real player names will be used or simple placeholders like `player` or `party1..4`.

@param[type=number] challengeId
@return[type=table]
]]
function MyDungeonsBook:DamageDoneToUnitsFrame_GetHeadersForTable(challengeId)
	local challenge = self.db.char.challenges[challengeId];
	local player = "Player";
	local party1 = "Party1";
	local party2 = "Party2";
	local party3 = "Party3";
	local party4 = "Party4";
	if (challenge) then
		local players = challenge.players;
		player = (players.player.name and self:ClassColorTextByClassIndex(players.player.class, players.player.name)) or L["Not Found"];
		party1 = (players.party1.name and self:ClassColorTextByClassIndex(players.party1.class, players.party1.name)) or L["Not Found"];
		party2 = (players.party2.name and self:ClassColorTextByClassIndex(players.party2.class, players.party2.name)) or L["Not Found"];
		party3 = (players.party3.name and self:ClassColorTextByClassIndex(players.party3.class, players.party3.name)) or L["Not Found"];
		party4 = (players.party4.name and self:ClassColorTextByClassIndex(players.party4.class, players.party4.name)) or L["Not Found"];
	end
	return {
		{
			name = L["NPC"],
			width = 120,
			align = "LEFT"
		},
		{
			name = player,
			width = 70,
			align = "RIGHT",
			DoCellUpdate = function(...)
				self:Table_Cell_FormatAsNumber(...);
			end
		},
		{
			name = "",
			width = 1,
			align = "RIGHT",
			DoCellUpdate = function(...)
				self:Table_Cell_FormatAsNumber(...);
			end
		},
		{
			name = "",
			width = 1,
			align = "RIGHT"
		},
		{
			name = party1,
			width = 70,
			align = "RIGHT",
			DoCellUpdate = function(...)
				self:Table_Cell_FormatAsNumber(...);
			end
		},
		{
			name = "",
			width = 1,
			align = "RIGHT",
			DoCellUpdate = function(...)
				self:Table_Cell_FormatAsNumber(...);
			end
		},
		{
			name = "",
			width = 1,
			align = "RIGHT"
		},
		{
			name = party2,
			width = 70,
			align = "RIGHT",
			DoCellUpdate = function(...)
				self:Table_Cell_FormatAsNumber(...);
			end
		},
		{
			name = "",
			width = 1,
			align = "RIGHT",
			DoCellUpdate = function(...)
				self:Table_Cell_FormatAsNumber(...);
			end
		},
		{
			name = "",
			width = 1,
			align = "RIGHT"
		},
		{
			name = party3,
			width = 70,
			align = "RIGHT",
			DoCellUpdate = function(...)
				self:Table_Cell_FormatAsNumber(...);
			end
		},
		{
			name = "",
			width = 1,
			align = "RIGHT",
			DoCellUpdate = function(...)
				self:Table_Cell_FormatAsNumber(...);
			end
		},
		{
			name = "",
			width = 1,
			align = "RIGHT"
		},
		{
			name = party4,
			width = 70,
			align = "RIGHT",
			DoCellUpdate = function(...)
				self:Table_Cell_FormatAsNumber(...);
			end
		},
		{
			name = "",
			width = 1,
			align = "RIGHT"
		},
		{
			name = "",
			width = 1,
			align = "RIGHT"
		}
	};
end

function MyDungeonsBook:DamageDoneToUnitsFrame_RowHover(rowFrame, cellFrame, data, cols, row, realrow, column, fShow, table)
	if (realrow and column % 3 == 2) then
		local amount = self:FormatNumber(data[realrow].cols[column].value);
		local overkill = self:FormatNumber(data[realrow].cols[column + 1].value);
		local hits = data[realrow].cols[column + 2].value;
		GameTooltip:SetOwner(cellFrame, "ANCHOR_NONE");
		GameTooltip:SetPoint("BOTTOMLEFT", cellFrame, "BOTTOMRIGHT");
		GameTooltip:AddLine(cols[column].name);
		GameTooltip:AddLine(string.format("%s: %s", L["Amount"], amount));
		GameTooltip:AddLine(string.format("%s: %s", L["Over"], overkill));
		GameTooltip:AddLine(string.format("%s: %s", L["Hits"], hits));
		GameTooltip:Show();
	end
end

--[[--
Map data about Damage Done To Units for challenge with id `challengeId`.

@param[type=number] challengeId
@param[type=string] key for mechanics table (it's different for BFA and SL)
@return[type=table]
]]
function MyDungeonsBook:DamageDoneToUnitsFrame_GetDataForTable(challengeId, key)
	local tableData = {};
	if (not challengeId) then
		return nil;
	end
	if (not self.db.char.challenges[challengeId].mechanics[key]) then
		self:DebugPrint(string.format("No Damage Done To Units data for challenge #%s", challengeId));
		return tableData;
	end
	for npcId, damageByPartyMembers in pairs(self.db.char.challenges[challengeId].mechanics[key]) do
		local row = {};
		for partyMemberName, partyMemberDamage in pairs(damageByPartyMembers) do
			local amount = 0;
			local hits = 0;
			local overkill = 0;
			local partyUnitId = self:GetPartyUnitByName(challengeId, partyMemberName);
			if (partyUnitId) then
				for _, damageBySpell in pairs(partyMemberDamage) do
					amount = amount + damageBySpell.amount;
					overkill = overkill + damageBySpell.overkill;
					hits = hits + damageBySpell.hits;
				end
				row[partyUnitId .. "Amount"] = amount;
				row[partyUnitId .. "Hits"] = hits;
				row[partyUnitId .. "Overkill"] = overkill;
			else
				self:DebugPrint(string.format("%s not found in the challenge party roster", partyMemberName));
			end
		end
		local npcs = self:GetBfADamageDoneToSpecificUnits();
		local npc = npcs[npcId];
		if (not npc) then
			npcs = self:GetSLDamageDoneToSpecificUnits();
			npc = npcs[npcId];
		end
		local npcName;
		if (npc and npc.name) then
			npcName = npc.name;
		end
		if (not npcName) then
			npcName = self.db.global.meta.npcs[npcId] and self.db.global.meta.npcs[npcId].name;
		end
		if (not npcName) then
			npcName = npcId;
		end
		local remappedRow = {
			cols = {
				{value = npcName}
			}
		};
		for _, unitId in pairs(self:GetPartyRoster()) do
			tinsert(remappedRow.cols, {
				value = row[unitId .. "Amount"] or 0
			});
			tinsert(remappedRow.cols, {
				value = row[unitId .. "Overkill"] or 0
			});
			tinsert(remappedRow.cols, {
				value = row[unitId .. "Hits"] or 0
			});
		end
		tinsert(tableData, remappedRow);
	end
	return tableData;
end

--[[--
Update Damage Done To Units tab for challenge with id `challengeId`.

@param[type=number] challengeId
]]
function MyDungeonsBook:DamageDoneToUnitsFrame_Update(challengeId)
	local challenge = self.db.char.challenges[challengeId];
	if (challenge) then
		local damageDoneToUnitsTableData = self:DamageDoneToUnitsFrame_GetDataForTable(challengeId, self:GetMechanicsPrefixForChallenge(challengeId) .. "-DAMAGE-DONE-TO-UNITS");
		self.challengeDetailsFrame.mechanicsFrame.damageFrame.damageDoneToUnitsFrame.table:SetData(damageDoneToUnitsTableData);
		self.challengeDetailsFrame.mechanicsFrame.damageFrame.damageDoneToUnitsFrame.table:SetDisplayCols(self:DamageDoneToUnitsFrame_GetHeadersForTable(challengeId));
		self.challengeDetailsFrame.mechanicsFrame.damageFrame.damageDoneToUnitsFrame.table:SortData();
	end
end
