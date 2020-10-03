local L = LibStub("AceLocale-3.0"):GetLocale("MyDungeonsBook");

--[[
Create a frame for Details tab (data should be ken from `details` section for challenge)

@method MyDungeonsBook:CreateDetailsFrame
@param {table} frame
@return {table} detailsWrapper
]]
function MyDungeonsBook:CreateDetailsFrame(frame)
	local detailsTableFrame = CreateFrame("Frame", nil, frame);
	detailsTableFrame:SetWidth(900);
	detailsTableFrame:SetHeight(490);
	detailsTableFrame:SetPoint("TOPRIGHT", -5, -100);
	detailsTableFrame.table = self:CreateDetailsTable(detailsTableFrame);
	return detailsTableFrame;
end

--[[
Create a table with data from Detauls addon

@method MyDungeonsBook:CreateDetailsTableFrame
@return {table}
]]
function MyDungeonsBook:CreateDetailsTable(frame)
	local ScrollingTable = LibStub("ScrollingTable");
	local cols = self:GetHeadersForDetailsTable();
	local tableWrapper = CreateFrame("Frame", nil, frame);
	tableWrapper:SetWidth(900);
	tableWrapper:SetHeight(250);
	tableWrapper:SetPoint("TOPRIGHT", 0, 0);
	return ScrollingTable:CreateST(cols, 5, 40, nil, tableWrapper);
end

--[[
Generate columns for avoidable damage table

@method MyDungeonsBook:GetHeadersForDetailsTable
@return {table}
]]
function MyDungeonsBook:GetHeadersForDetailsTable()
	return {
		{
			name = "Player",
			width = 275,
			align = "LEFT"
		},
		{
			name = "Damage",
			width = 100,
			align = "RIGHT",
			DoCellUpdate = function(...)
				self:FormatCellValueAsNumber(...);
			end
		},
		{
			name = "DPS",
			width = 100,
			align = "RIGHT",
			DoCellUpdate = function(...)
				self:FormatCellValueAsNumber(...);
			end
		},
		{
			name = "Heal",
			width = 100,
			align = "RIGHT",
			DoCellUpdate = function(...)
				self:FormatCellValueAsNumber(...);
			end
		},
		{
			name = "HPS",
			width = 100,
			align = "RIGHT",
			DoCellUpdate = function(...)
				self:FormatCellValueAsNumber(...);
			end
		},
		{
			name = "Interrupts",
			width = 100,
			align = "RIGHT"
		},
		{
			name = "Dispells",
			width = 100,
			align = "RIGHT"
		}
	};
end

--[[
Map data from Details addon for challenge with id `challengeId`

@method MyDungeonsBook:GetDataForDetailsTable
@param {number} challengeId
@return {table}
]]
function MyDungeonsBook:GetDataForDetailsTable(challengeId)
	local challenge = self.db.char.challenges[challengeId];
	local tableData = {};
	if (not challenge) then
		return tableData;
	end
	if (not challenge.details) then
		return tableData;
	end
	if (not challenge.details.exists) then
		return tableData;
	end
	for _, unitId in pairs(self:GetPartyRoster()) do
		local details = challenge.details[unitId];
		tinsert(tableData, {
			cols = {
				{
					value = self:GetUnitNameRealmRoleStr(challenge.players[unitId])
				},
				{
					value = details.totalDamage
				},
				{
					value = details.effectiveDps
				},
				{
					value = details.totalHeal
				},
				{
					value = details.effectiveHps
				},
				{
					value = self:RoundNumber(details.interrupt) or "-"
				},
				{
					value = self:RoundNumber(details.dispell) or "-"
				}
			}
		});
	end
	return tableData;
end

function MyDungeonsBook:UpdateDetailsFrame(challengeId)
	local challenge = self.db.char.challenges[challengeId];
	if (challenge) then
		self.challengeDetailsFrame.detailsFrame.table:SetData(self:GetDataForDetailsTable(challengeId));
	end
end