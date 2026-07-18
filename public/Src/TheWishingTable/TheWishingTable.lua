-- init
TheWishingTable.TheWishingTable = {}
local feature = "TheWishingTable"

function TheWishingTable.TheWishingTable.speakconsumableSpell(spellId)
  local pickedLine

  -- player info
  local Class = TheWishingTable.Constants.Class
  local Race = TheWishingTable.Constants.Race
  local playerName, playerGender, playerClass, playerRace, playerLevel =
    TheWishingTable.Helpers.GetPlayerInformation()

  -- dateFormat
  local rawTime = date("*t")
  local d = {
    day = rawTime.day,
    month = rawTime.month,
    year = rawTime.year,
  }

  -- get the current place of the player
  local zoneName = GetZoneText()

  local spellCategory = spellId and TheWishingTable.SpellIds.getSpellCategory(spellId) or nil

  local spellName = "This feast"
  if spellId then
    local ok, name = pcall(GetSpellInfo, spellId)
    spellName = (ok and name) or "The consumable"
  end

  -- In debug mode, randomly pick a category for unknown spells
  if not spellCategory and TheWishingTableVars and TheWishingTableVars.debugMode == true then
    local categories = { "mage_table", "soul_well", "feast", "cauldron" }
    spellCategory = categories[fastrandom(1, #categories)]
  end

  -- prefix
  local prefixText = ""

  if (spellCategory == "mage_table") then
    prefixText = "Mage Table"
  elseif (spellCategory == "soul_well") then
    prefixText = "Soul Well"
  elseif (spellCategory == "cauldron") then
    prefixText = "Cauldron"
  elseif (spellCategory == "feast") then
    prefixText = "Feast"
  end

  local prefix = TheWishingTableVars.usePrefix == true and "[" .. prefixText .. " put down]: " or ""

  -- Time-of-day
  -- date("!%H") is the UTC hour; comparing with local gives us a rough timezone offset,
  -- which is good enough to guess whether someone is on UK time (UTC+0 GMT / UTC+1 BST).
  local localHour = tonumber(date("%H")) or 12
  local utcHour = tonumber(date("!%H")) or localHour
  local utcOffset = localHour - utcHour
  if utcOffset > 12 then
    utcOffset = utcOffset - 24
  elseif utcOffset < -12 then
    utcOffset = utcOffset + 24
  end
  local likelyUK = (utcOffset == 0 or utcOffset == 1)

  -- Genders
  local playerGuyGirl = TheWishingTable.Helpers.GetGuyGirl(playerGender)
  local playerManWoman = TheWishingTable.Helpers.GetManWoman(playerGender)
  local oppositeSex = "guys"

  if (playerGender == "male") then
    oppositeSex = "girls"
  end

  local consumableSpellLines = {
      "Feat, my pretties! FEAST!!",
      "I'd like to present a dessert that really blurs the line between the holiday cookie jar and a French cheese board. Prepare yourselves for melty, savory cheese paired with a ginger snap crunch.",
      "I call this next course 'East Meets the Uncharted.' We're taking a beloved Korean barbecue pork belly profile and pairing it with a rich blue cheese and fruit pairing that will completely surprise you.",
      "Cake or death?",
      "We dine well here in ${zoneName}, we eat ham and jam and Spam a lot!",
      "Spam! Spam! Spam!",
      "We have conduments!!, like ketchup! Ketchup is just a kind of fruit jam.",
      "WE NEED MORE CHICKEN NUGGETS!!! FAST!!!",
      "The best part of a cucumber tastes like the worst part of a watermelon.",
      "Try my 'special sauce'.",
      "One bad hamburger, you can destroy McDonald's!",
      "At least I know what I am putting in it.",
      "Great ${playerRace} food.",
      "Crust first!",
      "The events are so exciting. When I’m done I don’t want to eat. That's why we eat first!",
      "Everyone loves something at McDonald's, but this one is just deplorable...",
      "If you combine this wine and dinner, the new word is winner.",
      "Maybe this junk food is good and the other food is no good.",
      "The tortollans gave their live for this meal! (they got caught up in their own plastic soup)",
      "This mushroom dish is inspired by the Sporregar. There might be even authentic ingredients in there too!",
      "I present to you, my award winning: Teddy Bear 'Meatloaf'!",
      "We have a, not to be mentioned further, person in the group who is allergic to bananas. This table is bana free.",
      "Fresh food, fresh food! By popular demand, no purple colors in here.",
      "Let's sit down and talk family matters",
    }

  -- spell based
  table.insert(
    consumableSpellLines,
    spellName .. " can be consumed most successfully if you inhale it like a vacuum cleaner"
  )
  table.insert(
    consumableSpellLines,
    spellName .. " is an old-fashioned term... it's a beautiful, descriptive word."
  )
  table.insert(
    consumableSpellLines,
    "Show me someone without a " .. spellName .. ", and I'll show you a loser."
  )
  table.insert(
    consumableSpellLines,
    "A nation without " .. spellName .. " is not a nation at all. "
  )
  table.insert(
    consumableSpellLines,
    "Sometimes the best " .. spellName .. " are the ones you don't make."
  )

  -- Table type
  if (spellCategory == "feast") then
    table.insert(consumableSpellLines, spellName .. " explodes into a poisonous goo")
  end

  -- Class/Race based
  if (playerClass == Class.Warlock) then
    table.insert(consumableSpellLines, "I've conjured a pretty big demon for this epic feast!")
  end

  if (playerRace == Race.Undead or playerRace == Race.VoidElf) then
    table.insert(consumableSpellLines, "The ${playerRace} Diet... cannot make you gain weight.")
  end

  if (playerRace == Race.Dracthyr) then
    table.insert(
      consumableSpellLines,
      "Crispy 'chicken' tenders or wings drizzled with hot honey and tossed in peanut butter and a pinch of chili powder."
    )
  end

  if (playerRace == Race.HighmountainTauren or playerRace == Race.Tauren) then
    table.insert(
      consumableSpellLines,
      "I offer a selection of the best beef meats me and my fellow ${playerRace} have to offer."
    )
  end

  if (playerRace == Race.Undead) then
    table.insert(
      consumableSpellLines,
      "Home made chicken nuggets, Jamie knows that ground bones in there is what people love!"
    )
    table.insert(
      consumableSpellLines,
      "I've used my brethren's bones to create this delicious soupe. Try the marrow."
    )
  end

  if (playerRace == Race.HighmountainTauren or playerRace == Race.Tauren) then
    table.insert(consumableSpellLines, "With extra ranch sauce!")
    table.insert(consumableSpellLines, "I have for you, a pan seared Tauren-wellington.")
    table.insert(consumableSpellLines, "Some Tauren-wellington")
  end

  if (playerRace == Race.HighmountainTauren) then
    local highmountainTaurenHomelands = { "Highmountain", "Thunder Totem" }
    local highmountainTaurenHomeland =
      highmountainTaurenHomelands[fastrandom(1, #highmountainTaurenHomelands)]
    table.insert(consumableSpellLines, "With extra ranch sauce!")
    table.insert(consumableSpellLines, "I have for you, a pan seared Tauren-wellington.")
    table.insert(consumableSpellLines, "These are " .. highmountainTaurenHomeland .. " tacos.")
  end

  if (playerRace == Race.Tauren) then
    local taurenHomelands =
      { "Mulgore", "Thunder Bluff", "The Barrens", "Feralas", "Thousand Needles" }
    local taurenHomeland = taurenHomelands[fastrandom(1, #taurenHomelands)]
    table.insert(consumableSpellLines, "With extra ranch sauce!")
    table.insert(
      consumableSpellLines,
      "Some Tauren-wellington, sourced fresh from " .. taurenHomeland .. "."
    )
  end

  if (playerRace == Race.Dwarf or playerRace == Race.Earthen) then
    table.insert(consumableSpellLines, "Beer enhanced stew, right here!")
    table.insert(
      consumableSpellLines,
      "Sharing our people's specialty, micro-organism soup! (nothing much else grows here...)"
    )
  end

  if (playerClass == Class.DeathKnight) then
    table.insert(
      consumableSpellLines,
      "Hereby, a platter of cold appetizers. They will melt in your mouths."
    )
  end

  if (playerRace == Race.Dracthyr) then
    table.insert(consumableSpellLines, "These pastries are all well scaled.")
    table.insert(consumableSpellLines, "Dragon fruit, enhanced with some flambéed brandy!")
    table.insert(consumableSpellLines, "Et voilà! Crêpes Suzette, served battle side.")
  end

  if (playerRace == Race.LightforgedDraenei or playerClass == Class.Paladin or playerClass == Class.Priest) then
    table.insert(consumableSpellLines, "Some light snacks for everyone!")
  end

  if (playerClass == Class.Priest) then
    table.insert(consumableSpellLines, "The only thing I got left are some communion wafers.")
    table.insert(
      consumableSpellLines,
      "For you, I preset the Sacramental bread, including salted butter."
    )
  end

  if (playerClass == Class.Druid and playerGender == "male") then
    table.insert(
      consumableSpellLines,
      "Pot luck of forest fruit, game and perhaps some lost brethren."
    )
  end

  -- Zone specific
  -- Midnight
  if (zoneName == "The Voidspire" or zoneName == "The Dreamrift" or zoneName == "March on Quel'Danas") then
    table.insert(
      consumableSpellLines,
      "Did you know, these [Void Fragments] make a pretty good stew!"
    )
  end

  -- The war within
  if (zoneName == "Nerub-ar Palace" or zoneName == "Liberation of Undermine" or zoneName == "Mana Forge Omega" or zoneName == "Blackrock Depths") then
    table.insert(
      consumableSpellLines,
      "Going on truffle hunting in ${zoneName} was a great idea!, enjoy!"
    )
  end

  -- Shadowlands
  if (zoneName == "Revendreth" or zoneName == "Castle Nathria") then
    table.insert(
      consumableSpellLines,
      "This food will give +100 against enemies. There's enough garlic in here to kill every vampire in ${zoneName}."
    )
  end

  -- Mushrooms
  if (zoneName == "Naxxramas" or zoneName == "Zangarmarsh" or zoneName == "Hallowfall" or zoneName == "Fungal Folly" or zoneName == "The Fungal Vale") then
    table.insert(consumableSpellLines, "These mushrooms are probably not poisonous...")
  end

  -- Category-specific messages
  if spellCategory == "soul_well" then
    table.insert(consumableSpellLines, "Cookies for everyone!")
    table.insert(
      consumableSpellLines,
      "It's finally time to give back to the community. (But nobody knows I recycled their own souls...)"
    )
    table.insert(
      consumableSpellLines,
      "I've channelled all souls from ${zoneName} into this Sould Well."
    )
  elseif spellCategory == "mage_table" then
    table.insert(consumableSpellLines, "A wild mage table appeared!")
  elseif spellCategory == "feast" then
    table.insert(
      consumableSpellLines,
      "A feast has been laid before us! Time to eat well before battle."
    )
  elseif spellCategory == "cauldron" then
    if (playerClass == Class.Shaman) then
      table.insert(
        consumableSpellLines,
        "The Cauldron bubbles with power! Shamans have made an extra effort!"
      )
    end
  end

  -- time of the day based messaged

  if localHour < 4 then
    -- Midnight snack (00:00 – 03:59)
    table.insert(
      consumableSpellLines,
      "For the main course, we have a dish inspired by my absolute favorite midnight snack. It balances the heat of a ${zoneName} peanut sauce with the junk-food thrill of your favorite childhood takeout."
    )
  end

  if (localHour >= 2 and localHour < 3) then
    table.insert(
      consumableSpellLines,
      "Tonight's appetizer takes a culinary trip to a 2am diner menu. We are serving a gourmet grilled cheese with a hidden, crunchy pickle center, designed to be dipped and conquered."
    )
  end

  if localHour >= 4 and localHour < 5 then
    -- 4am: the 'are you okay?' hour
    table.insert(
      consumableSpellLines,
      "The sun hasn't decided what it's doing yet, but we have food. Classic raid priorities."
    )
  end

  if localHour >= 5 and localHour < 10 then
    -- Breakfast (05:00 – 09:59)
    table.insert(
      consumableSpellLines,
      "First meal of the day, served right here in ${zoneName}. No toast, but the company is excellent."
    )

    if (playerClass == Class.Monk) then
      table.insert(
        consumableSpellLines,
        "This time, I'll make an exception to eat before training."
      )
    end
  end

  if localHour >= 10 and localHour < 12 then
    -- Brunch (10:00 – 11:59)
    table.insert(
      consumableSpellLines,
      "Too late for breakfast, too early for lunch – so we call it a feast and move on."
    )
    if (localHour == 11 and (Race.BloodElf or Race.NightElf or Race.Nightborne or Race.Haranir)) then
      table.insert(
        consumableSpellLines,
        "Elevenses! The most civilised tradition in all the realms. Table is up."
      )
    end
  end

  if localHour >= 12 and localHour < 14 then
    -- Lunch (12:00 – 13:59)
    table.insert(
      consumableSpellLines,
      "Dim sum energy at noon – a little of everything for everyone. Table is up!"
    )
    table.insert(
      consumableSpellLines,
      "You'll have exactly 10 seconds in this all-you-can-eat lunch."
    )
  end

  if localHour >= 14 and localHour < 18 then
    -- Afternoon tea (14:00 – 17:59)
    if likelyUK then
      table.insert(
        consumableSpellLines,
        "Right then – put the kettle on! Oh wait, we've got a whole banquet. Even better, innit."
      )
      table.insert(
        consumableSpellLines,
        "Cor blimey – tea time in ${zoneName}! Scones optional, attendance mandatory."
      )
    end
    table.insert(
      consumableSpellLines,
      "Afternoon tea is served! Whether you call it tea, merienda, or just the '4pm snack' --food's up."
    )
    table.insert(
      consumableSpellLines,
      "Four o'clock feast – internationally recognised as the most civilised time to eat."
    )
    table.insert(
      consumableSpellLines,
      "The afternoon slump has been cancelled. There is food. You are welcome."
    )

    if localHour == 16 then
      table.insert(
        consumableSpellLines,
        "Brotzeit! The Dwarfs were right – 4pm absolutely deserves a snack. Table delivered."
      )
    end
  end

  if localHour >= 18 and localHour < 21 then
    -- Dinner (18:00 – 20:59)
    table.insert(
      consumableSpellLines,
      "Dinner is served! Pull up a chair – the table won't last forever and neither will the boss."
    )
  end

  if localHour >= 21 then
    -- Late-night supper (21:00 – 23:59)
    table.insert(
      consumableSpellLines,
      "I brought the fridge, the microwave and some paper plates for a late-night supper!"
    )
  end

  -- Public festivities
  -- New Year's Day
  if (d.month == 1 and d.day == 1) then
    table.insert(consumableSpellLines, "I've conjured a pretty big demon for this epic feast!")
  end

  -- Epiphany / Three Kings' Day
  if (d.month == 1 and d.day == 6) then
    table.insert(
      consumableSpellLines,
      "I've prepared for you, the diner of the Three Kings. Unfortunately, only myrrh was edible, sorry..."
    )
  end

  -- Valentine's Day
  if (d.month == 2 and d.day == 14) then  end

  -- Imbolc / Candlemas (Celtic spring festival)
  if (d.month == 2 and d.day == 1) then
    table.insert(
      consumableSpellLines,
      "Imbolc --�the first stirrings of spring! New beginnings fuel our feast."
    )
  end

  -- International Women's Day
  if (d.month == 3 and d.day == 8) then
    table.insert(consumableSpellLines, "The women asked if I could prepare something for them.")
  end

  -- St. Patrick's Day
  if (d.month == 3 and d.day == 17) then
    table.insert(
      consumableSpellLines,
      "Luck o' the Irish! This feast is blessed with fortune --�may your rolls be crits!"
    )
    table.insert(
      consumableSpellLines,
      "Erin go Bragh! Raise your goblets --�the table's got the luck of the Emerald Isle."
    )
    table.insert(consumableSpellLines, "Sorry, today only collard greens!")
  end

  -- April Fools' Day
  if (d.month == 4 and d.day == 1) then
    table.insert(
      consumableSpellLines,
      "Feast has been placed... or has it? Trust nobody, but eat anyway."
    )
  end

  -- Earth Day
  if (d.month == 4 and d.day == 22) then
    table.insert(
      consumableSpellLines,
      "Azeroth! This table celebrates the bounty of our world --�sustainably summoned."
    )
  end

  -- Cinco de Mayo
  if (d.month == 5 and d.day == 5) then
    -- table.insert(consumableSpellLines, "�Viva Cinco de Mayo! Let's celebrate with feasts and felicity!")
  end

  -- International Workers' Day / May Day / Beltane (Celtic festival)
  if (d.month == 5 and d.day == 1) then
    table.insert(
      consumableSpellLines,
      "May Day! Beltane fires blaze --�this table is blessed by ancient magic."
    )
    table.insert(
      consumableSpellLines,
      "International Workers' Day --�a feast for those who labor! All hands welcome at the table."
    )
  end

  -- Star Wars Day
  if (d.month == 5 and d.day == 4) then
    table.insert(consumableSpellLines, "Today: Roast Nuna! May the Force be with you!")
  end

  -- Summer Solstice (Litha)
  if (d.month == 6 and d.day >= 20 and d.day <= 21) then
    -- table.insert(consumableSpellLines, "Litha! The summer sun reaches its peak --�feast in eternal daylight!")
    -- table.insert(consumableSpellLines, "Summer Solstice --�the longest day deserves the longest feast!")
  end

  -- Pride Day
  if (d.month == 6 and d.day == 28) then
    table.insert(consumableSpellLines, "Pride day! Enjoy some rainbow cake!")
  end

  -- Independence Day (US)
  if (d.month == 7 and d.day == 4) then
    -- table.insert(consumableSpellLines, "Independence Day! Freedom and feasts --�that's what Azeroth was founded on.")
  end

  -- Bastille Day (France)
  if (d.month == 7 and d.day == 14) then
    -- table.insert(consumableSpellLines, "Liberté, égalité, fraternité! Vive la France – and vive this feast!")
  end

  -- Lammas (Lughnasadh, Celtic harvest festival)
  if (d.month == 8 and d.day == 1) then
    table.insert(
      consumableSpellLines,
      "Lammas! The first harvest is here --�bread and bounty for all!"
    )
  end

  -- International Cat Day
  if (d.month == 8 and d.day == 8) then
    table.insert(
      consumableSpellLines,
      "International Cat Day! Enjoy the various cats I found in this lovely cat stew!"
    )
  end

  -- Autumn Equinox (Mabon, Celtic harvest festival)
  if (d.month == 9 and d.day >= 22 and d.day <= 23) then
    -- table.insert(consumableSpellLines, "Mabon! The harvest is balanced --�light and dark, feast and famine, no more!")
    table.insert(consumableSpellLines, "Here's the food, ritually prepared at the Hill of Tara!")
  end

  -- Oktoberfest (mid-September to early October)
  if (d.month == 9 and d.day >= 16) or (d.month == 10 and d.day <= 3) then
    -- table.insert(consumableSpellLines, "Prost! Oktoberfest is here --�this table comes with extra sausage and celebration!")
  end

  -- Halloween / Samhain (Celtic new year)
  if (d.month == 10 and d.day == 31) then
    -- table.insert(consumableSpellLines, "Samhain! The veil is thin --�the spirits feast with us tonight!")
    -- table.insert(consumableSpellLines, "Halloween --�spooky feasts for spooky raiders. Boo!")
    table.insert(
      consumableSpellLines,
      "Today's desert platter with your your favourite buff: SUGAR RUSH!"
    )
  end

  -- Day of the Dead (Día de Muertos) – Oct 31 - Nov 2
  if (d.month == 10 and d.day == 31) or (d.month == 11 and d.day >= 1 and d.day <= 2) then
    -- table.insert(consumableSpellLines, "D�a de Muertos! We celebrate with feasts and flowers for those who came before us.")
    table.insert(consumableSpellLines, "Today's specialty: Queso de la muerte!")
  end

  -- Guy Fawkes Night (UK)
  if (d.month == 11 and d.day == 5) then
    table.insert(consumableSpellLines, "Remember, remember, the 5th of Cucumber!")
  end

  -- Remembrance Day / Veterans Day
  if (d.month == 11 and d.day == 11) then
    -- table.insert(consumableSpellLines, "Remembrance Day --�we honor those who served. This feast is for the brave.")
    -- table.insert(consumableSpellLines, "Veterans Day --�salute to all who fought! May this table sustain you through the next battle.")
  end

  -- Thanksgiving (US, ~4th Thursday of November)
  if (d.month == 11 and d.day >= 22 and d.day <= 28) then
    table.insert(
      consumableSpellLines,
      "Thanksgiving! Gratitude and gobbling --�the only two things that matter."
    )
  end

  -- Winter Solstice (Yule)
  if (d.month == 12 and d.day >= 20 and d.day <= 21) then
    -- table.insert(consumableSpellLines, "Yule! The winter sun returns --�and so does the feast, burning bright as yuletide logs!")
    -- table.insert(consumableSpellLines, "Winter Solstice --�the darkest day, the brightest feast! Light returns through food and fellowship.")
  end

  -- New Year's Eve
  if (d.month == 12 and d.day == 31) then
    -- table.insert(consumableSpellLines, "New Year's Eve! Feast tonight, conquests tomorrow!")
  end

  -- ZODIAC SIGNS

  -- Chinese New Year (lunar calendar --�late January through mid-February)
  local chineseYearIndex = (d.year - 2020) % 12

  if chineseYearIndex == 0 then
    table.insert(consumableSpellLines, "Rat stew, served table-side!")
  elseif chineseYearIndex == 1 then
    table.insert(consumableSpellLines, "Ox stew, served table-side!")
  elseif chineseYearIndex == 2 then
    table.insert(consumableSpellLines, "Tiger stew, served table-side!")
  elseif chineseYearIndex == 3 then
    table.insert(consumableSpellLines, "Rabbit stew, served table-side!")
  elseif chineseYearIndex == 4 then
    table.insert(consumableSpellLines, "dragon stew, served table-side!")
  elseif chineseYearIndex == 5 then
    table.insert(consumableSpellLines, "Snake stew, served table-side!")
  elseif chineseYearIndex == 6 then
    table.insert(consumableSpellLines, "Horse stew, served table-side!")
  elseif chineseYearIndex == 7 then
    table.insert(consumableSpellLines, "Goat stew, served table-side!")
  elseif chineseYearIndex == 8 then
    table.insert(consumableSpellLines, "Monkey stew, served table-side!")
  elseif chineseYearIndex == 9 then
    table.insert(consumableSpellLines, "Rooster stew, served table-side!")
  elseif chineseYearIndex == 10 then
    table.insert(consumableSpellLines, "Dog stew, served table-side!")
  elseif chineseYearIndex == 11 then
    table.insert(consumableSpellLines, "Pig stew, served table-side!")
  end

  if (d.month == 1 and d.day >= 21) or (d.month == 2 and d.day <= 20) then
    table.insert(
      consumableSpellLines,
      "New Year, new raid tier, new provisions! Let's celebrate with red lanterns and dumplings."
    )
  end

  -- Western Zodiac Signs
  -- Capricorn (Dec 22 - Jan 19)
  if (d.month == 12 and d.day >= 22) or (d.month == 1 and d.day <= 19) then
    table.insert(
      consumableSpellLines,
      "Capricorn season brings ambition and discipline to the table. Let's climb this raid ladder together!"
    )
  end

  -- Aquarius (Jan 20 - Feb 18)
  if (d.month == 1 and d.day >= 20) or (d.month == 2 and d.day <= 18) then
    table.insert(
      consumableSpellLines,
      "Aquarius energy! Innovative feasts for unconventional raiders --�this table thinks outside the dungeon."
    )
  end

  -- Pisces (Feb 19 - Mar 20)
  if (d.month == 2 and d.day >= 19) or (d.month == 3 and d.day <= 20) then
    table.insert(
      consumableSpellLines,
      "Pisces season brings intuition and compassion. A feast for dreamers and healers alike."
    )
  end

  -- Aries (Mar 21 - Apr 19)
  if (d.month == 3 and d.day >= 21) or (d.month == 4 and d.day <= 19) then
    table.insert(
      consumableSpellLines,
      "Aries brings courage and boldness! This feast fuels the fiercest battles."
    )
  end

  -- Taurus (Apr 20 - May 20)
  if (d.month == 4 and d.day >= 20) or (d.month == 5 and d.day <= 20) then
    table.insert(
      consumableSpellLines,
      "Taurus season --�steadfast, reliable, and absolutely delicious. A feast built to last."
    )
  end

  -- Gemini (May 21 - Jun 20)
  if (d.month == 5 and d.day >= 21) or (d.month == 6 and d.day <= 20) then
    table.insert(
      consumableSpellLines,
      "Gemini vibes! Two helpings, double the conversation, infinite raid strategy banter."
    )
  end

  -- Cancer (Jun 21 - Jul 22)
  if (d.month == 6 and d.day >= 21) or (d.month == 7 and d.day <= 22) then
    table.insert(
      consumableSpellLines,
      "Cancer season brings comfort and care. This feast is home-cooked and guild-approved."
    )
  end

  -- Leo (Jul 23 - Aug 22)
  if (d.month == 7 and d.day >= 23) or (d.month == 8 and d.day <= 22) then
    table.insert(
      consumableSpellLines,
      "Leo season! Feast like royalty --�this table is the king or queen of provisions."
    )
  end

  -- Virgo (Aug 23 - Sep 22)
  if (d.month == 8 and d.day >= 23) or (d.month == 9 and d.day <= 22) then
    table.insert(
      consumableSpellLines,
      "Virgo season brings attention to detail. Every ingredient perfectly placed, every bite optimized for performance."
    )
  end

  -- Libra (Sep 23 - Oct 22)
  if (d.month == 9 and d.day >= 23) or (d.month == 10 and d.day <= 22) then
    table.insert(
      consumableSpellLines,
      "Libra season! Balanced nutrients, elegant presentation, everyone gets a fair share of the feast."
    )
  end

  -- Scorpio (Oct 23 - Nov 21)
  if (d.month == 10 and d.day >= 23) or (d.month == 11 and d.day <= 21) then
    table.insert(
      consumableSpellLines,
      "Scorpio intensity! This feast has depth, secrets, and enough spice to take down mythic bosses."
    )
  end

  -- Sagittarius (Nov 22 - Dec 21)
  if (d.month == 11 and d.day >= 22) or (d.month == 12 and d.day <= 21) then
    table.insert(
      consumableSpellLines,
      "Sagittarius season --�adventurous, optimistic, and ready to explore new raid content on a full stomach!"
    )
  end

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

-- Test mode wrappers for group detection (allows testing without real groups)
local function isInTestGroup()
  return TheWishingTableVars and TheWishingTableVars.testGroupMode and true or false
end

local function testIsInGroup(category)
  if isInTestGroup() then
    local mode = TheWishingTableVars.testGroupMode
    if mode == "party" or mode == "raid" then
      return true
    end
    return false
  end
  return IsInGroup(category)
end

local function testIsInRaid(category)
  if isInTestGroup() then
    local mode = TheWishingTableVars.testGroupMode
    if mode == "raid" then
      return true
    end
    return false
  end
  return IsInRaid(category)
end

local function getBroadcastChannel(broadCastChannels, canBroadcastToInstance)
  local canBroadcastToParty = canBroadcastParty(broadCastChannels)
  local canBroadcastToRaid = canBroadcastRaid(broadCastChannels)

  -- LFD/LFR/battleground groups talk through instance chat.
  if testIsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
    if not (canBroadcastToInstance == true) then
      return nil
    end

    if testIsInRaid(LE_PARTY_CATEGORY_INSTANCE) then
      return canBroadcastToRaid and "INSTANCE_CHAT" or nil
    end

    return canBroadcastToParty and "INSTANCE_CHAT" or nil
  end

  if testIsInRaid() then
    return canBroadcastToRaid and "RAID" or nil
  end

  if testIsInGroup() then
    return canBroadcastToParty and "PARTY" or nil
  end

  return nil
end

local function determineChannel()
  return getBroadcastChannel(
    TheWishingTableVars.consumableSpell_channel,
    TheWishingTableVars.consumableSpell_instance
  )
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
    local isDebugMode = TheWishingTableVars and TheWishingTableVars.debugMode == true
    local isKnownSpell = TheWishingTable.SpellIds.isConsumableSpellCasting(spellID)

    -- In debug mode, allow any spell through
    if not isKnownSpell and not isDebugMode then return end

    -- A spell with a cast time fires START and then SUCCEEDED for the same cast;
    -- announce it only once.
    local dedupeKey = castGUID or ("spell:" .. tostring(spellID))
    if (dedupeKey == lastAnnouncedKey and (GetTime() - lastAnnouncedTime) < 10) then return end

    local channel = determineChannel()
    if not channel then
      TheWishingTable.debugPrint(
        feature,
        "No broadcast channel (not in a group, or channel disabled in /twt)."
      )
      return
    end

    -- pcall keeps Midnight's secret-value restrictions from throwing Lua errors mid-fight;
    -- worst case the announcement is skipped.
    local ok, line = pcall(function()
      return TheWishingTable.TheWishingTable.speakconsumableSpell(spellID)
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
    TheWishingTable.debugPrint(
      feature,
      "[" .. channel .. "] " .. line .. (sent and "" or " (send failed)")
    )
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

      if not spellID then return end

      announceConsumablesPutDown(castGUID, spellID)
    end
  end)
end

TheWishingTable.TheWishingTable.Run()
