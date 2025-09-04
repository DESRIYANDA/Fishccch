-- Module Content Extractor
-- Script untuk mengekstrak isi ModuleScript

local modules = {
    "AutoFishingExperiment",
    "AutoFishingController", 
    "AFKFishingController",
    "ABTestExperiments"
}

local function extractModuleContent(modulePath, moduleName)
    local success, result = pcall(function()
        local module = game:GetService("ReplicatedStorage"):FindFirstChild(modulePath, true)
        if module and module:IsA("ModuleScript") then
            local content = require(module)
            return content
        end
        return nil
    end)
    
    if success and result then
        print("=== " .. moduleName .. " ===")
        print("Path: " .. modulePath)
        print("Content:")
        
        if type(result) == "table" then
            for key, value in pairs(result) do
                print("  " .. tostring(key) .. ": " .. tostring(value))
            end
        else
            print("  " .. tostring(result))
        end
        print("\n")
    else
        print("Failed to extract: " .. moduleName)
    end
end

-- Extract specific modules
print("Starting module extraction...")

-- 1. AutoFishing Experiment
extractModuleContent("AutoFishingExperiment", "AutoFishing Experiment")

-- 2. AutoFishing Controller  
extractModuleContent("AutoFishingController", "AutoFishing Controller")

-- 3. AFK Fishing Controller
extractModuleContent("AFKFishingController", "AFK Fishing Controller")

-- Alternative paths
local paths = {
    "ReplicatedStorage.shared.modules.ABTestExperiments.Experiments.AutoFishingExperiment",
    "ReplicatedStorage.client.legacyControllers.AutoFishingController",
    "ReplicatedStorage.client.legacyControllers.AFKFishingController"
}

for _, path in ipairs(paths) do
    local success, module = pcall(function()
        local parts = string.split(path, ".")
        local current = game
        
        for _, part in ipairs(parts) do
            current = current:FindFirstChild(part)
            if not current then break end
        end
        
        return current
    end)
    
    if success and module and module:IsA("ModuleScript") then
        print("Found module at: " .. path)
        local contentSuccess, content = pcall(require, module)
        if contentSuccess then
            print("Content type: " .. type(content))
            if type(content) == "table" then
                print("Keys:")
                for key, _ in pairs(content) do
                    print("  - " .. tostring(key))
                end
            end
        end
        print("---")
    end
end

print("Module extraction completed!")
