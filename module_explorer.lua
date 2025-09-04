--// Module Explorer Script
--// Untuk membaca isi ModuleScript dari game

local ModuleExplorer = {}

--// Services
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local HttpService = cloneref(game:GetService('HttpService'))

--// Function to safely require a module and get its contents
function ModuleExplorer:getModuleContents(modulePath)
    local success, result = pcall(function()
        -- Navigate to the module using the path
        local pathParts = string.split(modulePath, ".")
        local currentLocation = game
        
        -- Skip "ReplicatedStorage" if it's in the path since we start from game
        local startIndex = 1
        if pathParts[1] == "ReplicatedStorage" then
            currentLocation = ReplicatedStorage
            startIndex = 2
        end
        
        -- Navigate through the path
        for i = startIndex, #pathParts do
            currentLocation = currentLocation:FindFirstChild(pathParts[i])
            if not currentLocation then
                return nil, "Path not found at: " .. pathParts[i]
            end
        end
        
        -- Check if it's a ModuleScript
        if currentLocation.ClassName ~= "ModuleScript" then
            return nil, "Object is not a ModuleScript, it's: " .. currentLocation.ClassName
        end
        
        -- Require the module
        local moduleData = require(currentLocation)
        return moduleData, "Success"
    end)
    
    if success then
        return result
    else
        warn("Failed to get module contents: " .. tostring(result))
        return nil
    end
end

--// Function to print module contents in a readable format
function ModuleExplorer:printModuleContents(modulePath)
    print("🔍 Exploring Module: " .. modulePath)
    print("=" .. string.rep("=", #modulePath + 18))
    
    local moduleData = self:getModuleContents(modulePath)
    
    if moduleData then
        self:printTable(moduleData, 0)
    else
        print("❌ Failed to load module")
    end
end

--// Function to recursively print table contents
function ModuleExplorer:printTable(tbl, indent)
    local indentStr = string.rep("  ", indent)
    
    if type(tbl) ~= "table" then
        print(indentStr .. tostring(tbl))
        return
    end
    
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            print(indentStr .. "📁 " .. tostring(key) .. " = {")
            self:printTable(value, indent + 1)
            print(indentStr .. "}")
        elseif type(value) == "function" then
            print(indentStr .. "🔧 " .. tostring(key) .. " = function")
        elseif type(value) == "userdata" then
            if typeof(value) == "Instance" then
                print(indentStr .. "🎯 " .. tostring(key) .. " = " .. value.ClassName .. " (" .. value.Name .. ")")
            else
                print(indentStr .. "📦 " .. tostring(key) .. " = " .. typeof(value))
            end
        else
            print(indentStr .. "💫 " .. tostring(key) .. " = " .. tostring(value))
        end
    end
end

--// Function to save module contents to file (if writefile is available)
function ModuleExplorer:saveModuleToFile(modulePath, filename)
    local moduleData = self:getModuleContents(modulePath)
    
    if moduleData and writefile then
        local jsonData = HttpService:JSONEncode(moduleData)
        writefile(filename or "module_data.json", jsonData)
        print("✅ Module data saved to: " .. (filename or "module_data.json"))
    else
        print("❌ Cannot save module data (writefile not available or module failed to load)")
    end
end

--// Function to explore specific known modules
function ModuleExplorer:exploreKnownModules()
    local knownModules = {
        "ReplicatedStorage.shared.modules.library.locations",
        "ReplicatedStorage.shared.modules.library.fish",
        "ReplicatedStorage.shared.modules.library.bait",
        "ReplicatedStorage.shared.modules.library.rods",
        "ReplicatedStorage.shared.modules.library.items",
        "ReplicatedStorage.shared.modules.library.treasures",
        "ReplicatedStorage.shared.modules.library.recipes"
    }
    
    for _, modulePath in ipairs(knownModules) do
        print("\n" .. string.rep("=", 60))
        self:printModuleContents(modulePath)
        wait(1) -- Small delay to avoid spam
    end
end

--// Function to search for modules containing specific keywords
function ModuleExplorer:searchModules(keyword)
    print("🔍 Searching for modules containing: " .. keyword)
    
    local function searchInContainer(container, path)
        for _, child in pairs(container:GetChildren()) do
            if child.ClassName == "ModuleScript" and string.find(child.Name:lower(), keyword:lower()) then
                print("📋 Found: " .. path .. "." .. child.Name)
                
                -- Try to explore this module
                pcall(function()
                    print("   Contents preview:")
                    local moduleData = require(child)
                    if type(moduleData) == "table" then
                        local count = 0
                        for key, _ in pairs(moduleData) do
                            count = count + 1
                            if count <= 5 then -- Show first 5 keys
                                print("     • " .. tostring(key))
                            end
                        end
                        if count > 5 then
                            print("     ... and " .. (count - 5) .. " more items")
                        end
                    end
                end)
            end
            
            if #child:GetChildren() > 0 then
                searchInContainer(child, path .. "." .. child.Name)
            end
        end
    end
    
    searchInContainer(ReplicatedStorage, "ReplicatedStorage")
end

--// Function to extract all game data at once
function ModuleExplorer:extractAllGameData()
    print("🎮 EXTRACTING ALL GAME DATA...")
    print("=" .. string.rep("=", 30))
    
    local gameData = {
        locations = {},
        bait = {},
        fish = {},
        rods = {},
        items = {},
        treasures = {},
        recipes = {},
        zones = {}
    }
    
    -- Extract locations
    pcall(function()
        gameData.locations = self:getModuleContents("ReplicatedStorage.shared.modules.library.locations")
        print("✅ Locations data extracted")
    end)
    
    -- Extract bait
    pcall(function()
        gameData.bait = self:getModuleContents("ReplicatedStorage.shared.modules.library.bait")
        print("✅ Bait data extracted")
    end)
    
    -- Extract fish
    pcall(function()
        gameData.fish = self:getModuleContents("ReplicatedStorage.shared.modules.library.fish")
        print("✅ Fish data extracted")
    end)
    
    -- Extract rods
    pcall(function()
        gameData.rods = self:getModuleContents("ReplicatedStorage.shared.modules.library.rods")
        print("✅ Rods data extracted")
    end)
    
    -- Extract items
    pcall(function()
        gameData.items = self:getModuleContents("ReplicatedStorage.shared.modules.library.items")
        print("✅ Items data extracted")
    end)
    
    -- Extract treasures
    pcall(function()
        gameData.treasures = self:getModuleContents("ReplicatedStorage.shared.modules.library.treasures")
        print("✅ Treasures data extracted")
    end)
    
    -- Extract recipes
    pcall(function()
        gameData.recipes = self:getModuleContents("ReplicatedStorage.shared.modules.library.recipes")
        print("✅ Recipes data extracted")
    end)
    
    -- Extract fish zones
    pcall(function()
        gameData.zones = self:getModuleContents("ReplicatedStorage.shared.modules.library.fish.zones")
        print("✅ Fish zones data extracted")
    end)
    
    -- Save all data to file
    if writefile then
        local jsonData = HttpService:JSONEncode(gameData)
        writefile("complete_game_data.json", jsonData)
        print("💾 Complete game data saved to: complete_game_data.json")
    end
    
    return gameData
end

--// Function to get bait crate prices and info
function ModuleExplorer:getBaitCrateInfo()
    local baitData = self:getModuleContents("ReplicatedStorage.shared.modules.library.bait")
    
    if baitData then
        print("🎣 BAIT CRATE INFORMATION:")
        print("=" .. string.rep("=", 25))
        
        for baitName, baitInfo in pairs(baitData) do
            if type(baitInfo) == "table" then
                print("📦 " .. baitName)
                if baitInfo.price then
                    print("   💰 Price: $" .. baitInfo.price)
                end
                if baitInfo.sellPrice then
                    print("   💵 Sell Price: $" .. baitInfo.sellPrice)
                end
                if baitInfo.rarity then
                    print("   ⭐ Rarity: " .. baitInfo.rarity)
                end
                if baitInfo.description then
                    print("   📝 Description: " .. baitInfo.description)
                end
                print("")
            end
        end
    end
end

--// Function to get fish information with zones
function ModuleExplorer:getFishInfo()
    local fishData = self:getModuleContents("ReplicatedStorage.shared.modules.library.fish")
    
    if fishData then
        print("🐟 FISH INFORMATION:")
        print("=" .. string.rep("=", 20))
        
        for fishName, fishInfo in pairs(fishData) do
            if type(fishInfo) == "table" and fishInfo.rarity then
                print("🐟 " .. fishName)
                print("   ⭐ Rarity: " .. fishInfo.rarity)
                if fishInfo.price then
                    print("   💰 Price: $" .. fishInfo.price)
                end
                if fishInfo.zones then
                    print("   🌍 Zones: " .. table.concat(fishInfo.zones, ", "))
                end
                if fishInfo.weather then
                    print("   🌤️ Weather: " .. fishInfo.weather)
                end
                if fishInfo.season then
                    print("   📅 Season: " .. fishInfo.season)
                end
                print("")
            end
        end
    end
end

--// Quick commands for easy use
function ModuleExplorer:help()
    print("🎯 MODULE EXPLORER COMMANDS:")
    print("=" .. string.rep("=", 30))
    print("📋 Basic Exploration:")
    print("  ModuleExplorer:printModuleContents('path') - Explore specific module")
    print("  ModuleExplorer:exploreKnownModules() - Explore all known modules")
    print("  ModuleExplorer:searchModules('keyword') - Search for modules by keyword")
    print("")
    print("🎮 Game Data Extraction:")
    print("  ModuleExplorer:extractAllGameData() - Extract all game data at once")
    print("  ModuleExplorer:getBaitCrateInfo() - Get bait prices and info")
    print("  ModuleExplorer:getFishInfo() - Get fish data with zones")
    print("")
    print("💾 File Operations:")
    print("  ModuleExplorer:saveModuleToFile('path', 'filename.json') - Save module to file")
    print("")
    print("🔍 Quick Access:")
    print("  ModuleExplorer:getModuleContents('path') - Get raw module data")
    print("")
    print("📁 Example Paths:")
    print("  'ReplicatedStorage.shared.modules.library.locations'")
    print("  'ReplicatedStorage.shared.modules.library.bait'")
    print("  'ReplicatedStorage.shared.modules.library.fish'")
    print("  'ReplicatedStorage.shared.modules.library.rods'")
    print("  'ReplicatedStorage.shared.modules.library.items'")
    print("=" .. string.rep("=", 30))
end

return ModuleExplorer
