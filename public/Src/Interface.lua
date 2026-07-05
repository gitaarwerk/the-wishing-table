TheWishingTable = {}
TheWishingTableMessageColor = "\124cffff4f98"

local function dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      s = s .. "[" .. k .. "] = " .. dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

function TheWishingTable.debugPrint(feature, message)
  if not TheWishingTableVars then return end

  if (TheWishingTableVars.debugMode == true) then
    local featName = feature or "feature_not_set"
    local prefix = "[WISHING_TABLE_DEBUG (" .. feature .. ")] "
    print(prefix .. message)
  end
end

function TheWishingTable_ConfigScreen_SetChannel(spell, value)
  local channel = "off"
  local flooredValue = floor(value / 1) * 1

  if (flooredValue == 0) then
    channel = "off"
  elseif (flooredValue == 1) then
    channel = "party"
  elseif (flooredValue == 2) then
    channel = "raid"
  elseif (flooredValue == 3) then
    channel = "party and raid"
  end

  if (spell == "consumableSpell") then
    TheWishingTableVars.consumableSpell_channel = flooredValue
    TheWishingTableVars.consumableSpell_text = channel
    _G[TheWishingTable_ConfigScreen_consumableSpell_Channel:GetName() .. "Text"]:SetText(
      TheWishingTableVars.consumableSpell_text
    )
  end
end

function TheWishingTable_TheWishingTableOn()
  print("\124cffffcee2TheWishingTable is now ON.")
  TheWishingTableVars.TheWishingTableIsOn = true
  TheWishingTable_ConfigScreen_TheWishingTable:SetChecked(true)
end

function TheWishingTable_TheWishingTableOff()
  print("\124cffffcee2TheWishingTable is now OFF.")
  TheWishingTableVars.TheWishingTableIsOn = false
  TheWishingTable_ConfigScreen_TheWishingTable:SetChecked(false)
end

function TheWishingTable_DebugOn()
  print("\124cffffcee2TheWishingTable: Debug mode is now ON.")
  TheWishingTableVars.debugMode = true
end

function TheWishingTable_DebugOff()
  print("\124cffffcee2TheWishingTable: Debug mode is now OFF.")
  TheWishingTableVars.debugMode = false
end

function TheWishingTable_SetconsumableSpellInstance(value)
  TheWishingTableVars.consumableSpell_instance = value
end

local function TheWishingTable_Init(msg)
  -- pattern matching that skips leading whitespace and whitespace between cmd and args
  -- any whitespace at end of args is retained
  local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

  if cmd == "reset" then
    TheWishingTableVars = nil
    if (TheWishingTableVars == nil) then
      print("\124cffffcee2The Wishing Table settings have been reset. You should now type /reload.")
    end
  elseif cmd == "on" then
    TheWishingTable_TheWishingTableOn()
  elseif cmd == "off" then
    TheWishingTable_TheWishingTableOff()
  elseif cmd == "toggle" then
    if (TheWishingTableVars and TheWishingTableVars.TheWishingTableIsOn) then
      TheWishingTable_TheWishingTableOff()
      return
    end

    if (not TheWishingTableVars or TheWishingTableVars and TheWishingTableVars.TheWishingTableIsOn == false) then
      TheWishingTable_TheWishingTableOn()
    end
  elseif cmd == "debug" then
    -- Toggle debug mode
    if args == "line" then
      -- Show a random announcement line for preview
      local line = TheWishingTable.TheWishingTable.speakconsumableSpell()
      print(TheWishingTableMessageColor .. "[PREVIEW] " .. line)
    else
      -- Toggle debug mode on/off
      if not TheWishingTableVars then
        TheWishingTableVars = {}
      end
      TheWishingTableVars.debugMode = not (TheWishingTableVars.debugMode or false)
      local status = TheWishingTableVars.debugMode and "ON" or "OFF"
      print(TheWishingTableMessageColor .. "Debug mode is now " .. status)
    end
  elseif cmd == "test" then
    local testMode = string.lower(args)
    if testMode == "party" or testMode == "raid" or testMode == "solo" then
      if not TheWishingTableVars then
        TheWishingTableVars = {}
      end
      TheWishingTableVars.testGroupMode = testMode
      print(TheWishingTableMessageColor .. "Test mode: " .. testMode .. " group")
    else
      print("Test modes: /twt test solo | /twt test party | /twt test raid")
    end
  else
    TheWishingTable_ConfigScreen:Show()
    -- If not handled above, display some sort of help message
    print("/twt or /wishingtable for following commands")
    print("/twt on - turns on The Wishing Table")
    print("/twt off - turns off The Wishing Table")
    print("/twt toggle - toggles The Wishing Table on and off")
    print("/twt debug - toggles debug mode (reacts to any spell)")
    print("/twt debug line - shows a random announcement preview")
    print("/twt test solo|party|raid - test group broadcast modes")
    print("To reset the vars:")
    print("Syntax: /twt reset")
  end
end

SlashCmdList["TWISHINGTABLE"] = TheWishingTable_Init

SLASH_TWISHINGTABLE1 = "/twt"
SLASH_TWISHINGTABLE2 = "/wishingtable"
