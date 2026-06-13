TheWishingTable.SpellIds = {}

function TheWishingTable.SpellIds.isConsumableSpellCasting(spellId)
  local spellIds = {

    -- =========================================================
    -- Mage: Refreshment Table
    -- =========================================================
    58659,  -- Ritual of Refreshment              (WotLK 3.x)
    190336, -- Conjure Refreshment Table           (Legion 7.x – current)

    -- =========================================================
    -- Warlock: Soul Well
    -- =========================================================
    29893,  -- Ritual of Souls                     (TBC 2.x – current)

    -- =========================================================
    -- Cooking Feasts  (placed on the ground for the group)
    -- =========================================================

    -- Wrath of the Lich King (3.x)
    57301,  -- Fish Feast
    57425,  -- Great Feast
    72237,  -- Bountiful Feast                     (Pilgrim's Bounty holiday)

    -- Cataclysm (4.x)
    87560,  -- Seafood Magnifique Feast

    -- Mists of Pandaria (5.x)
    126492, -- Pandaren Banquet
    126494, -- Great Pandaren Banquet

    -- Warlords of Draenor (6.x)
    185706, -- Feast of Blood
    185707, -- Feast of the Waters

    -- Legion (7.x)
    199427, -- Lavish Suramar Feast
    201324, -- The Hungry Magister

    -- Battle for Azeroth (8.x)
    259409, -- Bountiful Captain's Feast
    259410, -- Galley Banquet

    -- Shadowlands (9.x)
    308458, -- Feast of Gluttonous Hedonism
    308460, -- Surprisingly Palatable Feast

    -- Dragonflight (10.x)
    382956, -- Grand Banquet of the Kalu'ak
    382953, -- Yusa's Hearty Stew
    390215, -- Deviously Deviled Eggs

    -- The War Within (11.x) – add feast IDs here when known
    -- Midnight (12.x)     – add feast IDs here when known

    -- =========================================================
    -- Alchemy Cauldrons  (placed on the ground for the raid)
    -- =========================================================

    -- Cataclysm (4.x)
    92682,  -- Cauldron of Battle
    92683,  -- Big Cauldron of Battle

    -- Shadowlands (9.x)
    307185, -- Potion Cauldron of Power
    391529, -- Cauldron of Ultimate Power          (added in 9.2)

    -- Dragonflight (10.x)
    382553, -- Elemental Cauldron of Power

    -- The War Within (11.x) – add cauldron IDs here when known
    -- Midnight (12.x)     – add cauldron IDs here when known

  }

  if TheWishingTable.Helpers.tableContainsValue(spellIds, spellId) then
    return true
  end

  return false
end
