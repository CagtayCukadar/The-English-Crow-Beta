const fs = require('fs');
const path = require('path');

const rawPath = path.join(__dirname, '../oxford_raw.json');
const outPath = path.join(__dirname, '../js/oxford.js');

const rawData = fs.readFileSync(rawPath, 'utf8');
const data = JSON.parse(rawData);

// Group by CEFR
const sets = {};
const levelColors = {
    'a1': '#4CAF50', // Green
    'a2': '#8BC34A', // Light Green
    'b1': '#FFC107', // Amber
    'b2': '#FF9800', // Orange
    'c1': '#F44336', // Red
    'c2': '#9C27B0'  // Purple
};

// Iterate objects (the json is { "0": {...}, "1": {...} })
Object.values(data).forEach(entry => {
    // Normalize level
    let level = (entry.cefr || 'uncategorized').toLowerCase();

    // Skip if invalid or missing important data
    if (!entry.word || !entry.definition) return;

    // Clean text
    const term = entry.word;
    const def = entry.definition;
    const example = entry.example; // Optional

    if (!sets[level]) {
        sets[level] = [];
    }

    sets[level].push({
        term: term,
        def: def + (example ? ` (Ex: ${example})` : ''),
        type: entry.type
    });
});

// Format for App
const output = [];
const levels = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];

levels.forEach(lvl => {
    if (sets[lvl]) {
        output.push({
            id: lvl.toUpperCase(),
            title: `Oxford 3000/5000 - ${lvl.toUpperCase()}`,
            desc: `Essential vocabulary for level ${lvl.toUpperCase()}`,
            thumbColor: levelColors[lvl] || '#999',
            cards: sets[lvl]
        });
    }
});

// Write to file
const fileContent = `window.OXFORD_DATA = ${JSON.stringify(output, null, 2)};`;
fs.writeFileSync(outPath, fileContent);

console.log("Processed " + output.length + " levels.");
output.forEach(s => console.log(s.id + ": " + s.cards.length + " words"));
