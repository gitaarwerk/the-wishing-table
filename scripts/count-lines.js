#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const projectRoot = path.join(__dirname, "..");
const mainFilePath = path.join(
  projectRoot,
  "public",
  "Src",
  "TheWhishingTable",
  "TheWhishingTable.lua"
);
const spellIdsFilePath = path.join(projectRoot, "public", "Src", "SpellIds.lua");

const functions = [
  { name: "speakconsumableSpell", tableName: "consumableSpellLines" },
];

function extractFunctionBody(content, funcName) {
  const marker = `function TheWishingTable.TheWishingTable.${funcName}`;
  const start = content.indexOf(marker);
  if (start === -1) return null;

  const nextMarker = content.indexOf(
    "function TheWishingTable.TheWishingTable.speak",
    start + marker.length
  );
  return nextMarker === -1 ? content.slice(start) : content.slice(start, nextMarker);
}

function extractTableBlock(body, tableName) {
  const pattern = new RegExp(`(?:local\\s+)?${tableName}\\s*=?\\s*\\n?\\s*\\{`);
  const match = body.match(pattern);
  if (!match) return "";

  const braceStart = body.indexOf("{", match.index + match[0].length - 1);
  let depth = 0;
  for (let i = braceStart; i < body.length; i++) {
    if (body[i] === "{") depth++;
    else if (body[i] === "}") {
      depth--;
      if (depth === 0) return body.slice(braceStart + 1, i);
    }
  }
  return "";
}

function countInlineEntries(tableContent) {
  return tableContent.split("\n").filter((line) => /^\s*["']/.test(line)).length;
}

function countInserts(body, tableName) {
  const pattern = new RegExp(`table\\.insert\\s*\\(\\s*${tableName}`, "g");
  return (body.match(pattern) || []).length;
}

function countFunction(content, funcName, tableName) {
  const body = extractFunctionBody(content, funcName);
  if (!body) return { inline: 0, inserts: 0, total: 0 };

  const tableBlock = extractTableBlock(body, tableName);
  const inline = countInlineEntries(tableBlock);
  const inserts = countInserts(body, tableName);

  return { inline, inserts, total: inline + inserts };
}

function countSpellIds(content) {
  const tableStart = content.indexOf("local spellIds = {");
  if (tableStart === -1) return 0;

  const braceStart = content.indexOf("{", tableStart);
  let depth = 0;
  let tableContent = "";
  for (let i = braceStart; i < content.length; i++) {
    if (content[i] === "{") depth++;
    else if (content[i] === "}") {
      depth--;
      if (depth === 0) {
        tableContent = content.slice(braceStart + 1, i);
        break;
      }
    }
  }
  return tableContent.split("\n").filter((line) => /^\s*\d+[,\s]/.test(line)).length;
}

function run() {
  if (!fs.existsSync(mainFilePath)) {
    console.error(`File not found: ${mainFilePath}`);
    process.exit(1);
  }
  if (!fs.existsSync(spellIdsFilePath)) {
    console.error(`File not found: ${spellIdsFilePath}`);
    process.exit(1);
  }

  const content = fs.readFileSync(mainFilePath, "utf8");
  const spellIdsContent = fs.readFileSync(spellIdsFilePath, "utf8");

  console.log("Lines per function in TheWishingTable.lua\n");

  const stats = {};
  let grandTotal = 0;

  for (const { name, tableName } of functions) {
    const { inline, inserts, total } = countFunction(content, name, tableName);
    stats[name] = { inline, inserts, total };
    grandTotal += total;

    const bar = "█".repeat(Math.max(1, Math.ceil(total / 5)));
    console.log(
      `${name.padEnd(24)} ${total.toString().padStart(3)} lines  (${inline} inline + ${inserts} inserts)  ${bar}`
    );
  }

  const spellIdCount = countSpellIds(spellIdsContent);
  console.log(`\n${"Spell IDs tracked".padEnd(24)} ${spellIdCount.toString().padStart(3)}`);

  console.log("\n" + "─".repeat(60));
  console.log(`${"TOTAL".padEnd(24)} ${grandTotal.toString().padStart(3)} lines`);
  console.log("─".repeat(60) + "\n");

  const markdown = `## Lines per function

| Function | Inline | Inserts | Total |
|----------|--------|---------|-------|
${functions
  .map(
    ({ name }) =>
      `| ${name} | ${stats[name].inline} | ${stats[name].inserts} | ${stats[name].total} |`
  )
  .join("\n")}
| **TOTAL** | | | **${grandTotal}** |

Spell IDs tracked: **${spellIdCount}**

Generated: ${new Date().toISOString()}
`;

  const mdFile = path.join(projectRoot, ".release-stats.md");
  const jsonFile = path.join(projectRoot, ".release-stats.json");

  fs.writeFileSync(mdFile, markdown);
  fs.writeFileSync(
    jsonFile,
    JSON.stringify(
      {
        functions: stats,
        total: grandTotal,
        spellIds: spellIdCount,
        generated: new Date().toISOString(),
      },
      null,
      2
    )
  );

  console.log(`Written: ${mdFile}`);
  console.log(`Written: ${jsonFile}`);
}

try {
  run();
  process.exit(0);
} catch (err) {
  console.error("Error:", err.message);
  process.exit(1);
}
