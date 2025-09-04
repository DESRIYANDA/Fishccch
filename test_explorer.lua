--// Example usage of Module Explorer
--// Load the module explorer first

local ModuleExplorer = loadstring(readfile("module_explorer.lua"))()

--// Basic usage examples:

-- 1. Explore locations module
print("🌍 EXPLORING LOCATIONS:")
ModuleExplorer:exploreLocations()

wait(2)

-- 2. Explore bait module  
print("\n🎣 EXPLORING BAIT:")
ModuleExplorer:exploreBait()

wait(2)

-- 3. Search for specific modules
print("\n🔍 SEARCHING FOR FISHING RELATED MODULES:")
ModuleExplorer:searchModules("fish")

wait(2)

-- 4. Explore specific module path
print("\n📋 EXPLORING SPECIFIC MODULE:")
ModuleExplorer:printModuleContents("ReplicatedStorage.shared.modules.library.locations")

-- 5. Save module data to file (if writefile available)
ModuleExplorer:saveModuleToFile("ReplicatedStorage.shared.modules.library.locations", "locations_data.json")

-- 6. Show help
print("\n❓ HELP:")
ModuleExplorer:help()
