TheWishingTable.Helpers = {}

function TheWishingTable.Helpers.parseText(s, tab)
  return (s:gsub("($%b{})", function(w)
    return tab[w:sub(3, -2)] or w
  end))
end

function TheWishingTable.Helpers.mergeTable(t1, t2)
  for i = 1, #t2 do
    t1[#t1 + 1] = t2[i]
  end
  return t1
end

function TheWishingTable.Helpers.GetHisHer(gender)
  if (gender == "male") then
    return "His"
  end

  return "Her"
end

function TheWishingTable.Helpers.GetHimHer(gender)
  if (gender == "male") then
    return "Him"
  end

  return "Her"
end

function TheWishingTable.Helpers.GetHeShe(gender)
  if (gender == "male") then
    return "he"
  end

  return "she"
end

function TheWishingTable.Helpers.GetSirMam(gender)
  if (gender == "male") then
    return "sir"
  end

  return "ma'm"
end

function TheWishingTable.Helpers.oppositeBfGf(gender)
  if (gender == "male") then
    return "girlfriend"
  end

  return "boyfriend"
end

function TheWishingTable.Helpers.GetGuyGirl(gender)
  if (gender == "male") then
    return "guy"
  end

  return "girl"
end

function TheWishingTable.Helpers.GetManWoman(gender)
  if (gender == "male") then
    return "man"
  end

  return "woman"
end

function TheWishingTable.Helpers.GetPoppaMomma(gender)
  if (gender == "male") then
    return "poppa"
  end

  return "momma"
end

local function getCharacterinfo(target)
  local genderTable = { "neuter or unknown", "male", "female" }
  local playerClass, englishClass, classIndex = UnitClass(target)
  local name, upName, level = UnitName(target)
  local unitLevel = UnitLevel(target)
  local gender = genderTable[UnitSex(target)]
  local race, raceEn = UnitRace(target)

  return name, gender, playerClass, race, unitLevel
end

function TheWishingTable.Helpers.GetTargetInformation()
  if UnitName("target") then
    return getCharacterinfo("target")
  end

  return nil
end

function TheWishingTable.Helpers.GetTargetInformationByUID(uid)
  local genderTable = { "neutral or unknown", "male", "female" }
  local targetClass, engClass, targetRace, engRace, sex, targetName, server

  if uid then
    targetClass, engClass, targetRace, engRace, sex, targetName, server = GetPlayerInfoByGUID(uid)
  end

  -- UnitSex() does not accept GUIDs; GetPlayerInfoByGUID already returns the sex.
  local targetGender = genderTable[sex or 1]

  return targetName or "someone", targetGender, targetClass or "hero", targetRace or "mortal"
end

function TheWishingTable.Helpers.GetPlayerInformation()
  return getCharacterinfo("player")
end

function TheWishingTable.Helpers.tableContainsValue(table, val)
  for index, value in ipairs(table) do
    if value == val then
      return true
    end
  end

  return false
end
