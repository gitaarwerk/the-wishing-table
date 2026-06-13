#!/usr/bin/env node

"use strict";

const fs = require("fs");
const path = require("path");
const luaparse = require("luaparse");

const ROOT = path.join(__dirname, "..");
const SRC = path.join(ROOT, "public", "Src");

let passed = 0;
let failed = 0;

function test(name, fn) {
  try {
    fn();
    console.log(`  ✓ ${name}`);
    passed++;
  } catch (err) {
    console.error(`  ✗ ${name}`);
    console.error(`    ${err.message}`);
    failed++;
  }
}

function assert(condition, message) {
  if (!condition) throw new Error(message || "assertion failed");
}

function readFile(relPath) {
  return fs.readFileSync(path.join(SRC, relPath), "utf8");
}

function parseLua(content) {
  return luaparse.parse(content, { luaVersion: "5.1", comments: true });
}

function extractTableBody(content, marker) {
  const start = content.indexOf(marker);
  if (start === -1) return null;
  const braceAt = content.indexOf("{", start + marker.length - 1);
  let depth = 0;
  for (let i = braceAt; i < content.length; i++) {
    if (content[i] === "{") depth++;
    else if (content[i] === "}") {
      if (--depth === 0) return content.slice(braceAt + 1, i);
    }
  }
  return null;
}

// ─────────────────────────────────────────────
// Generic compile check — every Lua source file
// ─────────────────────────────────────────────
console.log("\nCompile check (Lua syntax)\n");

const luaFiles = [
  "Interface.lua",
  "Constants/Constants.lua",
  "Helpers.lua",
  "SpellIds.lua",
  "TheWhishingTable/TheWhishingTable.lua",
];

for (const relPath of luaFiles) {
  test(`${relPath} — no syntax errors`, () => {
    parseLua(readFile(relPath));
  });
}

// ─────────────────────────────────────────────
// SpellIds.lua
// ─────────────────────────────────────────────
console.log("\nSpellIds.lua\n");

const spellContent = readFile("SpellIds.lua");

test("isConsumableSpellCasting function is defined", () => {
  assert(spellContent.includes("isConsumableSpellCasting"), "function not found");
});

test("Warlock Ritual of Souls (29893) is listed", () => {
  assert(/\b29893\b/.test(spellContent), "spell ID 29893 missing");
});

test("WotLK Ritual of Refreshment (58659) is listed", () => {
  assert(/\b58659\b/.test(spellContent), "spell ID 58659 missing");
});

test("Conjure Refreshment Table (190336) is listed", () => {
  assert(/\b190336\b/.test(spellContent), "spell ID 190336 missing");
});

test("at least one cooking feast ID is listed", () => {
  const feastIds = [57301, 57425, 87560, 126492, 185706, 199427, 259409, 308458, 382956];
  const found = feastIds.some((id) => new RegExp(`\\b${id}\\b`).test(spellContent));
  assert(found, "no cooking feast ID found");
});

test("at least one alchemy cauldron ID is listed", () => {
  const cauldronIds = [92682, 92683, 307185, 391529, 382553];
  const found = cauldronIds.some((id) => new RegExp(`\\b${id}\\b`).test(spellContent));
  assert(found, "no alchemy cauldron ID found");
});

test("spellIds table is not empty", () => {
  const mageTable = extractTableBody(spellContent, "TheWishingTable.SpellIds.MageTable = {");
  const soulWell = extractTableBody(spellContent, "TheWishingTable.SpellIds.SoulWell = {");
  const feast = extractTableBody(spellContent, "TheWishingTable.SpellIds.Feast = {");
  const cauldron = extractTableBody(spellContent, "TheWishingTable.SpellIds.Cauldron = {");

  assert(mageTable !== null || soulWell !== null || feast !== null || cauldron !== null, "spellIds table not found");

  const allEntries = [
    ...(mageTable ? mageTable.split("\n").filter((l) => /^\s*\d+/.test(l)) : []),
    ...(soulWell ? soulWell.split("\n").filter((l) => /^\s*\d+/.test(l)) : []),
    ...(feast ? feast.split("\n").filter((l) => /^\s*\d+/.test(l)) : []),
    ...(cauldron ? cauldron.split("\n").filter((l) => /^\s*\d+/.test(l)) : [])
  ];
  assert(allEntries.length > 0, "spellIds tables are empty");
});

// ─────────────────────────────────────────────
// TheWishingTable.lua
// ─────────────────────────────────────────────
console.log("\nTheWhishingTable/TheWhishingTable.lua\n");

const mainContent = readFile("TheWhishingTable/TheWhishingTable.lua");

test("speakconsumableSpell function is defined", () => {
  assert(
    mainContent.includes("function TheWishingTable.TheWishingTable.speakconsumableSpell"),
    "speakconsumableSpell not found"
  );
});

test("Run function is defined", () => {
  assert(
    mainContent.includes("function TheWishingTable.TheWishingTable.Run"),
    "Run not found"
  );
});

test("consumableSpellLines table exists", () => {
  assert(mainContent.includes("consumableSpellLines"), "consumableSpellLines not found");
});

test("consumableSpellLines has at least one inline entry", () => {
  const body = extractTableBody(mainContent, "consumableSpellLines = {");
  assert(body !== null, "consumableSpellLines table not found");
  const entries = body.split("\n").filter((l) => /^\s*["']/.test(l));
  assert(entries.length > 0, "consumableSpellLines initial table is empty");
});

test("spell ID guard is present (isConsumableSpellCasting)", () => {
  assert(mainContent.includes("isConsumableSpellCasting"), "spell ID guard missing");
});

test("deduplication guard is present", () => {
  assert(mainContent.includes("lastAnnouncedKey"), "dedup logic missing");
});

test("chat lockdown check is present", () => {
  assert(mainContent.includes("InChatMessagingLockdown"), "lockdown check missing");
});

test("UNIT_SPELLCAST_SUCCEEDED is registered", () => {
  assert(mainContent.includes("UNIT_SPELLCAST_SUCCEEDED"), "event not registered");
});

test("UNIT_SPELLCAST_START is registered", () => {
  assert(mainContent.includes("UNIT_SPELLCAST_START"), "event not registered");
});

test("getBroadcastChannel handles instance groups", () => {
  assert(mainContent.includes("LE_PARTY_CATEGORY_INSTANCE"), "instance group handling missing");
});

// ─────────────────────────────────────────────
// Helpers.lua — shared utilities
// ─────────────────────────────────────────────
console.log("\nHelpers.lua\n");

const helpersContent = readFile("Helpers.lua");

test("tableContainsValue is defined", () => {
  assert(helpersContent.includes("tableContainsValue"), "tableContainsValue missing");
});

test("GetPlayerInformation is defined", () => {
  assert(helpersContent.includes("GetPlayerInformation"), "GetPlayerInformation missing");
});

test("parseText is defined", () => {
  assert(helpersContent.includes("parseText"), "parseText missing");
});

// ─────────────────────────────────────────────
// Constants.lua
// ─────────────────────────────────────────────
console.log("\nConstants/Constants.lua\n");

const constantsContent = readFile("Constants/Constants.lua");

test("Constants.Class table is defined", () => {
  assert(constantsContent.includes("TheWishingTable.Constants.Class"), "Class constants missing");
});

test("Constants.Race table is defined", () => {
  assert(constantsContent.includes("TheWishingTable.Constants.Race"), "Race constants missing");
});

// ─────────────────────────────────────────────
// Summary
// ─────────────────────────────────────────────
console.log("\n" + "─".repeat(50));
console.log(`  ${passed} passed, ${failed} failed`);
console.log("─".repeat(50) + "\n");

if (failed > 0) process.exit(1);
process.exit(0);
