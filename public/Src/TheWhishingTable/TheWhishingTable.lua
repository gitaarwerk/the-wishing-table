-- init
TheWishingTable.TheWishingTable = {}
local feature = "TheWishingTable"


function TheWishingTable.TheWishingTable.speakconsumableSpell()
  local pickedLine
  local prefix = TheWishingTableVars.usePrefix == true and "[PREFIXX???]: " or ""

local Class = TheWishingTable.Constants.Class
local Race = TheWishingTable.Constants.Race

  local d = C_DateAndTime.GetCalendarTimeFromEpoch(1e6 * 60 * 60 * 24)
  local playerName, playerGender, playerClass, playerRace, playerLevel =
    TheWishingTable.Helpers.GetPlayerInformation()

  local playerGuyGirl = TheWishingTable.Helpers.GetGuyGirl(playerGender)
  local playerManWoman = TheWishingTable.Helpers.GetManWoman(playerGender)
  local oppositeSex = "guys"

  if (playerGender == "male") then
    oppositeSex = "girls"
  end

  local zoneName = GetZoneText()

  local consumableSpellLines = {
    "Feat, my pretties! FEAST!!"
  }

  if (playerClass == Class.Warlock) then
    table.insert(consumableSpellLines, "I've conjured a pretty big demon for this epic feast!")
  end


  -- New Year's Day
  if (d.month == 1 and d.day == 1) then  end

  -- Epiphany / Three Kings' Day
  if (d.month == 1 and d.day == 6) then  end

  -- Valentine's Day
  if (d.month == 2 and d.day == 14) then  end

  -- International Women's Day
  if (d.month == 3 and d.day == 8) then  end

  -- St. Patrick's Day
  if (d.month == 3 and d.day == 17) then  end

  -- April Fools' Day
  if (d.month == 4 and d.day == 1) then  end

  -- Earth Day
  if (d.month == 4 and d.day == 22) then  end

  -- International Workers' Day / May Day
  if (d.month == 5 and d.day == 1) then  end

  -- Star Wars Day
  if (d.month == 5 and d.day == 4) then  end

  -- Pride Day
  if (d.month == 6 and d.day == 28) then  end

  -- Independence Day (US)
  if (d.month == 7 and d.day == 4) then  end

  -- Bastille Day (France)
  if (d.month == 7 and d.day == 14) then  end

  -- International Cat Day
  if (d.month == 8 and d.day == 8) then  end

  -- Halloween
  if (d.month == 10 and d.day == 31) then  end

  -- Guy Fawkes Night (UK)
  if (d.month == 11 and d.day == 5) then  end

  -- Remembrance Day / Veterans Day
  if (d.month == 11 and d.day == 11) then  end

  -- Thanksgiving (US, ~4th Thursday of November)
  if (d.month == 11 and d.day >= 22 and d.day <= 28) then  end

  -- New Year's Eve
  if (d.month == 12 and d.day == 31) then  end


  pickedLine = consumableSpellLines[fastrandom(1, #consumableSpellLines)]

  return TheWishingTable.Helpers.parseText(prefix .. pickedLine, {
    playerName = playerName,
    playerGender = playerGender,
    playerClass = playerClass,
    playerRace = playerRace,
    playerLevel = playerLevel,
    playerManWoman = playerManWoman,
    playerGuyGirl = playerGuyGirl,
    oppositeSex = oppositeSex,
    zoneName = zoneName,
  })
end

local function str_to_bool(str)
  if str == nil then
    return false
  end
  return string.lower(str) == "true"
end

local function canBroadcastParty(value)
  if (value == 1 or value == 3) then
    return true
  end

  return false
end

local function canBroadcastRaid(value)
  if (value == 2 or value == 3) then
    return true
  end

  return false
end

local function getBroadcastChannel(broadCastChannels, canBroadcastToInstance)
  local canBroadcastToParty = canBroadcastParty(broadCastChannels)
  local canBroadcastToRaid = canBroadcastRaid(broadCastChannels)

  -- LFD/LFR/battleground groups talk through instance chat.
  if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
    if not (canBroadcastToInstance == true) then
      return nil
    end

    if IsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
      return canBroadcastToRaid and "INSTANCE_CHAT" or nil
    end

    return canBroadcastToParty and "INSTANCE_CHAT" or nil
  end

  if IsInRaid() then
    return canBroadcastToRaid and "RAID" or nil
  end

  if IsInGroup() then
    return canBroadcastToParty and "PARTY" or nil
  end

  return nil
end

local function determineChannel()
    return getBroadcastChannel(TheWishingTableVars.consumableSpell_channel, TheWishingTableVars.consumableSpell_instance)
end

function TheWishingTable.TheWishingTable.Run()
  local frame = CreateFrame("Frame")
  TheWishingTable.TheWishingTable.Frame = frame

  -- Midnight (12.0): the player's own spellcasts are explicitly non-secret, even in combat,
  -- so we can keep reacting to them. RegisterUnitEvent restricts the events to the player.
  -- UNIT_SPELLCAST_START only fires for spells with a cast time; UNIT_SPELLCAST_SUCCEEDED
  -- catches the instant ones (Raise Ally, Reincarnation, soulstone self-ress).
  -- UNIT_SPELLCAST_SENT still exists but its target parameter may be a secret value now,
  -- so it is registered defensively and only used when the name is actually readable.
  -- "pet" is included for pet-cast resurrections (hunter Stone Hound's Eternal Guardian);
  -- units controlled by the player are non-secret in Midnight too.
  pcall(frame.RegisterUnitEvent, frame, "UNIT_SPELLCAST_SENT", "player")
  frame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player", "pet")
  frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player", "pet")

  local lastAnnouncedKey, lastAnnouncedTime = nil, 0

  local function announceConsumablesPutDown(castGUID, spellID)

    if not TheWishingTable.SpellIds.isConsumableSpellCasting(spellID) then return end

    -- A spell with a cast time fires START and then SUCCEEDED for the same cast;
    -- announce it only once.
    local dedupeKey = castGUID or ("spell:" .. tostring(spellID))
    if (dedupeKey == lastAnnouncedKey and (GetTime() - lastAnnouncedTime) < 10) then return end

    local channel = determineChannel()
    if not channel then
      TheWishingTable.debugPrint(
        feature,
        "No broadcast channel (not in a group, or channel disabled in /nn)."
      )
      return
    end

    -- pcall keeps Midnight's secret-value restrictions from throwing Lua errors mid-fight;
    -- worst case the announcement is skipped.
    local ok, line = pcall(function()
        return TheWishingTable.TheWishingTable.speakconsumableSpell()
    end)

    if (not ok or type(line) ~= "string") then
      TheWishingTable.debugPrint(feature, "Could not build a line for spell " .. tostring(spellID))
      return
    end

    lastAnnouncedKey = dedupeKey
    lastAnnouncedTime = GetTime()

    -- Midnight blocks addon chat during boss encounters, keystone runs and PvP matches.
    if (C_ChatInfo and C_ChatInfo.InChatMessagingLockdown and C_ChatInfo.InChatMessagingLockdown()) then
      TheWishingTable.debugPrint(feature, "Chat messaging lockdown active; skipped: " .. line)
      return
    end

    local sent = pcall(SendChatMessage, line, channel)
    TheWishingTable.debugPrint(feature, "[" .. channel .. "] " .. line .. (sent and "" or " (send failed)"))
  end

  frame:SetScript("OnEvent", function(self, event, ...)
    if not TheWishingTableVars then return end

    if (not (TheWishingTableVars.TheWishingTableIsOn == true) and not (TheWishingTableVars.debugMode == true)) then return end

    if (event == "UNIT_SPELLCAST_SENT") then
      local unitTarget, arg2, arg3 = ...
      lastSentTargetName, lastSentCastGUID = nil, nil

      -- The SENT payload changed in Midnight: the target name parameter may be gone or
      -- secret. Only keep it when it is a readable name (cast GUIDs start with "Cast-").
      pcall(function()
        if (type(arg2) == "string" and arg2 ~= "" and not arg2:find("^Cast%-")) then
          lastSentTargetName = arg2
          lastSentCastGUID = arg3
        else
          lastSentCastGUID = arg2
        end
      end)
      return
    end

    if (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_SUCCEEDED") then
      local unitTarget, castGUID, spellID = ...

      if (not spellID) then return end

      announceConsumablesPutDown(castGUID, spellID)
    end
  end)
end

TheWishingTable.TheWishingTable.Run()
