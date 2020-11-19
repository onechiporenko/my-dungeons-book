local L = LibStub("AceLocale-3.0"):NewLocale("MyDungeonsBook", "enUS", true);

-- UI start
L["My Dungeons Book"] = true;
L["%s died"] = "%s died";
L["%s got hit by %s for %s (%s)"] = "%s got hit by %s for %s (%s)";
L["%s got debuff by %s"] = "%s got debuff by %s";
L["%s interrupted %s using %s"] = "%s interrupted %s using %s";
L["%s +%s is completed"] = "%s +%s is completed";
L["%s +%s is reset"] = "%s +%s is reset";
L["%s +%s is started"] = "%s +%s is started";
L["%s's cast %s is passed"] = "%s's cast %s is passed";
L["Date"] = "Date";
L["Time"] = "Time";
L["Version"] = "Version";
L["Dungeon"] = "Dungeon";
L["Key"] = "Key";
L["Affixes"] = "Affixes";
L["Not Found"] = "Not Found";
L["Yes"] = "Yes";
L["No"] = "No";
L["Reset"] = "Reset";
L["Deaths"] = "Deaths";
L["Fortified"] = "Fortified";
L["Tyrannical"] = "Tyrannical";
L["In Time"] = "In Time";
L["Not In Time"] = "Not In Time";
L["All"] = "All";
L["Race: %s"] = "Race: %s";
L["Hits"] = "Hits";
L["Spell"] = "Spell";
L["DEV"] = "DEV";
L["Mechanics"] = "Mechanics";
L["Interrupts"] = "Interrupts";
L["Encounters"] = "Encounters";
L["Details"] = "Details";
L["Avoidable Debuffs"] = "Avoidable Debuffs";
L["Avoidable Damage"] = "Avoidable Damage";
L["Roster"] = "Roster";
L["ID"] = "ID";
L["Dispells"] = "Dispells";
L["HPS"] = "HPS";
L["Heal"] = "Heal";
L["DPS"] = "DPS";
L["Damage"] = "Damage";
L["Player"] = "Player";
L["Sums"] = "Sums";
L["Nums"] = "Nums";
L["Sum"] = "Sum";
L["Num"] = "Num";
L["Kicks"] = "Kicks";
L["Passed"] = "Passed";
L["Kicked"] = "Kicked";
L["After"] = "After";
L["While"] = "While";
L["Before"] = "Before";
L["Duration"] = "Duration";
L["End Time"]= "End Time";
L["Start Time"]= "Start Time";
L["Name"] = "Name";
L["Over"] = "Over";
L["Amount"] = "Amount";
L["Damage Done To Units"] = "Damage Done To Units";
L["Special Casts"] = "Special Casts"
L["Own Casts"] = "Own Casts";
L["Buffs Or Debuffs On Units"] = "Buffs Or Debuffs On Units";
L["Special Buffs Or Debuffs"] = "Special Buffs Or Debuffs";
L["Casts"] = "Casts"
L["NPC"] = "NPC";
L["Count"] = "Count";
L["%s (%s) %s"] = "%s (%s) %s";
L["Time lost: %ss"] = "Time lost: %ss";
L["Time: %s / %s (%s%s) %.1f%%"] = "Time: %s / %s (%s%s) %.1f%%";
L["Key HP bonus: %s%%"] = "Key HP bonus: %s%%";
L["Key damage bonus: %s%%"] = "Key damage bonus: %s%%";
L["Dungeon: %s (+%s)"] = "Dungeon: %s (+%s)";
L["Used Items"] = "Used Items";
L["Item"] = "Item";
L["%s dispelled %s using %s"] = "%s dispelled %s using %s";
L["Effects and Auras"] = "Effects and Auras";
L["All Buffs"] = "All Buffs";
L["All Debuffs"] = "All Debuffs";
L["Time"] = "Time";
L["Target?"] = "Target?";
L["Swing Damage"] = "Swing Damage";
L["Result"] = "Result";
L["All damage taken"] = "All damage taken";
L["All damage done"] = "All damage done";
L["Dispels"] = "Dispels";
L["Casts"] = "Casts";
L["Are you sure you want to delete info about challenge?"] = "Are you sure you want to delete info about challenge?";
L["Challenge #%s is deleted successfully"] = "Challenge #%s is deleted successfully";
L["Min Not Crit"] = "Min Not Crit";
L["Hits Not Crit"] = "Hits Not Crit";
L["Max Not Crit"] = "Max Not Crit";
L["Min Crit"] = "Min Crit";
L["Max Crit"] = "Max Crit";
L["Crit, %"] = "Crit, %";
L["Hits Crit"] = "Hits Crit";
L["Show All Casts"] = "Show All Casts";
L["By Spell"] = "By Spell";
L["To Each Party Member"] = "To Each Party Member";
L["Quaked"] = "Quaked";
L["%"] = "%";
L["Summary"] = "Summary";
L["Not all spells have usage timestamps"] = "Not all spells have usage timestamps";
L["All Buffs & Debuffs"] = "All Buffs & Debuffs";
L["Uptime, %"] = "Uptime, %";
L["Max Stacks"] = "Max Stacks";
-- UI end

-- Help start
L["alias for previous word"] = "alias for previous word";
L["save info from Details addon. It's done automatically when challenge is completed (in time or not), however it's not done if challenge is abandonned. Use this command right before leave the party."] = "save info from Details addon. It's done automatically when challenge is completed (in time or not), however it's not done if challenge is abandonned. Use this command right before leave the party.";
L["update info about party member for current challenge. unitId must be 'player' or 'party1..4'."] = "update info about party member for current challenge. unitId must be 'player' or 'party1..4'.";
L["print this text."] = "print this text.";
-- Help end

-- Settings start
L["Performance"] = "Performance";
L["Run garbage collector on close"] = "Run garbage collector on close";
L["Show DEV Tab"] = "Show DEV Tab";
L["Verbose"] = "Verbose";
L["Show DEBUG messages"] = "Show DEBUG messages";
L["Show LOG messages"] = "Show LOG messages";
L["UI"] = "UI";
L["Main Window Scale"] = "Main Window Scale";
L["Date Format"] = "Date Format";
L["Time Format"] = "Time Format";
L["Icons"] = "Icons";
L["Time Format"] = "Time Format";
L["Flatten Icons"] = "Flatten Icons";
L["Date and Time"] = "Date and Time";
L["Logging Levels"] = "Logging Levels";
L["Logs"] = "Logs";
L["Show LOG messages about avoidable DEBUFFS"] = "Show LOG messages about avoidable DEBUFFS";
L["Show LOG messages about avoidable DAMAGE taken"] = "Show LOG messages about avoidable DAMAGE taken";
L["Show LOG messages about INTERRUPTS"] = "Show LOG messages about INTERRUPTS";
L["Show LOG messages about DISPELS"] = "Show LOG messages about DISPELS";
L["Show LOG messages about DEATHS"] = "Show LOG messages about DEATHS";
L["Show LOG messages about NOT INTERRUPTED casts"] = "Show LOG messages about NOT INTERRUPTED casts";
L["Options below are global. However they are overridden by LOG-option above. E.g. when \"Show LOG messages\" is disabled, no log messages will be printed independently of settings below."] = "Options below are global. However they are overridden by LOG-option above. E.g. when \"Show LOG messages\" is disabled, no log messages will be printed independently of settings below.";
-- Settings end

-- BfA start
-- NPCs start
L["Explosives"] = "Explosives";
L["Blood Tick"] = "Blood Tick";
L["Inconspicuous Plant"] = "Inconspicuous Plant";
L["Earthrager"] = "Earthrager";
L["Animated Gold"] = "Animated Gold";
L["Reban"] = "Reban";
L["T'zala"] = "T'zala";
L["Reanimated Raptor"] = "Reanimated Raptor";
L["Wasting Servant"] = "Wasting Servant";
L["Soul Thorns"] = "Soul Thorns";
L["Blood Visage"] = "Blood Visage";
L["Blood Effigy"] = "Blood Effigy";
L["A Knot of Snakes"] = "A Knot of Snakes";
L["Buzzing Drone"] = "Buzzing Drone";
L["Gripping Terror"] = "Gripping Terror";
L["Hull Cracker"] = "Hull Cracker";
L["Ashvane Cannoneer"] = "Ashvane Cannoneer";
L["Venture Co. Skyscorcher"] = "Venture Co. Skyscorcher";
L["Deathtouched Slaver"] = "Deathtouched Slaver";
L["Mindrend Tentacle"] = "Mindrend Tentacle";
-- NPCs end
-- BfA end

-- SL start
-- NPCs start
-- NPCs end
-- SL end
