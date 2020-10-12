--[[--
@module MyDungeonsBook
]]

--[[--
Mechanics
@section Mechanics
]]

-- Some stuff for interrupts is taken from https://wago.io/SkjHi61Bz/18

local L = LibStub("AceLocale-3.0"):GetLocale("MyDungeonsBook");

local function mergeInterruptSpellId(spellId)
	-- Warlock
	if (spellId == 119910 or spellId == 132409) then
		return 19647;
	end
	-- Priest
	if (spellId == 220543) then
		return 15487;
	end
	return spellId;
end

local function getPetOwner(unitGUID, partyRoster)
	for _, unitId in pairs(partyRoster) do
        if (UnitGUID(unitId .. "pet") == unitGUID) then
            return unitId;
        end
    end
	return nil;
end

-- Tooltip to track pet's owner
local scanTool = CreateFrame("GameTooltip", "ScanTooltip", nil, "GameTooltipTemplate");

-- from https://www.wowinterface.com/forums/showthread.php?t=43082
local function getPetOwnerWithTooltip(petName)
	scanTool:ClearLines();
	scanTool:SetUnit(petName);
	local ownerText = scanText:GetText();
	if (not ownerText) then
		return nil;
	end
	local owner, _ = string.split("'", ownerText);
	return owner; -- This is the pet's owner
end

--[[--
Add a table or counter (depends on `asCounter`) to the active challenge inside a `mechanics` (nested in 1 level).

It doesn't do anything if value `mechanics[first]` already exists.

@param[type=string|number] first key for the new value inside `mechanics`
@param[type=bool] asCounter truly for new value `0`, falsy for `{}`
]]
function MyDungeonsBook:InitMechanics1Lvl(first, asCounter)
	local id = self.db.char.activeChallengeId;
	if (not self.db.char.challenges[id].mechanics[first]) then
		self.db.char.challenges[id].mechanics[first] = (asCounter and 0) or {};
	end
end

--[[--
Add a table or counter (depends on `asCounter`) to the active challenge inside a `mechanics` (nested in 2 levels).

It doesn't do anything if value `mechanics[first][second]` already exists.

@param[type=string|number] first key for the new table inside `mechanics`
@param[type=string|number] second key for the new value inside mechanics&lbrack;first&rbrack;
@param[type=bool] asCounter truly for new value `0`, falsy for `{}`
]]
function MyDungeonsBook:InitMechanics2Lvl(first, second, asCounter)
	local id = self.db.char.activeChallengeId;
	self:InitMechanics1Lvl(first, false);
	if (not self.db.char.challenges[id].mechanics[first][second]) then
		self.db.char.challenges[id].mechanics[first][second] = (asCounter and 0) or {};
	end
end

--[[--
Add a table or counter (depends on `asCounter`) to the active challenge inside a `mechanics` (nested in 3 levels).

It doesn't do anything if value `mechanics[first][second][third]` already exists.

@param[type=string|number] first key for the new table inside `mechanics`
@param[type=string|number] second key for the new table inside mechanics&lbrack;first&rbrack;
@param[type=string|number] third key for the new value inside mechanics&lbrack;first&rbrack;&lbrack;second&rbrack;
@param[type=bool] asCounter truly for new value `0`, falsy for `{}`
]]
function MyDungeonsBook:InitMechanics3Lvl(first, second, third, asCounter)
	local id = self.db.char.activeChallengeId;
	self:InitMechanics2Lvl(first, second, false);
	if (not self.db.char.challenges[id].mechanics[first][second][third]) then
		self.db.char.challenges[id].mechanics[first][second][third] = (asCounter and 0) or {};
	end
end

--[[--
Add a table or counter (depends on `asCounter`) to the active challenge inside a `mechanics` (nested in 4 levels).

It doesn't do anything if value `mechanics[first][second][third][fourth]` already exists.

@param[type=string|number] first key for the new table inside `mechanics`
@param[type=string|number] second key for the new table inside mechanics&lbrack;first&rbrack;
@param[type=string|number] third key for the new table inside mechanics&lbrack;first&rbrack;&lbrack;second&rbrack;
@param[type=string|number] fourth key for the new value inside mechanics&lbrack;first&rbrack;&lbrack;second&rbrack&lbrack;third&rbrack;
@param[type=bool] asCounter truly for new value `0`, falsy for `{}`
]]
function MyDungeonsBook:InitMechanics4Lvl(first, second, third, fourth, asCounter)
	local id = self.db.char.activeChallengeId;
	self:InitMechanics3Lvl(first, second, third, false);
	if (not self.db.char.challenges[id].mechanics[first][second][third][fourth]) then
		self.db.char.challenges[id].mechanics[first][second][third][fourth] = (asCounter and 0) or {};
	end
end

--[[--
Track each player's death.

@param[type=GUID] deadUnitGUID 8th result of `CombatLogGetCurrentEventInfo` call
@param[type=string] unit 9th result of `CombatLogGetCurrentEventInfo` call
]]
function MyDungeonsBook:TrackDeath(deadUnitGUID, unit)
	local id = self.db.char.activeChallengeId;
	local isPlayer = strfind(deadUnitGUID, "Player"); -- needed GUID is something like "Player-......"
	if (not isPlayer) then
		return;
	end
	if (UnitIsFeignDeath(unit)) then
		self:DebugPrint(string.format("%s is feign death", unit));
	    return;
	end
	local surrenderedSoul = GetSpellInfo(212570);
	for i = 1, 40 do
		local debuffName = UnitDebuff(unit, i);
		if (debuffName == nil) then
			break;
		end
		if (debuffName == surrenderedSoul) then
			self:DebugPrint(string.format("%s is on Surrendered Soul debuff", unit));
			return;
		end
	end
	local key = "DEATHS";
	self:InitMechanics2Lvl(key, unit);
	tinsert(self.db.char.challenges[id].mechanics[key][unit], time());
	self:LogPrint(string.format(L["%s died"], self:ClassColorText(unit, unit)));
end

--[[--
Track interrupts done by party members.

@param[type=string] unit 5th result of `CombatLogGetCurrentEventInfo` call
@param[type=string] srcGUID 4th result of `CombatLogGetCurrentEventInfo` call
@param[type=number] spellId 12th result of `CombatLogGetCurrentEventInfo` call
@param[type=number] interruptedSpellId 15th result of `CombatLogGetCurrentEventInfo` call
]]
function MyDungeonsBook:TrackInterrupt(unit, srcGUID, spellId, interruptedSpellId)
	local id = self.db.char.activeChallengeId;
	--Attribute Pet Spell's to its owner
    local type = strsplit("-", srcGUID);
    if (type == "Pet") then
		local petOwnerId = getPetOwnerWithTooltip(srcGUID);
		if (petOwnerId) then
			unit = UnitName(petOwnerId);
		end
    end
	if (not UnitIsPlayer(unit)) then
		self:DebugPrint(string.format("%s is not player", unit));
	end
	local KEY = "COMMON-INTERRUPTS";
	spellId = mergeInterruptSpellId(spellId);
	self:LogPrint(string.format(L["%s interrupted %s using %s"], self:ClassColorText(unit, unit), GetSpellLink(interruptedSpellId), GetSpellLink(spellId)));
	self:InitMechanics4Lvl(KEY, unit, spellId, interruptedSpellId, true);
	self.db.char.challenges[id].mechanics[KEY][unit][spellId][interruptedSpellId] = self.db.char.challenges[id].mechanics[KEY][unit][spellId][interruptedSpellId] + 1;
end

--[[--
Track dispels done by party members.

@param[type=string] unit 5th result of `CombatLogGetCurrentEventInfo` call
@param[type=string] srcGUID 4th result of `CombatLogGetCurrentEventInfo` call
@param[type=number] spellId 12th result of `CombatLogGetCurrentEventInfo` call
@param[type=number] dispelledSpellId 15th result of `CombatLogGetCurrentEventInfo` call
]]
function MyDungeonsBook:TrackDispel(unit, srcGUID, spellId, dispelledSpellId)
	local id = self.db.char.activeChallengeId;
	--Attribute Pet Spell's to its owner
    local type = strsplit("-", srcGUID);
    if (type == "Pet") then
		local petOwnerId = getPetOwnerWithTooltip(srcGUID);
		if (petOwnerId) then
			unit = UnitName(petOwnerId);
		end
    end
	if (not UnitIsPlayer(unit)) then
		self:DebugPrint(string.format("%s is not player", unit));
		return;
	end
	local KEY = "COMMON-DISPEL";
	self:LogPrint(string.format(L["%s dispelled %s using %s"], self:ClassColorText(unit, unit), GetSpellLink(dispelledSpellId), GetSpellLink(spellId)));
	self:InitMechanics4Lvl(KEY, unit, spellId, dispelledSpellId, true);
	self.db.char.challenges[id].mechanics[KEY][unit][spellId][dispelledSpellId] = self.db.char.challenges[id].mechanics[KEY][unit][spellId][dispelledSpellId] + 1;
end

--[[--
Track casts that should interrupt enemies.

This mechanic is used together with `COMMON-INTERRUPTS` to get number of failed "interrrupt"-casts (e.g. when 2+ party member tried to interrupt the same cast together).

@param[type=number] spellId 12th param for `SPELL_CAST_SUCCESS`
@param[type=string] sourceGUID 4th param for `SPELL_CAST_SUCCESS`
@param[type=string] sourceName 5th param for `SPELL_CAST_SUCCESS`
]]
function MyDungeonsBook:TrackTryInterrupt(spellId, sourceGUID, sourceName)
	local interrupts = {
		[47528] = true,  --Mind Freeze
		[106839] = true, --Skull Bash
		[78675] = true,  --Solar Beam
		[183752] = true, --Disrupt
		[147362] = true, --Counter Shot
		[187707] = true, --Muzzle
		[2139] = true,   --Counter Spell
		[116705] = true, --Spear Hand Strike
		[96231] = true,  --Rebuke
		[1766] = true,   --Kick
		[57994] = true,  --Wind Shear
		[6552] = true,   --Pummel
		[119910] = true, --Spell Lock Command Demon
		[19647] = true,  --Spell Lock if used from pet bar
		[132409] = true, --Spell Lock Command Demon Sacrifice
		[15487] = true,  --Silence
		[31935] = true,  --Avenger's Shield
		[15487] = true,  --Silence
		[93985] = true,  --Skull Bash 
		[97547] = true,  --Solar Beam
		[91807] = true,  --Shambling Rush
	};
	if (not interrupts[spellId]) then
		return;
	end
	local id = self.db.char.activeChallengeId;
	local KEY = "COMMON-TRY-INTERRUPT";
    --Attribute Pet Spell's to its owner
    local type = strsplit("-", sourceGUID);
    if (type == "Pet") then
		local petOwnerId = getPetOwnerWithTooltip(sourceGUID);
		if (petOwnerId) then
			sourceName = UnitName(unit);
		end
    end
    spellId = mergeInterruptSpellId(spellId);
	self:InitMechanics3Lvl(KEY, sourceName, spellId, true);
	self.db.char.challenges[id].mechanics[KEY][sourceName][spellId] = self.db.char.challenges[id].mechanics[KEY][sourceName][spellId] + 1;
end

--[[--
Track gotten by players damage that could be avoided.

Check events not related to `SPELL_AURA_APPLIED` and `SPELL_AURA_APPLIED_DOSE` (they are tracked in the method `MyDungeonsBook:TrackAvoidableAuras`).

@param[type=string] key db key to save damage done by `spells` or `spellsNoTank`
@param[type=table] spells table with keys equal to tracked spell ids
@param[type=table] spellsNoTank table with keys equal to tracked spell ids allowed to hit tanks
@param[type=string] unit unit name that got damage (usualy it's a destUnit from `CombatLogGetCurrentEventInfo`)
@param[type=number] spellId spell that did damage to `unit`
@param[type=number] amount amount of damage done to `unit` by `spellId`
]]
function MyDungeonsBook:TrackAvoidableSpells(key, spells, spellsNoTank, unit, spellId, amount)
	if ((spells[spellId] or (spellsNoTank[spellId] and UnitGroupRolesAssigned(unit) ~= "TANK")) and UnitIsPlayer(unit)) then
		self:SaveTrackedDamageToPartyMembers(key, unit, spellId, amount);
	end
end

--[[--
Track all damage done to party members

@param[type=string] unit unit name that got damage (usualy it's a destUnit from `CombatLogGetCurrentEventInfo`)
@param[type=number] spellId spell that did damage to `unit`
@param[type=number] amount amount of damage done to `unit` by `spellId`
]]
function MyDungeonsBook:TrackAllDamageDoneToPartyMembers(unit, spellId, amount)
	local key = "ALL-DAMAGE-DONE-TO-PARTY-MEMBERS";
	if (UnitIsPlayer(unit)) then
		self:SaveTrackedDamageToPartyMembers(key, unit, spellId, amount);
	end
end

--[[--
@local
@param[type=string] key db key
@param[type=string] unit unit name that got damage (usualy it's a destUnit from `CombatLogGetCurrentEventInfo`)
@param[type=number] spellId spell that did damage to `unit`
@param[type=number] amount amount of damage done to `unit` by `spellId`
]]
function MyDungeonsBook:SaveTrackedDamageToPartyMembers(key, unit, spellId, amount)
	local partyUnit = self:GetPartyUnitByName(unit);
	if (partyUnit) then
		local amountInPercents = amount / UnitHealthMax(partyUnit) * 100;
		if (amountInPercents > 40) then
			self:LogPrint(string.format(L["%s got hit by %s for %s (%s)"], unit, GetSpellLink(spellId), self:FormatNumber(amount), string.format("%.1f\%", amountInPercents)));
		end
	end
	local id = self.db.char.activeChallengeId;
	self:InitMechanics2Lvl(key, unit);
	if (not self.db.char.challenges[id].mechanics[key][unit][spellId]) then
		self.db.char.challenges[id].mechanics[key][unit][spellId] = {
			num = 0,
			sum = 0
		};
	end
	if (not amount) then
		amount = 0;
		self:DebugPrint(string.format("Cast of %s did `nil` amount of damage", GetSpellLink(spellId)));
	end
	self.db.char.challenges[id].mechanics[key][unit][spellId].num = self.db.char.challenges[id].mechanics[key][unit][spellId].num + 1;
	self.db.char.challenges[id].mechanics[key][unit][spellId].sum = self.db.char.challenges[id].mechanics[key][unit][spellId].sum + amount;
end

--[[--
Track gotten by players debuffs that could be avoided.

Check events `SPELL_AURA_APPLIED` and `SPELL_AURA_APPLIED_DOSE`.

@param[type=string] key db key to save debuffs done by `spells` or `spellsNoTank`
@param[type=table] auras table with keys equal to tracked spell ids
@param[type=table] aurasNoTank table with keys equal to tracked spell ids allowed to hit tanks
@param[type=unitId] unit unit name that got damage (usualy it's a destUnit from `CombatLogGetCurrentEventInfo`)
@param[type=number] spellId spell that apply debuff to `damagedUnit`
]]
function MyDungeonsBook:TrackAvoidableAuras(key, auras, aurasNoTank, unit, spellId)
	if (auras[spellId] or (aurasNoTank[spellId] and UnitGroupRolesAssigned(unit) ~= "TANK")) and UnitIsPlayer(unit) then
		local id = self.db.char.activeChallengeId;
		self:InitMechanics3Lvl(key, unit, spellId, true);
		self.db.char.challenges[id].mechanics[key][unit][spellId] = self.db.char.challenges[id].mechanics[key][unit][spellId] + 1;
		self:LogPrint(string.format(L["%s got debuff by %s"], unit, GetSpellLink(spellId)));
	end
end

--[[--
Track all buffs and debuffs on party members

@param[type=unitId] unit unit name that got buff or debuff (usualy it's a destUnit from `CombatLogGetCurrentEventInfo`)
@param[type=number] spellId spell that apply debuff to `damagedUnit`
@param[type=string] auraType
]]
function MyDungeonsBook:TrackAllAurasOnPartyMembers(unit, spellId, auraType)
	if (UnitIsPlayer(unit)) then
		local id = self.db.char.activeChallengeId;
		local key = "ALL-AURAS";
		self:InitMechanics3Lvl(key, unit, spellId);
		self.db.char.challenges[id].mechanics[key][unit][spellId].auraType = auraType;
		if (not self.db.char.challenges[id].mechanics[key][unit][spellId].count) then
			self.db.char.challenges[id].mechanics[key][unit][spellId].count = 0;
		end
		self.db.char.challenges[id].mechanics[key][unit][spellId].count = self.db.char.challenges[id].mechanics[key][unit][spellId].count + 1;
	end
end

--[[--
Track passed casts that should be interrupted by players.

This mechanic is a subset of one from `TrackAllEnemyPassedCasts`.

@param[type=string] key db key
@param[type=table] spells table with keys equal to tracked spell ids
@param[type=string] unitName caster
@param[type=number] spellId casted spell id
]]
function MyDungeonsBook:TrackPassedCasts(key, spells, unitName, spellId)
	if (spells[spellId]) then
		self:LogPrint(string.format(L["%s's cast %s is passed"], unitName, GetSpellLink(spellId)));
		local id = self.db.char.activeChallengeId;
		self:InitMechanics2Lvl(key, spellId, true);
		self.db.char.challenges[id].mechanics[key][spellId] = self.db.char.challenges[id].mechanics[key][spellId] + 1;
	end
end

--[[--
Track all passed casts done by enemies.

@param[type=string] unitName caster's name
@param[type=GUID] unitGUID caster's GUID
@param[type=number] spellId casted spell ID
]]
function MyDungeonsBook:TrackAllEnemiesPassedCasts(unitName, unitGUID, spellId)
	local isPlayer = strfind(unitGUID, "Player");
	local isPet = strfind(unitGUID, "Pet");
	if (isPlayer or isPet) then
		return;
	end
	local KEY = "ALL-ENEMY-PASSED-CASTS";
	local id = self.db.char.activeChallengeId;
	self:InitMechanics2Lvl(KEY, spellId, true);
	self.db.char.challenges[id].mechanics[KEY][spellId] = self.db.char.challenges[id].mechanics[KEY][spellId] + 1;
end

--[[--
Track damage done by party members (and pets) for specific unit.

@param[type=string] key mechanic unique identifier
@param[type=table] npcs table with npcs needed to track (each key is a npc id)
@param[type=string] sourceUnitName name of unit that did damage
@param[type=GUID] sourceUnitGUID GUID of unit that did damage
@param[type=number] spellId spell id
@param[type=number] amount amount of done damage
@param[type=number] overkill amount of extra damage
@param[type=string] targetUnitName name of unit that got damage
@param[type=GUID] targetUnitGUID GUID of unit that got damage
]]
function MyDungeonsBook:TrackDamageDoneToSpecificUnits(key, npcs, sourceUnitName, sourceUnitGUID, spellId, amount, overkill, targetUnitName, targetUnitGUID)
	local id = self.db.char.activeChallengeId;
	local type = strsplit("-", sourceUnitGUID);
	if ((type ~= "Pet") and (type ~= "Player")) then
		return;
	end
	local npcId = self:GetNpcIdFromGuid(targetUnitGUID);
	if (not npcs[npcId]) then
		return;
	end
    if (type == "Pet") then
		local petOwnerId = getPetOwnerWithTooltip(sourceUnitGUID);
		if (petOwnerId) then
			sourceUnitName = string.format("%s (%s)", sourceUnitName, UnitName(petOwnerId));
		end
    end
	self:InitMechanics4Lvl(key, npcId, sourceUnitName, spellId);
	if (not self.db.char.challenges[id].mechanics[key][npcId][sourceUnitName][spellId].hits) then
		self.db.char.challenges[id].mechanics[key][npcId][sourceUnitName][spellId] = {
			hits = 0,
			amount = 0,
			overkill = 0
		};
	end
	self.db.char.challenges[id].mechanics[key][npcId][sourceUnitName][spellId].hits = self.db.char.challenges[id].mechanics[key][npcId][sourceUnitName][spellId].hits + 1;
	if (amount) then
		self.db.char.challenges[id].mechanics[key][npcId][sourceUnitName][spellId].amount = self.db.char.challenges[id].mechanics[key][npcId][sourceUnitName][spellId].amount + amount;
	else
		self:DebugPrint(string.format("Cast of %s did `nil` amount of damage", GetSpellLink(spellId)));
	end
	if (overkill and overkill > 0) then
		self.db.char.challenges[id].mechanics[key][npcId][sourceUnitName][spellId].overkill = self.db.char.challenges[id].mechanics[key][npcId][sourceUnitName][spellId].overkill + overkill;
	end
end

--[[--
Track cast done by any party member.

It should be used for player's own spells.

@param[type=string] key mechanic unique identifier
@param[type=table] spells table with spells needed to track (each key is a spell id)
@param[type=string] sourceUnitName name of unit that casted a spell
@param[type=number] spellId casted spell id
@param[type=?string] targetUnitName name of unit that is spell's target (only for single target spells)
]]
function MyDungeonsBook:TrackOwnCastDoneByPartyMembers(key, spells, sourceUnitName, spellId, targetUnitName)
	if (spells[spellId] and UnitIsPlayer(sourceUnitName)) then
		local id = self.db.char.activeChallengeId;
		self:InitMechanics3Lvl(key, sourceUnitName, spellId);
		local timestamp = time();
		self.db.char.challenges[id].mechanics[key][sourceUnitName][spellId][timestamp] = {
			time = timestamp,
			target = targetUnitName
		};
	end
end

--[[--
Track specific cast done by any party member.

It should not be used for player's own spells. It should be used for some specific for dungeon spells (e.g. kicking balls in the ML).

@param[type=string] key mechanic unique identifier
@param[type=table] spells table with spells needed to track (each key is a spell id)
@param[type=string] unit name of unit that casted a spell
@param[type=number] spellId casted spell id
]]
function MyDungeonsBook:TrackSpecificCastDoneByPartyMembers(key, spells, unit, spellId)
	if (spells[spellId] and UnitIsPlayer(unit)) then
		local id = self.db.char.activeChallengeId;
		self:InitMechanics3Lvl(key, spellId, unit, true);
		self.db.char.challenges[id].mechanics[key][spellId][unit] = self.db.char.challenges[id].mechanics[key][spellId][unit] + 1;
	end
end

--[[--
Track specific items used by any party member.

Technically using items is same as casting spells.

@param[type=string] key mechanic unique identifier
@param[type=table] spells table with spells needed to track (each key is a spell id and each value is item id)
@param[type=string] unit name of unit that casted a spell
@param[type=number] spellId casted spell id
]]
function MyDungeonsBook:TrackSpecificItemUsedByPartyMembers(key, spells, unit, spellId)
	local itemId = spells[spellId];
	if (itemId and UnitIsPlayer(unit)) then
		local id = self.db.char.activeChallengeId;
		self:InitMechanics3Lvl(key, itemId, unit, true);
		self.db.char.challenges[id].mechanics[key][itemId][unit] = self.db.char.challenges[id].mechanics[key][itemId][unit] + 1;
	end
end

--[[--
Track specific buffs or debuffs got by any party member.

@param[type=string] key mechanic unique identifier
@param[type=table] spells table with buffs (or debuffs) needed to track (each key is a spell id)
@param[type=string] unit name of unit that casted a spell
@param[type=number] spellId buff (or debuff) id
]]
function MyDungeonsBook:TrackSpecificBuffOrDebuffOnPartyMembers(key, spells, unit, spellId)
	if (spells[spellId] and UnitIsPlayer(unit)) then
		local id = self.db.char.activeChallengeId;
		self:InitMechanics3Lvl(key, spellId, unit, true);
		self.db.char.challenges[id].mechanics[key][spellId][unit] = self.db.char.challenges[id].mechanics[key][spellId][unit] + 1;
	end
end

--[[--
Track specific buffs or debuffs got by any unit.

@param[type=string] key mechanic unique identifier
@param[type=table] spells table with needed to track buffs and debuffs (each key is npc id)
@param[type=GUID] unitGUID GUID for unit with buff/debuff
@param[type=number] spellId buff (or debuff) id
]]
function MyDungeonsBook:TrackSpecificBuffOrDebuffOnUnit(key, spells, unitGUID, spellId)
	if (spells[spellId]) then
		local id = self.db.char.activeChallengeId;
		local npcId = self:GetNpcIdFromGuid(unitGUID);
		if (npcId) then
			self:InitMechanics3Lvl(key, spellId, npcId, true);
			self.db.char.challenges[id].mechanics[key][spellId][npcId] = self.db.char.challenges[id].mechanics[key][spellId][npcId] + 1;
		end
	end
end

--[[--
Track if specific npc appears in combat (and how many times this happens).

@param[type=string] key - mechanic unique identifier
@param[type=table] units - table with needed to track npcs (each key is npc id)
@param[type=GUID] sourceUnitGUID - GUID of source unit
@param[type=GUID] targetUnitGUID - GUID of target unit
]]
function MyDungeonsBook:TrackUnitsAppearsInCombat(key, units, sourceUnitGUID, targetUnitGUID)
	local sourceNpcId = self:GetNpcIdFromGuid(sourceUnitGUID);
	local targetNpcId = self:GetNpcIdFromGuid(targetUnitGUID);
	local id = self.db.char.activeChallengeId;
	local neededNpcGUID, neededNpcId;
	if (units[sourceNpcId]) then
		neededNpcGUID = sourceUnitGUID;
		neededNpcId = sourceNpcId;
	end
	if (units[targetNpcId]) then
		neededNpcGUID = targetUnitGUID;
		neededNpcId = targetNpcId;
	end
	if (neededNpcGUID and neededNpcId) then
		self:InitMechanics2Lvl(key, neededNpcId);
		self.db.char.challenges[id].mechanics[key][neededNpcId][neededNpcGUID] = true;
	end
end
