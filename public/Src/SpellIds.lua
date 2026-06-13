TheWishingTable.SpellIds = {}

TheWishingTable.SpellIds.MageTable = { 58659, 190336 } -- Ritual of Refreshment              (WotLK 3.x) -- Conjure Refreshment Table           (Legion 7.x – current)

TheWishingTable.SpellIds.SoulWell = { 29893 } -- Ritual of Souls                     (TBC 2.x – current)

TheWishingTable.SpellIds.Feast = { -- Wrath of the Lich King (3.x)
57301, 57425, 72237, -- Cataclysm (4.x) -- Fish Feast -- Great Feast -- Bountiful Feast                     (Pilgrim's Bounty holiday)
87560, -- Mists of Pandaria (5.x) -- Seafood Magnifique Feast
126492, 126494, -- Warlords of Draenor (6.x) -- Pandaren Banquet -- Great Pandaren Banquet
185706, 185707, -- Legion (7.x) -- Feast of Blood -- Feast of the Waters
199427, 201324, -- Battle for Azeroth (8.x) -- Lavish Suramar Feast -- The Hungry Magister
259409, 259410, -- Shadowlands (9.x) -- Bountiful Captain's Feast -- Galley Banquet
308458, 308460, -- Dragonflight (10.x) -- Feast of Gluttonous Hedonism -- Surprisingly Palatable Feast
382956, 382953, 390215 } -- Grand Banquet of the Kalu'ak -- Yusa's Hearty Stew -- Deviously Deviled Eggs

-- The War Within (11.x) – add feast IDs here when known
-- Midnight (12.x)     – add feast IDs here when known

TheWishingTable.SpellIds.Cauldron = { -- Cataclysm (4.x)
92682, 92683, -- Shadowlands (9.x) -- Cauldron of Battle -- Big Cauldron of Battle
307185, 391529, -- Dragonflight (10.x) -- Potion Cauldron of Power -- Cauldron of Ultimate Power          (added in 9.2)
382553 } -- Elemental Cauldron of Power

-- The War Within (11.x) – add cauldron IDs here when known
-- Midnight (12.x)     – add cauldron IDs here when known

function TheWishingTable.SpellIds.getSpellCategory(spellId)
  if TheWishingTable.Helpers.tableContainsValue(TheWishingTable.SpellIds.MageTable, spellId) then
    return "mage_table"
  elseif TheWishingTable.Helpers.tableContainsValue(TheWishingTable.SpellIds.SoulWell, spellId) then
    return "soul_well"
  elseif TheWishingTable.Helpers.tableContainsValue(TheWishingTable.SpellIds.Feast, spellId) then
    return "feast"
  elseif TheWishingTable.Helpers.tableContainsValue(TheWishingTable.SpellIds.Cauldron, spellId) then
    return "cauldron"
  end
  return nil
end

function TheWishingTable.SpellIds.isConsumableSpellCasting(spellId)
  return TheWishingTable.SpellIds.getSpellCategory(spellId) ~= nil
end
