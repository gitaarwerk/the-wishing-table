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

function TheWhishingTable_ConfigScreen_SetChannel(spell, value)
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
    _G[TheWhishingTable_ConfigScreen_consumableSpell_Channel:GetName() .. "Text"]:SetText(
      TheWishingTableVars.consumableSpell_text
    )
  end
end

function TheWhishingTable_TheWishingTableOn()
  print("\124cffffcee2TheWishingTable is now ON.")
  TheWishingTableVars.TheWishingTableIsOn = true
  TheWhishingTable_ConfigScreen_TheWishingTable:SetChecked(true)
end

function TheWhishingTable_TheWishingTableOff()
  print("\124cffffcee2TheWishingTable is now OFF.")
  TheWishingTableVars.TheWishingTableIsOn = false
  TheWhishingTable_ConfigScreen_TheWishingTable:SetChecked(false)
end

function TheWhishingTable_DebugOn()
  print("\124cffffcee2TheWishingTable: Debug mode is now ON.")
  TheWishingTableVars.debugMode = true
end

function TheWhishingTable_DebugOff()
  print("\124cffffcee2TheWishingTable: Debug mode is now OFF.")
  TheWishingTableVars.debugMode = false
end

function TheWhishingTable_SetconsumableSpellInstance(value)
  TheWishingTableVars.consumableSpell_instance = value
end

local function TheWhishingTable_Init(msg)
  -- pattern matching that skips leading whitespace and whitespace between cmd and args
  -- any whitespace at end of args is retained
  local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

  if cmd == "reset" then
    TheWishingTableVars = nil
    if (TheWishingTableVars == nil) then
      print("\124cffffcee2The Wishing Table settings have been reset. You should now type /reload.")
    end
  elseif cmd == "on" then
    TheWhishingTable_TheWishingTableOn()
  elseif cmd == "off" then
    TheWhishingTable_TheWishingTableOff()
  elseif cmd == "toggle" then
    if (TheWishingTableVars and TheWishingTableVars.TheWishingTableIsOn) then
      TheWhishingTable_TheWishingTableOff()
      return
    end

    if (not TheWishingTableVars or TheWishingTableVars and TheWishingTableVars.TheWishingTableIsOn == false) then
      TheWhishingTable_TheWishingTableOn()
    end
  elseif cmd == "debug" then
    if (TheWishingTableVars and TheWishingTableVars.debugMode) then
      TheWhishingTable_DebugOff()
      return
    end

    if (not TheWishingTableVars or TheWishingTableVars and TheWishingTableVars.debugMode == false) then
      TheWhishingTable_DebugOn()
    end
    local dumpedVars = dump(TheWishingTableVars)
    print("Dumped The Wishing Table Vars: " .. dumpedVars)
  else
    TheWhishingTable_ConfigScreen:Show()
    -- If not handled above, display some sort of help message
    print("/nn or /TheWishingTable for following commands")
    print("/nn on - turns on The Wishing Table")
    print("/nn off - turns off The Wishing Table")
    print("/nn toggle - toggles The Wishing Table on and off")
    print("And to reset the vars:")
    print("Syntax: /nn reset")
  end
end

SlashCmdList["NNANCY"] = TheWhishingTable_Init

SLASH_NNANCY1 = "/nn"
SLASH_NNANCY2 = "/TheWishingTable"
