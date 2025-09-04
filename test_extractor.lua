-- Test Extractor for Specific Experiments
-- Script untuk mengecek eksperimen tertentu termasuk CaughtLegendaryExperiment

print("🔬 Test Extractor - Analyzing Specific Experiments")

-- List eksperimen yang menarik untuk dianalisis
local targetExperiments = {
    "AutoFishingExperiment",
    "CaughtLegendaryExperiment", 
    "FishingAidMobileExperiment",
    "FishingConfettiExperiment",
    "FishingPolesExperiment",
    "EasyMinigameExperiment",
    "GamepadEasyShakeExperiment",
    "OneLessShakeExperiment",
    "OneMoreShakeExperiment"
}

-- Base path untuk eksperimen
local basePath = "ReplicatedStorage.shared.modules.ABTestExperiments.Experiments."

-- Function untuk navigate ke path
local function getExperiment(experimentName)
    local fullPath = basePath .. experimentName
    local success, module = pcall(function()
        local parts = string.split(fullPath, ".")
        local current = game
        for _, part in ipairs(parts) do
            current = current[part]
        end
        return current
    end)
    return success and module or nil, fullPath
end

-- Function untuk deep analysis
local function deepAnalyze(experimentName)
    print("\n" .. string.rep("=", 50))
    print("🎯 DEEP ANALYSIS: " .. experimentName)
    print(string.rep("=", 50))
    
    local module, fullPath = getExperiment(experimentName)
    
    if not module then
        print("❌ Not found: " .. experimentName)
        return
    end
    
    print("✅ Found: " .. fullPath)
    print("Type: " .. module.ClassName)
    
    if module:IsA("ModuleScript") then
        local success, content = pcall(require, module)
        if success then
            print("📋 Content Analysis:")
            print("Content Type: " .. type(content))
            
            if type(content) == "table" then
                print("\n� DETAILED TABLE CONTENTS:")
                local count = 0
                for key, value in pairs(content) do
                    count = count + 1
                    local valueType = type(value)
                    local valueStr = tostring(value)
                    
                    -- Handle different value types
                    if valueType == "function" then
                        valueStr = "function()"
                    elseif valueType == "table" then
                        -- Try to show table contents
                        local tableStr = "{"
                        local tableCount = 0
                        for k, v in pairs(value) do
                            tableCount = tableCount + 1
                            if tableCount <= 3 then
                                tableStr = tableStr .. tostring(k) .. "=" .. tostring(v) .. ", "
                            end
                        end
                        if tableCount > 3 then
                            tableStr = tableStr .. "... +" .. (tableCount-3) .. " more"
                        end
                        tableStr = tableStr .. "}"
                        valueStr = tableStr
                    elseif valueType == "boolean" then
                        valueStr = value and "true" or "false"
                    elseif string.len(valueStr) > 80 then
                        valueStr = string.sub(valueStr, 1, 80) .. "..."
                    end
                    
                    print(string.format("  [%d] %s: %s (%s)", 
                        count, tostring(key), valueStr, valueType))
                end
                
                print(string.format("\n📈 Total Properties: %d", count))
                
                -- Look for specific patterns
                local patterns = {
                    fishing = {"fish", "reel", "cast", "catch", "bobber"},
                    rewards = {"reward", "prize", "bonus", "multiplier"},
                    config = {"config", "setting", "param", "option"},
                    state = {"state", "enable", "active", "disabled"},
                    legendary = {"legendary", "mythic", "rare", "epic"}
                }
                
                print("\n� PATTERN ANALYSIS:")
                for patternName, keywords in pairs(patterns) do
                    local found = {}
                    for key, _ in pairs(content) do
                        local keyLower = string.lower(tostring(key))
                        for _, keyword in ipairs(keywords) do
                            if string.find(keyLower, keyword) then
                                table.insert(found, key)
                                break
                            end
                        end
                    end
                    if #found > 0 then
                        print(string.format("  %s: %s", patternName, table.concat(found, ", ")))
                    end
                end
                
            else
                print("Content Value: " .. tostring(content))
            end
        else
            print("❌ Failed to require: " .. tostring(content))
        end
    else
        print("❌ Not a ModuleScript")
    end
    
    print(string.rep("-", 50))
end

-- Analyze all target experiments
print("� Starting deep analysis of " .. #targetExperiments .. " experiments...")

for i, experimentName in ipairs(targetExperiments) do
    deepAnalyze(experimentName)
    
    -- Add small delay to prevent overwhelming output
    if i < #targetExperiments then
        wait(0.1)
    end
end

-- Function untuk quick check semua eksperimen
local function quickCheckAll()
    print("\n🔍 QUICK CHECK - All Available Experiments:")
    print(string.rep("=", 60))
    
    local baseModule = game:GetService("ReplicatedStorage").shared.modules.ABTestExperiments.Experiments
    local found = 0
    local working = 0
    
    for _, child in ipairs(baseModule:GetChildren()) do
        if child:IsA("ModuleScript") then
            found = found + 1
            local success, content = pcall(require, child)
            if success then
                working = working + 1
                print(string.format("✅ %s (Type: %s)", child.Name, type(content)))
            else
                print(string.format("❌ %s (Failed to require)", child.Name))
            end
        end
    end
    
    print(string.rep("=", 60))
    print(string.format("📊 Summary: %d found, %d working", found, working))
end

-- Global functions
_G.deepAnalyze = deepAnalyze
_G.quickCheckAll = quickCheckAll
_G.analyzeExperiment = function(name)
    deepAnalyze(name)
end

-- Run quick check
quickCheckAll()

print("\n💡 Available Commands:")
print("_G.deepAnalyze('ExperimentName') - Deep analysis of specific experiment")
print("_G.quickCheckAll() - Quick check of all experiments")
print("_G.analyzeExperiment('CaughtLegendaryExperiment') - Analyze specific experiment")

-- Auto-analyze CaughtLegendaryExperiment
print("\n🎯 Auto-analyzing CaughtLegendaryExperiment...")
deepAnalyze("CaughtLegendaryExperiment")
