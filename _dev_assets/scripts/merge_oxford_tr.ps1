# Load Raw English Data (Master Source for Levels)
$rawEnPath = "$PSScriptRoot\..\oxford_raw.json"
$enContent = Get-Content -Raw -Path $rawEnPath -Encoding UTF8 | ConvertFrom-Json

# Load Turkish Data
$rawTrPath = "$PSScriptRoot\..\oxford_tr.json"
$trJson = Get-Content -Raw -Path $rawTrPath -Encoding UTF8 | ConvertFrom-Json

# create Dictionary for fast lookup
$trDict = @{}
foreach ($item in $trJson) {
    if ($item.en) {
        $key = $item.en.Trim().ToLower()
        if (-not $trDict.ContainsKey($key)) {
            $trDict[$key] = $item.tr
        }
    }
}

$sets = @{}
$levelColors = @{
    'a1' = '#4CAF50';
    'a2' = '#8BC34A';
    'b1' = '#FFC107';
    'b2' = '#FF9800';
    'c1' = '#F44336';
    'c2' = '#9C27B0'
}

# Process English Data
$enContent.PSObject.Properties | ForEach-Object {
    $entry = $_.Value
    
    # Check validity
    if ($entry -is [System.Management.Automation.PSCustomObject] -and $entry.word) {
        $level = "uncategorized"
        if ($entry.cefr) { $level = $entry.cefr.ToLower() }
        
        if (-not $sets.ContainsKey($level)) {
            $sets[$level] = @()
        }
        
        $term = $entry.word.Trim()
        $lookupKey = $term.ToLower()
        
        # Decide Definition
        $originalDef = $entry.definition
        $def = $originalDef # Default to English
        
        # Override with Turkish if exists
        if ($trDict.ContainsKey($lookupKey)) {
            $trDef = $trDict[$lookupKey]
            # Capitalize first letter of TR def
            $trDef = $trDef.Substring(0,1).ToUpper() + $trDef.Substring(1)
            
            # COMBINED DEFINITION: Turkish + Original English (smaller)
            # This solves "single word logic" by keeping the rich context
            $def = "$trDef<div style='margin-top:8px; font-size:0.7em; opacity:0.7; font-style:italic;'>$originalDef</div>"
        }
        
        # Append Example if exists
        if ($entry.example) {
            $def += " (Ex: $($entry.example))"
        }
        
        $card = @{
            term = $term
            def  = $def
            type = $entry.type
        }
        
        $sets[$level] += $card
    }
}

$output = @()
$levels = @('a1', 'a2', 'b1', 'b2', 'c1', 'c2')

foreach ($lvl in $levels) {
    if ($sets.ContainsKey($lvl)) {
        $color = '#999'
        if ($levelColors.ContainsKey($lvl)) { $color = $levelColors[$lvl] }
        
        $setObj = @{
            id         = $lvl.ToUpper()
            title      = "Oxford 3000/5000 - $($lvl.ToUpper()) (TR)"
            desc       = "Essential vocabulary for level $($lvl.ToUpper())"
            thumbColor = $color
            cards      = $sets[$lvl]
        }
        $output += $setObj
    }
}

# JSON Output
$jsonOutput = $output | ConvertTo-Json -Depth 5
$jsContent = "window.OXFORD_DATA = $jsonOutput;"
$outPath = Join-Path "$PSScriptRoot\.." "js\oxford.js"

Set-Content -Path $outPath -Value $jsContent -Encoding UTF8

Write-Host "Merged Dictionary Created!"
foreach ($s in $output) {
    Write-Host "$($s.id): $($s.cards.Count) words"
}
