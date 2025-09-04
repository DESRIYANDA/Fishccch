-- Universal Module Finder
-- Mencari semua ModuleScript yang mengandung kata kunci tertentu

local keywords = {
    "auto", "fishing", "coin", "afk", "experiment"
}

local foundModules = {}

-- Function untuk mencari modules
local function searchModules(parent, depth)
    depth = depth or 0
    if depth > 10 then return end -- Prevent infinite recursion
    
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("ModuleScript") then
            local name = string.lower(child.Name)
            local path = child:GetFullName()
            
            -- Check if name contains any keywords
            for _, keyword in ipairs(keywords) do
                if string.find(name, keyword) then
                    table.insert(foundModules, {
                        name = child.Name,
                        path = path,
                        object = child
                    })
                    break
                end
            end
        end
        
        -- Recursively search children
        local success = pcall(function()
            searchModules(child, depth + 1)
        end)
    end
end

-- Start search
print("🔍 Searching for relevant ModuleScripts...")
searchModules(game:GetService("ReplicatedStorage"))

-- Display results
print("\n📋 Found " .. #foundModules .. " relevant modules:")
for i, module in ipairs(foundModules) do
    print(string.format("%d. %s", i, module.name))
    print("   Path: " .. module.path)
    
    -- Try to require and show basic info
    local success, content = pcall(require, module.object)
    if success then
        print("   Type: " .. type(content))
        if type(content) == "table" then
            local keys = {}
            for key, _ in pairs(content) do
                table.insert(keys, tostring(key))
            end
            if #keys > 0 then
                print("   Keys: " .. table.concat(keys, ", "))
            end
        end
    else
        print("   Status: Cannot require (may need parameters)")
    end
    print("---")
end

-- Global functions for manual inspection
_G.inspectModule = function(index)
    if foundModules[index] then
        local module = foundModules[index]
        print("Inspecting: " .. module.name)
        print("Path: " .. module.path)
        
        local success, content = pcall(require, module.object)
        if success then
            print("Content:")
            if type(content) == "table" then
                for key, value in pairs(content) do
                    local valueStr = tostring(value)
                    if string.len(valueStr) > 100 then
                        valueStr = string.sub(valueStr, 1, 100) .. "..."
                    end
                    print("  " .. tostring(key) .. ": " .. valueStr)
                end
            else
                print("  " .. tostring(content))
            end
        else
            print("Cannot require this module")
        end
    else
        print("Invalid module index")
    end
end

_G.listModules = function()
    print("Found modules:")
    for i, module in ipairs(foundModules) do
        print(string.format("%d. %s (%s)", i, module.name, module.path))
    end
end

print("\n💡 Commands:")
print("_G.listModules() - List all found modules")
print("_G.inspectModule(number) - Inspect specific module")
print("Example: _G.inspectModule(1)")
