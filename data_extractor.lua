--// Data Extractor Tool for Fisch Game
--// Extracts all available game data from ModuleScripts and game instances

local DataExtractor = {}

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local lp = Players.LocalPlayer

-- Data storage
local ExtractedData = {
    locations = {},
    fish = {},
    rods = {},
    bait = {},
    items = {},
    npcs = {},
    quests = {},
    remotes = {},
    modules = {}
}

--// Extract data from ModuleScripts
function DataExtractor:extractModuleData()
    print("🔍 Extracting data from ModuleScripts...")
    
    -- Extract Locations
    pcall(function()
        local locationsModule = ReplicatedStorage.shared.modules.library.locations
        if locationsModule then
            ExtractedData.locations = require(locationsModule)
            print("✅ Locations data extracted:", #ExtractedData.locations, "locations")
        end
    end)
    
    -- Extract Fish Data
    pcall(function()
        local fishModule = ReplicatedStorage.shared.modules.library.fish
        if fishModule then
            ExtractedData.fish = require(fishModule)
            print("✅ Fish data extracted:", #ExtractedData.fish, "fish types")
        end
    end)
    
    -- Extract Rod Data
    pcall(function()
        local rodsModule = ReplicatedStorage.shared.modules.library.rods
        if rodsModule then
            ExtractedData.rods = require(rodsModule)
            print("✅ Rods data extracted:", #ExtractedData.rods, "rods")
        end
    end)
    
    -- Extract Bait Data
    pcall(function()
        local baitModule = ReplicatedStorage.shared.modules.library.bait
        if baitModule then
            ExtractedData.bait = require(baitModule)
            print("✅ Bait data extracted:", #ExtractedData.bait, "bait types")
        end
    end)
    
    -- Extract Items Data
    pcall(function()
        local itemsModule = ReplicatedStorage.shared.modules.library.items
        if itemsModule then
            ExtractedData.items = require(itemsModule)
            print("✅ Items data extracted:", #ExtractedData.items, "items")
        end
    end)
    
    -- Extract Quest Data
    pcall(function()
        local questsModule = ReplicatedStorage.shared.modules.Quests
        if questsModule then
            for _, questScript in pairs(questsModule:GetChildren()) do
                if questScript:IsA("ModuleScript") then
                    local success, questData = pcall(require, questScript)
                    if success then
                        ExtractedData.quests[questScript.Name] = questData
                    end
                end
            end
            print("✅ Quests data extracted:", #ExtractedData.quests, "quests")
        end
    end)
end

--// Extract NPC data from workspace
function DataExtractor:extractNPCData()
    print("🤖 Extracting NPC data...")
    
    pcall(function()
        local npcsFolder = Workspace.world.npcs
        for _, npc in pairs(npcsFolder:GetChildren()) do
            if npc:FindFirstChild("HumanoidRootPart") then
                ExtractedData.npcs[npc.Name] = {
                    name = npc.Name,
                    position = npc.HumanoidRootPart.Position,
                    cframe = npc.HumanoidRootPart.CFrame,
                    dialog = {}
                }
                
                -- Extract dialog if available
                for _, child in pairs(npc:GetDescendants()) do
                    if child.Name:find("dialog") or child.Name:find("Dialog") then
                        table.insert(ExtractedData.npcs[npc.Name].dialog, child.Name)
                    end
                end
            end
        end
        print("✅ NPCs data extracted:", #ExtractedData.npcs, "NPCs")
    end)
end

--// Extract Remote Events data
function DataExtractor:extractRemoteData()
    print("📡 Extracting Remote Events data...")
    
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            table.insert(ExtractedData.remotes, {
                type = "RemoteEvent",
                name = remote.Name,
                path = remote:GetFullName()
            })
        elseif remote:IsA("RemoteFunction") then
            table.insert(ExtractedData.remotes, {
                type = "RemoteFunction", 
                name = remote.Name,
                path = remote:GetFullName()
            })
        end
    end
    
    print("✅ Remotes data extracted:", #ExtractedData.remotes, "remotes")
end

--// Extract fishing spots
function DataExtractor:extractFishingSpots()
    print("🎣 Extracting Fishing Spots...")
    
    ExtractedData.fishingSpots = {}
    
    -- Look for fishing spot markers
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:find("FishingSpot") or obj.Name:find("fishing") then
            if obj:IsA("Part") or obj:IsA("BasePart") then
                ExtractedData.fishingSpots[obj.Name] = {
                    name = obj.Name,
                    position = obj.Position,
                    cframe = obj.CFrame
                }
            end
        end
    end
    
    print("✅ Fishing spots extracted:", #ExtractedData.fishingSpots, "spots")
end

--// Extract all available ModuleScript names and paths
function DataExtractor:extractModulesList()
    print("📚 Extracting ModuleScripts list...")
    
    for _, module in pairs(ReplicatedStorage:GetDescendants()) do
        if module:IsA("ModuleScript") then
            table.insert(ExtractedData.modules, {
                name = module.Name,
                path = module:GetFullName(),
                parent = module.Parent.Name
            })
        end
    end
    
    print("✅ ModuleScripts list extracted:", #ExtractedData.modules, "modules")
end

--// Save data to string format
function DataExtractor:saveDataToString()
    local dataString = "-- FISCH GAME DATA EXTRACTION\n"
    dataString = dataString .. "-- Generated on: " .. os.date() .. "\n\n"
    
    -- Locations
    dataString = dataString .. "-- LOCATIONS DATA\n"
    dataString = dataString .. "local Locations = {\n"
    for name, data in pairs(ExtractedData.locations) do
        if type(data) == "table" and data.position then
            dataString = dataString .. string.format("    ['%s'] = CFrame.new(%s, %s, %s),\n", 
                name, data.position.X, data.position.Y, data.position.Z)
        end
    end
    dataString = dataString .. "}\n\n"
    
    -- NPCs
    dataString = dataString .. "-- NPCS DATA\n"
    dataString = dataString .. "local NPCs = {\n"
    for name, data in pairs(ExtractedData.npcs) do
        local pos = data.position
        dataString = dataString .. string.format("    ['%s'] = CFrame.new(%s, %s, %s),\n", 
            name, pos.X, pos.Y, pos.Z)
    end
    dataString = dataString .. "}\n\n"
    
    -- Fish
    dataString = dataString .. "-- FISH DATA\n"
    dataString = dataString .. "local Fish = {\n"
    for name, data in pairs(ExtractedData.fish) do
        if type(data) == "table" then
            dataString = dataString .. string.format("    ['%s'] = {\n", name)
            for key, value in pairs(data) do
                if type(value) == "string" then
                    dataString = dataString .. string.format("        %s = '%s',\n", key, value)
                elseif type(value) == "number" then
                    dataString = dataString .. string.format("        %s = %s,\n", key, value)
                end
            end
            dataString = dataString .. "    },\n"
        end
    end
    dataString = dataString .. "}\n\n"
    
    -- Remotes
    dataString = dataString .. "-- REMOTE EVENTS\n"
    dataString = dataString .. "local Remotes = {\n"
    for _, remote in pairs(ExtractedData.remotes) do
        dataString = dataString .. string.format("    {type = '%s', name = '%s', path = '%s'},\n", 
            remote.type, remote.name, remote.path)
    end
    dataString = dataString .. "}\n\n"
    
    return dataString
end

--// Main extraction function
function DataExtractor:extractAllData()
    print("🚀 Starting complete data extraction...")
    
    self:extractModuleData()
    self:extractNPCData() 
    self:extractRemoteData()
    self:extractFishingSpots()
    self:extractModulesList()
    
    print("✅ Data extraction completed!")
    print("📊 Summary:")
    print("   - Locations:", #ExtractedData.locations)
    print("   - Fish:", #ExtractedData.fish) 
    print("   - Rods:", #ExtractedData.rods)
    print("   - Bait:", #ExtractedData.bait)
    print("   - Items:", #ExtractedData.items)
    print("   - NPCs:", #ExtractedData.npcs)
    print("   - Quests:", #ExtractedData.quests)
    print("   - Remotes:", #ExtractedData.remotes)
    print("   - Modules:", #ExtractedData.modules)
    
    return ExtractedData
end

--// Print specific data
function DataExtractor:printLocations()
    print("📍 LOCATIONS:")
    for name, data in pairs(ExtractedData.locations) do
        print("  ", name, ":", data)
    end
end

function DataExtractor:printFish()
    print("🐟 FISH:")
    for name, data in pairs(ExtractedData.fish) do
        print("  ", name, ":", data)
    end
end

function DataExtractor:printNPCs()
    print("🤖 NPCs:")
    for name, data in pairs(ExtractedData.npcs) do
        print("  ", name, "at", data.position)
    end
end

function DataExtractor:printRemotes()
    print("📡 REMOTES:")
    for _, remote in pairs(ExtractedData.remotes) do
        print("  ", remote.type, ":", remote.path)
    end
end

return DataExtractor
