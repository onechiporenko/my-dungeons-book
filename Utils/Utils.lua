--[[--
@module MyDungeonsBook
]]

--[[--
Utils
@section Utils
]]

local affixesMap = {
	[1] = 463570, -- Overflowing
	[2] = 135994, -- Skittish
	[3] = 451169, -- Volcanic
	[4] = 1029009, -- Necrotic
	[5] = 136054, -- Teeming
	[6] = 132345, -- Raging
	[7] = 132333, -- Bolstering
	[8] = 136124, -- Sanguine
	[9] = 236401, -- Tyrannical
	[10] = 463829, -- Fortified
	[11] = 1035055, -- Bursting
	[12] = 132090, -- Grievous
	[13] = 2175503, -- Explosive
	[14] = 136025, -- Quaking
	[15] = 132739, -- Relentless
	[16] = 2032223, -- Infested
	[117] = 2446016, -- Reaping
	[119] = 237565, -- Beguiling
	[120] = 442737, -- Awakened
	[122] = 135946, -- Inspiring
	[123] = 135945, -- Spiteful
	[124] = 136018, -- Storming
	[121] = 3528307, -- Prideful
};

--[[--
Get texture for affix's icon (question mark is returned if no affix icon found).

It can be used in the strings like `"|T%%%:20:20:0:0:64:64:5:59:5:59|t"`, where `%%%` is a result of `MyDungeonsBook:GetAffixTextureById`.

@param[type=number] affixId myth+ affix identifier
@return[type=number] texture id for affix's icon
]]
function MyDungeonsBook:GetAffixTextureById(affixId)
	return affixesMap[affixId] or 134400;
end


--[[--
Convert number to K/M format.

@usage
FormatNumber(1); -- 1
FormatNumber(1234); -- 1.2K
FormatNumber(1234567); -- 1.23M

@param[type=number] n number to format
@return[type=string] formatted string
]]
function MyDungeonsBook:FormatNumber(n)
	if (type(n) ~= "number") then
		return n;
	end
    if (n >= 10 ^ 6) then
        return string.format("%.2fM", n / 10^6);
    elseif (n >= 10 ^ 3) then
        return string.format("%.1fK", n / 10^3);
    else
        return string.format("%.0f", n);
    end
end

--[[--
Type-safe function to round (floor) a number.

@param[type=number] n
@return[type=number]
]]
function MyDungeonsBook:RoundNumber(n)
	if (type(n) ~= "number") then
		return n;
	end
	return floor(n);
end

--[[--
@param[type=number] n number to format
@return[type=string] formatted string
]]
function MyDungeonsBook:FormatPercents(n)
	if (type(n) ~= "number") then
		return n;
	end
	return string.format("%.2f", n);
end

--[[--
Format seconds as date string

@param[type=number] seconds
@return[type=string]
]]
function MyDungeonsBook:FormatDate(seconds)
	local dateFormat = self.db.profile.display.dateFormat;
	return seconds and date(dateFormat, seconds) or seconds;
end

--[[--
Format milliseconds as time string

@param[type=number] milliseconds
@return[type=string]
]]
function MyDungeonsBook:FormatTime(milliseconds)
	local timeFormat = self.db.profile.display.timeFormat;
	local time = milliseconds / 1000;
	if (time > 3600) then
		local separator = (strfind(timeFormat, ":") and ":") or "-";
		return date("%S", math.floor(time / 3600 + 0.5)) .. separator .. date(timeFormat, time % 3600);
	end
	return date(timeFormat, time);
end

--[[--
Print message with DEBUG prefix.
Mostly used for debugging (and it's used a lot). It can be disabled in the addon settings.

@param[type=string] msg message to output
]]
function MyDungeonsBook:DebugPrint(...)
	if (self.db.profile.verbose.debug) then
		self:Print("|c0070DEFF[DEBUG]|r", ...);
	end
end

--[[--
Print message with LOG prefix.
Mostly used for debugging. It can be disabled in the addon settings.

@param[type=string] msg message to output
]]
function MyDungeonsBook:LogPrint(...)
	if (self.db.profile.verbose.log) then
		self:Print("|c8787EDFF[LOG]|r", ...);
	end
end

--[[--
Return string color with class-color of provided unit
If unit is not "classable", text is returned "as is"

@param[type=unitId] unit unitId to get its class color
@param[type=string] text message to colorize
@return[type=string] colorized `msg`
]]
function MyDungeonsBook:ClassColorText(unit, text)
	if unit and UnitExists(unit) then
		local _, class = UnitClass(unit);
		if not class then
			return text;
		else
			local classData = RAID_CLASS_COLORS[class];
			local coloredText = ("|c%s%s|r"):format(classData.colorStr, text);
			return coloredText;
		end
	else
		return text;
	end
end

--[[--
Colorize `text` to class color of `classIndex`

@param[type=number]classIndex wow class identifier
@param[type=string] text text to colorize
@return[type=string] colorized `text`
]]
function MyDungeonsBook:ClassColorTextByClassIndex(classIndex, text)
	local _, className = GetClassInfo(classIndex);
	if (className) then
		local classData = RAID_CLASS_COLORS[className];
		if (classData) then
			return ("|c%s%s|r"):format(classData.colorStr, text);
		end
		return text;
	end
	return text;
end

--[[--
Get unitId for GUID that may be in the party or is current player

@param[type=GUID] guid GUID to check
@return[type=?string] "player" or "party1..4" or nil
]]
function MyDungeonsBook:GetPartyUnitByGuid(guid)
	if (guid == UnitGUID("player")) then
		return "player";
	end
	for i = 1, 4 do
		if (guid == UnitGUID("party" .. i)) then
			return "party" .. i;
		end
	end
	return nil;
end

--[[--
Get unitId for player with name `name` in the challenge with id `challengeId`

@param[type=number] challengeId
@param[typestring] name
@return[type=?unitId]
]]
function MyDungeonsBook:GetPartyUnitByName(challengeId, name)
	local challenge = self.db.char.challenges[challengeId];
	if (not challenge) then
		return nil;
	end
	for _, unit in pairs(self:GetPartyRoster()) do
		if (challenge.players[unit] and challenge.players[unit].name and strfind(string.lower(name), string.lower(challenge.players[unit].name))) then
			return unit;
		end
	end
	return nil;
end

--[[--
Get a unit's name (with and without realm) for unit `unitId` in the challenge with id `challengeId`

@param[type=number] challengeId
@param[unitId] unitId
@return[type=string] just a name
@return[type=string] name with realm (if realm available)
]]
function MyDungeonsBook:GetNameByPartyUnit(challengeId, unitId)
	local challenge = self.db.char.challenges[challengeId];
	if (not challenge) then
		return nil, nil;
	end
	local name = challenge.players[unitId].name or "";
	local realm = challenge.players[unitId].realm;
	return name, (realm and string.format("%s-%s", name, realm)) or name;
end

--[[--
Create a colored string with key update level.

It can be "-1" (red), "+1" (green), "+2" (green) or "+3" (green).

@param[type=table] challenge
@return[type=string]
]]
function MyDungeonsBook:GetKeyUpgradeStr(challenge)
	local result;
	if (challenge.challengeInfo.onTime) then
		result = string.format("|cff1eff00+%s|r", challenge.challengeInfo.keystoneUpgradeLevels);
	else
		result = "|cffcc3333-1|r";
	end
	return result;
end

--[[--
Get a string with affixes icons for challenge with id `challengeId`.

Width and height for icons are set by `iconSize`.

@param[type=number] challengeId
@param[type=number] iconSize
@return[type=string] formatted string with icons for challenge affixes
]]
function MyDungeonsBook:GetChallengeAffixesIconsStr(challengeId, iconSize)
	local affixes = "";
	local challenge = self.db.char.challenges[challengeId];
	if (not challenge) then
		self:DebugPrint(string.format("[GetChallengeAffixesIconsStr] Challenge #%s not found"), challengeId);
	end
	local suffix = self:GetIconTextureSuffix(iconSize);
	if (challenge.challengeInfo.affixes) then
		for _, affixId in pairs(challenge.challengeInfo.affixes) do
			affixes = string.format("%s |T%s%s|t", affixes, self:GetAffixTextureById(affixId), suffix);
		end
	end
	return affixes;
end

--[[--
Get a string with a small role icon (19x19) for `role`.

@param[type=string] role can be `TANK`, `HEALER` or `DAMAGER`
@return[type=string]
]]
function MyDungeonsBook:GetSmallRoleIcon(role)
	local roles = {
		TANK = "|A:groupfinder-icon-role-large-tank:19:19|a",
		HEALER = "|A:groupfinder-icon-role-large-heal:19:19|a",
		DAMAGER = "|A:groupfinder-icon-role-large-dps:19:19|a"
	};
	return roles[role] or "";
end

--[[--
Get a string with unit role, name and realm colored with it's class.

`nil` is returned  if `unitInfo` is empty.

@param[type=table] unitInfo
@return[type=?string]
]]
function MyDungeonsBook:GetUnitNameRealmRoleStr(unitInfo)
	if (unitInfo.name) then
		return self:ClassColorTextByClassIndex(unitInfo.class, string.format("%s %s - %s", self:GetSmallRoleIcon(unitInfo.role), unitInfo.name, unitInfo.realm));
	end
	return nil;
end

--[[--
Get an icon id for class with index `classIndex`.

@param[type=string] classIndex
@return[type=number]
]]
function MyDungeonsBook:GetClassIconByIndex(classIndex)
	local icons = {
		["DEMONHUNTER"] = 236415,
		["DRUID"] = 625999,
		["HUNTER"] = 626000,
		["MAGE"] = 626001,
		["MONK"] = 626002,
		["PALADIN"] = 626003,
		["PRIEST"] = 626004,
		["ROGUE"] = 626005,
		["SHAMAN"] = 626006,
		["WARLOCK"] = 626007,
		["WARRIOR"] = 626008,
		["DEATHKNIGHT"] = 135771
	};
	local _, class = GetClassInfo(classIndex);
	return icons[class];
end

--[[--
Get a prefix for mechanics (`SL` or `BFA` etc).

TODO should check zone id and not game version?

@param[type=number] challengeId
@return[type=string]
]]
function MyDungeonsBook:GetMechanicsPrefixForChallenge(challengeId)
	local challenge = self.db.char.challenges[challengeId];
	if (not challenge) then
		return nil;
	end
	local version = challenge.gameInfo.version;
	local major = string.sub(version, 1, 1);
	if (major == "8" or version == "9.0.1") then
		return "BFA";
	end
	if (major == "9") then
		return "SL";
	end
	return nil;
end

--[[--
Get a table with values equal to party unit ids - `player`, `party1..4`

@return[type=table]
]]
function MyDungeonsBook:GetPartyRoster()
	return {"player", "party1", "party2", "party3", "party4"};
end

--[[--
Get count down time delay on challenge start.

Challenge's `startTime` is stored right after challenge start. However there is a countdown before "real" challenge timer starts.
Typically it's 9 seconds. It's possible to calculate it using `startTime`, `endTime` and `duration` (for already passed challenges).
If challenge is in progress or was abandonned, 9 seconds value is returned.

@param[type=number] challengeId
@return[type=number]
]]
function MyDungeonsBook:GetCountDownDelay(challengeId)
	local challenge = self.db.char.challenges[challengeId];
	if (not challenge) then
		return nil;
	end
	local startTime = challenge.challengeInfo.startTime;
	local endTime = challenge.challengeInfo.endTime;
	local duration = (challenge.challengeInfo.duration or 0) / 1000;
	if (not endTime) then
		return 9;
	end
	return endTime - startTime - duration;
end

--[[--
Extracts Npc ID from units GUID.

It doesn't check if it's realy npc etc - just trying to extract and convert to number.

@param[type=GUID] unitGUID
@return[type=?number]
]]
function MyDungeonsBook:GetNpcIdFromGuid(unitGUID)
	local _, _, _, _, _, npcId = strsplit("-", unitGUID);
	return tonumber(npcId);
end

local function mergeInternal(t1, key, value)
	if (type(value) == "table") then
		if (type(t1[key]) ~= "table") then
			t1[key] = {};
		end
		for k, v in pairs(value) do
			t1[key][k] = mergeInternal(t1[key], k, v);
		end
	else
		if (not t1[key]) then
			t1[key] = value;
		end
	end
	return t1[key];
end

--[[--
Recursively merge values from `table2` to `table1`. Values in `table1` won't be overridden if they are already exists.

@param[type=table] table1
@param[type=table] table2
@return[type=table] updated `table1`
]]
function MyDungeonsBook:MergeTables(table1, table2)
	if (type(table2) ~= "table") then
		return table1;
	end
	if (type(table1) ~= "table") then
		return table2;
	end
	for k, v in pairs(table2) do
		table1[k] = mergeInternal(table1, k, v);
	end
	return table1;
end

--[[--
@param[type=number] size
]]
function MyDungeonsBook:GetIconTextureSuffix(size)
	if (self.db.profile.display.flattenIcons) then
		return string.format(":%s:%s:0:0:64:64:5:59:5:59", size, size);
	end
	return string.format(":%s:%s:0:0:64:64:0:64:0:64", size, size);
end

--[[--
Check if value exists in the table

@param[type=table] tbl
@param[type=string|number|bool] value
]]
function MyDungeonsBook:TableContainsValue(tbl, value)
	for _, v in pairs(tbl) do
		if (v == value) then
			return true;
		end
	end
	return false;
end
