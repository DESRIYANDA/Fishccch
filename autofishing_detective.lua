-- AutoFishing Module Detective
-- Script khusus untuk mencari dan menganalisis module AutoFishing

-- Output storage for saving to file
local outputLog = {}
local function logOutput(text)
    print(text)
    table.insert(outputLog, text)
end

logOutput("🔍 AutoFishing Module Detective Starting...")

-- Daftar path yang mungkin untuk AutoFishing
local autoFishingPaths = {
    "ReplicatedStorage.shared.modules.ABTestExperiments.Experiments.AutoFishingExperiment",
    "ReplicatedStorage.client.legacyControllers.AutoFishingController",
    "ReplicatedStorage.client.legacyControllers.AFKFishingController",
    "ReplicatedStorage.client.legacyControllers.ABTestController"
}

-- Function untuk navigate ke path
local function navigateToPath(pathString)
    local parts = string.split(pathString, ".")
    local current = game
    
    for i, part in ipairs(parts) do
        local child = current:FindFirstChild(part)
        if child then
            current = child
        else
            return nil, "Failed at: " .. part .. " (step " .. i .. ")"
        end
    end
    
    return current, "Success"
end

-- Function untuk analyze module
local function analyzeModule(module, pathString)
    logOutput("\n🎯 Analyzing: " .. pathString)
    logOutput("Object Type: " .. module.ClassName)
    
    if module:IsA("ModuleScript") then
        logOutput("✅ Is ModuleScript")
        
        -- Try to require
        local success, content = pcall(require, module)
        if success then
            logOutput("✅ Successfully required")
            logOutput("Content Type: " .. type(content))
            
            if type(content) == "table" then
                logOutput("📋 Table Contents:")
                local count = 0
                for key, value in pairs(content) do
                    count = count + 1
                    if count <= 10 then -- Limit output
                        local valueType = type(value)
                        local valueStr = tostring(value)
                        
                        if valueType == "function" then
                            valueStr = "function()"
                        elseif valueType == "table" then
                            valueStr = "table{...}"
                        elseif string.len(valueStr) > 50 then
                            valueStr = string.sub(valueStr, 1, 50) .. "..."
                        end
                        
                        logOutput(string.format("  %s: %s (%s)", 
                            tostring(key), valueStr, valueType))
                    end
                end
                
                if count > 10 then
                    logOutput(string.format("  ... and %d more items", count - 10))
                end
                
                -- Look for specific AutoFishing related keys
                local autoFishingKeys = {}
                for key, _ in pairs(content) do
                    local keyLower = string.lower(tostring(key))
                    if string.find(keyLower, "auto") or 
                       string.find(keyLower, "fish") or 
                       string.find(keyLower, "coin") or
                       string.find(keyLower, "enable") or
                       string.find(keyLower, "active") then
                        table.insert(autoFishingKeys, key)
                    end
                end
                
                if #autoFishingKeys > 0 then
                    logOutput("🎣 AutoFishing-related keys found:")
                    for _, key in ipairs(autoFishingKeys) do
                        logOutput("  🔑 " .. tostring(key))
                    end
                end
            else
                logOutput("📝 Content: " .. tostring(content))
            end
        else
            logOutput("❌ Failed to require: " .. tostring(content))
        end
    else
        logOutput("❌ Not a ModuleScript")
        
        -- If it's a folder, list children
        if module:IsA("Folder") then
            logOutput("📁 Folder contents:")
            for _, child in ipairs(module:GetChildren()) do
                logOutput("  - " .. child.Name .. " (" .. child.ClassName .. ")")
            end
        end
    end
end

-- Search all paths
local foundModules = {}
for _, path in ipairs(autoFishingPaths) do
    logOutput("\n🔍 Checking path: " .. path)
    
    local module, status = navigateToPath(path)
    if module then
        logOutput("✅ Found: " .. module.Name)
        table.insert(foundModules, {path = path, module = module})
        analyzeModule(module, path)
    else
        logOutput("❌ " .. status)
    end
end

-- Additional search in common locations
logOutput("\n🔍 Additional search in key locations...")

local searchLocations = {
    game:GetService("ReplicatedStorage").shared.modules,
    game:GetService("ReplicatedStorage").client.legacyControllers
}

for _, location in ipairs(searchLocations) do
    local success = pcall(function()
        for _, child in ipairs(location:GetChildren()) do
            local name = string.lower(child.Name)
            if (string.find(name, "auto") and string.find(name, "fish")) or
               (string.find(name, "afk") and string.find(name, "fish")) then
                logOutput("🎯 Additional find: " .. child:GetFullName())
                analyzeModule(child, child:GetFullName())
            end
        end
    end)
end

-- Global functions for further inspection
_G.inspectAutoFishing = function(index)
    if foundModules[index] then
        local item = foundModules[index]
        logOutput("Re-analyzing: " .. item.path)
        analyzeModule(item.module, item.path)
    else
        logOutput("Invalid index. Available: 1-" .. #foundModules)
    end
end

_G.listAutoFishingModules = function()
    logOutput("Found AutoFishing modules:")
    for i, item in ipairs(foundModules) do
        logOutput(string.format("%d. %s", i, item.path))
    end
end

-- Function to save output to clipboard/file
_G.saveToFile = function()
    local output = table.concat(outputLog, "\n")
    
    -- Try to copy to clipboard (works in some executors)
    local success = pcall(function()
        setclipboard(output)
        logOutput("✅ Output copied to clipboard!")
    end)
    
    if not success then
        logOutput("❌ Clipboard not available")
    end
    
    -- Print the output for manual copying
    logOutput("\n📄 ===== FILE CONTENT START =====")
    logOutput("Copy everything below this line and paste to a .txt file:")
    logOutput("=" .. string.rep("=", 50))
    for _, line in ipairs(outputLog) do
        print(line) -- Use print here to ensure it shows in console
    end
    logOutput("=" .. string.rep("=", 50))
    logOutput("📄 ===== FILE CONTENT END =====")
    
    return output
end

-- Function to get clean output (without emojis for better compatibility)
_G.saveToFileClean = function()
    local cleanOutput = {}
    for _, line in ipairs(outputLog) do
        -- Remove emojis and special characters
        local cleanLine = string.gsub(line, "[🔍🎯✅❌📋📝📁🎣🔑💡]", "")
        table.insert(cleanOutput, cleanLine)
    end
    
    local output = table.concat(cleanOutput, "\n")
    
    -- Try to copy to clipboard
    local success = pcall(function()
        setclipboard(output)
        logOutput("✅ Clean output copied to clipboard!")
    end)
    
    if not success then
        logOutput("❌ Clipboard not available")
    end
    
    -- Print clean output
    logOutput("\n📄 ===== CLEAN FILE CONTENT START =====")
    for _, line in ipairs(cleanOutput) do
        print(line)
    end
    logOutput("📄 ===== CLEAN FILE CONTENT END =====")
    
    return output
end

logOutput("\n🎯 Search completed!")
logOutput("Found " .. #foundModules .. " AutoFishing-related modules")
logOutput("\n💡 Commands:")
logOutput("_G.listAutoFishingModules() - List found modules")
logOutput("_G.inspectAutoFishing(number) - Re-inspect module")
logOutput("_G.saveToFile() - Save output to file (with emojis)")
logOutput("_G.saveToFileClean() - Save output to file (clean version)")
logOutput("\n📋 How to save:")
logOutput("1. Run _G.saveToFile() or _G.saveToFileClean()")
logOutput("2. Copy the output from console")
logOutput("3. Paste into a new .txt file")
logOutput("4. Save the file as 'autofishing_analysis.txt'")
