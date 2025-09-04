--// Test script untuk Data Extractor
--// Jalankan ini di Roblox untuk extract semua data game

-- Load the data extractor
local DataExtractor = loadstring(readfile("data_extractor.lua"))()

-- Extract all data
print("🔍 Starting data extraction process...")
local extractedData = DataExtractor:extractAllData()

-- Print specific data types
print("\n" .. "="*50)
print("EXTRACTED DATA PREVIEW:")
print("="*50)

-- Print first 10 locations
print("\n📍 SAMPLE LOCATIONS:")
local count = 0
for name, data in pairs(extractedData.locations) do
    if count >= 10 then break end
    print("  ", name, ":", tostring(data))
    count = count + 1
end

-- Print first 10 fish
print("\n🐟 SAMPLE FISH:")
count = 0
for name, data in pairs(extractedData.fish) do
    if count >= 10 then break end
    print("  ", name, ":", type(data) == "table" and "Table Data" or tostring(data))
    count = count + 1
end

-- Print NPCs
print("\n🤖 NPCS:")
for name, data in pairs(extractedData.npcs) do
    print("  ", name, "at position:", data.position)
end

-- Print some remotes
print("\n📡 SAMPLE REMOTES:")
count = 0
for _, remote in pairs(extractedData.remotes) do
    if count >= 20 then break end
    if remote.path:find("Bait") or remote.path:find("Shop") or remote.path:find("Purchase") then
        print("  ", remote.type, ":", remote.path)
        count = count + 1
    end
end

-- Save to string format
print("\n💾 Generating data file...")
local dataString = DataExtractor:saveDataToString()

-- Try to save to file (if writefile is available)
pcall(function()
    if writefile then
        writefile("extracted_game_data.lua", dataString)
        print("✅ Data saved to extracted_game_data.lua")
    else
        print("⚠️ writefile not available, data string generated in memory")
    end
end)

print("\n🎉 Data extraction completed!")
print("Total data points extracted:", 
    #extractedData.locations + #extractedData.fish + #extractedData.rods + 
    #extractedData.bait + #extractedData.npcs + #extractedData.remotes)

-- Return data for further use
return extractedData
